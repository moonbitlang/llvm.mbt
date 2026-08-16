///|
pub extend LLVMAttributeIndex with Eq::{not_equal, equal}

///|
pub extend LLVMAttributeRef with Eq::{not_equal, equal}

///|
pub extend LLVMBasicBlockRef with Eq::{not_equal, equal}

///|
pub extend LLVMBool with Eq::{not_equal, equal}

///|
pub extend LLVMContextRef with Eq::{not_equal, equal}

///|
pub extend LLVMDWARFTypeEncoding with Eq::{not_equal, equal}

///|
pub extend LLVMJITSymbolTargetFlags with Eq::{not_equal, equal}

///|
pub extend LLVMJITSymbolTargetFlags with Show::{to_string, output}

///|
pub extend LLVMMetadataKind with Eq::{not_equal, equal}

///|
pub extend LLVMOpcode with Show::{to_string, output}

///|
pub extend LLVMOrcExecutorAddress with Default::{default}

///|
pub extend LLVMOrcExecutorAddress with Eq::{not_equal, equal}

///|
pub extend LLVMOrcExecutorAddress with Show::{to_string, output}

///|
pub extend LLVMOrcJITTargetAddress with Eq::{not_equal, equal}

///|
pub extend LLVMOrcJITTargetAddress with Show::{to_string, output}

///|
pub extend LLVMTailCallKind with Eq::{not_equal, equal}

///|
pub extend LLVMTypeKind with Eq::{not_equal, equal}

///|
pub extend LLVMTypeKind with Show::{to_string, output}

///|
pub extend LLVMTypeRef with Eq::{not_equal, equal}

///|
pub extend LLVMTypeRef with Show::{output}

///|
pub extend LLVMUnnamedAddr with Eq::{not_equal, equal}

///|
pub extend LLVMUnnamedAddr with Show::{to_string, output}

///|
pub extend LLVMValueRef with Eq::{not_equal, equal}

///|
pub extend LLVMValueRef with Show::{output}
