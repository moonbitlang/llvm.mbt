# Kaleidoscope for llvm.mbt

This directory will contain a host-only Kaleidoscope implementation built on
the public `Kaida-Amethyst/llvm/IR` and `Kaida-Amethyst/llvm/JIT` packages.

The example is an independent MoonBit module. Its REPL will use
`Kaida-Amethyst/readline`, without making the main `Kaida-Amethyst/llvm` module
depend on a terminal library.

Implementation is not present yet. The planned language surface and commit
boundaries are recorded in
[`docs/worklog/C-10-kaleidoscope-jit-example-commit-plan.md`](../../docs/worklog/C-10-kaleidoscope-jit-example-commit-plan.md).
