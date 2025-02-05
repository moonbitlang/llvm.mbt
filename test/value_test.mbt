
test "Int Value Test" {
  let context = @llvm.Context::create()

  let i32_ty = context.i32_type()
  let forty_two = i32_ty.const_int(42)
  let thirty_tri = i32_ty.const_int(33)
  let undef = i32_ty.get_undef()
  let poison = i32_ty.get_poison()

  // print
  inspect!(forty_two, content="i32 42")
  inspect!(thirty_tri, content="i32 33")
  inspect!(undef, content="i32 undef")
  inspect!(poison, content="i32 poison")

  // get_type
  inspect!(forty_two.get_type(), content="i32")

  // is_null
  assert_false!(forty_two.is_null())

  // is_undef
  assert_false!(forty_two.is_undef())
  assert_true!(undef.is_undef())
  assert_true!(poison.is_undef())

  // const_<op>
  inspect!(forty_two.const_not(), content="i32 -43")
  inspect!(forty_two.const_neg(), content="i32 -42")
  inspect!(forty_two.const_nsw_neg(), content="i32 -42")
  inspect!(forty_two.const_add(thirty_tri), content="i32 75")
  inspect!(forty_two.const_nsw_add(thirty_tri), content="i32 75")
  inspect!(forty_two.const_nuw_add(thirty_tri), content="i32 75")
  inspect!(forty_two.const_sub(thirty_tri), content="i32 9")
  inspect!(forty_two.const_nsw_sub(thirty_tri), content="i32 9")
  inspect!(forty_two.const_nuw_sub(thirty_tri), content="i32 9")
  inspect!(forty_two.const_mul(thirty_tri), content="i32 1386")
  inspect!(forty_two.const_nsw_mul(thirty_tri), content="i32 1386")
  inspect!(forty_two.const_nuw_mul(thirty_tri), content="i32 1386")
  inspect!(forty_two.const_xor(thirty_tri), content="i32 11")

  // is_const
  assert_true!(forty_two.is_const())

  // is_constant_int
  assert_true!(forty_two.is_constant_int())

  // const_truncate
  let max_u16p2 = i32_ty.const_int(65537) // 0x10001
  let u16_ty = context.i16_type()
  inspect!(
    max_u16p2.const_truncate(u16_ty),
    content="i16 1"
  )

  // get_zero_extended_constant
  let i8_ty = context.i8_type()
  let i8_all_one = i8_ty.const_all_ones()
  inspect!(
    i8_all_one.get_zero_extended_constant(),
    content="Some(255)"
  )

  // get_sign_extended_constant
  inspect!(
    i8_all_one.get_sign_extended_constant(),
    content="Some(-1)"
  )

  // TODO: add get_name, set_name test

  context.drop()
}

test "Floating-Point Value Test" {
  let context = @llvm.Context::create()
  let f64_ty = context.f64_type()
  let one = f64_ty.const_float(1.0)
  // let undef = f64_ty.get_undef()
  // let poison = f64_ty.get_poison()

  // print
  inspect!(one, content="double 1.000000e+00")

  // TODO:set_name and get_name

  // get_type
  inspect!(one.get_type(), content="double")
}
