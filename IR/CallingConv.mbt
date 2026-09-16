///|
/// LLVM calling conventions shared by declarations and call instructions.
///
/// These are pure MoonBit values. Numeric conventions are preserved when read;
/// IDs 0, 8, and 9 are canonicalized to `C`, `Fast`, and `Cold`. No convention
/// is guaranteed to be supported on every target or signature.
pub(all) enum CallingConv {
  /// The target's C ABI (LLVM convention 0).
  C
  /// LLVM's fast internal calling convention (8).
  Fast
  /// LLVM's cold internal calling convention (9).
  Cold
  /// An LLVM convention ID without a named wrapper; must be in 0..=1023.
  Other(UInt)
} derive(Eq)

///|
/// Reports a convention ID outside LLVM's representable range.
pub suberror CallingConvError {
  /// Carries the rejected numeric ID, which is greater than 1023.
  InvalidID(UInt)
}

///|
fn CallingConv::from_raw(value : UInt) -> CallingConv {
  match value {
    0 => C
    8 => Fast
    9 => Cold
    _ => Other(value)
  }
}

///|
fn CallingConv::to_raw(self : CallingConv) -> UInt raise CallingConvError {
  match self {
    C => 0
    Fast => 8
    Cold => 9
    Other(value) => {
      guard value <= 1023 else { raise InvalidID(value) }
      value
    }
  }
}

///|
/// Returns this Function's calling convention, preserving unnamed numeric IDs.
pub fn Function::getCallingConv(self : Self) -> CallingConv {
  CallingConv::from_raw(
    @raw.llvm_get_function_call_conv(self.get_raw_value_ref()),
  )
}

///|
/// Sets the calling convention recorded on this Function.
///
/// **Errors:** Raises `CallingConvError::InvalidID` for IDs above 1023.
///
/// **Preconditions:** Use a convention supported by the target and signature.
/// Callee declarations and their call sites must use matching conventions.
///
/// **Side effects:** Updates only this value; does not update its callee or users.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("convention")
///   let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
///   let callee = mod.addFunction(fty, "callee")
///   callee.setCallingConv(Fast)
///   let caller = mod.addFunction(fty, "caller")
///   let builder = ctx.createBuilder()
///   builder.setInsertPoint(caller.addBasicBlock())
///   let call = builder.createCall(callee, [])
///   call.setCallingConv(callee.getCallingConv())
///   builder.createRetVoid() |> ignore
///   inspect(call.getCallingConv() == Fast, content="true")
///   mod.verify()
/// }
/// ```
pub fn Function::setCallingConv(
  self : Self,
  convention : CallingConv,
) -> Unit raise CallingConvError {
  @raw.llvm_set_function_call_conv(
    self.get_raw_value_ref(),
    convention.to_raw(),
  )
}

///|
/// Returns this CallInst's calling convention, preserving unnamed numeric IDs.
pub fn CallInst::getCallingConv(self : Self) -> CallingConv {
  CallingConv::from_raw(
    @raw.llvm_get_instruction_call_conv(self.get_raw_value_ref()),
  )
}

///|
/// Sets the calling convention recorded on this CallInst.
///
/// **Errors:** Raises `CallingConvError::InvalidID` for IDs above 1023.
///
/// **Preconditions:** Use a convention supported by the target and signature.
/// Callee declarations and their call sites must use matching conventions.
///
/// **Side effects:** Updates only this value; does not update its callee or users.
pub fn CallInst::setCallingConv(
  self : Self,
  convention : CallingConv,
) -> Unit raise CallingConvError {
  @raw.llvm_set_instruction_call_conv(
    self.get_raw_value_ref(),
    convention.to_raw(),
  )
}
