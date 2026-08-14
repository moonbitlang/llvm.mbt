# Kaleidoscope for llvm.mbt

This directory contains a host-only implementation of the Kaleidoscope
language built entirely on the public `Kaida-Amethyst/llvm/IR` and
`Kaida-Amethyst/llvm/JIT` packages. It demonstrates incremental native code
generation: each input is parsed, lowered to verified LLVM IR, submitted to
LLJIT, and executed in the current process.

Kaleidoscope is an independent MoonBit module. Its REPL depends on
`Kaida-Amethyst/readline`; the main `Kaida-Amethyst/llvm` module does not.

## Run the REPL

From the llvm.mbt repository root:

```sh
moon -C examples/kaleidoscope run main --target native
```

The REPL accepts one complete top-level form per line:

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
ready> def binary% 50 (left right) left * right
defined binary%
ready> var total = 0 in (for i = 1, i < 5 in total = total + i) + total
10
```

`:help` lists local commands and `:quit` exits. EOF also exits normally. Ctrl-C
discards only the current unsubmitted input and preserves the editor and JIT
Session.

Empty lines are ignored and are not added to History. Every other submitted
line is added before processing, including local commands, failed language
inputs, and `:quit`; Ctrl-C and EOF add nothing. History is process-local and
is not saved to disk.

## Language

Every runtime value is a `Double`. The implemented surface is:

```text
top-level  ::= "def" prototype expression
             | "extern" prototype
             | expression

prototype  ::= identifier "(" identifiers... ")"
             | "unary" operator "(" identifier ")"
             | "binary" operator precedence? "(" identifier identifier ")"

expression ::= number | identifier | call | "(" expression ")"
             | unary-expression | binary-expression
             | "if" expression "then" expression "else" expression
             | "for" identifier "=" expression "," expression
               ("," expression)? "in" expression
             | "var" binding ("," binding)* "in" expression
             | identifier "=" expression

binding    ::= identifier ("=" expression)?
```

- Built-in binary operators are `<`, `+`, `-`, and `*`, with precedence 10,
  20, 20, and 40 respectively. `<` returns `0.0` or `1.0`.
- Assignment has the lowest precedence and associates right to left. It returns
  the stored value, so `x = y = 3` is valid.
- A binary operator declaration accepts an integer precedence from 1 through
  100; omitted precedence defaults to 30. Built-ins and assignment cannot be
  redefined. Successfully submitted operator definitions affect later inputs.
- Conditions treat `0.0` as false and every nonzero value as true. Both `if`
  branches must produce a `Double`.
- A `for` body runs once before its end condition is checked. After each body,
  the loop variable advances by the step (default `1.0`), then the end
  expression decides whether another iteration runs. The loop expression
  returns `0.0`.
- A missing `var` initializer defaults to `0.0`. Each initializer is evaluated
  before its own binding enters scope; earlier bindings in the same list remain
  visible. Inner bindings restore an outer binding on scope exit.
- A normal call must have a prototype and exactly the declared argument count.
  Function and operator redefinition is rejected; this example has no
  newest-first shadowing.
- `extern` records only a prototype. LLJIT resolves the symbol from the current
  process when generated code first needs it, so declaration can succeed before
  a missing-symbol error is reported.

## Architecture and lifecycle

The package dependencies remain one-way:

```text
lexer       ast
   \         /
      parser
        |
ast + llvm/IR -> codegen
parser + codegen + llvm/JIT -> session
session + readline -> main
session -> integration_test
```

Each definition or anonymous expression owns a fresh LLVM `Context`, `Module`,
and `IRBuilder`. The prototype catalog stores only MoonBit AST data and never
retains an LLVM value from a previous module. Successful definitions remain in
the LLJIT default tracker until `Session::close`.

An anonymous expression is compiled under a unique symbol and an independent
`ResourceTracker`. The Session looks it up, invokes it, and removes its tracker
before returning. Parse, codegen, verification, submission, lookup, or
materialization failure does not commit a partial definition or operator
precedence. Cleanup failure preserves both the primary and cleanup diagnostics.

The Session is intentionally serial. Call `Session::close` exactly once; use
after close and repeated close are errors.

## Safety boundary

No Kaleidoscope package imports `Kaida-Amethyst/llvm/internal/raw`. Conversion
from a JIT address to `FuncRef[() -> Double]` occurs only inside the private
Session execution boundary, while the address and resource tracker remain
alive. The parser, code generator, REPL, and integration tests do not handle
raw addresses.

This boundary provides lifecycle discipline, not isolation. Submitted input is
compiled to native code and executes in the REPL process. The example is not a
sandbox and must not evaluate untrusted source. `extern` can refer only to
symbols already visible in the current process; arbitrary MoonBit closures and
host callback registration are deliberately unsupported.

## Tests

From the repository root, run all workspace tests with:

```sh
moon check --target native
moon test --target native
```

The non-interactive suite includes lexer and parser snapshots, verified IR
snapshots, real JIT execution, repeated anonymous-module unload, cross-module
calls, error recovery, and deterministic shutdown. `integration_test` imports
only `session`; it does not import readline or raw bindings.

The repository's GitHub Actions matrix runs these workspace tests on macOS
ARM64 and Linux x86_64 with both the latest and nightly MoonBit toolchains. PTY
editing behavior remains the responsibility of readline.mbt, so CI does not
simulate an interactive terminal.

## Deliberate non-goals

- Optimization passes are omitted because llvm.mbt does not yet expose the
  required safe PassBuilder/PassManager layer. Generated modules are verified
  but otherwise unoptimized.
- Debug information is omitted because the safe API does not expose DIBuilder
  and source-location ownership.
- Object-file emission is not repeated here. The MiniMoonBit example already
  exercises llvm.mbt's native object and executable path; Kaleidoscope focuses
  on incremental JIT lifecycle.
- Hot redefinition, custom JITDylibs, lazy compilation, object caches,
  cross-target JIT, asynchronous execution, and arbitrary host callbacks are
  outside this example's ownership model.
- Strings, aggregates, garbage collection, multiple runtime types, multiline
  parsing, syntax highlighting, and language-server features are language
  extensions rather than llvm.mbt JIT demonstrations.
