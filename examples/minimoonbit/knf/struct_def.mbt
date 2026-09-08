///|
/// Represents the MiniMoonBit KNF value or lowering context `KnfStructDef`.
pub(all) struct KnfStructDef {
  /// Stores the `name` component of this KNF value.
  name : String
  // field name, is_mut, field type
  /// Stores the `fields` component of this KNF value.
  fields : Array[(String, Bool, Type)]
}

///|
/// Performs the `struct_def_to_knf` KNF lowering operation.
pub fn Context::struct_def_to_knf(
  self : Context,
  struct_def : @typecheck.StructDef,
) -> KnfStructDef raise KnfTransformError {
  let knf_fields : Array[(String, Bool, Type)] = Array::Array(capacity=0)
  for field in struct_def.fields {
    let { name, ty, } = field
    let { kind: typekind, mutable: is_mut, } = ty
    let field_type = self.typekind_to_knf(typekind)
    knf_fields.push((name, is_mut, field_type))
  }
  let struct_def = KnfStructDef::{ name: struct_def.name, fields: knf_fields, }
  struct_def
}

///|
/// Performs the `get_field_index` operation on `KnfStructDef`.
pub fn KnfStructDef::get_field_index(
  self : KnfStructDef,
  field_name : String,
) -> Int? {
  for i, f in self.fields {
    let (name, _, _) = f
    if name == field_name {
      return Some(i)
    }
  }
  None
}

///|
/// Formats `KnfStructDef` using MiniMoonBit KNF notation.
pub impl Show for KnfStructDef with fn output(self, logger) {
  let { name, fields, } = self
  logger.write_string("struct \{name} {\n")
  for field in fields {
    let (field_name, is_mut, field_type) = field
    let mutability = if is_mut { "mut " } else { "" }
    logger.write_string("  \{mutability}\{field_name}: \{field_type};\n")
  }
  logger.write_string("}\n")
}
