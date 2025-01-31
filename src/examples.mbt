// TODO: enable it when finish all
// fn simple_ret_42() -> String {
//   let context = @llvm.Context::create()
//   let llvm_module = context.create_module("demo")
//   let builder = context.create_builder()
//   let i32_ty = context.i32_type()
//   let fn_ty = i32_ty.fn_type([], false)
//   let func = llvm_module.add_function("main", fn_ty)
//   let bb = context.append_basic_block(func, "entry")
//   builder.position_at_end(bb)
//   let ret_val = i32_ty.const_int(42, false)
//   builder.build_return(val=Some(ret_val))
//   llvm_module.to_string()
// }

test "Basic type and Basic value" {
  let context = Context::create()

  // Basic Type
  let bool_ty = context.bool_type()
  inspect!(bool_ty, content="i1")

  let i8_ty = context.i8_type()
  inspect!(i8_ty, content="i8")

  let i16_ty = context.i16_type()
  inspect!(i16_ty, content="i16")

  let i32_ty = context.i32_type()
  inspect!(i32_ty, content="i32")

  let i64_ty = context.i64_type()
  inspect!(i64_ty, content="i64")

  let i128_ty = context.i128_type()
  inspect!(i128_ty, content="i128")

  let void_ty = context.void_type()
  inspect!(void_ty, content="void")

  let f16_ty = context.f16_type()
  inspect!(f16_ty, content="half")

  let f32_ty = context.f32_type()
  inspect!(f32_ty, content="float")

  let f64_ty = context.f64_type()
  inspect!(f64_ty, content="double")

  // Basic Value
  let true_val = bool_ty.const_int(1, false)
  inspect!(true_val, content="i1 true")

  // FIXME: The following code cause test failed
  // let false_val = bool_ty.const_int(0, false)
  // inspect!(false_val.to_string(), content="i1 false")

  let one = i8_ty.const_int(1, false)
  inspect!(one, content="i8 1")

  let thirty_three = i16_ty.const_int(33, false)
  inspect!(thirty_three, content="i16 33")

  let forty_two = i32_ty.const_int(42, false)
  inspect!(forty_two, content="i32 42")

  let tri_six = i64_ty.const_int(666, true)
  inspect!(tri_six, content="i64 666")

  let pi = f64_ty.const_float(3.1415926)
  inspect!(pi, content="double 0x400921FB4D12D84A")

  let e = f32_ty.const_float(2.7182818)
  inspect!(e, content="float 0x4005BF0A80000000")

  // size of and align of
  let i16_sz = i16_ty.size_of().to_string()
  let expect = "i64 ptrtoint (ptr getelementptr (i16, ptr null, i32 1) to i64)"
  inspect!(i16_sz, content=expect)

  let i16_align = i16_ty.get_alignment().to_string()
  let expect = "i64 ptrtoint (ptr getelementptr ({ i1, i16 }, ptr null, i64 0, i32 1) to i64)"
  inspect!(i16_align, content=expect)

  let i32_sz = i32_ty.size_of().to_string()
  let expect = "i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)"
  inspect!(i32_sz, content=expect)

  let i32_align = i32_ty.get_alignment().to_string()
  let expect = "i64 ptrtoint (ptr getelementptr ({ i1, i32 }, ptr null, i64 0, i32 1) to i64)"
  inspect!(i32_align, content=expect)


  // TODO: For following func type test, eliminate `as_type_ref` after compiler bug fixed.
  // (Int, Int) -> Int
  let fty1 = i32_ty.fn_type([i32_ty.as_type_ref(), i32_ty.as_type_ref()], false)
  inspect!(fty1, content="i32 (i32, i32)")

  // (Double, Int) -> Double
  let fty2 = f64_ty.fn_type([i32_ty.as_type_ref(), f64_ty.as_type_ref()], false)
  inspect!(fty2, content="double (i32, double)")

  // () -> Int
  let fty3 = i32_ty.fn_type([], false)
  inspect!(fty3, content="i32 ()")

  context.drop()
}
