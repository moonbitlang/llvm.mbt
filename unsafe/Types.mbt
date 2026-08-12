// LLVMTypes

///|
struct LLVMBool(Int) derive(Eq)

///|
/// Numeric attribute position used by LLVM-C attribute APIs.
///
/// Function, return, and parameter positions use LLVM's special index constants
/// and one-based parameter numbering; this wrapper performs no range validation.
pub(all) struct LLVMAttributeIndex(UInt) derive(Eq)

///|
/// Fast-math bit values accepted by LLVM-C instruction flag APIs.
///
/// Individual constructors are powers of two and may be combined only by APIs
/// that operate on the underlying mask; this enum itself represents one listed
/// value. These promises permit transformations that are invalid for strict IEEE
/// arithmetic.
pub(all) enum LLVMFastMathFlags {
  /// Permits reassociation of floating-point expressions.
  AllowReassoc = 1
  /// Promises that arguments and results are not NaN.
  NoNaNs = 2
  /// Promises that arguments and results are not infinite.
  NoInfs = 4
  /// Permits treating positive and negative zero as equivalent.
  NoSignedZeros = 8
  /// Permits reciprocal-based transformations instead of strict division.
  AllowReciprocal = 16
  /// Permits contraction, such as forming fused multiply-add operations.
  AllowContract = 32
  /// Permits approximate implementations of floating-point functions.
  ApproxFunc = 64
  /// Enables no fast-math promises.
  None = 0
  /// Enables every fast-math promise represented by LLVM 19's mask.
  All = 127
}

///|
/// Raw DWARF base-type encoding number (`DW_ATE_*`).
///
/// The value is an unsigned metadata code, not a byte count or a type width.
pub(all) struct LLVMDWARFTypeEncoding(UInt) derive(Eq)

///|
/// Raw LLVM metadata-kind identifier returned by metadata kind lookup APIs.
///
/// Kind IDs are Context-specific numeric tags and must not be invented unless
/// the consuming LLVM API explicitly permits it.
pub(all) struct LLVMMetadataKind(UInt) derive(Eq)

// Dummy function just for eliminating the warning

///|
/// Wraps an LLVM attribute position without validating it.
pub fn LLVMAttributeIndex::new(idx : UInt) -> LLVMAttributeIndex {
  LLVMAttributeIndex(idx)
}
// Dummy function just for eliminating the warning

// Dummy function just for eliminating the warning

///|
/// Wraps a raw DWARF type-encoding number without validation.
pub fn LLVMDWARFTypeEncoding::new(idx : UInt) -> LLVMDWARFTypeEncoding {
  LLVMDWARFTypeEncoding(idx)
}

// Dummy function just for eliminating the warning

///|
/// Wraps a raw metadata-kind identifier without validation.
pub fn LLVMMetadataKind::new(idx : UInt) -> LLVMMetadataKind {
  LLVMMetadataKind(idx)
}

///|
/// Opaque pointer identity for an LLVM memory buffer.
///
/// This type alone conveys no ownership; follow the allocator/disposer contract
/// of the LLVM-C function that produced or consumes the handle.
#external
pub type LLVMMemoryBufferRef

///|
/// Opaque pointer identity for an LLVM context.
///
/// The handle does not own or retain the context; its creating/disposal API
/// determines lifetime, and all child handles become invalid after disposal.
#external
pub type LLVMContextRef

///|
/// Opaque pointer identity for an LLVM module.
///
/// This type does not encode whether ownership is borrowed or transferred.
/// Follow the producing and consuming LLVM-C functions' lifetime contracts.
#external
pub type LLVMModuleRef

///|
/// Opaque pointer identity for an LLVM basic block.
///
/// It is normally a borrowed view into parent IR and may be invalidated by IR
/// mutation or disposal of its owning module/context.
#external
pub type LLVMBasicBlockRef

///|
/// Opaque pointer identity for LLVM metadata.
///
/// It is normally Context-owned; the handle itself does not retain its Context.
#external
pub type LLVMMetadataRef

///|
/// Opaque pointer identity for a named metadata node in a module.
///
/// It is a borrowed module child and becomes invalid with its parent module.
#external
pub type LLVMNamedMDNodeRef

///|
/// Opaque pointer identity for an entry in an LLVM value-metadata array.
///
/// The allocating API defines the array's lifetime and required disposal.
#external
pub type LLVMValueMetadataEntry

///|
/// Opaque pointer identity for an LLVM IR builder.
///
/// This handle does not imply ownership; builder creation APIs generally return
/// an owned resource that must be disposed by the paired LLVM-C function.
#external
pub type LLVMBuilderRef

///|
/// Opaque pointer identity for an LLVM debug-information builder.
///
/// Its creating API defines ownership and the required finalize/dispose order.
#external
pub type LLVMDIBuilderRef

///|
/// Opaque pointer identity for the legacy LLVM module-provider abstraction.
///
/// Ownership may transfer through legacy execution-engine APIs; consult the
/// specific producer/consumer rather than inferring it from this type.
#external
pub type LLVMModuleProviderRef

///|
/// Opaque pointer identity for an LLVM legacy pass manager.
///
/// Its constructor/disposer pair determines ownership; the handle is not a
/// managed reference.
#external
pub type LLVMPassManagerRef

///|
/// Opaque pointer identity for LLVM's process-global pass registry.
///
/// Registry lifetime and initialization are controlled by LLVM; this handle
/// does not represent independently owned storage.
#external
pub type LLVMPassRegistryRef

///|
/// Opaque pointer identity for options consumed by `LLVMRunPasses`.
///
/// Creation returns an owned options object that must be disposed by the paired
/// API; this raw type itself neither owns nor retains it.
#external
pub type LLVMPassBuilderOptionsRef

///|
/// Opaque pointer identity for the deprecated pass-manager builder.
///
/// The matching LLVM-C constructor/disposer functions define its ownership.
#external
pub type LLVMPassManagerBuilderRef

///|
/// Opaque pointer identity for one use edge of an LLVM value.
///
/// It is a borrowed IR view and may become invalid when operands or parent IR
/// are mutated or disposed.
#external
pub type LLVMUseRef

///|
/// Opaque pointer identity for an LLVM value.
///
/// It is usually borrowed from Context- or Module-owned IR. This type conveys no
/// ownership and does not prevent deletion or parent disposal.
#external
pub type LLVMValueRef

///|
/// Opaque pointer identity for an LLVM type.
///
/// LLVM types are Context-owned and uniqued; the raw handle does not retain the
/// Context or provide structural ownership.
#external
pub type LLVMTypeRef

///|
/// Opaque pointer identity for an LLVM operand bundle.
///
/// The creating and consuming LLVM-C calls define whether the handle is owned,
/// borrowed, or transferred.
#external
pub type LLVMOperandBundleRef

///|
/// Opaque pointer identity for an LLVM attribute.
///
/// Attributes are Context-owned/uniqued values; the handle itself conveys no
/// ownership and is invalid after its Context is disposed.
#external
pub type LLVMAttributeRef

///|
/// Opaque pointer identity for LLVM diagnostic information.
///
/// Diagnostic handlers normally receive a callback-scoped borrowed handle; do
/// not retain it beyond the callback unless the producing API says otherwise.
#external
pub type LLVMDiagnosticInfoRef

///|
/// Opaque pointer identity for a module-owned LLVM COMDAT.
///
/// It is a borrowed view and becomes invalid with its parent module.
#external
pub type LLVMComdatRef

///|
/// Opaque pointer identity for an entry in an allocated module-flag array.
///
/// The array-producing API specifies element validity and the required disposer.
#external
pub type LLVMModuleFlagEntry

///|
/// Opaque pointer identity for an LLVM JIT event listener.
///
/// Ownership and registration lifetime depend on the listener/engine APIs that
/// create and consume it.
#external
pub type LLVMJITEventListenerRef

///|
/// Opaque pointer identity for an LLVM binary object view.
///
/// Creation typically returns an owned binary handle; its source memory buffer
/// and paired disposer define the complete lifetime contract.
#external
pub type LLVMBinaryRef

///|
/// Opaque pointer identity for an LLVM target descriptor.
///
/// Targets are registry-owned static objects; callers must not dispose them.
#external
pub type LLVMTargetRef

///|
/// Opaque pointer identity for mutable LLVM target-machine options.
///
/// The creating call returns a resource consumed or disposed according to its
/// paired LLVM-C APIs; this type does not manage it.
#external
pub type LLVMTargetMachineOptionsRef

///|
/// Opaque pointer identity for an LLVM target machine.
///
/// Its creating API returns an owned native resource that normally requires
/// `LLVMDisposeTargetMachine`; the raw handle does not automate disposal.
#external
pub type LLVMTargetMachineRef

///|
/// Opaque pointer identity for an LLVM debug record attached to IR.
///
/// It is a borrowed view whose validity follows its parent instruction/module.
#external
pub type LLVMDbgRecordRef

///|
/// Opaque pointer identity for an LLVM generic execution value.
///
/// Its creating/disposal APIs determine ownership; it is not retained by this
/// raw handle type.
#external
pub type LLVMGenericValueRef

///|
/// Opaque pointer identity for an LLVM execution engine.
///
/// Creation APIs may take ownership of modules and return an owned engine; obey
/// their transfer and disposal contracts exactly.
#external
pub type LVMExecutionEngineRef

///|
/// Opaque pointer identity for an MCJIT memory manager.
///
/// Ownership is commonly transferred to an execution engine; consult the
/// consuming API before disposing or reusing the handle.
#external
pub type LVMMCJITMemoryManagerRef

///|
/// Opaque pointer identity for a string exposed by LLVM's remark API.
///
/// It is generally borrowed from a parent remark object and must not outlive it.
#external
pub type LLVMRemarkStringRef

///|
/// Opaque pointer identity for a consumable LLVM error.
///
/// Null is the success sentinel. A non-null error has linear ownership and must
/// be consumed by an LLVM error-handling API exactly once.
#external
pub type LLVMErrorRef

///|
/// Byte address in the executor process, represented as an unsigned 64-bit value.
pub(all) struct LLVMOrcJITTargetAddress(UInt64) derive(Eq)

///|
/// Writes the numeric target address in decimal form.
pub impl Show for LLVMOrcJITTargetAddress with fn output(self, logger) {
  self.0.output(logger)
}

///|
/// Byte address in the ORC executor process, represented as an unsigned 64-bit value.
pub(all) struct LLVMOrcExecutorAddress(UInt64) derive(Eq, Default)

///|
/// Writes the numeric executor address in decimal form.
pub impl Show for LLVMOrcExecutorAddress with fn output(self, logger) {
  self.0.output(logger)
}

// NOTE: It different with real, the real LLVMJITSymbolTargetFlags is uint8

///|
/// ORC target-specific symbol flags stored as a bit mask.
///
/// LLVM's ABI uses the low eight bits; this wrapper uses `UInt` for FFI
/// convenience and performs no masking or validation.
pub(all) struct LLVMJITSymbolTargetFlags(UInt) derive(Eq)

///|
/// Writes the numeric target-specific flag mask in decimal form.
pub impl Show for LLVMJITSymbolTargetFlags with fn output(self, logger) {
  self.0.output(logger)
}

///|
/// Opaque pointer identity for an ORC execution session.
///
/// It is normally borrowed from an ORC JIT owner and must not outlive that owner.
#external
pub type LLVMOrcExecutionSessionRef

///|
/// Opaque pointer identity for an ORC symbol-string pool.
///
/// It is normally borrowed from an execution session and shares its lifetime.
#external
pub type LLVMOrcSymbolStringPoolRef

///|
/// Opaque pointer identity for a reference-counted ORC symbol-pool entry.
///
/// Retain/release APIs, not this type, control the entry's reference count.
#external
pub type LLVMOrcSymbolStringPoolEntryRef

///|
/// Compares LLVM type handles by native pointer identity, not structure.
pub impl Eq for LLVMTypeRef with fn equal(
  self : LLVMTypeRef,
  other : LLVMTypeRef,
) -> Bool {
  self.is_equal(other)
}

///|
/// Compares LLVM value handles by native pointer identity, not IR equality.
pub impl Eq for LLVMValueRef with fn equal(
  self : LLVMValueRef,
  other : LLVMValueRef,
) -> Bool {
  self.is_equal(other)
}

///|
/// Compares LLVM context handles by native pointer identity.
pub impl Eq for LLVMContextRef with fn equal(
  self : LLVMContextRef,
  other : LLVMContextRef,
) -> Bool {
  self.is_equal(other)
}

///|
/// Compares LLVM attribute handles by native pointer identity.
pub impl Eq for LLVMAttributeRef with fn equal(
  self : LLVMAttributeRef,
  other : LLVMAttributeRef,
) -> Bool {
  self.is_equal(other)
}

///|
/// Compares LLVM basic-block handles by native pointer identity.
pub impl Eq for LLVMBasicBlockRef with fn equal(
  self : LLVMBasicBlockRef,
  other : LLVMBasicBlockRef,
) -> Bool {
  self.is_equal(other)
}

///|
/// Returns the wrapped raw DWARF type-encoding number.
pub fn LLVMDWARFTypeEncoding::into(self : LLVMDWARFTypeEncoding) -> UInt {
  guard self is LLVMDWARFTypeEncoding(val)
  val
}

///|
/// Returns the wrapped raw metadata-kind identifier.
pub fn LLVMMetadataKind::into(self : LLVMMetadataKind) -> UInt {
  guard self is LLVMMetadataKind(val)
  val
}

// enums

///|
/// LLVM 19 instruction and constant-expression opcode categories.
///
/// The integer conversion uses this binding's dense FFI index, which is
/// translated to LLVM-C in the native adapter; it is not LLVM's public numeric
/// opcode value.
pub(all) enum LLVMOpcode {
  /// Return terminator.
  LLVMRet
  /// Unconditional or conditional branch terminator.
  LLVMBr
  /// Multi-way integer switch terminator.
  LLVMSwitch
  /// Indirect branch through a block address.
  LLVMIndirectBr
  /// Call that transfers to normal or exception destinations.
  LLVMInvoke
  /// Terminator marking control flow as unreachable.
  LLVMUnreachable
  /// Call whose inline assembly can branch to listed labels.
  LLVMCallBr
  /// Floating-point negation.
  LLVMFNeg
  /// Integer addition.
  LLVMAdd
  /// Floating-point addition.
  LLVMFAdd
  /// Integer subtraction.
  LLVMSub
  /// Floating-point subtraction.
  LLVMFSub
  /// Integer multiplication.
  LLVMMul
  /// Floating-point multiplication.
  LLVMFMul
  /// Unsigned integer division.
  LLVMUDiv
  /// Signed integer division.
  LLVMSDiv
  /// Floating-point division.
  LLVMFDiv
  /// Unsigned integer remainder.
  LLVMURem
  /// Signed integer remainder.
  LLVMSRem
  /// Floating-point remainder.
  LLVMFRem
  /// Integer left shift.
  LLVMShl
  /// Logical right shift.
  LLVMLShr
  /// Arithmetic right shift.
  LLVMAShr
  /// Bitwise AND.
  LLVMAnd
  /// Bitwise OR.
  LLVMOr
  /// Bitwise exclusive OR.
  LLVMXor
  /// Stack allocation.
  LLVMAlloca
  /// Memory load.
  LLVMLoad
  /// Memory store.
  LLVMStore
  /// Get-element-pointer address calculation.
  LLVMGetElementPtr
  /// Integer truncation.
  LLVMTrunc
  /// Zero extension of an integer.
  LLVMZExt
  /// Sign extension of an integer.
  LLVMSExt
  /// Floating-point to unsigned-integer conversion.
  LLVMFPToUI
  /// Floating-point to signed-integer conversion.
  LLVMFPToSI
  /// Unsigned-integer to floating-point conversion.
  LLVMUIToFP
  /// Signed-integer to floating-point conversion.
  LLVMSIToFP
  /// Floating-point truncation.
  LLVMFPTrunc
  /// Floating-point extension.
  LLVMFPExt
  /// Pointer-to-integer conversion.
  LLVMPtrToInt
  /// Integer-to-pointer conversion.
  LLVMIntToPtr
  /// Same-size bit reinterpretation.
  LLVMBitCast
  /// Pointer address-space conversion.
  LLVMAddrSpaceCast
  /// Integer comparison.
  LLVMICmp
  /// Floating-point comparison.
  LLVMFCmp
  /// Static single-assignment PHI node.
  LLVMPHI
  /// Function or function-pointer call.
  LLVMCall
  /// Conditional value selection.
  LLVMSelect
  /// LLVM reserved user opcode 1.
  LLVMUserOp1
  /// LLVM reserved user opcode 2.
  LLVMUserOp2
  /// Variadic argument extraction.
  LLVMVAArg
  /// Vector element extraction.
  LLVMExtractElement
  /// Vector element insertion.
  LLVMInsertElement
  /// Vector lane shuffle.
  LLVMShuffleVector
  /// Aggregate value extraction.
  LLVMExtractValue
  /// Aggregate value insertion.
  LLVMInsertValue
  /// Converts poison or undef to a stable but arbitrary value.
  LLVMFreeze
  /// Atomic memory fence.
  LLVMFence
  /// Atomic compare-and-exchange.
  LLVMAtomicCmpXchg
  /// Atomic read-modify-write.
  LLVMAtomicRMW
  /// Resumes propagation of an exception.
  LLVMResume
  /// Landing pad for legacy exception handling.
  LLVMLandingPad
  /// Exits a cleanup pad.
  LLVMCleanupRet
  /// Exits a catch pad.
  LLVMCatchRet
  /// Begins a catch handler pad.
  LLVMCatchPad
  /// Begins a cleanup handler pad.
  LLVMCleanupPad
  /// Dispatches among exception catch handlers.
  LLVMCatchSwitch
}

///|
/// Prints the binding's dense FFI opcode index.
pub impl Show for LLVMOpcode with fn output(self, logger) {
  self.to_int().output(logger)
}

///|
/// Returns the binding's dense FFI index for this opcode.
pub fn LLVMOpcode::to_int(self : LLVMOpcode) -> Int {
  match self {
    LLVMRet => 0
    LLVMBr => 1
    LLVMSwitch => 2
    LLVMIndirectBr => 3
    LLVMInvoke => 4
    LLVMUnreachable => 5
    LLVMCallBr => 6
    LLVMFNeg => 7
    LLVMAdd => 8
    LLVMFAdd => 9
    LLVMSub => 10
    LLVMFSub => 11
    LLVMMul => 12
    LLVMFMul => 13
    LLVMUDiv => 14
    LLVMSDiv => 15
    LLVMFDiv => 16
    LLVMURem => 17
    LLVMSRem => 18
    LLVMFRem => 19
    LLVMShl => 20
    LLVMLShr => 21
    LLVMAShr => 22
    LLVMAnd => 23
    LLVMOr => 24
    LLVMXor => 25
    LLVMAlloca => 26
    LLVMLoad => 27
    LLVMStore => 28
    LLVMGetElementPtr => 29
    LLVMTrunc => 30
    LLVMZExt => 31
    LLVMSExt => 32
    LLVMFPToUI => 33
    LLVMFPToSI => 34
    LLVMUIToFP => 35
    LLVMSIToFP => 36
    LLVMFPTrunc => 37
    LLVMFPExt => 38
    LLVMPtrToInt => 39
    LLVMIntToPtr => 40
    LLVMBitCast => 41
    LLVMAddrSpaceCast => 42
    LLVMICmp => 43
    LLVMFCmp => 44
    LLVMPHI => 45
    LLVMCall => 46
    LLVMSelect => 47
    LLVMUserOp1 => 48
    LLVMUserOp2 => 49
    LLVMVAArg => 50
    LLVMExtractElement => 51
    LLVMInsertElement => 52
    LLVMShuffleVector => 53
    LLVMExtractValue => 54
    LLVMInsertValue => 55
    LLVMFreeze => 56
    LLVMFence => 57
    LLVMAtomicCmpXchg => 58
    LLVMAtomicRMW => 59
    LLVMResume => 60
    LLVMLandingPad => 61
    LLVMCleanupRet => 62
    LLVMCatchRet => 63
    LLVMCatchPad => 64
    LLVMCleanupPad => 65
    LLVMCatchSwitch => 66
  }
}

///|
/// Decodes the binding's dense FFI opcode index.
///
/// **Panics:** Aborts for an unknown index; this is not a checked parser for
/// arbitrary or future LLVM values.
pub fn LLVMOpcode::from_int(idx : Int) -> LLVMOpcode {
  match idx {
    0 => LLVMRet
    1 => LLVMBr
    2 => LLVMSwitch
    3 => LLVMIndirectBr
    4 => LLVMInvoke
    5 => LLVMUnreachable
    6 => LLVMCallBr
    7 => LLVMFNeg
    8 => LLVMAdd
    9 => LLVMFAdd
    10 => LLVMSub
    11 => LLVMFSub
    12 => LLVMMul
    13 => LLVMFMul
    14 => LLVMUDiv
    15 => LLVMSDiv
    16 => LLVMFDiv
    17 => LLVMURem
    18 => LLVMSRem
    19 => LLVMFRem
    20 => LLVMShl
    21 => LLVMLShr
    22 => LLVMAShr
    23 => LLVMAnd
    24 => LLVMOr
    25 => LLVMXor
    26 => LLVMAlloca
    27 => LLVMLoad
    28 => LLVMStore
    29 => LLVMGetElementPtr
    30 => LLVMTrunc
    31 => LLVMZExt
    32 => LLVMSExt
    33 => LLVMFPToUI
    34 => LLVMFPToSI
    35 => LLVMUIToFP
    36 => LLVMSIToFP
    37 => LLVMFPTrunc
    38 => LLVMFPExt
    39 => LLVMPtrToInt
    40 => LLVMIntToPtr
    41 => LLVMBitCast
    42 => LLVMAddrSpaceCast
    43 => LLVMICmp
    44 => LLVMFCmp
    45 => LLVMPHI
    46 => LLVMCall
    47 => LLVMSelect
    48 => LLVMUserOp1
    49 => LLVMUserOp2
    50 => LLVMVAArg
    51 => LLVMExtractElement
    52 => LLVMInsertElement
    53 => LLVMShuffleVector
    54 => LLVMExtractValue
    55 => LLVMInsertValue
    56 => LLVMFreeze
    57 => LLVMFence
    58 => LLVMAtomicCmpXchg
    59 => LLVMAtomicRMW
    60 => LLVMResume
    61 => LLVMLandingPad
    62 => LLVMCleanupRet
    63 => LLVMCatchRet
    64 => LLVMCatchPad
    65 => LLVMCleanupPad
    66 => LLVMCatchSwitch
    _ => abort("Invalid LLVMOpcode Number in `LLVMOpcode::from_int`")
  }
}

///|
/// LLVM 19 type categories returned by `LLVMGetTypeKind`.
pub(all) enum LLVMTypeKind {
  /// Unsized `void` type.
  LLVMVoidTypeKind
  /// IEEE binary16 floating-point type.
  LLVMHalfTypeKind
  /// IEEE binary32 floating-point type.
  LLVMFloatTypeKind
  /// IEEE binary64 floating-point type.
  LLVMDoubleTypeKind
  /// x87 80-bit floating-point type.
  LLVMX86_FP80TypeKind
  /// IEEE-style 128-bit floating-point type with a 112-bit fraction.
  LLVMFP128TypeKind
  /// PowerPC double-double 128-bit floating-point type.
  LLVMPPC_FP128TypeKind
  /// Basic-block label type.
  LLVMLabelTypeKind
  /// Arbitrary-width integer type.
  LLVMIntegerTypeKind
  /// Function signature type.
  LLVMFunctionTypeKind
  /// Structure aggregate type.
  LLVMStructTypeKind
  /// Array aggregate type.
  LLVMArrayTypeKind
  /// Opaque pointer type.
  LLVMPointerTypeKind
  /// Fixed-width SIMD vector type.
  LLVMVectorTypeKind
  /// Metadata pseudo-type.
  LLVMMetadataTypeKind
  /// Legacy x86 MMX type; unsupported by part of this binding's native adapter.
  LLVMX86_MMXTypeKind
  /// Token pseudo-type.
  LLVMTokenTypeKind
  /// Scalable SIMD vector type.
  LLVMScalableVectorTypeKind
  /// Brain floating-point 16-bit type.
  LLVMBFloatTypeKind
  /// x86 AMX tile type.
  LLVMX86_AMXTypeKind
  /// Target-defined extension type.
  LLVMTargetExtTypeKind
} derive(Eq)

///|
/// Prints the binding's dense FFI type-kind index.
pub impl Show for LLVMTypeKind with fn output(self, logger) {
  self.to_int().output(logger)
}

///|
/// Returns the binding's dense FFI index for this type category.
pub fn LLVMTypeKind::to_int(self : LLVMTypeKind) -> Int {
  match self {
    LLVMVoidTypeKind => 0
    LLVMHalfTypeKind => 1
    LLVMFloatTypeKind => 2
    LLVMDoubleTypeKind => 3
    LLVMX86_FP80TypeKind => 4
    LLVMFP128TypeKind => 5
    LLVMPPC_FP128TypeKind => 6
    LLVMLabelTypeKind => 7
    LLVMIntegerTypeKind => 8
    LLVMFunctionTypeKind => 9
    LLVMStructTypeKind => 10
    LLVMArrayTypeKind => 11
    LLVMPointerTypeKind => 12
    LLVMVectorTypeKind => 13
    LLVMMetadataTypeKind => 14
    LLVMX86_MMXTypeKind => 15
    LLVMTokenTypeKind => 16
    LLVMScalableVectorTypeKind => 17
    LLVMBFloatTypeKind => 18
    LLVMX86_AMXTypeKind => 19
    LLVMTargetExtTypeKind => 20
  }
}

///|
/// Decodes the binding's dense FFI type-kind index.
///
/// **Panics:** Aborts for an unknown index. Although index 15 maps to the legacy
/// MMX constructor here, the current native adapter does not translate that kind.
pub fn LLVMTypeKind::from_int(idx : Int) -> LLVMTypeKind {
  match idx {
    0 => LLVMVoidTypeKind
    1 => LLVMHalfTypeKind
    2 => LLVMFloatTypeKind
    3 => LLVMDoubleTypeKind
    4 => LLVMX86_FP80TypeKind
    5 => LLVMFP128TypeKind
    6 => LLVMPPC_FP128TypeKind
    7 => LLVMLabelTypeKind
    8 => LLVMIntegerTypeKind
    9 => LLVMFunctionTypeKind
    10 => LLVMStructTypeKind
    11 => LLVMArrayTypeKind
    12 => LLVMPointerTypeKind
    13 => LLVMVectorTypeKind
    14 => LLVMMetadataTypeKind
    15 => LLVMX86_MMXTypeKind
    16 => LLVMTokenTypeKind
    17 => LLVMScalableVectorTypeKind
    18 => LLVMBFloatTypeKind
    19 => LLVMX86_AMXTypeKind
    20 => LLVMTargetExtTypeKind
    _ => abort("Invalid LLVMTypeKind Number in `LLVMTypeKind::from_int`")
  }
}

///|
/// Linker visibility and coalescing policy for an LLVM global value.
pub(all) enum LLVMLinkage {
  /// Ordinary externally visible declaration or definition.
  LLVMExternalLinkage
  /// Definition available only for optimization and omitted from emitted code.
  LLVMAvailableExternallyLinkage
  /// Linker may keep any one definition.
  LLVMLinkOnceAnyLinkage
  /// Linker may keep one equivalent ODR definition.
  LLVMLinkOnceODRLinkage
  /// Obsolete auto-hide variant retained for LLVM-C compatibility.
  LLVMLinkOnceODRAutoHideLinkage
  /// Weak definition for which the linker may keep any copy.
  LLVMWeakAnyLinkage
  /// Weak definition whose copies must be ODR-equivalent.
  LLVMWeakODRLinkage
  /// Concatenates global arrays during linking.
  LLVMAppendingLinkage
  /// Module-local symbol analogous to a source-level `static` definition.
  LLVMInternalLinkage
  /// Module-local definition omitted from the object symbol table when possible.
  LLVMPrivateLinkage
  /// Obsolete DLL-import linkage retained for compatibility.
  LLVMDLLImportLinkage
  /// Obsolete DLL-export linkage retained for compatibility.
  LLVMDLLExportLinkage
  /// External reference that resolves to zero when no definition exists.
  LLVMExternalWeakLinkage
  /// Obsolete ghost linkage retained for compatibility.
  LLVMGhostLinkage
  /// Tentative common definition merged by the linker.
  LLVMCommonLinkage
  /// Linker-private symbol removed by the linker.
  LLVMLinkerPrivateLinkage
  /// Weak linker-private symbol.
  LLVMLinkerPrivateWeakLinkage
}

///|
/// Returns the binding's dense FFI index for this linkage.
pub fn LLVMLinkage::to_int(self : LLVMLinkage) -> Int {
  match self {
    LLVMExternalLinkage => 0
    LLVMAvailableExternallyLinkage => 1
    LLVMLinkOnceAnyLinkage => 2
    LLVMLinkOnceODRLinkage => 3
    LLVMLinkOnceODRAutoHideLinkage => 4
    LLVMWeakAnyLinkage => 5
    LLVMWeakODRLinkage => 6
    LLVMAppendingLinkage => 7
    LLVMInternalLinkage => 8
    LLVMPrivateLinkage => 9
    LLVMDLLImportLinkage => 10
    LLVMDLLExportLinkage => 11
    LLVMExternalWeakLinkage => 12
    LLVMGhostLinkage => 13
    LLVMCommonLinkage => 14
    LLVMLinkerPrivateLinkage => 15
    LLVMLinkerPrivateWeakLinkage => 16
  }
}

///|
fn LLVMLinkage::from_int(idx : Int) -> LLVMLinkage {
  match idx {
    0 => LLVMExternalLinkage
    1 => LLVMAvailableExternallyLinkage
    2 => LLVMLinkOnceAnyLinkage
    3 => LLVMLinkOnceODRLinkage
    4 => LLVMLinkOnceODRAutoHideLinkage
    5 => LLVMWeakAnyLinkage
    6 => LLVMWeakODRLinkage
    7 => LLVMAppendingLinkage
    8 => LLVMInternalLinkage
    9 => LLVMPrivateLinkage
    10 => LLVMDLLImportLinkage
    11 => LLVMDLLExportLinkage
    12 => LLVMExternalWeakLinkage
    13 => LLVMGhostLinkage
    14 => LLVMCommonLinkage
    15 => LLVMLinkerPrivateLinkage
    16 => LLVMLinkerPrivateWeakLinkage
    _ => abort("Invalid LLVMLinkage Number in `LLVMLinkage::from_int`")
  }
}

///|
/// Symbol visibility policy for an LLVM global value.
pub(all) enum LLVMVisibility {
  /// Visibility follows the target's ordinary default rules.
  LLVMDefaultVisibility
  /// Symbol is not preemptable or externally visible outside the linked unit.
  LLVMHiddenVisibility
  /// Symbol is externally visible but cannot be preempted within the defining unit.
  LLVMProtectedVisibility
}

///|
/// Returns the binding's dense FFI index for this visibility.
pub fn LLVMVisibility::to_int(self : LLVMVisibility) -> Int {
  match self {
    LLVMDefaultVisibility => 0
    LLVMHiddenVisibility => 1
    LLVMProtectedVisibility => 2
  }
}

///|
/// Decodes a dense visibility index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMVisibility::from_int(idx : Int) -> LLVMVisibility {
  match idx {
    0 => LLVMDefaultVisibility
    1 => LLVMHiddenVisibility
    2 => LLVMProtectedVisibility
    _ => abort("Invalid LLVMVisibility Number in `LLVMVisibility::from_int`")
  }
}

///|
/// Whether a global's address is semantically significant.
pub(all) enum LLVMUnnamedAddr {
  /// Address identity is significant.
  LLVMNoUnnamedAddr
  /// Address identity is insignificant within the current module.
  LLVMLocalUnnamedAddr
  /// Address identity is insignificant across modules.
  LLVMGlobalUnnamedAddr
} derive(Eq)

///|
/// Prints the binding's dense unnamed-address index.
pub impl Show for LLVMUnnamedAddr with fn output(self, logger) {
  self.to_int().output(logger)
}

///|
/// Returns the binding's dense FFI index for this unnamed-address state.
pub fn LLVMUnnamedAddr::to_int(self : LLVMUnnamedAddr) -> Int {
  match self {
    LLVMNoUnnamedAddr => 0
    LLVMLocalUnnamedAddr => 1
    LLVMGlobalUnnamedAddr => 2
  }
}

///|
/// Decodes a dense unnamed-address index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMUnnamedAddr::from_int(idx : Int) -> LLVMUnnamedAddr {
  match idx {
    0 => LLVMNoUnnamedAddr
    1 => LLVMLocalUnnamedAddr
    2 => LLVMGlobalUnnamedAddr
    _ => abort("Invalid LLVMUnnamedAddr Number in `LLVMUnnamedAddr::from_int`")
  }
}

///|
/// DLL import/export storage annotation for a global value.
pub(all) enum LLVMDLLStorageClass {
  /// No DLL storage annotation.
  LLVMDefaultStorageClass
  /// Symbol is imported from a DLL.
  LLVMDLLImportStorageClass
  /// Symbol is exported from a DLL.
  LLVMDLLExportStorageClass
}

///|
/// Returns the binding's dense FFI index for this DLL storage class.
pub fn LLVMDLLStorageClass::to_int(self : LLVMDLLStorageClass) -> Int {
  match self {
    LLVMDefaultStorageClass => 0
    LLVMDLLImportStorageClass => 1
    LLVMDLLExportStorageClass => 2
  }
}

///|
/// Decodes a dense DLL storage-class index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMDLLStorageClass::from_int(idx : Int) -> LLVMDLLStorageClass {
  match idx {
    0 => LLVMDefaultStorageClass
    1 => LLVMDLLImportStorageClass
    2 => LLVMDLLExportStorageClass
    _ =>
      abort(
        "Invalid LLVMDLLStorageClass Number in `LLVMDLLStorageClass::from_int`",
      )
  }
}

///|
/// Calling conventions exposed by LLVM 19's C API.
///
/// Many constructors are target-specific; using one with an incompatible target
/// or mismatching caller/callee convention can make generated code invalid.
pub(all) enum LLVMCallConv {
  /// Target's ordinary C calling convention.
  LLVMCCallConv
  /// LLVM `fastcc`, optimized for local calls rather than ABI compatibility.
  LLVMFastCallConv
  /// LLVM `coldcc`, optimized for rarely executed calls.
  LLVMColdCallConv
  /// Calling convention used by the Glasgow Haskell Compiler.
  LLVMGHCCallConv
  /// Legacy HiPE/Erlang calling convention.
  LLVMHiPECallConv
  /// LLVM `anyregcc`, allowing arguments in arbitrary registers.
  LLVMAnyRegCallConv
  /// Preserves most registers across the call.
  LLVMPreserveMostCallConv
  /// Preserves all registers except those required for the return value.
  LLVMPreserveAllCallConv
  /// Swift language calling convention.
  LLVMSwiftCallConv
  /// C++ fast thread-local-storage access convention.
  LLVMCXXFASTTLSCallConv
  /// 32-bit x86 `stdcall` convention.
  LLVMX86StdcallCallConv
  /// 32-bit x86 `fastcall` convention.
  LLVMX86FastcallCallConv
  /// ARM Procedure Call Standard convention.
  LLVMARMAPCSCallConv
  /// ARM Architecture Procedure Call Standard convention.
  LLVMARMAAPCSCallConv
  /// ARM AAPCS variant using VFP registers.
  LLVMARMAAPCSVFPCallConv
  /// MSP430 interrupt-handler convention.
  LLVMMSP430INTRCallConv
  /// 32-bit x86 C++ `thiscall` convention.
  LLVMX86ThisCallCallConv
  /// PTX kernel entry convention.
  LLVMPTXKernelCallConv
  /// PTX device-function convention.
  LLVMPTXDeviceCallConv
  /// SPIR device-function convention.
  LLVMSPIRFUNCCallConv
  /// SPIR kernel entry convention.
  LLVMSPIRKERNELCallConv
  /// Intel OpenCL built-in convention.
  LLVMIntelOCLBICallConv
  /// x86-64 System V ABI convention.
  LLVMX8664SysVCallConv
  /// Microsoft x64 ABI convention.
  LLVMWin64CallConv
  /// x86 vector-call convention.
  LLVMX86VectorCallCallConv
  /// HHVM internal convention.
  LLVMHHVMCallConv
  /// HHVM C-compatible convention.
  LLVMHHVMCCallConv
  /// x86 interrupt-handler convention.
  LLVMX86INTRCallConv
  /// AVR interrupt-handler convention.
  LLVMAVRINTRCallConv
  /// AVR signal-handler convention.
  LLVMAVRSIGNALCallConv
  /// AVR built-in function convention.
  LLVMAVRBUILTINCallConv
  /// AMDGPU vertex-shader convention.
  LLVMAMDGPUVSCallConv
  /// AMDGPU geometry-shader convention.
  LLVMAMDGPUGSCallConv
  /// AMDGPU pixel-shader convention.
  LLVMAMDGPUPSCallConv
  /// AMDGPU compute-shader convention.
  LLVMAMDGPUCSCallConv
  /// AMDGPU kernel entry convention.
  LLVMAMDGPUKERNELCallConv
  /// x86 register-call convention.
  LLVMX86RegCallCallConv
  /// AMDGPU hull-shader convention.
  LLVMAMDGPUHSCallConv
  /// MSP430 built-in function convention.
  LLVMMSP430BUILTINCallConv
  /// AMDGPU local-shader convention.
  LLVMAMDGPULSCallConv
  /// AMDGPU export-shader convention.
  LLVMAMDGPUESCallConv
}

///|
/// Returns the binding's dense FFI index for this calling convention.
pub fn LLVMCallConv::to_int(self : LLVMCallConv) -> Int {
  match self {
    LLVMCCallConv => 0
    LLVMFastCallConv => 1
    LLVMColdCallConv => 2
    LLVMGHCCallConv => 3
    LLVMHiPECallConv => 4
    LLVMAnyRegCallConv => 5
    LLVMPreserveMostCallConv => 6
    LLVMPreserveAllCallConv => 7
    LLVMSwiftCallConv => 8
    LLVMCXXFASTTLSCallConv => 9
    LLVMX86StdcallCallConv => 10
    LLVMX86FastcallCallConv => 11
    LLVMARMAPCSCallConv => 12
    LLVMARMAAPCSCallConv => 13
    LLVMARMAAPCSVFPCallConv => 14
    LLVMMSP430INTRCallConv => 15
    LLVMX86ThisCallCallConv => 16
    LLVMPTXKernelCallConv => 17
    LLVMPTXDeviceCallConv => 18
    LLVMSPIRFUNCCallConv => 19
    LLVMSPIRKERNELCallConv => 20
    LLVMIntelOCLBICallConv => 21
    LLVMX8664SysVCallConv => 22
    LLVMWin64CallConv => 23
    LLVMX86VectorCallCallConv => 24
    LLVMHHVMCallConv => 25
    LLVMHHVMCCallConv => 26
    LLVMX86INTRCallConv => 27
    LLVMAVRINTRCallConv => 28
    LLVMAVRSIGNALCallConv => 29
    LLVMAVRBUILTINCallConv => 30
    LLVMAMDGPUVSCallConv => 31
    LLVMAMDGPUGSCallConv => 32
    LLVMAMDGPUPSCallConv => 33
    LLVMAMDGPUCSCallConv => 34
    LLVMAMDGPUKERNELCallConv => 35
    LLVMX86RegCallCallConv => 36
    LLVMAMDGPUHSCallConv => 37
    LLVMMSP430BUILTINCallConv => 38
    LLVMAMDGPULSCallConv => 39
    LLVMAMDGPUESCallConv => 40
  }
}

///|
/// Decodes a dense calling-convention index.
///
/// **Panics:** Aborts for an unknown index; this does not accept LLVM's public
/// numeric calling-convention IDs directly.
pub fn LLVMCallConv::from_int(i : Int) -> LLVMCallConv {
  match i {
    0 => LLVMCCallConv
    1 => LLVMFastCallConv
    2 => LLVMColdCallConv
    3 => LLVMGHCCallConv
    4 => LLVMHiPECallConv
    5 => LLVMAnyRegCallConv
    6 => LLVMPreserveMostCallConv
    7 => LLVMPreserveAllCallConv
    8 => LLVMSwiftCallConv
    9 => LLVMCXXFASTTLSCallConv
    10 => LLVMX86StdcallCallConv
    11 => LLVMX86FastcallCallConv
    12 => LLVMARMAPCSCallConv
    13 => LLVMARMAAPCSCallConv
    14 => LLVMARMAAPCSVFPCallConv
    15 => LLVMMSP430INTRCallConv
    16 => LLVMX86ThisCallCallConv
    17 => LLVMPTXKernelCallConv
    18 => LLVMPTXDeviceCallConv
    19 => LLVMSPIRFUNCCallConv
    20 => LLVMSPIRKERNELCallConv
    21 => LLVMIntelOCLBICallConv
    22 => LLVMX8664SysVCallConv
    23 => LLVMWin64CallConv
    24 => LLVMX86VectorCallCallConv
    25 => LLVMHHVMCallConv
    26 => LLVMHHVMCCallConv
    27 => LLVMX86INTRCallConv
    28 => LLVMAVRINTRCallConv
    29 => LLVMAVRSIGNALCallConv
    30 => LLVMAVRBUILTINCallConv
    31 => LLVMAMDGPUVSCallConv
    32 => LLVMAMDGPUGSCallConv
    33 => LLVMAMDGPUPSCallConv
    34 => LLVMAMDGPUCSCallConv
    35 => LLVMAMDGPUKERNELCallConv
    36 => LLVMX86RegCallCallConv
    37 => LLVMAMDGPUHSCallConv
    38 => LLVMMSP430BUILTINCallConv
    39 => LLVMAMDGPULSCallConv
    40 => LLVMAMDGPUESCallConv
    _ => abort("Invalid LLVMCallConv Number in `LLVMCallConv::from_int`")
  }
}

///|
/// Runtime class categories returned by `LLVMGetValueKind`.
pub(all) enum LLVMValueKind {
  /// Function argument value.
  LLVMArgumentValueKind
  /// Basic block represented as a value.
  LLVMBasicBlockValueKind
  /// MemorySSA use node.
  LLVMMemoryUseValueKind
  /// MemorySSA definition node.
  LLVMMemoryDefValueKind
  /// MemorySSA PHI node.
  LLVMMemoryPhiValueKind
  /// Function global value.
  LLVMFunctionValueKind
  /// Global alias.
  LLVMGlobalAliasValueKind
  /// Indirect function (IFUNC) global value.
  LLVMGlobalIFuncValueKind
  /// Global variable.
  LLVMGlobalVariableValueKind
  /// Constant address of a basic block.
  LLVMBlockAddressValueKind
  /// Constant expression.
  LLVMConstantExprValueKind
  /// Constant array aggregate.
  LLVMConstantArrayValueKind
  /// Constant structure aggregate.
  LLVMConstantStructValueKind
  /// Constant vector aggregate.
  LLVMConstantVectorValueKind
  /// Undefined value.
  LLVMUndefValueValueKind
  /// All-zero aggregate constant.
  LLVMConstantAggregateZeroValueKind
  /// Packed constant-data array.
  LLVMConstantDataArrayValueKind
  /// Packed constant-data vector.
  LLVMConstantDataVectorValueKind
  /// Integer constant.
  LLVMConstantIntValueKind
  /// Floating-point constant.
  LLVMConstantFPValueKind
  /// Null pointer constant.
  LLVMConstantPointerNullValueKind
  /// `token none` constant.
  LLVMConstantTokenNoneValueKind
  /// Metadata wrapped as a value.
  LLVMMetadataAsValueValueKind
  /// Inline-assembly value.
  LLVMInlineAsmValueKind
  /// Any instruction value; inspect its opcode for a more specific class.
  LLVMInstructionValueKind
  /// Poison value.
  LLVMPoisonValueValueKind
  /// Target-specific `none` constant.
  LLVMConstantTargetNoneValueKind
}

///|
/// Returns the binding's dense FFI index for this value category.
pub fn LLVMValueKind::to_int(self : LLVMValueKind) -> Int {
  match self {
    LLVMArgumentValueKind => 0
    LLVMBasicBlockValueKind => 1
    LLVMMemoryUseValueKind => 2
    LLVMMemoryDefValueKind => 3
    LLVMMemoryPhiValueKind => 4
    LLVMFunctionValueKind => 5
    LLVMGlobalAliasValueKind => 6
    LLVMGlobalIFuncValueKind => 7
    LLVMGlobalVariableValueKind => 8
    LLVMBlockAddressValueKind => 9
    LLVMConstantExprValueKind => 10
    LLVMConstantArrayValueKind => 11
    LLVMConstantStructValueKind => 12
    LLVMConstantVectorValueKind => 13
    LLVMUndefValueValueKind => 14
    LLVMConstantAggregateZeroValueKind => 15
    LLVMConstantDataArrayValueKind => 16
    LLVMConstantDataVectorValueKind => 17
    LLVMConstantIntValueKind => 18
    LLVMConstantFPValueKind => 19
    LLVMConstantPointerNullValueKind => 20
    LLVMConstantTokenNoneValueKind => 21
    LLVMMetadataAsValueValueKind => 22
    LLVMInlineAsmValueKind => 23
    LLVMInstructionValueKind => 24
    LLVMPoisonValueValueKind => 25
    LLVMConstantTargetNoneValueKind => 26
  }
}

///|
/// Decodes a dense value-kind index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMValueKind::from_int(idx : Int) -> LLVMValueKind {
  match idx {
    0 => LLVMArgumentValueKind
    1 => LLVMBasicBlockValueKind
    2 => LLVMMemoryUseValueKind
    3 => LLVMMemoryDefValueKind
    4 => LLVMMemoryPhiValueKind
    5 => LLVMFunctionValueKind
    6 => LLVMGlobalAliasValueKind
    7 => LLVMGlobalIFuncValueKind
    8 => LLVMGlobalVariableValueKind
    9 => LLVMBlockAddressValueKind
    10 => LLVMConstantExprValueKind
    11 => LLVMConstantArrayValueKind
    12 => LLVMConstantStructValueKind
    13 => LLVMConstantVectorValueKind
    14 => LLVMUndefValueValueKind
    15 => LLVMConstantAggregateZeroValueKind
    16 => LLVMConstantDataArrayValueKind
    17 => LLVMConstantDataVectorValueKind
    18 => LLVMConstantIntValueKind
    19 => LLVMConstantFPValueKind
    20 => LLVMConstantPointerNullValueKind
    21 => LLVMConstantTokenNoneValueKind
    22 => LLVMMetadataAsValueValueKind
    23 => LLVMInlineAsmValueKind
    24 => LLVMInstructionValueKind
    25 => LLVMPoisonValueValueKind
    26 => LLVMConstantTargetNoneValueKind
    _ => abort("Invalid LLVMValueKind Number in `LLVMValueKind::from_int`")
  }
}

///|
/// Integer comparison predicates.
///
/// Equality ignores signedness; ordered predicates explicitly select unsigned
/// (`U*`) or two's-complement signed (`S*`) interpretation.
pub(all) enum LLVMIntPredicate {
  /// Equal.
  LLVMIntEQ
  /// Not equal.
  LLVMIntNE
  /// Unsigned greater than.
  LLVMIntUGT
  /// Unsigned greater than or equal.
  LLVMIntUGE
  /// Unsigned less than.
  LLVMIntULT
  /// Unsigned less than or equal.
  LLVMIntULE
  /// Signed greater than.
  LLVMIntSGT
  /// Signed greater than or equal.
  LLVMIntSGE
  /// Signed less than.
  LLVMIntSLT
  /// Signed less than or equal.
  LLVMIntSLE
}

///|
/// Returns the binding's dense FFI index for this integer predicate.
pub fn LLVMIntPredicate::to_int(self : LLVMIntPredicate) -> Int {
  match self {
    LLVMIntEQ => 0
    LLVMIntNE => 1
    LLVMIntUGT => 2
    LLVMIntUGE => 3
    LLVMIntULT => 4
    LLVMIntULE => 5
    LLVMIntSGT => 6
    LLVMIntSGE => 7
    LLVMIntSLT => 8
    LLVMIntSLE => 9
  }
}

///|
/// Decodes a dense integer-predicate index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMIntPredicate::from_int(idx : Int) -> LLVMIntPredicate {
  match idx {
    0 => LLVMIntEQ
    1 => LLVMIntNE
    2 => LLVMIntUGT
    3 => LLVMIntUGE
    4 => LLVMIntULT
    5 => LLVMIntULE
    6 => LLVMIntSGT
    7 => LLVMIntSGE
    8 => LLVMIntSLT
    9 => LLVMIntSLE
    _ =>
      abort("Invalid LLVMIntPredicate Number in `LLVMIntPredicate::from_int`")
  }
}

///|
/// Floating-point comparison predicates with explicit NaN behavior.
///
/// Ordered predicates are false if either operand is NaN; unordered predicates
/// are true in that case.
pub(all) enum LLVMRealPredicate {
  /// Always false.
  LLVMRealPredicateFalse
  /// Ordered and equal.
  LLVMRealOEQ
  /// Ordered and greater than.
  LLVMRealOGT
  /// Ordered and greater than or equal.
  LLVMRealOGE
  /// Ordered and less than.
  LLVMRealOLT
  /// Ordered and less than or equal.
  LLVMRealOLE
  /// Ordered and not equal.
  LLVMRealONE
  /// Ordered: neither operand is NaN.
  LLVMRealORD
  /// Unordered: at least one operand is NaN.
  LLVMRealUNO
  /// Unordered or equal.
  LLVMRealUEQ
  /// Unordered or greater than.
  LLVMRealUGT
  /// Unordered or greater than or equal.
  LLVMRealUGE
  /// Unordered or less than.
  LLVMRealULT
  /// Unordered or less than or equal.
  LLVMRealULE
  /// Unordered or not equal.
  LLVMRealUNE
  /// Always true.
  LLVMRealPredicateTrue
}

///|
/// Returns the binding's dense FFI index for this real predicate.
pub fn LLVMRealPredicate::to_int(self : LLVMRealPredicate) -> Int {
  match self {
    LLVMRealPredicateFalse => 0
    LLVMRealOEQ => 1
    LLVMRealOGT => 2
    LLVMRealOGE => 3
    LLVMRealOLT => 4
    LLVMRealOLE => 5
    LLVMRealONE => 6
    LLVMRealORD => 7
    LLVMRealUNO => 8
    LLVMRealUEQ => 9
    LLVMRealUGT => 10
    LLVMRealUGE => 11
    LLVMRealULT => 12
    LLVMRealULE => 13
    LLVMRealUNE => 14
    LLVMRealPredicateTrue => 15
  }
}

///|
/// Decodes a dense real-predicate index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMRealPredicate::from_int(idx : Int) -> LLVMRealPredicate {
  match idx {
    0 => LLVMRealPredicateFalse
    1 => LLVMRealOEQ
    2 => LLVMRealOGT
    3 => LLVMRealOGE
    4 => LLVMRealOLT
    5 => LLVMRealOLE
    6 => LLVMRealONE
    7 => LLVMRealORD
    8 => LLVMRealUNO
    9 => LLVMRealUEQ
    10 => LLVMRealUGT
    11 => LLVMRealUGE
    12 => LLVMRealULT
    13 => LLVMRealULE
    14 => LLVMRealUNE
    15 => LLVMRealPredicateTrue
    _ =>
      abort("Invalid LLVMRealPredicate Number in `LLVMRealPredicate::from_int`")
  }
}

///|
/// Kind of clause attached to a legacy landing-pad instruction.
pub(all) enum LLVMLandingPadClauseTy {
  /// Catches values matching one type-info constant.
  LLVMLandingPadCatch
  /// Filters out exceptions matching an array of type-info constants.
  LLVMLandingPadFilter
}

///|
/// Returns the binding's dense FFI index for this landing-pad clause kind.
pub fn LLVMLandingPadClauseTy::to_int(self : LLVMLandingPadClauseTy) -> Int {
  match self {
    LLVMLandingPadCatch => 0
    LLVMLandingPadFilter => 1
  }
}

///|
/// Decodes a dense landing-pad clause index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMLandingPadClauseTy::from_int(idx : Int) -> LLVMLandingPadClauseTy {
  match idx {
    0 => LLVMLandingPadCatch
    1 => LLVMLandingPadFilter
    _ =>
      abort(
        "Invalid LLVMLandingPadClauseTy Number in `LLVMLandingPadClauseTy::from_int`",
      )
  }
}

///|
/// Thread-local-storage model for an LLVM global variable.
///
/// The non-default models are target/linkage promises whose validity depends on
/// how the final object is linked and loaded.
pub(all) enum LLVMThreadLocalMode {
  /// The global is not thread-local.
  LLVMNotThreadLocal
  /// General-dynamic TLS model, valid for the broadest linkage/loading cases.
  LLVMGeneralDynamicTLSModel
  /// Local-dynamic TLS model for symbols in the current module.
  LLVMLocalDynamicTLSModel
  /// Initial-exec TLS model, requiring availability at process startup.
  LLVMInitialExecTLSModel
  /// Local-exec TLS model for non-preemptable symbols in the main executable.
  LLVMLocalExecTLSModel
}

///|
/// Returns the binding's dense FFI index for this TLS model.
pub fn LLVMThreadLocalMode::to_int(self : LLVMThreadLocalMode) -> Int {
  match self {
    LLVMNotThreadLocal => 0
    LLVMGeneralDynamicTLSModel => 1
    LLVMLocalDynamicTLSModel => 2
    LLVMInitialExecTLSModel => 3
    LLVMLocalExecTLSModel => 4
  }
}

///|
/// Decodes a dense TLS-model index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMThreadLocalMode::from_int(idx : Int) -> LLVMThreadLocalMode {
  match idx {
    0 => LLVMNotThreadLocal
    1 => LLVMGeneralDynamicTLSModel
    2 => LLVMLocalDynamicTLSModel
    3 => LLVMInitialExecTLSModel
    4 => LLVMLocalExecTLSModel
    _ =>
      abort(
        "Invalid LLVMThreadLocalMode Number in `LLVMThreadLocalMode::from_int`",
      )
  }
}

///|
/// LLVM atomic memory ordering, from weakest to strongest.
///
/// Not every ordering is legal for every load, store, fence, compare-exchange,
/// or atomic-RMW operation; callers must obey the consuming API's restrictions.
pub(all) enum LLVMAtomicOrdering {
  /// Operation is not atomic.
  LLVMAtomicOrderingNotAtomic
  /// Atomicity only, with no synchronization ordering.
  LLVMAtomicOrderingUnordered
  /// Per-location modification order without acquire/release synchronization.
  LLVMAtomicOrderingMonotonic
  /// Acquire ordering for later memory operations.
  LLVMAtomicOrderingAcquire
  /// Release ordering for earlier memory operations.
  LLVMAtomicOrderingRelease
  /// Both acquire and release ordering.
  LLVMAtomicOrderingAcquireRelease
  /// Sequential consistency in addition to acquire/release effects.
  LLVMAtomicOrderingSequentiallyConsistent
}

///|
/// Returns the binding's dense FFI index for this atomic ordering.
pub fn LLVMAtomicOrdering::to_int(self : LLVMAtomicOrdering) -> Int {
  match self {
    LLVMAtomicOrderingNotAtomic => 0
    LLVMAtomicOrderingUnordered => 1
    LLVMAtomicOrderingMonotonic => 2
    LLVMAtomicOrderingAcquire => 3
    LLVMAtomicOrderingRelease => 4
    LLVMAtomicOrderingAcquireRelease => 5
    LLVMAtomicOrderingSequentiallyConsistent => 6
  }
}

///|
/// Decodes a dense atomic-ordering index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMAtomicOrdering::from_int(idx : Int) -> LLVMAtomicOrdering {
  match idx {
    0 => LLVMAtomicOrderingNotAtomic
    1 => LLVMAtomicOrderingUnordered
    2 => LLVMAtomicOrderingMonotonic
    3 => LLVMAtomicOrderingAcquire
    4 => LLVMAtomicOrderingRelease
    5 => LLVMAtomicOrderingAcquireRelease
    6 => LLVMAtomicOrderingSequentiallyConsistent
    _ =>
      abort(
        "Invalid LLVMAtomicOrdering Number in `LLVMAtomicOrdering::from_int`",
      )
  }
}

///|
/// Operation performed by an LLVM atomic read-modify-write instruction.
pub(all) enum LLVMAtomicRMWBinOp {
  /// Exchanges the old value with the operand.
  LLVMAtomicRMWBinOpXchg
  /// Integer wrapping addition.
  LLVMAtomicRMWBinOpAdd
  /// Integer wrapping subtraction.
  LLVMAtomicRMWBinOpSub
  /// Bitwise AND.
  LLVMAtomicRMWBinOpAnd
  /// Bitwise NAND.
  LLVMAtomicRMWBinOpNand
  /// Bitwise OR.
  LLVMAtomicRMWBinOpOr
  /// Bitwise exclusive OR.
  LLVMAtomicRMWBinOpXor
  /// Signed integer maximum.
  LLVMAtomicRMWBinOpMax
  /// Signed integer minimum.
  LLVMAtomicRMWBinOpMin
  /// Unsigned integer maximum.
  LLVMAtomicRMWBinOpUMax
  /// Unsigned integer minimum.
  LLVMAtomicRMWBinOpUMin
  /// Floating-point addition.
  LLVMAtomicRMWBinOpFAdd
  /// Floating-point subtraction.
  LLVMAtomicRMWBinOpFSub
  /// Floating-point maximum.
  LLVMAtomicRMWBinOpFMax
  /// Floating-point minimum.
  LLVMAtomicRMWBinOpFMin
  /// Unsigned increment that wraps to zero at the supplied limit.
  LLVMAtomicRMWBinOpUIncWrap
  /// Unsigned decrement that wraps to the supplied limit at zero.
  LLVMAtomicRMWBinOpUDecWrap
}

///|
/// Returns the binding's dense FFI index for this atomic-RMW operation.
pub fn LLVMAtomicRMWBinOp::to_int(self : LLVMAtomicRMWBinOp) -> Int {
  match self {
    LLVMAtomicRMWBinOpXchg => 0
    LLVMAtomicRMWBinOpAdd => 1
    LLVMAtomicRMWBinOpSub => 2
    LLVMAtomicRMWBinOpAnd => 3
    LLVMAtomicRMWBinOpNand => 4
    LLVMAtomicRMWBinOpOr => 5
    LLVMAtomicRMWBinOpXor => 6
    LLVMAtomicRMWBinOpMax => 7
    LLVMAtomicRMWBinOpMin => 8
    LLVMAtomicRMWBinOpUMax => 9
    LLVMAtomicRMWBinOpUMin => 10
    LLVMAtomicRMWBinOpFAdd => 11
    LLVMAtomicRMWBinOpFSub => 12
    LLVMAtomicRMWBinOpFMax => 13
    LLVMAtomicRMWBinOpFMin => 14
    LLVMAtomicRMWBinOpUIncWrap => 15
    LLVMAtomicRMWBinOpUDecWrap => 16
  }
}

///|
/// Decodes a dense atomic-RMW operation index.
///
/// **Panics:** Aborts for an unknown index.
pub fn LLVMAtomicRMWBinOp::from_int(idx : Int) -> LLVMAtomicRMWBinOp {
  match idx {
    0 => LLVMAtomicRMWBinOpXchg
    1 => LLVMAtomicRMWBinOpAdd
    2 => LLVMAtomicRMWBinOpSub
    3 => LLVMAtomicRMWBinOpAnd
    4 => LLVMAtomicRMWBinOpNand
    5 => LLVMAtomicRMWBinOpOr
    6 => LLVMAtomicRMWBinOpXor
    7 => LLVMAtomicRMWBinOpMax
    8 => LLVMAtomicRMWBinOpMin
    9 => LLVMAtomicRMWBinOpUMax
    10 => LLVMAtomicRMWBinOpUMin
    11 => LLVMAtomicRMWBinOpFAdd
    12 => LLVMAtomicRMWBinOpFSub
    13 => LLVMAtomicRMWBinOpFMax
    14 => LLVMAtomicRMWBinOpFMin
    15 => LLVMAtomicRMWBinOpUIncWrap
    16 => LLVMAtomicRMWBinOpUDecWrap
    _ =>
      abort(
        "Invalid LLVMAtomicRMWBinOp Number in `LLVMAtomicRMWBinOp::from_int`",
      )
  }
}

///|
pub(all) enum LLVMDiagnosticSeverity {
  LLVMDSError
  LLVMDSWarning
  LLVMDSRemark
  LLVMDSNote
}

///|
pub fn LLVMDiagnosticSeverity::to_int(self : LLVMDiagnosticSeverity) -> Int {
  match self {
    LLVMDSError => 0
    LLVMDSWarning => 1
    LLVMDSRemark => 2
    LLVMDSNote => 3
  }
}

///|
pub fn LLVMDiagnosticSeverity::from_int(idx : Int) -> LLVMDiagnosticSeverity {
  match idx {
    0 => LLVMDSError
    1 => LLVMDSWarning
    2 => LLVMDSRemark
    3 => LLVMDSNote
    _ =>
      abort(
        "Invalid LLVMDiagnosticSeverity Number in `LLVMDiagnosticSeverity::from_int`",
      )
  }
}

///|
pub(all) enum LLVMInlineAsmDialect {
  LLVMInlineAsmDialectATT
  LLVMInlineAsmDialectIntel
}

///|
pub fn LLVMInlineAsmDialect::to_int(self : LLVMInlineAsmDialect) -> Int {
  match self {
    LLVMInlineAsmDialectATT => 0
    LLVMInlineAsmDialectIntel => 1
  }
}

///|
pub fn LLVMInlineAsmDialect::from_int(idx : Int) -> LLVMInlineAsmDialect {
  match idx {
    0 => LLVMInlineAsmDialectATT
    1 => LLVMInlineAsmDialectIntel
    _ =>
      abort(
        "Invalid LLVMInlineAsmDialect Number in `LLVMInlineAsmDialect::from_int`",
      )
  }
}

///|
pub(all) enum LLVMModuleFlagBehavior {
  /// 
  /// Emits an error if two values disagree, otherwise the resulting value is
  /// that of the operands.
  /// 
  /// - see Module::ModFlagBehavior::Error
  /// 
  LLVMModuleFlagBehaviorError
  /// Emits a warning if two values disagree. The result value will be the
  /// operand for the flag from the first module being linked.
  /// 
  /// - see Module::ModFlagBehavior::Warning
  /// 
  LLVMModuleFlagBehaviorWarning
  /// Adds a requirement that another module flag be present and have a
  /// specified value after linking is performed. The value must be a metadata
  /// pair, where the first element of the pair is the ID of the module flag
  /// to be restricted, and the second element of the pair is the value the
  /// module flag should be restricted to. This behavior can be used to
  /// restrict the allowable results (via triggering of an error) of linking
  /// IDs with the **Override** behavior.
  /// 
  /// - see Module::ModFlagBehavior::Require
  /// 
  LLVMModuleFlagBehaviorRequire
  /// 
  /// Uses the specified value, regardless of the behavior or value of the
  /// other module. If both modules specify **Override**, but the values
  /// differ, an error will be emitted.
  /// 
  /// - see Module::ModFlagBehavior::Override
  /// 
  LLVMModuleFlagBehaviorOverride
  /// 
  /// Appends the two values, which are required to be metadata nodes.
  /// 
  /// - see Module::ModFlagBehavior::Append
  /// 
  LLVMModuleFlagBehaviorAppend
  /// 
  /// Appends the two values, which are required to be metadata
  /// nodes. However, duplicate entries in the second list are dropped
  /// during the append operation.
  /// 
  /// - see Module::ModFlagBehavior::AppendUnique
  /// 
  LLVMModuleFlagBehaviorAppendUnique
}

///|
pub fn LLVMModuleFlagBehavior::to_int(self : LLVMModuleFlagBehavior) -> Int {
  match self {
    LLVMModuleFlagBehaviorError => 0
    LLVMModuleFlagBehaviorWarning => 1
    LLVMModuleFlagBehaviorRequire => 2
    LLVMModuleFlagBehaviorOverride => 3
    LLVMModuleFlagBehaviorAppend => 4
    LLVMModuleFlagBehaviorAppendUnique => 5
  }
}

///|
pub fn LLVMModuleFlagBehavior::from_int(idx : Int) -> LLVMModuleFlagBehavior {
  match idx {
    0 => LLVMModuleFlagBehaviorError
    1 => LLVMModuleFlagBehaviorWarning
    2 => LLVMModuleFlagBehaviorRequire
    3 => LLVMModuleFlagBehaviorOverride
    4 => LLVMModuleFlagBehaviorAppend
    5 => LLVMModuleFlagBehaviorAppendUnique
    _ =>
      abort(
        "Invalid LLVMModuleFlagBehavior Number in `LLVMModuleFlagBehavior::from_int`",
      )
  }
}

//
// /**
//  * Attribute index are either LLVMAttributeReturnIndex,
//  * LLVMAttributeFunctionIndex or a parameter number from 1 to N.
//  */
// enum {
//   LLVMAttributeReturnIndex = 0U,
//   // ISO C restricts enumerator values to range of 'int'
//   // (4294967295 is too large)
//   // LLVMAttributeFunctionIndex = ~0U,
//   LLVMAttributeFunctionIndex = -1,
// };

///|
pub(all) enum LLVMTailCallKind {
  LLVMTailCallKindNone
  LLVMTailCallKindTail
  LLVMTailCallKindMustTail
  LLVMTailCallKindNoTail
} derive(Eq)

///|
pub fn LLVMTailCallKind::to_int(self : LLVMTailCallKind) -> Int {
  match self {
    LLVMTailCallKindNone => 0
    LLVMTailCallKindTail => 1
    LLVMTailCallKindMustTail => 2
    LLVMTailCallKindNoTail => 3
  }
}

///|
pub fn LLVMTailCallKind::from_int(idx : Int) -> LLVMTailCallKind {
  match idx {
    0 => LLVMTailCallKindNone
    1 => LLVMTailCallKindTail
    2 => LLVMTailCallKindMustTail
    3 => LLVMTailCallKindNoTail
    _ =>
      abort("Invalid LLVMTailCallKind Number in `LLVMTailCallKind::from_int`")
  }
}

///|
pub(all) enum LLVMComdatSelectionKind {
  LLVMAnyComdatSelectionKind
  LLVMExactMatchComdatSelectionKind
  LLVMLargestComdatSelectionKind
  LLVMNoDeduplicateComdatSelectionKind
  LLVMSameSizeComdatSelectionKind
}

///|
pub fn LLVMComdatSelectionKind::to_int(self : LLVMComdatSelectionKind) -> Int {
  match self {
    LLVMAnyComdatSelectionKind => 0
    LLVMExactMatchComdatSelectionKind => 1
    LLVMLargestComdatSelectionKind => 2
    LLVMNoDeduplicateComdatSelectionKind => 3
    LLVMSameSizeComdatSelectionKind => 4
  }
}

///|
pub fn LLVMComdatSelectionKind::from_int(idx : Int) -> LLVMComdatSelectionKind {
  match idx {
    0 => LLVMAnyComdatSelectionKind
    1 => LLVMExactMatchComdatSelectionKind
    2 => LLVMLargestComdatSelectionKind
    3 => LLVMNoDeduplicateComdatSelectionKind
    4 => LLVMSameSizeComdatSelectionKind
    _ =>
      abort(
        "Invalid LLVMComdatSelectionKind Number in `LLVMComdatSelectionKind::from_int`",
      )
  }
}

///|
pub(all) enum LLVMLinkerMode {
  LLVMLinkerDestroySource
  LLVMLinkerPreserveSource_Removed
}

///|
pub fn LLVMLinkerMode::to_int(self : LLVMLinkerMode) -> Int {
  match self {
    LLVMLinkerDestroySource => 0
    LLVMLinkerPreserveSource_Removed => 1
  }
}

///|
pub fn LLVMLinkerMode::from_int(idx : Int) -> LLVMLinkerMode {
  match idx {
    0 => LLVMLinkerDestroySource
    1 => LLVMLinkerPreserveSource_Removed
    _ => abort("Invalid LLVMLinkerMode Number in `LLVMLinkerMode::from_int`")
  }
}

///|
pub(all) enum LLVMCodeGenOptLevel {
  LLVMCodeGenLevelNone
  LLVMCodeGenLevelLess
  LLVMCodeGenLevelDefault
  LLVMCodeGenLevelAggressive
}

///|
pub fn LLVMCodeGenOptLevel::to_int(self : LLVMCodeGenOptLevel) -> Int {
  match self {
    LLVMCodeGenLevelNone => 0
    LLVMCodeGenLevelLess => 1
    LLVMCodeGenLevelDefault => 2
    LLVMCodeGenLevelAggressive => 3
  }
}

///|
pub fn LLVMCodeGenOptLevel::from_int(idx : Int) -> LLVMCodeGenOptLevel {
  match idx {
    0 => LLVMCodeGenLevelNone
    1 => LLVMCodeGenLevelLess
    2 => LLVMCodeGenLevelDefault
    3 => LLVMCodeGenLevelAggressive
    _ =>
      abort(
        "Invalid LLVMCodeGenOptLevel Number in `LLVMCodeGenOptLevel::from_int`",
      )
  }
}

///|
pub(all) enum LLVMRelocMode {
  LLVMRelocDefault
  LLVMRelocStatic
  LLVMRelocPIC
  LLVMRelocDynamicNoPic
  LLVMRelocROPI
  LLVMRelocRWPI
  LLVMRelocROPI_RWPI
}

///|
pub fn LLVMRelocMode::to_int(self : LLVMRelocMode) -> Int {
  match self {
    LLVMRelocDefault => 0
    LLVMRelocStatic => 1
    LLVMRelocPIC => 2
    LLVMRelocDynamicNoPic => 3
    LLVMRelocROPI => 4
    LLVMRelocRWPI => 5
    LLVMRelocROPI_RWPI => 6
  }
}

///|
pub fn LLVMRelocMode::from_int(idx : Int) -> LLVMRelocMode {
  match idx {
    0 => LLVMRelocDefault
    1 => LLVMRelocStatic
    2 => LLVMRelocPIC
    3 => LLVMRelocDynamicNoPic
    4 => LLVMRelocROPI
    5 => LLVMRelocRWPI
    6 => LLVMRelocROPI_RWPI
    _ => abort("Invalid LLVMRelocMode Number in `LLVMRelocMode::from_int`")
  }
}

///|
pub(all) enum LLVMCodeModel {
  LLVMCodeModelDefault
  LLVMCodeModelJITDefault
  LLVMCodeModelTiny
  LLVMCodeModelSmall
  LLVMCodeModelKernel
  LLVMCodeModelMedium
  LLVMCodeModelLarge
}

///|
pub fn LLVMCodeModel::to_int(self : LLVMCodeModel) -> Int {
  match self {
    LLVMCodeModelDefault => 0
    LLVMCodeModelJITDefault => 1
    LLVMCodeModelTiny => 2
    LLVMCodeModelSmall => 3
    LLVMCodeModelKernel => 4
    LLVMCodeModelMedium => 5
    LLVMCodeModelLarge => 6
  }
}

///|
pub fn LLVMCodeModel::from_int(idx : Int) -> LLVMCodeModel {
  match idx {
    0 => LLVMCodeModelDefault
    1 => LLVMCodeModelJITDefault
    2 => LLVMCodeModelTiny
    3 => LLVMCodeModelSmall
    4 => LLVMCodeModelKernel
    5 => LLVMCodeModelMedium
    6 => LLVMCodeModelLarge
    _ => abort("Invalid LLVMCodeModel Number in `LLVMCodeModel::from_int`")
  }
}

///|
pub(all) enum LLVMCodeGenFileType {
  LLVMAssemblyFile
  LLVMObjectFile
}

///|
pub fn LLVMCodeGenFileType::to_int(self : LLVMCodeGenFileType) -> Int {
  match self {
    LLVMAssemblyFile => 0
    LLVMObjectFile => 1
  }
}

///|
pub fn LLVMCodeGenFileType::from_int(idx : Int) -> LLVMCodeGenFileType {
  match idx {
    0 => LLVMAssemblyFile
    1 => LLVMObjectFile
    _ =>
      abort(
        "Invalid LLVMCodeGenFileType Number in `LLVMCodeGenFileType::from_int`",
      )
  }
}

///|
pub(all) enum LLVMGlobalISelAbortMode {
  LLVMGlobalISelAbortEnable
  LLVMGlobalISelAbortDisable
  LLVMGlobalISelAbortDisableWithDiag
}

///|
pub fn LLVMGlobalISelAbortMode::to_int(self : LLVMGlobalISelAbortMode) -> Int {
  match self {
    LLVMGlobalISelAbortEnable => 0
    LLVMGlobalISelAbortDisable => 1
    LLVMGlobalISelAbortDisableWithDiag => 2
  }
}

///|
pub fn LLVMGlobalISelAbortMode::from_int(idx : Int) -> LLVMGlobalISelAbortMode {
  match idx {
    0 => LLVMGlobalISelAbortEnable
    1 => LLVMGlobalISelAbortDisable
    2 => LLVMGlobalISelAbortDisableWithDiag
    _ =>
      abort(
        "Invalid LLVMGlobalISelAbortMode Number in `LLVMGlobalISelAbortMode::from_int`",
      )
  }
}

///|
pub(all) enum LLVMBinaryType {
  // Archive file.
  LLVMBinaryTypeArchive

  // Mach-O Universal Binary file.
  LLVMBinaryTypeMachOUniversalBinary

  // COFF Import file.
  LLVMBinaryTypeCOFFImportFile

  // LLVM IR.
  LLVMBinaryTypeIR

  // Windows resource (.res) file.
  LLVMBinaryTypeWinRes

  // COFF Object file.
  LLVMBinaryTypeCOFF

  // ELF 32-bit, little endian.
  LLVMBinaryTypeELF32L

  // ELF 32-bit, big endian.
  LLVMBinaryTypeELF32B

  // ELF 64-bit, little endian.
  LLVMBinaryTypeELF64L

  // ELF 64-bit, big endian.
  LLVMBinaryTypeELF64B

  // MachO 32-bit, little endian.
  LLVMBinaryTypeMachO32L

  // MachO 32-bit, big endian.
  LLVMBinaryTypeMachO32B

  // MachO 64-bit, little endian.
  LLVMBinaryTypeMachO64L

  // MachO 64-bit, big endian.
  LLVMBinaryTypeMachO64B

  // Web Assembly.
  LLVMBinaryTypeWasm

  // Offloading fatbinary.
  LLVMBinaryTypeOffload
}

///|
pub fn LLVMBinaryType::to_int(self : LLVMBinaryType) -> Int {
  match self {
    LLVMBinaryTypeArchive => 0
    LLVMBinaryTypeMachOUniversalBinary => 1
    LLVMBinaryTypeCOFFImportFile => 2
    LLVMBinaryTypeIR => 3
    LLVMBinaryTypeWinRes => 4
    LLVMBinaryTypeCOFF => 5
    LLVMBinaryTypeELF32L => 6
    LLVMBinaryTypeELF32B => 7
    LLVMBinaryTypeELF64L => 8
    LLVMBinaryTypeELF64B => 9
    LLVMBinaryTypeMachO32L => 10
    LLVMBinaryTypeMachO32B => 11
    LLVMBinaryTypeMachO64L => 12
    LLVMBinaryTypeMachO64B => 13
    LLVMBinaryTypeWasm => 14
    LLVMBinaryTypeOffload => 15
  }
}

///|
pub fn LLVMBinaryType::from_int(idx : Int) -> LLVMBinaryType {
  match idx {
    0 => LLVMBinaryTypeArchive
    1 => LLVMBinaryTypeMachOUniversalBinary
    2 => LLVMBinaryTypeCOFFImportFile
    3 => LLVMBinaryTypeIR
    4 => LLVMBinaryTypeWinRes
    5 => LLVMBinaryTypeCOFF
    6 => LLVMBinaryTypeELF32L
    7 => LLVMBinaryTypeELF32B
    8 => LLVMBinaryTypeELF64L
    9 => LLVMBinaryTypeELF64B
    10 => LLVMBinaryTypeMachO32L
    11 => LLVMBinaryTypeMachO32B
    12 => LLVMBinaryTypeMachO64L
    13 => LLVMBinaryTypeMachO64B
    14 => LLVMBinaryTypeWasm
    15 => LLVMBinaryTypeOffload
    _ => abort("Invalid LLVMBinaryType Number in `LLVMBinaryType::from_int`")
  }
}

///|
pub(all) enum LLVMDIFlags {
  LLVMDIFlagZero
  LLVMDIFlagPrivate
  LLVMDIFlagProtected
  LLVMDIFlagPublic
  LLVMDIFlagFwdDecl
  LLVMDIFlagAppleBlock
  LLVMDIFlagReservedBit4
  LLVMDIFlagVirtual
  LLVMDIFlagArtificial
  LLVMDIFlagExplicit
  LLVMDIFlagPrototyped
  LLVMDIFlagObjcClassComplete
  LLVMDIFlagObjectPointer
  LLVMDIFlagVector
  LLVMDIFlagStaticMember
  LLVMDIFlagLValueReference
  LLVMDIFlagRValueReference
  LLVMDIFlagReserved
  LLVMDIFlagSingleInheritance
  LLVMDIFlagMultipleInheritance
  LLVMDIFlagVirtualInheritance
  LLVMDIFlagIntroducedVirtual
  LLVMDIFlagBitField
  LLVMDIFlagNoReturn
  LLVMDIFlagTypePassByValue
  LLVMDIFlagTypePassByReference
  LLVMDIFlagEnumClass
  LLVMDIFlagFixedEnum
  LLVMDIFlagThunk
  LLVMDIFlagNonTrivial
  LLVMDIFlagBigEndian
  LLVMDIFlagLittleEndian
  LLVMDIFlagIndirectVirtualBase
  LLVMDIFlagAccessibility
  LLVMDIFlagPtrToMemberRep
}

///|
pub fn LLVMDIFlags::to_int(self : LLVMDIFlags) -> Int {
  match self {
    LLVMDIFlagZero => 0
    LLVMDIFlagPrivate => 1
    LLVMDIFlagProtected => 2
    LLVMDIFlagPublic => 3
    LLVMDIFlagFwdDecl => 4
    LLVMDIFlagAppleBlock => 5
    LLVMDIFlagReservedBit4 => 6
    LLVMDIFlagVirtual => 7
    LLVMDIFlagArtificial => 8
    LLVMDIFlagExplicit => 9
    LLVMDIFlagPrototyped => 10
    LLVMDIFlagObjcClassComplete => 11
    LLVMDIFlagObjectPointer => 12
    LLVMDIFlagVector => 13
    LLVMDIFlagStaticMember => 14
    LLVMDIFlagLValueReference => 15
    LLVMDIFlagRValueReference => 16
    LLVMDIFlagReserved => 17
    LLVMDIFlagSingleInheritance => 18
    LLVMDIFlagMultipleInheritance => 19
    LLVMDIFlagVirtualInheritance => 20
    LLVMDIFlagIntroducedVirtual => 21
    LLVMDIFlagBitField => 22
    LLVMDIFlagNoReturn => 23
    LLVMDIFlagTypePassByValue => 24
    LLVMDIFlagTypePassByReference => 25
    LLVMDIFlagEnumClass => 26
    LLVMDIFlagFixedEnum => 27
    LLVMDIFlagThunk => 28
    LLVMDIFlagNonTrivial => 29
    LLVMDIFlagBigEndian => 30
    LLVMDIFlagLittleEndian => 31
    LLVMDIFlagIndirectVirtualBase => 32
    LLVMDIFlagAccessibility => 33
    LLVMDIFlagPtrToMemberRep => 34
  }
}

///|
pub fn LLVMDIFlags::from_int(idx : Int) -> LLVMDIFlags {
  match idx {
    0 => LLVMDIFlagZero
    1 => LLVMDIFlagPrivate
    2 => LLVMDIFlagProtected
    3 => LLVMDIFlagPublic
    4 => LLVMDIFlagFwdDecl
    5 => LLVMDIFlagAppleBlock
    6 => LLVMDIFlagReservedBit4
    7 => LLVMDIFlagVirtual
    8 => LLVMDIFlagArtificial
    9 => LLVMDIFlagExplicit
    10 => LLVMDIFlagPrototyped
    11 => LLVMDIFlagObjcClassComplete
    12 => LLVMDIFlagObjectPointer
    13 => LLVMDIFlagVector
    14 => LLVMDIFlagStaticMember
    15 => LLVMDIFlagLValueReference
    16 => LLVMDIFlagRValueReference
    17 => LLVMDIFlagReserved
    18 => LLVMDIFlagSingleInheritance
    19 => LLVMDIFlagMultipleInheritance
    20 => LLVMDIFlagVirtualInheritance
    21 => LLVMDIFlagIntroducedVirtual
    22 => LLVMDIFlagBitField
    23 => LLVMDIFlagNoReturn
    24 => LLVMDIFlagTypePassByValue
    25 => LLVMDIFlagTypePassByReference
    26 => LLVMDIFlagEnumClass
    27 => LLVMDIFlagFixedEnum
    28 => LLVMDIFlagThunk
    29 => LLVMDIFlagNonTrivial
    30 => LLVMDIFlagBigEndian
    31 => LLVMDIFlagLittleEndian
    32 => LLVMDIFlagIndirectVirtualBase
    33 => LLVMDIFlagAccessibility
    34 => LLVMDIFlagPtrToMemberRep
    _ => abort("Invalid LLVMDIFlags Number in `LLVMDIFlags::from_int`")
  }
}

///|
/// Source languages known by DWARF.
pub(all) enum LLVMDWARFSourceLanguage {
  LLVMDWARFSourceLanguageC89
  LLVMDWARFSourceLanguageC
  LLVMDWARFSourceLanguageAda83
  LLVMDWARFSourceLanguageC_plus_plus
  LLVMDWARFSourceLanguageCobol74
  LLVMDWARFSourceLanguageCobol85
  LLVMDWARFSourceLanguageFortran77
  LLVMDWARFSourceLanguageFortran90
  LLVMDWARFSourceLanguagePascal83
  LLVMDWARFSourceLanguageModula2
  // New in DWARF v3:
  LLVMDWARFSourceLanguageJava
  LLVMDWARFSourceLanguageC99
  LLVMDWARFSourceLanguageAda95
  LLVMDWARFSourceLanguageFortran95
  LLVMDWARFSourceLanguagePLI
  LLVMDWARFSourceLanguageObjC
  LLVMDWARFSourceLanguageObjC_plus_plus
  LLVMDWARFSourceLanguageUPC
  LLVMDWARFSourceLanguageD
  // New in DWARF v4:
  LLVMDWARFSourceLanguagePython
  // New in DWARF v5:
  LLVMDWARFSourceLanguageOpenCL
  LLVMDWARFSourceLanguageGo
  LLVMDWARFSourceLanguageModula3
  LLVMDWARFSourceLanguageHaskell
  LLVMDWARFSourceLanguageC_plus_plus_03
  LLVMDWARFSourceLanguageC_plus_plus_11
  LLVMDWARFSourceLanguageOCaml
  LLVMDWARFSourceLanguageRust
  LLVMDWARFSourceLanguageC11
  LLVMDWARFSourceLanguageSwift
  LLVMDWARFSourceLanguageJulia
  LLVMDWARFSourceLanguageDylan
  LLVMDWARFSourceLanguageC_plus_plus_14
  LLVMDWARFSourceLanguageFortran03
  LLVMDWARFSourceLanguageFortran08
  LLVMDWARFSourceLanguageRenderScript
  LLVMDWARFSourceLanguageBLISS
  LLVMDWARFSourceLanguageKotlin
  LLVMDWARFSourceLanguageZig
  LLVMDWARFSourceLanguageCrystal
  LLVMDWARFSourceLanguageC_plus_plus_17
  LLVMDWARFSourceLanguageC_plus_plus_20
  LLVMDWARFSourceLanguageC17
  LLVMDWARFSourceLanguageFortran18
  LLVMDWARFSourceLanguageAda2005
  LLVMDWARFSourceLanguageAda2012
  LLVMDWARFSourceLanguageHIP
  LLVMDWARFSourceLanguageAssembly
  LLVMDWARFSourceLanguageC_sharp
  LLVMDWARFSourceLanguageMojo
  LLVMDWARFSourceLanguageGLSL
  LLVMDWARFSourceLanguageGLSL_ES
  LLVMDWARFSourceLanguageHLSL
  LLVMDWARFSourceLanguageOpenCL_CPP
  LLVMDWARFSourceLanguageCPP_for_OpenCL
  LLVMDWARFSourceLanguageSYCL
  LLVMDWARFSourceLanguageRuby
  LLVMDWARFSourceLanguageMove
  LLVMDWARFSourceLanguageHylo
  LLVMDWARFSourceLanguageMetal

  // Vendor extensions:
  LLVMDWARFSourceLanguageMips_Assembler
  LLVMDWARFSourceLanguageGOOGLE_RenderScript
  LLVMDWARFSourceLanguageBORLAND_Delphi
}

///|
pub fn LLVMDWARFSourceLanguage::to_int(self : LLVMDWARFSourceLanguage) -> Int {
  match self {
    LLVMDWARFSourceLanguageC89 => 0
    LLVMDWARFSourceLanguageC => 1
    LLVMDWARFSourceLanguageAda83 => 2
    LLVMDWARFSourceLanguageC_plus_plus => 3
    LLVMDWARFSourceLanguageCobol74 => 4
    LLVMDWARFSourceLanguageCobol85 => 5
    LLVMDWARFSourceLanguageFortran77 => 6
    LLVMDWARFSourceLanguageFortran90 => 7
    LLVMDWARFSourceLanguagePascal83 => 8
    LLVMDWARFSourceLanguageModula2 => 9
    // New in DWARF v3:
    LLVMDWARFSourceLanguageJava => 10
    LLVMDWARFSourceLanguageC99 => 11
    LLVMDWARFSourceLanguageAda95 => 12
    LLVMDWARFSourceLanguageFortran95 => 13
    LLVMDWARFSourceLanguagePLI => 14
    LLVMDWARFSourceLanguageObjC => 15
    LLVMDWARFSourceLanguageObjC_plus_plus => 16
    LLVMDWARFSourceLanguageUPC => 17
    LLVMDWARFSourceLanguageD => 18
    // New in DWARF v4:
    LLVMDWARFSourceLanguagePython => 19
    // New in DWARF v5:
    LLVMDWARFSourceLanguageOpenCL => 20
    LLVMDWARFSourceLanguageGo => 21
    LLVMDWARFSourceLanguageModula3 => 22
    LLVMDWARFSourceLanguageHaskell => 23
    LLVMDWARFSourceLanguageC_plus_plus_03 => 24
    LLVMDWARFSourceLanguageC_plus_plus_11 => 25
    LLVMDWARFSourceLanguageOCaml => 26
    LLVMDWARFSourceLanguageRust => 27
    LLVMDWARFSourceLanguageC11 => 28
    LLVMDWARFSourceLanguageSwift => 29
    LLVMDWARFSourceLanguageJulia => 30
    LLVMDWARFSourceLanguageDylan => 31
    LLVMDWARFSourceLanguageC_plus_plus_14 => 32
    LLVMDWARFSourceLanguageFortran03 => 33
    LLVMDWARFSourceLanguageFortran08 => 34
    LLVMDWARFSourceLanguageRenderScript => 35
    LLVMDWARFSourceLanguageBLISS => 36
    LLVMDWARFSourceLanguageKotlin => 37
    LLVMDWARFSourceLanguageZig => 38
    LLVMDWARFSourceLanguageCrystal => 39
    LLVMDWARFSourceLanguageC_plus_plus_17 => 40
    LLVMDWARFSourceLanguageC_plus_plus_20 => 41
    LLVMDWARFSourceLanguageC17 => 42
    LLVMDWARFSourceLanguageFortran18 => 43
    LLVMDWARFSourceLanguageAda2005 => 44
    LLVMDWARFSourceLanguageAda2012 => 45
    LLVMDWARFSourceLanguageHIP => 46
    LLVMDWARFSourceLanguageAssembly => 47
    LLVMDWARFSourceLanguageC_sharp => 48
    LLVMDWARFSourceLanguageMojo => 49
    LLVMDWARFSourceLanguageGLSL => 50
    LLVMDWARFSourceLanguageGLSL_ES => 51
    LLVMDWARFSourceLanguageHLSL => 52
    LLVMDWARFSourceLanguageOpenCL_CPP => 53
    LLVMDWARFSourceLanguageCPP_for_OpenCL => 54
    LLVMDWARFSourceLanguageSYCL => 55
    LLVMDWARFSourceLanguageRuby => 56
    LLVMDWARFSourceLanguageMove => 57
    LLVMDWARFSourceLanguageHylo => 58
    LLVMDWARFSourceLanguageMetal => 59

    // Vendor extensions:
    LLVMDWARFSourceLanguageMips_Assembler => 60
    LLVMDWARFSourceLanguageGOOGLE_RenderScript => 61
    LLVMDWARFSourceLanguageBORLAND_Delphi => 62
  }
}

///|
pub fn LLVMDWARFSourceLanguage::from_int(i : Int) -> LLVMDWARFSourceLanguage {
  match i {
    0 => LLVMDWARFSourceLanguageC89
    1 => LLVMDWARFSourceLanguageC
    2 => LLVMDWARFSourceLanguageAda83
    3 => LLVMDWARFSourceLanguageC_plus_plus
    4 => LLVMDWARFSourceLanguageCobol74
    5 => LLVMDWARFSourceLanguageCobol85
    6 => LLVMDWARFSourceLanguageFortran77
    7 => LLVMDWARFSourceLanguageFortran90
    8 => LLVMDWARFSourceLanguagePascal83
    9 => LLVMDWARFSourceLanguageModula2
    10 => LLVMDWARFSourceLanguageJava
    11 => LLVMDWARFSourceLanguageC99
    12 => LLVMDWARFSourceLanguageAda95
    13 => LLVMDWARFSourceLanguageFortran95
    14 => LLVMDWARFSourceLanguagePLI
    15 => LLVMDWARFSourceLanguageObjC
    16 => LLVMDWARFSourceLanguageObjC_plus_plus
    17 => LLVMDWARFSourceLanguageUPC
    18 => LLVMDWARFSourceLanguageD
    19 => LLVMDWARFSourceLanguagePython
    20 => LLVMDWARFSourceLanguageOpenCL
    21 => LLVMDWARFSourceLanguageGo
    22 => LLVMDWARFSourceLanguageModula3
    23 => LLVMDWARFSourceLanguageHaskell
    24 => LLVMDWARFSourceLanguageC_plus_plus_03
    25 => LLVMDWARFSourceLanguageC_plus_plus_11
    26 => LLVMDWARFSourceLanguageOCaml
    27 => LLVMDWARFSourceLanguageRust
    28 => LLVMDWARFSourceLanguageC11
    29 => LLVMDWARFSourceLanguageSwift
    30 => LLVMDWARFSourceLanguageJulia
    31 => LLVMDWARFSourceLanguageDylan
    32 => LLVMDWARFSourceLanguageC_plus_plus_14
    33 => LLVMDWARFSourceLanguageFortran03
    34 => LLVMDWARFSourceLanguageFortran08
    35 => LLVMDWARFSourceLanguageRenderScript
    36 => LLVMDWARFSourceLanguageBLISS
    37 => LLVMDWARFSourceLanguageKotlin
    38 => LLVMDWARFSourceLanguageZig
    39 => LLVMDWARFSourceLanguageCrystal
    40 => LLVMDWARFSourceLanguageC_plus_plus_17
    41 => LLVMDWARFSourceLanguageC_plus_plus_20
    42 => LLVMDWARFSourceLanguageC17
    43 => LLVMDWARFSourceLanguageFortran18
    44 => LLVMDWARFSourceLanguageAda2005
    45 => LLVMDWARFSourceLanguageAda2012
    46 => LLVMDWARFSourceLanguageHIP
    47 => LLVMDWARFSourceLanguageAssembly
    48 => LLVMDWARFSourceLanguageC_sharp
    49 => LLVMDWARFSourceLanguageMojo
    50 => LLVMDWARFSourceLanguageGLSL
    51 => LLVMDWARFSourceLanguageGLSL_ES
    52 => LLVMDWARFSourceLanguageHLSL
    53 => LLVMDWARFSourceLanguageOpenCL_CPP
    54 => LLVMDWARFSourceLanguageCPP_for_OpenCL
    55 => LLVMDWARFSourceLanguageSYCL
    56 => LLVMDWARFSourceLanguageRuby
    57 => LLVMDWARFSourceLanguageMove
    58 => LLVMDWARFSourceLanguageHylo
    59 => LLVMDWARFSourceLanguageMetal
    60 => LLVMDWARFSourceLanguageMips_Assembler
    61 => LLVMDWARFSourceLanguageGOOGLE_RenderScript
    62 => LLVMDWARFSourceLanguageBORLAND_Delphi
    _ =>
      abort(
        "Invalid LLVMDWARFSourceLanguage Number in `LLVMDWARFSourceLanguage::from_int`",
      )
  }
}

///|
/// The amount of debug information to emit.
pub(all) enum LLVMDWARFEmissionKind {
  LLVMDWARFEmissionNone
  LLVMDWARFEmissionFull
  LLVMDWARFEmissionLineTablesOnly
}

///|
pub fn LLVMDWARFEmissionKind::to_int(self : LLVMDWARFEmissionKind) -> Int {
  match self {
    LLVMDWARFEmissionNone => 0
    LLVMDWARFEmissionFull => 1
    LLVMDWARFEmissionLineTablesOnly => 2
  }
}

///|
pub fn LLVMDWARFEmissionKind::from_int(idx : Int) -> LLVMDWARFEmissionKind {
  match idx {
    0 => LLVMDWARFEmissionNone
    1 => LLVMDWARFEmissionFull
    2 => LLVMDWARFEmissionLineTablesOnly
    _ =>
      abort(
        "Invalid LLVMDWARFEmissionKind Number in `LLVMDWARFEmissionKind::from_int`",
      )
  }
}

///|
/// The kind of metadata nodes.
pub(all) enum LLVMMDNodeKind {
  LLVMMDStringMetadataKind
  LLVMConstantAsMetadataMetadataKind
  LLVMLocalAsMetadataMetadataKind
  LLVMDistinctMDOperandPlaceholderMetadataKind
  LLVMMDTupleMetadataKind
  LLVMDILocationMetadataKind
  LLVMDIExpressionMetadataKind
  LLVMDIGlobalVariableExpressionMetadataKind
  LLVMGenericDINodeMetadataKind
  LLVMDISubrangeMetadataKind
  LLVMDIEnumeratorMetadataKind
  LLVMDIBasicTypeMetadataKind
  LLVMDIDerivedTypeMetadataKind
  LLVMDICompositeTypeMetadataKind
  LLVMDISubroutineTypeMetadataKind
  LLVMDIFileMetadataKind
  LLVMDICompileUnitMetadataKind
  LLVMDISubprogramMetadataKind
  LLVMDILexicalBlockMetadataKind
  LLVMDILexicalBlockFileMetadataKind
  LLVMDINamespaceMetadataKind
  LLVMDIModuleMetadataKind
  LLVMDITemplateTypeParameterMetadataKind
  LLVMDITemplateValueParameterMetadataKind
  LLVMDIGlobalVariableMetadataKind
  LLVMDILocalVariableMetadataKind
  LLVMDILabelMetadataKind
  LLVMDIObjCPropertyMetadataKind
  LLVMDIImportedEntityMetadataKind
  LLVMDIMacroMetadataKind
  LLVMDIMacroFileMetadataKind
  LLVMDICommonBlockMetadataKind
  LLVMDIStringTypeMetadataKind
  LLVMDIGenericSubrangeMetadataKind
  LLVMDIArgListMetadataKind
  LLVMDIAssignIDMetadataKind
}

///|
pub fn LLVMMDNodeKind::to_int(self : LLVMMDNodeKind) -> Int {
  match self {
    LLVMMDStringMetadataKind => 0
    LLVMConstantAsMetadataMetadataKind => 1
    LLVMLocalAsMetadataMetadataKind => 2
    LLVMDistinctMDOperandPlaceholderMetadataKind => 3
    LLVMMDTupleMetadataKind => 4
    LLVMDILocationMetadataKind => 5
    LLVMDIExpressionMetadataKind => 6
    LLVMDIGlobalVariableExpressionMetadataKind => 7
    LLVMGenericDINodeMetadataKind => 8
    LLVMDISubrangeMetadataKind => 9
    LLVMDIEnumeratorMetadataKind => 10
    LLVMDIBasicTypeMetadataKind => 11
    LLVMDIDerivedTypeMetadataKind => 12
    LLVMDICompositeTypeMetadataKind => 13
    LLVMDISubroutineTypeMetadataKind => 14
    LLVMDIFileMetadataKind => 15
    LLVMDICompileUnitMetadataKind => 16
    LLVMDISubprogramMetadataKind => 17
    LLVMDILexicalBlockMetadataKind => 18
    LLVMDILexicalBlockFileMetadataKind => 19
    LLVMDINamespaceMetadataKind => 20
    LLVMDIModuleMetadataKind => 21
    LLVMDITemplateTypeParameterMetadataKind => 22
    LLVMDITemplateValueParameterMetadataKind => 23
    LLVMDIGlobalVariableMetadataKind => 24
    LLVMDILocalVariableMetadataKind => 25
    LLVMDILabelMetadataKind => 26
    LLVMDIObjCPropertyMetadataKind => 27
    LLVMDIImportedEntityMetadataKind => 28
    LLVMDIMacroMetadataKind => 29
    LLVMDIMacroFileMetadataKind => 30
    LLVMDICommonBlockMetadataKind => 31
    LLVMDIStringTypeMetadataKind => 32
    LLVMDIGenericSubrangeMetadataKind => 33
    LLVMDIArgListMetadataKind => 34
    LLVMDIAssignIDMetadataKind => 35
  }
}

///|
pub fn LLVMMDNodeKind::from_int(i : Int) -> LLVMMDNodeKind {
  match i {
    0 => LLVMMDStringMetadataKind
    1 => LLVMConstantAsMetadataMetadataKind
    2 => LLVMLocalAsMetadataMetadataKind
    3 => LLVMDistinctMDOperandPlaceholderMetadataKind
    4 => LLVMMDTupleMetadataKind
    5 => LLVMDILocationMetadataKind
    6 => LLVMDIExpressionMetadataKind
    7 => LLVMDIGlobalVariableExpressionMetadataKind
    8 => LLVMGenericDINodeMetadataKind
    9 => LLVMDISubrangeMetadataKind
    10 => LLVMDIEnumeratorMetadataKind
    11 => LLVMDIBasicTypeMetadataKind
    12 => LLVMDIDerivedTypeMetadataKind
    13 => LLVMDICompositeTypeMetadataKind
    14 => LLVMDISubroutineTypeMetadataKind
    15 => LLVMDIFileMetadataKind
    16 => LLVMDICompileUnitMetadataKind
    17 => LLVMDISubprogramMetadataKind
    18 => LLVMDILexicalBlockMetadataKind
    19 => LLVMDILexicalBlockFileMetadataKind
    20 => LLVMDINamespaceMetadataKind
    21 => LLVMDIModuleMetadataKind
    22 => LLVMDITemplateTypeParameterMetadataKind
    23 => LLVMDITemplateValueParameterMetadataKind
    24 => LLVMDIGlobalVariableMetadataKind
    25 => LLVMDILocalVariableMetadataKind
    26 => LLVMDILabelMetadataKind
    27 => LLVMDIObjCPropertyMetadataKind
    28 => LLVMDIImportedEntityMetadataKind
    29 => LLVMDIMacroMetadataKind
    30 => LLVMDIMacroFileMetadataKind
    31 => LLVMDICommonBlockMetadataKind
    32 => LLVMDIStringTypeMetadataKind
    33 => LLVMDIGenericSubrangeMetadataKind
    34 => LLVMDIArgListMetadataKind
    35 => LLVMDIAssignIDMetadataKind
    _ => abort("Invalid LLVMMDNodeKind Number in `LLVMMDNodeKind::from_int`")
  }
}

///|
pub(all) enum LLVMVerifierFailureAction {
  LLVMAbortProcessAction
  LLVMPrintMessageAction
  LLVMReturnStatusAction
}

///|
pub fn LLVMVerifierFailureAction::to_int(
  self : LLVMVerifierFailureAction,
) -> Int {
  match self {
    LLVMAbortProcessAction => 0
    LLVMPrintMessageAction => 1
    LLVMReturnStatusAction => 2
  }
}

///|
pub fn LLVMVerifierFailureAction::from_int(
  idx : Int,
) -> LLVMVerifierFailureAction {
  match idx {
    0 => LLVMAbortProcessAction
    1 => LLVMPrintMessageAction
    2 => LLVMReturnStatusAction
    _ =>
      abort(
        "Invalid LLVMVerifierFailureAction Number in `LLVMVerifierFailureAction::from_int`",
      )
  }
}

///|
pub(all) enum LLVMRemarkType {
  LLVMRemarkTypeUnknown
  LLVMRemarkTypePassed
  LLVMRemarkTypeMissed
  LLVMRemarkTypeAnalysis
  LLVMRemarkTypeAnalysisFPCommute
  LLVMRemarkTypeAnalysisAliasing
  LLVMRemarkTypeFailure
}

///|
pub fn LLVMRemarkType::to_int(self : LLVMRemarkType) -> Int {
  match self {
    LLVMRemarkTypeUnknown => 0
    LLVMRemarkTypePassed => 1
    LLVMRemarkTypeMissed => 2
    LLVMRemarkTypeAnalysis => 3
    LLVMRemarkTypeAnalysisFPCommute => 4
    LLVMRemarkTypeAnalysisAliasing => 5
    LLVMRemarkTypeFailure => 6
  }
}

///|
pub fn LLVMRemarkType::from_int(idx : Int) -> LLVMRemarkType {
  match idx {
    0 => LLVMRemarkTypeUnknown
    1 => LLVMRemarkTypePassed
    2 => LLVMRemarkTypeMissed
    3 => LLVMRemarkTypeAnalysis
    4 => LLVMRemarkTypeAnalysisFPCommute
    5 => LLVMRemarkTypeAnalysisAliasing
    6 => LLVMRemarkTypeFailure
    _ => abort("Invalid LLVMRemarkType Number in `LLVMRemarkType::from_int`")
  }
}

///|
pub(all) enum LLVMJITSymbolGenericFlags {
  LLVMJITSymbolGenericFlagsNone
  LLVMJITSymbolGenericFlagsExported
  LLVMJITSymbolGenericFlagsWeak
  LLVMJITSymbolGenericFlagsCallable
  LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly
}

///|
pub fn LLVMJITSymbolGenericFlags::to_int(
  self : LLVMJITSymbolGenericFlags,
) -> Int {
  match self {
    LLVMJITSymbolGenericFlagsNone => 0
    LLVMJITSymbolGenericFlagsExported => 1
    LLVMJITSymbolGenericFlagsWeak => 2
    LLVMJITSymbolGenericFlagsCallable => 4
    LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly => 8
  }
}

///|
pub fn LLVMJITSymbolGenericFlags::from_int(
  idx : Int,
) -> LLVMJITSymbolGenericFlags {
  match idx {
    0 => LLVMJITSymbolGenericFlagsNone
    1 => LLVMJITSymbolGenericFlagsExported
    2 => LLVMJITSymbolGenericFlagsWeak
    4 => LLVMJITSymbolGenericFlagsCallable
    8 => LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly
    _ =>
      abort(
        "Invalid LLVMJITSymbolGenericFlags Number in `LLVMJITSymbolGenericFlags::from_int`",
      )
  }
}
