///|
/// Represents the MiniMoonBit parser AST node `Program`.
pub(all) struct Program {
  /// Stores the `source_file` component of this parser AST node.
  source_file : String
  /// Stores the `top_lets` component of this parser AST node.
  top_lets : Map[String, TopLet]
  /// Stores the `top_functions` component of this parser AST node.
  top_functions : Map[String, TopFunction]
  /// Stores the `extern_funcions` component of this parser AST node.
  extern_funcions : Map[String, ExternFunction]
  /// Stores the `struct_defs` component of this parser AST node.
  struct_defs : Map[String, StructDef]
  /// Stores the `enum_defs` component of this parser AST node.
  enum_defs : Map[String, EnumDef]
}

///|
/// Renders this `Program` value with optional ANSI coloring.
pub fn Program::to_string(self : Self, color? : Bool = true) -> String {
  let sb = StringBuilder::new()
  for _, extern_fn in self.extern_funcions {
    sb.write_string(extern_fn.to_string(color~))
  }
  for _, struct_def in self.struct_defs {
    sb.write_string(struct_def.to_string(color~))
  }
  for _, enum_def in self.enum_defs {
    sb.write_string(enum_def.to_string(color~))
  }
  for _, top_let in self.top_lets {
    sb.write_string(top_let.to_string(color~))
  }
  for _, top_fn in self.top_functions {
    sb.write_string(top_fn.to_string(color~))
  }
  sb.to_string()
}

///|
/// Formats `Program` using MiniMoonBit source notation.
pub impl Show for Program with fn output(self, logger) {
  logger.write_string(self.to_string(color=true))
}

///|
/// Parses a complete token stream into a MiniMoonBit program.
pub fn parse(tokens : Array[Token]) -> Program raise ParseError {
  guard tokens is [tok, ..] else {
    raise ParseError("Empty token array passed to parser")
  }
  let source_file = tok.file
  let top_lets = Map([])
  let top_functions = Map([])
  let extern_funcions = Map([])
  let struct_defs = Map([])
  let enum_defs = Map([])
  for current = tokens[:] {
    match current {
      [{ kind: Keyword(Extern), .. }, ..] as tokens => {
        let (extern_fn, rest) = parse_extern_function(tokens)
        extern_funcions.set(extern_fn.fname, extern_fn)
        continue rest
      }
      [{ kind: Keyword(Fn), .. }, ..] as tokens => {
        let (top_fn, rest) = parse_top_function(tokens)
        // Use whole_name() to avoid conflicts between methods with the same name
        // e.g., Point::new and Rect::new should be stored as different functions
        top_functions.set(top_fn.whole_name(), top_fn)
        continue rest
      }
      [{ kind: Keyword(Let), .. }, ..] as tokens => {
        let (top_let, rest) = parse_top_let(tokens)
        top_lets.set(top_let.name, top_let)
        continue rest
      }
      [{ kind: Keyword(Struct), .. }, ..] as tokens => {
        let (struct_def, rest) = parse_struct_def(tokens)
        struct_defs.set(struct_def.name, struct_def)
        continue rest
      }
      [{ kind: Keyword(Enum), .. }, ..] as tokens => {
        let (enum_def, rest) = parse_enum_def(tokens)
        enum_defs.set(enum_def.name, enum_def)
        continue rest
      }
      [{ kind: EOF, .. }, ..] => break
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => raise ParseError("Unexpected token in top level: \{tokens[0]}")
    }
  }
  let prog = Program::{
    top_lets,
    top_functions,
    extern_funcions,
    struct_defs,
    enum_defs,
    source_file,
  }
  prog
}
