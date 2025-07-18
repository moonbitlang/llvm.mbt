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
pub fn llvm_get_error_message(err : LLVMErrorRef) -> String {
  __llvm_get_error_message(err) |> c_str_to_moonbit_str
}

///|
extern "C" fn __llvm_get_error_message(err : LLVMErrorRef) -> CStr = "LLVMGetErrorMessage"

///| Disposes of the given error message.
pub extern "C" fn llvm_dispose_error_message(err_msg : CStr) = "LLVMDisposeErrorMessage"
//
// /**
//  * Returns the type id for llvm StringError.
//  */
// LLVMErrorTypeId LLVMGetStringErrorTypeId(void);

///| Creates a string error with the given message.
pub extern "C" fn llvm_create_string_error(err_msg : CStr) -> LLVMErrorRef = "LLVMCreateStringError"
