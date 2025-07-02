///|
pub suberror MoonllvmError {
  IntoTypeError(String)
  IntoValueError(String)
  BasicBlockHasNoParent
  SetBodyForNonOpaqueStruct
  MetadataNotNode
}

///|
pub impl Show for MoonllvmError with output(self, logger) {
  let msg = match self {
    IntoTypeError(msg) => msg
    IntoValueError(msg) => msg
    BasicBlockHasNoParent => "BasicBlock has no parent function"
    MetadataNotNode => "Metadata is expected to be a node"
    SetBodyForNonOpaqueStruct => "Cannot set body for non-opaque struct"
  }
  logger.write_string(msg)
}
