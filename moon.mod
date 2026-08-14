name = "Kaida-Amethyst/llvm"

version = "0.5.0"

import {
  "moonbitlang/async@0.20.5",
  "Kaida-Amethyst/either@0.1.0",
}

readme = "README.md"

repository = "https://github.com/moonbitlang/llvm.mbt"

license = "Apache-2.0"

keywords = [ "Compiler", "llvm", "Native-Only" ]

description = "llvm-c binding for Moonbit with friendly API, keeps the Cpp Style."

preferred_target = "native"

options(
  "--moonbit-unstable-prebuild": "build.js",
  exclude: [ "examples", "docs", "native_emission_test", "test" ],
)
