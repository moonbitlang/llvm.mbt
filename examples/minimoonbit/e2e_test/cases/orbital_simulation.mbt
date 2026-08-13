// 天体轨道模拟 - 简化的二体问题

extern "C" fn truncate(x: Double) -> Int = "truncate"
extern "C" fn sqrt(x: Double) -> Double = "sqrt"

struct Vector2D {
  x: Double;
  y: Double;
}

struct Body {
  position: Vector2D;
  velocity: Vector2D;
  mass: Double;
}

fn make_vector(x: Double, y: Double) -> Vector2D {
  Vector2D::{ x: x, y: y }
}

fn make_body(px: Double, py: Double, vx: Double, vy: Double, mass: Double) -> Body {
  Body::{
    position: make_vector(px, py),
    velocity: make_vector(vx, vy),
    mass: mass
  }
}

fn vector_add(v1: Vector2D, v2: Vector2D) -> Vector2D {
  make_vector(v1.x + v2.x, v1.y + v2.y)
}

fn vector_scale(v: Vector2D, s: Double) -> Vector2D {
  make_vector(v.x * s, v.y * s)
}

fn vector_length(v: Vector2D) -> Double {
  sqrt(v.x * v.x + v.y * v.y)
}

fn distance(b1: Body, b2: Body) -> Double {
  let dx = b2.position.x - b1.position.x;
  let dy = b2.position.y - b1.position.y;
  sqrt(dx * dx + dy * dy)
}

fn gravitational_force(b1: Body, b2: Body, g_const: Double) -> Vector2D {
  let dx = b2.position.x - b1.position.x;
  let dy = b2.position.y - b1.position.y;
  let dist = sqrt(dx * dx + dy * dy);
  
  if dist < 0.1 {
    make_vector(0.0, 0.0)
  } else {
    let force_magnitude = g_const * b1.mass * b2.mass / (dist * dist);
    let fx = force_magnitude * dx / dist;
    let fy = force_magnitude * dy / dist;
    make_vector(fx, fy)
  }
}

fn update_body(body: Body, force: Vector2D, dt: Double) -> Body {
  let ax = force.x / body.mass;
  let ay = force.y / body.mass;
  
  let new_vx = body.velocity.x + ax * dt;
  let new_vy = body.velocity.y + ay * dt;
  
  let new_px = body.position.x + new_vx * dt;
  let new_py = body.position.y + new_vy * dt;
  
  Body::{
    position: make_vector(new_px, new_py),
    velocity: make_vector(new_vx, new_vy),
    mass: body.mass
  }
}

fn simulate_orbit(planet: Body, star: Body, g_const: Double, steps: Int, dt: Double) -> Body {
  let mut current_planet = planet;
  let mut i = 0;
  
  while i < steps {
    let force = gravitational_force(current_planet, star, g_const);
    current_planet = update_body(current_planet, force, dt);
    i = i + 1;
  }
  
  current_planet
}

fn print_body_state(body: Body) -> Unit {
  println(truncate(body.position.x * 10.0));
  println(truncate(body.position.y * 10.0));
  println(truncate(body.velocity.x * 10.0));
  println(truncate(body.velocity.y * 10.0));
}

fn test_circular_orbit() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1000.0);
  let planet = make_body(10.0, 0.0, 0.0, 10.0, 1.0);
  
  let result = simulate_orbit(planet, star, 1.0, 100, 0.01);
  print_body_state(result);
}

fn test_elliptical_orbit() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1000.0);
  let planet = make_body(15.0, 0.0, 0.0, 7.0, 1.0);
  
  let result = simulate_orbit(planet, star, 1.0, 200, 0.01);
  print_body_state(result);
}

fn test_close_approach() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 500.0);
  let planet = make_body(5.0, 0.0, 0.0, 15.0, 1.0);
  
  let result = simulate_orbit(planet, star, 1.0, 150, 0.01);
  print_body_state(result);
}

fn test_distant_orbit() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 2000.0);
  let planet = make_body(30.0, 0.0, 0.0, 5.0, 1.0);
  
  let result = simulate_orbit(planet, star, 1.0, 300, 0.01);
  print_body_state(result);
}

fn calculate_energy(body: Body, star: Body, g_const: Double) -> Double {
  let v_squared = body.velocity.x * body.velocity.x + body.velocity.y * body.velocity.y;
  let kinetic = 0.5 * body.mass * v_squared;
  
  let dist = distance(body, star);
  let potential = 0.0 - g_const * body.mass * star.mass / dist;
  
  kinetic + potential
}

fn test_energy_conservation() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1000.0);
  let planet = make_body(10.0, 0.0, 0.0, 10.0, 1.0);
  
  let initial_energy = calculate_energy(planet, star, 1.0);
  println(truncate(initial_energy));
  
  let result = simulate_orbit(planet, star, 1.0, 500, 0.01);
  
  let final_energy = calculate_energy(result, star, 1.0);
  println(truncate(final_energy));
}

fn test_multiple_orbits() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1000.0);
  let planet = make_body(10.0, 0.0, 0.0, 10.0, 1.0);
  
  let mut current = planet;
  let mut orbit = 0;
  
  while orbit < 3 {
    current = simulate_orbit(current, star, 1.0, 100, 0.01);
    print_body_state(current);
    orbit = orbit + 1;
  }
}

fn test_varying_mass() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1500.0);
  let planet = make_body(12.0, 0.0, 0.0, 9.0, 2.0);
  
  let result = simulate_orbit(planet, star, 1.0, 250, 0.01);
  print_body_state(result);
}

fn track_orbit_points(planet: Body, star: Body, g_const: Double, steps: Int, dt: Double, sample_rate: Int) -> Unit {
  let mut current = planet;
  let mut i = 0;
  
  while i < steps {
    if i % sample_rate == 0 {
      println(truncate(current.position.x * 10.0));
      println(truncate(current.position.y * 10.0));
    };
    
    let force = gravitational_force(current, star, g_const);
    current = update_body(current, force, dt);
    i = i + 1;
  }
}

fn test_orbit_tracking() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1000.0);
  let planet = make_body(10.0, 0.0, 0.0, 10.0, 1.0);
  
  track_orbit_points(planet, star, 1.0, 300, 0.01, 50);
}

fn test_high_eccentricity() -> Unit {
  let star = make_body(0.0, 0.0, 0.0, 0.0, 1000.0);
  let planet = make_body(20.0, 0.0, 0.0, 4.0, 1.0);
  
  let result = simulate_orbit(planet, star, 1.0, 400, 0.01);
  print_body_state(result);
}

fn main {
  test_circular_orbit();
  test_elliptical_orbit();
  test_close_approach();
  test_distant_orbit();
  test_energy_conservation();
  test_multiple_orbits();
  test_varying_mass();
  test_orbit_tracking();
  test_high_eccentricity();
}

