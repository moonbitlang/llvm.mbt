///|
/// A MoonBit-managed owner for an LLVM context.
///
/// Its finalizer is intentionally inactive until all borrowed IR wrappers
/// retain their native owner.
priv type ContextOwner

///|
/// A MoonBit-managed owner for an LLVM module.
///
/// The C payload retains the module's ContextOwner.
priv type ModuleOwner

///|
/// A MoonBit-managed owner for an LLVM builder.
///
/// The C payload retains the builder's ContextOwner.
priv type BuilderOwner

///|
extern "C" fn ContextOwner::new(raw : @unsafe.LLVMContextRef) -> ContextOwner = "llvm_mbt_ir_context_owner_new"

///|
#borrow(self)
extern "C" fn ContextOwner::raw(self : ContextOwner) -> @unsafe.LLVMContextRef = "llvm_mbt_ir_context_owner_raw"

///|
#borrow(self, other)
#warnings("-unused_value")
extern "C" fn ContextOwner::same(
  self : ContextOwner,
  other : ContextOwner,
) -> Bool = "llvm_mbt_ir_context_owner_same"

///|
#borrow(context)
extern "C" fn ModuleOwner::new(
  raw : @unsafe.LLVMModuleRef,
  context : ContextOwner,
) -> ModuleOwner = "llvm_mbt_ir_module_owner_new"

///|
#borrow(self)
extern "C" fn ModuleOwner::raw(self : ModuleOwner) -> @unsafe.LLVMModuleRef = "llvm_mbt_ir_module_owner_raw"

///|
#borrow(self)
extern "C" fn ModuleOwner::context(self : ModuleOwner) -> ContextOwner = "llvm_mbt_ir_module_owner_context"

///|
#borrow(context)
#warnings("-unused_value")
extern "C" fn BuilderOwner::new(
  raw : @unsafe.LLVMBuilderRef,
  context : ContextOwner,
) -> BuilderOwner = "llvm_mbt_ir_builder_owner_new"

///|
#borrow(self)
#warnings("-unused_value")
extern "C" fn BuilderOwner::raw(self : BuilderOwner) -> @unsafe.LLVMBuilderRef = "llvm_mbt_ir_builder_owner_raw"

///|
#borrow(self)
#warnings("-unused_value")
extern "C" fn BuilderOwner::context(self : BuilderOwner) -> ContextOwner = "llvm_mbt_ir_builder_owner_context"
