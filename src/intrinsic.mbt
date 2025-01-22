
pub struct Intrinsic {
  id: UInt
}

pub fn Intrinsic::new(id: UInt) -> Intrinsic {
  Intrinsic::{ id }
}

// pub fn Intrinsic::find(name: String) -> Intrinsic? {
//   let id = llvm_lookup_intrinsic_id(name)
//
//   if id == 0 {
//     return None
//   }
//
//   Some(Intrinsic::new(id))
// }

// pub fn Intrinsic::is_overloaded(self: Intrinsic) -> Bool {
//   llvm_intrinsic_is_overloaded(self.id) != 0
// }
