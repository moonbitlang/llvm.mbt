///|
test "local commands are classified before language parsing" {
  inspect(classify_command("") is Empty, content="true")
  inspect(classify_command("   ") is Empty, content="true")
  inspect(classify_command(" :help ") is Help, content="true")
  inspect(classify_command(":quit") is Quit, content="true")
  inspect(classify_command(":unknown") is Unknown(":unknown"), content="true")
  inspect(classify_command(" 1 + 2 ") is Source(" 1 + 2 "), content="true")
}

///|
test "history records all non-empty submitted lines" {
  inspect(should_record_history(""), content="false")
  inspect(should_record_history("  \t"), content="false")
  inspect(should_record_history(":help"), content="true")
  inspect(should_record_history(":quit"), content="true")
  inspect(should_record_history("broken input"), content="true")
}

///|
test "successful outcomes have compact REPL output" {
  inspect(format_outcome(@session.Defined("add")), content="defined add")
  inspect(format_outcome(@session.Extern("sin")), content="declared sin")
  inspect(format_outcome(@session.Value(42.0)), content="42")
}

///|
test "help documents only implemented local commands" {
  inspect(
    help_text(),
    content=(
      #|Kaleidoscope commands:
      #|  :help  show this help
      #|  :quit  close the JIT session and exit
      #|
      #|Submit one definition, extern declaration, or expression per line.
    ),
  )
}
