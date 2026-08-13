// 金融预测系统 - 时间序列分析和风险评估

extern "C" fn truncate(x: Double) -> Int = "truncate"
extern "C" fn sqrt(x: Double) -> Double = "sqrt"
extern "C" fn float_of_int(x: Int) -> Double = "float_of_int"
extern "C" fn int_of_float(x: Double) -> Int = "int_of_float"


enum TrendType {
  Bullish;
  Bearish;
  Sideways;
}

enum RiskLevel {
  Low;
  Medium;
  High;
  Critical;
}

enum SignalType {
  Buy;
  Sell;
  Hold;
}

struct PriceData {
  price: Double;
  volume: Int;
  timestamp: Int;
}

struct MovingAverage {
  short_period: Int;
  long_period: Int;
  short_ma: Double;
  long_ma: Double;
}

struct Indicator {
  rsi: Double;
  macd: Double;
  signal: Double;
}

struct Portfolio {
  cash: Double;
  shares: Int;
  total_value: Double;
  roi: Double;
}

struct TradingSignal {
  signal_type: SignalType;
  confidence: Double;
  price: Double;
}

fn make_price_data(price: Double, volume: Int, time: Int) -> PriceData {
  PriceData::{ price: price, volume: volume, timestamp: time }
}

fn make_portfolio(cash: Double, shares: Int) -> Portfolio {
  Portfolio::{
    cash: cash,
    shares: shares,
    total_value: cash,
    roi: 0.0
  }
}

fn calculate_sma(prices: Array[Double], period: Int, index: Int) -> Double {
  if index < period - 1 {
    0.0
  } else {
    let mut sum = 0.0;
    let mut i = 0;
    while i < period {
      sum = sum + prices[index - i];
      i = i + 1;
    }
    sum / float_of_int(period)
  }
}

fn calculate_ema(prices: Array[Double], period: Int, index: Int, prev_ema: Double) -> Double {
  if index == 0 {
    prices[0]
  } else {
    let alpha = 2.0 / float_of_int(period + 1);
    alpha * prices[index] + (1.0 - alpha) * prev_ema
  }
}

fn calculate_rsi(prices: Array[Double], period: Int, index: Int) -> Double {
  if index < period {
    50.0
  } else {
    let mut gains = 0.0;
    let mut losses = 0.0;
    
    let mut i = 0;
    while i < period {
      let change = prices[index - i] - prices[index - i - 1];
      if change > 0.0 {
        gains = gains + change;
      } else {
        losses = losses - change;
      };
      i = i + 1;
    }
    
    let avg_gain = gains / float_of_int(period);
    let avg_loss = losses / float_of_int(period);
    
    if avg_loss == 0.0 {
      100.0
    } else {
      let rs = avg_gain / avg_loss;
      100.0 - 100.0 / (1.0 + rs)
    }
  }
}

fn calculate_volatility(prices: Array[Double], period: Int, index: Int) -> Double {
  if index < period {
    0.0
  } else {
    let mean = calculate_sma(prices, period, index);
    let mut variance = 0.0;
    
    let mut i = 0;
    while i < period {
      let diff = prices[index - i] - mean;
      variance = variance + diff * diff;
      i = i + 1;
    }
    
    sqrt(variance / float_of_int(period))
  }
}

fn identify_trend(short_ma: Double, long_ma: Double, prev_short: Double, prev_long: Double) -> TrendType {
  if short_ma > long_ma && prev_short <= prev_long {
    Bullish
  } else if short_ma < long_ma && prev_short >= prev_long {
    Bearish
  } else {
    Sideways
  }
}

fn assess_risk(volatility: Double, rsi: Double) -> RiskLevel {
  let vol_score = if volatility > 5.0 {
    2
  } else if volatility > 2.0 {
    1
  } else {
    0
  };
  
  let rsi_score = if rsi > 70.0 || rsi < 30.0 {
    2
  } else if rsi > 60.0 || rsi < 40.0 {
    1
  } else {
    0
  };
  
  let total_score = vol_score + rsi_score;
  
  if total_score >= 4 {
    Critical
  } else if total_score >= 3 {
    High
  } else if total_score >= 2 {
    Medium
  } else {
    Low
  }
}

fn generate_signal(rsi: Double, short_ma: Double, long_ma: Double, price: Double) -> TradingSignal {
  let mut signal = Hold;
  let mut confidence = 0.5;
  
  if rsi < 30.0 && short_ma > long_ma {
    signal = Buy;
    confidence = 0.8;
  } else if rsi > 70.0 && short_ma < long_ma {
    signal = Sell;
    confidence = 0.8;
  } else if short_ma > long_ma {
    signal = Buy;
    confidence = 0.6;
  } else if short_ma < long_ma {
    signal = Sell;
    confidence = 0.6;
  };
  
  TradingSignal::{ signal_type: signal, confidence: confidence, price: price }
}

fn execute_trade(portfolio: Portfolio, signal: TradingSignal, shares_to_trade: Int) -> Portfolio {
  match signal.signal_type {
    Buy => {
      let cost = float_of_int(shares_to_trade) * signal.price;
      if cost <= portfolio.cash {
        Portfolio::{
          cash: portfolio.cash - cost,
          shares: portfolio.shares + shares_to_trade,
          total_value: portfolio.total_value,
          roi: portfolio.roi
        }
      } else {
        portfolio
      }
    };
    Sell => {
      if shares_to_trade <= portfolio.shares {
        let revenue = float_of_int(shares_to_trade) * signal.price;
        Portfolio::{
          cash: portfolio.cash + revenue,
          shares: portfolio.shares - shares_to_trade,
          total_value: portfolio.total_value,
          roi: portfolio.roi
        }
      } else {
        portfolio
      }
    };
    Hold => portfolio;
  }
}

fn update_portfolio_value(portfolio: Portfolio, current_price: Double) -> Portfolio {
  let value = portfolio.cash + float_of_int(portfolio.shares) * current_price;
  Portfolio::{
    cash: portfolio.cash,
    shares: portfolio.shares,
    total_value: value,
    roi: (value - 10000.0) / 10000.0 * 100.0
  }
}

fn backtest_strategy(
  prices: Array[Double],
  num_prices: Int,
  initial_capital: Double
) -> Portfolio {
  let mut portfolio = make_portfolio(initial_capital, 0);
  let mut i = 20;
  
  while i < num_prices {
    let short_ma = calculate_sma(prices, 5, i);
    let long_ma = calculate_sma(prices, 20, i);
    let rsi = calculate_rsi(prices, 14, i);
    
    let signal = generate_signal(rsi, short_ma, long_ma, prices[i]);
    
    match signal.signal_type {
      Buy => {
        if portfolio.cash > prices[i] * 10.0 {
          portfolio = execute_trade(portfolio, signal, 10);
        };
      };
      Sell => {
        if portfolio.shares >= 10 {
          portfolio = execute_trade(portfolio, signal, 10);
        };
      };
      Hold => { () };
    };
    
    portfolio = update_portfolio_value(portfolio, prices[i]);
    i = i + 1;
  }
  
  portfolio
}

fn signal_to_int(sig: SignalType) -> Int {
  match sig {
    Buy => 1;
    Sell => 0 - 1;
    Hold => 0;
  }
}

fn risk_to_int(risk: RiskLevel) -> Int {
  match risk {
    Low => 0;
    Medium => 1;
    High => 2;
    Critical => 3;
  }
}

fn trend_to_int(trend: TrendType) -> Int {
  match trend {
    Bullish => 1;
    Bearish => 0 - 1;
    Sideways => 0;
  }
}

fn test_moving_averages() -> Unit {
  let prices = [100.0, 102.0, 105.0, 103.0, 107.0, 110.0, 108.0, 112.0, 115.0, 113.0];
  
  let ma5 = calculate_sma(prices, 5, 9);
  let ma3 = calculate_sma(prices, 3, 9);
  
  println(truncate(ma5 * 10.0));
  println(truncate(ma3 * 10.0));
}

fn test_rsi() -> Unit {
  let prices = [100.0, 102.0, 101.0, 103.0, 105.0, 104.0, 106.0, 108.0, 107.0, 109.0, 111.0, 110.0, 112.0, 114.0, 113.0];
  
  let rsi = calculate_rsi(prices, 14, 14);
  println(truncate(rsi));
}

fn test_volatility() -> Unit {
  let prices = [100.0, 105.0, 95.0, 110.0, 90.0, 115.0, 85.0, 120.0, 100.0, 110.0];
  
  let vol = calculate_volatility(prices, 5, 9);
  println(truncate(vol * 10.0));
}

fn test_trend_identification() -> Unit {
  let trend1 = identify_trend(105.0, 100.0, 98.0, 101.0);
  let trend2 = identify_trend(95.0, 100.0, 102.0, 99.0);
  let trend3 = identify_trend(100.0, 100.0, 100.0, 100.0);
  
  println(trend_to_int(trend1));
  println(trend_to_int(trend2));
  println(trend_to_int(trend3));
}

fn test_risk_assessment() -> Unit {
  let risk1 = assess_risk(1.0, 50.0);
  let risk2 = assess_risk(3.0, 75.0);
  let risk3 = assess_risk(6.0, 80.0);
  
  println(risk_to_int(risk1));
  println(risk_to_int(risk2));
  println(risk_to_int(risk3));
}

fn test_signal_generation() -> Unit {
  let sig1 = generate_signal(25.0, 105.0, 100.0, 100.0);
  let sig2 = generate_signal(75.0, 95.0, 100.0, 100.0);
  let sig3 = generate_signal(50.0, 100.0, 100.0, 100.0);
  
  println(signal_to_int(sig1.signal_type));
  println(signal_to_int(sig2.signal_type));
  println(signal_to_int(sig3.signal_type));
}

fn test_portfolio_management() -> Unit {
  let portfolio = make_portfolio(10000.0, 0);
  let buy_signal = TradingSignal::{ signal_type: Buy, confidence: 0.8, price: 100.0 };
  
  let portfolio2 = execute_trade(portfolio, buy_signal, 50);
  println(truncate(portfolio2.cash));
  println(portfolio2.shares);
  
  let sell_signal = TradingSignal::{ signal_type: Sell, confidence: 0.8, price: 110.0 };
  let portfolio3 = execute_trade(portfolio2, sell_signal, 25);
  println(truncate(portfolio3.cash));
  println(portfolio3.shares);
}

fn test_backtesting() -> Unit {
  let prices = [
    100.0, 102.0, 104.0, 103.0, 105.0, 107.0, 106.0, 108.0, 110.0, 109.0,
    111.0, 113.0, 112.0, 114.0, 116.0, 115.0, 117.0, 119.0, 118.0, 120.0,
    122.0, 121.0, 123.0, 125.0, 124.0
  ];
  
  let result = backtest_strategy(prices, 25, 10000.0);
  println(truncate(result.total_value));
  println(truncate(result.roi * 10.0));
}

fn main {
  test_moving_averages();
  test_rsi();
  test_volatility();
  test_trend_identification();
  test_risk_assessment();
  test_signal_generation();
  test_portfolio_management();
  test_backtesting();
}

