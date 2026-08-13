///|
fn Context::top_function_codegen(
  self : Self,
  func : @knf.KnfFunction,
) -> @llvm.Function raise {
  let old_name_value = self.name_values
  let old_name_knf_type = self.name_types
  let old_mutable_captured_vars = self.mutable_captured_vars
  self.name_values = Map([])
  self.name_types = Map([])
  self.mutable_captured_vars = Map([])
  guard self.functions.get(func.name) is Some(fval) else {
    raise CodegenError("Function declaration not found for \{func.name}")
  }
  let fty = fval.getType()
  if func.name != "main" {
    for i, param in func.params {
      let (param_name, param_type) = param
      guard fval.getArg(i) is Some(llvm_arg) else {
        raise CodegenError(
          "LLVM argument \{i} not found for function \{func.name}",
        )
      }
      self.name_values.set(param_name, llvm_arg)
      self.name_types.set(param_name, param_type)
    }
  }

  // traverse function body
  let entry_bb = fval.addBasicBlock(name="entry")
  self.builder.setInsertPoint(entry_bb)

  // For main function, initialize global array variables
  // Use a set to track which variables have been initialized to avoid duplicates
  if func.name == "main" {
    let initialized = Map([])
    fn init_global(
      ctx : Context,
      name : String,
      initialized : Map[String, Bool],
    ) -> Unit raise {
      // If already initialized, skip
      if initialized.get(name) is Some(_) {
        return
      }
      // Find the initialization info for this variable
      let mut init_info_opt : (@knf.Name, @knf.Type, @knf.KnfExpr)? = None
      for info in ctx.global_array_inits {
        if info.0.to_string() == name {
          init_info_opt = Some(info)
          break
        }
      }
      guard init_info_opt is Some(init_info) else { // Not a runtime-initialized global, skip
        return
      }
      let (_name, _ty, expr) = init_info

      // First, recursively initialize any dependencies in the expression
      fn collect_deps(expr : @knf.KnfExpr, deps : Array[String]) -> Unit {
        match expr {
          Ident(id) => {
            let id_str = id.to_string()
            // Check if it's a global variable that needs initialization
            if ctx.global_values.get(id_str) is Some(_) &&
              ctx.global_consts.get(id_str) is None(_) {
              deps.push(id_str)
            }
          }
          Binary(_, lhs, rhs) => {
            collect_deps(Ident(lhs), deps)
            collect_deps(Ident(rhs), deps)
          }
          Neg(id) | Not(id) => collect_deps(Ident(id), deps)
          ArrayAccess(arr, idx) => {
            collect_deps(Ident(arr), deps)
            collect_deps(Ident(idx), deps)
          }
          TupleAccess(tuple, _) => collect_deps(Ident(tuple), deps)
          FieldAccess(struct_, _) => collect_deps(Ident(struct_), deps)
          ArrayMake(size, init) => {
            collect_deps(Ident(size), deps)
            collect_deps(Ident(init), deps)
          }
          ArrayLiteral(_, elements) =>
            for elem in elements {
              collect_deps(Ident(elem), deps)
            }
          TupleLiteral(elements) =>
            for elem in elements {
              collect_deps(Ident(elem), deps)
            }
          CreateStruct(_, fields) =>
            for field in fields {
              collect_deps(Ident(field.1), deps)
            }
          If(cond, _, _) => collect_deps(cond, deps)
          Call(closure, args) => {
            collect_deps(Ident(closure), deps)
            for arg in args {
              collect_deps(Ident(arg), deps)
            }
          }
          _ => ()
        }
      }

      let deps : Array[String] = []
      collect_deps(expr, deps)

      // Initialize all dependencies first
      for dep in deps {
        init_global(ctx, dep, initialized)
      }

      // Now initialize this variable
      guard ctx.global_values.get(name) is Some(global_var) else {
        raise CodegenError("Global variable \{name} not found")
      }
      guard ctx.expr_codegen(expr) is Some(value) else {
        raise CodegenError("Global initialization failed for \{name}")
      }
      let _ = ctx.builder.createStore(value, global_var)
      initialized.set(name, true)
    }

    // Initialize all global variables in dependency order
    for init_info in self.global_array_inits {
      let (name, _, _) = init_info
      init_global(self, name.to_string(), initialized)
    }
  }
  let return_value = self.block_contents_codegen(func.body)
  if self.current_block().getTerminator() is None {
    match return_value {
      Some(value) => {
        let _ = self.builder.createRet(value)
      }
      None if fty.getReturnType().asTypeEnum() is VoidType(_) => {
        let _ = self.builder.createRetVoid()
      }
      None =>
        raise CodegenError(
          "Function \{func.name} completed without a return value",
        )
    }
  }

  // Restore old mappings
  self.name_values = old_name_value
  self.name_types = old_name_knf_type
  self.mutable_captured_vars = old_mutable_captured_vars
  fval
}
