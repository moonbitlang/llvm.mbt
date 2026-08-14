///|
/// A symbol address in the current-process JIT executor.
///
/// This value records an address and retains its LLJIT session. It does not
/// encode or validate the LLVM function type, calling convention, or machine
/// ABI of the symbol.
///
/// **Construction:** Use `LLJIT::lookup`.
///
/// **Lifecycle:** The address retains the LLJIT owner against finalizer-driven
/// close. Explicit `LLJIT::close` or removal of the defining ResourceTracker
/// still invalidates it and any function pointer derived from it.
pub struct JITAddress {
  priv address : UInt64
  priv owner : LLJITOwner
}

///|
fn JITAddress::fromRaw(
  address : @raw.LLVMOrcExecutorAddress,
  owner : LLJITOwner,
) -> JITAddress {
  JITAddress::{ address: address.to_uint64(), owner }
}

///|
extern "C" fn executorAddressToOpaqueFuncRef(
  address : UInt64,
) -> FuncRef[() -> Unit] = "llvm_mbt_jit_executor_address_to_func_ref"

///|
// Keep the unchecked cast behind a non-newtype heap box. The optimized C
// backend otherwise emits a direct assignment between two function-pointer
// signatures, which recent Clang versions reject before the documented unsafe
// call boundary can be exercised. The marker prevents newtype erasure.
priv struct FunctionRefBox[T] {
  function : FuncRef[T]
  marker : Int
}

///|
#inline(never)
fn boxOpaqueFunctionRef(
  function : FuncRef[() -> Unit],
) -> FunctionRefBox[() -> Unit] {
  { function, marker: 0 }
}

///|
#inline(never)
fn[From, To] specializeFunctionRefBox(
  box : FunctionRefBox[From],
) -> FunctionRefBox[To] = "%identity"

///|
#inline(never)
fn[T] unboxFunctionRef(box : FunctionRefBox[T]) -> FuncRef[T] {
  guard box.marker == 0 else { panic() }
  box.function
}

///|
/// Converts this executor address to a native function reference of type `T`.
///
/// **Errors:** Raises `Closed` if the parent session has already been closed.
///
/// **Safety:** This is an unchecked native address conversion. The caller must
/// guarantee that `T` exactly matches the symbol's parameter types, return
/// type, calling convention, and current-platform C ABI. Calling a mismatched
/// function reference is undefined behavior.
///
/// **Lifecycle:** Keep this `JITAddress` and its parent session reachable for
/// every call through the returned `FuncRef`. `FuncRef` does not retain this
/// owner. Never call it after its ResourceTracker is removed or the LLJIT is
/// closed.
///
/// **Platform support:** Current-process native JIT addresses on supported
/// 64-bit hosts only.
///
/// **See also:** `LLJIT::host` provides a complete lookup, conversion, call,
/// owner-keepalive, and close example.
pub fn[T] JITAddress::unsafeToFuncRef(
  self : JITAddress,
) -> FuncRef[T] raise JITError {
  guard self.owner.isOpen() else { raise Closed }
  let untyped = boxOpaqueFunctionRef(
    executorAddressToOpaqueFuncRef(self.address),
  )
  let specialized : FunctionRefBox[T] = specializeFunctionRefBox(untyped)
  unboxFunctionRef(specialized)
}
