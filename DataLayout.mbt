
///|
pub type DataLayout @unsafe.LLVMTargetDataRef

///| Get Type Size in Bits.
///
/// ```moonbit
/// let ctx = @llvm.Context::new()
/// let mod = ctx.addModule("demo")
///
/// mod.setDataLayout("e-m:e-i64:64-f80:128-n8:16:32:64-S128")
///
/// let i32_ty = ctx.getInt32Ty()
///
/// let dl = mod.getDataLayout()
/// let i32_ty_size = dl.getTypeSizeInBits(i32_ty)
///
/// assert_eq(i32_ty_size, 32)
/// ```
pub fn DataLayout::getTypeSizeInBits(self: DataLayout, ty: &Type) -> Int {
  let size = @unsafe.llvm_size_of_type_in_bits(self.inner(), ty.getTypeRef())
  size.to_int()
}

///| Get Type Store Size.
///
/// ```moonbit
/// let ctx = @llvm.Context::new()
/// let mod = ctx.addModule("demo")
///
/// mod.setDataLayout("e-m:e-i64:64-f80:128-n8:16:32:64-S128")
///
/// let i32_ty = ctx.getInt32Ty()
/// let f32_ty = ctx.getFloatTy();
///
/// let struct_ty = ctx.getStructType([i32_ty, f32_ty])
///
/// let dl = mod.getDataLayout()
/// let i32_ty_size = dl.getTypeStoreSize(i32_ty)
/// let f32_ty_size = dl.getTypeStoreSize(f32_ty)
/// let struct_ty_size = dl.getTypeStoreSize(struct_ty)
///
/// assert_eq(i32_ty_size, 4)
/// assert_eq(f32_ty_size, 4)
/// assert_eq(struct_ty_size, 8)
/// ```
pub fn DataLayout::getTypeStoreSize(self: DataLayout, ty: &Type) -> Int {
  let size = @unsafe.llvm_store_size_of_type(self.inner(), ty.getTypeRef())
  size.to_int()
}

///|
pub fn DataLayout::getTypeAllocSize(self: DataLayout, ty: &Type) -> Int {
  let size = @unsafe.llvm_abi_size_of_type(self.inner(), ty.getTypeRef())
  size.to_int()
}

///|
pub fn DataLayout::getTypeAlignment(self: DataLayout, ty: &Type) -> Int {
  let align = @unsafe.llvm_abi_alignment_of_type(self.inner(), ty.getTypeRef())
  align.reinterpret_as_int()
}
