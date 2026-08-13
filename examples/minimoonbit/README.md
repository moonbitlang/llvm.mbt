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
moon test --target native -p examples/minimoonbit/frontend_test
```

Run all MiniMoonBit package tests with:

```sh
moon test --target native -p examples/minimoonbit
```

There is no command-line driver in this directory yet. The code generator
produces a host-configured LLVM module and declares the original MiniMoonBit
runtime ABI; it does not yet package the runtime, emit an object, link an
executable, or run the result. End-to-end execution tests therefore remain a
separate follow-up.
