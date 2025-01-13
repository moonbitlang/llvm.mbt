pub type Context
pub type Module
pub type Builder
pub type Function
pub type BasicBlock
pub type Type
pub type IntType
pub type FunctionType
pub type IntValue

pub extern "C" fn Context::create() -> Context = "__LLVMContextCreate"
pub extern "C" fn create_module(self: Context, name: String) -> Module = "__LLVMModuleCreateWithNameInContext"
pub extern "C" fn create_builder(self: Context) -> Builder = "__LLVMCreateBuilder"
pub extern "C" fn i32_type(self: Context) -> IntType = "__LLVMInt32Type"
pub extern "C" fn fn_type(self: IntType, params: Array[Type], is_var_arg: Bool) -> FunctionType = "__LLVMFunctionType"
pub extern "C" fn add_func(self: Module, name: String, ty: FunctionType) -> Function = "__LLVMAddFunction"
pub extern "C" fn append_basic_block(self: Context, func: Function, name: String) -> BasicBlock = "__LLVMAppendBasicBlock"
pub extern "C" fn position_at_end(self: Builder, bb: BasicBlock) = "__LLVMPositionBuilderAtEnd"
pub extern "C" fn const_int(self: IntType, n: Int, sign_extend: Bool) -> IntValue = "__LLVMConstInt"
pub extern "C" fn build_ret(self: Builder, val: IntValue) = "__LLVMBuildRet"
pub extern "C" fn print_to_stdout(self: Module) = "__LLVMDumpModule"

