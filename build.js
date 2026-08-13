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
    throw new Error(
      `Cannot parse the JSON passed to build.js by Moon: ${error.message}`,
    );
  }

  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw new Error(
      'The input passed to build.js by Moon is not a JSON object',
    );
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
    throw new Error(
      "MOON_HOME is not set and the current user's home directory could not be determined",
    );
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
    `No prebuilt LLVM artifact is available for ${platform}; ` +
      `supported platforms: ${supported}. llvm.mbt does not fall back to ` +
      'system llvm-config, so that the LLVM version remains reproducible.',
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
      `The current Linux environment does not report a glibc version; ` +
        `${artifact.artifact} requires glibc ${artifact.minimumGlibcVersion} ` +
        'or later and does not support musl.',
    );
  }
  if (compareVersions(runtimeVersion, artifact.minimumGlibcVersion) < 0) {
    throw new Error(
      `The current glibc ${runtimeVersion} is older than ` +
        `${artifact.minimumGlibcVersion}, which is required by ${artifact.artifact}.`,
    );
  }
}

function cachePaths(moonHome, artifact) {
  const cacheRoot = path.join(
    moonHome,
    'cache',
    'lib',
    'Kaida-Amethyst',
    'llvm.mbt',
  );
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
    throw new CacheValidationError(
      `Cannot read ${description} at ${filename}: ${error.message}`,
    );
  }

  try {
    return JSON.parse(source);
  } catch (error) {
    throw new CacheValidationError(
      `${description} is not valid JSON: ${error.message}`,
    );
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
  const manifest = await readJsonFile(manifestPath, 'LLVM artifact manifest');

  requireManifestField(
    manifest.schema_version === 1,
    `Unsupported LLVM artifact manifest schema version: ` +
      `${manifest.schema_version}`,
  );
  requireManifestField(
    manifest.artifact === artifact.artifact,
    `LLVM artifact name mismatch: expected ${artifact.artifact}, ` +
      `got ${manifest.artifact}`,
  );
  requireManifestField(
    manifest.llvm_version === artifact.llvmVersion,
    `LLVM version mismatch: expected ${artifact.llvmVersion}, ` +
      `got ${manifest.llvm_version}`,
  );
  requireManifestField(
    manifest.artifact_revision === artifact.revision,
    `LLVM artifact revision mismatch: expected ${artifact.revision}, ` +
      `got ${manifest.artifact_revision}`,
  );
  requireManifestField(
    manifest.host === artifact.host,
    `LLVM artifact host mismatch: expected ${artifact.host}, ` +
      `got ${manifest.host}`,
  );
  if (artifact.minimumMacOSVersion) {
    requireManifestField(
      manifest.minimum_macos_version === artifact.minimumMacOSVersion,
      "The artifact's minimum macOS version does not match build.js",
    );
  }
  if (artifact.minimumGlibcVersion) {
    requireManifestField(
      manifest.minimum_glibc_version === artifact.minimumGlibcVersion,
      "The artifact's minimum glibc version does not match build.js",
    );
  }
  requireManifestField(
    manifest.include_dir === artifact.includeDirectory,
    "The artifact's include directory does not match build.js",
  );
  requireManifestField(
    manifest.static_library === artifact.staticLibrary,
    "The artifact's static library path does not match build.js",
  );
  requireManifestField(
    manifest.static_library_sha256 === artifact.staticLibrarySha256,
    'The static library SHA-256 in the artifact manifest does not match ' +
      'build.js',
  );
  requireManifestField(
    JSON.stringify(manifest.system_link_flags) ===
      JSON.stringify(artifact.systemLinkFlags),
    "The artifact's system linker flags do not match build.js",
  );

  const includeDirectory = path.join(installRoot, artifact.includeDirectory);
  let includeStat;
  try {
    includeStat = await fsp.lstat(includeDirectory);
  } catch (error) {
    throw new CacheValidationError(
      `LLVM include directory is unavailable: ${error.message}`,
    );
  }
  requireManifestField(
    includeStat.isDirectory(),
    'LLVM include path is not a directory',
  );

  const staticLibrary = path.join(installRoot, artifact.staticLibrary);
  let libraryStat;
  try {
    libraryStat = await fsp.lstat(staticLibrary);
  } catch (error) {
    throw new CacheValidationError(
      `LLVM static library is unavailable: ${error.message}`,
    );
  }
  requireManifestField(
    libraryStat.isFile(),
    'LLVM static library path is not a regular file',
  );
  requireManifestField(
    libraryStat.size === artifact.staticLibrarySize,
    `LLVM static library size mismatch: expected ${artifact.staticLibrarySize} ` +
      `bytes, got ${libraryStat.size} bytes`,
  );

  const librarySha256 = await sha256File(staticLibrary);
  requireManifestField(
    librarySha256 === artifact.staticLibrarySha256,
    `LLVM static library SHA-256 mismatch: expected ` +
      `${artifact.staticLibrarySha256}, got ${librarySha256}`,
  );

  if (requireMarker) {
    const markerPath = path.join(installRoot, '.complete.json');
    const marker = await readJsonFile(
      markerPath,
      'LLVM cache completion marker',
    );
    requireManifestField(
      marker.cache_schema_version === CACHE_SCHEMA_VERSION,
      `Unsupported llvm.mbt cache schema version: ` +
        `${marker.cache_schema_version}`,
    );
    requireManifestField(
      marker.artifact === artifact.artifact,
      'Artifact name mismatch in LLVM cache completion marker',
    );
    requireManifestField(
      marker.archive_sha256 === artifact.archiveSha256,
      'Archive SHA-256 mismatch in LLVM cache completion marker',
    );
    requireManifestField(
      marker.static_library_sha256 === artifact.staticLibrarySha256,
      'Static library SHA-256 mismatch in LLVM cache completion marker',
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
      reject(new Error(`Invalid LLVM download URL ${url}: ${error.message}`));
      return;
    }

    // 固定摘要能够发现内容被替换，而只允许 HTTPS 可以避免无意间把
    // GitHub 的下载重定向降级成明文 HTTP。
    if (parsedUrl.protocol !== 'https:') {
      reject(
        new Error(`Refusing to download LLVM from a non-HTTPS URL: ${url}`),
      );
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
            reject(
              new Error(`LLVM download exceeded ${MAX_REDIRECTS} redirects`),
            );
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
          reject(
            new Error(`LLVM download request returned HTTP ${statusCode}`),
          );
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
              `LLVM download size mismatch: expected ${expectedSize} bytes, ` +
                `server reported ${contentLength} bytes`,
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
                  `LLVM download exceeded the expected ${expectedSize} bytes; ` +
                    'aborting',
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
                  `Incomplete LLVM download: expected ${expectedSize} bytes, ` +
                    `received ${received} bytes`,
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
      request.destroy(
        new Error('LLVM download received no data for 30 seconds'),
      );
    });
    request.on('error', reject);
  });
}

async function downloadAndVerify(artifact, archivePath) {
  for (let attempt = 1; attempt <= DOWNLOAD_ATTEMPTS; attempt += 1) {
    await fsp.rm(archivePath, { force: true });
    try {
      report(
        `Downloading ${artifact.archiveName} (${artifact.archiveSize} bytes, ` +
          `attempt ${attempt}/${DOWNLOAD_ATTEMPTS})`,
      );
      const result = await downloadOnce(
        artifact.url,
        archivePath,
        artifact.archiveSize,
      );
      if (result.sha256 !== artifact.archiveSha256) {
        throw new Error(
          `LLVM archive SHA-256 mismatch: expected ${artifact.archiveSha256}, ` +
            `got ${result.sha256}`,
        );
      }
      report('LLVM archive downloaded and SHA-256 verified');
      return;
    } catch (error) {
      await fsp.rm(archivePath, { force: true });
      if (attempt === DOWNLOAD_ATTEMPTS) {
        throw error;
      }
      report(`Download attempt failed: ${error.message}; retrying shortly`);
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
    throw new Error(`Failed to start tar: ${result.error.message}`);
  }
  if (result.status !== 0) {
    const detail = (result.stderr || result.stdout || '').trim();
    throw new Error(
      `Failed to extract LLVM archive${detail ? `: ${detail}` : ''}`,
    );
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
    report(`Moved invalid LLVM cache to ${quarantine}`);
    return quarantine;
  } catch (error) {
    // 另一个并发进程可能已经移走了同一个目录；调用者会重新检查最终路径。
    if (error && error.code === 'ENOENT') {
      return null;
    }
    throw new Error(
      `Failed to quarantine invalid LLVM cache ${installRoot}: ${error.message}`,
    );
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
      `First-time installation will download about ` +
        `${formatMiB(artifact.archiveSize)} MiB; the extracted LLVM static ` +
        `library uses about ${formatMiB(artifact.staticLibrarySize)} MiB`,
    );
    await downloadAndVerify(artifact, archivePath);

    report('Extracting LLVM artifact');
    extractArchive(archivePath, extractionRoot);
    const extractedArtifact = path.join(extractionRoot, artifact.artifact);

    report('Validating extracted LLVM static library');
    await validateInstalledArtifact(extractedArtifact, artifact, false);
    await writeCompletionMarker(extractedArtifact, artifact);

    try {
      await fsp.rename(extractedArtifact, paths.installRoot);
      published = true;
      report(`Installed LLVM into shared cache ${paths.installRoot}`);
    } catch (error) {
      if (!error || !['EEXIST', 'ENOTEMPTY'].includes(error.code)) {
        throw error;
      }

      // 两个项目可能同时第一次使用 llvm.mbt。若另一个进程先完成发布，
      // 当前进程直接校验并复用胜出者，不把并发视为错误。
      report(
        'Another process populated the LLVM cache; validating and reusing it',
      );
      await validateInstalledArtifact(paths.installRoot, artifact, true);
      published = true;
    }
  } finally {
    // 只删除 mkdtemp 创建的本次临时目录，不触碰其他版本或其他进程的文件。
    // 如果这里因为磁盘或权限问题失败，主要安装结果仍然保持可用。
    try {
      await fsp.rm(workRoot, { recursive: true, force: true });
    } catch (error) {
      report(
        `Warning: failed to clean temporary directory ${workRoot}: ` +
          `${error.message}`,
      );
    }
  }

  if (!published) {
    throw new Error('LLVM artifact was not installed into the cache');
  }
}

async function ensureArtifact(moonHome, artifact) {
  const paths = cachePaths(moonHome, artifact);
  let quarantine = null;

  if (await pathExists(paths.installRoot)) {
    try {
      const validated = await validateInstalledArtifact(
        paths.installRoot,
        artifact,
        true,
      );
      return validated;
    } catch (error) {
      if (!(error instanceof CacheValidationError)) {
        throw error;
      }
      report(`LLVM shared cache validation failed: ${error.message}`);
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
      report(`New LLVM cache is ready; removed invalid cache ${quarantine}`);
    } catch (error) {
      report(
        `Warning: failed to remove invalid cache ${quarantine}: ${error.message}`,
      );
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
      ? `The archive is about ${formatMiB(artifact.archiveSize)} MiB and ` +
        `the static library is about ` +
        `${formatMiB(artifact.staticLibrarySize)} MiB. `
      : '';
    return (
      `Not enough disk space. ${sizeHint}` +
      'Free space on the volume containing ' +
      '$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt and try again.'
    );
  }
  if (error && error.code === 'EACCES') {
    return `Cannot write to the LLVM shared cache: ${error.message}`;
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
  report(`Error: ${formatTopLevelError(error)}`);
  process.exitCode = 1;
});
