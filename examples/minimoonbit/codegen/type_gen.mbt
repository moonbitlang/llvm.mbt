///|
fn Context::type_codegen_opaque(
  self : Context,
  knf_type : @knf.Type,
) -> &@llvm.Type {
  match knf_type {
    Int => (self.llvm_ctx.getInt32Ty() : &@llvm.Type)
    Int64 => self.llvm_ctx.getInt64Ty()
    UInt => self.llvm_ctx.getInt32Ty()
    UInt64 => self.llvm_ctx.getInt64Ty()
    Bool => self.llvm_ctx.getInt1Ty()
    Unit => self.llvm_ctx.getVoidTy()
    Double => self.llvm_ctx.getDoubleTy()
    Float => self.llvm_ctx.getFloatTy()
    Char => self.llvm_ctx.getInt8Ty()
    Array(_) => self.llvm_ctx.getPtrTy()
    String => self.llvm_ctx.getPtrTy()
    Tuple(_) => self.llvm_ctx.getPtrTy()
    Struct(_) => self.llvm_ctx.getPtrTy()
    Union(_) => self.llvm_ctx.getPtrTy()
    Function(_, _) => self.llvm_ctx.getPtrTy()
  }
}

///|
fn Context::type_codegen_storage(
  self : Context,
  knf_type : @knf.Type,
) -> &@llvm.Type {
  match knf_type {
    Unit => (self.llvm_ctx.getPtrTy() : &@llvm.Type)
    _ => self.type_codegen_opaque(knf_type)
  }
}

///|
fn Context::type_codegen_concrete(
  self : Context,
  knf_type : @knf.Type,
) -> &@llvm.Type raise {
  match knf_type {
    Int => (self.llvm_ctx.getInt32Ty() : &@llvm.Type)
    Int64 => self.llvm_ctx.getInt64Ty()
    UInt => self.llvm_ctx.getInt32Ty()
    UInt64 => self.llvm_ctx.getInt64Ty()
    Bool => self.llvm_ctx.getInt1Ty()
    Unit => self.llvm_ctx.getVoidTy()
    Double => self.llvm_ctx.getDoubleTy()
    Float => self.llvm_ctx.getFloatTy()
    Char => self.llvm_ctx.getInt8Ty()
    Array(_) => self.llvm_ctx.getPtrTy()
    String => self.llvm_ctx.getPtrTy()
    Tuple(elem_types) => {
      let llvm_elem_types = elem_types.map(elem_type => {
        self.type_codegen_storage(elem_type)
      })
      self.llvm_ctx.getStructType(llvm_elem_types)
    }
    Struct(struct_name) => {
      guard self.struct_types.get(struct_name) is Some(struct_type) else {
        raise CodegenError("LLVM struct type not found for \{struct_name}")
      }
      struct_type
    }
    Union(_) => self.llvm_ctx.getPtrTy()
    Function(param_types, return_type) => {
      let llvm_param_types = param_types.map(param_type => {
        self.type_codegen_storage(param_type)
      })
      let llvm_return_type = self.type_codegen_opaque(return_type)
      self.llvm_ctx.getFunctionType(llvm_return_type, llvm_param_types)
    }
  }
}

///|
fn Context::collect_extern_func_values(
  self : Context,
  knf_externs : Map[String, @knf.KnfExtern],
) -> Unit raise {
  for fname, ext_func in knf_externs {
    let { params, ret_ty, ffi_name, .. } = ext_func
    let param_types : Array[&@llvm.Type] = []
    for param_type in params {
      let llvm_param_type = self.type_codegen_storage(param_type)
      param_types.push(llvm_param_type)
    }
    let llvm_ret_type = self.type_codegen_opaque(ret_ty)
    let llvm_fty = self.llvm_ctx.getFunctionType(llvm_ret_type, param_types)
    let llvm_func = self.llvm_mod.addFunction(llvm_fty, ffi_name)
    self.extern_funcs.set(fname, llvm_func)
    // Store the KNF function type
    let knf_func_type = @knf.Type::Function(params, ret_ty)
    self.function_types.set(fname, knf_func_type)
  }
}

///|
fn Context::collect_func_values(
  self : Context,
  knf_funcs : Map[String, @knf.KnfFunction],
) -> Unit raise {
  for fname, func in knf_funcs {
    let { params, ret_ty, .. } = func
    let param_types : Array[&@llvm.Type] = []
    // Top level functions no longer need closure environment pointer
    for param in params {
      let (_, param_type) = param
      let llvm_param_type = self.type_codegen_storage(param_type)
      param_types.push(llvm_param_type)
    }
    let llvm_ret_type = self.type_codegen_opaque(ret_ty)
    let llvm_fty = self.llvm_ctx.getFunctionType(llvm_ret_type, param_types)
    let func_real_name = if fname == "main" { "moonbit_main" } else { fname }
    let llvm_func = self.llvm_mod.addFunction(llvm_fty, func_real_name)
    self.functions.set(fname, llvm_func)
    // Store the KNF function type
    let knf_param_types = params.map(p => p.1)
    let knf_func_type = @knf.Type::Function(knf_param_types, ret_ty)
    self.function_types.set(fname, knf_func_type)
  }
}

///|
fn Context::collect_struct_types(
  self : Context,
  knf_structs : Map[String, @knf.KnfStructDef],
) -> Unit raise {
  for sname, knf_struct in knf_structs {
    let field_types : Array[&@llvm.Type] = []
    for field in knf_struct.fields {
      let llvm_field_type = self.type_codegen_storage(field.2)
      field_types.push(llvm_field_type)
    }
    let llvm_sty = self.llvm_ctx.getStructType(field_types, name=sname)
    self.struct_types.set(sname, llvm_sty)
    self.knf_struct_types.set(sname, knf_struct)
  }
}
