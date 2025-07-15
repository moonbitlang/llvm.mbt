///|
test "Simple Stack Memory Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty])
  let fval = mod.addFunction(fty, "stack_test")
  let bb = fval.appendBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  builder.setInsertPoint(bb)

  // Test alloca
  let alloca = builder.createAlloca(i32_ty, name="temp")

  // Test store
  let _ = builder.createStore(arg0, alloca)

  // Test load
  let load = builder.createLoad(i32_ty, alloca, name="loaded")

  // Return loaded value
  let _ = builder.createRet(load)
  let expect =
    #|define i32 @stack_test(i32 %0) {
    #|entry:
    #|  %temp = alloca i32, align 4
    #|  store i32 %0, ptr %temp, align 4
    #|  %loaded = load i32, ptr %temp, align 4
    #|  ret i32 %loaded
    #|}
    #|
  inspect(fval, content=expect)

  // Test store with non-pointer - may not be checked in current implementation
  assert_true(
    (try? builder.createStore(arg0, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
}

///|
test "Aggregate Stack Memory Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let array_ty = ctx.getArrayType(i32_ty, 3)
  let struct_ty = ctx.getStructType([i32_ty, i32_ty])
  let fty = ctx.getFunctionType(i32_ty, [])
  let fval = mod.addFunction(fty, "aggregate_stack_test")
  let bb = fval.appendBasicBlock(name="entry")
  builder.setInsertPoint(bb)

  // Test alloca with array type
  let array_alloca = builder.createAlloca(array_ty, name="array_temp")

  // Test alloca with struct type
  let struct_alloca = builder.createAlloca(struct_ty, name="struct_temp")

  // Test GEP with array
  let zero = ctx.getConstInt32(0)
  let one = ctx.getConstInt32(1)
  let array_gep = builder.createGEP(
    array_alloca,
    array_ty,
    [zero, one],
    name="array_elem",
    inbounds=true,
  )

  // Test GEP with struct
  let struct_gep = builder.createGEP(
    struct_alloca,
    struct_ty,
    [zero, one],
    name="struct_elem",
    inbounds=true,
  )

  // Store values through GEP
  let val42 = ctx.getConstInt32(42)
  let val24 = ctx.getConstInt32(24)
  let _ = builder.createStore(val42, array_gep)
  let _ = builder.createStore(val24, struct_gep)

  // Load values through GEP
  let loaded_array = builder.createLoad(i32_ty, array_gep, name="loaded_array")
  let loaded_struct = builder.createLoad(
    i32_ty,
    struct_gep,
    name="loaded_struct",
  )

  // Test insertvalue and extractvalue with struct
  let struct_val = ctx.getConstStruct([
    ctx.getConstInt32(10),
    ctx.getConstInt32(20),
  ])
  let insert_val = builder.createInsertValue(
    struct_val,
    val42,
    0,
    name="inserted",
  )
  let extract_val = builder.createExtractValue(insert_val, 1, name="extracted")

  // Add loaded values and return
  let sum1 = builder.createAdd(loaded_array, loaded_struct, name="sum1")
  let sum2 = builder.createAdd(sum1, extract_val, name="sum2")
  let _ = builder.createRet(sum2)
  let expect =
    #|define i32 @aggregate_stack_test() {
    #|entry:
    #|  %array_temp = alloca [3 x i32], align 4
    #|  %struct_temp = alloca { i32, i32 }, align 8
    #|  %array_elem = getelementptr inbounds [3 x i32], ptr %array_temp, i32 0, i32 1
    #|  %struct_elem = getelementptr inbounds { i32, i32 }, ptr %struct_temp, i32 0, i32 1
    #|  store i32 42, ptr %array_elem, align 4
    #|  store i32 24, ptr %struct_elem, align 4
    #|  %loaded_array = load i32, ptr %array_elem, align 4
    #|  %loaded_struct = load i32, ptr %struct_elem, align 4
    #|  %sum1 = add i32 %loaded_array, %loaded_struct
    #|  %sum2 = add i32 %sum1, 20
    #|  ret i32 %sum2
    #|}
    #|
  inspect(fval, content=expect)

  // Test GEP with wrong pointer type
  assert_true(
    (try? builder.createGEP(val42, array_ty, [zero, one]))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // Test GEP with non-integer index
  let f32_val = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createGEP(array_alloca, array_ty, [zero, f32_val]))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // Test extractvalue with wrong index - may not be checked
  assert_true(
    (try? builder.createExtractValue(struct_val, 5))
    is Err(BuilderError::InValidArgument(_)),
  )
}

///|
test "Simple Heap Memory Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let void_ty = ctx.getVoidTy()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty])
  let fval = mod.addFunction(fty, "heap_test")
  let bb = fval.appendBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  builder.setInsertPoint(bb)

  // Test malloc
  let malloc = builder.createMalloc(i32_ty, name="heap_ptr")

  // Test store to heap memory
  let _ = builder.createStore(arg0, malloc)

  // Test load from heap memory
  let load = builder.createLoad(i32_ty, malloc, name="heap_loaded")

  // Test free
  let _ = builder.createFree(malloc)

  // Return loaded value
  let _ = builder.createRet(load)
  let expect =
    #|define i32 @heap_test(i32 %0) {
    #|entry:
    #|  %heap_ptr = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i32))
    #|  store i32 %0, ptr %heap_ptr, align 4
    #|  %heap_loaded = load i32, ptr %heap_ptr, align 4
    #|  tail call void @free(ptr %heap_ptr)
    #|  ret i32 %heap_loaded
    #|}
    #|
  inspect(fval, content=expect)

  // Test malloc with abstract type (should fail)
  assert_true(
    (try? builder.createMalloc(void_ty)) is Err(BuilderError::ValueTypeError(_)),
  )

  // Test free with non-pointer
  let i32_val = ctx.getConstInt32(42)
  assert_true(
    (try? builder.createFree(i32_val)) is Err(BuilderError::ValueTypeError(_)),
  )
}

///|
test "Aggreagate Heap Memory Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let array_ty = ctx.getArrayType(i32_ty, 4)
  let struct_ty = ctx.getStructType([i32_ty, i32_ty, i32_ty])
  let fty = ctx.getFunctionType(i32_ty, [])
  let fval = mod.addFunction(fty, "aggregate_heap_test")
  let bb = fval.appendBasicBlock(name="entry")
  builder.setInsertPoint(bb)

  // Test malloc with array type
  let array_malloc = builder.createMalloc(array_ty, name="heap_array")

  // Test malloc with struct type
  let struct_malloc = builder.createMalloc(struct_ty, name="heap_struct")

  // Test GEP with heap-allocated array
  let zero = ctx.getConstInt32(0)
  let one = ctx.getConstInt32(1)
  let two = ctx.getConstInt32(2)
  let array_gep = builder.createGEP(
    array_malloc,
    array_ty,
    [zero, two],
    name="heap_array_elem",
    inbounds=true,
  )

  // Test GEP with heap-allocated struct
  let struct_gep = builder.createGEP(
    struct_malloc,
    struct_ty,
    [zero, one],
    name="heap_struct_elem",
    inbounds=true,
  )

  // Store values through heap GEP
  let val100 = ctx.getConstInt32(100)
  let val200 = ctx.getConstInt32(200)
  let _ = builder.createStore(val100, array_gep)
  let _ = builder.createStore(val200, struct_gep)

  // Load values through heap GEP
  let loaded_array = builder.createLoad(
    i32_ty,
    array_gep,
    name="loaded_heap_array",
  )
  let loaded_struct = builder.createLoad(
    i32_ty,
    struct_gep,
    name="loaded_heap_struct",
  )

  // Test insertvalue and extractvalue with struct constants
  let struct_const = ctx.getConstStruct([
    ctx.getConstInt32(30),
    ctx.getConstInt32(40),
    ctx.getConstInt32(50),
  ])
  let insert_val = builder.createInsertValue(
    struct_const,
    val100,
    1,
    name="heap_inserted",
  )
  let extract_val = builder.createExtractValue(
    insert_val,
    2,
    name="heap_extracted",
  )

  // Memory operations
  let size_64 = ctx.getConstInt64(16)
  let byte_val = ctx.getConstInt8(0)

  // Test memset
  let _ = builder.createMemSet(array_malloc, byte_val, size_64, 4)

  // Test memcpy
  let _ = builder.createMemCpy(struct_malloc, 4, array_malloc, 4, size_64)

  // Calculate result
  let sum1 = builder.createAdd(loaded_array, loaded_struct, name="heap_sum1")
  let sum2 = builder.createAdd(sum1, extract_val, name="heap_sum2")

  // Free memory
  let _ = builder.createFree(array_malloc)
  let _ = builder.createFree(struct_malloc)

  // Return result
  let _ = builder.createRet(sum2)
  let expect =
    #|define i32 @aggregate_heap_test() {
    #|entry:
    #|  %heap_array = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr ([4 x i32], ptr null, i32 1) to i32))
    #|  %heap_struct = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr ({ i32, i32, i32 }, ptr null, i32 1) to i32))
    #|  %heap_array_elem = getelementptr inbounds [4 x i32], ptr %heap_array, i32 0, i32 2
    #|  %heap_struct_elem = getelementptr inbounds { i32, i32, i32 }, ptr %heap_struct, i32 0, i32 1
    #|  store i32 100, ptr %heap_array_elem, align 4
    #|  store i32 200, ptr %heap_struct_elem, align 4
    #|  %loaded_heap_array = load i32, ptr %heap_array_elem, align 4
    #|  %loaded_heap_struct = load i32, ptr %heap_struct_elem, align 4
    #|  call void @llvm.memset.p0.i64(ptr align 4 %heap_array, i8 0, i64 16, i1 false)
    #|  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %heap_struct, ptr align 4 %heap_array, i64 16, i1 false)
    #|  %heap_sum1 = add i32 %loaded_heap_array, %loaded_heap_struct
    #|  %heap_sum2 = add i32 %heap_sum1, 50
    #|  tail call void @free(ptr %heap_array)
    #|  tail call void @free(ptr %heap_struct)
    #|  ret i32 %heap_sum2
    #|}
    #|
  inspect(fval, content=expect)

  // Error tests - some may not be checked in current implementation
  let i32_val = ctx.getConstInt32(42)

  // Test memset with wrong dst type - may not be checked
  assert_true(
    (try? builder.createMemSet(i32_val, byte_val, size_64, 4))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // Test memcpy with wrong src type - may not be checked
  assert_true(
    (try? builder.createMemCpy(struct_malloc, 4, i32_val, 4, size_64))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // Test insertvalue with wrong type - may not be checked
  assert_true(
    (try? builder.createInsertValue(i32_val, val100, 0))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // Test extractvalue from non-aggregate - may not be checked
  assert_true(
    (try? builder.createExtractValue(i32_val, 0))
    is Err(BuilderError::ValueTypeError(_)),
  )
}
