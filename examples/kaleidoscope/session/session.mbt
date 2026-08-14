///|
/// Owns one incremental Kaleidoscope parser, prototype catalog, and host LLJIT.
///
/// Definitions persist until `close`; extern declarations update only the
/// catalog; anonymous expressions are submitted under independent resource
/// trackers and removed immediately after evaluation.
///
/// **Lifecycle:** Call `Session::close` exactly once. After close, `evaluate`
/// and repeated `close` calls raise `SessionError::Closed`.
///
/// **Thread safety:** A Session is serial and must not be evaluated concurrently.
pub struct Session {
  priv jit : @JIT.LLJIT
  priv parser : @parser.Parser
  priv catalog : @codegen.PrototypeCatalog
  priv mut next_id : Int
  priv mut closed : Bool
}

///|
fn[T] jit_operation(
  action : () -> T raise @JIT.JITError,
) -> T raise SessionError {
  action() catch {
    @JIT.JITError::Closed => raise Closed
    error => raise JITFailure(describe_jit_error(error))
  }
}

///|
fn parse_source(
  parser : @parser.Parser,
  source : String,
) -> @ast.TopLevel raise SessionError {
  parser.parseTopLevel(source) catch {
    @lexer.LexError::InvalidCharacter(_, _) as error =>
      raise LexerFailure(error)
    @lexer.LexError::MalformedNumber(_, _) as error => raise LexerFailure(error)
    @parser.ParseError::UnexpectedToken(_, _) as error =>
      raise ParserFailure(error)
    @parser.ParseError::UnexpectedEndOfInput(_, _) as error =>
      raise ParserFailure(error)
    @parser.ParseError::DuplicateParameter(_, _) as error =>
      raise ParserFailure(error)
    error => raise UnexpectedFailure(error.to_string())
  }
}

///|
fn[T] codegen_operation(
  action : () -> T raise @codegen.CodegenError,
) -> T raise SessionError {
  action() catch {
    error => raise CodegenFailure(error)
  }
}

///|
fn lookup(
  jit : @JIT.LLJIT,
  symbol : String,
) -> @JIT.JITAddress raise SessionError {
  jit.lookup(symbol) catch {
    @JIT.JITError::CreationFailed(_) as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::SnapshotFailed(_) as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::SubmissionFailed(_) as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::LookupFailed(_) as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::ResourceRemovalFailed(_) as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::CloseFailed(_) as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::Closed => raise Closed
    @JIT.JITError::ResourceTrackerRemoved as error =>
      raise JITFailure(describe_jit_error(error))
    @JIT.JITError::ResourceTrackerOwnerMismatch as error =>
      raise JITFailure(describe_jit_error(error))
    @IR.StringError::ContainsNul as error =>
      raise IRStringFailure(describe_ir_string_error(error))
    @IR.StringError::MalformedUtf8(_) as error =>
      raise IRStringFailure(describe_ir_string_error(error))
    error => raise UnexpectedFailure(error.to_string())
  }
}

///|
fn cleanup_tracker(
  tracker : @JIT.ResourceTracker,
  primary? : String,
) -> Unit raise SessionError {
  match primary {
    None => jit_operation(() => tracker.remove())
    Some(primary) =>
      tracker.remove() catch {
        error => raise CleanupFailure(primary, describe_jit_error(error))
      }
  }
}

///|
fn Session::freshNames(self : Session) -> (String, String) {
  let id = self.next_id
  self.next_id += 1
  ("kaleidoscope.expression.\{id}", "__llvm_mbt_kaleidoscope_expression_\{id}")
}

///|
fn Session::evaluateExpression(
  self : Session,
  expression : @ast.Expr,
) -> Double raise SessionError {
  let (module_name, symbol_name) = self.freshNames()
  let tracker = jit_operation(() => self.jit.createResourceTracker())
  let mod = codegen_operation(() => {
    @codegen.compileExpression(
      self.catalog,
      expression,
      module_name~,
      symbol_name~,
    )
  }) catch {
    error => {
      cleanup_tracker(tracker, primary=error.message())
      raise error
    }
  }
  jit_operation(() => self.jit.addModule(mod, tracker~)) catch {
    error => {
      cleanup_tracker(tracker, primary=error.message())
      raise error
    }
  }
  let result = try {
    let address = lookup(self.jit, symbol_name)
    let callable : FuncRef[() -> Double] = jit_operation(() => {
      address.unsafeToFuncRef()
    })
    let result = callable()
    let _keep_address_alive : FuncRef[() -> Double] = jit_operation(() => {
      address.unsafeToFuncRef()
    })
    result
  } catch {
    error => {
      cleanup_tracker(tracker, primary=error.message())
      raise error
    }
  }
  cleanup_tracker(tracker)
  result
}

///|
/// Creates an empty host-only incremental JIT session.
///
/// **Errors:** Raises `JITFailure` when native LLJIT initialization fails.
pub fn Session::new() -> Session raise SessionError {
  let jit = jit_operation(() => @JIT.LLJIT::host())
  {
    jit,
    parser: @parser.Parser::new(operators=@parser.OperatorTable::new()),
    catalog: @codegen.PrototypeCatalog::new(),
    next_id: 0,
    closed: false,
  }
}

///|
/// Parses and evaluates exactly one complete top-level input.
///
/// **Returns:** `Defined`, `Extern`, or the native `Value` produced by the
/// submitted input.
///
/// **Side Effects:** Successful definitions and extern declarations update the
/// Session. Failed operations and anonymous expressions do not leave catalog
/// state behind.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let session = @session.Session::new()
///   let result = session.evaluate("1 + 2 * 3")
///   debug_inspect(result, content="Value(7)")
///   session.close()
/// }
/// ```
pub fn Session::evaluate(
  self : Session,
  source : String,
) -> EvalOutcome raise SessionError {
  guard !self.closed else { raise Closed }
  match parse_source(self.parser, source) {
    Definition(prototype, body) => {
      let id = self.next_id
      self.next_id += 1
      let mod = codegen_operation(() => {
        @codegen.compileDefinition(
          self.catalog,
          prototype,
          body,
          module_name="kaleidoscope.definition.\{id}",
        )
      })
      jit_operation(() => self.jit.addModule(mod))
      codegen_operation(() => self.catalog.commitDefinition(prototype))
      Defined(prototype.name)
    }
    Extern(prototype) => {
      codegen_operation(() => self.catalog.commitExtern(prototype))
      EvalOutcome::Extern(prototype.name)
    }
    Expression(expression) => Value(self.evaluateExpression(expression))
  }
}

///|
/// Deterministically releases all persistent definitions and JIT resources.
///
/// A failed native close still marks the Session closed, matching LLJIT's
/// lifecycle contract.
pub fn Session::close(self : Session) -> Unit raise SessionError {
  guard !self.closed else { raise Closed }
  self.closed = true
  jit_operation(() => self.jit.close())
}
