///|
/// Represents the MiniMoonBit KNF value or lowering context `KnfProgram`.
pub(all) struct KnfProgram {
  /// Stores the `source_file` component of this KNF value.
  source_file : String
  /// Stores the `struct_defs` component of this KNF value.
  struct_defs : Map[String, KnfStructDef]
  /// Stores the `unions` component of this KNF value.
  unions : Map[String, KnfUnion]
  /// Stores the `global_stmts` component of this KNF value.
  global_stmts : Array[KnfStmt]
  /// Stores the `top_lets` component of this KNF value.
  top_lets : Map[String, KnfTopLet]
  /// Stores the `functions` component of this KNF value.
  functions : Map[String, KnfFunction]
  /// Stores the `externs` component of this KNF value.
  externs : Map[String, KnfExtern]
}

///|
/// Formats `KnfProgram` using MiniMoonBit KNF notation.
pub impl Show for KnfProgram with fn output(self, logger) {
  logger.write_string(";; KnfProgram: \{self.source_file}\n\n")
  for _, struct_def in self.struct_defs {
    logger.write_object(struct_def)
    logger.write_char('\n')
  }
  for s in self.global_stmts {
    logger.write_object(s)
    logger.write_char('\n')
  }
  for _, top_let in self.top_lets {
    logger.write_object(top_let)
    logger.write_char('\n')
  }
  for _, func in self.functions {
    logger.write_object(func)
    logger.write_char('\n')
  }
}

///|
/// Performs the `program_to_knf` KNF lowering operation.
pub fn Context::program_to_knf(
  self : Context,
  prog : @typecheck.Program,
) -> KnfProgram raise KnfTransformError {
  let source_file = prog.source_file
  let struct_defs = Map([])
  let unions = Map([])
  let top_lets = Map([])
  let functions = Map([])
  let externs = Map([])

  // Step 1, process all enum definitions
  for enum_name, enum_def in prog.enum_defs {
    let knf_union = self.enum_to_knf(enum_def)
    let union_variant_names = Array::new()
    unions.set(enum_name, knf_union)
    for variant in knf_union.variants {
      struct_defs.set(variant.name, variant)
      self.struct_defs.set(variant.name, variant)
      union_variant_names.push(variant.name)
    }
    self.unions.set(enum_name, union_variant_names)
  }

  // Step -2, register all struct definitions
  for sname, struct_def in prog.struct_defs {
    let knf_struct_def = self.struct_def_to_knf(struct_def)
    struct_defs.set(sname, knf_struct_def)
    self.struct_defs.set(sname, knf_struct_def)
  }

  // Step - 3, regiter all extern functions
  for fname, extern_func in prog.extern_funcions {
    let knf_extern = self.extern_to_knf(extern_func)
    externs.set(knf_extern.name, knf_extern)
    self.globals.set(fname, Function(knf_extern.params, knf_extern.ret_ty))
  }

  // Step - 4, register all function signatures in globals
  // so that top_let expressions can reference them
  for _, func in prog.top_functions {
    let param_types = func.param_list.map(p => self.typekind_to_knf(p.ty))
    let ret_ty = self.typekind_to_knf(func.ret_ty)
    // Use func.fname which is the mangled name (e.g., Vec2$$new)
    self.globals.set(func.fname, Function(param_types, ret_ty))
  }

  // Step - 5, process top-level let declarations
  for let_name, top_let in prog.top_lets {
    let knf_top_let = self.top_let_to_knf(top_let)
    top_lets.set(let_name, knf_top_let)
  }

  // Step - 6, process function bodies
  for _, func in prog.top_functions {
    let knf_func = self.top_function_to_knf(func)
    // Use func.fname which is the mangled name (e.g., Vec2$$new)
    functions.set(func.fname, knf_func)
  }
  let global_stmts = self.global_stmts
  KnfProgram::{
    source_file,
    struct_defs,
    unions,
    externs,
    top_lets,
    global_stmts,
    functions,
  }
}

///|
/// Runs the MiniMoonBit KNF operation `knf_transform`.
pub fn knf_transform(
  prog : @typecheck.Program,
) -> KnfProgram raise KnfTransformError {
  let context = Context::new()

  // Builtin print functions
  context.globals.set("__builtin_println_int", Function([Int], Unit))
  context.globals.set("__builtin_println_int64", Function([Int64], Unit))
  context.globals.set("__builtin_println_uint", Function([UInt], Unit))
  context.globals.set("__builtin_println_uint64", Function([UInt64], Unit))
  context.globals.set("__builtin_println_string", Function([String], Unit))
  context.globals.set("__builtin_println_bool", Function([Bool], Unit))
  context.globals.set("__builtin_println_double", Function([Double], Unit))
  context.globals.set("__builtin_println_float", Function([Float], Unit))
  context.globals.set("__builtin_println_char", Function([Char], Unit))
  context.globals.set("__builtin_print_int", Function([Int], Unit))
  context.globals.set("__builtin_print_int64", Function([Int64], Unit))
  context.globals.set("__builtin_print_uint", Function([UInt], Unit))
  context.globals.set("__builtin_print_uint64", Function([UInt64], Unit))
  context.globals.set("__builtin_print_string", Function([String], Unit))
  context.globals.set("__builtin_print_bool", Function([Bool], Unit))
  context.globals.set("__builtin_print_double", Function([Double], Unit))
  context.globals.set("__builtin_print_float", Function([Float], Unit))
  context.globals.set("__builtin_print_char", Function([Char], Unit))

  // Array/String builtin methods
  context.globals.set("get_array_length", Function([Int], Int)) // Takes array, returns length
  context.globals.set("__builtin_get_string_length", Function([String], Int))
  context.globals.set(
    "__builtin_get_char_in_string",
    Function([String, Int], Char),
  )
  context.globals.set("moonbit_string_eq", Function([String, String], Bool))

  // Array push methods
  context.globals.set("array_int_push", Function([Int, Int], Unit))
  context.globals.set("array_int64_push", Function([Int64, Int64], Unit))
  context.globals.set("array_uint_push", Function([UInt, UInt], Unit))
  context.globals.set("array_uint64_push", Function([UInt64, UInt64], Unit))
  context.globals.set("array_double_push", Function([Double, Double], Unit))
  context.globals.set("array_float_push", Function([Float, Float], Unit))
  context.globals.set("array_bool_push", Function([Bool, Bool], Unit))
  context.globals.set("array_char_push", Function([Char, Char], Unit))
  context.globals.set("array_ptr_push", Function([Int, Int], Unit)) // Generic pointer type

  // Type conversion to_string functions
  context.globals.set("__builtin_int_to_string", Function([Int], String))
  context.globals.set("__builtin_int64_to_string", Function([Int64], String))
  context.globals.set("__builtin_uint_to_string", Function([UInt], String))
  context.globals.set("__builtin_uint64_to_string", Function([UInt64], String))
  context.globals.set("__builtin_float_to_string", Function([Float], String))
  context.globals.set("__builtin_double_to_string", Function([Double], String))
  context.globals.set("__builtin_char_to_string", Function([Char], String))
  context.program_to_knf(prog)
}
