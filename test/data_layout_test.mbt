///|
using @IR {type DataLayout}

///|
fn assert_layout_metrics(
  layout : DataLayout,
  ty : &Type,
  bits : Int,
  store_size : Int,
  alloc_size : Int,
  alignment : Int,
) -> Unit raise {
  assert_eq(layout.getTypeSizeInBits(ty), bits)
  assert_eq(layout.getTypeStoreSize(ty), store_size)
  assert_eq(layout.getTypeAllocSize(ty), alloc_size)
  assert_eq(layout.getTypeAlignment(ty), alignment)
}

///|
test "new Module leaves target unspecified" {
  let context = Context::new()
  let mod = context.addModule("target_unspecified")
  inspect(mod.getTargetTriple(), content="")
  inspect(mod.getDataLayoutStr(), content="")
  mod.setDataLayout("e-p:64:64-i64:64-n8:16:32:64")
  inspect(mod.getDataLayoutStr(), content="e-p:64:64-i64:64-n8:16:32:64")
}

///|
test "DataLayout reports integer and array metrics" {
  let context = Context::new()
  let mod = context.addModule("data_layout_scalars")
  mod.setDataLayout(
    "e-p:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-v48:64:64-n8:16:32:64-S128",
  )
  let layout = mod.getDataLayout()
  assert_layout_metrics(layout, context.getInt1Ty(), 1, 1, 1, 1)
  assert_layout_metrics(layout, context.getInt32Ty(), 32, 4, 4, 4)
  assert_layout_metrics(layout, context.getInt64Ty(), 64, 8, 8, 8)
  assert_layout_metrics(
    layout,
    context.getArrayType(context.getInt16Ty(), 3),
    48,
    6,
    6,
    2,
  )
}

///|
test "DataLayout distinguishes packed padding and vector allocation" {
  let context = Context::new()
  let mod = context.addModule("data_layout_composites")
  mod.setDataLayout(
    "e-p:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-v48:64:64-n8:16:32:64-S128",
  )
  let layout = mod.getDataLayout()
  let i8_type = context.getInt8Ty()
  let i16_type = context.getInt16Ty()
  let i32_type = context.getInt32Ty()
  let unpacked = context.getStructType([i8_type, i32_type])
  let packed = context.getStructType([i8_type, i32_type], isPacked=true)
  let vector = context.getFixedVectorType(i16_type, 3)
  assert_layout_metrics(layout, unpacked, 64, 8, 8, 4)
  assert_layout_metrics(layout, packed, 40, 5, 5, 1)
  assert_layout_metrics(layout, vector, 48, 6, 8, 8)
}
