// =======================================================
// DebugInfo.h
// =======================================================
// /**
//  * The current debug metadata version number.
//  */
// unsigned LLVMDebugMetadataVersion(void);
pub extern "C" fn llvm_debug_metadata_version() -> UInt = "__llvm_debug_metadata_version"
//
// /**
//  * The version of debug metadata that's present in the provided \c Module.
//  */
// unsigned LLVMGetModuleDebugMetadataVersion(LLVMModuleRef Module);
pub extern "C" fn llvm_get_module_debug_metadata_version(mod_ref: LLVMModuleRef) -> UInt = "__llvm_get_module_debug_metadata_version"
//
// /**
//  * Strip debug info in the module if it exists.
//  * To do this, we remove all calls to the debugger intrinsics and any named
//  * metadata for debugging. We also remove debug locations for instructions.
//  * Return true if module is modified.
//  */
// LLVMBool LLVMStripModuleDebugInfo(LLVMModuleRef Module);
pub extern "C" fn llvm_strip_module_debug_info(mod_ref: LLVMModuleRef) -> LLVMBool = "__llvm_strip_module_debug_info"
//
// /**
//  * Construct a builder for a module, and do not allow for unresolved nodes
//  * attached to the module.
//  */
// LLVMDIBuilderRef LLVMCreateDIBuilderDisallowUnresolved(LLVMModuleRef M);
pub extern "C" fn llvm_create_di_builder_disallow_unresolved(mod_ref: LLVMModuleRef) -> LLVMDIBuilderRef = "__llvm_create_di_builder_disallow_unresolved"
//
// /**
//  * Construct a builder for a module and collect unresolved nodes attached
//  * to the module in order to resolve cycles during a call to
//  * \c LLVMDIBuilderFinalize.
//  */
// LLVMDIBuilderRef LLVMCreateDIBuilder(LLVMModuleRef M);
pub extern "C" fn llvm_create_di_builder(mod_ref: LLVMModuleRef) -> LLVMDIBuilderRef = "__llvm_create_di_builder"
//
// /**
//  * Deallocates the \c DIBuilder and everything it owns.
//  * @note You must call \c LLVMDIBuilderFinalize before this
//  */
// void LLVMDisposeDIBuilder(LLVMDIBuilderRef Builder);
pub extern "C" fn llvm_dispose_di_builder(builder_ref: LLVMDIBuilderRef) = "__llvm_dispose_di_builder"
//
// /**
//  * Construct any deferred debug info descriptors.
//  */
// void LLVMDIBuilderFinalize(LLVMDIBuilderRef Builder);
pub extern "C" fn llvm_di_builder_finalize(builder_ref: LLVMDIBuilderRef) = "__llvm_di_builder_finalize"
//
// /**
//  * Finalize a specific subprogram.
//  * No new variables may be added to this subprogram afterwards.
//  */
// void LLVMDIBuilderFinalizeSubprogram(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef Subprogram);
pub extern "C" fn llvm_di_builder_finalize_subprogram(builder_ref: LLVMDIBuilderRef, subprogram_ref: LLVMMetadataRef) = "__llvm_di_builder_finalize_subprogram"
//
// /**
//  * A CompileUnit provides an anchor for all debugging
//  * information generated during this instance of compilation.
//  * \param Lang          Source programming language, eg.
//  *                      \c LLVMDWARFSourceLanguageC99
//  * \param FileRef       File info.
//  * \param Producer      Identify the producer of debugging information
//  *                      and code.  Usually this is a compiler
//  *                      version string.
//  * \param ProducerLen   The length of the C string passed to \c Producer.
//  * \param isOptimized   A boolean flag which indicates whether optimization
//  *                      is enabled or not.
//  * \param Flags         This string lists command line options. This
//  *                      string is directly embedded in debug info
//  *                      output which may be used by a tool
//  *                      analyzing generated debugging information.
//  * \param FlagsLen      The length of the C string passed to \c Flags.
//  * \param RuntimeVer    This indicates runtime version for languages like
//  *                      Objective-C.
//  * \param SplitName     The name of the file that we'll split debug info
//  *                      out into.
//  * \param SplitNameLen  The length of the C string passed to \c SplitName.
//  * \param Kind          The kind of debug information to generate.
//  * \param DWOId         The DWOId if this is a split skeleton compile unit.
//  * \param SplitDebugInlining    Whether to emit inline debug info.
//  * \param DebugInfoForProfiling Whether to emit extra debug info for
//  *                              profile collection.
//  * \param SysRoot         The Clang system root (value of -isysroot).
//  * \param SysRootLen      The length of the C string passed to \c SysRoot.
//  * \param SDK           The SDK. On Darwin, the last component of the sysroot.
//  * \param SDKLen        The length of the C string passed to \c SDK.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateCompileUnit(
//     LLVMDIBuilderRef Builder, LLVMDWARFSourceLanguage Lang,
//     LLVMMetadataRef FileRef, const char *Producer, size_t ProducerLen,
//     LLVMBool isOptimized, const char *Flags, size_t FlagsLen,
//     unsigned RuntimeVer, const char *SplitName, size_t SplitNameLen,
//     LLVMDWARFEmissionKind Kind, unsigned DWOId, LLVMBool SplitDebugInlining,
//     LLVMBool DebugInfoForProfiling, const char *SysRoot, size_t SysRootLen,
//     const char *SDK, size_t SDKLen);
//
// /**
//  * Create a file descriptor to hold debugging information for a file.
//  * \param Builder      The \c DIBuilder.
//  * \param Filename     File name.
//  * \param FilenameLen  The length of the C string passed to \c Filename.
//  * \param Directory    Directory.
//  * \param DirectoryLen The length of the C string passed to \c Directory.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateFile(LLVMDIBuilderRef Builder, const char *Filename,
//                         size_t FilenameLen, const char *Directory,
//                         size_t DirectoryLen);
//
// /**
//  * Creates a new descriptor for a module with the specified parent scope.
//  * \param Builder         The \c DIBuilder.
//  * \param ParentScope     The parent scope containing this module declaration.
//  * \param Name            Module name.
//  * \param NameLen         The length of the C string passed to \c Name.
//  * \param ConfigMacros    A space-separated shell-quoted list of -D macro
//                           definitions as they would appear on a command line.
//  * \param ConfigMacrosLen The length of the C string passed to \c ConfigMacros.
//  * \param IncludePath     The path to the module map file.
//  * \param IncludePathLen  The length of the C string passed to \c IncludePath.
//  * \param APINotesFile    The path to an API notes file for the module.
//  * \param APINotesFileLen The length of the C string passed to \c APINotestFile.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateModule(LLVMDIBuilderRef Builder, LLVMMetadataRef ParentScope,
//                           const char *Name, size_t NameLen,
//                           const char *ConfigMacros, size_t ConfigMacrosLen,
//                           const char *IncludePath, size_t IncludePathLen,
//                           const char *APINotesFile, size_t APINotesFileLen);
//
// /**
//  * Creates a new descriptor for a namespace with the specified parent scope.
//  * \param Builder          The \c DIBuilder.
//  * \param ParentScope      The parent scope containing this module declaration.
//  * \param Name             NameSpace name.
//  * \param NameLen          The length of the C string passed to \c Name.
//  * \param ExportSymbols    Whether or not the namespace exports symbols, e.g.
//  *                         this is true of C++ inline namespaces.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateNameSpace(LLVMDIBuilderRef Builder,
//                              LLVMMetadataRef ParentScope,
//                              const char *Name, size_t NameLen,
//                              LLVMBool ExportSymbols);
//
// /**
//  * Create a new descriptor for the specified subprogram.
//  * \param Builder         The \c DIBuilder.
//  * \param Scope           Function scope.
//  * \param Name            Function name.
//  * \param NameLen         Length of enumeration name.
//  * \param LinkageName     Mangled function name.
//  * \param LinkageNameLen  Length of linkage name.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Function type.
//  * \param IsLocalToUnit   True if this function is not externally visible.
//  * \param IsDefinition    True if this is a function definition.
//  * \param ScopeLine       Set to the beginning of the scope this starts
//  * \param Flags           E.g.: \c LLVMDIFlagLValueReference. These flags are
//  *                        used to emit dwarf attributes.
//  * \param IsOptimized     True if optimization is ON.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateFunction(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *LinkageName, size_t LinkageNameLen,
//     LLVMMetadataRef File, unsigned LineNo, LLVMMetadataRef Ty,
//     LLVMBool IsLocalToUnit, LLVMBool IsDefinition,
//     unsigned ScopeLine, LLVMDIFlags Flags, LLVMBool IsOptimized);
//
// /**
//  * Create a descriptor for a lexical block with the specified parent context.
//  * \param Builder      The \c DIBuilder.
//  * \param Scope        Parent lexical block.
//  * \param File         Source file.
//  * \param Line         The line in the source file.
//  * \param Column       The column in the source file.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateLexicalBlock(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope,
//     LLVMMetadataRef File, unsigned Line, unsigned Column);
//
// /**
//  * Create a descriptor for a lexical block with a new file attached.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          Lexical block.
//  * \param File           Source file.
//  * \param Discriminator  DWARF path discriminator value.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateLexicalBlockFile(LLVMDIBuilderRef Builder,
//                                     LLVMMetadataRef Scope,
//                                     LLVMMetadataRef File,
//                                     unsigned Discriminator);
//
// /**
//  * Create a descriptor for an imported namespace. Suitable for e.g. C++
//  * using declarations.
//  * \param Builder    The \c DIBuilder.
//  * \param Scope      The scope this module is imported into
//  * \param File       File where the declaration is located.
//  * \param Line       Line number of the declaration.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateImportedModuleFromNamespace(LLVMDIBuilderRef Builder,
//                                                LLVMMetadataRef Scope,
//                                                LLVMMetadataRef NS,
//                                                LLVMMetadataRef File,
//                                                unsigned Line);
//
// /**
//  * Create a descriptor for an imported module that aliases another
//  * imported entity descriptor.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          The scope this module is imported into
//  * \param ImportedEntity Previous imported entity to alias.
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedModuleFromAlias(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope,
//     LLVMMetadataRef ImportedEntity, LLVMMetadataRef File, unsigned Line,
//     LLVMMetadataRef *Elements, unsigned NumElements);
//
// /**
//  * Create a descriptor for an imported module.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          The scope this module is imported into
//  * \param M              The module being imported here
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedModuleFromModule(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, LLVMMetadataRef M,
//     LLVMMetadataRef File, unsigned Line, LLVMMetadataRef *Elements,
//     unsigned NumElements);
//
// /**
//  * Create a descriptor for an imported function, type, or variable.  Suitable
//  * for e.g. FORTRAN-style USE declarations.
//  * \param Builder        The DIBuilder.
//  * \param Scope          The scope this module is imported into.
//  * \param Decl           The declaration (or definition) of a function, type,
//                          or variable.
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Name           A name that uniquely identifies this imported
//  declaration.
//  * \param NameLen        The length of the C string passed to \c Name.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedDeclaration(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, LLVMMetadataRef Decl,
//     LLVMMetadataRef File, unsigned Line, const char *Name, size_t NameLen,
//     LLVMMetadataRef *Elements, unsigned NumElements);
//
// /**
//  * Creates a new DebugLocation that describes a source location.
//  * \param Line The line in the source file.
//  * \param Column The column in the source file.
//  * \param Scope The scope in which the location resides.
//  * \param InlinedAt The scope where this location was inlined, if at all.
//  *                  (optional).
//  * \note If the item to which this location is attached cannot be
//  *       attributed to a source line, pass 0 for the line and column.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateDebugLocation(LLVMContextRef Ctx, unsigned Line,
//                                  unsigned Column, LLVMMetadataRef Scope,
//                                  LLVMMetadataRef InlinedAt);
//
// /**
//  * Get the line number of this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getLine()
//  */
// unsigned LLVMDILocationGetLine(LLVMMetadataRef Location);

///| Get the line number of this debug location.
/// 
/// - see `DILocation::getLine()`
pub extern "C" fn llvm_di_location_get_line(location_ref: LLVMMetadataRef) -> UInt = "__llvm_di_location_get_line"
//
// /**
//  * Get the column number of this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getColumn()
//  */
// unsigned LLVMDILocationGetColumn(LLVMMetadataRef Location);

///| Get the column number of this debug location.
/// 
/// - see `DILocation::getColumn()`
/// 
pub extern "C" fn llvm_di_location_get_column(location_ref: LLVMMetadataRef) -> UInt = "__llvm_di_location_get_column"
//
// /**
//  * Get the local scope associated with this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getScope()
//  */
// LLVMMetadataRef LLVMDILocationGetScope(LLVMMetadataRef Location);

///| Get the local scope associated with this debug location.
/// 
/// - see `DILocation::getScope()`
/// 
pub extern "C" fn llvm_di_location_get_scope(location_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_location_get_scope"

// /**
//  * Get the "inline at" location associated with this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getInlinedAt()
//  */
// LLVMMetadataRef LLVMDILocationGetInlinedAt(LLVMMetadataRef Location);

///| Get the "inline at" location associated with this debug location.
/// 
/// - see `DILocation::getInlinedAt()`
/// 
pub extern "C" fn llvm_di_location_get_inlined_at(location_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_location_get_inlined_at"
//
// /**
//  * Get the metadata of the file associated with a given scope.
//  * \param Scope     The scope object.
//  *
//  * @see DIScope::getFile()
//  */
// LLVMMetadataRef LLVMDIScopeGetFile(LLVMMetadataRef Scope);

///| Get the metadata of the file associated with a given scope.
/// 
/// - see `DIScope::getFile()`
/// 
pub extern "C" fn llvm_di_scope_get_file(scope_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_scope_get_file"

//
// /**
//  * Get the directory of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getDirectory()
//  */
// const char *LLVMDIFileGetDirectory(LLVMMetadataRef File, unsigned *Len);

///| Get the directory of a given file.
/// 
/// - see `DIFile::getDirectory()`
/// 
pub fn llvm_di_file_get_directory(file_ref: LLVMMetadataRef) -> String {
  let len: Ref[UInt] = Ref::new(0);
  let cstr = __llvm_di_file_get_directory(file_ref, len)
  c_str_to_moonbit_str_with_length(cstr, len.val)
}
extern "C" fn __llvm_di_file_get_directory(file_ref: LLVMMetadataRef, len: Ref[UInt]) -> CStr = "__llvm_di_file_get_directory"

// /**
//  * Get the name of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getFilename()
//  */
// const char *LLVMDIFileGetFilename(LLVMMetadataRef File, unsigned *Len);

///| Get the name of a given file.
/// 
/// - see `DIFile::getFilename()`
pub fn llvm_di_file_get_filename(file_ref: LLVMMetadataRef) -> String {
  let len: Ref[UInt] = Ref::new(0);
  let cstr = __llvm_di_file_get_filename(file_ref, len)
  c_str_to_moonbit_str_with_length(cstr, len.val)
}

extern "C" fn __llvm_di_file_get_filename(file_ref: LLVMMetadataRef, len: Ref[UInt]) -> CStr = "__llvm_di_file_get_filename"

//
// /**
//  * Get the source of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getSource()
//  */
// const char *LLVMDIFileGetSource(LLVMMetadataRef File, unsigned *Len);

///| Get the source of a given file.
/// 
/// - see `DIFile::getSource()`
pub fn llvm_di_file_get_source(file_ref: LLVMMetadataRef) -> String {
  let len: Ref[UInt] = Ref::new(0);
  let cstr = __llvm_di_file_get_source(file_ref, len)
  c_str_to_moonbit_str_with_length(cstr, len.val)
}

extern "C" fn __llvm_di_file_get_source(file_ref: LLVMMetadataRef, len: Ref[UInt]) -> CStr = "__llvm_di_file_get_source"
// /**
//  * Create a type array.
//  * \param Builder        The DIBuilder.
//  * \param Data           The type elements.
//  * \param NumElements    Number of type elements.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateTypeArray(LLVMDIBuilderRef Builder,
//                                                   LLVMMetadataRef *Data,
//                                                   size_t NumElements);
//
// /**
//  * Create subroutine type.
//  * \param Builder        The DIBuilder.
//  * \param File            The file in which the subroutine resides.
//  * \param ParameterTypes  An array of subroutine parameter types. This
//  *                        includes return type at 0th index.
//  * \param NumParameterTypes The number of parameter types in \c ParameterTypes
//  * \param Flags           E.g.: \c LLVMDIFlagLValueReference.
//  *                        These flags are used to emit dwarf attributes.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateSubroutineType(LLVMDIBuilderRef Builder,
//                                   LLVMMetadataRef File,
//                                   LLVMMetadataRef *ParameterTypes,
//                                   unsigned NumParameterTypes,
//                                   LLVMDIFlags Flags);
//
// /**
//  * Create debugging information entry for a macro.
//  * @param Builder         The DIBuilder.
//  * @param ParentMacroFile Macro parent (could be NULL).
//  * @param Line            Source line number where the macro is defined.
//  * @param RecordType      DW_MACINFO_define or DW_MACINFO_undef.
//  * @param Name            Macro name.
//  * @param NameLen         Macro name length.
//  * @param Value           Macro value.
//  * @param ValueLen        Macro value length.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateMacro(LLVMDIBuilderRef Builder,
//                                          LLVMMetadataRef ParentMacroFile,
//                                          unsigned Line,
//                                          LLVMDWARFMacinfoRecordType RecordType,
//                                          const char *Name, size_t NameLen,
//                                          const char *Value, size_t ValueLen);
//
// /**
//  * Create debugging information temporary entry for a macro file.
//  * List of macro node direct children will be calculated by DIBuilder,
//  * using the \p ParentMacroFile relationship.
//  * @param Builder         The DIBuilder.
//  * @param ParentMacroFile Macro parent (could be NULL).
//  * @param Line            Source line number where the macro file is included.
//  * @param File            File descriptor containing the name of the macro file.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateTempMacroFile(LLVMDIBuilderRef Builder,
//                                  LLVMMetadataRef ParentMacroFile, unsigned Line,
//                                  LLVMMetadataRef File);
//
// /**
//  * Create debugging information entry for an enumerator.
//  * @param Builder        The DIBuilder.
//  * @param Name           Enumerator name.
//  * @param NameLen        Length of enumerator name.
//  * @param Value          Enumerator value.
//  * @param IsUnsigned     True if the value is unsigned.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateEnumerator(LLVMDIBuilderRef Builder,
//                                               const char *Name, size_t NameLen,
//                                               int64_t Value,
//                                               LLVMBool IsUnsigned);
//
// /**
//  * Create debugging information entry for an enumeration.
//  * \param Builder        The DIBuilder.
//  * \param Scope          Scope in which this enumeration is defined.
//  * \param Name           Enumeration name.
//  * \param NameLen        Length of enumeration name.
//  * \param File           File where this member is defined.
//  * \param LineNumber     Line number.
//  * \param SizeInBits     Member size.
//  * \param AlignInBits    Member alignment.
//  * \param Elements       Enumeration elements.
//  * \param NumElements    Number of enumeration elements.
//  * \param ClassTy        Underlying type of a C++11/ObjC fixed enum.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateEnumerationType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMMetadataRef *Elements,
//     unsigned NumElements, LLVMMetadataRef ClassTy);
//
// /**
//  * Create debugging information entry for a union.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Scope in which this union is defined.
//  * \param Name         Union name.
//  * \param NameLen      Length of union name.
//  * \param File         File where this member is defined.
//  * \param LineNumber   Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Elements     Union elements.
//  * \param NumElements  Number of union elements.
//  * \param RunTimeLang  Optional parameter, Objective-C runtime version.
//  * \param UniqueId     A unique identifier for the union.
//  * \param UniqueIdLen  Length of unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateUnionType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef *Elements, unsigned NumElements, unsigned RunTimeLang,
//     const char *UniqueId, size_t UniqueIdLen);
//
//
// /**
//  * Create debugging information entry for an array.
//  * \param Builder      The DIBuilder.
//  * \param Size         Array size.
//  * \param AlignInBits  Alignment.
//  * \param Ty           Element type.
//  * \param Subscripts   Subscripts.
//  * \param NumSubscripts Number of subscripts.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateArrayType(LLVMDIBuilderRef Builder, uint64_t Size,
//                              uint32_t AlignInBits, LLVMMetadataRef Ty,
//                              LLVMMetadataRef *Subscripts,
//                              unsigned NumSubscripts);
//
// /**
//  * Create debugging information entry for a vector type.
//  * \param Builder      The DIBuilder.
//  * \param Size         Vector size.
//  * \param AlignInBits  Alignment.
//  * \param Ty           Element type.
//  * \param Subscripts   Subscripts.
//  * \param NumSubscripts Number of subscripts.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateVectorType(LLVMDIBuilderRef Builder, uint64_t Size,
//                               uint32_t AlignInBits, LLVMMetadataRef Ty,
//                               LLVMMetadataRef *Subscripts,
//                               unsigned NumSubscripts);
//
// /**
//  * Create a DWARF unspecified type.
//  * \param Builder   The DIBuilder.
//  * \param Name      The unspecified type's name.
//  * \param NameLen   Length of type name.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateUnspecifiedType(LLVMDIBuilderRef Builder, const char *Name,
//                                    size_t NameLen);

///| Create a DWARF unspecified type.
pub fn llvm_di_builder_create_unspecified_type(builder_ref: LLVMDIBuilderRef, name: String) -> LLVMMetadataRef {
  let cstr = moonbit_str_to_c_str(name);
  let len = name.length().to_uint64();
  __llvm_di_builder_create_unspecified_type(builder_ref, cstr, len)
}

extern "C" fn __llvm_di_builder_create_unspecified_type(builder_ref: LLVMDIBuilderRef, name: CStr, name_len: UInt64) -> LLVMMetadataRef = "__llvm_di_builder_create_unspecified_type"

// /**
//  * Create debugging information entry for a basic
//  * type.
//  * \param Builder     The DIBuilder.
//  * \param Name        Type name.
//  * \param NameLen     Length of type name.
//  * \param SizeInBits  Size of the type.
//  * \param Encoding    DWARF encoding code, e.g. \c LLVMDWARFTypeEncoding_float.
//  * \param Flags       Flags to encode optional attribute like endianness
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateBasicType(LLVMDIBuilderRef Builder, const char *Name,
//                              size_t NameLen, uint64_t SizeInBits,
//                              LLVMDWARFTypeEncoding Encoding,
//                              LLVMDIFlags Flags);
//
// /**
//  * Create debugging information entry for a pointer.
//  * \param Builder     The DIBuilder.
//  * \param PointeeTy         Type pointed by this pointer.
//  * \param SizeInBits        Size.
//  * \param AlignInBits       Alignment. (optional, pass 0 to ignore)
//  * \param AddressSpace      DWARF address space. (optional, pass 0 to ignore)
//  * \param Name              Pointer type name. (optional)
//  * \param NameLen           Length of pointer type name. (optional)
//  */
// LLVMMetadataRef LLVMDIBuilderCreatePointerType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef PointeeTy,
//     uint64_t SizeInBits, uint32_t AlignInBits, unsigned AddressSpace,
//     const char *Name, size_t NameLen);
//
// /**
//  * Create debugging information entry for a struct.
//  * \param Builder     The DIBuilder.
//  * \param Scope        Scope in which this struct is defined.
//  * \param Name         Struct name.
//  * \param NameLen      Struct name length.
//  * \param File         File where this member is defined.
//  * \param LineNumber   Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Elements     Struct elements.
//  * \param NumElements  Number of struct elements.
//  * \param RunTimeLang  Optional parameter, Objective-C runtime version.
//  * \param VTableHolder The object containing the vtable for the struct.
//  * \param UniqueId     A unique identifier for the struct.
//  * \param UniqueIdLen  Length of the unique identifier for the struct.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateStructType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef DerivedFrom, LLVMMetadataRef *Elements,
//     unsigned NumElements, unsigned RunTimeLang, LLVMMetadataRef VTableHolder,
//     const char *UniqueId, size_t UniqueIdLen);
//
// /**
//  * Create debugging information entry for a member.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Member scope.
//  * \param Name         Member name.
//  * \param NameLen      Length of member name.
//  * \param File         File where this member is defined.
//  * \param LineNo       Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param OffsetInBits Member offset.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Ty           Parent type.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateMemberType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNo,
//     uint64_t SizeInBits, uint32_t AlignInBits, uint64_t OffsetInBits,
//     LLVMDIFlags Flags, LLVMMetadataRef Ty);
//
// /**
//  * Create debugging information entry for a
//  * C++ static data member.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Member scope.
//  * \param Name         Member name.
//  * \param NameLen      Length of member name.
//  * \param File         File where this member is declared.
//  * \param LineNumber   Line number.
//  * \param Type         Type of the static member.
//  * \param Flags        Flags to encode member attribute, e.g. private.
//  * \param ConstantVal  Const initializer of the member.
//  * \param AlignInBits  Member alignment.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateStaticMemberType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     LLVMMetadataRef Type, LLVMDIFlags Flags, LLVMValueRef ConstantVal,
//     uint32_t AlignInBits);
//
// /**
//  * Create debugging information entry for a pointer to member.
//  * \param Builder      The DIBuilder.
//  * \param PointeeType  Type pointed to by this pointer.
//  * \param ClassType    Type for which this pointer points to members of.
//  * \param SizeInBits   Size.
//  * \param AlignInBits  Alignment.
//  * \param Flags        Flags.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateMemberPointerType(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef PointeeType,
//                                      LLVMMetadataRef ClassType,
//                                      uint64_t SizeInBits,
//                                      uint32_t AlignInBits,
//                                      LLVMDIFlags Flags);
// /**
//  * Create debugging information entry for Objective-C instance variable.
//  * \param Builder      The DIBuilder.
//  * \param Name         Member name.
//  * \param NameLen      The length of the C string passed to \c Name.
//  * \param File         File where this member is defined.
//  * \param LineNo       Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param OffsetInBits Member offset.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Ty           Parent type.
//  * \param PropertyNode Property associated with this ivar.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjCIVar(LLVMDIBuilderRef Builder,
//                             const char *Name, size_t NameLen,
//                             LLVMMetadataRef File, unsigned LineNo,
//                             uint64_t SizeInBits, uint32_t AlignInBits,
//                             uint64_t OffsetInBits, LLVMDIFlags Flags,
//                             LLVMMetadataRef Ty, LLVMMetadataRef PropertyNode);
//
// /**
//  * Create debugging information entry for Objective-C property.
//  * \param Builder            The DIBuilder.
//  * \param Name               Property name.
//  * \param NameLen            The length of the C string passed to \c Name.
//  * \param File               File where this property is defined.
//  * \param LineNo             Line number.
//  * \param GetterName         Name of the Objective C property getter selector.
//  * \param GetterNameLen      The length of the C string passed to \c GetterName.
//  * \param SetterName         Name of the Objective C property setter selector.
//  * \param SetterNameLen      The length of the C string passed to \c SetterName.
//  * \param PropertyAttributes Objective C property attributes.
//  * \param Ty                 Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjCProperty(LLVMDIBuilderRef Builder,
//                                 const char *Name, size_t NameLen,
//                                 LLVMMetadataRef File, unsigned LineNo,
//                                 const char *GetterName, size_t GetterNameLen,
//                                 const char *SetterName, size_t SetterNameLen,
//                                 unsigned PropertyAttributes,
//                                 LLVMMetadataRef Ty);
//
// /**
//  * Create a uniqued DIType* clone with FlagObjectPointer and FlagArtificial set.
//  * \param Builder   The DIBuilder.
//  * \param Type      The underlying type to which this pointer points.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjectPointerType(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a qualified
//  * type, e.g. 'const int'.
//  * \param Builder     The DIBuilder.
//  * \param Tag         Tag identifying type,
//  *                    e.g. LLVMDWARFTypeQualifier_volatile_type
//  * \param Type        Base Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateQualifiedType(LLVMDIBuilderRef Builder, unsigned Tag,
//                                  LLVMMetadataRef Type);

///| Create debugging information entry for a qualified type, e.g. 'const int'.
pub extern "C" fn llvm_di_builder_create_qualified_type(builder_ref: LLVMDIBuilderRef, tag: UInt, type_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_builder_create_qualified_type"
//
// /**
//  * Create debugging information entry for a c++
//  * style reference or rvalue reference type.
//  * \param Builder   The DIBuilder.
//  * \param Tag       Tag identifying type,
//  * \param Type      Base Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateReferenceType(LLVMDIBuilderRef Builder, unsigned Tag,
//                                  LLVMMetadataRef Type);
pub extern "C" fn llvm_di_builder_create_reference_type(builder_ref: LLVMDIBuilderRef, tag: UInt, type_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_builder_create_reference_type"
//
// /**
//  * Create C++11 nullptr type.
//  * \param Builder   The DIBuilder.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateNullPtrType(LLVMDIBuilderRef Builder);
pub extern "C" fn llvm_di_builder_create_null_ptr_type(builder_ref: LLVMDIBuilderRef) -> LLVMMetadataRef = "__llvm_di_builder_create_null_ptr_type"
//
// /**
//  * Create debugging information entry for a typedef.
//  * \param Builder    The DIBuilder.
//  * \param Type       Original type.
//  * \param Name       Typedef name.
//  * \param File       File where this type is defined.
//  * \param LineNo     Line number.
//  * \param Scope      The surrounding context for the typedef.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateTypedef(LLVMDIBuilderRef Builder, LLVMMetadataRef Type,
//                            const char *Name, size_t NameLen,
//                            LLVMMetadataRef File, unsigned LineNo,
//                            LLVMMetadataRef Scope, uint32_t AlignInBits);
//
// /**
//  * Create debugging information entry to establish inheritance relationship
//  * between two types.
//  * \param Builder       The DIBuilder.
//  * \param Ty            Original type.
//  * \param BaseTy        Base type. Ty is inherits from base.
//  * \param BaseOffset    Base offset.
//  * \param VBPtrOffset  Virtual base pointer offset.
//  * \param Flags         Flags to describe inheritance attribute, e.g. private
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateInheritance(LLVMDIBuilderRef Builder,
//                                LLVMMetadataRef Ty, LLVMMetadataRef BaseTy,
//                                uint64_t BaseOffset, uint32_t VBPtrOffset,
//                                LLVMDIFlags Flags);
//
// /**
//  * Create a permanent forward-declared type.
//  * \param Builder             The DIBuilder.
//  * \param Tag                 A unique tag for this type.
//  * \param Name                Type name.
//  * \param NameLen             Length of type name.
//  * \param Scope               Type scope.
//  * \param File                File where this type is defined.
//  * \param Line                Line number where this type is defined.
//  * \param RuntimeLang         Indicates runtime version for languages like
//  *                            Objective-C.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateForwardDecl(
//     LLVMDIBuilderRef Builder, unsigned Tag, const char *Name,
//     size_t NameLen, LLVMMetadataRef Scope, LLVMMetadataRef File, unsigned Line,
//     unsigned RuntimeLang, uint64_t SizeInBits, uint32_t AlignInBits,
//     const char *UniqueIdentifier, size_t UniqueIdentifierLen);
//
// /**
//  * Create a temporary forward-declared type.
//  * \param Builder             The DIBuilder.
//  * \param Tag                 A unique tag for this type.
//  * \param Name                Type name.
//  * \param NameLen             Length of type name.
//  * \param Scope               Type scope.
//  * \param File                File where this type is defined.
//  * \param Line                Line number where this type is defined.
//  * \param RuntimeLang         Indicates runtime version for languages like
//  *                            Objective-C.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param Flags               Flags.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateReplaceableCompositeType(
//     LLVMDIBuilderRef Builder, unsigned Tag, const char *Name,
//     size_t NameLen, LLVMMetadataRef Scope, LLVMMetadataRef File, unsigned Line,
//     unsigned RuntimeLang, uint64_t SizeInBits, uint32_t AlignInBits,
//     LLVMDIFlags Flags, const char *UniqueIdentifier,
//     size_t UniqueIdentifierLen);
//
// /**
//  * Create debugging information entry for a bit field member.
//  * \param Builder             The DIBuilder.
//  * \param Scope               Member scope.
//  * \param Name                Member name.
//  * \param NameLen             Length of member name.
//  * \param File                File where this member is defined.
//  * \param LineNumber          Line number.
//  * \param SizeInBits          Member size.
//  * \param OffsetInBits        Member offset.
//  * \param StorageOffsetInBits Member storage offset.
//  * \param Flags               Flags to encode member attribute.
//  * \param Type                Parent type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateBitFieldMemberType(LLVMDIBuilderRef Builder,
//                                       LLVMMetadataRef Scope,
//                                       const char *Name, size_t NameLen,
//                                       LLVMMetadataRef File, unsigned LineNumber,
//                                       uint64_t SizeInBits,
//                                       uint64_t OffsetInBits,
//                                       uint64_t StorageOffsetInBits,
//                                       LLVMDIFlags Flags, LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a class.
//  * \param Scope               Scope in which this class is defined.
//  * \param Name                Class name.
//  * \param NameLen             The length of the C string passed to \c Name.
//  * \param File                File where this member is defined.
//  * \param LineNumber          Line number.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param OffsetInBits        Member offset.
//  * \param Flags               Flags to encode member attribute, e.g. private.
//  * \param DerivedFrom         Debug info of the base class of this type.
//  * \param Elements            Class members.
//  * \param NumElements         Number of class elements.
//  * \param VTableHolder        Debug info of the base class that contains vtable
//  *                            for this type. This is used in
//  *                            DW_AT_containing_type. See DWARF documentation
//  *                            for more info.
//  * \param TemplateParamsNode  Template type parameters.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateClassType(LLVMDIBuilderRef Builder,
//     LLVMMetadataRef Scope, const char *Name, size_t NameLen,
//     LLVMMetadataRef File, unsigned LineNumber, uint64_t SizeInBits,
//     uint32_t AlignInBits, uint64_t OffsetInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef DerivedFrom,
//     LLVMMetadataRef *Elements, unsigned NumElements,
//     LLVMMetadataRef VTableHolder, LLVMMetadataRef TemplateParamsNode,
//     const char *UniqueIdentifier, size_t UniqueIdentifierLen);
//
// /**
//  * Create a uniqued DIType* clone with FlagArtificial set.
//  * \param Builder     The DIBuilder.
//  * \param Type        The underlying type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateArtificialType(LLVMDIBuilderRef Builder,
//                                   LLVMMetadataRef Type);
pub extern "C" fn llvm_di_builder_create_artificial_type(builder_ref: LLVMDIBuilderRef, type_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_builder_create_artificial_type"
//
// /**
//  * Get the name of this DIType.
//  * \param DType     The DIType.
//  * \param Length    The length of the returned string.
//  *
//  * @see DIType::getName()
//  */
// const char *LLVMDITypeGetName(LLVMMetadataRef DType, size_t *Length);

///| Get the name of this DIType.
/// 
/// - see `DIType::getName()`
pub fn llvm_di_type_get_name(type_ref: LLVMMetadataRef) -> String {
  let len: Ref[UInt] = Ref::new(0);
  let cstr = __llvm_di_type_get_name(type_ref, len)
  c_str_to_moonbit_str_with_length(cstr, len.val)
}

extern "C" fn __llvm_di_type_get_name(type_ref: LLVMMetadataRef, len: Ref[UInt]) -> CStr = "__llvm_di_type_get_name"
//
// /**
//  * Get the size of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getSizeInBits()
//  */
// uint64_t LLVMDITypeGetSizeInBits(LLVMMetadataRef DType);

///| Get the size of this DIType in bits.
/// 
/// - see `DIType::getSizeInBits()`
pub extern "C" fn llvm_di_type_get_size_in_bits(type_ref: LLVMMetadataRef) -> UInt64 = "__llvm_di_type_get_size_in_bits"

// /**
//  * Get the offset of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getOffsetInBits()
//  */
// uint64_t LLVMDITypeGetOffsetInBits(LLVMMetadataRef DType);
pub extern "C" fn llvm_di_type_get_offset_in_bits(type_ref: LLVMMetadataRef) -> UInt64 = "__llvm_di_type_get_offset_in_bits"
//
// /**
//  * Get the alignment of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getAlignInBits()
//  */
// uint32_t LLVMDITypeGetAlignInBits(LLVMMetadataRef DType);

///| Get the alignment of this DIType in bits.
/// 
/// - see `DIType::getAlignInBits()`
pub extern "C" fn llvm_di_type_get_align_in_bits(type_ref: LLVMMetadataRef) -> UInt = "__llvm_di_type_get_align_in_bits"
//
// /**
//  * Get the source line where this DIType is declared.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getLine()
//  */
// unsigned LLVMDITypeGetLine(LLVMMetadataRef DType);

///| Get the source line where this DIType is declared.
/// 
/// - see `DIType::getLine()`
pub extern "C" fn llvm_di_type_get_line(type_ref: LLVMMetadataRef) -> UInt = "__llvm_di_type_get_line"

// /**
//  * Get the flags associated with this DIType.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getFlags()
//  */
// LLVMDIFlags LLVMDITypeGetFlags(LLVMMetadataRef DType);

///| Get the flags associated with this DIType.
/// 
/// - see `DIType::getFlags()`
pub extern "C" fn llvm_di_type_get_flags(type_ref: LLVMMetadataRef) -> LLVMDIFlags = "__llvm_di_type_get_flags"

//
// /**
//  * Create a descriptor for a value range.
//  * \param Builder    The DIBuilder.
//  * \param LowerBound Lower bound of the subrange, e.g. 0 for C, 1 for Fortran.
//  * \param Count      Count of elements in the subrange.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateSubrange(LLVMDIBuilderRef Builder,
//                                                  int64_t LowerBound,
//                                                  int64_t Count);

///| Create a descriptor for a value range.
pub extern "C" fn llvm_di_builder_get_or_create_subrange(builder_ref: LLVMDIBuilderRef, lower_bound: Int64, count: Int64) -> LLVMMetadataRef = "__llvm_di_builder_get_or_create_subrange"

// LLVMMetadataRef LLVMDIBuilderGetOrCreateArray(LLVMDIBuilderRef Builder,
//                                               LLVMMetadataRef *Data,
//                                               size_t NumElements);
//
// /**
//  * Create a new descriptor for the specified variable which has a complex
//  * address expression for its address.
//  * \param Builder     The DIBuilder.
//  * \param Addr        An array of complex address operations.
//  * \param Length      Length of the address operation array.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateExpression(LLVMDIBuilderRef Builder,
//                                               uint64_t *Addr, size_t Length);
//
// /**
//  * Create a new descriptor for the specified variable that does not have an
//  * address, but does have a constant value.
//  * \param Builder     The DIBuilder.
//  * \param Value       The constant value.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateConstantValueExpression(LLVMDIBuilderRef Builder,
//                                            uint64_t Value);

///| Create a new descriptor for the specified variable that does not have an address, but does have a constant value.
pub extern "C" fn llvm_di_builder_create_constant_value_expression(builder_ref: LLVMDIBuilderRef, value: UInt64) -> LLVMMetadataRef = "__llvm_di_builder_create_constant_value_expression"

//
// /**
//  * Create a new descriptor for the specified variable.
//  * \param Scope       Variable scope.
//  * \param Name        Name of the variable.
//  * \param NameLen     The length of the C string passed to \c Name.
//  * \param Linkage     Mangled  name of the variable.
//  * \param LinkLen     The length of the C string passed to \c Linkage.
//  * \param File        File where this variable is defined.
//  * \param LineNo      Line number.
//  * \param Ty          Variable Type.
//  * \param LocalToUnit Boolean flag indicate whether this variable is
//  *                    externally visible or not.
//  * \param Expr        The location of the global relative to the attached
//  *                    GlobalVariable.
//  * \param Decl        Reference to the corresponding declaration.
//  *                    variables.
//  * \param AlignInBits Variable alignment(or 0 if no alignment attr was
//  *                    specified)
//  */
// LLVMMetadataRef LLVMDIBuilderCreateGlobalVariableExpression(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *Linkage, size_t LinkLen, LLVMMetadataRef File,
//     unsigned LineNo, LLVMMetadataRef Ty, LLVMBool LocalToUnit,
//     LLVMMetadataRef Expr, LLVMMetadataRef Decl, uint32_t AlignInBits);
//

// uint16_t LLVMGetDINodeTag(LLVMMetadataRef MD);

///| Get the dwarf::Tag of a DINode
pub extern "C" fn llvm_get_di_node_tag(metadata_ref: LLVMMetadataRef) -> UInt16 = "__llvm_get_di_node_tag"

// LLVMMetadataRef LLVMDIGlobalVariableExpressionGetVariable(LLVMMetadataRef GVE);

///| Retrieves the DIVariable associated with this global variable expression.
///
///  - see `llvm::DIGlobalVariableExpression::getVariable()`
pub extern "C" fn llvm_di_global_variable_expression_get_variable(metadata_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_global_variable_expression_get_variable"

// LLVMMetadataRef LLVMDIGlobalVariableExpressionGetExpression(
//     LLVMMetadataRef GVE);

///| Retrieves the \c DIExpression associated with this global variable expression.
///
/// - see `llvm::DIGlobalVariableExpression::getExpression()`
pub extern "C" fn llvm_di_global_variable_expression_get_expression(metadata_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_global_variable_expression_get_expression"

// LLVMMetadataRef LLVMDIVariableGetFile(LLVMMetadataRef Var);

///| Get the metadata of the file associated with a given variable.
/// 
/// - `see DIVariable::getFile()`
pub extern "C" fn llvm_di_variable_get_file(metadata_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_variable_get_file"

// LLVMMetadataRef LLVMDIVariableGetScope(LLVMMetadataRef Var);

///| Get the metadata of the scope associated with a given variable.
/// 
/// - see `DIVariable::getScope()`
pub extern "C" fn llvm_di_variable_get_scope(metadata_ref: LLVMMetadataRef) -> LLVMMetadataRef = "__llvm_di_variable_get_scope"

// unsigned LLVMDIVariableGetLine(LLVMMetadataRef Var);

///| Get the source line where this DIVariable is declared.
/// 
/// - see `DIVariable::getLine()`
pub extern "C" fn llvm_di_variable_get_line(metadata_ref: LLVMMetadataRef) -> UInt = "__llvm_di_variable_get_line"
//
// /**
//  * Create a new temporary \c MDNode.  Suitable for use in constructing cyclic
//  * \c MDNode structures. A temporary \c MDNode is not uniqued, may be RAUW'd,
//  * and must be manually deleted with \c LLVMDisposeTemporaryMDNode.
//  * \param Ctx            The context in which to construct the temporary node.
//  * \param Data           The metadata elements.
//  * \param NumElements    Number of metadata elements.
//  */
// LLVMMetadataRef LLVMTemporaryMDNode(LLVMContextRef Ctx, LLVMMetadataRef *Data,
//                                     size_t NumElements);


// void LLVMDisposeTemporaryMDNode(LLVMMetadataRef TempNode);
///| Deallocate a temporary node.
/// 
/// Calls replaceAllUsesWith(nullptr) before deleting, so any remaining
/// references will be reset.
pub extern "C" fn llvm_dispose_temporary_md_node(metadata_ref: LLVMMetadataRef) = "__llvm_dispose_temporary_md_node"

// void LLVMMetadataReplaceAllUsesWith(LLVMMetadataRef TempTargetMetadata,
//                                     LLVMMetadataRef Replacement);
///| Replace all uses of temporary metadata.
pub extern "C" fn llvm_metadata_replace_all_uses_with(temp_target_metadata: LLVMMetadataRef, replacement: LLVMMetadataRef) = "__llvm_metadata_replace_all_uses_with"
//
// /**
//  * Create a new descriptor for the specified global variable that is temporary
//  * and meant to be RAUWed.
//  * \param Scope       Variable scope.
//  * \param Name        Name of the variable.
//  * \param NameLen     The length of the C string passed to \c Name.
//  * \param Linkage     Mangled  name of the variable.
//  * \param LnkLen      The length of the C string passed to \c Linkage.
//  * \param File        File where this variable is defined.
//  * \param LineNo      Line number.
//  * \param Ty          Variable Type.
//  * \param LocalToUnit Boolean flag indicate whether this variable is
//  *                    externally visible or not.
//  * \param Decl        Reference to the corresponding declaration.
//  * \param AlignInBits Variable alignment(or 0 if no alignment attr was
//  *                    specified)
//  */
// LLVMMetadataRef LLVMDIBuilderCreateTempGlobalVariableFwdDecl(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *Linkage, size_t LnkLen, LLVMMetadataRef File,
//     unsigned LineNo, LLVMMetadataRef Ty, LLVMBool LocalToUnit,
//     LLVMMetadataRef Decl, uint32_t AlignInBits);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a Declare DbgRecord before the given instruction.
//  * \param Builder     The DIBuilder.
//  * \param Storage     The storage of the variable to declare.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Instr       Instruction acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDeclareRecordBefore(
//     LLVMDIBuilderRef Builder, LLVMValueRef Storage, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMValueRef Instr);

/// The debug format can be switched later after inserting the records using
/// LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
/// 
/// Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
/// See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
pub extern "C" fn llvm_di_builder_insert_declare_record_before(
  builder_ref: LLVMDIBuilderRef,
  storage: LLVMValueRef,
  var_info: LLVMMetadataRef,
  expr: LLVMMetadataRef,
  debug_loc: LLVMMetadataRef,
  instr: LLVMValueRef
) -> LLVMDbgRecordRef = "__llvm_di_builder_insert_declare_record_before"
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a Declare DbgRecord at the end of the given basic block. If the basic
//  * block has a terminator instruction, the record is inserted before that
//  * terminator instruction.
//  * \param Builder     The DIBuilder.
//  * \param Storage     The storage of the variable to declare.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Block       Basic block acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDeclareRecordAtEnd(
//     LLVMDIBuilderRef Builder, LLVMValueRef Storage, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMBasicBlockRef Block);

///| Insert a Declare DbgRecord at the end of the given basic block.
///
/// Insert a Declare DbgRecord at the end of the given basic block. If the basic
/// block has a terminator instruction, the record is inserted before that
/// terminator instruction.
///
/// Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
/// See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
/// 
/// The debug format can be switched later after inserting the records using
/// LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
pub extern "C" fn llvm_di_builder_insert_declare_record_at_end(
  builder_ref: LLVMDIBuilderRef,
  storage: LLVMValueRef,
  var_info: LLVMMetadataRef,
  expr: LLVMMetadataRef,
  debug_loc: LLVMMetadataRef,
  block: LLVMBasicBlockRef
) -> LLVMDbgRecordRef = "__llvm_di_builder_insert_declare_record_at_end"

// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a new debug record before the given instruction.
//  * \param Builder     The DIBuilder.
//  * \param Val         The value of the variable.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Instr       Instruction acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDbgValueRecordBefore(
//     LLVMDIBuilderRef Builder, LLVMValueRef Val, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMValueRef Instr);

///| Insert a new debug record before the given instruction.
///
/// Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
/// See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
/// 
/// The debug format can be switched later after inserting the records using
/// LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
/// 
pub extern "C" fn llvm_di_builder_insert_dbg_value_record_before(
  builder_ref: LLVMDIBuilderRef,
  val: LLVMValueRef,
  var_info: LLVMMetadataRef,
  expr: LLVMMetadataRef,
  debug_loc: LLVMMetadataRef,
  instr: LLVMValueRef
) -> LLVMDbgRecordRef = "__llvm_di_builder_insert_dbg_value_record_before"

// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a new debug record at the end of the given basic block. If the
//  * basic block has a terminator instruction, the record is inserted before
//  * that terminator instruction.
//  * \param Builder     The DIBuilder.
//  * \param Val         The value of the variable.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Block       Basic block acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDbgValueRecordAtEnd(
//     LLVMDIBuilderRef Builder, LLVMValueRef Val, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMBasicBlockRef Block);

///| Insert a new debug record at the end of the given basic block. If the
///
/// Insert a new debug record at the end of the given basic block.
/// basic block has a terminator instruction, the record is inserted before
/// that terminator instruction.
///
/// Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
/// See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
/// 
/// The debug format can be switched later after inserting the records using
/// LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
pub extern "C" fn llvm_di_builder_insert_dbg_value_record_at_end(
  builder_ref: LLVMDIBuilderRef,
  val: LLVMValueRef,
  var_info: LLVMMetadataRef,
  expr: LLVMMetadataRef,
  debug_loc: LLVMMetadataRef,
  block: LLVMBasicBlockRef
) -> LLVMDbgRecordRef = "__llvm_di_builder_insert_dbg_value_record_at_end"

// /**
//  * Create a new descriptor for a local auto variable.
//  * \param Builder         The DIBuilder.
//  * \param Scope           The local scope the variable is declared in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Metadata describing the type of the variable.
//  * \param AlwaysPreserve  If true, this descriptor will survive optimizations.
//  * \param Flags           Flags.
//  * \param AlignInBits     Variable alignment.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateAutoVariable(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNo, LLVMMetadataRef Ty,
//     LLVMBool AlwaysPreserve, LLVMDIFlags Flags, uint32_t AlignInBits);
//
// /**
//  * Create a new descriptor for a function parameter variable.
//  * \param Builder         The DIBuilder.
//  * \param Scope           The local scope the variable is declared in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param ArgNo           Unique argument number for this variable; starts at 1.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Metadata describing the type of the variable.
//  * \param AlwaysPreserve  If true, this descriptor will survive optimizations.
//  * \param Flags           Flags.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateParameterVariable(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, unsigned ArgNo, LLVMMetadataRef File, unsigned LineNo,
//     LLVMMetadataRef Ty, LLVMBool AlwaysPreserve, LLVMDIFlags Flags);
//

// LLVMMetadataRef LLVMGetSubprogram(LLVMValueRef Func);

///| Get the metadata of the subprogram attached to a function.
/// 
/// - see `llvm::Function::getSubprogram()`
pub extern "C" fn llvm_get_subprogram(func: LLVMValueRef) -> LLVMMetadataRef = "__llvm_get_subprogram"

// void LLVMSetSubprogram(LLVMValueRef Func, LLVMMetadataRef SP);

///| Set the subprogram attached to a function.
///
/// - see `llvm::Function::setSubprogram()`
pub extern "C" fn llvm_set_subprogram(func: LLVMValueRef, sp: LLVMMetadataRef) = "__llvm_set_subprogram"

// unsigned LLVMDISubprogramGetLine(LLVMMetadataRef Subprogram);

///| Get the line associated with a given subprogram.
///
/// - see `DISubprogram::getLine()`
pub extern "C" fn llvm_di_subprogram_get_line(subprogram: LLVMMetadataRef) -> UInt = "__llvm_di_subprogram_get_line"


// LLVMMetadataRef LLVMInstructionGetDebugLoc(LLVMValueRef Inst);

///| Get the debug location for the given instruction.
///
/// - see `llvm::Instruction::getDebugLoc()`
pub extern "C" fn llvm_instruction_get_debug_loc(inst: LLVMValueRef) -> LLVMMetadataRef = "__llvm_instruction_get_debug_loc"

// void LLVMInstructionSetDebugLoc(LLVMValueRef Inst, LLVMMetadataRef Loc);

///| Set the debug location for the given instruction.
///
/// To clear the location metadata of the given instruction, pass NULL to Loc.
///
/// - see `llvm::Instruction::setDebugLoc()`
pub extern "C" fn llvm_instruction_set_debug_loc(inst: LLVMValueRef, loc: LLVMMetadataRef) = "__llvm_instruction_set_debug_loc"

//
// /**
//  * Create a new descriptor for a label
//  *
//  * \param Builder         The DIBuilder.
//  * \param Scope           The scope to create the label in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param File            The file to create the label in.
//  * \param LineNo          Line Number.
//  * \param AlwaysPreserve  Preserve the label regardless of optimization.
//  *
//  * @see llvm::DIBuilder::createLabel()
//  */
// LLVMMetadataRef LLVMDIBuilderCreateLabel(
//     LLVMDIBuilderRef Builder,
//     LLVMMetadataRef Context, const char *Name, size_t NameLen,
//     LLVMMetadataRef File, unsigned LineNo, LLVMBool AlwaysPreserve);
//
// /**
//  * Insert a new llvm.dbg.label intrinsic call
//  *
//  * \param Builder         The DIBuilder.
//  * \param LabelInfo       The Label's debug info descriptor
//  * \param Location        The debug info location
//  * \param InsertBefore    Location for the new intrinsic.
//  *
//  * @see llvm::DIBuilder::insertLabel()
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertLabelBefore(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef LabelInfo,
//     LLVMMetadataRef Location, LLVMValueRef InsertBefore);

///| Insert a new llvm.dbg.label intrinsic call.
///
/// - see `llvm::DIBuilder::insertLabel()`
pub extern "C" fn llvm_di_builder_insert_label_before(
  builder_ref: LLVMDIBuilderRef,
  label_info: LLVMMetadataRef,
  location: LLVMMetadataRef,
  insert_before: LLVMValueRef
) -> LLVMDbgRecordRef = "__llvm_di_builder_insert_label_before"

// LLVMDbgRecordRef LLVMDIBuilderInsertLabelAtEnd(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef LabelInfo,
//     LLVMMetadataRef Location, LLVMBasicBlockRef InsertAtEnd);

///| Insert a new llvm.dbg.label intrinsic call.
///
/// - see `llvm::DIBuilder::insertLabel()`
pub extern "C" fn llvm_di_builder_insert_label_at_end(
  builder_ref: LLVMDIBuilderRef,
  label_info: LLVMMetadataRef,
  location: LLVMMetadataRef,
  insert_at_end: LLVMBasicBlockRef
) -> LLVMDbgRecordRef = "__llvm_di_builder_insert_label_at_end"

// LLVMMetadataKind LLVMGetMetadataKind(LLVMMetadataRef Metadata);

///| Obtain the enumerated type of a Metadata instance.
///
/// - see `llvm::Metadata::getMetadataID()`
pub extern "C" fn llvm_get_metadata_kind(metadata_ref: LLVMMetadataRef) -> LLVMMetadataKind = "__llvm_get_metadata_kind"
