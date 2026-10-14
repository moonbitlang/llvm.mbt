///|
/// Reports an unavailable intrinsic name or a declaration-name collision.
pub suberror IntrinsicError {
  /// LLVM does not recognize this intrinsic base name.
  UnknownName(String)
  /// LLVM recognizes this name, but this wrapper does not yet validate its overloads.
  UnsupportedName(String)
  /// The module already contains an symbol incompatible with an intrinsic declaration at the overload name.
  ConflictingDeclaration(String)
}

///|
priv enum IntrinsicFamily {
  IntegerOverflow
  FloatingPoint(Int)
}

///|
/// Gets or inserts an integer overflow or scalar floating-point intrinsic declaration.
///
/// **Parameters:** `name` must be an unsuffixed base name from these families:
///
/// - `{ T, i1 } (T, T)`: `llvm.sadd.with.overflow`, `llvm.ssub.with.overflow`,
///   `llvm.smul.with.overflow`, `llvm.uadd.with.overflow`,
///   `llvm.usub.with.overflow`, `llvm.umul.with.overflow`.
///   The result contains the wrapped arithmetic result and an overflow flag.
///   The `s` variants check the signed range; the `u` variants check the unsigned
///   range, including underflow for subtraction.
/// - `T (T)`: `llvm.fabs`, `llvm.sqrt`, `llvm.floor`, `llvm.ceil`, `llvm.trunc`,
///   `llvm.round`, `llvm.roundeven`, `llvm.rint`, `llvm.nearbyint`.
/// - `T (T, T)`: `llvm.copysign`, `llvm.minnum`, `llvm.maxnum`, `llvm.minimum`,
///   `llvm.maximum`.
/// - `T (T, T, T)`: `llvm.fma`, `llvm.fmuladd`.
///
/// `overloadTypes` must contain exactly one scalar type from this module's
/// context: an integer for overflow intrinsics, or `half`, `bfloat`, `float`,
/// `double`, or `fp128` for floating-point intrinsics. Vectors are not supported.
/// Floating-point declarations use LLVM overload suffixes such as `f32` and
/// `f64`; target support for executing each floating-point type varies.
///
/// **Errors:** Raises `IntrinsicError::UnknownName` for an unrecognized name,
/// `IntrinsicError::UnsupportedName` for other recognized intrinsics,
/// `InValidTypeError` for an incorrect overload count/type/context, and
/// `IntrinsicError::ConflictingDeclaration` for an incompatible existing symbol or intrinsic definition.
///
/// **Lifecycle:** Returns a module-anchored function. Repeated requests reuse
/// the same declaration. Erasing the function invalidates its aliases.
///
/// **Side effects:** Adds the declaration on its first request.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let mod = ctx.addModule("overflow")
///   let intrinsic = mod.getIntrinsicDeclaration("llvm.sadd.with.overflow", [
///     ctx.getInt32Ty(),
///   ])
///   inspect(
///     intrinsic.getValueName() == Some("llvm.sadd.with.overflow.i32"),
///     content="true",
///   )
///   mod.verify()
/// }
/// ```
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let mod = ctx.addModule("sqrt")
///   let sqrt = mod.getIntrinsicDeclaration("llvm.sqrt", [ctx.getDoubleTy()])
///   inspect(sqrt.getValueName() == Some("llvm.sqrt.f64"), content="true")
///   let caller = mod.addFunction(
///     ctx.getFunctionType(ctx.getDoubleTy(), []),
///     "root",
///   )
///   let builder = ctx.createBuilder()
///   builder.setInsertPoint(caller.addBasicBlock())
///   builder.createRet(builder.createCall(sqrt, [ctx.getConstDouble(4.0)]))
///   |> ignore
///   mod.verify()
/// }
/// ```
pub fn Module::getIntrinsicDeclaration(
  self : Self,
  name : String,
  overloadTypes : Array[&Type],
) -> Function raise {
  let id = @raw.llvm_lookup_intrinsic_id(name)
  guard id != 0 else { raise UnknownName(name) }
  let family = match name {
    "llvm.sadd.with.overflow"
    | "llvm.ssub.with.overflow"
    | "llvm.smul.with.overflow"
    | "llvm.uadd.with.overflow"
    | "llvm.usub.with.overflow"
    | "llvm.umul.with.overflow" => IntegerOverflow
    "llvm.fabs"
    | "llvm.sqrt"
    | "llvm.floor"
    | "llvm.ceil"
    | "llvm.trunc"
    | "llvm.round"
    | "llvm.roundeven"
    | "llvm.rint"
    | "llvm.nearbyint" => FloatingPoint(1)
    "llvm.copysign"
    | "llvm.minnum"
    | "llvm.maxnum"
    | "llvm.minimum"
    | "llvm.maximum" => FloatingPoint(2)
    "llvm.fma" | "llvm.fmuladd" => FloatingPoint(3)
    _ => raise UnsupportedName(name)
  }
  guard overloadTypes is [ty] else {
    raise InValidTypeError(
      match family {
        IntegerOverflow =>
          "Overflow intrinsics require exactly one scalar integer overload type"
        FloatingPoint(_) =>
          "Floating-point intrinsics require exactly one scalar floating-point overload type"
      },
    )
  }
  let ctx = self.getContext()
  let (suffix, expected) = match family {
    IntegerOverflow => {
      guard ty.getContext() == ctx && ty.tryAsIntTypeEnum() is Some(_) else {
        raise InValidTypeError(
          "Overflow intrinsic type must be a scalar integer from the module context",
        )
      }
      (
        ty.to_string(),
        ctx.getFunctionType(ctx.getStructType([ty, ctx.getInt1Ty()]), [ty, ty]),
      )
    }
    FloatingPoint(arity) => {
      guard ty.getContext() == ctx && ty.tryAsFPTypeEnum() is Some(fp) else {
        raise InValidTypeError(
          "Floating-point intrinsic type must be a scalar floating-point type from the module context",
        )
      }
      let suffix = match fp {
        HalfType(_) => "f16"
        BFloatType(_) => "bf16"
        FloatType(_) => "f32"
        DoubleType(_) => "f64"
        FP128Type(_) => "f128"
      }
      (suffix, ctx.getFunctionType(ty, Array::make(arity, ty)))
    }
  }
  let overload_name = name + "." + suffix
  if self.getFunction(overload_name) is Some(existing) {
    guard existing.getType() == expected && existing.getNumBasicBlocks() == 0 else {
      raise ConflictingDeclaration(overload_name)
    }
  }
  guard @raw.llvm_get_named_global(self.get_raw_ref(), overload_name).is_null() &&
    @raw.llvm_get_named_global_alias(self.get_raw_ref(), overload_name).is_null() &&
    @raw.llvm_get_named_global_ifunc(self.get_raw_ref(), overload_name).is_null() else {
    raise ConflictingDeclaration(overload_name)
  }
  Function::from_raw(
    @raw.llvm_get_intrinsic_declaration(self.get_raw_ref(), id, [
      ty.get_raw_type_ref(),
    ]),
    self,
  )
}
