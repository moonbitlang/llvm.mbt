///|
fn Context::closure_codegen(
  self : Context,
  closure_def : @knf.KnfClosure,
) -> Unit raise {
  let func_value = self.closure_func_codegen(closure_def)
  // Generate closure function
  let captured_vars : Array[(@knf.Name, (@knf.Type, Bool))] = closure_def.captured_vars.to_array()
  let ptrty = self.llvm_ctx.getPtrTy()
  let zero = self.llvm_ctx.getConstInt32(0)

  // Generate closure struct
  let closure_struct_field_types : Array[&@llvm.Type] = []
  // first field: function pointer
  closure_struct_field_types.push(ptrty)
  // following fields: captured variables
  for _, captured_var in captured_vars {
    let (_, (captured_ty, is_mut)) = captured_var
    // For mutable captured variables, store pointer; for immutable, store value
    let captured_llvm_ty = if is_mut {
      (ptrty : &@llvm.Type)
    } else {
      self.type_codegen_storage(captured_ty)
    }
    closure_struct_field_types.push(captured_llvm_ty)
  }
  let closure_struct_ty = self.llvm_ctx.getStructType(
    closure_struct_field_types,
  )
  let mbt_malloc = self.get_builtin_function("moonbit_malloc")
  let closure_size = self.type_alloc_size(closure_struct_ty)
  let closure_size = self.llvm_ctx.getConstInt32(closure_size)
  let closure_ptr = self.builder.createCall(mbt_malloc, [closure_size])
  // Register the closure pointer first (for recursive closures)
  self.name_values.set(closure_def.name, closure_ptr)
  // Also register the closure type
  let param_types : Array[@knf.Type] = closure_def.params.map(fn(p) { p.1 })
  let closure_type = @knf.Type::Function(param_types, closure_def.ret_ty)
  self.name_types.set(closure_def.name, closure_type)
  // set function pointer
  let func_ptr_ptr = self.builder.createGEP(closure_ptr, closure_struct_ty, [
    zero, zero,
  ])
  let _ = self.builder.createStore(func_value, func_ptr_ptr)
  // set captured variables
  for i, captured_var in captured_vars {
    let (captured_name, (_, is_mut)) = captured_var
    // For mutable variables, we need to get the alloca pointer instead of loading the value
    let captured_value = if is_mut {
      // For mutable variables, store the pointer itself
      match self.get_value_by_name(captured_name) {
        Some(v) => v
        None =>
          raise CodegenError(
            "Captured mutable variable \{captured_name} not found",
          )
      }
    } else {
      // For immutable variables, store the value
      self.get_value_by_name_or_load(captured_name)
    }
    let field_index_val = self.llvm_ctx.getConstInt32(i + 1) // +1 for function pointer
    let captured_ptr = self.builder.createGEP(closure_ptr, closure_struct_ty, [
      zero, field_index_val,
    ])
    let _ = self.builder.createStore(captured_value, captured_ptr)
  }
}

///|
fn Context::closure_func_codegen(
  self : Context,
  closure_def : @knf.KnfClosure,
) -> @llvm.Function raise {
  let current_insert_block = self.builder.getInsertBlock()
  let captured_vars : Array[(@knf.Name, (@knf.Type, Bool))] = closure_def.captured_vars.to_array()
  let zero = self.llvm_ctx.getConstInt32(0)

  // Generate closure function declaration
  let ptrty = self.llvm_ctx.getPtrTy()
  let ret_ty = self.type_codegen_opaque(closure_def.ret_ty)
  let arg_types : Array[&@llvm.Type] = []
  // first argument: closure environment pointer
  arg_types.push(ptrty)
  // following arguments: closure parameters
  for param in closure_def.params {
    let (_, param_ty) = param
    //let param_llvm_ty = self.type_codegen_opaque(param_ty)
    let param_llvm_ty = self.type_codegen_storage(param_ty)
    arg_types.push(param_llvm_ty)
  }
  let func_ty = self.llvm_ctx.getFunctionType(ret_ty, arg_types)
  let func_name = closure_def.name.to_string()
  let parent_func_name = self
    .current_function()
    .getName()
    .unwrap_or("anonymous")
  let func_name = "\{parent_func_name}$\{func_name}"
  let func_value = self.llvm_mod.addFunction(func_ty, func_name)

  // Generate closure struct type
  let closure_struct_ty : Array[&@llvm.Type] = []
  closure_struct_ty.push(ptrty) // function pointer
  for _, captured_var in captured_vars {
    let (_, (captured_ty, is_mut)) = captured_var
    // For mutable captured variables, the struct stores pointer; for immutable, stores value
    let captured_llvm_ty = if is_mut {
      (ptrty : &@llvm.Type)
    } else {
      self.type_codegen_storage(captured_ty)
    }
    closure_struct_ty.push(captured_llvm_ty)
  }
  let closure_struct_ty = self.llvm_ctx.getStructType(closure_struct_ty)

  // Generate function body
  let old_name_value = self.name_values
  let old_name_knf_type = self.name_types
  let old_mutable_captured_vars = self.mutable_captured_vars
  self.name_values = Map([])
  self.name_types = Map([])
  self.mutable_captured_vars = Map([])
  let entry_bb = func_value.addBasicBlock(name="entry")
  self.builder.setInsertPoint(entry_bb)
  for i, param in closure_def.params {
    let (param_name, param_type) = param
    guard func_value.getArg(i + 1) is Some(llvm_arg) else {
      raise CodegenError(
        "LLVM argument \{i + 1} not found for closure \{closure_def.name}",
      )
    }
    self.name_values.set(param_name, llvm_arg)
    self.name_types.set(param_name, param_type)
  }
  guard func_value.getArg(0) is Some(func_arg0) else {
    raise CodegenError(
      "Closure environment argument not found for \{closure_def.name}",
    )
  }
  for i, captured_var in captured_vars {
    let (captured_name, (captured_ty, is_mut)) = captured_var
    let field_index_val = self.llvm_ctx.getConstInt32(i + 1) // +1 for function pointer
    let captured_ptr = self.builder.createGEP(func_arg0, closure_struct_ty, [
      zero, field_index_val,
    ])
    if is_mut {
      // For mutable variables, the struct contains the pointer to alloca
      // Load the pointer and register it directly (it's already an alloca pointer)
      let alloca_ptr = self.builder.createLoad(ptrty, captured_ptr)
      self.name_values.set(captured_name, alloca_ptr)
      self.name_types.set(captured_name, captured_ty)
      // Mark this as a mutable captured variable
      self.mutable_captured_vars.set(captured_name, true)
    } else {
      // For immutable variables, load the value
      let captured_value = self.builder.createLoad(
        self.type_codegen_storage(captured_ty),
        captured_ptr,
      )
      self.name_values.set(captured_name, captured_value)
      self.name_types.set(captured_name, captured_ty)
    }
  }
  let return_value = self.block_contents_codegen(closure_def.body)
  if self.current_block().getTerminator() is None {
    match return_value {
      Some(value) => {
        let _ = self.builder.createRet(value)
      }
      None if func_ty.getReturnType().asTypeEnum() is VoidType(_) => {
        let _ = self.builder.createRetVoid()
      }
      None =>
        raise CodegenError(
          "Closure \{closure_def.name} completed without a return value",
        )
    }
  }

  // Restore old mappings
  self.name_values = old_name_value
  self.name_types = old_name_knf_type
  self.mutable_captured_vars = old_mutable_captured_vars
  guard current_insert_block is Some(current_insert_block) else {
    raise CodegenError("Closure definition has no caller insertion block")
  }
  self.builder.setInsertPoint(current_insert_block)
  func_value
}
