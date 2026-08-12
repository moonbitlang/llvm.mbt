///|
using @IR {
  type Context,
  type Module,
  type TargetMachine,
  type TargetMachineOptions,
}

///|
fn build_average_module() -> (Context, Module) raise {
  let context = Context::new()
  let mod = context.addModule("native_average")
  let double_type = context.getDoubleTy()
  let function_type = context.getFunctionType(double_type, [
    double_type, double_type,
  ])
  let average = mod.addFunction(function_type, "average")
  guard average.getArg(0) is Some(lhs) else { fail("expected average lhs") }
  guard average.getArg(1) is Some(rhs) else { fail("expected average rhs") }
  let entry = average.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  let sum = builder.createFAdd(lhs, rhs, name="sum")
  let divisor = context.getConstDouble(2.0)
  let result = builder.createFDiv(sum, divisor, name="result")
  ignore(builder.createRet(result))
  (context, mod)
}

///|
fn fail_process(
  stage : String,
  code : Int,
  stdout : String,
  stderr : String,
) -> Unit raise {
  fail(
    "\{stage} failed with exit code \{code}\nstdout:\n\{stdout}\nstderr:\n\{stderr}",
  )
}

///|
async test "host object links and executes through the system toolchain" {
  @async.with_task_group() <| group => {
    let temp_dir = @fs.tmpdir(prefix="llvm-mbt-native-emission")
    group.add_defer() <| () => {
      @async.protect_from_cancel(() => @fs.rmdir(temp_dir, recursive=true))
    }
    let object_path = "\{temp_dir}/average.o"
    let harness_path = "\{temp_dir}/harness.c"
    let executable_path = "\{temp_dir}/average-test"
    let (context, mod) = build_average_module()
    ignore(context)
    let machine = TargetMachine::host(TargetMachineOptions::default())
    machine.configureModule(mod)
    mod.verify()
    machine.emitObjectToFile(mod, object_path)
    @fs.write_file(
      harness_path,
      (
        #|#include <stdio.h>
        #|
        #|extern double average(double lhs, double rhs);
        #|
        #|int main(void) {
        #|  printf("%.1f\n", average(3.0, 4.0));
        #|  return 0;
        #|}
        #|
      ),
      create_mode=@fs.CreateOrTruncate,
    )
    let (link_code, link_stdout, link_stderr) = @async.with_timeout(10000, () => {
      @process.collect_output("cc", [
        harness_path, object_path, "-o", executable_path,
      ])
    })
    let link_stdout = link_stdout.text()
    let link_stderr = link_stderr.text()
    guard link_code == 0 else {
      fail_process("cc link", link_code, link_stdout, link_stderr)
    }
    inspect(link_stdout, content="")
    inspect(link_stderr, content="")
    let (run_code, run_stdout, run_stderr) = @async.with_timeout(10000, () => {
      @process.collect_output(executable_path, [])
    })
    let run_stdout = run_stdout.text()
    let run_stderr = run_stderr.text()
    guard run_code == 0 else {
      fail_process("generated executable", run_code, run_stdout, run_stderr)
    }
    inspect(run_stdout, content="3.5\n")
    inspect(run_stderr, content="")
  }
}
