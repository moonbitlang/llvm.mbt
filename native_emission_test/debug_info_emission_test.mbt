///|
/// Builds `answer` and `main` with line-table debug info, unwind tables, and
/// frame pointers, as a compiler front end would.
fn build_debug_module() -> Module raise {
  let ctx = Context::new()
  let mod = ctx.addModule("native_debug_info")
  mod.setSourceFileName("main.runa")
  let dib = @IR.DIBuilder::new(mod)
  let file = dib.createFile("main.runa", "/work/runa")
  dib.createCompileUnit(C11, file, "runa", emissionKind=LineTablesOnly)
  |> ignore
  let fn_ty = ctx.getFunctionType(ctx.getInt32Ty(), [])
  let di_ty = dib.createSubroutineType(file, [])
  let flags = @IR.DIFlags::new([Prototyped])
  let builder = ctx.createBuilder()
  let answer = mod.addFunction(fn_ty, "answer")
  let answer_sp = dib.createFunction(
    file,
    "answer",
    "answer",
    file,
    10,
    di_ty,
    flags~,
  )
  answer.setSubprogram(answer_sp)
  builder.setInsertPoint(answer.addBasicBlock(name="entry"))
  builder.setCurrentDebugLocation(
    Some(ctx.createDebugLocation(11, 3, answer_sp)),
  )
  builder.createRet(ctx.getConstInt32(42)) |> ignore
  let main = mod.addFunction(fn_ty, "main")
  let main_sp = dib.createFunction(file, "main", "main", file, 1, di_ty, flags~)
  main.setSubprogram(main_sp)
  builder.setInsertPoint(main.addBasicBlock(name="entry"))
  builder.setCurrentDebugLocation(Some(ctx.createDebugLocation(2, 5, main_sp)))
  let value = builder.createCall(answer, [], name="value")
  builder.setCurrentDebugLocation(Some(ctx.createDebugLocation(3, 5, main_sp)))
  builder.createRet(value) |> ignore
  for f in [answer, main] {
    f.addFnAttr(UWTable(Async))
    f.addFnStringAttr("frame-pointer", value="all")
  }
  mod.addModuleFlagInt(Max, "Dwarf Version", 4)
  mod.addModuleFlagInt(
    Warning,
    "Debug Info Version",
    @IR.debugMetadataVersion(),
  )
  dib.finalize()
  mod
}

///|
fn bytes_contain(haystack : Bytes, needle : String) -> Bool {
  let pattern : Array[Byte] = []
  for char in needle {
    pattern.push(char.to_int().to_byte())
  }
  let last = haystack.length() - pattern.length()
  for start = 0; start <= last; start = start + 1 {
    let mut matched = true
    for offset = 0; offset < pattern.length(); offset = offset + 1 {
      if haystack[start + offset] != pattern[offset] {
        matched = false
        break
      }
    }
    if matched {
      return true
    }
  }
  false
}

///|
async test "debug line table and unwind info reach the native object" {
  @async.with_task_group() <| group => {
    let temp_dir = @fs.tmpdir(prefix="llvm-mbt-debug-info")
    group.add_defer() <| () => {
      @async.protect_from_cancel(() => @fs.rmdir(temp_dir, recursive=true))
    }
    let object_path = "\{temp_dir}/debug_info.o"
    let mod = build_debug_module()
    let machine = TargetMachine::host(TargetMachineOptions::default())
    machine.configureModule(mod)
    mod.verify()
    machine.emitObjectToFile(mod, object_path)
    let object = @fs.read_file(object_path).binary()
    // Mach-O names the sections `__debug_line`/`__debug_info`; ELF uses
    // `.debug_line`/`.debug_info`. Both contain these substrings.
    assert_true(bytes_contain(object, "debug_line"))
    assert_true(bytes_contain(object, "debug_info"))
    // Mach-O arm64 emits compact unwind entries; ELF emits `.eh_frame`.
    assert_true(
      bytes_contain(object, "__compact_unwind") ||
      bytes_contain(object, "eh_frame"),
    )
    // Decode the line table when llvm-dwarfdump is installed; skip otherwise.
    let dump = @async.with_timeout(10000, () => {
      @process.collect_output("llvm-dwarfdump", ["--debug-line", object_path])
    }) catch {
      _ => return
    }
    let (code, stdout, stderr) = dump
    let stdout = stdout.text()
    guard code == 0 else {
      fail_process("llvm-dwarfdump", code, stdout, stderr.text())
    }
    assert_true(stdout.contains("main.runa"))
  }
}
