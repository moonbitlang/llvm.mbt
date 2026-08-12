///|
/// Represents the MiniMoonBit KNF value or lowering context `KnfExtern`.
pub(all) struct KnfExtern {
  /// Stores the `name` component of this KNF value.
  name : String
  /// Stores the `ret_ty` component of this KNF value.
  ret_ty : Type
  /// Stores the `params` component of this KNF value.
  params : Array[Type]
  /// Stores the `ffi_name` component of this KNF value.
  ffi_name : String
}

///|
/// Performs the `extern_to_knf` KNF lowering operation.
pub fn Context::extern_to_knf(
  self : Context,
  ext_func : @typecheck.ExternFunction,
) -> KnfExtern raise KnfTransformError {
  let param_types : Array[Type] = Array::new()
  for param in ext_func.param_list {
    let param_type = self.typekind_to_knf(param.ty)
    param_types.push(param_type)
  }
  let ret_ty = self.typekind_to_knf(ext_func.ret_ty)
  let func_type = Function(param_types, ret_ty)
  let func_name = self.add_new_name(ext_func.fname, func_type)
  KnfExtern::{
    name: func_name.to_string(),
    ret_ty,
    params: param_types,
    ffi_name: ext_func.ffi_name,
  }
}
