///|
test "Real Case - Simple Calculation" {
  // int foo(int x, int y) {
  //   int a = x + y;
  //   int b = x - y;
  //   int c = a * b;
  //   return c;
  // } 

  let context = @llvm.Context::create()
  let lmodule = context.create_module("demo")
  let i32_ty = context.i32_type()
  let fty = i32_ty.fn_type([i32_ty, i32_ty])
  let fval = lmodule.add_function("foo", fty)
  let bb = context.append_basic_block(fval, name="entry")
  let builder = context.create_builder()
  builder.position_at_end(bb)
  let arg0 = fval.get_nth_param(0).unwrap()
  let arg1 = fval.get_nth_param(1).unwrap()
  let a_ptr = builder.build_alloca(i32_ty, name="a")
  let b_ptr = builder.build_alloca(i32_ty, name="b")
  let c_ptr = builder.build_alloca(i32_ty, name="c")
  let x = arg0.into_int_value()
  let y = arg1.into_int_value()
  let add = builder.build_int_add(x, y)
  let _ = builder.build_store(a_ptr, add)
  let sub = builder.build_int_sub(x, y)
  let _ = builder.build_store(b_ptr, sub)
  let a_val = builder.build_load(i32_ty, a_ptr).into_int_value()
  let b_val = builder.build_load(i32_ty, b_ptr).into_int_value()
  let mul = builder.build_int_mul(a_val, b_val)
  let _ = builder.build_store(c_ptr, mul)
  let c_val = builder.build_load(i32_ty, c_ptr).into_int_value()
  let _ = builder.build_return(Some(c_val))
  let expect =
    #|define i32 @foo(i32 %0, i32 %1) {
    #|entry:
    #|  %a = alloca i32, align 4
    #|  %b = alloca i32, align 4
    #|  %c = alloca i32, align 4
    #|  %2 = add i32 %0, %1
    #|  store i32 %2, ptr %a, align 4
    #|  %3 = sub i32 %0, %1
    #|  store i32 %3, ptr %b, align 4
    #|  %4 = load i32, ptr %a, align 4
    #|  %5 = load i32, ptr %b, align 4
    #|  %6 = mul i32 %4, %5
    #|  store i32 %6, ptr %c, align 4
    #|  %7 = load i32, ptr %c, align 4
    #|  ret i32 %7
    #|}
    #|
  inspect(fval, content=expect)
  context.drop()
}

///|
test "Real Case - Simple Branch" {
  // int collatz(int x) {
  //   while (x != 1) {
  //     if (x % 2 == 0) {
  //       x = x / 2;
  //     } else {
  //       x = 3 * x + 1;
  //     }
  //   }
  //   return x;
  // }

  let context = @llvm.Context::create()
  let lmodule = context.create_module("demo")
  let i32_ty = context.i32_type()
  let fty = i32_ty.fn_type([i32_ty])
  let fval = lmodule.add_function("collatz", fty)
  let entry_bb = context.append_basic_block(fval, name="entry")
  let loop_bb = context.append_basic_block(fval, name="loop")
  let even_bb = context.append_basic_block(fval, name="even")
  let odd_bb = context.append_basic_block(fval, name="odd")
  let exit_bb = context.append_basic_block(fval, name="exit")
  let builder = context.create_builder()
  let zero = i32_ty.const_int(0)
  let one = i32_ty.const_int(1)
  let two = i32_ty.const_int(2)
  builder.position_at_end(entry_bb)
  let arg0 = fval.get_nth_param(0).unwrap().into_int_value()
  let x_ptr = builder.build_alloca(i32_ty, name="x")
  let _ = builder.build_store(x_ptr, arg0)
  let _ = builder.build_unconditional_branch(loop_bb)
  builder.position_at_end(loop_bb)
  let x_val = builder.build_load(i32_ty, x_ptr).into_int_value()
  let cond = builder.build_int_compare(NE, x_val, one)
  let _ = builder.build_conditional_branch(cond, even_bb, exit_bb)
  builder.position_at_end(even_bb)
  let x_even = builder.build_load(i32_ty, x_ptr).into_int_value()
  let srem = builder.build_int_signed_rem(x_even, two)
  let is_even = builder.build_int_compare(EQ, srem, zero)
  let _ = builder.build_conditional_branch(is_even, even_bb, odd_bb)
  builder.position_at_end(even_bb)
  let x_even_val = builder.build_load(i32_ty, x_ptr).into_int_value()
  let x_div = builder.build_int_signed_div(x_even_val, two)
  let _ = builder.build_store(x_ptr, x_div)
  let _ = builder.build_unconditional_branch(loop_bb)
  builder.position_at_end(odd_bb)
  let x_odd_val = builder.build_load(i32_ty, x_ptr).into_int_value()
  let x_mul = builder.build_int_mul(x_odd_val, i32_ty.const_int(3))
  let x_add = builder.build_int_add(x_mul, i32_ty.const_int(1))
  let _ = builder.build_store(x_ptr, x_add)
  let _ = builder.build_unconditional_branch(loop_bb)
  builder.position_at_end(exit_bb)
  let x_final = builder.build_load(i32_ty, x_ptr).into_int_value()
  let _ = builder.build_return(Some(x_final))
  let expect =
    #|define i32 @collatz(i32 %0) {
    #|entry:
    #|  %x = alloca i32, align 4
    #|  store i32 %0, ptr %x, align 4
    #|  br label %loop
    #|
    #|loop:                                             ; preds = %odd, %even, %entry
    #|  %1 = load i32, ptr %x, align 4
    #|  %2 = icmp ne i32 %1, 1
    #|  br i1 %2, label %even, label %exit
    #|
    #|even:                                             ; preds = %even, %loop
    #|  %3 = load i32, ptr %x, align 4
    #|  %4 = srem i32 %3, 2
    #|  %5 = icmp eq i32 %4, 0
    #|  br i1 %5, label %even, label %odd
    #|  %6 = load i32, ptr %x, align 4
    #|  %7 = sdiv i32 %6, 2
    #|  store i32 %7, ptr %x, align 4
    #|  br label %loop
    #|
    #|odd:                                              ; preds = %even
    #|  %8 = load i32, ptr %x, align 4
    #|  %9 = mul i32 %8, 3
    #|  %10 = add i32 %9, 1
    #|  store i32 %10, ptr %x, align 4
    #|  br label %loop
    #|
    #|exit:                                             ; preds = %loop
    #|  %11 = load i32, ptr %x, align 4
    #|  ret i32 %11
    #|}
    #|
  inspect(fval, content=expect)
  context.drop()
}
