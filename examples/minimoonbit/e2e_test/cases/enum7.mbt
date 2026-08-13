extern "C" fn sqrt(x: Double) -> Double = "sqrt";
extern "C" fn truncate(x: Double) -> Int = "truncate";

enum Location {
  TwoDim(Double, Double)
  TriDim(Double, Double, Double)
  FourDim(Double, Double, Double, Double)
}

fn distance(loc1: Location, loc2: Location) -> Double {
  let (x1, y1, z1, w1) = match loc1 {
    TwoDim(x, y) => (x, y, 0.0, 0.0)
    TriDim(x, y, z) => (x, y, z, 0.0)
    FourDim(x, y, z, w) => (x, y, z, w)
  };

  let (x2, y2, z2, w2) = match loc2 {
    TwoDim(x, y) => (x, y, 0.0, 0.0)
    TriDim(x, y, z) => (x, y, z, 0.0)
    FourDim(x, y, z, w) => (x, y, z, w)
  };

  let disx2 = (x2 - x1)*(x2 - x1)
  let disy2 = (y2 - y1)*(y2 - y1)
  let disz2 = (z2 - z1)*(z2 - z1)
  let disw2 = (w2 - w1)*(w2 - w1)

  sqrt(disx2 + disy2 + disz2 + disw2);
}

fn main {
  let loc1 = TwoDim(3.0, 4.0)
  let loc2 = TriDim(6.0, 8.0, 10.0)
  let loc3 = FourDim(1.0, 2.0, 3.0, 4.0)

  let dis_1_2 = distance(loc1, loc2)
  let dis_1_3 = distance(loc1, loc3)
  let dis_2_3 = distance(loc2, loc3)

  println(truncate(dis_1_2))
  println(truncate(dis_1_3))
  println(truncate(dis_2_3))
}
