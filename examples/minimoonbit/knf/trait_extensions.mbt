///|
/// Exposes the selected `Eq` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Show::{to_string, output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfBlock`.
pub extend KnfBlock with Show::{output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfExpr`.
pub extend KnfExpr with Show::{output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfFunction`.
pub extend KnfFunction with Show::{to_string, output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfProgram`.
pub extend KnfProgram with Show::{to_string, output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfStmt`.
pub extend KnfStmt with Show::{output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfStructDef`.
pub extend KnfStructDef with Show::{to_string, output}

///|
/// Exposes the selected `Show` methods as regular methods on `KnfTopLet`.
pub extend KnfTopLet with Show::{to_string, output}

///|
/// Exposes the selected `Debug` methods as regular methods on `KnfTransformError`.
pub extend KnfTransformError with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `Name`.
pub extend Name with Eq::{not_equal, equal}

///|
/// Exposes the selected `Hash` methods as regular methods on `Name`.
pub extend Name with Hash::{hash, hash_combine}

///|
/// Exposes the selected `Show` methods as regular methods on `Name`.
pub extend Name with Show::{to_string, output}

///|
/// Exposes the selected `Show` methods as regular methods on `Type`.
pub extend Type with Show::{to_string, output}
