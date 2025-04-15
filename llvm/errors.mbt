
///|
pub type! MoonllvmError {
  BasicBlockHasNoParent
}

///|
pub impl Show for MoonllvmError with to_string(self) -> String {
  match self {
    BasicBlockHasNoParent => "BasicBlock has no parent function"
  }
}

///|
pub impl Show for MoonllvmError with output(self, logger) {
  logger.write_string(self.to_string())
}
