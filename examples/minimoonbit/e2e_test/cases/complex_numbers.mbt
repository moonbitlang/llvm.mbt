extern "C" fn sqrt(x: Double) -> Double = "sqrt";

struct Complex {
  real: Double
  imag: Double
}

fn Complex::new(real: Double, imag: Double) -> Complex {
  Complex::{ real: real, imag: imag }
}

fn Complex::add(self: Complex, other: Complex) -> Complex {
  Complex::new(self.real + other.real, self.imag + other.imag)
}

fn Complex::sub(self: Complex, other: Complex) -> Complex {
  Complex::new(self.real - other.real, self.imag - other.imag)
}

fn Complex::mul(self: Complex, other: Complex) -> Complex {
  let new_real = self.real * other.real - self.imag * other.imag;
  let new_imag = self.real * other.imag + self.imag * other.real;
  Complex::new(new_real, new_imag)
}

fn Complex::magnitude(self: Complex) -> Double {
  sqrt(self.real * self.real + self.imag * self.imag)
}

fn Complex::conjugate(self: Complex) -> Complex {
  Complex::new(self.real, 0.0 - self.imag)
}

fn Complex::scale(self: Complex, factor: Double) -> Complex {
  Complex::new(self.real * factor, self.imag * factor)
}

fn main {
  let z1 = Complex::new(3.0, 4.0);
  let z2 = Complex::new(1.0, 2.0);
  
  let sum = z1.add(z2);
  println("z1 + z2 = " + sum.real.to_string() + " + " + sum.imag.to_string() + "i");
  
  let diff = z1.sub(z2);
  println("z1 - z2 = " + diff.real.to_string() + " + " + diff.imag.to_string() + "i");
  
  let prod = z1.mul(z2);
  println("z1 * z2 = " + prod.real.to_string() + " + " + prod.imag.to_string() + "i");
  
  let mag = z1.magnitude();
  println("magnitude of z1 = " + mag.to_string());
  
  let conj = z1.conjugate();
  println("conjugate of z1 = " + conj.real.to_string() + " + " + conj.imag.to_string() + "i");
  
  let scaled = z1.scale(2.0);
  println("z1 * 2 = " + scaled.real.to_string() + " + " + scaled.imag.to_string() + "i");
}

