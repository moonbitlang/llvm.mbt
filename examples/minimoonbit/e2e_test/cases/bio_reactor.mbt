// 生物反应器模拟系统 - 微生物生长和代谢建模

extern "C" fn truncate(x: Double) -> Int = "truncate"

enum ReactionType {
  Growth;
  Maintenance;
  ProductFormation;
  SubstrateUptake;
}

enum ReactorState {
  Lag;
  Exponential;
  Stationary;
  Death;
}

struct Metabolite {
  concentration: Double;
  uptake_rate: Double;
  production_rate: Double;
}

struct Organism {
  biomass: Double;
  growth_rate: Double;
  max_growth_rate: Double;
  yield_coefficient: Double;
}

struct Reactor {
  organism: Organism;
  substrate: Metabolite;
  product: Metabolite;
  volume: Double;
  temperature: Double;
  ph: Double;
}

struct ReactionKinetics {
  km_substrate: Double;
  ki_product: Double;
  optimal_temp: Double;
  optimal_ph: Double;
}

fn make_metabolite(conc: Double, uptake: Double, production: Double) -> Metabolite {
  Metabolite::{
    concentration: conc,
    uptake_rate: uptake,
    production_rate: production
  }
}

fn make_organism(biomass: Double, max_growth: Double, yield: Double) -> Organism {
  Organism::{
    biomass: biomass,
    growth_rate: 0.0,
    max_growth_rate: max_growth,
    yield_coefficient: yield
  }
}

fn make_reactor(
  org: Organism,
  sub: Metabolite,
  prod: Metabolite,
  vol: Double,
  temp: Double,
  ph: Double
) -> Reactor {
  Reactor::{
    organism: org,
    substrate: sub,
    product: prod,
    volume: vol,
    temperature: temp,
    ph: ph
  }
}

fn monod_kinetics(substrate_conc: Double, km: Double, max_rate: Double) -> Double {
  max_rate * substrate_conc / (km + substrate_conc)
}

fn product_inhibition(product_conc: Double, ki: Double) -> Double {
  ki / (ki + product_conc)
}

fn temperature_effect(temp: Double, optimal: Double) -> Double {
  let diff = temp - optimal;
  let factor = 1.0 - diff * diff / 1000.0;
  if factor > 0.0 { factor } else { 0.0 }
}

fn ph_effect(ph: Double, optimal: Double) -> Double {
  let diff = ph - optimal;
  let factor = 1.0 - diff * diff / 10.0;
  if factor > 0.0 { factor } else { 0.0 }
}

fn calculate_growth_rate(reactor: Reactor, kinetics: ReactionKinetics) -> Double {
  let substrate_term = monod_kinetics(
    reactor.substrate.concentration,
    kinetics.km_substrate,
    reactor.organism.max_growth_rate
  );
  
  let inhibition = product_inhibition(reactor.product.concentration, kinetics.ki_product);
  let temp_factor = temperature_effect(reactor.temperature, kinetics.optimal_temp);
  let ph_factor = ph_effect(reactor.ph, kinetics.optimal_ph);
  
  substrate_term * inhibition * temp_factor * ph_factor
}

fn update_reactor(reactor: Reactor, kinetics: ReactionKinetics, dt: Double) -> Reactor {
  let growth_rate = calculate_growth_rate(reactor, kinetics);
  
  let biomass_change = growth_rate * reactor.organism.biomass * dt;
  let new_biomass = reactor.organism.biomass + biomass_change;
  
  let substrate_consumed = biomass_change / reactor.organism.yield_coefficient;
  let new_substrate_conc = reactor.substrate.concentration - substrate_consumed / reactor.volume;
  
  let product_formed = biomass_change * 0.5;
  let new_product_conc = reactor.product.concentration + product_formed / reactor.volume;
  
  let new_organism = Organism::{
    biomass: new_biomass,
    growth_rate: growth_rate,
    max_growth_rate: reactor.organism.max_growth_rate,
    yield_coefficient: reactor.organism.yield_coefficient
  };
  
  let new_substrate = Metabolite::{
    concentration: if new_substrate_conc > 0.0 { new_substrate_conc } else { 0.0 },
    uptake_rate: substrate_consumed / dt,
    production_rate: reactor.substrate.production_rate
  };
  
  let new_product = Metabolite::{
    concentration: new_product_conc,
    uptake_rate: reactor.product.uptake_rate,
    production_rate: product_formed / dt
  };
  
  Reactor::{
    organism: new_organism,
    substrate: new_substrate,
    product: new_product,
    volume: reactor.volume,
    temperature: reactor.temperature,
    ph: reactor.ph
  }
}

fn simulate_batch(reactor: Reactor, kinetics: ReactionKinetics, time: Double, dt: Double) -> Reactor {
  let steps = truncate(time / dt);
  let mut current = reactor;
  let mut i = 0;
  
  while i < steps {
    current = update_reactor(current, kinetics, dt);
    i = i + 1;
  }
  
  current
}

fn determine_growth_phase(reactor: Reactor) -> ReactorState {
  if reactor.organism.biomass < 0.1 {
    Lag
  } else if reactor.organism.growth_rate > reactor.organism.max_growth_rate * 0.5 {
    Exponential
  } else if reactor.substrate.concentration < 0.5 {
    Stationary
  } else {
    Death
  }
}

fn state_to_int(state: ReactorState) -> Int {
  match state {
    Lag => 0;
    Exponential => 1;
    Stationary => 2;
    Death => 3;
  }
}

fn calculate_productivity(reactor: Reactor, time: Double) -> Double {
  reactor.product.concentration * reactor.volume / time
}

fn calculate_yield(biomass: Double, substrate_consumed: Double) -> Double {
  if substrate_consumed > 0.0 {
    biomass / substrate_consumed
  } else {
    0.0
  }
}

fn optimize_temperature(
  reactor: Reactor,
  kinetics: ReactionKinetics,
  temps: Array[Double],
  num_temps: Int,
  time: Double,
  dt: Double
) -> Double {
  let mut best_temp = temps[0];
  let mut best_biomass = 0.0;
  
  let mut i = 0;
  while i < num_temps {
    let test_reactor = Reactor::{
      organism: reactor.organism,
      substrate: reactor.substrate,
      product: reactor.product,
      volume: reactor.volume,
      temperature: temps[i],
      ph: reactor.ph
    };
    
    let result = simulate_batch(test_reactor, kinetics, time, dt);
    
    if result.organism.biomass > best_biomass {
      best_biomass = result.organism.biomass;
      best_temp = temps[i];
    };
    
    i = i + 1;
  }
  
  best_temp
}

fn print_reactor_state(reactor: Reactor) -> Unit {
  println(truncate(reactor.organism.biomass * 100.0));
  println(truncate(reactor.substrate.concentration * 100.0));
  println(truncate(reactor.product.concentration * 100.0));
}

fn test_basic_growth() -> Unit {
  let organism = make_organism(0.1, 0.5, 0.5);
  let substrate = make_metabolite(10.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  let reactor = make_reactor(organism, substrate, product, 1.0, 30.0, 7.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.5,
    ki_product: 10.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let result = simulate_batch(reactor, kinetics, 10.0, 0.1);
  print_reactor_state(result);
}

fn test_substrate_limitation() -> Unit {
  let organism = make_organism(0.5, 0.6, 0.4);
  let substrate = make_metabolite(2.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  let reactor = make_reactor(organism, substrate, product, 1.0, 30.0, 7.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.3,
    ki_product: 15.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let result = simulate_batch(reactor, kinetics, 20.0, 0.1);
  print_reactor_state(result);
}

fn test_product_inhibition() -> Unit {
  let organism = make_organism(0.2, 0.5, 0.5);
  let substrate = make_metabolite(15.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  let reactor = make_reactor(organism, substrate, product, 1.0, 30.0, 7.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.5,
    ki_product: 2.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let result = simulate_batch(reactor, kinetics, 15.0, 0.1);
  print_reactor_state(result);
}

fn test_temperature_effect() -> Unit {
  let organism = make_organism(0.1, 0.5, 0.5);
  let substrate = make_metabolite(10.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  
  let reactor1 = make_reactor(organism, substrate, product, 1.0, 25.0, 7.0);
  let reactor2 = make_reactor(organism, substrate, product, 1.0, 35.0, 7.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.5,
    ki_product: 10.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let result1 = simulate_batch(reactor1, kinetics, 10.0, 0.1);
  let result2 = simulate_batch(reactor2, kinetics, 10.0, 0.1);
  
  print_reactor_state(result1);
  print_reactor_state(result2);
}

fn test_ph_effect() -> Unit {
  let organism = make_organism(0.1, 0.5, 0.5);
  let substrate = make_metabolite(10.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  
  let reactor1 = make_reactor(organism, substrate, product, 1.0, 30.0, 6.0);
  let reactor2 = make_reactor(organism, substrate, product, 1.0, 30.0, 8.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.5,
    ki_product: 10.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let result1 = simulate_batch(reactor1, kinetics, 10.0, 0.1);
  let result2 = simulate_batch(reactor2, kinetics, 10.0, 0.1);
  
  print_reactor_state(result1);
  print_reactor_state(result2);
}

fn test_growth_phases() -> Unit {
  let organism = make_organism(0.05, 0.5, 0.5);
  let substrate = make_metabolite(10.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  let reactor = make_reactor(organism, substrate, product, 1.0, 30.0, 7.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.5,
    ki_product: 10.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let mut current = reactor;
  let mut time = 0.0;
  
  while time < 30.0 {
    let state = determine_growth_phase(current);
    if truncate(time) % 10 == 0 {
      println(state_to_int(state));
    };
    current = update_reactor(current, kinetics, 1.0);
    time = time + 1.0;
  }
}

fn test_productivity() -> Unit {
  let organism = make_organism(0.1, 0.5, 0.5);
  let substrate = make_metabolite(10.0, 0.0, 0.0);
  let product = make_metabolite(0.0, 0.0, 0.0);
  let reactor = make_reactor(organism, substrate, product, 1.0, 30.0, 7.0);
  
  let kinetics = ReactionKinetics::{
    km_substrate: 0.5,
    ki_product: 10.0,
    optimal_temp: 30.0,
    optimal_ph: 7.0
  };
  
  let result = simulate_batch(reactor, kinetics, 15.0, 0.1);
  let productivity = calculate_productivity(result, 15.0);
  
  println(truncate(productivity * 1000.0));
}

fn main {
  test_basic_growth();
  test_substrate_limitation();
  test_product_inhibition();
  test_temperature_effect();
  test_ph_effect();
  test_growth_phases();
  test_productivity();
}

