extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";

// N-Body simulation in MoonBit
// Converted to MiniMoonbit syntax

// Constants as global let declarations
let pi : Double = 3.141592653589793;
let solar_mass : Double = 4.0 * pi * pi;
let days_per_year : Double = 365.24;

// Create a new planet
fn new_planet(
  x : Double,
  y : Double,
  z : Double,
  vx : Double,
  vy : Double,
  vz : Double,
  mass : Double
) -> (Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double) {
  ([x], [y], [z], [vx], [vy], [vz], mass)
}

let body0: (Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double) = new_planet(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, solar_mass);

let body1: (Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double) = new_planet(
4.84143144246472090,
-1.16032004402742839,
-1.03622044471123109,
1.66007664274403694 * days_per_year,
7.69901118419740425 * days_per_year,
-6.90460016972063023 * days_per_year,
9.54791938424326609 * solar_mass
);

let body2: (Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double) = new_planet(
8.34336671824457987,
4.12479856412430479,
-4.03523417114321381,
-2.76742510726862411 * days_per_year,
4.99852801234917238 * days_per_year,
2.30417297573763929 * days_per_year,
2.85885980666130812 * solar_mass
);

let body3: (Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double) = new_planet(
1.28943695621391310,
-1.51111514016986312,
-2.23307578892655734,
2.96460137564761618 * days_per_year,
2.37847173959480950 * days_per_year,
-2.96589568540237556 * days_per_year,
4.36624404335156298 * solar_mass
);

let body4: (Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double) = new_planet(
1.53796971148509165,
-2.59193146099879641,
1.79258772950371181,
2.68067772490389322 * days_per_year,
1.62824170038242295 * days_per_year,
-9.51592254519715870 * days_per_year,
5.15138902046611451 * solar_mass
);

let bodies : Array[Array[(Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double)]] = Array::make(5000000, [body0, body1, body2, body3, body4]);

// Advance the system by one time step
fn advance(bodies : Array[(Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double)], dt : Double, nbodies : Int) -> Unit {
  // Calculate forces and update velocities
  let mut i = 0;
  while i < nbodies {
    let (bx, by, bz, bvx, bvy, bvz, bmass) = bodies[i];
    let mut j = i + 1;
    while j < nbodies {
      let (b2x, b2y, b2z, b2vx, b2vy, b2vz, b2mass) = bodies[j];
      let dx = bx[0] - b2x[0];
      let dy = by[0] - b2y[0];
      let dz = bz[0] - b2z[0];
      let distance = sqrt(dx * dx + dy * dy + dz * dz);
      let mag = dt / (distance * distance * distance);
      bvx[0] = bvx[0] - dx * b2mass * mag;
      bvy[0] = bvy[0] - dy * b2mass * mag;
      bvz[0] = bvz[0] - dz * b2mass * mag;
      b2vx[0] = b2vx[0] + dx * bmass * mag;
      b2vy[0] = b2vy[0] + dy * bmass * mag;
      b2vz[0] = b2vz[0] + dz * bmass * mag;
      j = j + 1;
    }
    i = i + 1;
  }

  // Update positions
  let mut i = 0;
  while i < nbodies {
    let (bx, by, bz, bvx, bvy, bvz, _) = bodies[i];
    bx[0] = bx[0] + dt * bvx[0];
    by[0] = by[0] + dt * bvy[0];
    bz[0] = bz[0] + dt * bvz[0];
    i = i + 1;
  }
}

// Calculate total energy of the system
fn energy(bodies : Array[(Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double)], nbodies : Int) -> Double {
  let mut e = 0.0;
  let mut i = 0;
  while i < nbodies {
    //let b = bodies[i];
    let (bx, by, bz, bvx, bvy, bvz, bmass) = bodies[i];
    e = e + 0.5 * bmass * (bvx[0] * bvx[0] + bvy[0] * bvy[0] + bvz[0] * bvz[0]);
    let mut j = i + 1;
    while j < nbodies {
      let (b2x, b2y, b2z, _, _, _, b2mass) = bodies[j];
      let dx = bx[0] - b2x[0];
      let dy = by[0] - b2y[0];
      let dz = bz[0] - b2z[0];
      let distance = sqrt(dx * dx + dy * dy + dz * dz);
      e = e - bmass * b2mass / distance;
      j = j + 1;
    }
    i = i + 1;
  }
  e
}

fn print_double(x : Double) -> Unit {
  print_int(int_of_float(x));
}


// Offset momentum to match initial conditions
fn offset_momentum(bodies : Array[(Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Array[Double], Double)], nbodies : Int) -> Unit {
  let mut px = 0.0;
  let mut py = 0.0;
  let mut pz = 0.0;
  let mut i = 0;
  while i < nbodies {
    let (_, _, _, bvx, bvy, bvz, bmass) = bodies[i];
    px = px + bvx[0] * bmass;
    py = py + bvy[0] * bmass;
    pz = pz + bvz[0] * bmass;
    i = i + 1;
  }
  //let sun = bodies[0];
  let (_, _, _, sun_vx, sun_vy, sun_vz, _) = bodies[0];
  sun_vx[0] = -px / solar_mass;
  sun_vy[0] = -py / solar_mass;
  sun_vz[0] = -pz / solar_mass;
}

fn main {
  let bodies = [body0, body1, body2, body3, body4];
  let nbodies = 5;
  let n = 50;
  
  offset_momentum(bodies, nbodies);

  // Format to 9 decimal places like the C version
  let initial_energy = energy(bodies, nbodies);
  let formatted_initial = initial_energy;
  print_double(formatted_initial);
  
  let mut i = 1;
  while i <= n {
    advance(bodies, 0.01, nbodies);
    i = i + 1;
  }
  
  let final_energy = energy(bodies, nbodies);
  let formatted_final = final_energy;
  print_double(formatted_final);
}
