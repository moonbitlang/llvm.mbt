///|
test "unreachable terminates noreturn call and supports instruction views" {
  let ctx = Context::new()
  let mod = ctx.addModule("never")
  let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
  let panic_fn = mod.addFunction(fty, "panic")
  panic_fn.addFnAttr(NoReturn)
  let caller = mod.addFunction(fty, "caller")
  let bb = caller.addBasicBlock(name="entry")
  let builder = ctx.createBuilder()
  builder.setInsertPoint(bb)
  let call = builder.createCall(panic_fn, [])
  call.addFnAttr(NoReturn)
  inspect(bb.getTerminator() is None, content="true")
  let terminal = builder.createUnreachable()
  inspect(terminal.asValueEnum() is UnreachableInst(_), content="true")
  inspect(terminal.asInstEnum() is UnreachableInst(_), content="true")
  inspect(terminal.getContext() == ctx, content="true")
  inspect(terminal.getType().to_string(), content="void")
  guard terminal.getParentBasicBlock() is Some(parent) else {
    fail("missing parent")
  }
  inspect(parent.getName() == Some("entry"), content="true")
  guard bb.getTerminator() is Some(queried) else { fail("missing terminator") }
  inspect(queried.asInstEnum() is UnreachableInst(_), content="true")
  guard call.getNextInst() is Some(next) else { fail("missing next") }
  inspect(next.asInstEnum() is UnreachableInst(_), content="true")
  inspect(terminal.getNextInst() is None, content="true")
  guard terminal.getPrevInst() is Some(prev) else { fail("missing previous") }
  inspect(prev.asInstEnum() is CallInst(_), content="true")
  builder.setInsertPoint(terminal)
  builder.createCall(panic_fn, []) |> ignore
  inspect(
    caller,
    content=(
      #|define void @caller() {
      #|entry:
      #|  call void @panic() #0
      #|  call void @panic()
      #|  unreachable
      #|}
      #|
    ),
  )
  mod.verify()
}

///|
test "unreachable rejects unset ended and middle insertion points" {
  let ctx = Context::new()
  let builder = ctx.createBuilder()
  assert_builder_error(() => builder.createUnreachable(), e => {
    e is @IR.BuilderError::UnsetPosition
  })
  let mod = ctx.addModule("position")
  let function = mod.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  let bb = function.addBasicBlock()
  builder.setInsertPoint(bb)
  let ret = builder.createRetVoid()
  assert_builder_error(() => builder.createUnreachable(), e => {
    e is @IR.BuilderError::InValidInsertPoint(_)
  })
  builder.setInsertPoint(ret)
  assert_builder_error(() => builder.createUnreachable(), e => {
    e is @IR.BuilderError::InValidInsertPoint(_)
  })
  builder.setInsertPointBefore(ret)
  assert_builder_error(() => builder.createUnreachable(), e => {
    e is @IR.BuilderError::InValidInsertPoint(_)
  })
  ret.eraseFromParent()
  builder.setInsertPoint(bb)
  let terminal = builder.createUnreachable()
  terminal.removeFromParent()
  inspect(terminal.getParentBasicBlock() is None, content="true")
  builder.setInsertPoint(bb)
  builder.createUnreachable() |> ignore
  mod.verify()
}

///|
test "unreachable retains its module outside construction scope" {
  let terminal = {
    let ctx = Context::new()
    let mod = ctx.addModule("owner")
    let function = mod.addFunction(
      ctx.getFunctionType(ctx.getVoidTy(), []),
      "f",
    )
    let builder = ctx.createBuilder()
    builder.setInsertPoint(function.addBasicBlock(name="entry"))
    builder.createUnreachable()
  }
  inspect(terminal, content="  unreachable")
  guard terminal.getParentBasicBlock() is Some(bb) else {
    fail("missing owner")
  }
  inspect(bb.getName() == Some("entry"), content="true")
}

///|
test "call ABI extension attributes add remove and verify" {
  let ctx = Context::new()
  let mod = ctx.addModule("abi")
  let fty = ctx.getFunctionType(ctx.getInt8Ty(), [
    ctx.getInt8Ty(),
    ctx.getInt1Ty(),
  ])
  let callee = mod.addFunction(fty, "callee")
  callee.addRetAttr(SExt)
  guard callee.getArg(0) is Some(a) && callee.getArg(1) is Some(b) else {
    fail("missing parameters")
  }
  a.addAttr(SExt)
  b.addAttr(ZExt)
  let function = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), []),
    "caller",
  )
  let builder = ctx.createBuilder()
  builder.setInsertPoint(function.addBasicBlock())
  let call = builder.createCall(callee, [
    ctx.getConstInt8(-1),
    ctx.getConstTrue(),
  ])
  call.addRetAttr(SExt)
  call.addParamAttr(0, SExt)
  call.addParamAttr(1, ZExt)
  call.addFnAttr(NoUnwind)
  builder.createRetVoid() |> ignore
  mod.verify()
  inspect(
    callee,
    content=(
      #|declare signext i8 @callee(i8 signext, i1 zeroext)
      #|
    ),
  )
  inspect(
    call,
    content=(
      #|  %1 = call signext i8 @callee(i8 signext -1, i1 zeroext true) #0
    ),
  )
  call.removeRetAttr(SExt)
  call.removeParamAttr(0, SExt)
  call.removeParamAttr(1, ZExt)
  call.removeFnAttr(NoUnwind)
  callee.removeRetAttr(SExt)
  a.removeAttr(SExt)
  b.removeAttr(ZExt)
  callee.addRetAttr(ZExt)
  a.addAttr(ZExt)
  b.addAttr(SExt)
  call.addRetAttr(ZExt)
  call.addParamAttr(0, ZExt)
  call.addParamAttr(1, SExt)
  mod.verify()
  inspect(
    call,
    content=(
      #|  %1 = call zeroext i8 @callee(i8 zeroext -1, i1 signext true)
    ),
  )
  for index in [-1, 2, 2147483647] {
    assert_builder_error(() => call.addParamAttr(index, ZExt), e => {
      e is @IR.IndexOutOfBounds(_)
    })
    assert_builder_error(() => call.removeParamAttr(index, SExt), e => {
      e is @IR.IndexOutOfBounds(_)
    })
  }
  inspect(
    call,
    content=(
      #|  %1 = call zeroext i8 @callee(i8 zeroext -1, i1 signext true)
    ),
  )
}

///|
test "calling conventions roundtrip canonical values and reject truncation" {
  let ctx = Context::new()
  let mod = ctx.addModule("conventions")
  let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
  let callee = mod.addFunction(fty, "callee")
  let caller = mod.addFunction(fty, "caller")
  let builder = ctx.createBuilder()
  builder.setInsertPoint(caller.addBasicBlock())
  let call = builder.createCall(callee, [])
  builder.createRetVoid() |> ignore
  inspect(callee.getCallingConv() == @IR.CallingConv::C, content="true")
  inspect(call.getCallingConv() == @IR.CallingConv::C, content="true")
  for convention in [@IR.CallingConv::C, Fast, Cold, Other(777), Other(1023)] {
    callee.setCallingConv(convention)
    call.setCallingConv(convention)
    assert_true(callee.getCallingConv() == convention)
    assert_true(call.getCallingConv() == convention)
    mod.verify()
  }
  callee.setCallingConv(Other(8))
  call.setCallingConv(Other(8))
  inspect(call.getCallingConv() == @IR.CallingConv::Fast, content="true")
  inspect(call, content="  call fastcc void @callee()")
  for value in [1024U, 4294967295U] {
    assert_builder_error(() => callee.setCallingConv(Other(value)), e => {
      e is @IR.CallingConvError::InvalidID(_)
    })
    assert_builder_error(() => call.setCallingConv(Other(value)), e => {
      e is @IR.CallingConvError::InvalidID(_)
    })
  }
  inspect(callee.getCallingConv() == @IR.CallingConv::Fast, content="true")
  inspect(call.getCallingConv() == @IR.CallingConv::Fast, content="true")
  mod.verify()
}

///|
test "struct field offsets follow padding packing nesting and live layout" {
  let ctx = Context::new()
  let mod = ctx.addModule("offsets")
  mod.setDataLayout("e-p:64:64-i32:32-i64:64")
  let layout = mod.getDataLayout()
  let plain = ctx.getStructType([
    ctx.getInt8Ty(),
    ctx.getInt32Ty(),
    ctx.getInt8Ty(),
  ])
  let packed = ctx.getStructType(
    [ctx.getInt8Ty(), ctx.getInt32Ty()],
    isPacked=true,
  )
  let nested = ctx.getStructType([ctx.getInt8Ty(), plain, ctx.getInt64Ty()])
  debug_inspect(
    [
      layout.getElementOffset(plain, 0),
      layout.getElementOffset(plain, 1),
      layout.getElementOffset(plain, 2),
    ],
    content="[0, 4, 8]",
  )
  inspect(layout.getElementOffset(packed, 1), content="1")
  debug_inspect(
    [layout.getElementOffset(nested, 1), layout.getElementOffset(nested, 2)],
    content="[4, 16]",
  )
  let pointers = ctx.getStructType([ctx.getInt8Ty(), ctx.getPtrTy()])
  inspect(layout.getElementOffset(pointers, 1), content="8")
  mod.setDataLayout("e-p:32:32-i32:32")
  inspect(layout.getElementOffset(pointers, 1), content="4")
}

///|
test "struct field offset validation covers unsized scalable and foreign types" {
  let ctx = Context::new()
  let mod = ctx.addModule("invalid_offsets")
  let layout = mod.getDataLayout()
  let plain = ctx.getStructType([ctx.getInt8Ty()])
  for index in [-1, 1] {
    assert_builder_error(() => layout.getElementOffset(plain, index), e => {
      e is @IR.IndexOutOfBounds(_)
    })
  }
  let opaque_ty = ctx.getOpaqueStructType("Opaque")
  let nested_opaque = ctx.getStructType([opaque_ty])
  let foreign_ctx = Context::new()
  let foreign = foreign_ctx.getStructType([foreign_ctx.getInt8Ty()])
  let vector = ctx.getScalableVectorType(ctx.getInt32Ty(), 4)
  let scalable = ctx.getStructType([vector, vector])
  for ty in [opaque_ty, nested_opaque, foreign, scalable] {
    assert_builder_error(() => layout.getElementOffset(ty, 0), e => {
      e is @IR.InValidTypeError(_)
    })
  }
  let empty = ctx.getOpaqueStructType("Empty")
  empty.setBody([])
  assert_builder_error(() => layout.getElementOffset(empty, 0), e => {
    e is @IR.IndexOutOfBounds(_)
  })
}

///|
test "field offsets reject values above Int maximum without truncating" {
  let ctx = Context::new()
  let mod = ctx.addModule("large_offsets")
  let huge = ctx.getArrayType(ctx.getInt8Ty(), 2147483647)
  let ty = ctx.getStructType([huge, ctx.getInt8Ty(), ctx.getInt8Ty()])
  let layout = mod.getDataLayout()
  inspect(layout.getElementOffset(ty, 1), content="2147483647")
  assert_builder_error(() => layout.getElementOffset(ty, 2), e => {
    e is @IR.DataLayoutError::OffsetOutOfRange(2147483648UL)
  })
}

///|
test "byte constants preserve NUL non UTF8 empty and termination" {
  let ctx = Context::new()
  let bytes = ctx.getConstBytes(b"a\x00\xffb")
  inspect(
    bytes,
    content=(
      #|[4 x i8] c"a\00\FFb"
    ),
  )
  inspect(
    ctx.getConstBytes(b""),
    content=(
      #|[0 x i8] zeroinitializer
    ),
  )
  inspect(
    ctx.getConstBytes(b"", nullTerminate=true),
    content=(
      #|[1 x i8] zeroinitializer
    ),
  )
  inspect(
    ctx.getConstBytes(b"a\x00", nullTerminate=true),
    content=(
      #|[3 x i8] c"a\00\00"
    ),
  )
  let mod = ctx.addModule("bytes")
  mod.addGlobalConstant(bytes.getType(), "data", bytes) |> ignore
  mod.verify()
}

///|
test "intrinsic overloads create reusable verified integer declarations" {
  let ctx = Context::new()
  let mod = ctx.addModule("intrinsics")
  for
    name in [
      "llvm.sadd.with.overflow", "llvm.ssub.with.overflow", "llvm.smul.with.overflow",
    ] {
    for ty in [ctx.getInt8Ty() as &Type, ctx.getInt32Ty(), ctx.getInt64Ty()] {
      let intrinsic = mod.getIntrinsicDeclaration(name, [ty])
      let again = mod.getIntrinsicDeclaration(name, [ty])
      assert_eq(intrinsic.getValueName(), again.getValueName())
      assert_eq(intrinsic.getType().to_string(), "{ \{ty}, i1 } (\{ty}, \{ty})")
    }
  }
  inspect(mod.getFunctions().length(), content="9")
  mod.verify()
}

///|
test "intrinsic validation rejects unknown unsupported overload and collision" {
  let ctx = Context::new()
  let mod = ctx.addModule("intrinsic_errors")
  let name = "llvm.sadd.with.overflow"
  assert_builder_error(
    () => mod.getIntrinsicDeclaration("llvm.does.not.exist", []),
    e => e is @IR.IntrinsicError::UnknownName(_),
  )
  assert_builder_error(
    () => mod.getIntrinsicDeclaration("llvm.sqrt", [ctx.getDoubleTy()]),
    e => e is @IR.IntrinsicError::UnsupportedName(_),
  )
  let foreign = Context::new()
  for
    types in [
      [],
      [ctx.getInt32Ty() as &Type, ctx.getInt32Ty()],
      [ctx.getFloatTy()],
      [foreign.getInt32Ty()],
      [ctx.getFixedVectorType(ctx.getInt32Ty(), 4)],
    ] {
    assert_builder_error(() => mod.getIntrinsicDeclaration(name, types), e => {
      e is @IR.InValidTypeError(_)
    })
  }
  mod.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), name + ".i32")
  |> ignore
  assert_builder_error(
    () => mod.getIntrinsicDeclaration(name, [ctx.getInt32Ty()]),
    e => e is @IR.IntrinsicError::ConflictingDeclaration(_),
  )
}

///|
test "pass pipeline optimizes a clone and keeps original instruction alive" {
  let ctx = Context::new()
  let mod = ctx.addModule("passes")
  let machine = @IR.TargetMachine::host(@IR.TargetMachineOptions::default())
  machine.configureModule(mod)
  let function = mod.addFunction(
    ctx.getFunctionType(ctx.getInt32Ty(), [ctx.getInt32Ty()]),
    "identity",
  )
  guard function.getArg(0) is Some(arg) else { fail("missing argument") }
  let builder = ctx.createBuilder()
  builder.setInsertPoint(function.addBasicBlock())
  let add = builder.createAdd(arg, ctx.getConstInt32(0), name="redundant")
  builder.createRet(add) |> ignore
  let before = mod.to_string()
  let optimized = mod.runPasses("function(instcombine)", targetMachine=machine)
  inspect(mod.to_string() == before, content="true")
  inspect(add, content="  %redundant = add i32 %0, 0")
  guard optimized.getFunction("identity") is Some(result) else {
    fail("missing optimized function")
  }
  inspect(
    result,
    content=(
      #|define i32 @identity(i32 %0) {
      #|  ret i32 %0
      #|}
      #|
    ),
  )
  optimized.verify()
  mod.verify()
  for pipeline in ["not-a-pass", "default<O9>", "instcombine\u0000,verify"] {
    assert_builder_error(() => mod.runPasses(pipeline, targetMachine=machine), e => {
      e is @IR.PassError::PipelineFailed(_)
    })
    assert_eq(mod.to_string(), before)
  }
}

///|
test "pass pipeline reports invalid input with verifier diagnostic" {
  let ctx = Context::new()
  let mod = ctx.addModule("invalid_pass_input")
  let function = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), []),
    "unterminated",
  )
  function.addBasicBlock() |> ignore
  let machine = @IR.TargetMachine::host(@IR.TargetMachineOptions::default())
  machine.configureModule(mod)
  assert_builder_error(
    () => mod.runPasses("default<O2>", targetMachine=machine),
    e => e is @IR.VerificationError(_),
  )
}

///|
test "overflow intrinsics execute wrapping results and signed overflow flags" {
  let ctx = Context::new()
  let mod = ctx.addModule("execute_overflow")
  let i32 = ctx.getInt32Ty()
  for op in ["sadd", "ssub", "smul"] {
    let intrinsic = mod.getIntrinsicDeclaration("llvm.\{op}.with.overflow", [
      i32,
    ])
    for index in 0..<2 {
      let function = mod.addFunction(
        ctx.getFunctionType(i32, [i32, i32]),
        "\{op}_\{index}",
      )
      guard function.getArgs() is [lhs, rhs] else { fail("missing arguments") }
      let builder = ctx.createBuilder()
      builder.setInsertPoint(function.addBasicBlock())
      let pair = builder.createCall(intrinsic, [lhs, rhs])
      let value = builder.createExtractValue(pair, index)
      let result = if index == 1 {
        builder.createZExt(value, i32)
      } else {
        value
      }
      builder.createRet(result) |> ignore
    }
  }
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)
  for
    (op, lhs, rhs, expected, overflow) in [
      ("sadd", 20, 22, 42, 0),
      ("sadd", 2147483647, 1, -2147483648, 1),
      ("ssub", 20, 22, -2, 0),
      ("ssub", -2147483648, 1, 2147483647, 1),
      ("smul", 6, 7, 42, 0),
      ("smul", 2147483647, 2, -2, 1),
      ("smul", -2147483648, -1, -2147483648, 1),
    ] {
    let value : FuncRef[(Int, Int) -> Int] = jit
      .lookup("\{op}_0")
      .unsafeToFuncRef()
    let flag : FuncRef[(Int, Int) -> Int] = jit
      .lookup("\{op}_1")
      .unsafeToFuncRef()
    assert_eq(value(lhs, rhs), expected)
    assert_eq(flag(lhs, rhs), overflow)
  }
  jit.close()
}

///|
test "call attributes address variadic actual arguments" {
  let ctx = Context::new()
  let mod = ctx.addModule("varargs")
  let callee = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), [], isVarArg=true),
    "callee",
  )
  let caller = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), []),
    "caller",
  )
  let builder = ctx.createBuilder()
  builder.setInsertPoint(caller.addBasicBlock())
  let call = builder.createCall(callee, [ctx.getConstInt32(42)])
  call.addParamAttr(0, ZExt)
  inspect(call, content="  call void (...) @callee(i32 zeroext 42)")
  builder.createRetVoid() |> ignore
  mod.verify()
  call.removeParamAttr(0, ZExt)
  assert_builder_error(() => call.addParamAttr(1, ZExt), e => {
    e is @IR.IndexOutOfBounds(_)
  })
  mod.verify()
}

///|
test "intrinsic declarations reject colliding globals and definitions" {
  let ctx = Context::new()
  let name = "llvm.sadd.with.overflow"
  let i32 = ctx.getInt32Ty()
  let globals = ctx.addModule("colliding_global")
  globals.addGlobalVariable(i32, name + ".i32") |> ignore
  assert_builder_error(() => globals.getIntrinsicDeclaration(name, [i32]), e => {
    e is @IR.IntrinsicError::ConflictingDeclaration(_)
  })
  let definitions = ctx.addModule("colliding_definition")
  let result_type = ctx.getStructType([i32, ctx.getInt1Ty()])
  let definition = definitions.addFunction(
    ctx.getFunctionType(result_type, [i32, i32]),
    name + ".i32",
  )
  definition.addBasicBlock() |> ignore
  assert_builder_error(() => definitions.getIntrinsicDeclaration(name, [i32]), e => {
    e is @IR.IntrinsicError::ConflictingDeclaration(_)
  })
}
