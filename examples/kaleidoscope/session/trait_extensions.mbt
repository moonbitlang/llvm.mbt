///|
/// Exposes the selected `Debug` methods as regular methods on `EvalOutcome`.
pub extend EvalOutcome with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `EvalOutcome`.
pub extend EvalOutcome with Eq::{not_equal, equal}

///|
/// Exposes the selected `Debug` methods as regular methods on `SessionError`.
pub extend SessionError with Debug::{to_repr}

///|
/// Exposes the selected `Show` methods as regular methods on `SessionError`.
pub extend SessionError with Show::{to_string, output}
