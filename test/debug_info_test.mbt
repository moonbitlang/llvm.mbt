///|
using @IR {
  type DIBuilder,
  type DIFlags,
  type DIFile,
  type DILocation,
  type DISubprogram,
  type DebugInfoError,
  type Function,
}

///|
/// Pieces of a compiler-style line-table module used by several tests.
priv struct DebugModule {
  ctx : Context
  mod : @IR.Module
  dib : DIBuilder
  file : DIFile
  callee : Function
  callee_sp : DISubprogram
  main : Function
  main_sp : DISubprogram
}

///|
/// Builds `callee` and `main` with subprograms, but no instructions yet.
fn debug_module(name : String) -> DebugModule raise {
  let ctx = Context::new()
  let mod = ctx.addModule(name)
  mod.setSourceFileName("main.runa")
  let dib = DIBuilder::new(mod)
  let file = dib.createFile("main.runa", "/work/runa")
  dib.createCompileUnit(
    C11,
    file,
    "runa 0.1",
    emissionKind=LineTablesOnly,
    splitDebugInlining=false,
  )
  |> ignore
  let fn_ty = ctx.getFunctionType(ctx.getInt32Ty(), [])
  let di_ty = dib.createSubroutineType(file, [])
  let callee = mod.addFunction(fn_ty, "callee")
  let callee_sp = dib.createFunction(
    file,
    "callee",
    "callee",
    file,
    10,
    di_ty,
    flags=DIFlags::new([Prototyped]),
  )
  callee.setSubprogram(callee_sp)
  let main = mod.addFunction(fn_ty, "main")
  let main_sp = dib.createFunction(
    file,
    "main",
    "main",
    file,
    1,
    di_ty,
    scopeLine=2,
    flags=DIFlags::new([Prototyped]),
  )
  main.setSubprogram(main_sp)
  { ctx, mod, dib, file, callee, callee_sp, main, main_sp, }
}

///|
/// Emits `ret i32 1` with a location into `callee`.
fn emit_callee_body(m : DebugModule) -> Unit raise {
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.callee.addBasicBlock(name="entry"))
  builder.setCurrentDebugLocation(
    Some(m.ctx.createDebugLocation(11, 3, m.callee_sp)),
  )
  builder.createRet(m.ctx.getConstInt32(1)) |> ignore
}

///|
fn add_debug_module_flags(mod : @IR.Module) -> Unit {
  mod.addModuleFlagInt(Max, "Dwarf Version", 4)
  mod.addModuleFlagInt(
    Warning,
    "Debug Info Version",
    @IR.debugMetadataVersion(),
  )
}

///|
fn expect_verifier_error(mod : @IR.Module, fragment : String) -> Unit raise {
  try mod.verify() catch {
    @IR.VerificationError(message) =>
      if !message.contains(fragment) {
        fail("unexpected verifier message: \{message}")
      }
  } noraise {
    _ => fail("expected the verifier to reject the module")
  }
}

///|
test "line-table debug info for a small module verifies and prints" {
  let m = debug_module("debug_info")
  emit_callee_body(m)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock(name="entry"))
  let block = m.dib.createLexicalBlock(m.main_sp, m.file, 3, 5)
  builder.setCurrentDebugLocation(Some(m.ctx.createDebugLocation(3, 9, block)))
  let call = builder.createCall(m.callee, [], name="r")
  call.addFnStringAttr("runa-call", value="direct")
  builder.setCurrentDebugLocation(
    Some(m.ctx.createDebugLocation(4, 3, m.main_sp)),
  )
  builder.createRet(call) |> ignore
  for f in [m.callee, m.main] {
    f.addFnAttr(UWTable(Async))
    f.addFnStringAttr("frame-pointer", value="all")
  }
  add_debug_module_flags(m.mod)
  m.dib.finalize()
  m.mod.verify()
  inspect(m.mod.getDebugMetadataVersion(), content="3")
  inspect(
    m.mod,
    content=(
      #|; ModuleID = 'debug_info'
      #|source_filename = "main.runa"
      #|
      #|; Function Attrs: uwtable
      #|define i32 @callee() #0 !dbg !4 {
      #|entry:
      #|  ret i32 1, !dbg !7
      #|}
      #|
      #|; Function Attrs: uwtable
      #|define i32 @main() #0 !dbg !8 {
      #|entry:
      #|  %r = call i32 @callee() #1, !dbg !9
      #|  ret i32 %r, !dbg !11
      #|}
      #|
      #|attributes #0 = { uwtable "frame-pointer"="all" }
      #|attributes #1 = { "runa-call"="direct" }
      #|
      #|!llvm.dbg.cu = !{!0}
      #|!llvm.module.flags = !{!2, !3}
      #|
      #|!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "runa 0.1", isOptimized: false, runtimeVersion: 0, emissionKind: LineTablesOnly, splitDebugInlining: false)
      #|!1 = !DIFile(filename: "main.runa", directory: "/work/runa")
      #|!2 = !{i32 7, !"Dwarf Version", i32 4}
      #|!3 = !{i32 2, !"Debug Info Version", i32 3}
      #|!4 = distinct !DISubprogram(name: "callee", linkageName: "callee", scope: !1, file: !1, line: 10, type: !5, scopeLine: 10, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0)
      #|!5 = !DISubroutineType(types: !6)
      #|!6 = !{}
      #|!7 = !DILocation(line: 11, column: 3, scope: !4)
      #|!8 = distinct !DISubprogram(name: "main", linkageName: "main", scope: !1, file: !1, line: 1, type: !5, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0)
      #|!9 = !DILocation(line: 3, column: 9, scope: !10)
      #|!10 = distinct !DILexicalBlock(scope: !8, file: !1, line: 3, column: 5)
      #|!11 = !DILocation(line: 4, column: 3, scope: !8)
      #|
    ),
  )
}

///|
test "debug handles round-trip through functions, builders and instructions" {
  let m = debug_module("debug_roundtrip")
  inspect(m.file.getFilename(), content="main.runa")
  inspect(m.file.getDirectory(), content="/work/runa")
  assert_true(m.file.getFile() == Some(m.file))
  assert_true(m.main_sp.getFile() == Some(m.file))
  inspect(m.main_sp.getLine(), content="1")
  assert_true(m.main.getSubprogram() == Some(m.main_sp))
  let other = m.mod.addFunction(
    m.ctx.getFunctionType(m.ctx.getVoidTy(), []),
    "no_debug",
  )
  assert_true(other.getSubprogram() is None)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock(name="entry"))
  assert_true(builder.getCurrentDebugLocation() is None)
  let block = m.dib.createLexicalBlock(m.main_sp, m.file, 2, 1)
  let inner = m.dib.createLexicalBlock(block, m.file, 3, 1)
  assert_true(inner.getFile() == Some(m.file))
  let call_site = m.ctx.createDebugLocation(5, 1, m.main_sp)
  let loc = m.ctx.createDebugLocation(6, 2, inner, inlinedAt=call_site)
  inspect(loc.getLine(), content="6")
  inspect(loc.getColumn(), content="2")
  assert_true(loc.getInlinedAt() == Some(call_site))
  assert_true(call_site.getInlinedAt() is None)
  guard loc.getScope() is Some(scope) else { fail("expected a scope") }
  assert_true(scope.asDILocalScopeEnum() is DILexicalBlock(b) && b == inner)
  guard call_site.getScope() is Some(scope) else { fail("expected a scope") }
  assert_true(scope.asDILocalScopeEnum() is DISubprogram(sp) && sp == m.main_sp)
  // Uniqued nodes compare equal; distinct nodes do not.
  assert_true(
    m.ctx.createDebugLocation(6, 2, inner, inlinedAt=call_site) == loc,
  )
  assert_false(m.dib.createLexicalBlock(block, m.file, 3, 1) == inner)
  let here = m.ctx.createDebugLocation(7, 4, m.main_sp)
  builder.setCurrentDebugLocation(Some(here))
  assert_true(builder.getCurrentDebugLocation() == Some(here))
  let ret = builder.createRet(m.ctx.getConstInt32(0))
  assert_true(ret.getDebugLoc() == Some(here))
  ret.setDebugLoc(Some(call_site))
  assert_true(ret.getDebugLoc() == Some(call_site))
  ret.setDebugLoc(None)
  assert_true(ret.getDebugLoc() is None)
  ret.setDebugLoc(Some(here))
  builder.clearCurrentDebugLocation()
  assert_true(builder.getCurrentDebugLocation() is None)
  builder.setCurrentDebugLocation(Some(here))
  builder.setCurrentDebugLocation(None)
  assert_true(builder.getCurrentDebugLocation() is None)
  emit_callee_body(m)
  add_debug_module_flags(m.mod)
  m.dib.finalize()
  m.mod.verify()
}

///|
test "finalizeSubprogram and early finalize produce a verifiable module" {
  let m = debug_module("debug_finalize_subprogram")
  emit_callee_body(m)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock(name="entry"))
  builder.setCurrentDebugLocation(
    Some(m.ctx.createDebugLocation(2, 1, m.main_sp)),
  )
  builder.createRet(builder.createCall(m.callee, [])) |> ignore
  m.dib.finalizeSubprogram(m.callee_sp)
  m.dib.finalizeSubprogram(m.main_sp)
  add_debug_module_flags(m.mod)
  assert_false(m.dib.isFinalized())
  m.dib.finalize()
  assert_true(m.dib.isFinalized())
  // A second finalize is a no-op.
  m.dib.finalize()
  m.mod.verify()
}

///|
test "verifier rejects an inlinable call without a debug location" {
  let m = debug_module("debug_missing_call_loc")
  emit_callee_body(m)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock(name="entry"))
  // The call is built without a current debug location.
  let call = builder.createCall(m.callee, [])
  builder.setCurrentDebugLocation(
    Some(m.ctx.createDebugLocation(4, 3, m.main_sp)),
  )
  builder.createRet(call) |> ignore
  add_debug_module_flags(m.mod)
  m.dib.finalize()
  expect_verifier_error(
    m.mod,
    "inlinable function call in a function with debug info must have a !dbg location",
  )
  // Attaching a location afterwards repairs the module.
  call.setDebugLoc(Some(m.ctx.createDebugLocation(3, 1, m.main_sp)))
  m.mod.verify()
}

///|
test "verifier rejects a location scoped in another function" {
  let m = debug_module("debug_wrong_scope")
  emit_callee_body(m)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock(name="entry"))
  builder.setCurrentDebugLocation(
    Some(m.ctx.createDebugLocation(4, 3, m.callee_sp)),
  )
  builder.createRet(m.ctx.getConstInt32(0)) |> ignore
  add_debug_module_flags(m.mod)
  m.dib.finalize()
  expect_verifier_error(m.mod, "!dbg attachment points at wrong subprogram")
}

///|
test "verifier rejects a definition subprogram without a compile unit" {
  let ctx = Context::new()
  let mod = ctx.addModule("debug_no_compile_unit")
  let dib = DIBuilder::new(mod)
  let file = dib.createFile("main.runa", "/work/runa")
  let f = mod.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  f.setSubprogram(
    dib.createFunction(
      file,
      "f",
      "f",
      file,
      1,
      dib.createSubroutineType(file, []),
    ),
  )
  let builder = ctx.createBuilder()
  builder.setInsertPoint(f.addBasicBlock())
  builder.createRetVoid() |> ignore
  dib.finalize()
  expect_verifier_error(mod, "subprogram definitions must have a compile unit")
}

///|
test "verifier rejects duplicate module flag keys" {
  let mod = Context::new().addModule("duplicate_flags")
  mod.addModuleFlagInt(Max, "Dwarf Version", 4)
  mod.addModuleFlagInt(Max, "Dwarf Version", 5)
  expect_verifier_error(mod, "module flag identifiers must be unique")
}

///|
test "DIBuilder rejects a second compile unit and use after finalize" {
  let ctx = Context::new()
  let dib = DIBuilder::new(ctx.addModule("dibuilder_errors"))
  let file = dib.createFile("a.runa", "")
  dib.createCompileUnit(C11, file, "runa") |> ignore
  try dib.createCompileUnit(C11, file, "runa") catch {
    DebugInfoError::DuplicateCompileUnit => ()
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected DuplicateCompileUnit")
  }
  let ty = dib.createSubroutineType(file, [])
  let sp = dib.createFunction(file, "f", "", file, 1, ty)
  dib.finalize()
  let after_finalize : Array[() -> Unit raise DebugInfoError] = [
    () => dib.createFile("b.runa", "") |> ignore,
    () => dib.createSubroutineType(file, []) |> ignore,
    () => dib.createFunction(file, "g", "", file, 2, ty) |> ignore,
    () => dib.createLexicalBlock(sp, file, 1, 1) |> ignore,
    () => dib.createBasicType("Int", 64, Signed) |> ignore,
    () => dib.finalizeSubprogram(sp),
  ]
  for action in after_finalize {
    try action() catch {
      DebugInfoError::DIBuilderFinalized => ()
      _ => fail("unexpected error")
    } noraise {
      _ => fail("expected DIBuilderFinalized")
    }
  }
  // Locations do not need the builder and stay available after finalize.
  inspect(ctx.createDebugLocation(1, 1, sp).getLine(), content="1")
}

///|
fn expect_context_mismatch(
  action : () -> Unit raise DebugInfoError,
) -> Unit raise {
  try action() catch {
    DebugInfoError::MetadataContextMismatch => ()
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected MetadataContextMismatch")
  }
}

///|
test "debug info APIs reject metadata from another context" {
  let m = debug_module("debug_context_owner")
  let foreign = debug_module("debug_foreign_owner")
  let foreign_loc = foreign.ctx.createDebugLocation(1, 1, foreign.main_sp)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock())
  let ret = builder.createRet(m.ctx.getConstInt32(0))
  let actions : Array[() -> Unit raise DebugInfoError] = [
    () => m.dib.createCompileUnit(C11, foreign.file, "x") |> ignore,
    () => m.dib.createSubroutineType(foreign.file, []) |> ignore,
    () => {
      m.dib.createFunction(
        foreign.file,
        "f",
        "",
        m.file,
        1,
        m.dib.createSubroutineType(m.file, []),
      )
      |> ignore
    },
    () => m.dib.createLexicalBlock(foreign.main_sp, m.file, 1, 1) |> ignore,
    () => m.dib.finalizeSubprogram(foreign.main_sp),
    () => m.ctx.createDebugLocation(1, 1, foreign.main_sp) |> ignore,
    () => {
      m.ctx.createDebugLocation(1, 1, m.main_sp, inlinedAt=foreign_loc)
      |> ignore
    },
    () => m.main.setSubprogram(foreign.main_sp),
    () => builder.setCurrentDebugLocation(Some(foreign_loc)),
    () => ret.setDebugLoc(Some(foreign_loc)),
    () => m.mod.addModuleFlag(Error, "k", foreign.ctx.getMDString("v")),
    () => m.ctx.getConstantAsMetadata(foreign.ctx.getConstInt32(1)) |> ignore,
  ]
  for action in actions {
    expect_context_mismatch(action)
  }
  assert_true(m.main.getSubprogram() == Some(m.main_sp))
}

///|
test "compile unit options, basic types, and flags appear in the IR" {
  let ctx = Context::new()
  let mod = ctx.addModule("debug_options")
  let dib = DIBuilder::new(mod)
  let file = dib.createFile("lib.runa", "/src")
  dib.createCompileUnit(
    Rust,
    file,
    "runa",
    isOptimized=true,
    flags="-O2",
    emissionKind=DebugDirectivesOnly,
    sysroot="/sdk",
    sdk="MacOSX.sdk",
  )
  |> ignore
  let int_ty = dib.createBasicType("Int", 64, Signed)
  let ty = dib.createSubroutineType(file, [None, Some(int_ty)])
  let flags = DIFlags::new([Artificial]) | DIFlags::new([Prototyped, NoReturn])
  assert_true(flags.contains(NoReturn))
  assert_false(flags.contains(Thunk))
  let decl = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), [ctx.getInt64Ty()]),
    "abort_with",
  )
  decl.setSubprogram(
    dib.createFunction(
      file,
      "abort_with",
      "runa_abort_with",
      file,
      7,
      ty,
      isLocalToUnit=true,
      isDefinition=false,
      flags~,
      isOptimized=true,
    ),
  )
  dib.finalize()
  mod.verify()
  inspect(
    mod,
    content=(
      #|; ModuleID = 'debug_options'
      #|source_filename = "debug_options"
      #|
      #|declare !dbg !2 void @abort_with(i64)
      #|
      #|!llvm.dbg.cu = !{!0}
      #|
      #|!0 = distinct !DICompileUnit(language: DW_LANG_Rust, file: !1, producer: "runa", isOptimized: true, flags: "-O2", runtimeVersion: 0, emissionKind: DebugDirectivesOnly, sysroot: "/sdk", sdk: "MacOSX.sdk")
      #|!1 = !DIFile(filename: "lib.runa", directory: "/src")
      #|!2 = !DISubprogram(name: "abort_with", linkageName: "runa_abort_with", scope: !1, file: !1, line: 7, type: !3, scopeLine: 7, flags: DIFlagArtificial | DIFlagPrototyped | DIFlagNoReturn, spFlags: DISPFlagLocalToUnit | DISPFlagOptimized)
      #|!3 = !DISubroutineType(types: !4)
      #|!4 = !{null, !5}
      #|!5 = !DIBasicType(name: "Int", size: 64, encoding: DW_ATE_signed)
      #|
    ),
  )
}

///|
test "module flags cover every merge behavior" {
  let ctx = Context::new()
  let mod = ctx.addModule("module_flags")
  mod.addModuleFlagInt(Error, "error", 1)
  mod.addModuleFlagInt(Warning, "warning", 2)
  mod.addModuleFlagInt(Override, "override", 3)
  mod.addModuleFlag(Append, "append", ctx.getMDString("a"))
  mod.addModuleFlag(AppendUnique, "append-unique", ctx.getMDString("b"))
  mod.addModuleFlagInt(Max, "max", 4)
  mod.addModuleFlagInt(Min, "min", 5)
  mod.addModuleFlag(
    Override,
    "constant",
    ctx.getConstantAsMetadata(ctx.getConstInt32(6)),
  )
  guard mod.getModuleFlag("min") is Some(min) else { fail("missing min") }
  inspect(min, content="i32 5")
  guard mod.getModuleFlag("append") is Some(append) else {
    fail("missing append")
  }
  inspect(append, content="!\"a\"")
  assert_true(append == ctx.getMDString("a"))
  assert_true(mod.getModuleFlag("absent") is None)
  inspect(mod.getDebugMetadataVersion(), content="0")
  inspect(
    mod,
    content=(
      #|; ModuleID = 'module_flags'
      #|source_filename = "module_flags"
      #|
      #|!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7}
      #|
      #|!0 = !{i32 1, !"error", i32 1}
      #|!1 = !{i32 2, !"warning", i32 2}
      #|!2 = !{i32 4, !"override", i32 3}
      #|!3 = !{i32 5, !"append", !"a"}
      #|!4 = !{i32 6, !"append-unique", !"b"}
      #|!5 = !{i32 7, !"max", i32 4}
      #|!6 = !{i32 8, !"min", i32 5}
      #|!7 = !{i32 4, !"constant", i32 6}
      #|
    ),
  )
}

///|
test "stripDebugInfo removes subprograms, locations and debug metadata" {
  let m = debug_module("debug_strip")
  emit_callee_body(m)
  let builder = m.ctx.createBuilder()
  builder.setInsertPoint(m.main.addBasicBlock(name="entry"))
  builder.setCurrentDebugLocation(
    Some(m.ctx.createDebugLocation(2, 1, m.main_sp)),
  )
  builder.createRet(builder.createCall(m.callee, [])) |> ignore
  add_debug_module_flags(m.mod)
  m.dib.finalize()
  m.mod.verify()
  inspect(m.mod.stripDebugInfo(), content="true")
  assert_true(m.main.getSubprogram() is None)
  // Module flags, including "Debug Info Version", are not debug metadata.
  inspect(m.mod.getDebugMetadataVersion(), content="3")
  m.mod.verify()
  inspect(m.mod.stripDebugInfo(), content="false")
  let text = m.mod.to_string()
  assert_false(text.contains("!dbg"))
  assert_false(text.contains("DICompileUnit"))
}

///|
test "uwtable kinds and string attributes on functions and calls" {
  let ctx = Context::new()
  let mod = ctx.addModule("unwind_attrs")
  let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
  let callee = mod.addFunction(fty, "callee")
  let f = mod.addFunction(fty, "f")
  f.addFnAttr(UWTable(Sync))
  f.addFnStringAttr("frame-pointer", value="non-leaf")
  f.addFnStringAttr("runa-marker")
  // Re-adding a string attribute replaces its value.
  f.addFnStringAttr("frame-pointer", value="all")
  debug_inspect(f.getFnStringAttr("frame-pointer"), content="Some(\"all\")")
  debug_inspect(f.getFnStringAttr("runa-marker"), content="Some(\"\")")
  debug_inspect(f.getFnStringAttr("absent"), content="None")
  let builder = ctx.createBuilder()
  builder.setInsertPoint(f.addBasicBlock(name="entry"))
  let call = builder.createCall(callee, [])
  call.addFnStringAttr("frame-pointer", value="all")
  debug_inspect(call.getFnStringAttr("frame-pointer"), content="Some(\"all\")")
  debug_inspect(call.getFnStringAttr("runa-marker"), content="None")
  builder.createRetVoid() |> ignore
  mod.verify()
  inspect(
    f,
    content=(
      #|; Function Attrs: uwtable(sync)
      #|define void @f() #0 {
      #|entry:
      #|  call void @callee() #1
      #|  ret void
      #|}
      #|
    ),
  )
  inspect(
    mod
    .to_string()
    .contains(
      "attributes #0 = { uwtable(sync) \"frame-pointer\"=\"all\" \"runa-marker\" }",
    ),
    content="true",
  )
  inspect(
    mod.to_string().contains("attributes #1 = { \"frame-pointer\"=\"all\" }"),
    content="true",
  )
  f.removeFnAttr(UWTable(Async))
  f.addFnAttr(UWTable(Async))
  f.removeFnStringAttr("runa-marker")
  call.removeFnStringAttr("frame-pointer")
  debug_inspect(f.getFnStringAttr("runa-marker"), content="None")
  debug_inspect(call.getFnStringAttr("frame-pointer"), content="None")
  inspect(
    mod
    .to_string()
    .contains("attributes #0 = { uwtable \"frame-pointer\"=\"all\" }"),
    content="true",
  )
  f.removeFnAttr(UWTable(Sync))
  inspect(f.countFnAttrs(), content="1")
}

///|
test "DIBuilder keeps its module alive and locations survive the builder" {
  fn make() -> (DIBuilder, DILocation) raise {
    let ctx = Context::new()
    let dib = DIBuilder::new(ctx.addModule("temporary"), allowUnresolved=false)
    let file = dib.createFile("t.runa", "/tmp")
    dib.createCompileUnit(C, file, "runa") |> ignore
    let sp = dib.createFunction(
      file,
      "t",
      "t",
      file,
      1,
      dib.createSubroutineType(file, []),
    )
    (dib, ctx.createDebugLocation(9, 9, sp))
  }

  let (dib, loc) = make()
  inspect(dib.getModule().getName(), content="temporary")
  dib.finalize()
  inspect(loc.getLine(), content="9")
}
