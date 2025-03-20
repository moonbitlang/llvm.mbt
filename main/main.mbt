
fn main_err () -> Unit!Error {
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

  let context = @llvm.Context::create();
  let lmodule = context.create_module("demo");
  let i32_ty = context.i32_type();
  let fty = i32_ty.fn_type([i32_ty]);
  let fval = lmodule.add_function("collatz", fty);
  let entry_bb = context.append_basic_block(fval, "entry");
  let loop_bb = context.append_basic_block(fval, "loop");
  let even_bb = context.append_basic_block(fval, "even");
  let odd_bb = context.append_basic_block(fval, "odd");
  let exit_bb = context.append_basic_block(fval, "exit");
  let builder = context.create_builder();

  let zero = i32_ty.const_int(0);
  let one = i32_ty.const_int(1);
  let two = i32_ty.const_int(2);

  builder.position_at_end(entry_bb);
  let arg0 = fval.get_nth_param(0).unwrap().into_int_value();
  let x_ptr = builder.build_alloca!(i32_ty, name="x");
  let _ = builder.build_store!(x_ptr, arg0);
  let _ = builder.build_unconditional_branch!(loop_bb);

  builder.position_at_end(loop_bb);
  let x_val = builder.build_load!(i32_ty, x_ptr).into_int_value();
  let cond = builder.build_int_compare!(NE, x_val, one);
  let _ = builder.build_conditional_branch!(cond, even_bb, exit_bb);

  builder.position_at_end(even_bb);
  let x_even = builder.build_load!(i32_ty, x_ptr).into_int_value();
  let srem = builder.build_int_signed_rem!(x_even, two);
  let is_even = builder.build_int_compare!(EQ, srem, zero);
  let _ = builder.build_conditional_branch!(is_even, even_bb, odd_bb);

  builder.position_at_end(even_bb);
  let x_even_val = builder.build_load!(i32_ty, x_ptr).into_int_value();
  let x_div = builder.build_int_signed_div!(x_even_val, two);
  let _ = builder.build_store!(x_ptr, x_div);
  let _ = builder.build_unconditional_branch!(loop_bb);

  builder.position_at_end(odd_bb);
  let x_odd_val = builder.build_load!(i32_ty, x_ptr).into_int_value();
  let x_mul = builder.build_int_mul!(x_odd_val, i32_ty.const_int(3));
  let x_add = builder.build_int_add!(x_mul, i32_ty.const_int(1));
  let _ = builder.build_store!(x_ptr, x_add);
  let _ = builder.build_unconditional_branch!(loop_bb);

  builder.position_at_end(exit_bb);
  let x_final = builder.build_load!(i32_ty, x_ptr).into_int_value();
  let _ = builder.build_return!(Some(x_final));
  println(lmodule)
}

test {
  main_err!()
}