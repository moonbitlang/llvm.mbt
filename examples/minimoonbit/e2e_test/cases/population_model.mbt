// 种群动力学模型模拟 - Lotka-Volterra捕食者-猎物模型

extern "C" fn truncate(x: Double) -> Int = "truncate"

struct Population {
  prey: Double;
  predator: Double;
  prey_growth: Double;
  predation_rate: Double;
  predator_death: Double;
  conversion_rate: Double;
}

fn make_population(
  prey: Double,
  predator: Double,
  prey_growth: Double,
  predation_rate: Double,
  predator_death: Double,
  conversion_rate: Double
) -> Population {
  Population::{
    prey: prey,
    predator: predator,
    prey_growth: prey_growth,
    predation_rate: predation_rate,
    predator_death: predator_death,
    conversion_rate: conversion_rate
  }
}

fn step_euler(pop: Population, dt: Double) -> Population {
  let dprey = pop.prey_growth * pop.prey - pop.predation_rate * pop.prey * pop.predator;
  let dpredator = pop.conversion_rate * pop.predation_rate * pop.prey * pop.predator - pop.predator_death * pop.predator;
  
  Population::{
    prey: pop.prey + dprey * dt,
    predator: pop.predator + dpredator * dt,
    prey_growth: pop.prey_growth,
    predation_rate: pop.predation_rate,
    predator_death: pop.predator_death,
    conversion_rate: pop.conversion_rate
  }
}

fn simulate_population(pop: Population, steps: Int, dt: Double) -> Population {
  let mut current = pop;
  let mut i = 0;
  
  while i < steps {
    current = step_euler(current, dt);
    i = i + 1;
  }
  
  current
}

fn print_population(pop: Population) -> Unit {
  println(truncate(pop.prey * 10.0));
  println(truncate(pop.predator * 10.0));
}

fn simulate_and_sample(pop: Population, total_steps: Int, sample_interval: Int, dt: Double) -> Unit {
  let mut current = pop;
  let mut step = 0;
  
  while step < total_steps {
    if step % sample_interval == 0 {
      print_population(current);
    };
    current = step_euler(current, dt);
    step = step + 1;
  }
}

fn test_stable_equilibrium() -> Unit {
  let pop = make_population(10.0, 5.0, 0.1, 0.02, 0.1, 0.5);
  let result = simulate_population(pop, 1000, 0.1);
  print_population(result);
}

fn test_oscillation() -> Unit {
  let pop = make_population(20.0, 5.0, 0.5, 0.05, 0.3, 0.8);
  simulate_and_sample(pop, 500, 50, 0.1);
}

fn test_predator_dominance() -> Unit {
  let pop = make_population(50.0, 20.0, 0.3, 0.08, 0.2, 1.0);
  let result = simulate_population(pop, 300, 0.1);
  print_population(result);
}

fn test_prey_growth() -> Unit {
  let pop = make_population(5.0, 1.0, 0.8, 0.02, 0.4, 0.5);
  let result = simulate_population(pop, 200, 0.1);
  print_population(result);
}

fn test_extinction_risk() -> Unit {
  let pop = make_population(3.0, 8.0, 0.2, 0.1, 0.1, 0.3);
  let result = simulate_population(pop, 400, 0.05);
  print_population(result);
}

fn test_balanced_system() -> Unit {
  let pop = make_population(15.0, 10.0, 0.4, 0.04, 0.3, 0.7);
  simulate_and_sample(pop, 600, 100, 0.1);
}

fn test_high_prey_growth() -> Unit {
  let pop = make_population(10.0, 5.0, 1.0, 0.03, 0.25, 0.6);
  let result = simulate_population(pop, 500, 0.05);
  print_population(result);
}

fn test_low_predation() -> Unit {
  let pop = make_population(20.0, 3.0, 0.3, 0.01, 0.2, 0.4);
  let result = simulate_population(pop, 800, 0.1);
  print_population(result);
}

struct EcosystemState {
  time: Int;
  prey_count: Int;
  predator_count: Int;
}

fn record_trajectory(pop: Population, steps: Int, dt: Double, records: Array[EcosystemState]) -> Int {
  let mut current = pop;
  let mut i = 0;
  let mut record_count = 0;
  
  while i < steps {
    if i % 50 == 0 && record_count < 10 {
      let state = EcosystemState::{
        time: i,
        prey_count: truncate(current.prey),
        predator_count: truncate(current.predator)
      };
      records[record_count] = state;
      record_count = record_count + 1;
    };
    current = step_euler(current, dt);
    i = i + 1;
  }
  
  record_count
}

fn analyze_trajectory() -> Unit {
  let pop = make_population(25.0, 8.0, 0.4, 0.04, 0.25, 0.6);
  let records = Array::make(10, EcosystemState::{ time: 0, prey_count: 0, predator_count: 0 });
  
  let count = record_trajectory(pop, 500, 0.1, records);
  
  let mut i = 0;
  while i < count {
    println(records[i].prey_count);
    println(records[i].predator_count);
    i = i + 1;
  }
}

fn test_rapid_changes() -> Unit {
  let pop = make_population(30.0, 10.0, 0.6, 0.06, 0.4, 0.9);
  simulate_and_sample(pop, 400, 40, 0.05);
}

fn main {
  test_stable_equilibrium();
  test_oscillation();
  test_predator_dominance();
  test_prey_growth();
  test_extinction_risk();
  test_balanced_system();
  test_high_prey_growth();
  test_low_predation();
  analyze_trajectory();
  test_rapid_changes();
}

