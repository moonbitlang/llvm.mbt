// =======================================================
// Object.h
// =======================================================

// /**
//  * Create a binary file from the given memory buffer.
//  *
//  * The exact type of the binary file will be inferred automatically, and the
//  * appropriate implementation selected.  The context may be NULL except if
//  * the resulting file is an LLVM IR file.
//  *
//  * The memory buffer is not consumed by this function.  It is the responsibility
//  * of the caller to free it with \c LLVMDisposeMemoryBuffer.
//  *
//  * If NULL is returned, the \p ErrorMessage parameter is populated with the
//  * error's description.  It is then the caller's responsibility to free this
//  * message by calling \c LLVMDisposeMessage.
//  *
//  * @see llvm::object::createBinary
//  */
// LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf,
//                                LLVMContextRef Context,
//                                char **ErrorMessage);
//
// /**
//  * Dispose of a binary file.
//  *
//  * The binary file does not own its backing buffer.  It is the responsibility
//  * of the caller to free it with \c LLVMDisposeMemoryBuffer.
//  */
// void LLVMDisposeBinary(LLVMBinaryRef BR);
//
// /**
//  * Retrieves a copy of the memory buffer associated with this object file.
//  *
//  * The returned buffer is merely a shallow copy and does not own the actual
//  * backing buffer of the binary. Nevertheless, it is the responsibility of the
//  * caller to free it with \c LLVMDisposeMemoryBuffer.
//  *
//  * @see llvm::object::getMemoryBufferRef
//  */
// LLVMMemoryBufferRef LLVMBinaryCopyMemoryBuffer(LLVMBinaryRef BR);
//
// /**
//  * Retrieve the specific type of a binary.
//  *
//  * @see llvm::object::Binary::getType
//  */
// LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR);
//
// /*
//  * For a Mach-O universal binary file, retrieves the object file corresponding
//  * to the given architecture if it is present as a slice.
//  *
//  * If NULL is returned, the \p ErrorMessage parameter is populated with the
//  * error's description.  It is then the caller's responsibility to free this
//  * message by calling \c LLVMDisposeMessage.
//  *
//  * It is the responsibility of the caller to free the returned object file by
//  * calling \c LLVMDisposeBinary.
//  */
// LLVMBinaryRef LLVMMachOUniversalBinaryCopyObjectForArch(LLVMBinaryRef BR,
//                                                         const char *Arch,
//                                                         size_t ArchLen,
//                                                         char **ErrorMessage);
//
// /**
//  * Retrieve a copy of the section iterator for this object file.
//  *
//  * If there are no sections, the result is NULL.
//  *
//  * The returned iterator is merely a shallow copy. Nevertheless, it is
//  * the responsibility of the caller to free it with
//  * \c LLVMDisposeSectionIterator.
//  *
//  * @see llvm::object::sections()
//  */
// LLVMSectionIteratorRef LLVMObjectFileCopySectionIterator(LLVMBinaryRef BR);
//
// /**
//  * Returns whether the given section iterator is at the end.
//  *
//  * @see llvm::object::section_end
//  */
// LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
//                                               LLVMSectionIteratorRef SI);
//
// /**
//  * Retrieve a copy of the symbol iterator for this object file.
//  *
//  * If there are no symbols, the result is NULL.
//  *
//  * The returned iterator is merely a shallow copy. Nevertheless, it is
//  * the responsibility of the caller to free it with
//  * \c LLVMDisposeSymbolIterator.
//  *
//  * @see llvm::object::symbols()
//  */
// LLVMSymbolIteratorRef LLVMObjectFileCopySymbolIterator(LLVMBinaryRef BR);
//
// /**
//  * Returns whether the given symbol iterator is at the end.
//  *
//  * @see llvm::object::symbol_end
//  */
// LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
//                                              LLVMSymbolIteratorRef SI);
//
// void LLVMDisposeSectionIterator(LLVMSectionIteratorRef SI);
//
// void LLVMMoveToNextSection(LLVMSectionIteratorRef SI);
// void LLVMMoveToContainingSection(LLVMSectionIteratorRef Sect,
//                                  LLVMSymbolIteratorRef Sym);
//
// // ObjectFile Symbol iterators
// void LLVMDisposeSymbolIterator(LLVMSymbolIteratorRef SI);
// void LLVMMoveToNextSymbol(LLVMSymbolIteratorRef SI);
//
// // SectionRef accessors
// const char *LLVMGetSectionName(LLVMSectionIteratorRef SI);
// uint64_t LLVMGetSectionSize(LLVMSectionIteratorRef SI);
// const char *LLVMGetSectionContents(LLVMSectionIteratorRef SI);
// uint64_t LLVMGetSectionAddress(LLVMSectionIteratorRef SI);
// LLVMBool LLVMGetSectionContainsSymbol(LLVMSectionIteratorRef SI,
//                                  LLVMSymbolIteratorRef Sym);
//
// // Section Relocation iterators
// LLVMRelocationIteratorRef LLVMGetRelocations(LLVMSectionIteratorRef Section);
// void LLVMDisposeRelocationIterator(LLVMRelocationIteratorRef RI);
// LLVMBool LLVMIsRelocationIteratorAtEnd(LLVMSectionIteratorRef Section,
//                                        LLVMRelocationIteratorRef RI);
// void LLVMMoveToNextRelocation(LLVMRelocationIteratorRef RI);
//
//
// // SymbolRef accessors
// const char *LLVMGetSymbolName(LLVMSymbolIteratorRef SI);
// uint64_t LLVMGetSymbolAddress(LLVMSymbolIteratorRef SI);
// uint64_t LLVMGetSymbolSize(LLVMSymbolIteratorRef SI);
//
// // RelocationRef accessors
// uint64_t LLVMGetRelocationOffset(LLVMRelocationIteratorRef RI);
// LLVMSymbolIteratorRef LLVMGetRelocationSymbol(LLVMRelocationIteratorRef RI);
// uint64_t LLVMGetRelocationType(LLVMRelocationIteratorRef RI);
// // NOTE: Caller takes ownership of returned string of the two
// // following functions.
// const char *LLVMGetRelocationTypeName(LLVMRelocationIteratorRef RI);
// const char *LLVMGetRelocationValueString(LLVMRelocationIteratorRef RI);
//
// /** Deprecated: Use LLVMBinaryRef instead. */
// typedef struct LLVMOpaqueObjectFile *LLVMObjectFileRef;
//
// /** Deprecated: Use LLVMCreateBinary instead. */
// LLVMObjectFileRef LLVMCreateObjectFile(LLVMMemoryBufferRef MemBuf);
//
// /** Deprecated: Use LLVMDisposeBinary instead. */
// void LLVMDisposeObjectFile(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileCopySectionIterator instead. */
// LLVMSectionIteratorRef LLVMGetSections(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileIsSectionIteratorAtEnd instead. */
// LLVMBool LLVMIsSectionIteratorAtEnd(LLVMObjectFileRef ObjectFile,
//                                     LLVMSectionIteratorRef SI);
//
// /** Deprecated: Use LLVMObjectFileCopySymbolIterator instead. */
// LLVMSymbolIteratorRef LLVMGetSymbols(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileIsSymbolIteratorAtEnd instead. */
// LLVMBool LLVMIsSymbolIteratorAtEnd(LLVMObjectFileRef ObjectFile,
//                                    LLVMSymbolIteratorRef SI);

