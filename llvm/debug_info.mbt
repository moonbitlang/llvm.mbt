///|
pub struct DebugInfoBuilder {
  builder : @unsafe.LLVMDIBuilderRef
}

///|
pub fn DebugInfoBuilder::new(
  dgb_info_builder : @unsafe.LLVMDIBuilderRef
) -> DebugInfoBuilder {
  // assert_not(dgb_info_builder.is_null())

  DebugInfoBuilder::{ builder: dgb_info_builder }
}
