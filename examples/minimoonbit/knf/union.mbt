///|
/// Represents the MiniMoonBit KNF value or lowering context `KnfUnion`.
pub(all) struct KnfUnion {
  /// Stores the `name` component of this KNF value.
  name : String
  /// Stores the `variants` component of this KNF value.
  variants : Array[KnfStructDef]
}

///|
///
/// for enum in MiniMoonBit like:
/// 
/// ```mbt skip
/// enum Color {
///   Red
///   RGB(Int, Int, Int)
/// }
/// ```
///
/// In Knf Phase, it will be transformed to:
///
/// ```c
/// struct Color$Red {
///   int tag;
/// };
///
/// struct Color$RGB {
///   int tag;
///   int $0;
///   int $1;
///   int $2;
/// };
///
/// union Color {
///   struct Color$Red Red;
///   struct Color$RGB RGB;
/// }
/// ```
pub fn Context::enum_to_knf(
  self : Context,
  enum_def : @typecheck.EnumDef,
) -> KnfUnion raise KnfTransformError {
  let { name: union_name, enum_fields, } = enum_def
  let knf_variants : Array[KnfStructDef] = Array::Array(capacity=0)
  for enum_field in enum_fields {
    let { name, types, } = enum_field
    let fields : Array[(String, Bool, Type)] = Array::Array(capacity=0)
    fields.push(("tag", false, Type::Int))
    for i, ty in types {
      let field_name = "$\{i}"
      let field_type = self.typekind_to_knf(ty)
      fields.push((field_name, false, field_type))
    }
    let variant = KnfStructDef::{ name: "\{union_name}$\{name}", fields, }
    knf_variants.push(variant)
  }
  let knf_union = KnfUnion::{ name: union_name, variants: knf_variants, }
  knf_union
}
