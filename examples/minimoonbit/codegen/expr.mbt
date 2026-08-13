///|
///
/// 注意这里的expr_codegen的返回值是Option[&@llvm.Value]
/// 对于Unit类型的表达式，应当返回None做特殊处理。
///
/// 对于像let a: Unit = (); 这种表达式，可以考虑把a的值设为null指针，
/// 使用llvm_ctx.getConstPointerNull(llvm_ctx.getPtrTy())
fn Context::expr_codegen(
  self : Self,
  expr : @knf.KnfExpr,
) -> &@llvm.Value? raise {
  match expr {
    Unit => None
    Int(i) => (self.llvm_ctx.getConstInt32(i) : &@llvm.Value) |> Some
    Int64(i) => self.llvm_ctx.getConstInt64(i) |> Some
    UInt(i) =>
      (self.llvm_ctx.getConstInt32(i.reinterpret_as_int()) : &@llvm.Value)
      |> Some
    UInt64(i) => self.llvm_ctx.getConstInt64(i.reinterpret_as_int64()) |> Some
    Bool(true) => self.llvm_ctx.getConstTrue() |> Some
    Bool(false) => self.llvm_ctx.getConstFalse() |> Some
    Double(d) => self.llvm_ctx.getConstDouble(d) |> Some
    Float(f) => self.llvm_ctx.getConstFloat(Float::from_double(f)) |> Some
    Char(c) => self.llvm_ctx.getConstInt8(c.to_int()) |> Some
    // if name is a top function, we need to make a closure wrapper
    Ident(name) if self.is_top_level_function(name) =>
      Some(self.generate_top_level_function_closure(name))
    Ident(name) => self.get_value_by_name_or_load(name) |> Some
    String(s) => {
      // Create global string constant
      let str_ptr = self.builder.createGlobalString(
        s,
        name="str_lit_\{self.str_cnt}",
      )
      self.str_cnt += 1
      // Call __builtin_create_string to create MoonBitStr
      let create_string_func = self.get_builtin_function(
        "__builtin_create_string",
      )
      let moonbit_str = self.builder.createCall(create_string_func, [str_ptr])
      Some(moonbit_str)
    }
    Binary(bin_op, left_name, right_name) => {
      let lhs_value = self.get_value_by_name_or_load(left_name)
      let rhs_value = self.get_value_by_name_or_load(right_name)
      let is_fp_ty = lhs_value.getType().isIEEELikeFPTy()

      // For shift right, check if left operand is unsigned
      let is_unsigned = match self.get_knf_type_by_name(left_name) {
        Some(UInt) | Some(UInt64) => true
        _ => false
      }
      let v = match (bin_op, is_fp_ty) {
        (Add, false) => self.builder.createAdd(lhs_value, rhs_value)
        (Add, true) => self.builder.createFAdd(lhs_value, rhs_value)
        (Sub, false) => self.builder.createSub(lhs_value, rhs_value)
        (Sub, true) => self.builder.createFSub(lhs_value, rhs_value)
        (Mul, false) => self.builder.createMul(lhs_value, rhs_value)
        (Mul, true) => self.builder.createFMul(lhs_value, rhs_value)
        (Div, false) =>
          // Use unsigned division for unsigned types
          if is_unsigned {
            self.builder.createUDiv(lhs_value, rhs_value)
          } else {
            self.builder.createSDiv(lhs_value, rhs_value)
          }
        (Div, true) => self.builder.createFDiv(lhs_value, rhs_value)
        (Mod, false) =>
          // Use unsigned remainder for unsigned types
          if is_unsigned {
            self.builder.createURem(lhs_value, rhs_value)
          } else {
            self.builder.createSRem(lhs_value, rhs_value)
          }
        (Mod, true) => self.builder.createFRem(lhs_value, rhs_value)
        (Eq, false) => self.builder.createICmpEQ(lhs_value, rhs_value)
        (Eq, true) => self.builder.createFCmpOEQ(lhs_value, rhs_value)
        (NE, false) => self.builder.createICmpNE(lhs_value, rhs_value)
        (NE, true) => self.builder.createFCmpONE(lhs_value, rhs_value)
        (LT, false) =>
          // Use unsigned comparison for unsigned types
          if is_unsigned {
            self.builder.createICmpULT(lhs_value, rhs_value)
          } else {
            self.builder.createICmpSLT(lhs_value, rhs_value)
          }
        (LT, true) => self.builder.createFCmpOLT(lhs_value, rhs_value)
        (LE, false) =>
          // Use unsigned comparison for unsigned types
          if is_unsigned {
            self.builder.createICmpULE(lhs_value, rhs_value)
          } else {
            self.builder.createICmpSLE(lhs_value, rhs_value)
          }
        (LE, true) => self.builder.createFCmpOLE(lhs_value, rhs_value)
        (GT, false) =>
          // Use unsigned comparison for unsigned types
          if is_unsigned {
            self.builder.createICmpUGT(lhs_value, rhs_value)
          } else {
            self.builder.createICmpSGT(lhs_value, rhs_value)
          }
        (GT, true) => self.builder.createFCmpOGT(lhs_value, rhs_value)
        (GE, false) =>
          // Use unsigned comparison for unsigned types
          if is_unsigned {
            self.builder.createICmpUGE(lhs_value, rhs_value)
          } else {
            self.builder.createICmpSGE(lhs_value, rhs_value)
          }
        (GE, true) => self.builder.createFCmpOGE(lhs_value, rhs_value)
        (And, false) => self.builder.createAnd(lhs_value, rhs_value)
        (Or, false) => self.builder.createOr(lhs_value, rhs_value)
        (BitAnd, false) => self.builder.createAnd(lhs_value, rhs_value)
        (BitOr, false) => self.builder.createOr(lhs_value, rhs_value)
        (ShiftLeft, false) => self.builder.createShl(lhs_value, rhs_value)
        (ShiftRight, false) =>
          // Use logical shift for unsigned types, arithmetic shift for signed types
          if is_unsigned {
            self.builder.createLShr(lhs_value, rhs_value)
          } else {
            self.builder.createAShr(lhs_value, rhs_value)
          }
        (op, _) =>
          raise CodegenError(
            "Unsupported binary operation \{op} in codegen, type is \{lhs_value.getType()}",
          )
      }
      Some(v)
    }
    Neg(name) => {
      let value = self.get_value_by_name_or_load(name)
      guard self.get_knf_type_by_name(name) is Some(operand_type) else {
        raise CodegenError(
          "Failed to get KNF type for negation operand \{name}",
        )
      }
      let v = match operand_type {
        Int => self.builder.createSub(self.llvm_ctx.getConstInt32(0), value)
        Int64 => self.builder.createSub(self.llvm_ctx.getConstInt64(0L), value)
        Float | Double => self.builder.createFNeg(value)
        _ =>
          raise CodegenError(
            "Unsupported negation operand type \{operand_type}",
          )
      }
      Some(v)
    }
    Not(name) => {
      let value = self.get_value_by_name_or_load(name)
      let one = self.llvm_ctx.getConstTrue()
      let v = self.builder.createXor(one, value)
      Some(v)
    }
    // Use `make_int_array`, 
    //     `make_double_array`, 
    //     `make_bool_array`, or
    //     `make_ptr_array`
    ArrayMake(size_name, init_name) => {
      // For top-level functions, we need to create a closure wrapper first
      let init_value : &@llvm.Value = if self.is_top_level_function(init_name) {
        self.generate_top_level_function_closure(init_name)
      } else {
        self.get_value_by_name_or_load(init_name)
      }
      let size_value = self.get_value_by_name_or_load(size_name)
      guard self.get_knf_type_by_name(init_name) is Some(init_knf_ty) else {
        raise CodegenError(
          "Failed to get KNF type by name \{init_name} for array init value",
        )
      }
      let v = match init_knf_ty {
        Int => {
          let make_int_array_func = self.get_builtin_function("make_int_array")
          self.builder.createCall(make_int_array_func, [size_value, init_value])
        }
        Int64 => {
          let make_int64_array_func = self.get_builtin_function(
            "make_int64_array",
          )
          self.builder.createCall(make_int64_array_func, [
            size_value, init_value,
          ])
        }
        UInt => {
          let make_uint_array_func = self.get_builtin_function(
            "make_uint_array",
          )
          self.builder.createCall(make_uint_array_func, [size_value, init_value])
        }
        UInt64 => {
          let make_uint64_array_func = self.get_builtin_function(
            "make_uint64_array",
          )
          self.builder.createCall(make_uint64_array_func, [
            size_value, init_value,
          ])
        }
        Bool => {
          let make_bool_array_func = self.get_builtin_function(
            "make_bool_array",
          )
          self.builder.createCall(make_bool_array_func, [size_value, init_value])
        }
        Double => {
          let make_double_array_func = self.get_builtin_function(
            "make_double_array",
          )
          self.builder.createCall(make_double_array_func, [
            size_value, init_value,
          ])
        }
        Float => {
          let make_float_array_func = self.get_builtin_function(
            "make_float_array",
          )
          self.builder.createCall(make_float_array_func, [
            size_value, init_value,
          ])
        }
        Char => {
          let make_char_array_func = self.get_builtin_function(
            "make_char_array",
          )
          self.builder.createCall(make_char_array_func, [size_value, init_value])
        }
        _ => {
          // For all other types (functions, structs, tuples, etc.), use make_ptr_array
          let make_ptr_array_func = self.get_builtin_function("make_ptr_array")
          self.builder.createCall(make_ptr_array_func, [size_value, init_value])
        }
      }
      Some(v)
    }
    ArrayAccess(arr_name, idx_name) => {
      let array_value = self.get_value_by_name_or_load(arr_name)
      let index_value = self.get_value_by_name_or_load(idx_name)
      guard self.get_knf_type_by_name(arr_name) is Some(array_knf_type) else {
        raise CodegenError(
          "Failed to get KNF type by name \{arr_name} for array access",
        )
      }
      match array_knf_type {
        Array(Int) => {
          let array_int_get = self.get_builtin_function("array_int_get")
          let v = self.builder.createCall(array_int_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(Int64) => {
          let array_int64_get = self.get_builtin_function("array_int64_get")
          let v = self.builder.createCall(array_int64_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(UInt) => {
          let array_uint_get = self.get_builtin_function("array_uint_get")
          let v = self.builder.createCall(array_uint_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(UInt64) => {
          let array_uint64_get = self.get_builtin_function("array_uint64_get")
          let v = self.builder.createCall(array_uint64_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(Bool) => {
          let array_bool_get = self.get_builtin_function("array_bool_get")
          let v = self.builder.createCall(array_bool_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(Double) => {
          let array_double_get = self.get_builtin_function("array_double_get")
          let v = self.builder.createCall(array_double_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(Float) => {
          let array_float_get = self.get_builtin_function("array_float_get")
          let v = self.builder.createCall(array_float_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(Char) => {
          let array_char_get = self.get_builtin_function("array_char_get")
          let v = self.builder.createCall(array_char_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        Array(_) => {
          let array_ptr_get = self.get_builtin_function("array_ptr_get")
          let v = self.builder.createCall(array_ptr_get, [
            array_value, index_value,
          ])
          Some(v)
        }
        String => {
          // String array access returns Char
          let get_char_func = self.get_builtin_function(
            "__builtin_get_char_in_string",
          )
          let v = self.builder.createCall(get_char_func, [
            array_value, index_value,
          ])
          Some(v)
        }
        _ => raise CodegenError("Unsupported array element type in codegen")
      }
    }
    Block(block) => self.block_codegen(block)
    If(cond, then_block, else_block) =>
      self.if_codegen(cond, then_block, else_block)
    FieldAccess(struct_name, field_str) => {
      let struct_value = self.get_value_by_name_or_load(struct_name)
      guard self.get_knf_type_by_name(struct_name) is Some(struct_knf_type) else {
        raise CodegenError(
          "Failed to get KNF type by name \{struct_name} for field access",
        )
      }
      guard struct_knf_type is Struct(struct_name_str) else {
        raise CodegenError("Field access requires a struct value")
      }
      guard self.knf_struct_types.get(struct_name_str) is Some(knf_struct_def) else {
        raise CodegenError(
          "Failed to get KNF struct definition for \{struct_name_str}",
        )
      }
      guard self.struct_types.get(struct_name_str) is Some(struct_ty) else {
        raise CodegenError(
          "Failed to get LLVM struct type for \{struct_name_str}",
        )
      }
      guard knf_struct_def.get_field_index(field_str) is Some(field_index) else {
        raise CodegenError(
          "Failed to get field index for field \{field_str} in struct \{struct_name_str}",
        )
      }
      let zero = self.llvm_ctx.getConstInt32(0)
      let field_index_val = self.llvm_ctx.getConstInt32(field_index)
      let field_ptr = self.builder.createGEP(struct_value, struct_ty, [
        zero, field_index_val,
      ])
      let (_, _, field_ty) = knf_struct_def.fields[field_index]
      let field_llvm_ty = self.type_codegen_storage(field_ty)
      let v = self.builder.createLoad(field_llvm_ty, field_ptr)
      Some(v)
    }
    // use `make_int_array`
    ArrayLiteral(Int, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_int_array_func = self.get_builtin_function("make_int_array")
      let init_value = self.llvm_ctx.getConstInt32(0)
      let v = self.builder.createCall(make_int_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_int_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_int64_array`
    ArrayLiteral(Int64, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_int64_array_func = self.get_builtin_function("make_int64_array")
      let init_value = self.llvm_ctx.getConstInt64(0L)
      let v = self.builder.createCall(make_int64_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_int64_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_uint_array`
    ArrayLiteral(UInt, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_uint_array_func = self.get_builtin_function("make_uint_array")
      let init_value = self.llvm_ctx.getConstInt32(0)
      let v = self.builder.createCall(make_uint_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_uint_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_uint64_array`
    ArrayLiteral(UInt64, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_uint64_array_func = self.get_builtin_function(
        "make_uint64_array",
      )
      let init_value = self.llvm_ctx.getConstInt64(0L)
      let v = self.builder.createCall(make_uint64_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_uint64_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_bool_array`
    ArrayLiteral(Bool, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_bool_array_func = self.get_builtin_function("make_bool_array")
      let init_value = self.llvm_ctx.getConstFalse()
      let v = self.builder.createCall(make_bool_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_bool_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_double_array`
    ArrayLiteral(Double, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_double_array_func = self.get_builtin_function(
        "make_double_array",
      )
      let init_value = self.llvm_ctx.getConstDouble(0.0)
      let v = self.builder.createCall(make_double_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_double_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_float_array`
    ArrayLiteral(Float, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_float_array_func = self.get_builtin_function("make_float_array")
      let init_value = self.llvm_ctx.getConstFloat(0.0)
      let v = self.builder.createCall(make_float_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_float_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_char_array`
    ArrayLiteral(Char, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_char_array_func = self.get_builtin_function("make_char_array")
      let init_value = self.llvm_ctx.getConstInt8(0)
      let v = self.builder.createCall(make_char_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_char_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    // use `make_ptr_array`
    ArrayLiteral(_, elements) => {
      let elem_values = elements.map(e => self.get_value_by_name_or_load(e))
      let array_size = self.llvm_ctx.getConstInt32(elem_values.length())
      let make_ptr_array_func = self.get_builtin_function("make_ptr_array")
      let init_value = self.llvm_ctx.getConstPointerNull(
        self.llvm_ctx.getPtrTy(),
      )
      let v = self.builder.createCall(make_ptr_array_func, [
        array_size, init_value,
      ])
      let array_put = self.get_builtin_function("array_ptr_put")
      for i, elem_value in elem_values {
        let index_value = self.llvm_ctx.getConstInt32(i)
        let _ = self.builder.createCall(array_put, [v, index_value, elem_value])
      }
      Some(v)
    }
    CreateStruct(struct_name, field_inits) => {
      guard self.knf_struct_types.get(struct_name) is Some(knf_struct_def) else {
        raise CodegenError(
          "Failed to get KNF struct definition for \{struct_name}",
        )
      }
      guard self.struct_types.get(struct_name) is Some(struct_ty) else {
        raise CodegenError("Failed to get LLVM struct type for \{struct_name}")
      }
      let struct_size = self.type_alloc_size(struct_ty)
      let struct_size = self.llvm_ctx.getConstInt32(struct_size)
      let malloc_func = self.get_builtin_function("moonbit_malloc")
      let struct_ptr = self.builder.createCall(malloc_func, [struct_size])
      for field_init in field_inits {
        let (field_name, field_value_name) = field_init
        guard knf_struct_def.get_field_index(field_name) is Some(field_index) else {
          raise CodegenError(
            "Failed to get field index for field \{field_name} in struct \{struct_name}",
          )
        }
        let field_value = self.get_value_by_name_or_load(field_value_name)
        let zero = self.llvm_ctx.getConstInt32(0)
        let field_index_val = self.llvm_ctx.getConstInt32(field_index)
        let field_ptr = self.builder.createGEP(struct_ptr, struct_ty, [
          zero, field_index_val,
        ])
        let _ = self.builder.createStore(field_value, field_ptr)
      }
      Some(struct_ptr)
    }
    TupleLiteral(elem_names) => {
      let elem_values = elem_names.map(e => self.get_value_by_name_or_load(e))
      let tuple_ty = self.llvm_ctx.getStructType(
        elem_values.map(v => v.getType()),
      )
      let struct_size = self.type_alloc_size(tuple_ty)
      let struct_size = self.llvm_ctx.getConstInt32(struct_size)
      let malloc_func = self.get_builtin_function("moonbit_malloc")
      let tuple_ptr = self.builder.createCall(malloc_func, [struct_size])
      for i, elem_value in elem_values {
        let zero = self.llvm_ctx.getConstInt32(0)
        let field_index_val = self.llvm_ctx.getConstInt32(i)
        let field_ptr = self.builder.createGEP(tuple_ptr, tuple_ty, [
          zero, field_index_val,
        ])
        let _ = self.builder.createStore(elem_value, field_ptr)
      }
      Some(tuple_ptr)
    }
    TupleAccess(tuple_name, index) => {
      let tuple_value = self.get_value_by_name_or_load(tuple_name)
      guard self.get_knf_type_by_name(tuple_name) is Some(tuple_knf_type) else {
        raise CodegenError(
          "Failed to get KNF type by name \{tuple_name} for tuple access",
        )
      }
      let tuple_ty = self.type_codegen_concrete(tuple_knf_type)
      guard tuple_knf_type is Tuple(elem_types) else {
        raise CodegenError("Tuple access requires a tuple value")
      }
      guard elem_types.get(index) is Some(elem_type) else {
        raise CodegenError(
          "Tuple index \{index} out of bounds for tuple type \{tuple_knf_type}",
        )
      }
      let elem_llvm_type = self.type_codegen_storage(elem_type)
      let zero = self.llvm_ctx.getConstInt32(0)
      let index_val = self.llvm_ctx.getConstInt32(index)
      let elem_ptr = self.builder.createGEP(tuple_value, tuple_ty, [
        zero, index_val,
      ])
      let v = self.builder.createLoad(elem_llvm_type, elem_ptr)
      Some(v)
    }
    // Top level functions are now called directly without closure environment pointer
    Call(fname, arg_names) if self.is_top_level_function(fname) => {
      guard self.functions.get(fname.to_string()) is Some(func_value) else {
        raise CodegenError(
          "Failed to get function value for top-level function \{fname}",
        )
      }
      let arg_values = arg_names.map(n => self.get_value_by_name_or_load(n))
      let v = self.builder.createCall(func_value, arg_values)
      if v.getType().asTypeEnum() is VoidType(_) {
        None
      } else {
        Some(v)
      }
    }
    // In this case, fname is a closure struct, the first field is the function pointer
    Call(fname, arg_names) if self.is_local_name(fname) => {
      let ptrty = self.llvm_ctx.getPtrTy()
      guard self.get_knf_type_by_name(fname) is Some(fname_knf_type) else {
        raise CodegenError(
          "Failed to get KNF type by name \{fname} for closure call",
        )
      }
      guard fname_knf_type is Function(arg_types, ret_ty) else {
        raise CodegenError("Expected function type for closure call")
      }
      let llvm_arg_types : Array[&@llvm.Type] = [ptrty] // first arg is closure struct ptr
      for t in arg_types {
        let llvm_ty = self.type_codegen_storage(t)
        llvm_arg_types.push(llvm_ty)
      }
      let ret_ty = self.type_codegen_opaque(ret_ty)
      let func_ty = self.llvm_ctx.getFunctionType(ret_ty, llvm_arg_types)
      let closure_struct_value = self.get_value_by_name_or_load(fname)
      let zero = self.llvm_ctx.getConstInt32(0)
      let closure_struct_ty = self.llvm_ctx.getStructType([ptrty])
      let func_ptr_ptr = self.builder.createGEP(
        closure_struct_value,
        closure_struct_ty,
        [zero, zero],
      )
      let func_ptr = self.builder.createLoad(ptrty, func_ptr_ptr)
      let arg_values = arg_names.map(n => self.get_value_by_name_or_load(n))
      let all_args : Array[&@llvm.Value] = []
      all_args.push(closure_struct_value)
      all_args.append(arg_values)
      let v = self.builder.createCallPtr(func_ptr, func_ty, all_args)
      if v.getType().asTypeEnum() is VoidType(_) {
        None
      } else {
        Some(v)
      }
    }
    // For extern function calls, just call directly
    Call(fname, arg_names) if self.is_extern_name(fname) => {
      let func_value = self.get_extern_function(fname.to_string())
      let arg_values = arg_names.map(n => self.get_value_by_name_or_load(n))
      let v = self.builder.createCall(func_value, arg_values)
      if v.getType().asTypeEnum() is VoidType(_) {
        None
      } else {
        Some(v)
      }
    }
    Call(fname, arg_names) if self.is_builtin_name(fname) => {
      let func_value = self.get_builtin_function(fname.to_string())
      let arg_values = arg_names.map(n => self.get_value_by_name_or_load(n))
      let v = self.builder.createCall(func_value, arg_values)
      if v.getType().asTypeEnum() is VoidType(_) {
        None
      } else {
        Some(v)
      }
    }
    Cast(target_ty, source_name) => {
      let source_value = self.get_value_by_name_or_load(source_name)
      guard self.get_knf_type_by_name(source_name) is Some(source_ty) else {
        raise CodegenError(
          "Failed to get KNF type for cast source: \{source_name}",
        )
      }
      let v = match (source_ty, target_ty) {
        // Int conversions
        (Int, Int64) => {
          let int64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createSExt(source_value, int64_ty)
        }
        (Int, Float) => {
          let float_ty = self.llvm_ctx.getFloatTy()
          self.builder.createSIToFP(source_value, float_ty)
        }
        (Int, Double) => {
          let double_ty = self.llvm_ctx.getDoubleTy()
          self.builder.createSIToFP(source_value, double_ty)
        }
        // Int64 conversions
        (Int64, Int) => {
          let int_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createTrunc(source_value, int_ty)
        }
        (Int64, Float) => {
          let float_ty = self.llvm_ctx.getFloatTy()
          self.builder.createSIToFP(source_value, float_ty)
        }
        (Int64, Double) => {
          let double_ty = self.llvm_ctx.getDoubleTy()
          self.builder.createSIToFP(source_value, double_ty)
        }
        // UInt conversions
        (UInt, Int) => source_value // Same bitwise representation
        (UInt, Int64) => {
          let int64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createZExt(source_value, int64_ty)
        }
        (UInt, UInt64) => {
          let uint64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createZExt(source_value, uint64_ty)
        }
        (UInt, Float) => {
          let float_ty = self.llvm_ctx.getFloatTy()
          self.builder.createUIToFP(source_value, float_ty)
        }
        (UInt, Double) => {
          let double_ty = self.llvm_ctx.getDoubleTy()
          self.builder.createUIToFP(source_value, double_ty)
        }
        // UInt64 conversions
        (UInt64, Int) => {
          let int_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createTrunc(source_value, int_ty)
        }
        (UInt64, Int64) => source_value // Same bitwise representation
        (UInt64, UInt) => {
          let uint_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createTrunc(source_value, uint_ty)
        }
        (UInt64, Float) => {
          let float_ty = self.llvm_ctx.getFloatTy()
          self.builder.createUIToFP(source_value, float_ty)
        }
        (UInt64, Double) => {
          let double_ty = self.llvm_ctx.getDoubleTy()
          self.builder.createUIToFP(source_value, double_ty)
        }
        // Conversions from Int to UInt/UInt64
        (Int, UInt) => source_value // Same bitwise representation
        (Int, UInt64) => {
          let uint64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createSExt(source_value, uint64_ty)
        }
        // Conversions from Int64 to UInt/UInt64
        (Int64, UInt) => {
          let uint_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createTrunc(source_value, uint_ty)
        }
        (Int64, UInt64) => source_value // Same bitwise representation
        // Float conversions
        (Float, Int) => {
          let int_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createFPToSI(source_value, int_ty)
        }
        (Float, Int64) => {
          let int64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createFPToSI(source_value, int64_ty)
        }
        (Float, UInt) => {
          let uint_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createFPToUI(source_value, uint_ty)
        }
        (Float, UInt64) => {
          let uint64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createFPToUI(source_value, uint64_ty)
        }
        (Float, Double) => {
          let double_ty = self.llvm_ctx.getDoubleTy()
          self.builder.createFPExt(source_value, double_ty)
        }
        // Double conversions
        (Double, Int) => {
          let int_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createFPToSI(source_value, int_ty)
        }
        (Double, Int64) => {
          let int64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createFPToSI(source_value, int64_ty)
        }
        (Double, UInt) => {
          let uint_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createFPToUI(source_value, uint_ty)
        }
        (Double, UInt64) => {
          let uint64_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createFPToUI(source_value, uint64_ty)
        }
        (Double, Float) => {
          let float_ty = self.llvm_ctx.getFloatTy()
          self.builder.createFPTrunc(source_value, float_ty)
        }
        _ =>
          raise CodegenError(
            "Unsupported cast from \{source_ty} to \{target_ty}",
          )
      }
      Some(v)
    }
    BitCast(target_ty, source_name) => {
      let source_value = self.get_value_by_name_or_load(source_name)
      let v = match target_ty {
        Int => {
          let target_llvm_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createBitCast(source_value, target_llvm_ty)
        }
        Int64 => {
          let target_llvm_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createBitCast(source_value, target_llvm_ty)
        }
        UInt => {
          let target_llvm_ty = self.llvm_ctx.getInt32Ty()
          self.builder.createBitCast(source_value, target_llvm_ty)
        }
        UInt64 => {
          let target_llvm_ty = self.llvm_ctx.getInt64Ty()
          self.builder.createBitCast(source_value, target_llvm_ty)
        }
        Float => {
          let target_llvm_ty = self.llvm_ctx.getFloatTy()
          self.builder.createBitCast(source_value, target_llvm_ty)
        }
        Double => {
          let target_llvm_ty = self.llvm_ctx.getDoubleTy()
          self.builder.createBitCast(source_value, target_llvm_ty)
        }
        _ => raise CodegenError("Unsupported bitcast target type: \{target_ty}")
      }
      Some(v)
    }
    GetUnionTag(union_name) => {
      // Get the tag from the first field (index 0) of the union struct
      let union_value = self.get_value_by_name_or_load(union_name)
      let zero = self.llvm_ctx.getConstInt32(0)

      // Create a struct type with a single i32 field (the tag)
      let tag_struct_ty = self.llvm_ctx.getStructType([
        self.llvm_ctx.getInt32Ty(),
      ])

      // GEP to get pointer to the tag field
      let tag_ptr = self.builder.createGEP(union_value, tag_struct_ty, [
        zero, zero,
      ])

      // Load the tag value
      let tag_value = self.builder.createLoad(
        self.llvm_ctx.getInt32Ty(),
        tag_ptr,
      )
      Some(tag_value)
    }
    ReInterpretUnion(_variant_name, union_name) => {
      // Since unions and structs are both pointers in our representation,
      // we just return the union pointer as is (no actual reinterpretation needed)
      // The type system will ensure correctness
      let union_value = self.get_value_by_name_or_load(union_name)
      Some(union_value)
    }
    Switch(cond_name, cases, default_block) =>
      self.switch_codegen(cond_name, cases, default_block)
    e => raise CodegenError("Unsupported expression in codegen: \{e}")
  }
}
