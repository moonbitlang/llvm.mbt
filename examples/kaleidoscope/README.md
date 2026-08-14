# Kaleidoscope for llvm.mbt

This directory contains a host-only Kaleidoscope implementation built on the
public `Kaida-Amethyst/llvm/IR` and `Kaida-Amethyst/llvm/JIT` packages.

The example is an independent MoonBit module. Its REPL uses
`Kaida-Amethyst/readline`, without making the main `Kaida-Amethyst/llvm` module
depend on a terminal library.

## Run the REPL

From the llvm.mbt repository root:

```sh
moon -C examples/kaleidoscope run --target native main
```

The current language accepts one complete form per line:

```text
ready> 1 + 2 * 3
7
ready> def add(x y) x + y
defined add
ready> add(20, 22)
42
ready> extern sin(x)
declared sin
ready> sin(0)
0
```

`:help` lists local commands and `:quit` exits. EOF also exits normally. Ctrl-C
discards only the current unsubmitted input and keeps the same editor and JIT
Session alive.

Empty lines are ignored and are not added to History. Every other submitted
line is added before processing, including local commands, failed language
inputs, and `:quit`; Ctrl-C and EOF add nothing. History is process-local and is
not saved to disk.

## Current scope

All values are `Double`. The implemented core supports numeric literals,
variables, calls, `+`, `-`, `*`, `<`, normal function definitions, extern
declarations, and anonymous expressions. Each definition is compiled in a fresh
LLVM Context and persists in one LLJIT Session. Each anonymous expression uses
an independent ResourceTracker and is unloaded after its native result is
returned.

The example imports only the public `IR` and `JIT` packages; unsafe address
conversion is confined to the private Session execution boundary. Lexer,
parser, codegen, Session, and tests do not import readline. Only the executable
`main` package owns terminal behavior.

Control flow, user-defined operators, mutable variables, optimization passes,
and debug information are not implemented at this stage. The planned language
surface and remaining commit boundaries are recorded in
[`C-10-kaleidoscope-jit-example-commit-plan.md`](../../docs/worklog/C-10-kaleidoscope-jit-example-commit-plan.md).
