///|
fn floating_intrinsic_cases() -> Array[(String, Int)] {
  [
    ("llvm.fabs", 1),
    ("llvm.sqrt", 1),
    ("llvm.floor", 1),
    ("llvm.ceil", 1),
    ("llvm.trunc", 1),
    ("llvm.round", 1),
    ("llvm.roundeven", 1),
    ("llvm.rint", 1),
    ("llvm.nearbyint", 1),
    ("llvm.copysign", 2),
    ("llvm.minnum", 2),
    ("llvm.maxnum", 2),
    ("llvm.minimum", 2),
    ("llvm.maximum", 2),
    ("llvm.fma", 3),
    ("llvm.fmuladd", 3),
  ]
}

///|
test "floating intrinsics verify all names scalar overloads signatures and reuse" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("floating_intrinsics")
  for (name, arity) in floating_intrinsic_cases() {
    for
      (ty, suffix) in [
        (ctx.getFloatTy() as &@IR.Type, "f32"),
        (ctx.getDoubleTy(), "f64"),
        (ctx.getHalfTy(), "f16"),
        (ctx.getBFloatTy(), "bf16"),
        (ctx.getFP128Ty(), "f128"),
      ] {
      let intrinsic = mod.getIntrinsicDeclaration(name, [ty])
      let expected = ctx.getFunctionType(ty, Array::make(arity, ty))
      assert_eq(intrinsic.getValueName(), Some(name + "." + suffix))
      assert_true(intrinsic.getType() == expected)
      guard intrinsic.getArg(0) is Some(arg) else { fail("missing argument") }
      arg.setValueName("input")
      let again = mod.getIntrinsicDeclaration(name, [ty])
      guard again.getArg(0) is Some(same_arg) else { fail("missing argument") }
      // A mutation through one wrapper must be visible through the other.
      assert_eq(same_arg.getValueName(), Some("input"))
      let caller = mod.addFunction(expected, "call_" + name + "." + suffix)
      let builder = ctx.createBuilder()
      builder.setInsertPoint(caller.addBasicBlock())
      let args : Array[&@IR.Value] = caller.getArgs().map(arg => arg)
      builder.createRet(builder.createCall(intrinsic, args)) |> ignore
    }
  }
  inspect(mod.getFunctions().length(), content="160")
  mod.verify()
}

///|
test "floating intrinsic validation rejects invalid overloads without inserting declarations" {
  let ctx = @IR.Context::new()
  let foreign = @IR.Context::new()
  let mod = ctx.addModule("invalid_floating_intrinsics")
  for (name, _) in floating_intrinsic_cases() {
    for
      types in [
        [],
        [ctx.getDoubleTy() as &@IR.Type, ctx.getDoubleTy()],
        [ctx.getInt32Ty()],
        [ctx.getVoidTy()],
        [ctx.getPtrTy()],
        [foreign.getFloatTy()],
        [foreign.getDoubleTy()],
        [ctx.getFixedVectorType(ctx.getFloatTy(), 4)],
        [ctx.getScalableVectorType(ctx.getDoubleTy(), 2)],
      ] {
      assert_builder_error(() => mod.getIntrinsicDeclaration(name, types), e => {
        e is @IR.InValidTypeError(_)
      })
    }
  }
  inspect(mod.getFunctions().length(), content="0")
  mod.verify()
}

///|
test "floating intrinsic collisions check result parameters varargs globals and definitions" {
  let ctx = @IR.Context::new()
  for (name, arity) in floating_intrinsic_cases() {
    for
      (ty, suffix) in [
        (ctx.getFloatTy() as &@IR.Type, "f32"),
        (ctx.getDoubleTy(), "f64"),
      ] {
      let overload_name = name + "." + suffix
      let args = Array::make(arity, ty)
      for
        wrong_type in [
          ctx.getFunctionType(ctx.getVoidTy(), args),
          ctx.getFunctionType(ty, []),
          ctx.getFunctionType(
            ty,
            Array::make(arity, ctx.getInt32Ty() as &@IR.Type),
          ),
          ctx.getFunctionType(ty, args, isVarArg=true),
        ] {
        let mod = ctx.addModule("conflicting_function")
        mod.addFunction(wrong_type, overload_name) |> ignore
        let before = mod.to_string()
        assert_builder_error(() => mod.getIntrinsicDeclaration(name, [ty]), e => {
          e is @IR.IntrinsicError::ConflictingDeclaration(n) &&
          n == overload_name
        })
        assert_eq(mod.to_string(), before)
      }
      let globals = ctx.addModule("conflicting_global")
      globals.addGlobalVariable(ty, overload_name) |> ignore
      assert_builder_error(() => globals.getIntrinsicDeclaration(name, [ty]), e => {
        e is @IR.IntrinsicError::ConflictingDeclaration(n) && n == overload_name
      })
      let definitions = ctx.addModule("conflicting_definition")
      let definition = definitions.addFunction(
        ctx.getFunctionType(ty, args),
        overload_name,
      )
      definition.addBasicBlock() |> ignore
      assert_builder_error(
        () => definitions.getIntrinsicDeclaration(name, [ty]),
        e => {
          e is @IR.IntrinsicError::ConflictingDeclaration(n) &&
          n == overload_name
        },
      )
      let compatible = ctx.addModule("compatible_declaration")
      let declaration = compatible.addFunction(
        ctx.getFunctionType(ty, args),
        overload_name,
      )
      guard declaration.getArg(0) is Some(arg) else { fail("missing argument") }
      arg.setValueName("existing")
      let intrinsic = compatible.getIntrinsicDeclaration(name, [ty])
      guard intrinsic.getArg(0) is Some(same_arg) else {
        fail("missing argument")
      }
      assert_eq(same_arg.getValueName(), Some("existing"))
      assert_eq(compatible.getFunctions().length(), 1)
      compatible.verify()
    }
  }
}

///|
test "floating sqrt and round execute with float and double overloads" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("execute_floating_intrinsics")
  for name in ["sqrt", "round"] {
    for
      (ty, suffix) in [
        (ctx.getFloatTy() as &@IR.Type, "f32"),
        (ctx.getDoubleTy(), "f64"),
      ] {
      let intrinsic = mod.getIntrinsicDeclaration("llvm." + name, [ty])
      let caller = mod.addFunction(
        ctx.getFunctionType(ty, [ty]),
        name + "_" + suffix,
      )
      guard caller.getArg(0) is Some(arg) else { fail("missing argument") }
      let builder = ctx.createBuilder()
      builder.setInsertPoint(caller.addBasicBlock())
      builder.createRet(builder.createCall(intrinsic, [arg])) |> ignore
    }
  }
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)
  let sqrt64 : FuncRef[(Double) -> Double] = jit
    .lookup("sqrt_f64")
    .unsafeToFuncRef()
  let round64 : FuncRef[(Double) -> Double] = jit
    .lookup("round_f64")
    .unsafeToFuncRef()
  let sqrt32 : FuncRef[(Float) -> Float] = jit
    .lookup("sqrt_f32")
    .unsafeToFuncRef()
  let round32 : FuncRef[(Float) -> Float] = jit
    .lookup("round_f32")
    .unsafeToFuncRef()
  inspect(sqrt64(4.0), content="2")
  inspect(round64(-2.5), content="-3")
  inspect(sqrt32(4.0), content="2")
  inspect(round32(-2.5), content="-3")
  jit.close()
}
