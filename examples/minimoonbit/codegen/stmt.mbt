///|
fn Context::stmt_codegen(self : Self, stmt : @knf.KnfStmt) -> Unit raise {
  match stmt {
    Let(name, ty, expr) => self.let_stmt_codegen(name, ty, expr)
    LetMut(name, ty, expr) => self.let_mut_stmt_codegen(name, ty, expr)
    Assign(name, expr) => self.assign_stmt_codegen(name, expr)
    ArrayPut(name, idx, expr) => self.array_put_codegen(name, idx, expr)
    StructFieldSet(name, field, value_name) =>
      self.struct_field_set_codegen(name, field, value_name)
    While(cond, body) => self.while_stmt_codegen(cond, body)
    ExprStmt(expr) => {
      let _ = self.expr_codegen(expr)
    }
    Return(expr) => {
      guard self.expr_codegen(expr) is Some(ret_value) else {
        raise CodegenError(
          "Return expression cannot be void, knf expr is \{expr}",
        )
      }
      let _ = self.builder.createRet(ret_value)
    }
    ReturnUnit => {
      let _ = self.builder.createRetVoid()
    }
    ClosureDef(closure_def) => self.closure_codegen(closure_def)
  }
}

///|
fn Context::let_stmt_codegen(
  self : Self,
  name : @knf.Name,
  ty : @knf.Type,
  expr : @knf.KnfExpr,
) -> Unit raise {
  let value = match self.expr_codegen(expr) {
    Some(v) => v
    None => self.llvm_ctx.getConstPointerNull(self.llvm_ctx.getPtrTy())
  }
  self.name_values.set(name, value)
  self.name_types.set(name, ty)
}

///|
fn Context::let_mut_stmt_codegen(
  self : Self,
  name : @knf.Name,
  ty : @knf.Type,
  expr : @knf.KnfExpr,
) -> Unit raise {
  guard self.expr_codegen(expr) is Some(value) else {
    raise CodegenError("Let mut expression cannot be void")
  }
  let llvmty = self.type_codegen_storage(ty)

  // Always create alloca at the entry block to avoid stack overflow in loops
  let func = self.current_function()

  // Get entry block
  let basic_blocks = func.getBasicBlocks()
  guard basic_blocks.length() > 0 else {
    raise CodegenError("Function has no entry block")
  }
  let entry_block = basic_blocks[0]

  // Save current position
  let saved_block = self.current_block()

  // Switch to entry block and create alloca before the terminator
  // Find the terminator (br, ret, etc.) and insert before it
  let alloca = match entry_block.getTerminator() {
    Some(term) => {
      // Insert before terminator
      self.builder.setInsertPointBefore(term)
      let alloca = self.builder.createAlloca(llvmty)
      self.builder.setInsertPoint(saved_block)
      alloca
    }
    None => {
      // No terminator yet, insert at end
      self.builder.setInsertPoint(entry_block)
      let alloca = self.builder.createAlloca(llvmty)
      self.builder.setInsertPoint(saved_block)
      alloca
    }
  }

  // Now store the initial value at the current position
  let _ = self.builder.createStore(value, alloca)
  self.name_values.set(name, alloca)
  self.name_types.set(name, ty)
}

///|
fn Context::assign_stmt_codegen(
  self : Self,
  name : @knf.Name,
  expr : @knf.KnfExpr,
) -> Unit raise {
  guard self.expr_codegen(expr) is Some(value) else {
    raise CodegenError("Assign expression cannot be void")
  }
  match self.get_value_by_name(name) {
    Some(v) => {
      guard v.getType().asTypeEnum() is PointerType(_) else {
        raise CodegenError(
          "Cannot assign to non-alloca value '\{name}' in codegen",
        )
      }
      let _ = self.builder.createStore(value, v)
    }
    None => raise CodegenError("Identifier \{name} not found in codegen")
  }
}

///|
fn Context::array_put_codegen(
  self : Self,
  name : @knf.Name,
  idx : @knf.Name,
  expr : @knf.KnfExpr,
) -> Unit raise {
  let array_value = self.get_value_by_name_or_load(name)
  let index_value = self.get_value_by_name_or_load(idx)
  guard self.expr_codegen(expr) is Some(elem_value) else {
    raise CodegenError("Array put expression cannot be void")
  }
  guard self.get_knf_type_by_name(name) is Some(arr_knf_type) else {
    raise CodegenError("Array put: cannot find type of array in codegen")
  }
  match arr_knf_type {
    Array(Int) => {
      let array_int_put = self.get_builtin_function("array_int_put")
      let _ = self.builder.createCall(array_int_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(Int64) => {
      let array_int64_put = self.get_builtin_function("array_int64_put")
      let _ = self.builder.createCall(array_int64_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(UInt) => {
      let array_uint_put = self.get_builtin_function("array_uint_put")
      let _ = self.builder.createCall(array_uint_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(UInt64) => {
      let array_uint64_put = self.get_builtin_function("array_uint64_put")
      let _ = self.builder.createCall(array_uint64_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(Bool) => {
      let array_bool_put = self.get_builtin_function("array_bool_put")
      let _ = self.builder.createCall(array_bool_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(Double) => {
      let array_double_put = self.get_builtin_function("array_double_put")
      let _ = self.builder.createCall(array_double_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(Float) => {
      let array_float_put = self.get_builtin_function("array_float_put")
      let _ = self.builder.createCall(array_float_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(Char) => {
      let array_char_put = self.get_builtin_function("array_char_put")
      let _ = self.builder.createCall(array_char_put, [
        array_value, index_value, elem_value,
      ])
    }
    Array(_) => {
      let array_ptr_put = self.get_builtin_function("array_ptr_put")
      let _ = self.builder.createCall(array_ptr_put, [
        array_value, index_value, elem_value,
      ])
    }
    _ => raise CodegenError("Unsupported array element type in codegen")
  }
}

///|
fn Context::struct_field_set_codegen(
  self : Self,
  name : @knf.Name,
  field : String,
  value_name : @knf.Name,
) -> Unit raise {
  let struct_value = self.get_value_by_name_or_load(name)
  guard self.get_knf_type_by_name(name) is Some(struct_knf_type) else {
    raise CodegenError(
      "Struct field set: cannot find type of struct in codegen",
    )
  }
  guard struct_knf_type is Struct(struct_name) else {
    raise CodegenError("Struct field assignment requires a struct value")
  }
  guard self.knf_struct_types.get(struct_name) is Some(knf_struct_def) else {
    raise CodegenError(
      "Struct field set: cannot find struct definition in codegen",
    )
  }
  guard self.struct_types.get(struct_name) is Some(struct_ty) else {
    raise CodegenError(
      "Struct field set: cannot find LLVM struct type in codegen",
    )
  }
  guard knf_struct_def.get_field_index(field) is Some(field_index) else {
    raise CodegenError("Struct field set: cannot find field index in codegen")
  }
  let field_value = self.get_value_by_name_or_load(value_name)
  let zero = self.llvm_ctx.getConstInt32(0)
  let field_index_val = self.llvm_ctx.getConstInt32(field_index)
  let field_ptr = self.builder.createGEP(struct_value, struct_ty, [
    zero, field_index_val,
  ])
  let _ = self.builder.createStore(field_value, field_ptr)
}

///|
fn Context::while_stmt_codegen(
  self : Self,
  cond : @knf.KnfBlock,
  body : @knf.KnfBlock,
) -> Unit raise {
  let function = self.current_function()
  let cond_bb = function.addBasicBlock()
  let body_bb = function.addBasicBlock()
  let merge_bb = function.addBasicBlock()
  let _ = self.builder.createBr(cond_bb)
  // condition block
  self.builder.setInsertPoint(cond_bb)
  let cond_value = self.block_contents_codegen(cond)
  if self.current_block().getTerminator() is Some(_) {
    body_bb.eraseFromParent()
    merge_bb.eraseFromParent()
    return
  }
  guard cond_value is Some(cond_value) else {
    raise CodegenError("While condition block did not produce a value")
  }
  let _ = self.builder.createCondBr(cond_value, body_bb, merge_bb)
  // body block
  self.builder.setInsertPoint(body_bb)
  let _ = self.block_contents_codegen(body)
  if self.current_block().getTerminator() is None {
    let _ = self.builder.createBr(cond_bb)
  }
  // merge block
  self.builder.setInsertPoint(merge_bb)
}
