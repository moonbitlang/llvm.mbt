// =======================================================
// Debug information: metadata handles
// =======================================================

///|
/// A metadata handle whose lifetime is bounded by its LLVM Context.
priv struct ContextAnchoredMetadata {
  md : @raw.LLVMMetadataRef
  context : Context
}

///|
fn ContextAnchoredMetadata::new(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> ContextAnchoredMetadata {
  ContextAnchoredMetadata::{ md, context, }
}

// LLVM-C `LLVMMetadataKind` enumerator values used to classify returned nodes.

///|
const DI_SUBPROGRAM_METADATA_KIND : UInt = 17

///|
const DI_LEXICAL_BLOCK_METADATA_KIND : UInt = 18

///|
fn metadata_kind(md : @raw.LLVMMetadataRef) -> UInt {
  @raw.llvm_get_metadata_kind(md).into()
}

///|
/// Errors raised by the debug-information API.
pub suberror DebugInfoError {
  /// A node was requested from a `DIBuilder` after `DIBuilder::finalize`.
  DIBuilderFinalized
  /// `DIBuilder::createCompileUnit` was called a second time on one builder.
  ///
  /// LLVM supports exactly one compile unit per `DIBuilder`; create another
  /// builder for an additional compile unit.
  DuplicateCompileUnit
  /// A metadata operand, IR object, and builder do not share one `Context`.
  MetadataContextMismatch
}

///|
fn check_metadata_context(
  expected : Context,
  actual : Context,
) -> Unit raise DebugInfoError {
  guard expected == actual else { raise MetadataContextMismatch }
}

///|
/// Context-owned, untyped LLVM metadata such as a constant or string.
///
/// Module flags take their value as `Metadata`.
///
/// **Construction:** Use `Context::getConstantAsMetadata`,
/// `Context::getMDString`, or `Module::getModuleFlag`.
///
/// **Lifecycle:** The handle retains its `Context`; metadata is owned by that
/// context and stays valid while the handle is reachable.
pub struct Metadata {
  priv value : ContextAnchoredMetadata
}

///|
fn Metadata::from_raw(md : @raw.LLVMMetadataRef, context : Context) -> Metadata {
  Metadata::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Wraps an integer constant as metadata.
///
/// This is LLVM's `ConstantAsMetadata::get`, the representation used for
/// integer-valued module flags such as `"Dwarf Version"`.
///
/// **Errors:** Raises `MetadataContextMismatch` when `value` belongs to another
/// context.
///
/// **LLVM API:** `LLVMValueAsMetadata`.
pub fn Context::getConstantAsMetadata(
  self : Context,
  value : ConstantInt,
) -> Metadata raise DebugInfoError {
  check_metadata_context(self, value.getContext())
  Metadata::from_raw(
    @raw.llvm_value_as_metadata(value.get_raw_value_ref()),
    self,
  )
}

///|
/// Returns the uniqued metadata string `!"value"` in this context.
///
/// The string is passed with its UTF-8 byte length, so embedded NUL bytes are
/// preserved.
///
/// **LLVM API:** `LLVMMDStringInContext2`.
pub fn Context::getMDString(self : Context, value : String) -> Metadata {
  Metadata::from_raw(
    @raw.llvm_md_string_in_context2(self.get_raw_ref(), value),
    self,
  )
}

///|
/// Compares metadata by native identity; uniqued constants and strings with
/// equal contents compare equal.
pub impl Eq for Metadata with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Writes LLVM's textual form of this metadata, such as `i32 3` or `!"text"`.
///
/// Metadata nodes are printed outside a module, so their operands appear as
/// native addresses; use the module's `Show` output for stable node text.
pub impl Show for Metadata with fn output(self, logger) {
  let as_value = @raw.llvm_metadata_as_value(
    self.value.context.get_raw_ref(),
    self.value.md,
  )
  let text = @raw.llvm_print_value_to_string(as_value) catch {
    error => "<LLVM metadata text unavailable: \{error}>"
  }
  logger.write_string(text)
}

///|
/// Debug-information descriptor of a source file (`!DIFile`).
///
/// **Construction:** Use `DIBuilder::createFile`.
///
/// **Lifecycle:** Uniqued by and owned by its `Context`, which this handle
/// retains.
pub struct DIFile {
  priv value : ContextAnchoredMetadata
}

///|
fn DIFile::from_raw(md : @raw.LLVMMetadataRef, context : Context) -> DIFile {
  DIFile::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Returns the file name recorded in this descriptor.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
pub fn DIFile::getFilename(self : DIFile) -> String raise StringError {
  @raw.llvm_di_file_get_filename(self.value.md) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Returns the directory recorded in this descriptor.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
pub fn DIFile::getDirectory(self : DIFile) -> String raise StringError {
  @raw.llvm_di_file_get_directory(self.value.md) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Compares file descriptors by native identity; equal file/directory pairs
/// are uniqued to one descriptor.
pub impl Eq for DIFile with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Debug-information compile unit (`!DICompileUnit`), the root of the debug
/// information emitted for one module.
///
/// **Construction:** Use `DIBuilder::createCompileUnit`.
///
/// **Lifecycle:** A distinct node owned by its `Context`, which this handle
/// retains. Creating it also lists it in the module's `!llvm.dbg.cu`.
pub struct DICompileUnit {
  priv value : ContextAnchoredMetadata
}

///|
fn DICompileUnit::from_raw(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> DICompileUnit {
  DICompileUnit::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Compares compile units by native identity.
pub impl Eq for DICompileUnit with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Debug-information type descriptor.
///
/// Only basic types are currently constructible; they are used as subroutine
/// type operands. Line-table-only compile units do not emit them.
///
/// **Construction:** Use `DIBuilder::createBasicType`.
///
/// **Lifecycle:** Owned by its `Context`, which this handle retains.
pub struct DIType {
  priv value : ContextAnchoredMetadata
}

///|
fn DIType::from_raw(md : @raw.LLVMMetadataRef, context : Context) -> DIType {
  DIType::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Compares type descriptors by native identity.
pub impl Eq for DIType with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Debug-information function signature (`!DISubroutineType`).
///
/// **Construction:** Use `DIBuilder::createSubroutineType`.
///
/// **Lifecycle:** Uniqued by and owned by its `Context`, which this handle
/// retains.
pub struct DISubroutineType {
  priv value : ContextAnchoredMetadata
}

///|
fn DISubroutineType::from_raw(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> DISubroutineType {
  DISubroutineType::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Compares subroutine types by native identity; structurally equal types are
/// uniqued to one node.
pub impl Eq for DISubroutineType with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Debug-information descriptor of a function (`!DISubprogram`).
///
/// A definition subprogram is attached to its `Function` with
/// `Function::setSubprogram` and is the outermost scope of the function's
/// debug locations.
///
/// **Construction:** Use `DIBuilder::createFunction` or
/// `Function::getSubprogram`.
///
/// **Lifecycle:** Owned by its `Context`, which this handle retains.
pub struct DISubprogram {
  priv value : ContextAnchoredMetadata
}

///|
fn DISubprogram::from_raw(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> DISubprogram {
  DISubprogram::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Returns the source line recorded for this subprogram.
pub fn DISubprogram::getLine(self : DISubprogram) -> UInt {
  @raw.llvm_di_subprogram_get_line(self.value.md)
}

///|
/// Compares subprograms by native identity.
pub impl Eq for DISubprogram with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Debug-information lexical block (`!DILexicalBlock`), a nested local scope
/// such as a block statement or closure body.
///
/// **Construction:** Use `DIBuilder::createLexicalBlock`.
///
/// **Lifecycle:** A distinct node owned by its `Context`, which this handle
/// retains.
pub struct DILexicalBlock {
  priv value : ContextAnchoredMetadata
}

///|
fn DILexicalBlock::from_raw(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> DILexicalBlock {
  DILexicalBlock::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
/// Compares lexical blocks by native identity.
pub impl Eq for DILexicalBlock with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Source location attached to instructions (`!DILocation`).
///
/// **Construction:** Use `Context::createDebugLocation`,
/// `IRBuilder::getCurrentDebugLocation`, or `Instruction::getDebugLoc`.
///
/// **Lifecycle:** Uniqued by and owned by its `Context`, which this handle
/// retains.
pub struct DILocation {
  priv value : ContextAnchoredMetadata
}

///|
fn DILocation::from_raw(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> DILocation {
  DILocation::{ value: ContextAnchoredMetadata::new(md, context), }
}

///|
fn DILocation::from_nullable(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> DILocation? {
  unless(md.is_null(), () => DILocation::from_raw(md, context))
}

///|
/// Returns the source line, or `0` when the location has no line.
pub fn DILocation::getLine(self : DILocation) -> UInt {
  @raw.llvm_di_location_get_line(self.value.md)
}

///|
/// Returns the source column, or `0` when the location has no column.
pub fn DILocation::getColumn(self : DILocation) -> UInt {
  @raw.llvm_di_location_get_column(self.value.md)
}

///|
/// Returns the local scope containing this location.
///
/// **Returns:** `None` only when the scope is a local-scope kind this API does
/// not model, such as `DILexicalBlockFile`.
pub fn DILocation::getScope(self : DILocation) -> &DILocalScope? {
  let scope = @raw.llvm_di_location_get_scope(self.value.md)
  init_local_scope(scope, self.value.context)
}

///|
/// Returns the call-site location this location was inlined at, if any.
pub fn DILocation::getInlinedAt(self : DILocation) -> DILocation? {
  DILocation::from_nullable(
    @raw.llvm_di_location_get_inlined_at(self.value.md),
    self.value.context,
  )
}

///|
/// Compares locations by native identity; locations with equal line, column,
/// scope, and inlined-at operands are uniqued to one node.
pub impl Eq for DILocation with fn equal(self, other) {
  self.value.md == other.value.md
}

///|
/// Creates (or returns the uniqued) source location in this context.
///
/// This is LLVM's `DILocation::get`; it does not need a `DIBuilder`.
///
/// **Parameters:**
///
/// - `line`, `column`: One-based source position; pass `0` for an unknown
///   line or column.
/// - `scope`: The innermost local scope, a `DISubprogram` or `DILexicalBlock`.
///   Its subprogram must be the one attached to the function that receives
///   the location, or the verifier rejects the module.
/// - `inlinedAt`: The call-site location when this location describes code
///   inlined into another function.
///
/// **Errors:** Raises `MetadataContextMismatch` when `scope` or `inlinedAt`
/// belongs to another context.
///
/// **LLVM API:** `LLVMDIBuilderCreateDebugLocation`.
///
/// **See also:** `IRBuilder::setCurrentDebugLocation`,
/// `Instruction::setDebugLoc`.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let mod = ctx.addModule("loc")
///   let dib = @IR.DIBuilder::new(mod)
///   let file = dib.createFile("main.runa", "/src")
///   let ty = dib.createSubroutineType(file, [])
///   let sp = dib.createFunction(file, "main", "main", file, 1, ty)
///   let loc = ctx.createDebugLocation(3, 7, sp)
///   inspect(loc.getLine(), content="3")
///   inspect(loc.getColumn(), content="7")
///   inspect(loc.getInlinedAt() is None, content="true")
/// }
/// ```
pub fn Context::createDebugLocation(
  self : Context,
  line : UInt,
  column : UInt,
  scope : &DILocalScope,
  inlinedAt? : DILocation,
) -> DILocation raise DebugInfoError {
  check_metadata_context(self, scope.get_local_scope_context())
  let inlined_at = match inlinedAt {
    Some(location) => {
      check_metadata_context(self, location.value.context)
      location.value.md
    }
    None => @raw.LLVMMetadataRef::null()
  }
  let md = @raw.llvm_di_builder_create_debug_location(
    self.get_raw_ref(),
    line,
    column,
    scope.get_local_scope_raw(),
    inlined_at,
  )
  DILocation::from_raw(md, self)
}

// =======================================================
// Scopes
// =======================================================

///|
/// Common interface of debug-information scopes (`DIScope`).
///
/// Files, compile units, subprograms, and lexical blocks can contain other
/// debug-information entities.
///
/// **Implementor contract:** `asDIScopeEnum` must return the same live node as
/// the implementing value. External implementations are not supported.
pub trait DIScope {
  /// Returns the concrete scope classification.
  fn asDIScopeEnum(Self) -> DIScopeEnum

  /// Returns the file this scope belongs to; a `DIFile` returns itself.
  fn getFile(Self) -> DIFile? = _
}

///|
/// Closed classification of supported debug-information scopes.
pub enum DIScopeEnum {
  /// A source file scope.
  DIFile(DIFile)
  /// A compile unit scope.
  DICompileUnit(DICompileUnit)
  /// A function scope.
  DISubprogram(DISubprogram)
  /// A nested lexical block scope.
  DILexicalBlock(DILexicalBlock)
}

///|
fn &DIScope::get_scope_value(self : &DIScope) -> ContextAnchoredMetadata {
  match self.asDIScopeEnum() {
    DIFile(scope) => scope.value
    DICompileUnit(scope) => scope.value
    DISubprogram(scope) => scope.value
    DILexicalBlock(scope) => scope.value
  }
}

///|
impl DIScope with fn getFile(self) {
  let value = (self : &DIScope).get_scope_value()
  let file = @raw.llvm_di_scope_get_file(value.md)
  unless(file.is_null(), () => DIFile::from_raw(file, value.context))
}

///|
/// Classifies this file as `DIScopeEnum::DIFile`.
pub impl DIScope for DIFile with fn asDIScopeEnum(self) {
  DIFile(self)
}

///|
/// Classifies this compile unit as `DIScopeEnum::DICompileUnit`.
pub impl DIScope for DICompileUnit with fn asDIScopeEnum(self) {
  DICompileUnit(self)
}

///|
/// Classifies this subprogram as `DIScopeEnum::DISubprogram`.
pub impl DIScope for DISubprogram with fn asDIScopeEnum(self) {
  DISubprogram(self)
}

///|
/// Classifies this lexical block as `DIScopeEnum::DILexicalBlock`.
pub impl DIScope for DILexicalBlock with fn asDIScopeEnum(self) {
  DILexicalBlock(self)
}

///|
/// Scopes that may contain source locations (`DILocalScope`): subprograms and
/// lexical blocks.
///
/// **Implementor contract:** `asDILocalScopeEnum` must return the same live
/// node as the implementing value. External implementations are not
/// supported.
pub trait DILocalScope: DIScope {
  /// Returns the concrete local-scope classification.
  fn asDILocalScopeEnum(Self) -> DILocalScopeEnum
}

///|
/// Closed classification of supported local scopes.
pub enum DILocalScopeEnum {
  /// A function scope.
  DISubprogram(DISubprogram)
  /// A nested lexical block scope.
  DILexicalBlock(DILexicalBlock)
}

///|
/// Classifies this subprogram as `DILocalScopeEnum::DISubprogram`.
pub impl DILocalScope for DISubprogram with fn asDILocalScopeEnum(self) {
  DISubprogram(self)
}

///|
/// Classifies this lexical block as `DILocalScopeEnum::DILexicalBlock`.
pub impl DILocalScope for DILexicalBlock with fn asDILocalScopeEnum(self) {
  DILexicalBlock(self)
}

///|
fn &DILocalScope::get_local_scope_raw(
  self : &DILocalScope,
) -> @raw.LLVMMetadataRef {
  match self.asDILocalScopeEnum() {
    DISubprogram(scope) => scope.value.md
    DILexicalBlock(scope) => scope.value.md
  }
}

///|
fn &DILocalScope::get_local_scope_context(self : &DILocalScope) -> Context {
  match self.asDILocalScopeEnum() {
    DISubprogram(scope) => scope.value.context
    DILexicalBlock(scope) => scope.value.context
  }
}

///|
fn init_local_scope(
  md : @raw.LLVMMetadataRef,
  context : Context,
) -> &DILocalScope? {
  guard !md.is_null() else { None }
  match metadata_kind(md) {
    DI_SUBPROGRAM_METADATA_KIND =>
      Some(DISubprogram::from_raw(md, context) as &DILocalScope)
    DI_LEXICAL_BLOCK_METADATA_KIND =>
      Some(DILexicalBlock::from_raw(md, context))
    _ => None
  }
}

// =======================================================
// Enums and flags
// =======================================================

///|
/// Source language recorded in a compile unit (`DW_LANG_*`).
///
/// Only commonly used languages are listed; the values map to LLVM-C's
/// `LLVMDWARFSourceLanguage` enumerators. A language without a dedicated tag
/// commonly uses `C11` or `C99` so debuggers apply C-like expression rules.
pub(all) enum DWARFSourceLanguage {
  /// `DW_LANG_C89`.
  C89
  /// `DW_LANG_C`.
  C
  /// `DW_LANG_C99`.
  C99
  /// `DW_LANG_C11`.
  C11
  /// `DW_LANG_C17`.
  C17
  /// `DW_LANG_C_plus_plus`.
  CPlusPlus
  /// `DW_LANG_C_plus_plus_11`.
  CPlusPlus11
  /// `DW_LANG_C_plus_plus_14`.
  CPlusPlus14
  /// `DW_LANG_C_plus_plus_17`.
  CPlusPlus17
  /// `DW_LANG_C_plus_plus_20`.
  CPlusPlus20
  /// `DW_LANG_ObjC`.
  ObjC
  /// `DW_LANG_Go`.
  Go
  /// `DW_LANG_Haskell`.
  Haskell
  /// `DW_LANG_OCaml`.
  OCaml
  /// `DW_LANG_Rust`.
  Rust
  /// `DW_LANG_Swift`.
  Swift
  /// `DW_LANG_Julia`.
  Julia
  /// `DW_LANG_Kotlin`.
  Kotlin
  /// `DW_LANG_Zig`.
  Zig
  /// `DW_LANG_Mojo`.
  Mojo
  /// `DW_LANG_Assembly`.
  Assembly
} derive(Eq, Debug)

///|
fn DWARFSourceLanguage::to_llvm(self : DWARFSourceLanguage) -> Int {
  // Values are LLVM 22 `LLVMDWARFSourceLanguage` enumerators (dense C enum).
  match self {
    C89 => 0
    C => 1
    CPlusPlus => 3
    C99 => 11
    ObjC => 14
    Go => 21
    Haskell => 23
    CPlusPlus11 => 25
    OCaml => 26
    Rust => 27
    C11 => 28
    Swift => 29
    Julia => 30
    CPlusPlus14 => 32
    Kotlin => 37
    Zig => 38
    CPlusPlus17 => 40
    CPlusPlus20 => 41
    C17 => 42
    Assembly => 47
    Mojo => 49
  }
}

///|
/// Amount of debug information emitted for a compile unit
/// (`DICompileUnit::DebugEmissionKind`).
pub(all) enum DebugEmissionKind {
  /// Emit no debug information for this compile unit.
  NoDebug
  /// Emit full debug information, including variables and types.
  FullDebug
  /// Emit only line tables and the function entries they need.
  ///
  /// This is enough for symbolizing stack traces.
  LineTablesOnly
  /// Emit only `.loc`/`.file` directives in assembly output, without
  /// `.debug_info` entries.
  DebugDirectivesOnly
} derive(Eq, Debug)

///|
fn DebugEmissionKind::to_llvm(self : DebugEmissionKind) -> Int {
  match self {
    NoDebug => 0
    FullDebug => 1
    LineTablesOnly => 2
    DebugDirectivesOnly => 3
  }
}

///|
/// DWARF base-type encoding (`DW_ATE_*`) used by `DIBuilder::createBasicType`.
pub(all) enum DWARFTypeEncoding {
  /// `DW_ATE_address`: a machine address.
  Address
  /// `DW_ATE_boolean`.
  Boolean
  /// `DW_ATE_float`: binary floating point.
  Float
  /// `DW_ATE_signed`: signed two's-complement integer.
  Signed
  /// `DW_ATE_signed_char`.
  SignedChar
  /// `DW_ATE_unsigned`: unsigned integer.
  Unsigned
  /// `DW_ATE_unsigned_char`.
  UnsignedChar
  /// `DW_ATE_UTF`: a Unicode character.
  UTF
} derive(Eq, Debug)

///|
fn DWARFTypeEncoding::to_llvm(self : DWARFTypeEncoding) -> UInt {
  match self {
    Address => 0x01
    Boolean => 0x02
    Float => 0x04
    Signed => 0x05
    SignedChar => 0x06
    Unsigned => 0x07
    UnsignedChar => 0x08
    UTF => 0x10
  }
}

///|
/// One debug-information flag bit (`DINode::DIFlags`).
///
/// Combine flags into a `DIFlags` set. Multi-bit fields such as accessibility
/// and pointer-to-member inheritance are not exposed.
pub(all) enum DIFlag {
  /// The entity is a forward declaration.
  FwdDecl
  /// The entity is an Apple block.
  AppleBlock
  /// The member or base is virtual.
  Virtual
  /// The entity was generated by the compiler rather than written by the user.
  Artificial
  /// The constructor or conversion is explicit.
  Explicit
  /// The function type includes a prototype.
  Prototyped
  /// The parameter is the object (`this`/`self`) pointer.
  ObjectPointer
  /// The member is static.
  StaticMember
  /// The type is an lvalue reference.
  LValueReference
  /// The type is an rvalue reference.
  RValueReference
  /// The member is a bit field.
  BitField
  /// The function does not return.
  NoReturn
  /// The type is passed by value according to the ABI.
  TypePassByValue
  /// The type is passed by reference according to the ABI.
  TypePassByReference
  /// The enumeration is a scoped enum class.
  EnumClass
  /// The subprogram is a thunk.
  Thunk
  /// The type is non-trivial for copy, move, or destruction.
  NonTrivial
  /// The type representation is big-endian.
  BigEndian
  /// The type representation is little-endian.
  LittleEndian
} derive(Eq, Debug)

///|
fn DIFlag::to_bits(self : DIFlag) -> UInt {
  match self {
    FwdDecl => 1U << 2
    AppleBlock => 1U << 3
    Virtual => 1U << 5
    Artificial => 1U << 6
    Explicit => 1U << 7
    Prototyped => 1U << 8
    ObjectPointer => 1U << 10
    StaticMember => 1U << 12
    LValueReference => 1U << 13
    RValueReference => 1U << 14
    BitField => 1U << 19
    NoReturn => 1U << 20
    TypePassByValue => 1U << 22
    TypePassByReference => 1U << 23
    EnumClass => 1U << 24
    Thunk => 1U << 25
    NonTrivial => 1U << 26
    BigEndian => 1U << 27
    LittleEndian => 1U << 28
  }
}

///|
/// A set of debug-information flags (`DINode::DIFlags`).
///
/// `DIFlags::default()` is the empty set (`FlagZero`). Sets combine with `|`.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let flags = @IR.DIFlags::new([Prototyped]) | @IR.DIFlags::new([NoReturn])
///   inspect(flags.contains(Prototyped), content="true")
///   inspect(flags.contains(Artificial), content="false")
///   inspect(@IR.DIFlags::default().contains(Prototyped), content="false")
/// }
/// ```
pub struct DIFlags {
  priv bits : UInt
} derive(Eq)

///|
/// Creates the set containing exactly `flags`.
pub fn DIFlags::new(flags : Array[DIFlag]) -> DIFlags {
  let mut bits = 0U
  for flag in flags {
    bits = bits | flag.to_bits()
  }
  DIFlags::{ bits, }
}

///|
/// Reports whether `flag` is in this set.
pub fn DIFlags::contains(self : DIFlags, flag : DIFlag) -> Bool {
  (self.bits & flag.to_bits()) != 0
}

///|
fn DIFlags::to_llvm(self : DIFlags) -> Int {
  self.bits.reinterpret_as_int()
}

///|
/// Returns the empty flag set (`DINode::FlagZero`).
pub impl Default for DIFlags with fn default() {
  DIFlags::{ bits: 0, }
}

///|
/// Returns the union of two flag sets.
pub impl BitOr for DIFlags with fn lor(self, other) {
  DIFlags::{ bits: self.bits | other.bits, }
}

// =======================================================
// DIBuilder
// =======================================================

///|
/// Builder of debug-information metadata for one module (`llvm::DIBuilder`).
///
/// A typical line-table workflow creates a file and one compile unit, then a
/// subroutine type and subprogram per function, attaches each subprogram with
/// `Function::setSubprogram`, sets builder debug locations while emitting
/// instructions, adds the `"Debug Info Version"` and `"Dwarf Version"` module
/// flags, and finally calls `finalize`.
///
/// Node constructors check that every metadata operand belongs to the
/// builder's `Context` and raise `MetadataContextMismatch` otherwise.
///
/// **Lifecycle:** The builder owns its native `DIBuilder` and retains its
/// module. Created metadata is owned by the context and stays valid after the
/// builder is released. Releasing the builder does not finalize it:
/// call `finalize` explicitly before verifying or emitting the module.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let mod = ctx.addModule("dbg")
///   let dib = @IR.DIBuilder::new(mod)
///   let file = dib.createFile("main.runa", "/src")
///   dib.createCompileUnit(C11, file, "runa", emissionKind=LineTablesOnly)
///   |> ignore
///   let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
///   let main = mod.addFunction(fty, "main")
///   let sp = dib.createFunction(
///     file,
///     "main",
///     "main",
///     file,
///     1,
///     dib.createSubroutineType(file, []),
///     flags=@IR.DIFlags::new([Prototyped]),
///   )
///   main.setSubprogram(sp)
///   let builder = ctx.createBuilder()
///   builder.setInsertPoint(main.addBasicBlock(name="entry"))
///   builder.setCurrentDebugLocation(Some(ctx.createDebugLocation(2, 3, sp)))
///   builder.createRetVoid() |> ignore
///   mod.addModuleFlagInt(
///     Warning,
///     "Debug Info Version",
///     @IR.debugMetadataVersion(),
///   )
///   mod.addModuleFlagInt(Max, "Dwarf Version", 5)
///   dib.finalize()
///   mod.verify()
///   inspect(mod.getDebugMetadataVersion(), content="3")
/// }
/// ```
pub struct DIBuilder {
  priv owner : DIBuilderOwner
  priv mut finalized : Bool
  priv mut has_compile_unit : Bool
}

///|
/// Creates a debug-information builder for `mod`.
///
/// **Parameters:**
///
/// - `allowUnresolved`: When `true` (the default), unresolved nodes are
///   collected and resolved by `finalize`, as in `llvm::DIBuilder(M)`.
///
/// **Lifecycle:** The builder retains `mod`. See `DIBuilder` for the required
/// `finalize` call.
///
/// **LLVM API:** `LLVMCreateDIBuilder` or
/// `LLVMCreateDIBuilderDisallowUnresolved`.
pub fn DIBuilder::new(
  mod : Module,
  allowUnresolved? : Bool = true,
) -> DIBuilder {
  let raw = if allowUnresolved {
    @raw.llvm_create_di_builder(mod.get_raw_ref())
  } else {
    @raw.llvm_create_di_builder_disallow_unresolved(mod.get_raw_ref())
  }
  DIBuilder::{
    owner: DIBuilderOwner::new(raw, mod.get_owner()),
    finalized: false,
    has_compile_unit: false,
  }
}

///|
fn DIBuilder::get_raw_ref(self : DIBuilder) -> @raw.LLVMDIBuilderRef {
  self.owner.raw()
}

///|
fn DIBuilder::get_context(self : DIBuilder) -> Context {
  Context::from_owner(self.owner.module_owner().context())
}

///|
fn DIBuilder::check_open(self : DIBuilder) -> Context raise DebugInfoError {
  guard !self.finalized else { raise DIBuilderFinalized }
  self.get_context()
}

///|
/// Returns the module this builder writes debug information into.
pub fn DIBuilder::getModule(self : DIBuilder) -> Module {
  Module::{ owner: self.owner.module_owner(), }
}

///|
/// Reports whether `finalize` has been called.
pub fn DIBuilder::isFinalized(self : DIBuilder) -> Bool {
  self.finalized
}

///|
/// Constructs all deferred debug-information descriptors.
///
/// This finalizes every subprogram and the compile unit, and resolves
/// remaining cycles. Calling it again is a no-op.
///
/// **Preconditions:** Call it after all debug information has been created
/// and before verifying, printing for consumption, or emitting the module.
///
/// **Side effects:** Mutates debug metadata of the builder's module. Later node
/// constructors on this builder raise `DIBuilderFinalized`.
///
/// **LLVM API:** `LLVMDIBuilderFinalize`.
pub fn DIBuilder::finalize(self : DIBuilder) -> Unit {
  guard !self.finalized else { return }
  @raw.llvm_di_builder_finalize(self.get_raw_ref())
  self.finalized = true
}

///|
/// Finalizes one subprogram early; `finalize` also finalizes all of them.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`, or
/// `MetadataContextMismatch` for a subprogram from another context.
///
/// **LLVM API:** `LLVMDIBuilderFinalizeSubprogram`.
pub fn DIBuilder::finalizeSubprogram(
  self : DIBuilder,
  subprogram : DISubprogram,
) -> Unit raise DebugInfoError {
  let context = self.check_open()
  check_metadata_context(context, subprogram.value.context)
  @raw.llvm_di_builder_finalize_subprogram(
    self.get_raw_ref(),
    subprogram.value.md,
  )
}

///|
/// Creates (or returns the uniqued) descriptor for a source file.
///
/// **Parameters:**
///
/// - `filename`: The file name, absolute or relative to `directory`.
/// - `directory`: The compilation directory; may be empty.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`.
///
/// **LLVM API:** `LLVMDIBuilderCreateFile`.
pub fn DIBuilder::createFile(
  self : DIBuilder,
  filename : String,
  directory : String,
) -> DIFile raise DebugInfoError {
  let context = self.check_open()
  let md = @raw.llvm_di_builder_create_file(
    self.get_raw_ref(),
    filename,
    directory,
  )
  DIFile::from_raw(md, context)
}

///|
/// Creates the compile unit of this builder and lists it in `!llvm.dbg.cu`.
///
/// Optional arguments default to the values of `llvm::DIBuilder::createCompileUnit`.
///
/// **Parameters:**
///
/// - `lang`: The source language tag.
/// - `file`: The primary source file.
/// - `producer`: The producer string, usually the compiler name and version.
/// - `isOptimized`: Whether the code is optimized.
/// - `flags`: Command-line options recorded in the debug information.
/// - `runtimeVersion`: The Objective-C runtime version, or `0`.
/// - `emissionKind`: How much debug information to emit; `LineTablesOnly` is
///   enough for stack-trace symbolization.
/// - `splitName`: The split DWARF (`.dwo`) file name, if any.
/// - `dwoId`: The DWO identifier of a split skeleton unit.
/// - `splitDebugInlining`: Whether to emit inline info into split DWARF.
/// - `debugInfoForProfiling`: Whether to emit extra profiling information.
/// - `sysroot`, `sdk`: The system root and SDK name recorded for the unit.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`,
/// `DuplicateCompileUnit` on a second call, or `MetadataContextMismatch` for a
/// file from another context.
///
/// **Side effects:** Appends the compile unit to the module's `!llvm.dbg.cu`.
///
/// **LLVM API:** `LLVMDIBuilderCreateCompileUnit`.
///
/// **See also:** `DIBuilder` for a complete example.
pub fn DIBuilder::createCompileUnit(
  self : DIBuilder,
  lang : DWARFSourceLanguage,
  file : DIFile,
  producer : String,
  isOptimized? : Bool = false,
  flags? : String = "",
  runtimeVersion? : UInt = 0,
  emissionKind? : DebugEmissionKind = FullDebug,
  splitName? : String = "",
  dwoId? : UInt = 0,
  splitDebugInlining? : Bool = true,
  debugInfoForProfiling? : Bool = false,
  sysroot? : String = "",
  sdk? : String = "",
) -> DICompileUnit raise DebugInfoError {
  let context = self.check_open()
  check_metadata_context(context, file.value.context)
  guard !self.has_compile_unit else { raise DuplicateCompileUnit }
  let md = @raw.llvm_di_builder_create_compile_unit(
    self.get_raw_ref(),
    lang.to_llvm(),
    file.value.md,
    producer,
    isOptimized,
    flags,
    runtimeVersion,
    splitName,
    emissionKind.to_llvm(),
    dwoId,
    splitDebugInlining,
    debugInfoForProfiling,
    sysroot,
    sdk,
  )
  self.has_compile_unit = true
  DICompileUnit::from_raw(md, context)
}

///|
/// Creates a basic (scalar) type descriptor.
///
/// **Parameters:**
///
/// - `name`: The source-level type name.
/// - `sizeInBits`: The storage size in bits.
/// - `encoding`: How the bits are interpreted.
/// - `flags`: Extra flags such as `BigEndian`.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`.
///
/// **LLVM API:** `LLVMDIBuilderCreateBasicType`.
pub fn DIBuilder::createBasicType(
  self : DIBuilder,
  name : String,
  sizeInBits : UInt64,
  encoding : DWARFTypeEncoding,
  flags? : DIFlags = DIFlags::default(),
) -> DIType raise DebugInfoError {
  let context = self.check_open()
  let md = @raw.llvm_di_builder_create_basic_type(
    self.get_raw_ref(),
    name,
    sizeInBits,
    encoding.to_llvm(),
    flags.to_llvm(),
  )
  DIType::from_raw(md, context)
}

///|
/// Creates (or returns the uniqued) subroutine type.
///
/// **Parameters:**
///
/// - `file`: The file the type is described in.
/// - `parameterTypes`: DWARF-ordered types: element zero is the return type
///   (`None` for `void`), the rest are parameter types. An empty array is
///   valid and common for line-table-only debug information.
/// - `flags`: Extra flags; usually empty.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`, or
/// `MetadataContextMismatch` for an operand from another context.
///
/// **LLVM API:** `LLVMDIBuilderCreateSubroutineType`.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let dib = @IR.DIBuilder::new(ctx.addModule("types"))
///   let file = dib.createFile("main.runa", "/src")
///   let int_ty = dib.createBasicType("Int", 32, Signed)
///   let empty = dib.createSubroutineType(file, [])
///   let unary = dib.createSubroutineType(file, [Some(int_ty), Some(int_ty)])
///   inspect(empty == dib.createSubroutineType(file, []), content="true")
///   inspect(empty == unary, content="false")
/// }
/// ```
pub fn DIBuilder::createSubroutineType(
  self : DIBuilder,
  file : DIFile,
  parameterTypes : Array[DIType?],
  flags? : DIFlags = DIFlags::default(),
) -> DISubroutineType raise DebugInfoError {
  let context = self.check_open()
  check_metadata_context(context, file.value.context)
  let types : Array[@raw.LLVMMetadataRef] = []
  for ty in parameterTypes {
    match ty {
      Some(ty) => {
        check_metadata_context(context, ty.value.context)
        types.push(ty.value.md)
      }
      None => types.push(@raw.LLVMMetadataRef::null())
    }
  }
  let md = @raw.llvm_di_builder_create_subroutine_type(
    self.get_raw_ref(),
    file.value.md,
    types,
    flags.to_llvm(),
  )
  DISubroutineType::from_raw(md, context)
}

///|
/// Creates a subprogram descriptor for a function.
///
/// **Parameters:**
///
/// - `scope`: The enclosing scope, usually the `DIFile` or `DICompileUnit`.
/// - `name`: The source-level function name.
/// - `linkageName`: The symbol name; may be empty when equal to `name`.
/// - `file`, `line`: Where the function is declared.
/// - `ty`: The function's subroutine type.
/// - `isLocalToUnit`: Whether the function has internal linkage.
/// - `isDefinition`: Whether this describes a definition (the default). A
///   definition is distinct and requires a compile unit on this builder;
///   otherwise the verifier reports "subprogram definitions must have a
///   compile unit".
/// - `scopeLine`: The line where the function body starts; defaults to `line`.
/// - `flags`: Flags such as `Prototyped` or `Artificial`.
/// - `isOptimized`: Whether the function is optimized.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`, or
/// `MetadataContextMismatch` for an operand from another context.
///
/// **Lifecycle:** A definition subprogram may be attached to at most one
/// function.
///
/// **LLVM API:** `LLVMDIBuilderCreateFunction`.
///
/// **See also:** `Function::setSubprogram`, `DIBuilder` for a complete example.
pub fn DIBuilder::createFunction(
  self : DIBuilder,
  scope : &DIScope,
  name : String,
  linkageName : String,
  file : DIFile,
  line : UInt,
  ty : DISubroutineType,
  isLocalToUnit? : Bool = false,
  isDefinition? : Bool = true,
  scopeLine? : UInt,
  flags? : DIFlags = DIFlags::default(),
  isOptimized? : Bool = false,
) -> DISubprogram raise DebugInfoError {
  let context = self.check_open()
  let scope = scope.get_scope_value()
  check_metadata_context(context, scope.context)
  check_metadata_context(context, file.value.context)
  check_metadata_context(context, ty.value.context)
  let md = @raw.llvm_di_builder_create_function(
    self.get_raw_ref(),
    scope.md,
    name,
    linkageName,
    file.value.md,
    line,
    ty.value.md,
    isLocalToUnit,
    isDefinition,
    scopeLine.unwrap_or(line),
    flags.to_llvm(),
    isOptimized,
  )
  DISubprogram::from_raw(md, context)
}

///|
/// Creates a lexical block nested in `scope`.
///
/// Locations inside the block use it as their scope; its subprogram is the
/// one of `scope`.
///
/// **Parameters:**
///
/// - `scope`: The parent subprogram or lexical block.
/// - `file`, `line`, `column`: Where the block starts.
///
/// **Errors:** Raises `DIBuilderFinalized` after `finalize`, or
/// `MetadataContextMismatch` for an operand from another context.
///
/// **LLVM API:** `LLVMDIBuilderCreateLexicalBlock`.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let dib = @IR.DIBuilder::new(ctx.addModule("blocks"))
///   let file = dib.createFile("main.runa", "/src")
///   let ty = dib.createSubroutineType(file, [])
///   let sp = dib.createFunction(file, "main", "main", file, 1, ty)
///   let block = dib.createLexicalBlock(sp, file, 4, 9)
///   let loc = ctx.createDebugLocation(5, 2, block)
///   inspect(loc.getScope() is Some(_), content="true")
///   inspect(block.getFile() == Some(file), content="true")
/// }
/// ```
pub fn DIBuilder::createLexicalBlock(
  self : DIBuilder,
  scope : &DILocalScope,
  file : DIFile,
  line : UInt,
  column : UInt,
) -> DILexicalBlock raise DebugInfoError {
  let context = self.check_open()
  check_metadata_context(context, scope.get_local_scope_context())
  check_metadata_context(context, file.value.context)
  let md = @raw.llvm_di_builder_create_lexical_block(
    self.get_raw_ref(),
    scope.get_local_scope_raw(),
    file.value.md,
    line,
    column,
  )
  DILexicalBlock::from_raw(md, context)
}

///|
/// Returns the debug-metadata version this LLVM build emits
/// (`llvm::DEBUG_METADATA_VERSION`).
///
/// Record it in the `"Debug Info Version"` module flag. LLVM's IR and bitcode
/// readers strip debug information whose version flag is missing or different.
///
/// **LLVM API:** `LLVMDebugMetadataVersion`.
pub fn debugMetadataVersion() -> UInt {
  @raw.llvm_debug_metadata_version()
}
