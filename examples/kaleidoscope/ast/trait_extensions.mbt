///|
/// Exposes the selected `Debug` methods as regular methods on `Expr`.
pub extend Expr with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `Expr`.
pub extend Expr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Debug` methods as regular methods on `Prototype`.
pub extend Prototype with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `Prototype`.
pub extend Prototype with Eq::{not_equal, equal}

///|
/// Exposes the selected `Debug` methods as regular methods on `PrototypeKind`.
pub extend PrototypeKind with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `PrototypeKind`.
pub extend PrototypeKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Debug` methods as regular methods on `TopLevel`.
pub extend TopLevel with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `TopLevel`.
pub extend TopLevel with Eq::{not_equal, equal}

///|
/// Exposes the selected `Debug` methods as regular methods on `VarBinding`.
pub extend VarBinding with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `VarBinding`.
pub extend VarBinding with Eq::{not_equal, equal}
