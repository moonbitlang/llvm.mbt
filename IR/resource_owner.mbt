///|
/// A MoonBit-managed owner for an LLVM context.
///
/// Its finalizer releases the native LLVM context.
priv type ContextOwner

///|
/// A MoonBit-managed owner for an LLVM module.
///
/// The C payload retains the module's ContextOwner and releases the native LLVM
/// module before dropping that parent reference.
priv type ModuleOwner

///|
/// A MoonBit-managed owner for an LLVM builder.
///
/// The C payload retains the builder's ContextOwner and, while positioned, the
/// ModuleOwner containing its insertion point. Its finalizer releases the
/// native LLVM builder before dropping those parent references.
priv type BuilderOwner

///|
/// A MoonBit-managed owner for an LLVM target machine.
///
/// Its payload owns exactly one target machine and has no parent resource.
priv type TargetMachineOwner

///|
extern "C" fn ContextOwner::new(raw : @unsafe.LLVMContextRef) -> ContextOwner = "llvm_mbt_ir_context_owner_new"

///|
#borrow(self)
extern "C" fn ContextOwner::raw(self : ContextOwner) -> @unsafe.LLVMContextRef = "llvm_mbt_ir_context_owner_raw"

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
extern "C" fn BuilderOwner::new(
  raw : @unsafe.LLVMBuilderRef,
  context : ContextOwner,
) -> BuilderOwner = "llvm_mbt_ir_builder_owner_new"

///|
#borrow(self)
extern "C" fn BuilderOwner::raw(self : BuilderOwner) -> @unsafe.LLVMBuilderRef = "llvm_mbt_ir_builder_owner_raw"

///|
#borrow(self, owner_module)
extern "C" fn BuilderOwner::set_module(
  self : BuilderOwner,
  owner_module : ModuleOwner,
) = "llvm_mbt_ir_builder_owner_set_module"

///|
#borrow(self)
extern "C" fn BuilderOwner::context(self : BuilderOwner) -> ContextOwner = "llvm_mbt_ir_builder_owner_context"

///|
extern "C" fn TargetMachineOwner::new(
  raw : @unsafe.LLVMTargetMachineRef,
) -> TargetMachineOwner = "llvm_mbt_ir_target_machine_owner_new"
