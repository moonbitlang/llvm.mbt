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
/// Gets or inserts a signed integer overflow intrinsic declaration in this module.
///
/// **Parameters:** `name` must be the unsuffixed base name
/// `llvm.sadd.with.overflow`, `llvm.ssub.with.overflow`, or
/// `llvm.smul.with.overflow`. `overloadTypes` must contain exactly one scalar
/// integer type from this module's context. The result has signature
/// `{ T, i1 } (T, T)`, returning the arithmetic result and an overflow flag.
/// Vectors and other intrinsic families are not currently exposed.
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
///   let ctx = Context::new()
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
pub fn Module::getIntrinsicDeclaration(
  self : Self,
  name : String,
  overloadTypes : Array[&Type],
) -> Function raise {
  let id = @raw.llvm_lookup_intrinsic_id(name)
  guard id != 0 else { raise UnknownName(name) }
  guard name == "llvm.sadd.with.overflow" ||
    name == "llvm.ssub.with.overflow" ||
    name == "llvm.smul.with.overflow" else {
    raise UnsupportedName(name)
  }
  guard overloadTypes is [ty] else {
    raise InValidTypeError(
      "Overflow intrinsics require exactly one scalar integer overload type",
    )
  }
  guard ty.getContext() == self.getContext() && ty.tryAsIntTypeEnum() is Some(_) else {
    raise InValidTypeError(
      "Overflow intrinsic type must be a scalar integer from the module context",
    )
  }
  let overload_name = name + "." + ty.to_string()
  let expected = self
    .getContext()
    .getFunctionType(
      self.getContext().getStructType([ty, self.getContext().getInt1Ty()]),
      [ty, ty],
    )
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
