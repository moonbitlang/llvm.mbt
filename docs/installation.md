# Installing llvm.mbt

[中文说明](#中文说明)

llvm.mbt uses a prebuilt LLVM 22.1.0 static library. Moon runs `build.js`
before a native build; the script selects the artifact for the current host,
downloads it when necessary, validates it, and returns the compiler and linker
flags required by the binding.

The installer does not use `LLVM_HOME`, `llvm-config`, or a system LLVM
installation.

## Supported hosts

| Host | Minimum version | Artifact | Download | Static library |
| --- | --- | --- | ---: | ---: |
| macOS ARM64 | macOS 11 | `llvm-22.1.0-r1-macos-arm64` | 29.3 MiB | 198.8 MiB |
| Linux x86_64 | glibc 2.31 | `llvm-22.1.0-r1-linux-x86_64` | 41.2 MiB | 320.4 MiB |

Linux systems using musl are not supported. `build.js` checks the runtime glibc
version before downloading the Linux artifact.

The following programs must be available in `PATH`:

- Node.js, used to run `build.js`;
- `cc`, used by Moon's native toolchain;
- `tar` with XZ support, used when installing an artifact for the first time.

The first build also needs HTTPS access to the project's
[LLVM 22.1.0 GitHub Release](https://github.com/moonbitlang/llvm.mbt/releases/tag/llvm-22.1.0).

## Cache location

If `MOON_HOME` is set, the installer uses that directory. A relative
`MOON_HOME` is converted to an absolute path. If it is not set, the default is
the current user's `~/.moon` directory.

Artifacts are installed under:

```text
$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt/
  22.1.0-r1/
    <platform>/
      sha256-<archive-sha256>/
        include/
        lib/libLLVM-mbt.a
        manifest.json
        .complete.json
```

The LLVM version, artifact revision, host platform, and archive digest are all
part of the path. Projects using the same artifact share this cache, while a
future artifact can be installed beside it without overwriting the old one.

## What `build.js` does

### 1. Select the artifact

The script uses the operating system and architecture reported by Node.js. It
accepts only `darwin-arm64` and `linux-x64`. On Linux it also rejects a glibc
version older than 2.31 and environments that do not report glibc, including
musl-based distributions.

The archive URL, expected byte length, archive SHA-256, static-library byte
length, and static-library SHA-256 are fixed in the released `build.js`.

### 2. Validate an existing cache

When the final cache directory already exists, the script checks:

- the artifact manifest schema, name, LLVM version, revision, and host;
- the declared minimum macOS or glibc version;
- the include directory, static-library path, and system linker flags;
- that `include/` is a directory and `libLLVM-mbt.a` is a regular file;
- the exact size and SHA-256 of `libLLVM-mbt.a`;
- the cache schema and both digests stored in `.complete.json`.

The static library is hashed again on a cache hit. This detects a partial
installation, manual modification, and disk corruption instead of passing a
bad library to the native linker.

### 3. Download a missing artifact

A first-time installation downloads one of these release assets:

- `llvm-22.1.0-r1-macos-arm64.tar.xz`
- `llvm-22.1.0-r1-linux-x86_64.tar.xz`

The downloader accepts HTTPS only, follows at most ten redirects, and makes up
to three attempts. Its 30-second timeout means 30 seconds without network
activity; it is not a limit on the total download time.

While streaming the response, the script rejects data that exceeds the
expected size. After the download it requires both the exact byte length and
the SHA-256 embedded in `build.js`. A `.sha256` file downloaded from the same
Release is not used as the trust source.

### 4. Extract and publish the cache

The verified archive is extracted with `tar -xf` into a temporary directory
inside the llvm.mbt cache. The installer then validates `manifest.json` and the
extracted static library, writes `.complete.json`, and renames the completed
artifact to its final content-addressed directory.

The temporary and final directories are on the same filesystem, so the rename
publishes the cache atomically. Other builds should see either no cache or a
complete cache, not a half-extracted directory.

If two builds install the same artifact concurrently, one rename wins. The
other process validates and reuses the completed cache instead of treating the
race as an error.

### 5. Return build flags to Moon

After validation, `build.js` returns JSON containing:

- the LLVM include directory and required C preprocessor definitions for the
  native wrapper;
- the absolute path to `libLLVM-mbt.a`;
- the platform system libraries required when linking it.

Standard output is reserved for this JSON protocol. Download messages, cache
paths, and errors are written to standard error with an `[llvm.mbt]` prefix.

## Invalid cache recovery

If an existing cache fails validation, the installer renames that exact
content-addressed directory to a sibling ending in `.corrupt-<timestamp>-<pid>`
and installs a new copy. Once the new cache passes validation, it removes the
quarantined directory.

Normally no manual cache deletion is needed. If validation repeatedly fails,
do not delete all of `$MOON_HOME/cache`; preserve the full `[llvm.mbt]` error
and inspect the specific path reported by the installer.

## Troubleshooting

### Unsupported platform

An error such as `No prebuilt LLVM artifact is available` means that the
operating-system and architecture pair is not supported by this release.
llvm.mbt does not fall back to `llvm-config`, even when a compatible LLVM is
installed locally.

On Linux, an error about glibc means either that glibc is older than 2.31 or
that the environment is based on musl. Use a supported glibc environment.

### Node.js or `cc` is missing

Check that both tools are visible to the same environment in which Moon runs:

```bash
node --version
cc --version
moon version --all
```

Changing an interactive shell configuration is not sufficient when an editor,
CI runner, or other process starts Moon with a different `PATH`.

### Download failure

The downloader uses Node.js HTTPS directly. Confirm that the Node.js process
can reach GitHub Release assets and that a firewall or corporate network is not
blocking or replacing the download. The installer reports HTTP status, size,
digest, redirect, and idle-timeout failures separately and retries transient
failures three times.

### Extraction failure

An extraction error usually means `tar` is missing, cannot start, or lacks XZ
support. The error includes the output returned by `tar`.

### Cache permission failure

The user running Moon must be able to create and rename directories below:

```text
$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt
```

If `MOON_HOME` is customized, check that it points to the intended writable
directory. The installer reports `EACCES` as a cache write failure.

### Insufficient disk space

The first installation temporarily needs space for both the compressed archive
and the extracted artifact. The artifact sizes are listed above. `ENOSPC`
errors include the relevant size hints and cache location.

### Native linker failure

If download and validation succeed but the final native link fails, keep the
complete linker command and diagnostic. This is distinct from an installer
failure: `build.js` has already supplied the validated static library and its
platform system-link flags.

## Reporting an installation problem

An issue is most useful when it includes:

- the complete error lines beginning with `[llvm.mbt]`;
- `moon version --all` and `node --version`;
- the output of `uname -s` and `uname -m`;
- on Linux, the runtime glibc version reported by `ldd --version`;
- whether `MOON_HOME` is set, without including unrelated environment values;
- whether the failure happens during download, extraction, cache validation,
  or native linking.

Do not include credentials, proxy secrets, or an unfiltered environment dump.

---

# 中文说明

[English](#installing-llvmbt)

llvm.mbt 使用预先构建的 LLVM 22.1.0 静态库。Moon 会在 native 构建前运行
`build.js`；脚本负责为当前宿主选择产物、在需要时下载、完成校验，并返回 binding
所需的编译和链接参数。

安装器不使用 `LLVM_HOME`、`llvm-config` 或系统 LLVM。

## 支持的宿主平台

| 宿主平台 | 最低版本 | 产物 | 下载大小 | 静态库大小 |
| --- | --- | --- | ---: | ---: |
| macOS ARM64 | macOS 11 | `llvm-22.1.0-r1-macos-arm64` | 29.3 MiB | 198.8 MiB |
| Linux x86_64 | glibc 2.31 | `llvm-22.1.0-r1-linux-x86_64` | 41.2 MiB | 320.4 MiB |

不支持使用 musl 的 Linux 系统。下载 Linux 产物之前，`build.js` 会检查运行时
glibc 版本。

`PATH` 中必须存在：

- Node.js，用来运行 `build.js`；
- `cc`，供 Moon 的 native 工具链使用；
- 支持 XZ 的 `tar`，第一次安装产物时用来解压。

第一次构建还需要能够通过 HTTPS 访问项目的
[LLVM 22.1.0 GitHub Release](https://github.com/moonbitlang/llvm.mbt/releases/tag/llvm-22.1.0)。

## 缓存位置

如果设置了 `MOON_HOME`，安装器会使用该目录；相对路径会先转换为绝对路径。
如果没有设置，则默认使用当前用户的 `~/.moon`。

产物安装在：

```text
$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt/
  22.1.0-r1/
    <platform>/
      sha256-<archive-sha256>/
        include/
        lib/libLLVM-mbt.a
        manifest.json
        .complete.json
```

LLVM 版本、产物 revision、宿主平台和压缩包摘要都是路径的一部分。使用相同产物
的项目共享这一缓存；未来的新产物可以安装在旁边，不会覆盖旧产物。

## `build.js` 做了什么

### 1. 选择产物

脚本根据 Node.js 报告的操作系统和架构选择产物，只接受 `darwin-arm64` 和
`linux-x64`。在 Linux 上，它还会拒绝低于 2.31 的 glibc，以及无法报告 glibc
版本的环境，其中包括基于 musl 的发行版。

压缩包 URL、预期字节数、压缩包 SHA-256、静态库字节数和静态库 SHA-256 都固定
在发布版本的 `build.js` 中。

### 2. 校验已有缓存

最终缓存目录已经存在时，脚本会检查：

- 产物 manifest 的 schema、名称、LLVM 版本、revision 和宿主；
- 声明的最低 macOS 或 glibc 版本；
- include 目录、静态库路径和系统链接参数；
- `include/` 是目录，`libLLVM-mbt.a` 是普通文件；
- `libLLVM-mbt.a` 的准确大小和 SHA-256；
- `.complete.json` 中的缓存 schema 和两份摘要。

命中缓存时仍会重新计算静态库摘要。这样可以在交给 native linker 之前发现不完整
安装、手工修改或磁盘损坏。

### 3. 下载缺失的产物

第一次安装会下载以下 Release asset 之一：

- `llvm-22.1.0-r1-macos-arm64.tar.xz`
- `llvm-22.1.0-r1-linux-x86_64.tar.xz`

下载器只接受 HTTPS，最多跟随十次重定向，最多尝试三次。30 秒超时是指连续
30 秒没有网络活动，不是限制整个下载必须在 30 秒内完成。

接收数据时，如果内容超过预期大小，脚本会立即拒绝。下载完成后，实际字节数和
SHA-256 都必须与 `build.js` 中固定的值完全一致。从同一个 Release 下载的
`.sha256` 文件不会被用作信任来源。

### 4. 解压并发布缓存

通过校验的压缩包会用 `tar -xf` 解压到 llvm.mbt 缓存内部的临时目录。安装器
随后校验 `manifest.json` 和解压后的静态库，写入 `.complete.json`，最后把完整
产物重命名到内容寻址的最终目录。

临时目录和最终目录位于同一文件系统，因此 rename 可以原子地发布缓存。其他构建
看到的应该是“不存在缓存”或“完整缓存”，不会看到只解压了一半的目录。

两个构建并发安装同一产物时，其中一个 rename 会先成功；另一个进程会校验并复用
已经完成的缓存，而不会把正常竞争当作错误。

### 5. 向 Moon 返回构建参数

校验完成后，`build.js` 返回一份 JSON，其中包含：

- native wrapper 所需的 LLVM include 目录和 C 预处理定义；
- `libLLVM-mbt.a` 的绝对路径；
- 链接该静态库所需的平台系统库。

标准输出只用于这份 JSON 协议。下载信息、缓存路径和错误会带着 `[llvm.mbt]`
前缀写到标准错误。

## 无效缓存的恢复

已有缓存校验失败时，安装器会把这个准确的内容寻址目录重命名为以
`.corrupt-<timestamp>-<pid>` 结尾的相邻目录，然后安装新副本。新缓存通过校验
以后，再删除被隔离的目录。

通常不需要手工删除缓存。如果校验反复失败，不要删除整个 `$MOON_HOME/cache`；
请保留完整的 `[llvm.mbt]` 错误，并检查安装器报告的具体路径。

## 常见问题

### 不支持的平台

`No prebuilt LLVM artifact is available` 表示当前操作系统和架构不受此版本支持。
即使本机安装了兼容 LLVM，llvm.mbt 也不会回退到 `llvm-config`。

Linux 上出现 glibc 错误，说明 glibc 低于 2.31，或者环境使用 musl。请改用受支持
的 glibc 环境。

### 找不到 Node.js 或 `cc`

检查 Moon 所在的同一个环境能否找到这些工具：

```bash
node --version
cc --version
moon version --all
```

如果编辑器、CI runner 或其他进程使用不同的 `PATH`，只修改交互式 shell 配置并
不能解决问题。

### 下载失败

下载器直接使用 Node.js HTTPS。请确认 Node.js 进程可以访问 GitHub Release
asset，并且防火墙或企业网络没有阻止或替换下载内容。安装器会分别报告 HTTP
状态、大小、摘要、重定向和网络空闲超时，并对临时失败尝试三次。

### 解压失败

解压错误通常说明 `tar` 不存在、无法启动，或不支持 XZ。错误信息会包含 `tar`
返回的输出。

### 缓存权限错误

运行 Moon 的用户必须能够在以下目录中创建和重命名目录：

```text
$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt
```

如果自定义了 `MOON_HOME`，请检查它是否指向预期的可写目录。安装器会把
`EACCES` 报告为缓存写入失败。

### 磁盘空间不足

第一次安装会临时同时占用压缩包和解压后产物的空间。具体大小见前面的表格。
`ENOSPC` 错误会同时给出大小提示和缓存位置。

### Native linker 失败

如果下载和校验已经成功，但最后的 native link 失败，请保留完整 linker 命令和
诊断。这与安装器失败不同：此时 `build.js` 已经提供了校验过的静态库和平台系统
链接参数。

## 报告安装问题

提交 issue 时，以下信息最有帮助：

- 所有以 `[llvm.mbt]` 开头的完整错误行；
- `moon version --all` 和 `node --version`；
- `uname -s` 和 `uname -m` 的输出；
- Linux 上 `ldd --version` 报告的运行时 glibc 版本；
- 是否设置了 `MOON_HOME`，但不要附带无关环境变量；
- 错误发生在下载、解压、缓存校验还是 native linking 阶段。

不要提交凭据、代理密码或未经筛选的完整环境变量。
