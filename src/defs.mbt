// extern types
type CStr
type LLVMBool Int derive(Eq)

// type LLVMMemoryBufferRef
type LLVMContextRef
type LLVMModuleRef
type LLVMBasicBlockRef
// type LLVMMetadataRef
// type LLVMNamedMDNodeRef
// type LLVMValueMetadataEntry
type LLVMBuilderRef
// type LLVMDIBuilderRef
// type LLVMModuleProviderRef
// type LLVMPassManagerRef
type LLVMUseRef
type LLVMValueRef
type LLVMTypeRef
// type LLVMOperandBundleRef
// type LLVMAttributeRef
// type LLVMDiagnosticInfoRef
// type LLVMComdatRef
// type LLVMModuleFlagEntry
// type LLVMJITEventListenerRef
// type LLVMBinaryRef
// type LLVMDbgRecordRef


// pub enum IntPredicate {
//   // Equal
//   EQ
//
//   // Not equal
//   NE
//
//   // Unsigned greater than
//   UGT
//
//   // Unsigned greater than or equal
//   UGE
//
//   // Unsigned less than
//   ULT
//
//   // Unsigned greater than or equal
//   ULE
//
//   // Signed greater than
//   SGT
//
//   // Signed greater than or equal
//   SGE
//
//   // Signed less than
//   SLT
//
//   // Signed less than or equal
//   SLE
// } derive(Eq, Show, Hash)
//
// pub enum FloatPredicate {
//   /// Returns true if `left` == `right` and neither are NaN
//   OEQ
//
//   /// Returns true if `left` >= `right` and neither are NaN
//
//   OGE
//
//   /// Returns true if `left` > `right` and neither are NaN
//   OGT
//
//   /// Returns true if `left` <= `right` and neither are NaN
//   OLE
//
//   /// Returns true if `left` < `right` and neither are NaN
//   OLT
//
//   /// Returns true if `left` != `right` and neither are NaN
//   ONE
//
//   /// Returns true if neither value is NaN
//   ORD
//
//   /// Always returns false
//   PredicateFalse
//
//   /// Always returns true
//   PredicateTrue
//
//   /// Returns true if `left` == `right` or either is NaN
//   UEQ
//
//   /// Returns true if `left` >= `right` or either is NaN
//   UGE
//
//   /// Returns true if `left` > `right` or either is NaN
//   UGT
//
//   /// Returns true if `left` <= `right` or either is NaN
//   ULE
//
//   /// Returns true if `left` < `right` or either is NaN
//   ULT
//
//   /// Returns true if `left` != `right` or either is NaN
//   UNE
//
//   /// Returns true if either value is NaN
//   UNO
// } derive(Eq, Show, Hash)
//

// pub enum InstructionOpcode {
//     Add
//     AddrSpaceCast
//     Alloca
//     And
//     AShr
//     AtomicCmpXchg
//     AtomicRMW
//     BitCast
//     Br
//     Call
//     CallBr
//     CatchPad
//     CatchRet
//     CatchSwitch
//     CleanupPad
//     CleanupRet
//     ExtractElement
//     ExtractValue
//     FNeg
//     FAdd
//     FCmp
//     FDiv
//     Fence
//     FMul
//     FPExt
//     FPToSI
//     FPToUI
//     FPTrunc
//     Freeze
//     FRem
//     FSub
//     GetElementPtr
//     ICmp
//     IndirectBr
//     InsertElement
//     InsertValue
//     IntToPtr
//     Invoke
//     LandingPad
//     Load
//     LShr
//     Mul
//     Or
//     Phi
//     PtrToInt
//     Resume
//     Return
//     SDiv
//     Select
//     SExt
//     Shl
//     ShuffleVector
//     SIToFP
//     SRem
//     Store
//     Sub
//     Switch
//     Trunc
//     UDiv
//     UIToFP
//     Unreachable
//     URem
//     UserOp1
//     UserOp2
//     VAArg
//     Xor
//     ZExt
// } derive(Eq, Show, Hash)


// pub enum AtomicOrdering {
//   NotAtomic
//
//   Unordered
//
//   Monotonic
//
//   Acquire
//
//   Release
//
//   AcquireRelease
//
//   SequentiallyConsistent
// } derive(Eq, Show, Hash)
//
// pub enum AtomicRMWBinOp {
//   /// Stores to memory and returns the prior value.
//   Xchg
//
//   /// Adds to the value in memory and returns the prior value.
//   Add
//
//   /// Subtract a value off the value in memory and returns the prior value.
//   Sub
//
//   /// Bitwise and into memory and returns the prior value.
//   And
//
//   /// Bitwise nands into memory and returns the prior value.
//   Nand
//
//   /// Bitwise ors into memory and returns the prior value.
//   Or
//
//   /// Bitwise xors into memory and returns the prior value.
//   Xor
//
//   /// Sets memory to the signed-greater of the value provided and the value in memory. Returns the value that was in memory.
//   Max
//
//   /// Sets memory to the signed-lesser of the value provided and the value in memory. Returns the value that was in memory.
//   Min
//
//   /// Sets memory to the unsigned-greater of the value provided and the value in memory. Returns the value that was in memory.
//   UMax
//
//   /// Sets memory to the unsigned-lesser of the value provided and the value in memory. Returns the value that was in memory.
//   UMin
//
//   /// Adds to the float-typed value in memory and returns the prior value.
//   FAdd
//
//   /// Subtract a float-typed value off the value in memory and returns the prior value.
//   FSub
//
//   /// Sets memory to the greater of the two float-typed values, one provided and one from memory. Returns the value that was in memory.
//   FMax
//
//   /// Sets memory to the lesser of the two float-typed values, one provided and one from memory. Returns the value that was in memory.
//   FMin
// } derive(Eq, Show, Hash)
//
// pub enum OptimizationLevel {
//   None
//
//   Less
//
//   Default
//
//   Aggressive
// } derive(Eq, Show, Hash)
//
// pub enum GlobalVisibility {
//   Default
//
//   Hidden
//
//   Protected
// } derive(Eq, Show, Hash)
//
// pub enum ThreadLocalMode {
//   NotThreadLocal
//
//   GeneralDynamic
//
//   LocalDynamic
//
//   InitialExec
//
//   LocalExec
// } derive(Eq, Show, Hash)
//
// pub enum DLLStorageClass {
//   Default
//
//   DLLImport
//
//   DLLExport
// } derive(Eq, Show, Hash)
//
// pub enum InlineAsmDialect {
//   ATT
//   Intel
// } derive(Eq, Show, Hash)
