// test "Basic type and Basic value" {
//   let context = @llvm.Context::create()
//
//   let void_ty = context.void_type()
//   inspect!(void_ty, content="void")
//
//   context.drop()
// }

test "integer type" {
  let context = @llvm.Context::create()

  let bool_ty = context.bool_type()
  let i8_ty = context.i8_type()
  let i16_ty = context.i16_type()
  let i32_ty = context.i32_type()
  let i64_ty = context.i64_type()
  let i128_ty = context.i128_type()

  inspect!(bool_ty, content="i1")
  inspect!(i8_ty, content="i8")
  inspect!(i16_ty, content="i16")
  inspect!(i32_ty, content="i32")
  inspect!(i64_ty, content="i64")
  inspect!(i128_ty, content="i128")

  // const_int
  // TODO: test signextension
  inspect!(bool_ty.const_int(1), content="i1 true")
  inspect!(i8_ty.const_int(42), content="i8 42")
  inspect!(i16_ty.const_int(42), content="i16 42")
  inspect!(i32_ty.const_int(42), content="i32 42")
  inspect!(i64_ty.const_int(42), content="i64 42")
  inspect!(i128_ty.const_int(42), content="i128 42")

  // const_int_arbitrary_precision

  // const_all_ones
  inspect!(bool_ty.const_all_ones(), content="i1 true")
  inspect!(i8_ty.const_all_ones(), content="i8 -1")
  inspect!(i16_ty.const_all_ones(), content="i16 -1")
  inspect!(i32_ty.const_all_ones(), content="i32 -1")
  inspect!(i64_ty.const_all_ones(), content="i64 -1")
  inspect!(i128_ty.const_all_ones(), content="i128 -1")

  // const_zero

  // fn_type
  // let fn_type = i32_ty.fn_type([i16_ty, i64_ty])
  // inspect!(fn_type, content="i32 (i16, i64)")
  let fn_type = i32_ty.fn_type_unsafe([i16_ty.as_type_ref(), i64_ty.as_type_ref()])
  inspect!(fn_type, content="i32 (i16, i64)")

  // array_type
  inspect!(bool_ty.array_type(4), content="[4 x i1]")
  inspect!(i8_ty.array_type(8), content="[8 x i8]")
  inspect!(i16_ty.array_type(16), content="[16 x i16]")
  inspect!(i32_ty.array_type(32), content="[32 x i32]")
  inspect!(i64_ty.array_type(64), content="[64 x i64]")
  inspect!(i128_ty.array_type(128), content="[128 x i128]")

  // vector_type
  inspect!(bool_ty.vec_type(2), content="<2 x i1>")
  inspect!(i8_ty.vec_type(2), content="<2 x i8>")
  inspect!(i16_ty.vec_type(4), content="<4 x i16>")
  inspect!(i32_ty.vec_type(8), content="<8 x i32>")
  inspect!(i64_ty.vec_type(16), content="<16 x i64>")
  inspect!(i128_ty.vec_type(32), content="<32 x i128>")

  // scalable_vec_type
  inspect!(bool_ty.scalable_vec_type(2), content="<vscale x 2 x i1>")
  inspect!(i8_ty.scalable_vec_type(2), content="<vscale x 2 x i8>")
  inspect!(i16_ty.scalable_vec_type(4), content="<vscale x 4 x i16>")
  inspect!(i32_ty.scalable_vec_type(8), content="<vscale x 8 x i32>")
  inspect!(i64_ty.scalable_vec_type(16), content="<vscale x 16 x i64>")
  inspect!(i128_ty.scalable_vec_type(32), content="<vscale x 32 x i128>")

  // get_context
  assert_true!(bool_ty.get_context() == context)
  assert_true!(i8_ty.get_context() == context)
  assert_true!(i16_ty.get_context() == context)
  assert_true!(i32_ty.get_context() == context)
  assert_true!(i64_ty.get_context() == context)
  assert_true!(i128_ty.get_context() == context)

  // size_of
  inspect!(
    bool_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (i1, ptr null, i32 1) to i64)"
  )
  inspect!(
    i8_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (i8, ptr null, i32 1) to i64)"
  )
  inspect!(
    i16_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (i16, ptr null, i32 1) to i64)"
  )
  inspect!(
    i32_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)"
  )
  inspect!(
    i64_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)"
  )
  inspect!(
    i128_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (i128, ptr null, i32 1) to i64)"
  )

  // is_sized
  assert_true!(bool_ty.is_sized())
  assert_true!(i8_ty.is_sized())
  assert_true!(i16_ty.is_sized())
  assert_true!(i32_ty.is_sized())
  assert_true!(i64_ty.is_sized())
  assert_true!(i128_ty.is_sized())

  // get_alignment
  inspect!(
    bool_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, i1 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    i8_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, i8 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    i16_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, i16 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    i32_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, i32 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    i64_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, i64 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    i128_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, i128 }, ptr null, i64 0, i32 1) to i64)"
  )

  // ptr_type
  let addr_space = @llvm.AddressSpace::default()
  inspect!(bool_ty.ptr_type(addr_space), content="ptr")
  inspect!(i8_ty.ptr_type(addr_space), content="ptr")
  inspect!(i16_ty.ptr_type(addr_space), content="ptr")
  inspect!(i32_ty.ptr_type(addr_space), content="ptr")
  inspect!(i64_ty.ptr_type(addr_space), content="ptr")
  inspect!(i128_ty.ptr_type(addr_space), content="ptr")

  // get_bit_width
  inspect!(bool_ty.get_bit_width(), content="1")
  inspect!(i8_ty.get_bit_width(), content="8")
  inspect!(i16_ty.get_bit_width(), content="16")
  inspect!(i32_ty.get_bit_width(), content="32")
  inspect!(i64_ty.get_bit_width(), content="64")
  inspect!(i128_ty.get_bit_width(), content="128")

  // get_undef
  inspect!(bool_ty.get_undef(), content="i1 undef")
  inspect!(i8_ty.get_undef(), content="i8 undef")
  inspect!(i16_ty.get_undef(), content="i16 undef")
  inspect!(i32_ty.get_undef(), content="i32 undef")
  inspect!(i64_ty.get_undef(), content="i64 undef")
  inspect!(i128_ty.get_undef(), content="i128 undef")

  // get_poison
  inspect!(bool_ty.get_poison(), content="i1 poison")
  inspect!(i8_ty.get_poison(), content="i8 poison")
  inspect!(i16_ty.get_poison(), content="i16 poison")
  inspect!(i32_ty.get_poison(), content="i32 poison")
  inspect!(i64_ty.get_poison(), content="i64 poison")
  inspect!(i128_ty.get_poison(), content="i128 poison")

  context.drop()
}

// TODO: test `fn_type`, `const_array`, `const_float_from_string`.
test "floating-point type" {
  let context = @llvm.Context::create()

  let half_ty = context.f16_type()
  let float_ty = context.f32_type()
  let double_ty = context.f64_type()
  let x86_f80_ty = context.x86_f80_type()
  let f128_ty = context.f128_type()
  let ppc_f128_ty = context.ppc_f128_type()

  inspect!(half_ty, content="half")
  inspect!(float_ty, content="float")
  inspect!(double_ty, content="double")
  inspect!(x86_f80_ty, content="x86_fp80")
  inspect!(f128_ty, content="fp128")
  inspect!(ppc_f128_ty, content="ppc_fp128")

  // const_float
  inspect!(
    half_ty.const_float(3.1415926),
    content="half 0xH4248"
  )
  inspect!(
    float_ty.const_float(3.1415926),
    content="float 0x400921FB40000000"
  )
  inspect!(
    double_ty.const_float(3.1415926),
    content="double 0x400921FB4D12D84A"
  )
  inspect!(
    x86_f80_ty.const_float(3.1415926),
    content="x86_fp80 0xK4000C90FDA6896C25000"
  )
  inspect!(
    f128_ty.const_float(3.1415926),
    content="fp128 0xLA0000000000000004000921FB4D12D84"
  )
  inspect!(
    ppc_f128_ty.const_float(3.1415926),
    content="ppc_fp128 0xM400921FB4D12D84A0000000000000000"
  )

  // array_type
  inspect!(half_ty.array_type(4), content="[4 x half]")
  inspect!(float_ty.array_type(8), content="[8 x float]")
  inspect!(double_ty.array_type(16), content="[16 x double]")
  inspect!(x86_f80_ty.array_type(32), content="[32 x x86_fp80]")
  inspect!(f128_ty.array_type(64), content="[64 x fp128]")
  inspect!(ppc_f128_ty.array_type(128), content="[128 x ppc_fp128]")

  // vec_type
  inspect!(half_ty.vec_type(2), content="<2 x half>")
  inspect!(float_ty.vec_type(4), content="<4 x float>")
  inspect!(double_ty.vec_type(8), content="<8 x double>")
  inspect!(x86_f80_ty.vec_type(16), content="<16 x x86_fp80>")
  inspect!(f128_ty.vec_type(32), content="<32 x fp128>")
  inspect!(ppc_f128_ty.vec_type(64), content="<64 x ppc_fp128>")

  // scalable_vec_type
  inspect!(half_ty.scalable_vec_type(2), content="<vscale x 2 x half>")
  inspect!(float_ty.scalable_vec_type(4), content="<vscale x 4 x float>")
  inspect!(double_ty.scalable_vec_type(8), content="<vscale x 8 x double>")
  inspect!(x86_f80_ty.scalable_vec_type(16), content="<vscale x 16 x x86_fp80>")
  inspect!(f128_ty.scalable_vec_type(32), content="<vscale x 32 x fp128>")
  inspect!(ppc_f128_ty.scalable_vec_type(64), content="<vscale x 64 x ppc_fp128>")

  // get_context
  assert_true!(half_ty.get_context() == context)
  assert_true!(float_ty.get_context() == context)
  assert_true!(double_ty.get_context() == context)
  assert_true!(x86_f80_ty.get_context() == context)
  assert_true!(f128_ty.get_context() == context)
  assert_true!(ppc_f128_ty.get_context() == context)

  // size of
  inspect!(
    half_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (half, ptr null, i32 1) to i64)"
  )
  inspect!(
    float_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (float, ptr null, i32 1) to i64)"
  )
  inspect!(
    double_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (double, ptr null, i32 1) to i64)"
  )
  inspect!(
    x86_f80_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (x86_fp80, ptr null, i32 1) to i64)"
  )
  inspect!(
    f128_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (fp128, ptr null, i32 1) to i64)"
  )
  inspect!(
    ppc_f128_ty.size_of(),
    content="i64 ptrtoint (ptr getelementptr (ppc_fp128, ptr null, i32 1) to i64)"
  )

  // is_sized
  assert_true!(half_ty.is_sized())
  assert_true!(float_ty.is_sized())
  assert_true!(double_ty.is_sized())
  assert_true!(x86_f80_ty.is_sized())
  assert_true!(f128_ty.is_sized())
  assert_true!(ppc_f128_ty.is_sized())

  // get_alignment
  inspect!(
    half_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, half }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    float_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, float }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    double_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, double }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    x86_f80_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, x86_fp80 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    f128_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, fp128 }, ptr null, i64 0, i32 1) to i64)"
  )
  inspect!(
    ppc_f128_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, ppc_fp128 }, ptr null, i64 0, i32 1) to i64)"
  )

  // ptr_type
  let addr_space = @llvm.AddressSpace::default()
  inspect!(half_ty.ptr_type(addr_space), content="ptr")
  inspect!(float_ty.ptr_type(addr_space), content="ptr")
  inspect!(double_ty.ptr_type(addr_space), content="ptr")
  inspect!(x86_f80_ty.ptr_type(addr_space), content="ptr")
  inspect!(f128_ty.ptr_type(addr_space), content="ptr")
  inspect!(ppc_f128_ty.ptr_type(addr_space), content="ptr")

  // get_undef
  inspect!(half_ty.get_undef(), content="half undef")
  inspect!(float_ty.get_undef(), content="float undef")
  inspect!(double_ty.get_undef(), content="double undef")
  inspect!(x86_f80_ty.get_undef(), content="x86_fp80 undef")
  inspect!(f128_ty.get_undef(), content="fp128 undef")
  inspect!(ppc_f128_ty.get_undef(), content="ppc_fp128 undef")

  // get_poison
  inspect!(half_ty.get_poison(), content="half poison")
  inspect!(float_ty.get_poison(), content="float poison")
  inspect!(double_ty.get_poison(), content="double poison")
  inspect!(x86_f80_ty.get_poison(), content="x86_fp80 poison")
  inspect!(f128_ty.get_poison(), content="fp128 poison")
  inspect!(ppc_f128_ty.get_poison(), content="ppc_fp128 poison")

  context.drop()
}

test "void type" {
  let context = @llvm.Context::create()

  let void_ty = context.void_type()

  inspect!(void_ty, content="void")

  // inspect!(void_ty.fn_type([], is_var_arg=false), content="void ()")
  inspect!(void_ty.fn_type_unsafe([]), content="void ()")
  
  inspect!(
    void_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, void }, ptr null, i64 0, i32 1) to i64)"
  )

  assert_false!(void_ty.is_sized())
  assert_true!(void_ty.get_context() == context)
  context.drop()
}
