# MiniMoonBit compiler example

This directory ports the frontend of the author's MiniMoonBit compiler into
`llvm.mbt`. It is both an example compiler and an integration-test workload for
the binding.

The current port includes LLVM IR code generation:

```text
source -> lexer -> parser -> typecheck -> KNF -> LLVM IR
```

The packages intentionally follow the original compiler boundaries: `color`,
`lexer`, `parser`, `typecheck`, `knf`, and `codegen`. They are example-facing
APIs rather than stable core APIs of `llvm.mbt`.

The original frontend test suites have been retained: 17 lexer tests, 32 parser
tests, 23 type-checker tests, and 19 KNF tests. A separate black-box integration
test also composes all four frontend stages on one in-memory source program.

Run the MiniMoonBit frontend integration test with:

```sh
moon test --target native -p Kaida-Amethyst/llvm-minimoonbit/frontend_test
```

Run the 124 native end-to-end programs with:

```sh
moon test --target native -p Kaida-Amethyst/llvm-minimoonbit/e2e_test
```

Run all MiniMoonBit package tests with:

```sh
moon test --target native examples/minimoonbit
```

There is no command-line driver in this directory yet. The code generator
produces a host-configured LLVM module and declares the original MiniMoonBit
runtime ABI. The native-only end-to-end test package organizes the original 124
regular MiniMoonBit programs into semantic groups. It emits objects, links them
with the test runtime through the host C compiler, executes the resulting
programs, and compares their output with checked-in answers. The original
benchmark programs remain outside this test suite.
