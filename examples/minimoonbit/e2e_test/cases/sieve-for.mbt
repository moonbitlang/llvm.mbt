
// Sieve of Eratosthenes using for loops with complex conditions
fn sqrt_int(n: Int) -> Int {
  // Simple integer square root
  if n < 2 {
    n
  } else {
    let mut result = 1;
    for i = 1; i * i <= n; i = i + 1 {
      result = i;
    }
    result
  }
}

fn get_limit(n: Int) -> Int {
  sqrt_int(n)
}

fn sieve(limit: Int, primes: Array[Int]) -> Int {
  let is_prime = Array::make(limit + 1, 1);
  is_prime[0] = 0;
  is_prime[1] = 0;
  
  let sqrt_limit = get_limit(limit);
  
  // Mark non-primes using nested for loops with function calls
  for i = 2; i <= sqrt_limit; i = i + 1 {
    if is_prime[i] == 1 {
      // Mark multiples of i as non-prime
      // Start from i*i, use is_prime.length() to get limit
      let start = i * i;
      let array_limit = is_prime.length() - 1;
      for j = start; j <= array_limit; j = j + i {
        is_prime[j] = 0;
      }
    } else {
      ()
    }
  }
  
  // Count and collect primes using primes.length()
  let mut count = 0;
  let max_limit = is_prime.length() - 1;
  for i = 2; i <= max_limit; i = i + 1 {
    if is_prime[i] == 1 {
      if count < primes.length() {
        primes[count] = i;
        count = count + 1;
      } else {
        ()
      }
    } else {
      ()
    }
  }
  
  count
}

fn sum_primes(primes: Array[Int], count: Int) -> Int {
  let mut sum = 0;
  for i = 0; i < count; i = i + 1 {
    sum = sum + primes[i];
  }
  sum
}

fn count_twin_primes(primes: Array[Int], count: Int) -> Int {
  let mut twins = 0;
  // Twin primes are primes that differ by 2
  for i = 0; i < count - 1; i = i + 1 {
    if primes[i + 1] - primes[i] == 2 {
      twins = twins + 1;
    } else {
      ()
    }
  }
  twins
}

fn main {
  let limit = 100;
  let primes = Array::make(limit, 0);
  
  let count = sieve(limit, primes);
  
  // Print number of primes found
  println(count);
  
  // Print sum of all primes
  let sum = sum_primes(primes, count);
  println(sum);
  
  // Print number of twin prime pairs
  let twins = count_twin_primes(primes, count);
  println(twins);
  
  // Print first 10 primes
  for i = 0; i < 10; i = i + 1 {
    println(primes[i]);
  }
  
  ()
}

