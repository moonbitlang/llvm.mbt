///|
/// Reports incompatible provenance when combining LLVM values.
pub suberror ValueOwnerError {
  /// A value or type belongs to a different LLVM context.
  ContextMismatch
  /// Values refer to different modules, or to a module other than the destination.
  ModuleMismatch
}

///|
// Module retention is a dependency of the constant, not ownership of the
// native constant allocation. ModuleOwner already retains its ContextOwner.
priv struct ConstantAnchoredValue {
  value_ref : ValueRef
  context : Context
  owner_module : Module?
}

///|
fn ConstantAnchoredValue::new(
  value_ref : ValueRef,
  context : Context,
  owner_module : Module?,
) -> ConstantAnchoredValue {
  { value_ref, context, owner_module, }
}

///|
fn ConstantAnchoredValue::get_raw_ref(self : ConstantAnchoredValue) -> ValueRef {
  self.value_ref
}

///|
fn ConstantAnchoredValue::get_context(self : ConstantAnchoredValue) -> Context {
  self.context
}

///|
fn value_module(value : &Value) -> Module? {
  match value.asValueEnum() {
    Function(v) => Some(v.get_module())
    GlobalVariable(v) => Some(v.get_module())
    GlobalConstant(v) => Some(v.get_module())
    ConstantArray(v) => v.value.owner_module
    ConstantStruct(v) => v.value.owner_module
    ConstantVector(v) => v.value.owner_module
    ConstantExpr(v) => v.value.owner_module
    ConstantInt(_)
    | ConstantFP(_)
    | ConstantPointerNull(_)
    | UndefValue(_)
    | PoisonValue(_) => None
    Argument(v) => Some(v.get_module())
    BasicBlock(v) => Some(v.get_module())
    AllocaInst(v) => Some(v.get_module())
    LoadInst(v) => Some(v.get_module())
    StoreInst(v) => Some(v.get_module())
    CastInst(v) => Some(v.get_module())
    UnaryInst(v) => Some(v.get_module())
    BinaryInst(v) => Some(v.get_module())
    ICmpInst(v) => Some(v.get_module())
    FCmpInst(v) => Some(v.get_module())
    GetElementPtrInst(v) => Some(v.get_module())
    SelectInst(v) => Some(v.get_module())
    ExtractValueInst(v) => Some(v.get_module())
    InsertValueInst(v) => Some(v.get_module())
    PHINode(v) => Some(v.get_module())
    ReturnInst(v) => Some(v.get_module())
    UnreachableInst(v) => Some(v.get_module())
    BranchInst(v) => Some(v.get_module())
    SwitchInst(v) => Some(v.get_module())
    CallInst(v) => Some(v.get_module())
  }
}

///|
// Reject conflicting dependencies before entering LLVM. Constants without a
// module dependency may be reused across modules of the same context.
fn merge_value_owners(
  context : Context,
  destination : Module?,
  values : Array[&Value],
) -> Module? raise ValueOwnerError {
  if destination is Some(mod) {
    guard mod.getContext() == context else { raise ContextMismatch }
  }
  for index = 0, owner = destination; index < values.length(); {
    let value = values[index]
    guard value.getContext() == context else { raise ContextMismatch }
    match (owner, value_module(value)) {
      (Some(left), Some(right)) => {
        guard physical_equal(left.get_owner(), right.get_owner()) else {
          raise ModuleMismatch
        }
        continue index + 1, owner
      }
      (None, Some(mod)) => continue index + 1, Some(mod)
      (_, None) => continue index + 1, owner
    }
  } nobreak {
    owner
  }
}

///|
fn check_type_context(
  context : Context,
  ty : &Type,
) -> Unit raise ValueOwnerError {
  guard ty.getContext() == context else { raise ContextMismatch }
}

///|
fn check_constant_element_type(ty : &Type) -> Unit raise InValidTypeError {
  guard ty.isSized() && (ty.isSingleValueType() || ty.isAggregateType()) else {
    raise InValidTypeError(
      "Constant aggregate elements must have a sized data type",
    )
  }
}

///|
// Walk only constant operands. Globals are leaves: traversing initializers
// would introduce cycles and confuse an address with the contents of storage.
fn constant_needs_module(value : ValueRef) -> Bool {
  match @raw.llvm_get_value_kind(value) {
    LLVMGlobalVariableValueKind
    | LLVMFunctionValueKind
    | LLVMGlobalAliasValueKind
    | LLVMGlobalIFuncValueKind
    | LLVMBlockAddressValueKind => true
    LLVMConstantExprValueKind
    | LLVMConstantArrayValueKind
    | LLVMConstantStructValueKind
    | LLVMConstantVectorValueKind => {
      let count = @raw.llvm_get_num_operands(value)
      for index in 0..<count {
        if constant_needs_module(
            @raw.llvm_get_operand(value, index.reinterpret_as_uint()),
          ) {
          return true
        }
      }
      false
    }
    _ => false
  }
}

///|
// Classify the actual LLVM value, never just its result type: ptrtoint is an
// integer-typed ConstantExpr, and extractvalue may return a global address.
fn wrap_constant(
  value : ValueRef,
  context : Context,
  source_module : Module?,
) -> &Value raise BuilderError {
  let owner_module = if constant_needs_module(value) {
    guard source_module is Some(_) else {
      raise ValueTypeError("Constant requires a module anchor")
    }
    source_module
  } else {
    None
  }
  match @raw.llvm_get_value_kind(value) {
    LLVMGlobalVariableValueKind => {
      guard owner_module is Some(mod) else {
        raise ValueTypeError("Global requires a module anchor")
      }
      if @raw.llvm_is_global_constant(value) {
        GlobalConstant::from_raw(value, mod) as &Value
      } else {
        GlobalVariable::from_raw(value, mod)
      }
    }
    LLVMFunctionValueKind => {
      guard owner_module is Some(mod) else {
        raise ValueTypeError("Function requires a module anchor")
      }
      Function::from_raw(value, mod)
    }
    LLVMConstantIntValueKind => ConstantInt::from_raw(value, context)
    LLVMConstantFPValueKind => ConstantFP::from_raw(value, context)
    LLVMConstantPointerNullValueKind =>
      ConstantPointerNull::from_raw(value, context)
    LLVMUndefValueValueKind => UndefValue::from_raw(value, context)
    LLVMPoisonValueValueKind => PoisonValue::from_raw(value, context)
    LLVMConstantExprValueKind =>
      ConstantExpr::from_raw(value, context, owner_module~)
    LLVMConstantArrayValueKind | LLVMConstantDataArrayValueKind =>
      ConstantArray::from_raw(value, context, owner_module~)
    LLVMConstantStructValueKind =>
      ConstantStruct::from_raw(value, context, owner_module~)
    LLVMConstantVectorValueKind | LLVMConstantDataVectorValueKind =>
      ConstantVector::from_raw(value, context, owner_module~)
    LLVMConstantAggregateZeroValueKind =>
      match @raw.llvm_get_type_kind(@raw.llvm_type_of(value)) {
        LLVMArrayTypeKind => ConstantArray::from_raw(value, context) as &Value
        LLVMStructTypeKind => ConstantStruct::from_raw(value, context)
        LLVMVectorTypeKind | LLVMScalableVectorTypeKind =>
          ConstantVector::from_raw(value, context)
        _ => raise ValueTypeError("Unsupported zero aggregate constant")
      }
    _ => raise ValueTypeError("Unsupported folded LLVM constant")
  }
}

///|
fn IRBuilder::check_value_owners(
  self : IRBuilder,
  values : Array[&Value],
) -> Unit raise {
  merge_value_owners(self.get_context(), Some(self.get_insert_module()), values)
  |> ignore
}

///|
fn IRBuilder::wrap_constant(
  self : IRBuilder,
  value : ValueRef,
) -> &Value raise BuilderError {
  wrap_constant(value, self.get_context(), Some(self.get_insert_module()))
}
