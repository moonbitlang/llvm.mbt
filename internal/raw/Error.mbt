// /*===------- llvm-c/Error.h - llvm::Error class C Interface -------*- C -*-===*\
// |*                                                                            *|
// |* Part of the LLVM Project, under the Apache License v2.0 with LLVM *|
// |* Exceptions. *|
// |* See https://llvm.org/LICENSE.txt for license information. *|
// |* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception *|
// |* *|
// |*===----------------------------------------------------------------------===*|
// |* *|
// |* This file defines the C interface to LLVM's Error class. *|
// |* *|
// \*===----------------------------------------------------------------------===*/
//
// /**
//  * @defgroup LLVMCError Error Handling
//  * @ingroup LLVMC
//  *
//  * @{
//  */
//
// #define LLVMErrorSuccess 0
//
// typedef struct LLVMOpaqueError *LLVMErrorRef;
//
// /**
//  * Error type identifier.
//  */
// typedef const void *LLVMErrorTypeId;
//
// /**
//  * Returns the type id for the given error instance, which must be a failure
//  * value (i.e. non-null).
//  */
// LLVMErrorTypeId LLVMGetErrorTypeId(LLVMErrorRef Err);
//
// /**
//  * Dispose of the given error without handling it. This operation consumes
//  the
//  * error, and the given LLVMErrorRef value is not usable once this call
//  returns.
//  * Note: This method *only* needs to be called if the error is not being
//  passed
//  * to some other consuming operation, e.g. LLVMGetErrorMessage.
//  */

///|
pub extern "C" fn llvm_consume_error(err : LLVMErrorRef) = "LLVMConsumeError"
//
// /**
//  * Returns the given string's error message. This operation consumes the
//  error,
//  * and the given LLVMErrorRef value is not usable once this call returns.
//  * The caller is responsible for disposing of the string by calling
//  * LLVMDisposeErrorMessage.
//  */

///|
pub fn llvm_get_error_message(
  err : LLVMErrorRef,
) -> String raise @utf8.Malformed {
  __llvm_get_error_message(err).to_string()
}

///|
extern "C" fn __llvm_take_error_message(err : LLVMErrorRef) -> Bytes = "llvm_mbt_take_error_message"

///|
/// Consumes a non-null LLVM error and returns an independent diagnostic.
pub fn llvm_take_error_message(err : LLVMErrorRef) -> String {
  __llvm_take_error_message(err) |> @utf8.decode_lossy
}

///|
extern "C" fn __llvm_get_error_message(err : LLVMErrorRef) -> LLVMErrorMessage = "llvm_mbt_get_error_message"

///|
/// Disposes of the given error message.
// LLVM error messages are disposed by the LLVMErrorMessage C finalizer.
//
// /**
//  * Returns the type id for llvm StringError.
//  */
// LLVMErrorTypeId LLVMGetStringErrorTypeId(void);

///|
/// Creates a string error with the given message.
#borrow(err_msg)
extern "C" fn __llvm_create_string_error(err_msg : Utf8Z) -> LLVMErrorRef = "LLVMCreateStringError"

///|
pub fn llvm_create_string_error(err_msg : String) -> LLVMErrorRef {
  let err_msg = Utf8Z::from_string(err_msg) catch {
    EmbeddedNul => return llvm_embedded_nul_error()
  }
  __llvm_create_string_error(err_msg)
}
