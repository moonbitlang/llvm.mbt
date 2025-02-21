
pub struct MemoryBuffer {
  memory_buffer: @unsafe.LLVMMemoryBufferRef
}

pub fn MemoryBuffer::new(mbuf: @unsafe.LLVMMemoryBufferRef) -> MemoryBuffer {
  // assert_not(mbuf.is_null()))

  MemoryBuffer::{
    memory_buffer: mbuf
  }
}

pub fn MemoryBuffer::as_mem_buf(self: MemoryBuffer) -> @unsafe.LLVMMemoryBufferRef {
  self.memory_buffer
}

// pub fn MemoryBuffer::create_from_file(path:String) -> Result[MemoryBuffer, String] {
//   let (mbuf, msg, is_ok) = @unsafe.llvm_create_memory_buffer_with_contents_of_file(path)
//
//   if is_ok {
//     Ok(MemoryBuffer::new(mbuf))
//   } else {
//     Err(msg)
//   }
// }
//
// pub fn MemoryBuffer::create_from_stdin() -> Result[MemoryBuffer, String] {
//   let (mbuf, msg, is_ok) = @unsafe.llvm_create_memory_buffer_with_stdin()
//
//   if is_ok {
//     Ok(MemoryBuffer::new(mbuf))
//   } else {
//     Err(msg)
//   }
// }

pub fn MemoryBuffer::get_size(self: MemoryBuffer) -> Int {
  @unsafe.llvm_get_buffer_size(self.memory_buffer)
}

// create_object_file

pub fn MemoryBuffer::dispose(self: MemoryBuffer) -> Unit {
  @unsafe.llvm_dispose_memory_buffer(self.memory_buffer)
}

pub fn MemoryBuffer::drop(self: MemoryBuffer) -> Unit {
  self.dispose()
}
