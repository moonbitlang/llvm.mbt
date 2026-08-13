///|
/// A managed host-only ORC LLJIT session.
///
/// `LLJIT` compiles and links IR inside the current process. All aliases share
/// one native session and one open/closed state.
///
/// **Lifecycle:** Call `close` for deterministic cleanup. If omitted, the last
/// owner finalizer closes the session and consumes any shutdown error that
/// cannot be reported. Closing any alias invalidates all aliases and addresses
/// derived from this session.
///
/// **Thread safety:** Serialize submission, lookup, resource removal, and close,
/// or provide external synchronization.
///
/// **Platform support:** Native host execution only; cross-target JIT is not
/// supported.
pub struct LLJIT {
  priv owner : LLJITOwner
}

///|
fn LLJIT::fromOwner(owner : LLJITOwner) -> LLJIT {
  LLJIT::{ owner, }
}

///|
#warnings("-unused_value")
fn LLJIT::getOwnerForTest(self : LLJIT) -> LLJITOwner {
  self.owner
}

///|
fn LLJIT::requireRaw(self : LLJIT) -> @raw.LLVMOrcLLJITRef raise JITError {
  guard self.owner.isOpen() else { raise Closed }
  self.owner.raw()
}

///|
/// Creates an LLJIT configured for the current process and host target.
///
/// The constructor initializes native code generation as needed and makes
/// current-process C symbols, including libc/libm symbols, visible to JIT code.
///
/// **Errors:** Raises `CreationFailed` if native target initialization, LLJIT
/// construction, or process-symbol setup fails.
///
/// **Lifecycle:** The returned session owns all modules and generated code
/// submitted without an explicit resource tracker. Call `close` when finished.
///
/// **Platform support:** Native host execution only.
pub fn LLJIT::host() -> LLJIT raise JITError {
  @IR.TargetRegistry::initializeNativeCodegen() catch {
    @IR.NativeTargetUnavailable =>
      raise CreationFailed("native LLVM target initialization failed")
    @IR.NativeAsmPrinterUnavailable =>
      raise CreationFailed("native LLVM assembly-printer initialization failed")
    @IR.TargetNotFound(message) => raise CreationFailed(message)
  }
  let (raw, message, failed) = @raw.llvm_orc_create_lljit()
  guard !failed else { raise CreationFailed(message) }
  LLJIT::fromOwner(LLJITOwner::new(raw))
}

///|
/// Returns the target triple used by this host JIT.
///
/// **Errors:** Raises `JITError::Closed` after session close, or
/// `IR::StringError::MalformedUtf8` if LLVM returns invalid UTF-8.
pub fn LLJIT::getTargetTriple(self : LLJIT) -> String raise {
  let raw = self.requireRaw()
  @raw.llvm_orc_lljit_get_triple_string(raw) catch {
    @utf8.Malformed(bytes) => raise @IR.MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Returns the native data-layout string used by this host JIT.
///
/// **Errors:** Raises `JITError::Closed` after session close, or
/// `IR::StringError::MalformedUtf8` if LLVM returns invalid UTF-8.
pub fn LLJIT::getDataLayoutStr(self : LLJIT) -> String raise {
  let raw = self.requireRaw()
  @raw.llvm_orc_lljit_get_data_layout_str(raw) catch {
    @utf8.Malformed(bytes) => raise @IR.MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Looks up a symbol in this session's main JITDylib.
///
/// **Parameters:**
///
/// - `name`: The unmangled symbol name. Embedded NUL bytes are rejected before
///   entering LLVM.
///
/// **Returns:** An executor address that retains this session but carries no
/// type or ABI proof.
///
/// **Errors:** Raises `Closed` after session close,
/// `IR::StringError::ContainsNul` for an invalid name, or `LookupFailed` with
/// LLVM's diagnostic for missing symbols and materialization failures.
///
/// **Lifecycle:** A ResourceTracker removal can invalidate a returned address
/// even while this session remains open.
pub fn LLJIT::lookup(self : LLJIT, name : String) -> JITAddress raise {
  let raw = self.requireRaw()
  let (address, message, failed) = @raw.llvm_orc_lljit_lookup(raw, name) catch {
    @raw.EmbeddedNul => raise @IR.ContainsNul
  }
  guard !failed else { raise LookupFailed(message) }
  JITAddress::fromRaw(address, self.owner)
}

///|
/// Deterministically closes this JIT session and releases all generated code.
///
/// **Errors:** Raises `Closed` if any alias already closed the session, or
/// `CloseFailed` if LLVM reports an error while ending the session. A failed
/// close still leaves the session permanently closed.
///
/// **Lifecycle:** Closing invalidates every alias, resource tracker, JIT
/// address, and function pointer produced by this session. Stop all JIT code
/// calls before closing.
pub fn LLJIT::close(self : LLJIT) -> Unit raise JITError {
  guard self.owner.isOpen() else { raise Closed }
  let (message, failed) = self.owner.close()
  guard !failed else { raise CloseFailed(message) }
}
