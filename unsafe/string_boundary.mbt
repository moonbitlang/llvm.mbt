///|
/// A NUL-terminated UTF-8 input contains an embedded NUL code unit.
pub suberror CStringError {
  /// The input cannot be represented as one C string without truncation.
  EmbeddedNul
}

///|
/// NUL-terminated UTF-8 bytes borrowed by one synchronous C call.
priv struct Utf8Z(Bytes)

///|
fn Utf8Z::from_string(text : String) -> Utf8Z raise CStringError {
  guard !text.contains_code_unit(0) else { raise EmbeddedNul }
  Utf8Z(@utf8.encode(text))
}

///|
/// Creates an LLVM error for APIs whose existing result type is LLVMErrorRef.
extern "C" fn llvm_embedded_nul_error() -> LLVMErrorRef = "llvm_mbt_create_embedded_nul_error"

///|
/// An LLVM message owned by a MoonBit managed external object.
priv type LLVMMessage

///|
/// An LLVM error message owned by a MoonBit managed external object.
priv type LLVMErrorMessage

///|
/// A libc-owned string owned by a MoonBit managed external object.
priv type LibcCString

///|
#borrow(message)
extern "C" fn LLVMMessage::copy_bytes(message : LLVMMessage) -> Bytes = "llvm_mbt_llvm_message_copy_bytes"

///|
#borrow(message)
extern "C" fn LLVMErrorMessage::copy_bytes(message : LLVMErrorMessage) -> Bytes = "llvm_mbt_llvm_error_message_copy_bytes"

///|
#borrow(message)
extern "C" fn LibcCString::copy_bytes(message : LibcCString) -> Bytes = "llvm_mbt_libc_cstring_copy_bytes"

///|
fn LLVMMessage::to_string(self : LLVMMessage) -> String raise @utf8.Malformed {
  self.copy_bytes() |> @utf8.decode
}

///|
fn LLVMErrorMessage::to_string(
  self : LLVMErrorMessage,
) -> String raise @utf8.Malformed {
  self.copy_bytes() |> @utf8.decode
}

///|
fn LibcCString::to_string(self : LibcCString) -> String raise @utf8.Malformed {
  self.copy_bytes() |> @utf8.decode
}
