
typealias @unsafe.LLVMAttributeRef as AttributeRef 

pub type Attribute AttributeRef

pub(all) enum FnAttr {
  AllocAlign
  AllocaPtr
  AlwaysInline
  Builtin
  Cold
  Convergent
  //CoroDestroyOnlyWhenComplete
  NoUnwind
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
  NoAlias
  //NoCapture
  //WillReturn
  //NoSync
  AllocSize(Int)
  //Dereferenceable(UInt64)
  //DereferenceableOrNull(UInt64)
  //AllocSize(Int)
  //NonLazyBind
  //Naked
  //InlineHint
} derive(Eq)

fn FnAttr::attr_name(self: FnAttr) -> String {
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

fn FnAttr::attr_value(self: FnAttr) -> UInt64 {
  match self {
    AllocSize(size) => size.to_uint64()
    _ => 0
  }
}

fn FnAttr::to_llvm_attr(self: FnAttr, ctx: Context) -> Attribute {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(self.attr_name())
  let value = self.attr_value()
  @unsafe.llvm_create_enum_attribute(ctx.inner(), kind_n, value)
}

pub(all) enum ParamAttr {
  Alignment(Int)
  //AllocAlign
  //ByVal(&Type)
  //ByRef(&Type)
  NoAlias
  NonNull
  InReg
} derive(Eq)

fn ParamAttr::attr_name(self: ParamAttr) -> String {
  match self {
    Alignment(_) => "alignment"
    NoAlias => "noalias"
    NonNull => "nonnull"
    InReg => "inreg"
  }
}

fn ParamAttr::attr_value(self: ParamAttr) -> UInt64 {
  match self {
    Alignment(size) => size.to_uint64()
    _ => 0
  }
}

fn ParamAttr::to_llvm_attr(self: ParamAttr, ctx: Context) -> Attribute {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(self.attr_name())
  let value = self.attr_value()
  @unsafe.llvm_create_enum_attribute(ctx.inner(), kind_n, value)
}

pub(all) enum RetAttr {
  NoAlias
  NonNull
  InReg
} derive(Eq)

fn RetAttr::attr_name(self: RetAttr) -> String {
  match self {
    NoAlias => "noalias"
    NonNull => "nonnull"
    InReg => "inreg"
  }
}

fn RetAttr::attr_value(self: RetAttr) -> UInt64 {
  match self {
    _ => 0
  }
}

fn RetAttr::to_llvm_attr(self: RetAttr, ctx: Context) -> Attribute {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(self.attr_name())
  let value = self.attr_value()
  @unsafe.llvm_create_enum_attribute(ctx.inner(), kind_n, value)
}
