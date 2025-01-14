///|
pub type Context

///|
pub type Module

///|
pub type Builder

///|
pub type Function

///|
pub type BasicBlock

///|
pub type Type

///|
pub type IntType

///|
pub type FunctionType

///|
pub type IntValue

///|
pub extern "C" fn Context::create() -> Context = "__llvm_context_create"

///|
pub extern "C" fn create_module(self : Context, name : String) -> Module = "__llvm_module_create_with_name_in_context"

///|
pub extern "C" fn create_builder(self : Context) -> Builder = "__llvm_create_builder"

///|
pub extern "C" fn i32_type(self : Context) -> IntType = "__llvm_int32_type"

///|
pub extern "C" fn fn_type(
  self : IntType,
  params : Array[Type],
  is_var_arg : Bool
) -> FunctionType = "__llvm_function_type"

///|
pub extern "C" fn add_func(
  self : Module,
  name : String,
  ty : FunctionType
) -> Function = "__llvm_add_function"

///|
pub extern "C" fn append_basic_block(
  self : Context,
  func : Function,
  name : String
) -> BasicBlock = "__llvm_append_basic_block"

///|
pub extern "C" fn position_at_end(self : Builder, bb : BasicBlock) = "__llvm_position_builder_at_end"

///|
pub extern "C" fn const_int(
  self : IntType,
  n : Int,
  sign_extend : Bool
) -> IntValue = "__llvm_const_int"

///|
pub extern "C" fn build_ret(self : Builder, val : IntValue) = "__llvm_build_ret"

///|
pub extern "C" fn print_to_stdout(self : Module) = "__llvm_dump_module"
