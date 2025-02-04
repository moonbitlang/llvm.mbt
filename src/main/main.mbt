
fn struct_test() -> Unit!Error {
  let context = @llvm.Context::create()

  let i32_ty = context.i32_type()
  let f64_ty = context.f64_type()

  // let struct_ty = context.struct_type([i32_ty, f64_ty], is_packed=false)
  let struct_ty = context.struct_type_unsafe(
    [i32_ty.as_type_ref(), f64_ty.as_type_ref()]
  )
  let opaque_struct_ty = context.opaque_struct_type("foo")

  inspect!(struct_ty, content="{ i32, double }")
  inspect!(opaque_struct_ty, content="%foo = type opaque")

  // get_field_type_at_index
  let first_ty = struct_ty.get_field_type_at_index(0)
  let second_ty = struct_ty.get_field_type_at_index(1)
  let third_ty = struct_ty.get_field_type_at_index(2)
  inspect!(first_ty, content="Some(i32)")
  inspect!(second_ty, content="Some(double)")
  inspect!(third_ty, content="None")

  // is_sized and size_of
  assert_true!(struct_ty.is_sized())
  assert_false!(opaque_struct_ty.is_sized())
  inspect!(
    struct_ty.size_of().unwrap(),
    content="i64 ptrtoint (ptr getelementptr ({ i32, double }, ptr null, i32 1) to i64)"
  )
  inspect!(
    opaque_struct_ty.size_of(),
    content="None"
  )

  // get_alignment
  inspect!(
    struct_ty.get_alignment(),
    content="i64 ptrtoint (ptr getelementptr ({ i1, { i32, double } }, ptr null, i64 0, i32 1) to i64)"
  )

  // get_context
  assert_true!(struct_ty.get_context() == context)

  // fn_type
  inspect!(
    struct_ty.fn_type_unsafe([i32_ty.as_type_ref(), f64_ty.as_type_ref()]),
    content="{ i32, double } (i32, double)"
  )

  // array_type
  inspect!(struct_ty.array_type(4), content="[4 x { i32, double }]")
  inspect!(opaque_struct_ty.array_type(4), content="[4 x %foo]")

  // ptr_type
  let addr_space = @llvm.AddressSpace::default()
  inspect!(struct_ty.ptr_type(addr_space), content="ptr")
  inspect!(opaque_struct_ty.ptr_type(addr_space), content="ptr")

  // is_packed
  assert_false!(struct_ty.is_packed())
  assert_false!(opaque_struct_ty.is_packed())

  // count fields
  assert_eq!(struct_ty.count_fields(), 2)
  assert_eq!(opaque_struct_ty.count_fields(), 0)

  // get_field_types
  // inspect!(struct_ty.get_field_types(), content="[i32, double]")
  // inspect!(opaque_struct_ty.get_field_types(), content="[]")

  // get_undef
  inspect!(struct_ty.get_undef(), content="{ i32, double } undef")
  inspect!(opaque_struct_ty.get_undef(), content="%foo undef")

  // get_poison
  inspect!(struct_ty.get_poison(), content="{ i32, double } poison")
  inspect!(opaque_struct_ty.get_poison(), content="%foo poison")

  // set body (The following code is problematic)
  let i64_ty = context.i64_type()
  let _ = struct_ty.set_body_unsafe(
    [i32_ty.as_type_ref(), i64_ty.as_type_ref()]
  )
  let _ = opaque_struct_ty.set_body_unsafe(
    [i64_ty.as_type_ref(), f64_ty.as_type_ref()],
    is_packed=true
  )
  inspect!(opaque_struct_ty, content="%foo = type <{ i64, double }>")
  assert_true!(opaque_struct_ty.is_packed())
  inspect!(struct_ty.get_field_types(), content="[i32, i64]")
  inspect!(opaque_struct_ty.get_field_types(), content="[i64, double]")
  inspect!(opaque_struct_ty.get_undef(), content="%foo undef")
}

fn main {
  // match struct_test?() {
  //   Ok(_) => println("All tests passed")
  //   Err(_) => println("Some tests failed")
  // }
  let context = @llvm.Context::create()
  let i32_ty = context.i32_type()
  let arr_ty = i32_ty.array_type(8)
  println(arr_ty.size_of().unwrap())
}
