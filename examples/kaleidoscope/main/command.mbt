///|
priv enum Command {
  Empty
  Help
  Quit
  Unknown(String)
  Source(String)
}

///|
fn classify_command(line : String) -> Command {
  let trimmed = line.trim()
  match trimmed {
    "" => Empty
    ":help" => Help
    ":quit" => Quit
    command if command.has_prefix(":") => Unknown(command.to_owned())
    _ => Source(line)
  }
}

///|
fn should_record_history(line : String) -> Bool {
  line.trim() != ""
}

///|
fn help_text() -> String {
  (
    #|Kaleidoscope commands:
    #|  :help  show this help
    #|  :quit  close the JIT session and exit
    #|
    #|Submit one definition, extern declaration, or expression per line.
  )
}

///|
fn format_outcome(outcome : @session.EvalOutcome) -> String {
  match outcome {
    Defined(name) => "defined \{name}"
    Extern(name) => "declared \{name}"
    Value(value) => "\{value}"
  }
}

///|
fn is_fatal_session_error(error : @session.SessionError) -> Bool {
  match error {
    Closed | CleanupFailure(_, _) | UnexpectedFailure(_) => true
    _ => false
  }
}
