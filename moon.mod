name = "Kaida-Amethyst/llvm"

version = "0.3.0"

import {
  "moonbitlang/async@0.20.5",
}

readme = "README.md"

repository = "https://github.com/moonbitlang/llvm.mbt"

license = "Apache-2.0"

keywords = [ "Compiler", "llvm", "Native-Only" ]

description = "llvm-c binding for Moonbit with friendly API, keeps the Cpp Style."

preferred_target = "native"

options(
  "--moonbit-unstable-prebuild": "build.js",
)
