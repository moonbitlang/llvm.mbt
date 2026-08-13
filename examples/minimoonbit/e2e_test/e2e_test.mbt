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
) -> (String, String) {
  let (code, stdout, stderr) = @async.with_timeout(10000, () => {
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
async fn load_cases() -> Array[Case] {
  let names = [
    "hello_world", "integer_arithmetic", "string", "array", "struct", "enum", "closure",
    "loop",
  ]
  let cases : Array[Case] = []
  for name in names {
    let base = "examples/minimoonbit/e2e_test/cases/\{name}"
    cases.push({
      name,
      source: @fs.read_file("\{base}.mbt").text(),
      expected: @fs.read_file("\{base}.ans").text(),
    })
  }
  cases
}

///|
async test "MiniMoonBit representative programs emit, link, and run" {
  @async.with_task_group() <| group => {
    let temp_dir = @fs.tmpdir(prefix="llvm-mbt-minimoonbit-e2e")
    group.add_defer() <| () => {
      @async.protect_from_cancel(() => @fs.rmdir(temp_dir, recursive=true))
    }
    let runtime_source = "examples/minimoonbit/runtime/runtime.c"
    let runtime_object = "\{temp_dir}/runtime.o"
    let (runtime_stdout, runtime_stderr) = run_process(
      "runtime",
      "runtime compilation",
      "cc",
      [
        "-std=c11", "-Wall", "-Wextra", "-pedantic", "-c", runtime_source, "-o",
        runtime_object,
      ],
    )
    guard runtime_stdout == "" && runtime_stderr == "" else {
      fail(
        "MiniMoonBit runtime compilation produced unexpected output\nstdout:\n\{runtime_stdout}\nstderr:\n\{runtime_stderr}",
      )
    }
    let machine = @IR.TargetMachine::host(@IR.TargetMachineOptions::default())
    let cases = load_cases()
    for case in cases {
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
      )
      guard stderr == "" else {
        fail(
          "MiniMoonBit case `\{case.name}` wrote unexpected stderr:\n\{stderr}",
        )
      }
      guard stdout.trim() == case.expected.trim() else {
        fail(
          "MiniMoonBit case `\{case.name}` produced unexpected stdout\nexpected:\n---\n\{case.expected}\n---\nactual:\n---\n\{stdout}\n---",
        )
      }
    }
  }
}
