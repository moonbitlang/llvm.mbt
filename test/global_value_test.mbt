///|
using @IR {type Linkage, type StringError, type UnnamedAddr}

///|
fn[T] assert_contains_nul(f : () -> T raise) -> Unit raise {
  try f() catch {
    error => assert_true(error is StringError::ContainsNul)
  } noraise {
    _ => fail("expected StringError::ContainsNul")
  }
}

///|
fn same_linkage(expected : Linkage, actual : Linkage) -> Bool {
  match expected {
    ExternalLinkage => actual is ExternalLinkage
    AvailableExternallyLinkage => actual is AvailableExternallyLinkage
    LinkOnceAnyLinkage => actual is LinkOnceAnyLinkage
    LinkOnceODRLinkage => actual is LinkOnceODRLinkage
    LinkOnceODRAutoHideLinkage => actual is LinkOnceODRAutoHideLinkage
    WeakAnyLinkage => actual is WeakAnyLinkage
    WeakODRLinkage => actual is WeakODRLinkage
    AppendingLinkage => actual is AppendingLinkage
    InternalLinkage => actual is InternalLinkage
    PrivateLinkage => actual is PrivateLinkage
    DLLImportLinkage => actual is DLLImportLinkage
    DLLExportLinkage => actual is DLLExportLinkage
    ExternalWeakLinkage => actual is ExternalWeakLinkage
    GhostLinkage => actual is GhostLinkage
    CommonLinkage => actual is CommonLinkage
    LinkerPrivateLinkage => actual is LinkerPrivateLinkage
    LinkerPrivateWeakLinkage => actual is LinkerPrivateWeakLinkage
  }
}

///|
fn linkage_name(linkage : Linkage) -> String {
  match linkage {
    ExternalLinkage => "ExternalLinkage"
    AvailableExternallyLinkage => "AvailableExternallyLinkage"
    LinkOnceAnyLinkage => "LinkOnceAnyLinkage"
    LinkOnceODRLinkage => "LinkOnceODRLinkage"
    LinkOnceODRAutoHideLinkage => "LinkOnceODRAutoHideLinkage"
    WeakAnyLinkage => "WeakAnyLinkage"
    WeakODRLinkage => "WeakODRLinkage"
    AppendingLinkage => "AppendingLinkage"
    InternalLinkage => "InternalLinkage"
    PrivateLinkage => "PrivateLinkage"
    DLLImportLinkage => "DLLImportLinkage"
    DLLExportLinkage => "DLLExportLinkage"
    ExternalWeakLinkage => "ExternalWeakLinkage"
    GhostLinkage => "GhostLinkage"
    CommonLinkage => "CommonLinkage"
    LinkerPrivateLinkage => "LinkerPrivateLinkage"
    LinkerPrivateWeakLinkage => "LinkerPrivateWeakLinkage"
  }
}

///|
fn expected_linkage_after_set(linkage : Linkage) -> Linkage {
  match linkage {
    LinkOnceODRAutoHideLinkage => @IR.LinkOnceODRLinkage
    GhostLinkage => @IR.ExternalWeakLinkage
    DLLImportLinkage => @IR.PrivateLinkage
    DLLExportLinkage => @IR.PrivateLinkage
    LinkerPrivateLinkage => @IR.PrivateLinkage
    LinkerPrivateWeakLinkage => @IR.PrivateLinkage
    _ => linkage
  }
}

///|
fn same_unnamed_addr(expected : UnnamedAddr, actual : UnnamedAddr) -> Bool {
  match expected {
    NoUnnamedAddr => actual is NoUnnamedAddr
    Local => actual is Local
    Global => actual is Global
  }
}

///|
test "GlobalVariable basic behavior" {
  let context = Context::new()
  let mod = context.addModule("global_variable")
  let i32_type = context.getInt32Ty()
  let initial_value = context.getConstInt32(42)
  let global = mod.addGlobalVariable(
    i32_type,
    "answer",
    initializer=initial_value,
  )
  inspect(
    global,
    content=(
      #|@answer = global i32 42
    ),
  )
  debug_inspect(
    global.getValueName(),
    content=(
      #|Some("answer")
    ),
  )
  assert_true(global.asValueEnum() is GlobalVariable(_))
  assert_true(global.asGlobalEnum() is GlobalVariable(_))
  assert_true(global.getLinkage() is ExternalLinkage)
  assert_true(global.getUnnamedAddr() is NoUnnamedAddr)
}

///|
test "GlobalValue linkage round trip and normalization" {
  let context = Context::new()
  let mod = context.addModule("global_linkage")
  let global = mod.addGlobalVariable(context.getInt32Ty(), "value")
  let linkages = [
    @IR.ExternalLinkage,
    @IR.AvailableExternallyLinkage,
    @IR.LinkOnceAnyLinkage,
    @IR.LinkOnceODRLinkage,
    @IR.LinkOnceODRAutoHideLinkage,
    @IR.WeakAnyLinkage,
    @IR.WeakODRLinkage,
    @IR.AppendingLinkage,
    @IR.InternalLinkage,
    @IR.PrivateLinkage,
    @IR.DLLImportLinkage,
    @IR.DLLExportLinkage,
    @IR.ExternalWeakLinkage,
    @IR.GhostLinkage,
    @IR.CommonLinkage,
    @IR.LinkerPrivateLinkage,
    @IR.LinkerPrivateWeakLinkage,
  ]
  for linkage in linkages {
    global.setLinkage(linkage)
    let actual = global.getLinkage()
    let expected = expected_linkage_after_set(linkage)
    assert_true(
      same_linkage(expected, actual),
      msg="\{linkage_name(linkage)} -> \{linkage_name(actual)}",
    )
  }
}

///|
test "GlobalValue unnamed address round trip and removal" {
  let context = Context::new()
  let mod = context.addModule("global_unnamed_address")
  let global = mod.addGlobalVariable(context.getInt32Ty(), "value")
  let unnamed_addresses = [@IR.NoUnnamedAddr, @IR.Local, @IR.Global]
  for unnamed_address in unnamed_addresses {
    global.setUnnamedAddr(unnamed_address)
    assert_true(same_unnamed_addr(unnamed_address, global.getUnnamedAddr()))
  }
  global.removeUnnamedAddr()
  assert_true(global.getUnnamedAddr() is NoUnnamedAddr)
}

///|
test "GlobalValue name round trip" {
  let context = Context::new()
  let mod = context.addModule("global_name")
  let global = mod.addGlobalVariable(context.getInt32Ty(), "original")
  global.setValueName("renamed")
  debug_inspect(
    global.getValueName(),
    content=(
      #|Some("renamed")
    ),
  )
  global.setValueName("")
  assert_true(global.getValueName() is None)
}

///|
test "GlobalValue names reject embedded NUL" {
  let context = Context::new()
  let mod = context.addModule("global_name_error")
  let i32_type = context.getInt32Ty()
  let value = context.getConstInt32(1)
  let invalid_name = "invalid\u{0000}name"
  assert_contains_nul(() => mod.addGlobalVariable(i32_type, invalid_name))
  assert_contains_nul(() => mod.addGlobalConstant(i32_type, invalid_name, value))
  let global = mod.addGlobalVariable(i32_type, "valid")
  assert_contains_nul(() => global.setValueName(invalid_name))
}

///|
test "GlobalConstant basic behavior" {
  let context = Context::new()
  let mod = context.addModule("global_constant")
  let i32_type = context.getInt32Ty()
  let value = context.getConstInt32(7)
  let global = mod.addGlobalConstant(i32_type, "limit", value)
  inspect(
    global,
    content=(
      #|@limit = constant i32 7
    ),
  )
  debug_inspect(
    global.getValueName(),
    content=(
      #|Some("limit")
    ),
  )
  assert_true(global.asValueEnum() is GlobalConstant(_))
  assert_true(global.asGlobalEnum() is GlobalConstant(_))
  assert_true(global.getLinkage() is ExternalLinkage)
  assert_true(global.getUnnamedAddr() is NoUnnamedAddr)
}
