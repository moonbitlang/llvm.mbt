test "Builder Test" {
  let context = @llvm.Context::create();
  let lmodule = context.create_module("demo");
  let i32_ty = context.i32_type();
  let void_ty = context.void_type();

  // let fty = void_ty.fn_type([i32_ty, f32_ty, f64_ty, bool_ty]);
  let fty = void_ty.fn_type_unsafe([
    i32_ty.as_type_ref(),
    i32_ty.as_type_ref(),
  ]);

  let fval = lmodule.add_function("foo", fty);
  let bb = context.append_basic_block(fval, "entry");

  let builder = context.create_builder();
  builder.position_at_end(bb);

  let arg0 = fval.get_nth_param(0).unwrap();
  let arg1 = fval.get_nth_param(1).unwrap();

  let iarg0 = arg0.into_int_value();
  let iarg1 = arg1.into_int_value();

  let add = builder.build_int_add!(iarg0, iarg1);
  inspect!(add, content = "  %2 = add i32 %0, %1")

  let nsw_add = builder.build_int_nsw_add!(iarg0, iarg1);
  inspect!(nsw_add, content = "  %3 = add nsw i32 %0, %1")

  let nuw_add = builder.build_int_nuw_add!(iarg1, iarg0, name="nuw_add");
  inspect!(nuw_add, content= "  %nuw_add = add nuw i32 %1, %0")

  let sub = builder.build_int_sub!(iarg0, iarg1);
  inspect!(sub, content = "  %4 = sub i32 %0, %1")

  let nsw_sub = builder.build_int_nsw_sub!(iarg0, iarg1);
  inspect!(nsw_sub, content = "  %5 = sub nsw i32 %0, %1")

  let nuw_sub = builder.build_int_nuw_sub!(iarg1, iarg0);
  inspect!(nuw_sub, content = "  %6 = sub nuw i32 %1, %0")

  let mul = builder.build_int_mul!(iarg0, iarg1);
  inspect!(mul, content = "  %7 = mul i32 %0, %1")

  let nsw_mul = builder.build_int_nsw_mul!(iarg0, iarg1);
  inspect!(nsw_mul, content = "  %8 = mul nsw i32 %0, %1")

  let nuw_mul = builder.build_int_nuw_mul!(iarg1, iarg0);
  inspect!(nuw_mul, content = "  %9 = mul nuw i32 %1, %0")

  let xor = builder.build_xor!(iarg0, iarg1);
  inspect!(xor, content = "  %10 = xor i32 %0, %1")

  let and = builder.build_and!(iarg0, iarg1);
  inspect!(and, content = "  %11 = and i32 %0, %1")

  let or = builder.build_or!(iarg0, iarg1);
  inspect!(or, content = "  %12 = or i32 %0, %1")

  let shl = builder.build_left_shift!(iarg0, iarg1);
  inspect!(shl, content = "  %13 = shl i32 %0, %1")

  let lshr = builder.build_right_shift!(iarg0, iarg1, sign_extend=false);
  inspect!(lshr, content = "  %14 = lshr i32 %0, %1")

  let ashr = builder.build_right_shift!(iarg0, iarg1);
  inspect!(ashr, content = "  %15 = ashr i32 %0, %1")

  let neg = builder.build_int_neg!(iarg0);
  inspect!(neg, content = "  %16 = sub i32 0, %0")

  let nsw_neg = builder.build_int_nsw_neg!(iarg0);
  inspect!(nsw_neg, content = "  %17 = sub nsw i32 0, %0")

  // let nuw_neg = builder.build_int_nuw_neg!(iarg0);
  // inspect!(nuw_neg, content = "  %18 = sub nuw i32 0, %0")

  let not = builder.build_not!(iarg0);
  inspect!(not, content = "  %18 = xor i32 %0, -1")

  let f32_ty = context.f32_type();
  // let farg0 = builder.build_bit_cast!(iarg0, f32_ty, name="f0");
  // let farg1 = builder.build_bit_cast!(iarg1, f32_ty, name="f1");
  let farg0 = builder.build_bit_cast_unsafe!(
    iarg0.as_value_ref(), f32_ty.as_type_ref(), name="f0"
  ).into_float_value();
  let farg1 = builder.build_bit_cast_unsafe!(
    iarg1.as_value_ref(), f32_ty.as_type_ref(), name="f1"
  ).into_float_value();
  inspect!(farg0, content = "  %f0 = bitcast i32 %0 to float")
  inspect!(farg1, content = "  %f1 = bitcast i32 %1 to float")

  let fadd = builder.build_float_add!(farg0, farg1);
  inspect!(fadd, content = "  %19 = fadd float %f0, %f1")

  let fsub = builder.build_float_sub!(farg0, farg1);
  inspect!(fsub, content = "  %20 = fsub float %f0, %f1")

  let fmul = builder.build_float_mul!(farg0, farg1);
  inspect!(fmul, content = "  %21 = fmul float %f0, %f1")

  let fdiv = builder.build_float_div!(farg0, farg1);
  inspect!(fdiv, content = "  %22 = fdiv float %f0, %f1")

  let frem = builder.build_float_rem!(farg0, farg1);
  inspect!(frem, content = "  %23 = frem float %f0, %f1")

  context.drop()
}
