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

  let sdiv = builder.build_int_signed_div!(iarg0, iarg1, name="sdiv");
  inspect!(sdiv, content = "  %sdiv = sdiv i32 %0, %1")

  let udiv = builder.build_int_unsigned_div!(iarg0, iarg1, name="udiv");
  inspect!(udiv, content = "  %udiv = udiv i32 %0, %1")

  let srem = builder.build_int_signed_rem!(iarg0, iarg1, name="srem");
  inspect!(srem, content = "  %srem = srem i32 %0, %1")

  let urem = builder.build_int_unsigned_rem!(iarg0, iarg1, name="urem");
  inspect!(urem, content = "  %urem = urem i32 %0, %1")

  let exact_div = builder.build_int_exact_signed_div!(
    iarg0, iarg1, name="exact_div"
  );
  inspect!(exact_div, content = "  %exact_div = sdiv exact i32 %0, %1")

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
  let farg0 = builder.build_bit_cast!(
    iarg0, f32_ty, name="f0"
  ).into_float_value();
  let farg1 = builder.build_bit_cast!(
    iarg1, f32_ty, name="f1"
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

  let fneg = builder.build_float_neg!(farg0);
  inspect!(fneg, content = "  %24 = fneg float %f0")

  // int compare
// - EQ : Equal.
// - NE : Not equal.
// - UGT : Unsigned greater than.
// - UGE : Unsigned greater than or equal.
// - ULT : Unsigned less than.
// - ULE : Unsigned less than or equal.
// - SGT : Signed greater than.
// - SGE : Signed greater than or equal.
// - SLT : Signed less than.
// - SLE : Signed less than or equal.
  let pred_eq = @llvm.IntPredicate::EQ;
  let pred_ne = @llvm.IntPredicate::NE;
  let pred_ugt = @llvm.IntPredicate::UGT;
  let pred_uge = @llvm.IntPredicate::UGE;
  let pred_ult = @llvm.IntPredicate::ULT;
  let pred_ule = @llvm.IntPredicate::ULE;
  let pred_sgt = @llvm.IntPredicate::SGT;
  let pred_sge = @llvm.IntPredicate::SGE;
  let pred_slt = @llvm.IntPredicate::SLT;
  let pred_sle = @llvm.IntPredicate::SLE;

  let ieq = builder.build_int_compare!(pred_eq, iarg0, iarg1, name="ieq")
  inspect!(ieq, content = "  %ieq = icmp eq i32 %0, %1") //?

  let ine = builder.build_int_compare!(pred_ne, iarg0, iarg1, name="ine")
  inspect!(ine, content = "  %ine = icmp ne i32 %0, %1")

  let ugt = builder.build_int_compare!(pred_ugt, iarg0, iarg1, name="ugt")
  inspect!(ugt, content = "  %ugt = icmp ugt i32 %0, %1")

  let uge = builder.build_int_compare!(pred_uge, iarg0, iarg1, name="uge")
  inspect!(uge, content = "  %uge = icmp uge i32 %0, %1")

  let ult = builder.build_int_compare!(pred_ult, iarg0, iarg1, name="ult")
  inspect!(ult, content = "  %ult = icmp ult i32 %0, %1")

  let ule = builder.build_int_compare!(pred_ule, iarg0, iarg1, name="ule")
  inspect!(ule, content = "  %ule = icmp ule i32 %0, %1")

  let sgt = builder.build_int_compare!(pred_sgt, iarg0, iarg1, name="sgt")
  inspect!(sgt, content = "  %sgt = icmp sgt i32 %0, %1")

  let sge = builder.build_int_compare!(pred_sge, iarg0, iarg1, name="sge")
  inspect!(sge, content = "  %sge = icmp sge i32 %0, %1")

  let slt = builder.build_int_compare!(pred_slt, iarg0, iarg1, name="slt")
  inspect!(slt, content = "  %slt = icmp slt i32 %0, %1")

  let sle = builder.build_int_compare!(pred_sle, iarg0, iarg1, name="sle")
  inspect!(sle, content = "  %sle = icmp sle i32 %0, %1")

  let fpred_oeq = @llvm.FloatPredicate::OEQ;
  let fpred_ogt = @llvm.FloatPredicate::OGT;
  let fpred_oge = @llvm.FloatPredicate::OGE;
  let fpred_olt = @llvm.FloatPredicate::OLT;
  let fpred_ole = @llvm.FloatPredicate::OLE;
  let fpred_one = @llvm.FloatPredicate::ONE;
  let fpred_ord = @llvm.FloatPredicate::ORD;
  let fpred_false = @llvm.FloatPredicate::PredicateFalse;
  let fpred_true = @llvm.FloatPredicate::PredicateTrue;
  let fpred_ueq = @llvm.FloatPredicate::UEQ;
  let fpred_uge = @llvm.FloatPredicate::UGE;
  let fpred_ugt = @llvm.FloatPredicate::UGT;
  let fpred_ult = @llvm.FloatPredicate::ULT;
  let fpred_ule = @llvm.FloatPredicate::ULE;
  let fpred_une = @llvm.FloatPredicate::UNE;

  let foeq = builder.build_float_compare!(fpred_oeq, farg0, farg1, name="foeq")
  inspect!(foeq, content = "  %foeq = fcmp oeq float %f0, %f1")

  let fogt = builder.build_float_compare!(fpred_ogt, farg0, farg1, name="fogt")
  inspect!(fogt, content = "  %fogt = fcmp ogt float %f0, %f1")

  let foge = builder.build_float_compare!(fpred_oge, farg0, farg1, name="foge")
  inspect!(foge, content = "  %foge = fcmp oge float %f0, %f1")

  let folt = builder.build_float_compare!(fpred_olt, farg0, farg1, name="folt")
  inspect!(folt, content = "  %folt = fcmp olt float %f0, %f1")

  let fole = builder.build_float_compare!(fpred_ole, farg0, farg1, name="fole")
  inspect!(fole, content = "  %fole = fcmp ole float %f0, %f1")

  let fone = builder.build_float_compare!(fpred_one, farg0, farg1, name="fone")
  inspect!(fone, content = "  %fone = fcmp one float %f0, %f1")

  let ford = builder.build_float_compare!(fpred_ord, farg0, farg1, name="ford")
  inspect!(ford, content = "  %ford = fcmp ord float %f0, %f1")

  let ffalse = builder.build_float_compare!(
    fpred_false, farg0, farg1, name="ffalse"
  )
  inspect!(ffalse, content = "  %ffalse = fcmp false float %f0, %f1")

  let ftrue = builder.build_float_compare!(
    fpred_true, farg0, farg1, name="ftrue"
  )
  inspect!(ftrue, content = "  %ftrue = fcmp true float %f0, %f1")

  let fueq = builder.build_float_compare!(fpred_ueq, farg0, farg1, name="fueq")
  inspect!(fueq, content = "  %fueq = fcmp ueq float %f0, %f1")

  let fuge = builder.build_float_compare!(fpred_uge, farg0, farg1, name="fuge")
  inspect!(fuge, content = "  %fuge = fcmp uge float %f0, %f1")

  let fugt = builder.build_float_compare!(fpred_ugt, farg0, farg1, name="fugt")
  inspect!(fugt, content = "  %fugt = fcmp ugt float %f0, %f1")

  let fult = builder.build_float_compare!(fpred_ult, farg0, farg1, name="fult")
  inspect!(fult, content = "  %fult = fcmp ult float %f0, %f1")

  let fule = builder.build_float_compare!(fpred_ule, farg0, farg1, name="fule")
  inspect!(fule, content = "  %fule = fcmp ule float %f0, %f1")

  let fune = builder.build_float_compare!(fpred_une, farg0, farg1, name="fune")
  inspect!(fune, content = "  %fune = fcmp une float %f0, %f1")

  context.drop()
}
