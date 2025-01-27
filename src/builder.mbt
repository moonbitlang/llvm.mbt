
enum PositionState {
    NotSet
    Set
} derive(Eq)

// pub enum BuilderError {
//     #[error("Builder position is not set")]
//     UnsetPosition
//     #[error("Alignment error")]
//     AlignmentError(&'static str)
//     #[error("Aggregate extract index out of range")]
//     ExtractOutOfRange
//     #[error("Bitwidth of a value is incorrect")]
//     BitwidthError(&'static str)
//     #[error("Pointee type does not match the value's type")]
//     PointeeTypeMismatch(&'static str)
//     #[error("Values do not have the same type")]
//     ValueTypeMismatch(&'static str)
//     #[error("Ordering error or mismatch")]
//     OrderingError(&'static str)
//     #[error("GEP pointee is not a struct")]
//     GEPPointee
//     #[error("GEP index out of range")]
//     GEPIndex
// }

pub type! BuilderError {
  // Builder position is not set
  UnsetPosition
  // Alignment error
  AlignmentError(String)
  // Aggregate extract index out of range
  ExtractOutOfRange
  // Bitwidth of a value is incorrect
  BitwidthError(String)
  // Pointee type does not match the value's type
  PointeeTypeMismatch(String)
  // Values do not have the same type
  ValueTypeMismatch(String)
  // Ordering error or mismatch
  OrderingError(String)
  // GEP pointee is not a struct
  GEPPointee
  // GEP index out of range
  GEPIndex
}


pub struct Builder {
  builder_ref: LLVMBuilderRef
  positioned: PositionState
}

pub fn Builder::new(builder_ref: LLVMBuilderRef) -> Builder {
  Builder::{
    builder_ref: builder_ref,
    positioned: NotSet
  }
}

fn Builder::as_builder_ref(self: Builder) -> LLVMBuilderRef {
  self.builder_ref
}

fn Builder::get_positioned(self: Builder) -> PositionState {
  self.positioned
}

pub fn Builder::build_return(
  self: Builder, val~:&BasicValue? = None
) -> InstructionValue!BuilderError {
  if self.get_positioned() == PositionState::NotSet {
    raise UnsetPosition
  }

  let builder_ref = self.as_builder_ref()
  let inst = match val {
    Some(val) => {
      let val_ref = val.as_value_ref()
      llvm_build_ret(builder_ref, val_ref)
    }
    None => {
      llvm_build_ret_void(builder_ref)
    }
  }
  InstructionValue::new(inst)
}

pub fn Builder::build_aggregate_return(
  self: Builder, values: Array[BasicValueEnum]
) -> InstructionValue!BuilderError {
  if self.get_positioned() == PositionState::NotSet {
    raise UnsetPosition
  }

  let builder_ref = self.as_builder_ref()
  let args = values.map(fn (v) {v.as_value_ref()})
  let ret_v = llvm_build_aggregate_ret(builder_ref, args)

  InstructionValue::new(ret_v)
}

// pub fn Builder::build_call(
//   self: Builder, 
//   func: FunctionValue, 
//   args: Array[BasicMetadataValueEnum],
//   name: String
// ) -> CallSiteValue!BuilderError {
//   if self.get_positioned() != PositionState::Set {
//     raise UnsetPosition
//   }
//
//   self.build_direct_call(func, args, name)
// }

// pub fn Builder::build_direct_call(
//   self: Builder, 
//   func: FunctionValue, 
//   args: Array[BasicValueEnum],
//   name: String
// ) -> CallSiteValue!BuilderError {
//   if self.get_positioned() != PositionState::Set {
//     raise UnsetPosition
//   }
//
//   self.build_call_help(func, args, name)
// }

// pub fn Builder::build_call_help(func: FunctionValue, args: Array[BasicValueEnum], name: String) -> Ca

pub fn position_at_end(self: Builder, bb: BasicBlock) -> Unit {
  let builder_ref = self.builder_ref
  let bb_ref = bb.bb_ref
  llvm_position_builder_at_end(builder_ref, bb_ref)
}

