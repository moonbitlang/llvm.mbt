
test "Int Value Test" {
  let context = @llvm.Context::create()

  let i32_ty = context.i32_type()
  let zero = i32_ty.const_int(0)
  let forty_two = i32_ty.const_int(42)
  let thirty_tri = i32_ty.const_int(33)
  let undef = i32_ty.get_undef()
  let poison = i32_ty.get_poison()

  // print
  inspect!(zero, content="i32 0")
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

  context.drop()
}

test "Floating-Point Value Test" {
  let context = @llvm.Context::create()
  let lmodule = context.create_module("demo")

  let f64_ty = context.f64_type()
  let fty = f64_ty.fn_type([f64_ty])
  let fval = lmodule.add_function("foo", fty)
  let entry_bb = context.append_basic_block(fval, "entry")
  let builder = context.create_builder()
  builder.position_at_end(entry_bb)

  let x = fval.get_nth_param(0).unwrap().into_float_value()
  let one = f64_ty.const_float(1.0)
  let xplusone = builder.build_float_add!(x, one, name="xp1")
  let undef = f64_ty.get_undef()

  // print
  inspect!(one, content="double 1.000000e+00")

  inspect!(xplusone.get_name(), content="xp1")
  xplusone.set_name("xplusone")
  inspect!(xplusone.get_name(), content="xplusone")

  // get_type
  inspect!(one.get_type(), content="double")

  // is_null
  assert_false!(one.is_null())

  // is_undef
  assert_false!(one.is_undef())
  assert_true!(undef.is_undef())

  // get_constant
  inspect!(one.get_constant(), content="Some((1, false))")

  lmodule.drop()
  context.drop()
}

test "Function Value Test" {

  let context = @llvm.Context::create()
  let llvm_module = context.create_module("demo")

  let bool_ty = context.bool_type()
  let i32_ty = context.i32_type()
  let f64_ty = context.f64_type()

  let foo_ty = i32_ty.fn_type([f64_ty, bool_ty])
  let foo_val = llvm_module.add_function("foo", foo_ty)

  // get_linkage
  inspect!(foo_val.get_linkage(), content="External")

  // set_linkage
  foo_val.set_linkage(@llvm.Linkage::Internal)
  inspect!(foo_val.get_linkage(), content="Internal")
  foo_val.set_linkage(@llvm.Linkage::External)

  // is_null
  assert_false!(foo_val.is_null())

  // get_first param and get_last_param
  inspect!(foo_val.get_first_param(), content="Some(double %0)")
  inspect!(foo_val.get_last_param(), content="Some(i1 %1)")

  // get_nth_param
  inspect!(foo_val.get_nth_param(0), content="Some(double %0)")
  inspect!(foo_val.get_nth_param(1), content="Some(i1 %1)")
  inspect!(foo_val.get_nth_param(2), content="None")

  // count_params
  assert_eq!(foo_val.count_params(), 2)

  // get_params
  inspect!(foo_val.get_params(), content = "[double %0, i1 %1]")

  // get_name
  inspect!(foo_val.get_name(), content="foo")

  // get_type
  inspect!(foo_val.get_type(), content="ptr")

  // Attributes
  let string_attribute = context.create_string_attribute("my_key", "my_val");
  let enum_attribute = context.create_enum_attribute(1, 1);
  let attr_ret = @llvm.AttributeLoc::Return;
  foo_val.add_attribute(attr_ret, string_attribute);
  foo_val.add_attribute(attr_ret, enum_attribute);

  // count_attributes
  assert_eq!(foo_val.count_attributes(attr_ret), 2)

  // TODO: Test Attributes
  // TODO: Test BasicBlocks

  llvm_module.drop()
  context.drop()
}
