///|
fn CallInst::attribute_index(
  self : CallInst,
  index : Int,
) -> UInt raise IndexOutOfBounds {
  guard index >= 0 &&
    index.reinterpret_as_uint() <
    @raw.llvm_get_num_arg_operands(self.get_raw_value_ref()) else {
    raise IndexOutOfBounds("Call argument index out of bounds: \{index}")
  }
  index.reinterpret_as_uint() + 1
}

///|
/// Adds a function-level attribute to this call instruction.
///
/// **Preconditions:** The attribute must be valid at a call site for this
/// signature and target ABI. In particular, function-definition-only `FnAttr`
/// values are not legal here. `NoReturn` does not insert `unreachable` or
/// change control flow.
///
/// **Side effects:** Modifies this call's attributes, leaving the callee unchanged.
///
/// **See also:** `CallInst::addRetAttr` for an ABI attribute example.
pub fn CallInst::addFnAttr(self : Self, attr : FnAttr) -> Unit {
  let idx = @uint.MAX_VALUE
  @raw.llvm_add_call_site_attribute(
    self.get_raw_value_ref(),
    idx,
    attr.to_llvm_attr(self.getContext()).0,
  )
}

///|
/// Removes the selected function-level attribute kind from this call if present.
///
/// **Side effects:** Modifies only this call's attributes; removal uses the
/// attribute kind, ignoring any value payload.
pub fn CallInst::removeFnAttr(self : Self, attr : FnAttr) -> Unit {
  let idx = @uint.MAX_VALUE
  @raw.llvm_remove_call_site_enum_attribute(
    self.get_raw_value_ref(),
    idx,
    @raw.llvm_get_enum_attribute_kind_for_name(attr.attr_name()),
  )
}

///|
/// Adds a return-value attribute to this call instruction.
///
/// **Preconditions:** The attribute must be valid for the return type and
/// target ABI. `SExt` and `ZExt` require an integer return, must not be combined,
/// and must agree with the callee's ABI attributes.
///
/// **Side effects:** Modifies this call's attributes, leaving the callee unchanged.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("abi")
///   let fty = ctx.getFunctionType(ctx.getInt1Ty(), [ctx.getInt1Ty()])
///   let callee = mod.addFunction(fty, "boolean")
///   callee.addRetAttr(ZExt)
///   guard callee.getArg(0) is Some(arg) else { fail("missing argument") }
///   arg.addAttr(ZExt)
///   let caller = mod.addFunction(
///     ctx.getFunctionType(ctx.getVoidTy(), []),
///     "caller",
///   )
///   let builder = ctx.createBuilder()
///   builder.setInsertPoint(caller.addBasicBlock())
///   let call = builder.createCall(callee, [ctx.getConstTrue()])
///   call.addRetAttr(ZExt)
///   call.addParamAttr(0, ZExt)
///   builder.createRetVoid() |> ignore
///   mod.verify()
/// }
/// ```
pub fn CallInst::addRetAttr(self : Self, attr : RetAttr) -> Unit {
  let idx = 0U
  @raw.llvm_add_call_site_attribute(
    self.get_raw_value_ref(),
    idx,
    attr.to_llvm_attr(self.getContext()).0,
  )
}

///|
/// Removes the selected return-value attribute kind from this call if present.
///
/// **Side effects:** Modifies only this call's attributes; removal uses the
/// attribute kind, ignoring any value payload.
pub fn CallInst::removeRetAttr(self : Self, attr : RetAttr) -> Unit {
  let idx = 0U
  @raw.llvm_remove_call_site_enum_attribute(
    self.get_raw_value_ref(),
    idx,
    @raw.llvm_get_enum_attribute_kind_for_name(attr.attr_name()),
  )
}

///|
/// Adds an argument attribute to this call instruction.
///
/// **Parameters:** `index` is the zero-based call argument index, including
/// variadic arguments; LLVM's special attribute indices are handled internally.
///
/// **Errors:** Raises `IndexOutOfBounds` for negative or out-of-range indices.
///
/// **Preconditions:** The attribute must be valid for the argument type and
/// target ABI. `SExt` and `ZExt` require integer arguments, must not be combined,
/// and must agree with the callee's ABI attributes.
///
/// **Side effects:** Modifies this call's attributes, leaving the callee unchanged.
///
/// **See also:** `CallInst::addRetAttr` for an ABI attribute example.
pub fn CallInst::addParamAttr(
  self : Self,
  index : Int,
  attr : ParamAttr,
) -> Unit raise IndexOutOfBounds {
  let idx = self.attribute_index(index)
  @raw.llvm_add_call_site_attribute(
    self.get_raw_value_ref(),
    idx,
    attr.to_llvm_attr(self.getContext()).0,
  )
}

///|
/// Removes the selected argument attribute kind from this call if present.
///
/// **Parameters:** `index` is the zero-based call argument index.
///
/// **Errors:** Raises `IndexOutOfBounds` for negative or out-of-range indices.
///
/// **Side effects:** Modifies only this call's attributes; removal uses the
/// attribute kind, ignoring any value payload.
pub fn CallInst::removeParamAttr(
  self : Self,
  index : Int,
  attr : ParamAttr,
) -> Unit raise IndexOutOfBounds {
  let idx = self.attribute_index(index)
  @raw.llvm_remove_call_site_enum_attribute(
    self.get_raw_value_ref(),
    idx,
    @raw.llvm_get_enum_attribute_kind_for_name(attr.attr_name()),
  )
}
