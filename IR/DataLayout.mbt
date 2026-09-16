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
  { target_data_ref, owner_module, }
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

///|
/// Reports a target layout result that does not fit MoonBit's signed `Int`.
pub suberror DataLayoutError {
  /// Carries the exact byte offset exceeding 2147483647.
  OffsetOutOfRange(UInt64)
}

///|
fn contains_scalable_type(ty : @raw.LLVMTypeRef) -> Bool {
  // Inspect raw field types so an otherwise valid layout query also handles
  // integer widths and other fields absent from the public TypeEnum.
  match @raw.llvm_get_type_kind(ty) {
    LLVMScalableVectorTypeKind => true
    LLVMArrayTypeKind => contains_scalable_type(@raw.llvm_get_element_type(ty))
    LLVMStructTypeKind => {
      let count = @raw.llvm_count_struct_element_types(ty).reinterpret_as_int()
      for index in 0..<count {
        if contains_scalable_type(
            @raw.llvm_struct_get_type_at_index(ty, index.reinterpret_as_uint()),
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
/// Returns a physical struct field's byte offset under the module's current layout.
///
/// **Parameters:** `index` is the zero-based physical LLVM field index, not a
/// source-language field number. Padding and nested aggregates follow LLVM's
/// target layout. The returned `Int` is in 0..=2147483647.
///
/// **Errors:** Raises `IndexOutOfBounds` for negative or out-of-range indices;
/// `InValidTypeError` for a different context, opaque/unsized struct, or scalable
/// fields; `DataLayoutError::OffsetOutOfRange` if the byte offset does not fit.
///
/// **Lifecycle:** Uses this module-owned view at query time; changing the
/// module's layout affects subsequent queries. Does not create a snapshot.
///
/// **LLVM API:** `LLVMOffsetOfElement`, with checked conversion from UInt64.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("layout")
///   mod.setDataLayout("e-p:64:64-i32:32")
///   let ty = ctx.getStructType([ctx.getInt8Ty(), ctx.getInt32Ty()])
///   inspect(mod.getDataLayout().getElementOffset(ty, 1), content="4")
/// }
/// ```
pub fn DataLayout::getElementOffset(
  self : Self,
  ty : StructType,
  index : Int,
) -> Int raise {
  guard ty.getContext() == self.owner_module.getContext() else {
    raise InValidTypeError(
      "Struct and data layout must belong to the same context",
    )
  }
  guard !ty.isOpaque() && ty.isSized() else {
    raise InValidTypeError("Field offsets require a sized struct with a body")
  }
  guard index >= 0 && index < ty.numOfElements() else {
    raise IndexOutOfBounds("Struct field index out of bounds: \{index}")
  }
  guard !contains_scalable_type((ty : &Type).get_raw_type_ref()) else {
    raise InValidTypeError("Field offsets require fixed-size fields")
  }
  let offset = @raw.llvm_offset_of_element(
    self.get_raw_ref(),
    (ty : &Type).get_raw_type_ref(),
    index.reinterpret_as_uint(),
  )
  guard offset <= 2147483647UL else { raise OffsetOutOfRange(offset) }
  offset.to_int()
}
