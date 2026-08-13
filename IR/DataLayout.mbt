///|
/// Borrowed view of an LLVM module's current target data layout.
///
/// The layout interprets type sizes and alignments according to the module's
/// configured target ABI. It is not an independently owned target-data object.
///
/// **Lifecycle:** This wrapper retains its owning module. Do not dispose the raw
/// target-data reference or assume a view obtained before `Module::setDataLayout`
/// remains a snapshot independent of later module mutation.
pub struct DataLayout {
  priv target_data_ref : @raw.LLVMTargetDataRef
  priv owner_module : Module
}

///|
fn DataLayout::from_raw(
  target_data_ref : @raw.LLVMTargetDataRef,
  owner_module : Module,
) -> DataLayout {
  { target_data_ref, owner_module }
}

///|
fn DataLayout::get_raw_ref(self : DataLayout) -> @raw.LLVMTargetDataRef {
  // Borrowing the raw view must also keep its owning Module alive.
  ignore(self.owner_module)
  self.target_data_ref
}

///|
/// Returns the logical size of `ty` in bits under this target layout.
///
/// This is the bit width of the value representation. It may not be a whole
/// number of bytes and is distinct from store size and allocation size.
///
/// **Preconditions:** `ty` must be sized and belong to a context compatible
/// with the owning module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   mod.setDataLayout("e-m:e-i64:64-f80:128-n8:16:32:64-S128")
///
///   let i32_ty = ctx.getInt32Ty()
///
///   let dl = mod.getDataLayout()
///   let i32_ty_size = dl.getTypeSizeInBits(i32_ty)
///
///   assert_eq(i32_ty_size, 32)
/// }
/// ```
pub fn DataLayout::getTypeSizeInBits(self : DataLayout, ty : &Type) -> Int {
  let size = @raw.llvm_size_of_type_in_bits(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
  )
  size.to_int()
}

///|
/// Returns the minimum number of bytes required to store `ty`.
///
/// Store size rounds the bit size up to whole bytes but excludes trailing ABI
/// padding that may be included in allocation size.
///
/// **Preconditions:** `ty` must be sized and compatible with this layout.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   mod.setDataLayout("e-m:e-i64:64-f80:128-n8:16:32:64-S128")
///
///   let i32_ty = ctx.getInt32Ty()
///   let f32_ty = ctx.getFloatTy()
///
///   let struct_ty = ctx.getStructType([i32_ty, f32_ty])
///
///   let dl = mod.getDataLayout()
///   let i32_ty_size = dl.getTypeStoreSize(i32_ty)
///   let f32_ty_size = dl.getTypeStoreSize(f32_ty)
///   let struct_ty_size = dl.getTypeStoreSize(struct_ty)
///
///   assert_eq(i32_ty_size, 4)
///   assert_eq(f32_ty_size, 4)
///   assert_eq(struct_ty_size, 8)
/// }
/// ```
pub fn DataLayout::getTypeStoreSize(self : DataLayout, ty : &Type) -> Int {
  let size = @raw.llvm_store_size_of_type(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
  )
  size.to_int()
}

///|
/// Returns the ABI allocation size of `ty` in bytes.
///
/// Allocation size includes padding needed so consecutive objects are properly
/// aligned and is therefore greater than or equal to store size.
///
/// **Preconditions:** `ty` must be sized and compatible with this layout.
pub fn DataLayout::getTypeAllocSize(self : DataLayout, ty : &Type) -> Int {
  let size = @raw.llvm_abi_size_of_type(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
  )
  size.to_int()
}

///|
/// Returns the ABI-required alignment of `ty` in bytes.
///
/// **Notes:** This is the target ABI alignment, not a preferred alignment and
/// not the alignment explicitly attached to a particular instruction/global.
///
/// **Preconditions:** `ty` must be sized and compatible with this layout.
pub fn DataLayout::getTypeAlignment(self : DataLayout, ty : &Type) -> Int {
  let align = @raw.llvm_abi_alignment_of_type(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
  )
  align.reinterpret_as_int()
}
