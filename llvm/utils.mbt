// fn assert(cond: Bool) -> Unit {
//   if cond == false {
//     panic()
//   }
// }

///|
fn is_power_of_two(value : UInt) -> Bool {
  (value & (value - 1)) == 0
}

///|
fn is_alignment_ok(align : UInt) -> Bool {
  align > 0 &&
  is_power_of_two(align) &&
  @math.log2(align.to_uint64().to_double()) < 64.0
}
