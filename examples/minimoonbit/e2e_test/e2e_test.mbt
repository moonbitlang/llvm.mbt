///|
priv struct Case {
  name : String
  source : String
  expected : String
}

///|
fn fail_process(
  case_name : String,
  stage : String,
  code : Int,
  stdout : String,
  stderr : String,
) -> Unit raise {
  fail(
    "MiniMoonBit case `\{case_name}` failed during \{stage} with exit code \{code}\nstdout:\n\{stdout}\nstderr:\n\{stderr}",
  )
}

///|
async fn run_process(
  case_name : String,
  stage : String,
  command : String,
  arguments : Array[String],
  timeout_ms? : Int = 10000,
) -> (String, String) {
  let (code, stdout, stderr) = @async.with_timeout(timeout_ms, () => {
    @process.collect_output(command, arguments)
  })
  let stdout = stdout.text()
  let stderr = stderr.text()
  if code != 0 {
    fail_process(case_name, stage, code, stdout, stderr)
  }
  (stdout, stderr)
}

///|
async fn load_case(name : String) -> Case {
  let base = "examples/minimoonbit/e2e_test/cases/\{name}"
  {
    name,
    source: @fs.read_file("\{base}.mbt").text(),
    expected: @fs.read_file("\{base}.ans").text(),
  }
}

///|
async fn run_case(
  machine : @IR.TargetMachine,
  runtime_object : String,
  temp_dir : String,
  case : Case,
  execution_timeout_ms : Int,
) -> Unit {
  let object_path = "\{temp_dir}/\{case.name}.o"
  let executable_path = "\{temp_dir}/\{case.name}"
  let mod = @codegen.compile(case.source, source_file="\{case.name}.mbt")
  machine.configureModule(mod)
  mod.verify()
  machine.emitObjectToFile(mod, object_path)
  let (link_stdout, link_stderr) = run_process(case.name, "linking", "cc", [
    object_path, runtime_object, "-lm", "-o", executable_path,
  ])
  guard link_stdout == "" && link_stderr == "" else {
    fail(
      "MiniMoonBit case `\{case.name}` linking produced unexpected output\nstdout:\n\{link_stdout}\nstderr:\n\{link_stderr}",
    )
  }
  let (stdout, stderr) = run_process(
    case.name,
    "execution",
    executable_path,
    [],
    timeout_ms=execution_timeout_ms,
  )
  guard stderr == "" else {
    fail("MiniMoonBit case `\{case.name}` wrote unexpected stderr:\n\{stderr}")
  }
  guard stdout.trim() == case.expected.trim() else {
    fail(
      "MiniMoonBit case `\{case.name}` produced unexpected stdout\nexpected:\n---\n\{case.expected}\n---\nactual:\n---\n\{stdout}\n---",
    )
  }
}

///|
async fn run_group(
  group_name : String,
  names : Array[String],
  execution_timeout_ms? : Int = 10000,
) -> Unit {
  @async.with_task_group() <| group => {
    let temp_dir = @fs.tmpdir(prefix="llvm-mbt-minimoonbit-\{group_name}")
    group.add_defer() <| () => {
      @async.protect_from_cancel(() => @fs.rmdir(temp_dir, recursive=true))
    }
    let runtime_source = "examples/minimoonbit/runtime/runtime.c"
    let runtime_object = "\{temp_dir}/runtime.o"
    let (runtime_stdout, runtime_stderr) = run_process(
      "runtime/\{group_name}",
      "runtime compilation",
      "cc",
      [
        "-std=c11", "-Wall", "-Wextra", "-pedantic", "-c", runtime_source, "-o",
        runtime_object,
      ],
    )
    guard runtime_stdout == "" && runtime_stderr == "" else {
      fail(
        "MiniMoonBit runtime compilation for group `\{group_name}` produced unexpected output\nstdout:\n\{runtime_stdout}\nstderr:\n\{runtime_stderr}",
      )
    }
    let machine = @IR.TargetMachine::host(
      @IR.TargetMachineOptions::new(relocationMode=@IR.Pic),
    )
    let failures : Array[String] = []
    for name in names {
      let case = load_case(name)
      run_case(machine, runtime_object, temp_dir, case, execution_timeout_ms) catch {
        err => failures.push("- `\{name}`: \{err}")
      }
    }
    guard failures.is_empty() else {
      fail(
        "MiniMoonBit e2e group `\{group_name}` failed in \{failures.length()} case(s):\n\{failures.join("\n")}",
      )
    }
  }
}

///|
async test "MiniMoonBit e2e: basic values and conversions" {
  run_group("basic", [
    "hello_world", "integer_arithmetic", "basic2", "basic3", "basic4", "basic5",
    "basic6", "basic7", "basic8", "basic9", "basic10", "bitcast_test", "int64_float_test",
    "uint_basic_test", "uint_conversion_test", "type_conversion", "to_string_test",
    "print", "id", "rectangle",
  ])
}

///|
async test "MiniMoonBit e2e: control flow and recursion" {
  run_group("control", [
    "loop", "ack", "caltz", "even-odd", "fib", "for-array", "for-nested", "gcd",
    "non-tail-if", "non-tail-if2", "sieve-for", "small", "sum", "sum-tail", "clamp",
    "shuffle",
  ])
}

///|
async test "MiniMoonBit e2e: arrays and data structures" {
  run_group("arrays", [
    "array", "avl", "list", "mergesort", "quicksort", "segment_tree", "union_find",
    "matrix-transpose", "uint_array_test",
  ])
}

///|
async test "MiniMoonBit e2e: strings" {
  run_group("strings", ["string", "string-loop", "string-nested"])
}

///|
async test "MiniMoonBit e2e: structs and tuples" {
  run_group("structs", [
    "struct", "struct2", "struct3", "struct4", "struct5", "struct6", "struct7", "struct8",
    "struct9", "struct10", "match_tuple_int", "vector2d", "complex_numbers",
  ])
}

///|
async test "MiniMoonBit e2e: enums and mixed aggregates" {
  run_group("enums", [
    "enum", "enum2", "enum3", "enum4", "enum5", "enum6", "enum7", "enum8", "struct_enum1",
    "struct_enum2", "struct_enum3", "struct_enum4", "struct_enum5", "struct_enum6",
    "struct_enum7",
  ])
}

///|
async test "MiniMoonBit e2e: closures" {
  run_group("closures", [
    "closure", "closure2", "closure3", "closure4", "closure5", "cls-bug", "cls-bug2",
    "cls-rec", "cls-reg-bug", "funcomp",
  ])
}

///|
async test "MiniMoonBit e2e: compiler regressions" {
  run_group("regressions", [
    "adder", "adder2", "counter", "join-reg", "join-reg2", "join-stack", "join-stack2",
    "join-stack3", "spill", "spill2", "spill3",
  ])
}

///|
async test "MiniMoonBit e2e: numerical programs" {
  run_group(
    "numerics",
    [
      "float", "exp", "expm1", "cbrt", "log", "log10", "inprod", "inprod-loop", "inprod-rec",
      "cholesky", "eigen", "invmat", "lu", "matmul", "matmul-flat", "matmul-for",
      "matmul-loop", "nbody", "qr", "schur", "svd", "conv_pool",
    ],
    execution_timeout_ms=30000,
  )
}

///|
async test "MiniMoonBit e2e: application workloads" {
  run_group(
    "applications",
    [
      "bio_reactor", "financial_forecast", "genomics_pipeline", "orbital_simulation",
      "population_model",
    ],
    execution_timeout_ms=30000,
  )
}
