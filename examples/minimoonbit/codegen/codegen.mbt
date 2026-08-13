///|
/// Compiles MiniMoonBit source text into a host-configured LLVM module.
///
/// The returned module contains declarations for the MiniMoonBit runtime but
/// does not link or embed that runtime.
///
/// **Parameters:**
///
/// - `code`: Complete MiniMoonBit source text.
/// - `source_file`: Source name recorded in frontend diagnostics and used as
///   the LLVM module identifier.
///
/// **Returns:** An LLVM module configured for the current host target. The
/// caller should run `Module::verify` before emission.
///
/// **Errors:** Propagates lexer, parser, type-checking, KNF, LLVM construction,
/// target initialization, and code-generation failures.
///
/// **Side effects:** Initializes LLVM's native target registry through
/// `TargetMachine::host` and constructs an in-memory module.
///
/// **Platform support:** Native target only.
#alias(codegen_all)
pub fn compile(
  code : String,
  source_file? : String = "demo",
) -> @llvm.Module raise {
  let tokens = @lexer.tokenize(code, source_file~)
  let ast = @parser.parse(tokens)
  let typed_ast = @typecheck.typecheck(ast)
  let knf_prog = @knf.knf_transform(typed_ast)
  let llvm_mod = codegen(knf_prog)
  llvm_mod
}

///|
/// Lowers an existing MiniMoonBit KNF program into a host-configured LLVM
/// module.
///
/// **Errors:** Raises when the KNF program is inconsistent, uses an unsupported
/// lowering form, or an LLVM/target operation fails.
///
/// **Side effects:** Initializes LLVM's native target registry and constructs
/// an in-memory module containing runtime function declarations.
///
/// **Platform support:** Native target only.
pub fn codegen(knf_prog : @knf.KnfProgram) -> @llvm.Module raise {
  let codegen_ctx = Context::new(knf_prog.source_file)
  codegen_ctx.collect_struct_types(knf_prog.struct_defs)
  codegen_ctx.generate_global_stmts(knf_prog.global_stmts)
  codegen_ctx.collect_top_lets(knf_prog.top_lets)
  codegen_ctx.collect_extern_func_values(knf_prog.externs)
  codegen_ctx.collect_func_values(knf_prog.functions)
  codegen_ctx.generate_functions(knf_prog.functions)
  codegen_ctx.llvm_mod
}

///|
fn Context::generate_global_stmts(
  self : Context,
  knf_global_stmts : Array[@knf.KnfStmt],
) -> Unit raise {
  for knf_stmt in knf_global_stmts {
    match knf_stmt {
      Let(name, ty, expr) =>
        // Try to evaluate as constant, if it fails, defer to runtime
        match expr {
          Int(_)
          | Int64(_)
          | UInt(_)
          | UInt64(_)
          | Bool(_)
          | Double(_)
          | Float(_)
          | Char(_)
          | Unit => {
            let val = self.global_expr_codegen(expr)
            guard val.tryAsConstant() is Some(const_val) else {
              raise CodegenError(
                "Global let expression did not evaluate to a constant",
              )
            }
            self.global_consts.set(name.to_string(), const_val)
            self.global_types.set(name.to_string(), ty)
          }
          _ => {
            // For complex expressions, create a global variable and defer init
            let llvm_ty = self.type_codegen_storage(ty)
            let null_val = self.zero_initializer(ty)
            let v = self.llvm_mod.addGlobalVariable(
              llvm_ty,
              name.to_string(),
              initializer=null_val,
            )
            self.global_values.set(name.to_string(), v)
            self.global_types.set(name.to_string(), ty)
            // Store the initialization expression for later use in main
            self.global_array_inits.push((name, ty, expr))
          }
        }
      _ =>
        raise CodegenError(
          "Only let statements are allowed in global statements",
        )
    }
  }
}

///|
fn Context::collect_top_lets(
  self : Context,
  top_lets : Map[String, @knf.KnfTopLet],
) -> Unit raise {
  for _, top_let in top_lets {
    let _ = self.top_let_codegen(top_let)
  }
}

///|
fn Context::generate_functions(
  self : Context,
  functions : Map[String, @knf.KnfFunction],
) -> Unit raise {
  for _, knf_func in functions {
    let _ = self.top_function_codegen(knf_func)
  }
}
