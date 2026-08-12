# MiniMoonBit frontend example

This directory ports the frontend of the author's MiniMoonBit compiler into
`llvm.mbt`. It is both an example compiler and an integration-test workload for
the binding.

The current port stops after KNF lowering:

```text
source -> lexer -> parser -> typecheck -> KNF
```

The packages intentionally follow the original compiler boundaries: `color`,
`lexer`, `parser`, `typecheck`, and `knf`. They are example-facing APIs rather
than stable core APIs of `llvm.mbt`.

There is no command-line driver in this directory yet. Code generation, native
object emission, linking, and execution will be added in a later phase, while
porting the original code generator against `Kaida-Amethyst/llvm/IR`.
