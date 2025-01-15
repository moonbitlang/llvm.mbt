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
fn assert_not(cond: Bool) -> Unit {
  if cond == true {
    panic()
  }
}
