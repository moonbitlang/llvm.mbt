fn to_moonbit_bool(self: LLVMBool) -> Bool {
  if self == 0 {
    false
  } else {
    true
  }
}

fn to_llvm_bool(b: Bool) -> LLVMBool {
  if b {
    1
  } else {
    0
  }
}

// fn assert(cond: Bool) -> Unit {
//   if cond == false {
//     panic()
//   }
// }

fn assert_val_ref(val_ref: LLVMValueRef) -> Unit {
  if val_ref.is_null() {
    println("ValueRef is null")
    panic()
  }
}

fn assert_type_ref(type_ref: LLVMTypeRef) -> Unit {
  if type_ref.is_null() {
    println("TypeRef is null")
    panic()
  }
}

fn is_power_of_two(value: UInt) -> Bool {
  (value & (value - 1)) == 0
}

fn is_alignment_ok(align: UInt) -> Bool {
  align > 0 && is_power_of_two(align) && @math.log2(align.to_uint64().to_double()) < 64.0
}
