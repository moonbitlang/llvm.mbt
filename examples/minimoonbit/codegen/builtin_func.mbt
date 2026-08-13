///|
fn get_builtin_functions(
  llvm_ctx : @llvm.Context,
) -> Map[String, @llvm.FunctionType] {
  let i32ty = llvm_ctx.getInt32Ty()
  let i64ty = llvm_ctx.getInt64Ty()
  let i8ty = llvm_ctx.getInt8Ty()
  let doublety = llvm_ctx.getDoubleTy()
  let floatty = llvm_ctx.getFloatTy()
  let boolty = llvm_ctx.getInt1Ty()
  let ptrty = llvm_ctx.getPtrTy()
  let voidty = llvm_ctx.getVoidTy()
  let moonbit_malloc_ty = llvm_ctx.getFunctionType(ptrty, [i32ty])
  // Add `make_int_array_ty, make_int_array`: (Int, Int) -> Ptr
  // Add `make_double_array_ty, make_double_array`: (Int, Double) -> Ptr
  // Add `make_bool_array_ty, make_bool_array`: (Int, Bool) -> Ptr
  // Add `make_ptr_array_ty, make_ptr_array`: (Int, Ptr) -> Ptr
  let make_int_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, i32ty])
  let make_int64_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, i64ty])
  let make_uint_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, i32ty])
  let make_uint64_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, i64ty])
  let make_double_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, doublety])
  let make_float_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, floatty])
  let make_bool_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, boolty])
  let make_char_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, i8ty])
  let make_ptr_array_ty = llvm_ctx.getFunctionType(ptrty, [i32ty, ptrty])
  let get_array_length_ty = llvm_ctx.getFunctionType(i32ty, [ptrty])
  let array_int_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, i32ty,
  ])
  let array_int64_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, i64ty,
  ])
  let array_uint_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, i32ty,
  ])
  let array_uint64_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, i64ty,
  ])
  let array_double_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, doublety,
  ])
  let array_float_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, floatty,
  ])
  let array_bool_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, boolty,
  ])
  let array_char_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, i8ty,
  ])
  let array_ptr_push_ty = llvm_ctx.getFunctionType(llvm_ctx.getVoidTy(), [
    ptrty, ptrty,
  ])
  let array_int_get_ty = llvm_ctx.getFunctionType(i32ty, [ptrty, i32ty])
  let array_int64_get_ty = llvm_ctx.getFunctionType(i64ty, [ptrty, i32ty])
  let array_uint_get_ty = llvm_ctx.getFunctionType(i32ty, [ptrty, i32ty])
  let array_uint64_get_ty = llvm_ctx.getFunctionType(i64ty, [ptrty, i32ty])
  let array_double_get_ty = llvm_ctx.getFunctionType(doublety, [ptrty, i32ty])
  let array_float_get_ty = llvm_ctx.getFunctionType(floatty, [ptrty, i32ty])
  let array_bool_get_ty = llvm_ctx.getFunctionType(boolty, [ptrty, i32ty])
  let array_char_get_ty = llvm_ctx.getFunctionType(i8ty, [ptrty, i32ty])
  let array_ptr_get_ty = llvm_ctx.getFunctionType(ptrty, [ptrty, i32ty])
  let array_int_put_ty = llvm_ctx.getFunctionType(voidty, [ptrty, i32ty, i32ty])
  let array_int64_put_ty = llvm_ctx.getFunctionType(voidty, [
    ptrty, i32ty, i64ty,
  ])
  let array_uint_put_ty = llvm_ctx.getFunctionType(voidty, [ptrty, i32ty, i32ty])
  let array_uint64_put_ty = llvm_ctx.getFunctionType(voidty, [
    ptrty, i32ty, i64ty,
  ])
  let array_double_put_ty = llvm_ctx.getFunctionType(voidty, [
    ptrty, i32ty, doublety,
  ])
  let array_float_put_ty = llvm_ctx.getFunctionType(voidty, [
    ptrty, i32ty, floatty,
  ])
  let array_bool_put_ty = llvm_ctx.getFunctionType(voidty, [
    ptrty, i32ty, boolty,
  ])
  let array_char_put_ty = llvm_ctx.getFunctionType(voidty, [ptrty, i32ty, i8ty])
  let array_ptr_put_ty = llvm_ctx.getFunctionType(voidty, [ptrty, i32ty, ptrty])
  let int_of_float_ty = llvm_ctx.getFunctionType(i32ty, [doublety])
  let float_of_int_ty = llvm_ctx.getFunctionType(doublety, [i32ty])
  let builtin_print_int_ty = llvm_ctx.getFunctionType(voidty, [i32ty])
  let builtin_print_int64_ty = llvm_ctx.getFunctionType(voidty, [i64ty])
  let builtin_print_uint_ty = llvm_ctx.getFunctionType(voidty, [i32ty])
  let builtin_print_uint64_ty = llvm_ctx.getFunctionType(voidty, [i64ty])
  let builtin_print_double_ty = llvm_ctx.getFunctionType(voidty, [doublety])
  let builtin_print_float_ty = llvm_ctx.getFunctionType(voidty, [floatty])
  let builtin_print_char_ty = llvm_ctx.getFunctionType(voidty, [i8ty])
  let builtin_print_bool_ty = llvm_ctx.getFunctionType(voidty, [boolty])
  let builtin_print_string_ty = llvm_ctx.getFunctionType(voidty, [ptrty])
  let builtin_println_int_ty = llvm_ctx.getFunctionType(voidty, [i32ty])
  let builtin_println_int64_ty = llvm_ctx.getFunctionType(voidty, [i64ty])
  let builtin_println_uint_ty = llvm_ctx.getFunctionType(voidty, [i32ty])
  let builtin_println_uint64_ty = llvm_ctx.getFunctionType(voidty, [i64ty])
  let builtin_println_double_ty = llvm_ctx.getFunctionType(voidty, [doublety])
  let builtin_println_float_ty = llvm_ctx.getFunctionType(voidty, [floatty])
  let builtin_println_char_ty = llvm_ctx.getFunctionType(voidty, [i8ty])
  let builtin_println_bool_ty = llvm_ctx.getFunctionType(voidty, [boolty])
  let builtin_println_string_ty = llvm_ctx.getFunctionType(voidty, [ptrty])
  // String related functions
  let builtin_create_string_ty = llvm_ctx.getFunctionType(ptrty, [ptrty])
  let builtin_get_string_length_ty = llvm_ctx.getFunctionType(i32ty, [ptrty])
  let builtin_string_concat_ty = llvm_ctx.getFunctionType(ptrty, [ptrty, ptrty])
  let builtin_get_char_in_string_ty = llvm_ctx.getFunctionType(i8ty, [
    ptrty, i32ty,
  ])
  let moonbit_string_eq_ty = llvm_ctx.getFunctionType(boolty, [ptrty, ptrty])
  // Type conversion to string functions
  let builtin_int_to_string_ty = llvm_ctx.getFunctionType(ptrty, [i32ty])
  let builtin_int64_to_string_ty = llvm_ctx.getFunctionType(ptrty, [i64ty])
  let builtin_uint_to_string_ty = llvm_ctx.getFunctionType(ptrty, [i32ty])
  let builtin_uint64_to_string_ty = llvm_ctx.getFunctionType(ptrty, [i64ty])
  let builtin_float_to_string_ty = llvm_ctx.getFunctionType(ptrty, [floatty])
  let builtin_double_to_string_ty = llvm_ctx.getFunctionType(ptrty, [doublety])
  let builtin_char_to_string_ty = llvm_ctx.getFunctionType(ptrty, [i8ty])
  let builtin_func_tys = {
    "moonbit_malloc": moonbit_malloc_ty,
    "make_int_array": make_int_array_ty,
    "make_int64_array": make_int64_array_ty,
    "make_uint_array": make_uint_array_ty,
    "make_uint64_array": make_uint64_array_ty,
    "make_double_array": make_double_array_ty,
    "make_float_array": make_float_array_ty,
    "make_bool_array": make_bool_array_ty,
    "make_char_array": make_char_array_ty,
    "make_ptr_array": make_ptr_array_ty,
    "get_array_length": get_array_length_ty,
    "array_int_push": array_int_push_ty,
    "array_int64_push": array_int64_push_ty,
    "array_uint_push": array_uint_push_ty,
    "array_uint64_push": array_uint64_push_ty,
    "array_double_push": array_double_push_ty,
    "array_float_push": array_float_push_ty,
    "array_bool_push": array_bool_push_ty,
    "array_char_push": array_char_push_ty,
    "array_ptr_push": array_ptr_push_ty,
    "array_int_get": array_int_get_ty,
    "array_int64_get": array_int64_get_ty,
    "array_uint_get": array_uint_get_ty,
    "array_uint64_get": array_uint64_get_ty,
    "array_double_get": array_double_get_ty,
    "array_float_get": array_float_get_ty,
    "array_bool_get": array_bool_get_ty,
    "array_char_get": array_char_get_ty,
    "array_ptr_get": array_ptr_get_ty,
    "array_int_put": array_int_put_ty,
    "array_int64_put": array_int64_put_ty,
    "array_uint_put": array_uint_put_ty,
    "array_uint64_put": array_uint64_put_ty,
    "array_double_put": array_double_put_ty,
    "array_float_put": array_float_put_ty,
    "array_bool_put": array_bool_put_ty,
    "array_char_put": array_char_put_ty,
    "array_ptr_put": array_ptr_put_ty,
    "int_of_float": int_of_float_ty,
    "float_of_int": float_of_int_ty,
    "__builtin_print_int": builtin_print_int_ty,
    "__builtin_print_int64": builtin_print_int64_ty,
    "__builtin_print_uint": builtin_print_uint_ty,
    "__builtin_print_uint64": builtin_print_uint64_ty,
    "__builtin_print_double": builtin_print_double_ty,
    "__builtin_print_float": builtin_print_float_ty,
    "__builtin_print_char": builtin_print_char_ty,
    "__builtin_print_bool": builtin_print_bool_ty,
    "__builtin_print_string": builtin_print_string_ty,
    "__builtin_println_int": builtin_println_int_ty,
    "__builtin_println_int64": builtin_println_int64_ty,
    "__builtin_println_uint": builtin_println_uint_ty,
    "__builtin_println_uint64": builtin_println_uint64_ty,
    "__builtin_println_double": builtin_println_double_ty,
    "__builtin_println_float": builtin_println_float_ty,
    "__builtin_println_char": builtin_println_char_ty,
    "__builtin_println_bool": builtin_println_bool_ty,
    "__builtin_println_string": builtin_println_string_ty,
    "__builtin_create_string": builtin_create_string_ty,
    "__builtin_get_string_length": builtin_get_string_length_ty,
    "__builtin_string_concat": builtin_string_concat_ty,
    "__builtin_get_char_in_string": builtin_get_char_in_string_ty,
    "moonbit_string_eq": moonbit_string_eq_ty,
    "__builtin_int_to_string": builtin_int_to_string_ty,
    "__builtin_int64_to_string": builtin_int64_to_string_ty,
    "__builtin_uint_to_string": builtin_uint_to_string_ty,
    "__builtin_uint64_to_string": builtin_uint64_to_string_ty,
    "__builtin_float_to_string": builtin_float_to_string_ty,
    "__builtin_double_to_string": builtin_double_to_string_ty,
    "__builtin_char_to_string": builtin_char_to_string_ty,
  }
  builtin_func_tys
}
