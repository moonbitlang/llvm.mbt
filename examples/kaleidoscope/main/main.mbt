///|
priv suberror ReplError {
  ReadlineFailure(@readline.ReadlineError)
  SessionFailure(@session.SessionError)
  RunAndCloseFailure(String, String)
} derive(Debug)

///|
fn describe_readline_error(error : @readline.ReadlineError) -> String {
  fn errno_suffix(code : Int?) -> String {
    match code {
      Some(code) => "errno \{code}"
      None => "no OS error code"
    }
  }
  match error {
    EmbeddedNul => "readline received a string containing NUL"
    UnsupportedLocale => "readline could not create a UTF-8 locale"
    InitializationFailed => "readline initialization failed"
    ConfigurationFailed => "readline configuration failed"
    InvalidHistoryCapacity(capacity) =>
      "invalid readline history capacity: \{capacity}"
    HistoryUpdateFailed => "readline history update failed"
    HistoryLoadFailed(path, code) =>
      "failed to load readline history `\{path}` (\{errno_suffix(code)})"
    HistorySaveFailed(path, code) =>
      "failed to save readline history `\{path}` (\{errno_suffix(code)})"
    InvalidUtf8 => "readline returned invalid UTF-8"
    ReadFailed(code) => "readline failed (errno \{code})"
    Busy => "another readline operation is active"
    Interrupted => "readline input was interrupted"
  }
}

///|
fn ReplError::message(self : ReplError) -> String {
  match self {
    ReadlineFailure(error) => describe_readline_error(error)
    SessionFailure(error) => error.message()
    RunAndCloseFailure(primary, cleanup) =>
      "\{primary}; closing the JIT also failed: \{cleanup}"
  }
}

///|
fn[T] readline_operation(
  action : () -> T raise @readline.ReadlineError,
) -> T raise ReplError {
  action() catch {
    error => raise ReadlineFailure(error)
  }
}

///|
fn[T] session_operation(
  action : () -> T raise @session.SessionError,
) -> T raise ReplError {
  action() catch {
    error => raise SessionFailure(error)
  }
}

///|
fn evaluate_line(
  session : @session.Session,
  line : String,
) -> Unit raise ReplError {
  try session.evaluate(line) catch {
    error if is_fatal_session_error(error) => raise SessionFailure(error)
    error => println("error: \{error.message()}")
  } noraise {
    outcome => println(format_outcome(outcome))
  }
}

///|
fn run_repl(
  editor : @readline.LineEditor,
  history : @readline.History,
  session : @session.Session,
) -> Unit raise ReplError {
  for ;; {
    let input = editor.read_line(prompt="ready> ") catch {
      @readline.ReadlineError::Interrupted => {
        println("")
        continue
      }
      error => raise ReadlineFailure(error)
    }
    guard input is Some(line) else { break }
    if should_record_history(line) {
      readline_operation(() => history.add(line))
    }
    match classify_command(line) {
      Empty => ()
      Help => println(help_text())
      Quit => break
      Unknown(command) =>
        println("error: unknown command `\{command}`; try :help")
      Source(source) => evaluate_line(session, source)
    }
  }
}

///|
fn run_application() -> Unit raise ReplError {
  let history = readline_operation(() => @readline.History::new())
  let editor = readline_operation(() => {
    @readline.LineEditor::open(
      config=@readline.LineEditorConfig::new(
        application_name="llvm.mbt-kaleidoscope",
      ),
      history~,
    )
  })
  let session = session_operation(() => @session.Session::new())
  println("Kaleidoscope JIT — type :help for commands")
  let run_error = try {
    run_repl(editor, history, session)
    None
  } catch {
    error => Some(error)
  }
  let close_error = try {
    session_operation(() => session.close())
    None
  } catch {
    error => Some(error)
  }
  match (run_error, close_error) {
    (None, None) => ()
    (Some(error), None) | (None, Some(error)) => raise error
    (Some(primary), Some(cleanup)) =>
      raise RunAndCloseFailure(primary.message(), cleanup.message())
  }
}

///|
fn main {
  run_application() catch {
    error => println("fatal: \{error.message()}")
  }
}
