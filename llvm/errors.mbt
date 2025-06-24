///|
pub suberror MoonllvmError {
  BasicBlockHasNoParent
  MetadataNotNode
}

///|
pub impl Show for MoonllvmError with output(self, logger) {
  let msg = match self {
    BasicBlockHasNoParent => "BasicBlock has no parent function"
    MetadataNotNode => "Metadata is expetced to be a node"
  }
  logger.write_string(msg)
}
