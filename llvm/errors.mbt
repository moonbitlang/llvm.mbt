///|
pub suberror MoonllvmError {
  BasicBlockHasNoParent
  SetBodyForNonOpaqueStruct
  MetadataNotNode
}

///|
pub impl Show for MoonllvmError with output(self, logger) {
  let msg = match self {
    BasicBlockHasNoParent => "BasicBlock has no parent function"
    MetadataNotNode => "Metadata is expetced to be a node"
    SetBodyForNonOpaqueStruct => "Cannot set body for non-opaque struct"
  }
  logger.write_string(msg)
}
