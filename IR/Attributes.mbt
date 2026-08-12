///|
/// Borrowed LLVM attribute handle used internally by the safe wrappers.
type AttributeRef = @unsafe.LLVMAttributeRef

///|
/// Context-owned LLVM attribute value.
///
/// Public APIs normally accept the higher-level `FnAttr`, `ParamAttr`, and
/// `RetAttr` enums and construct this wrapper internally.
pub struct Attribute(AttributeRef)

///|
/// Supported function-level LLVM attributes.
///
/// Attribute validity depends on the complete function signature and intended
/// target ABI; constructors do not validate every LLVM verifier rule.
pub(all) enum FnAttr {
  /// Marks the parameter that specifies an allocator's returned alignment.
  ///
  /// **Notes:** LLVM defines `allocalign` as a parameter attribute. This
  /// function-level exposure mirrors the current implementation and requires
  /// careful verifier review.
  AllocAlign
  /// Marks the pointer parameter manipulated by an allocator operation.
  ///
  /// **Notes:** LLVM defines `allocptr` as a parameter attribute. This
  /// function-level exposure mirrors the current implementation.
  AllocaPtr
  /// Requires the optimizer to inline this function whenever legal.
  AlwaysInline
  /// Treats the function as a recognized builtin despite a surrounding
  /// `nobuiltin` setting.
  Builtin
  /// Marks the function as residing on a cold execution path.
  Cold
  /// Restricts transformations that would break convergent control dependence.
  Convergent
  //CoroDestroyOnlyWhenComplete
  /// Promises that the function does not unwind the stack.
  NoUnwind
  /// Forbids inlining this function.
  NoInline
  //OptimizeNone
  //StackProtect
  //StackProtectReq
  //StackProtectStrong
  //ReturnsTwice
  //ReadNone
  //ReadOnly
  //NoRecurse
  //InaccessibleMemOnly
  //InaccessibleMemOrArgMemOnly
  //ArgMemOnly
  /// Promises that the returned pointer does not alias another accessible
  /// pointer for the relevant LLVM contract.
  NoAlias
  //NoCapture
  //WillReturn
  //NoSync
  /// Identifies the zero-based argument supplying an allocation size.
  ///
  /// **Parameters:** The payload is encoded as LLVM's raw `allocsize` integer
  /// representation. Only the single size-argument form is exposed.
  AllocSize(Int)
  //Dereferenceable(UInt64)
  //DereferenceableOrNull(UInt64)
  //AllocSize(Int)
  //NonLazyBind
  //Naked
  //InlineHint
} derive(Eq)

///|
fn FnAttr::attr_name(self : FnAttr) -> String {
  match self {
    AllocAlign => "allocalign"
    AllocaPtr => "allocaptr"
    AlwaysInline => "alwaysinline"
    Builtin => "builtin"
    Cold => "cold"
    Convergent => "convergent"
    NoInline => "noinline"
    AllocSize(_) => "allocsize"
    NoUnwind => "nounwind"
    NoAlias => "noalias"
  }
}

///|
fn FnAttr::attr_value(self : FnAttr) -> UInt64 {
  match self {
    AllocSize(size) => size.to_uint64()
    _ => 0
  }
}

///|
fn FnAttr::to_llvm_attr(self : FnAttr, ctx : Context) -> Attribute {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(self.attr_name())
  let value = self.attr_value()
  @unsafe.llvm_create_enum_attribute(ctx.get_unsafe_ref(), kind_n, value)
}

///|
/// Supported LLVM parameter attributes.
///
/// The selected attribute must be valid for the parameter's type and the target
/// ABI. The wrapper does not pre-validate every LLVM verifier rule.
pub(all) enum ParamAttr {
  /// Promises the parameter is aligned to the given power-of-two byte boundary.
  Alignment(Int)
  //AllocAlign
  //ByVal(&Type)
  //ByRef(&Type)
  /// Promises the pointer argument does not alias according to LLVM's `noalias`
  /// parameter contract.
  NoAlias
  /// Promises the pointer argument is non-null.
  NonNull
  /// Requests ABI register passing or return where the target supports it.
  InReg
} derive(Eq)

///|
fn ParamAttr::attr_name(self : ParamAttr) -> String {
  match self {
    Alignment(_) => "alignment"
    NoAlias => "noalias"
    NonNull => "nonnull"
    InReg => "inreg"
  }
}

///|
fn ParamAttr::attr_value(self : ParamAttr) -> UInt64 {
  match self {
    Alignment(size) => size.to_uint64()
    _ => 0
  }
}

///|
fn ParamAttr::to_llvm_attr(self : ParamAttr, ctx : Context) -> Attribute {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(self.attr_name())
  let value = self.attr_value()
  @unsafe.llvm_create_enum_attribute(ctx.get_unsafe_ref(), kind_n, value)
}

///|
/// Supported LLVM return-value attributes.
///
/// Applicability depends on the return type and target ABI.
pub(all) enum RetAttr {
  /// Promises the returned pointer does not alias accessible pointer values.
  NoAlias
  /// Promises the returned pointer is non-null.
  NonNull
  /// Requests returning the value in a register where supported by the ABI.
  InReg
} derive(Eq)

///|
fn RetAttr::attr_name(self : RetAttr) -> String {
  match self {
    NoAlias => "noalias"
    NonNull => "nonnull"
    InReg => "inreg"
  }
}

///|
fn RetAttr::attr_value(self : RetAttr) -> UInt64 {
  match self {
    _ => 0
  }
}

///|
fn RetAttr::to_llvm_attr(self : RetAttr, ctx : Context) -> Attribute {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(self.attr_name())
  let value = self.attr_value()
  @unsafe.llvm_create_enum_attribute(ctx.get_unsafe_ref(), kind_n, value)
}
