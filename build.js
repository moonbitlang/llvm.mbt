'use strict';

const crypto = require('node:crypto');
const fs = require('node:fs');
const fsp = require('node:fs/promises');
const https = require('node:https');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { Transform } = require('node:stream');
const { pipeline } = require('node:stream/promises');

// 这份脚本是 llvm.mbt 当前的原生依赖安装器。
//
// Moon 会在构建开始前运行它，并通过标准输入传入一份 JSON。脚本完成后，
// 必须在标准输出中返回 Moon 能识别的 JSON。正因为 stdout 是协议的一部分，
// 所有下载进度、缓存提示和错误说明都必须写到 stderr，不能使用 console.log。

const CACHE_SCHEMA_VERSION = 1;
const MAX_REDIRECTS = 10;
const DOWNLOAD_ATTEMPTS = 3;
const DOWNLOAD_IDLE_TIMEOUT_MS = 30_000;

// 每个平台产物的 URL 和摘要都固定在发布出去的 llvm.mbt 源码中。
// `.sha256` Release 附件方便人工核对，但不能在构建时把它当作信任根：
// 如果压缩包和校验文件都从同一个可变地址下载，攻击者可以同时替换二者。
// 因此 build.js 直接内置我们审核过的摘要。
const ARTIFACTS = Object.freeze({
  'darwin-arm64': Object.freeze({
    artifact: 'llvm-22.1.0-r1-macos-arm64',
    llvmVersion: '22.1.0',
    revision: 'r1',
    platform: 'darwin-arm64',
    host: 'arm64-apple-darwin',
    minimumMacOSVersion: '11.0',
    archiveName: 'llvm-22.1.0-r1-macos-arm64.tar.xz',
    archiveSize: 30_702_924,
    archiveSha256:
      'f34d05b3ba9568c1f4bd48d1274f08a7865cf9ae227bd581318fba5964432565',
    staticLibrary: 'lib/libLLVM-mbt.a',
    staticLibrarySize: 208_409_616,
    staticLibrarySha256:
      '929ce44df61216c25af969aea1a1714c1f17250277253da012afe126ef2c9b79',
    includeDirectory: 'include',
    systemLinkFlags: Object.freeze(['-lm', '-lc++']),
    url:
      'https://github.com/moonbitlang/llvm.mbt/releases/download/' +
      'llvm-22.1.0/llvm-22.1.0-r1-macos-arm64.tar.xz',
  }),
  // Node.js 把 AMD64/x86_64 统一称为 `x64`，所以这里的键使用
  // `linux-x64`；产物名称和缓存目录仍使用更常见的 `x86_64`。
  'linux-x64': Object.freeze({
    artifact: 'llvm-22.1.0-r1-linux-x86_64',
    llvmVersion: '22.1.0',
    revision: 'r1',
    platform: 'linux-x86_64',
    host: 'x86_64-unknown-linux-gnu',
    minimumGlibcVersion: '2.31',
    archiveName: 'llvm-22.1.0-r1-linux-x86_64.tar.xz',
    archiveSize: 43_236_400,
    archiveSha256:
      '49b988f2459d84cae7fcb3c0627d27aaa7b550681395c0b42283d09609b2ee59',
    staticLibrary: 'lib/libLLVM-mbt.a',
    staticLibrarySize: 336_001_376,
    staticLibrarySha256:
      'fde96a4a4c3fe028a94fc68158a421a0d5c1f2abcf82fe52a1a6cfa74d2498e8',
    includeDirectory: 'include',
    systemLinkFlags: Object.freeze([
      '-lrt',
      '-ldl',
      '-lpthread',
      '-lm',
      '-lstdc++',
      '-pthread',
    ]),
    url:
      'https://github.com/moonbitlang/llvm.mbt/releases/download/' +
      'llvm-22.1.0/llvm-22.1.0-r1-linux-x86_64.tar.xz',
  }),
});

class CacheValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'CacheValidationError';
  }
}

function report(message) {
  console.error(`[llvm.mbt] ${message}`);
}

function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function pathExists(filename) {
  try {
    await fsp.access(filename);
    return true;
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      return false;
    }
    throw error;
  }
}

// Moon 当前把构建环境快照放在标准输入 JSON 的 `env` 字段中。
// 直接运行 build.js 做诊断时可能没有标准输入，所以这里保留 process.env
// 作为后备；Moon 正常调用时仍优先使用它明确传入的环境快照。
async function readBuildInput() {
  let source = '';
  process.stdin.setEncoding('utf8');
  for await (const chunk of process.stdin) {
    source += chunk;
  }

  if (source.trim() === '') {
    return { env: { ...process.env } };
  }

  let input;
  try {
    input = JSON.parse(source);
  } catch (error) {
    throw new Error(`无法解析 Moon 传给 build.js 的 JSON：${error.message}`);
  }

  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw new Error('Moon 传给 build.js 的输入不是 JSON 对象');
  }
  if (!input.env || typeof input.env !== 'object' || Array.isArray(input.env)) {
    input.env = { ...process.env };
  }
  return input;
}

function resolveMoonHome(input) {
  const configured = input.env.MOON_HOME;
  if (typeof configured === 'string' && configured.length > 0) {
    // 最终链接参数必须使用绝对路径。即使用户把 MOON_HOME 写成相对路径，
    // 这里也先按照 build.js 的当前工作目录解析成绝对路径。
    return path.resolve(configured);
  }

  const userHome = os.homedir();
  if (!userHome) {
    throw new Error('没有设置 MOON_HOME，并且无法确定当前用户的 home 目录');
  }
  return path.join(userHome, '.moon');
}

function selectArtifact() {
  const platform = `${process.platform}-${process.arch}`;
  const artifact = ARTIFACTS[platform];
  if (artifact) {
    return artifact;
  }

  const supported = Object.keys(ARTIFACTS).join(', ');
  throw new Error(
    `当前平台 ${platform} 没有 llvm.mbt 预构建 LLVM 产物；` +
      `当前支持的平台：${supported}。为了保证 LLVM 版本可复现，` +
      '这里不会回退到系统 llvm-config。',
  );
}

function compareVersions(left, right) {
  const leftParts = left.split('.').map((part) => Number.parseInt(part, 10));
  const rightParts = right.split('.').map((part) => Number.parseInt(part, 10));
  const length = Math.max(leftParts.length, rightParts.length);
  for (let index = 0; index < length; index += 1) {
    const difference = (leftParts[index] || 0) - (rightParts[index] || 0);
    if (difference !== 0) {
      return difference;
    }
  }
  return 0;
}

// Linux 产物以 glibc 2.31 为兼容基线。musl 系统也会被 Node 报告成“没有
// glibc 版本”；与其等到最终链接或运行时给出模糊错误，不如在下载 41 MiB
// 之前就明确拒绝。这个检查只约束 Linux，不影响 macOS。
function validateHostCompatibility(artifact) {
  if (!artifact.minimumGlibcVersion) {
    return;
  }

  const reportHeader = process.report?.getReport?.().header;
  const runtimeVersion = reportHeader && reportHeader.glibcVersionRuntime;
  if (!runtimeVersion) {
    throw new Error(
      `当前 Linux 环境无法识别 glibc；${artifact.artifact} 只支持 ` +
        `glibc ${artifact.minimumGlibcVersion} 或更高版本，不支持 musl。`,
    );
  }
  if (compareVersions(runtimeVersion, artifact.minimumGlibcVersion) < 0) {
    throw new Error(
      `当前 glibc ${runtimeVersion} 低于 ${artifact.artifact} 要求的 ` +
        `${artifact.minimumGlibcVersion}。`,
    );
  }
}

function cachePaths(moonHome, artifact) {
  const cacheRoot = path.join(moonHome, 'cache', 'lib', 'llvm.mbt');
  const versionRoot = path.join(
    cacheRoot,
    `${artifact.llvmVersion}-${artifact.revision}`,
    artifact.platform,
  );
  const installRoot = path.join(
    versionRoot,
    `sha256-${artifact.archiveSha256}`,
  );
  return { cacheRoot, versionRoot, installRoot };
}

async function sha256File(filename) {
  const hash = crypto.createHash('sha256');
  const input = fs.createReadStream(filename);

  return new Promise((resolve, reject) => {
    input.on('data', (chunk) => hash.update(chunk));
    input.on('error', reject);
    input.on('end', () => resolve(hash.digest('hex')));
  });
}

async function readJsonFile(filename, description) {
  let source;
  try {
    source = await fsp.readFile(filename, 'utf8');
  } catch (error) {
    throw new CacheValidationError(`无法读取${description} ${filename}：${error.message}`);
  }

  try {
    return JSON.parse(source);
  } catch (error) {
    throw new CacheValidationError(`${description}不是有效 JSON：${error.message}`);
  }
}

function requireManifestField(condition, message) {
  if (!condition) {
    throw new CacheValidationError(message);
  }
}

// 解压后的静态库也有自己的 SHA-256。冷缓存安装时同时检查压缩包和
// libLLVM-mbt.a，命中缓存时则重新检查静态库。这样不仅能发现下载损坏，
// 也能发现用户手工修改缓存或磁盘损坏。
async function validateInstalledArtifact(installRoot, artifact, requireMarker) {
  const manifestPath = path.join(installRoot, 'manifest.json');
  const manifest = await readJsonFile(manifestPath, 'LLVM 产物清单');

  requireManifestField(
    manifest.schema_version === 1,
    `不支持的 LLVM 产物清单版本：${manifest.schema_version}`,
  );
  requireManifestField(
    manifest.artifact === artifact.artifact,
    `LLVM 产物名称不匹配：期望 ${artifact.artifact}，实际 ${manifest.artifact}`,
  );
  requireManifestField(
    manifest.llvm_version === artifact.llvmVersion,
    `LLVM 版本不匹配：期望 ${artifact.llvmVersion}，实际 ${manifest.llvm_version}`,
  );
  requireManifestField(
    manifest.artifact_revision === artifact.revision,
    `LLVM 产物修订号不匹配：期望 ${artifact.revision}，实际 ${manifest.artifact_revision}`,
  );
  requireManifestField(
    manifest.host === artifact.host,
    `LLVM 产物 host 不匹配：期望 ${artifact.host}，实际 ${manifest.host}`,
  );
  if (artifact.minimumMacOSVersion) {
    requireManifestField(
      manifest.minimum_macos_version === artifact.minimumMacOSVersion,
      'LLVM 产物的最低 macOS 版本与 build.js 中记录的不一致',
    );
  }
  if (artifact.minimumGlibcVersion) {
    requireManifestField(
      manifest.minimum_glibc_version === artifact.minimumGlibcVersion,
      'LLVM 产物的最低 glibc 版本与 build.js 中记录的不一致',
    );
  }
  requireManifestField(
    manifest.include_dir === artifact.includeDirectory,
    'LLVM 产物的 include 目录与 build.js 中记录的不一致',
  );
  requireManifestField(
    manifest.static_library === artifact.staticLibrary,
    'LLVM 产物的静态库路径与 build.js 中记录的不一致',
  );
  requireManifestField(
    manifest.static_library_sha256 === artifact.staticLibrarySha256,
    'LLVM 产物清单中的静态库 SHA-256 与 build.js 中记录的不一致',
  );
  requireManifestField(
    JSON.stringify(manifest.system_link_flags) ===
      JSON.stringify(artifact.systemLinkFlags),
    'LLVM 产物的系统链接参数与 build.js 中记录的不一致',
  );

  const includeDirectory = path.join(installRoot, artifact.includeDirectory);
  let includeStat;
  try {
    includeStat = await fsp.lstat(includeDirectory);
  } catch (error) {
    throw new CacheValidationError(`LLVM include 目录不可用：${error.message}`);
  }
  requireManifestField(includeStat.isDirectory(), 'LLVM include 路径不是目录');

  const staticLibrary = path.join(installRoot, artifact.staticLibrary);
  let libraryStat;
  try {
    libraryStat = await fsp.lstat(staticLibrary);
  } catch (error) {
    throw new CacheValidationError(`LLVM 静态库不可用：${error.message}`);
  }
  requireManifestField(libraryStat.isFile(), 'LLVM 静态库路径不是普通文件');
  requireManifestField(
    libraryStat.size === artifact.staticLibrarySize,
    `LLVM 静态库大小不匹配：期望 ${artifact.staticLibrarySize} 字节，` +
      `实际 ${libraryStat.size} 字节`,
  );

  const librarySha256 = await sha256File(staticLibrary);
  requireManifestField(
    librarySha256 === artifact.staticLibrarySha256,
    `LLVM 静态库 SHA-256 不匹配：期望 ${artifact.staticLibrarySha256}，` +
      `实际 ${librarySha256}`,
  );

  if (requireMarker) {
    const markerPath = path.join(installRoot, '.complete.json');
    const marker = await readJsonFile(markerPath, 'LLVM 缓存完成标记');
    requireManifestField(
      marker.cache_schema_version === CACHE_SCHEMA_VERSION,
      `不支持的 llvm.mbt 缓存格式：${marker.cache_schema_version}`,
    );
    requireManifestField(
      marker.artifact === artifact.artifact,
      'LLVM 缓存完成标记中的产物名称不匹配',
    );
    requireManifestField(
      marker.archive_sha256 === artifact.archiveSha256,
      'LLVM 缓存完成标记中的压缩包 SHA-256 不匹配',
    );
    requireManifestField(
      marker.static_library_sha256 === artifact.staticLibrarySha256,
      'LLVM 缓存完成标记中的静态库 SHA-256 不匹配',
    );
  }

  return { includeDirectory, staticLibrary };
}

function downloadOnce(url, destination, expectedSize, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    let parsedUrl;
    try {
      parsedUrl = new URL(url);
    } catch (error) {
      reject(new Error(`无效的 LLVM 下载地址 ${url}：${error.message}`));
      return;
    }

    // 固定摘要能够发现内容被替换，而只允许 HTTPS 可以避免无意间把
    // GitHub 的下载重定向降级成明文 HTTP。
    if (parsedUrl.protocol !== 'https:') {
      reject(new Error(`拒绝通过非 HTTPS 地址下载 LLVM：${url}`));
      return;
    }

    const request = https.get(
      parsedUrl,
      {
        headers: {
          'User-Agent': 'llvm.mbt-build.js/1',
          Accept: 'application/octet-stream',
        },
      },
      (response) => {
        const statusCode = response.statusCode || 0;
        const location = response.headers.location;

        if ([301, 302, 303, 307, 308].includes(statusCode) && location) {
          response.resume();
          if (redirectCount >= MAX_REDIRECTS) {
            reject(new Error(`LLVM 下载重定向超过 ${MAX_REDIRECTS} 次`));
            return;
          }
          const redirected = new URL(location, parsedUrl).toString();
          downloadOnce(redirected, destination, expectedSize, redirectCount + 1).then(
            resolve,
            reject,
          );
          return;
        }

        if (statusCode !== 200) {
          response.resume();
          reject(new Error(`LLVM 下载请求返回 HTTP ${statusCode}`));
          return;
        }

        const contentLength = response.headers['content-length'];
        if (
          contentLength !== undefined &&
          Number.parseInt(contentLength, 10) !== expectedSize
        ) {
          response.resume();
          reject(
            new Error(
              `LLVM 下载大小不匹配：期望 ${expectedSize} 字节，` +
                `服务器报告 ${contentLength} 字节`,
            ),
          );
          return;
        }

        let received = 0;
        const hash = crypto.createHash('sha256');
        const verifier = new Transform({
          transform(chunk, encoding, callback) {
            received += chunk.length;
            if (received > expectedSize) {
              callback(
                new Error(
                  `LLVM 下载超过预期大小 ${expectedSize} 字节，已中止下载`,
                ),
              );
              return;
            }
            hash.update(chunk);
            callback(null, chunk);
          },
        });

        const output = fs.createWriteStream(destination, { flags: 'wx' });
        pipeline(response, verifier, output).then(
          () => {
            if (received !== expectedSize) {
              reject(
                new Error(
                  `LLVM 下载不完整：期望 ${expectedSize} 字节，实际 ${received} 字节`,
                ),
              );
              return;
            }
            resolve({ bytes: received, sha256: hash.digest('hex') });
          },
          reject,
        );
      },
    );

    // 这是“连续 30 秒没有网络活动”超时，而不是把整个下载限制在 30 秒内。
    request.setTimeout(DOWNLOAD_IDLE_TIMEOUT_MS, () => {
      request.destroy(new Error('LLVM 下载连续 30 秒没有收到数据'));
    });
    request.on('error', reject);
  });
}

async function downloadAndVerify(artifact, archivePath) {
  for (let attempt = 1; attempt <= DOWNLOAD_ATTEMPTS; attempt += 1) {
    await fsp.rm(archivePath, { force: true });
    try {
      report(
        `下载 ${artifact.archiveName}（${artifact.archiveSize} 字节，` +
          `第 ${attempt}/${DOWNLOAD_ATTEMPTS} 次尝试）`,
      );
      const result = await downloadOnce(
        artifact.url,
        archivePath,
        artifact.archiveSize,
      );
      if (result.sha256 !== artifact.archiveSha256) {
        throw new Error(
          `LLVM 压缩包 SHA-256 不匹配：期望 ${artifact.archiveSha256}，` +
            `实际 ${result.sha256}`,
        );
      }
      report('LLVM 压缩包下载完成，SHA-256 校验通过');
      return;
    } catch (error) {
      await fsp.rm(archivePath, { force: true });
      if (attempt === DOWNLOAD_ATTEMPTS) {
        throw error;
      }
      report(`本次下载失败：${error.message}；稍后重试`);
      await delay(500 * attempt);
    }
  }
}

function extractArchive(archivePath, destination) {
  // macOS 的 bsdtar 和 Linux 的 GNU tar 都会根据文件格式自动调用 xz
  // 解压，但不同系统会把 tar 放在 /usr/bin 或 /bin，因此通过 PATH 查找。
  // 参数通过 spawnSync 的数组传递，不经过 shell，路径中有空格或引号也
  // 不会被当成命令的一部分。压缩包通过固定 SHA-256 验证后才会进入解压。
  const result = spawnSync(
    'tar',
    ['-xf', archivePath, '-C', destination],
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] },
  );

  if (result.error) {
    throw new Error(`无法启动 tar：${result.error.message}`);
  }
  if (result.status !== 0) {
    const detail = (result.stderr || result.stdout || '').trim();
    throw new Error(`LLVM 压缩包解压失败${detail ? `：${detail}` : ''}`);
  }
}

async function writeCompletionMarker(installRoot, artifact) {
  const marker = {
    cache_schema_version: CACHE_SCHEMA_VERSION,
    artifact: artifact.artifact,
    archive_sha256: artifact.archiveSha256,
    static_library_sha256: artifact.staticLibrarySha256,
    installed_at: new Date().toISOString(),
  };
  await fsp.writeFile(
    path.join(installRoot, '.complete.json'),
    `${JSON.stringify(marker, null, 2)}\n`,
    'utf8',
  );
}

async function quarantineInvalidCache(installRoot) {
  const quarantine = `${installRoot}.corrupt-${Date.now()}-${process.pid}`;
  try {
    await fsp.rename(installRoot, quarantine);
    report(`已把损坏的缓存移到 ${quarantine}`);
    return quarantine;
  } catch (error) {
    // 另一个并发进程可能已经移走了同一个目录；调用者会重新检查最终路径。
    if (error && error.code === 'ENOENT') {
      return null;
    }
    throw new Error(`无法隔离损坏的 LLVM 缓存 ${installRoot}：${error.message}`);
  }
}

async function installArtifact(paths, artifact) {
  await fsp.mkdir(paths.cacheRoot, { recursive: true });
  await fsp.mkdir(paths.versionRoot, { recursive: true });

  // 临时目录和最终缓存位于同一个 cacheRoot 下，rename 不会跨文件系统，
  // 因而可以作为原子“发布”操作。其他进程只能看到完整缓存，看不到解压一半
  // 的目录。
  const workRoot = await fsp.mkdtemp(
    path.join(paths.cacheRoot, `.${artifact.artifact}.tmp-`),
  );
  const archivePath = path.join(workRoot, artifact.archiveName);
  const extractionRoot = path.join(workRoot, 'extracted');
  let published = false;

  try {
    await fsp.mkdir(extractionRoot);
    report(
      `首次安装需要下载约 ${formatMiB(artifact.archiveSize)} MiB；` +
        `解压后的 LLVM 静态库约占 ${formatMiB(artifact.staticLibrarySize)} MiB`,
    );
    await downloadAndVerify(artifact, archivePath);

    report('正在解压 LLVM 产物');
    extractArchive(archivePath, extractionRoot);
    const extractedArtifact = path.join(extractionRoot, artifact.artifact);

    report('正在校验解压后的 LLVM 静态库');
    await validateInstalledArtifact(extractedArtifact, artifact, false);
    await writeCompletionMarker(extractedArtifact, artifact);

    try {
      await fsp.rename(extractedArtifact, paths.installRoot);
      published = true;
      report(`LLVM 已安装到共享缓存 ${paths.installRoot}`);
    } catch (error) {
      if (!error || !['EEXIST', 'ENOTEMPTY'].includes(error.code)) {
        throw error;
      }

      // 两个项目可能同时第一次使用 llvm.mbt。若另一个进程先完成发布，
      // 当前进程直接校验并复用胜出者，不把并发视为错误。
      report('另一个进程已经写入 LLVM 缓存，正在校验并复用该缓存');
      await validateInstalledArtifact(paths.installRoot, artifact, true);
      published = true;
    }
  } finally {
    // 只删除 mkdtemp 创建的本次临时目录，不触碰其他版本或其他进程的文件。
    // 如果这里因为磁盘或权限问题失败，主要安装结果仍然保持可用。
    try {
      await fsp.rm(workRoot, { recursive: true, force: true });
    } catch (error) {
      report(`警告：无法清理临时目录 ${workRoot}：${error.message}`);
    }
  }

  if (!published) {
    throw new Error('LLVM 产物没有成功写入缓存');
  }
}

async function ensureArtifact(moonHome, artifact) {
  const paths = cachePaths(moonHome, artifact);
  let quarantine = null;

  if (await pathExists(paths.installRoot)) {
    try {
      report(`发现 LLVM 共享缓存，正在校验 ${paths.installRoot}`);
      const validated = await validateInstalledArtifact(
        paths.installRoot,
        artifact,
        true,
      );
      report('LLVM 共享缓存校验通过');
      return validated;
    } catch (error) {
      if (!(error instanceof CacheValidationError)) {
        throw error;
      }
      report(`LLVM 共享缓存校验失败：${error.message}`);
      quarantine = await quarantineInvalidCache(paths.installRoot);
    }
  }

  // 如果另一个进程恰好在我们隔离缓存后抢先完成安装，先复用它；否则再下载。
  if (!(await pathExists(paths.installRoot))) {
    await installArtifact(paths, artifact);
  }

  const validated = await validateInstalledArtifact(paths.installRoot, artifact, true);
  if (quarantine) {
    try {
      await fsp.rm(quarantine, { recursive: true, force: true });
      report(`新的 LLVM 缓存可用，已删除旧的损坏缓存 ${quarantine}`);
    } catch (error) {
      report(`警告：无法删除旧的损坏缓存 ${quarantine}：${error.message}`);
    }
  }
  return validated;
}

// Moon 最终会用 shlex 拆分这些字符串。用单引号包住整个参数，并正确处理
// 参数中原有的单引号，可以保证 `$MOON_HOME` 路径中含空格时仍然只形成一个
// 编译或链接参数。
function shellQuote(value) {
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function makeBuildOutput(validated, artifact) {
  const stubCompilerFlags = [
    shellQuote(`-I${validated.includeDirectory}`),
    '-D__STDC_CONSTANT_MACROS',
    '-D__STDC_FORMAT_MACROS',
    '-D__STDC_LIMIT_MACROS',
  ].join(' ');

  const linkFlags = [
    shellQuote(validated.staticLibrary),
    ...artifact.systemLinkFlags,
  ].join(' ');

  return {
    vars: {
      LLVM_MBT_STUB_CC_FLAGS: stubCompilerFlags,
    },
    link_configs: [
      {
        package: 'Kaida-Amethyst/llvm/unsafe',
        link_flags: linkFlags,
      },
    ],
  };
}

function formatMiB(bytes) {
  return (bytes / (1024 * 1024)).toFixed(1);
}

function formatTopLevelError(error) {
  if (error && error.code === 'ENOSPC') {
    const artifact = ARTIFACTS[`${process.platform}-${process.arch}`];
    const sizeHint = artifact
      ? `压缩包约 ${formatMiB(artifact.archiveSize)} MiB，` +
        `静态库约 ${formatMiB(artifact.staticLibrarySize)} MiB；`
      : '';
    return (
      `磁盘空间不足。${sizeHint}` +
      '请清理 $MOON_HOME/cache/lib/llvm.mbt 所在磁盘后重试。'
    );
  }
  if (error && error.code === 'EACCES') {
    return `没有权限写入 LLVM 共享缓存：${error.message}`;
  }
  return error && error.message ? error.message : String(error);
}

async function main() {
  const input = await readBuildInput();
  const artifact = selectArtifact();
  validateHostCompatibility(artifact);
  const moonHome = resolveMoonHome(input);
  const validated = await ensureArtifact(moonHome, artifact);
  const output = makeBuildOutput(validated, artifact);

  // stdout 只能包含这一份 JSON；Moon 会直接反序列化它。
  console.log(JSON.stringify(output));
}

main().catch((error) => {
  report(`错误：${formatTopLevelError(error)}`);
  process.exitCode = 1;
});
