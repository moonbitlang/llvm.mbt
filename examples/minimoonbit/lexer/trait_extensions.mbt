///|
/// Exposes the selected `Debug` methods as regular methods on `AssignOp`.
pub extend AssignOp with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `AssignOp`.
pub extend AssignOp with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `AssignOp`.
pub extend AssignOp with Show::{to_string, output}

///|
/// Exposes the selected `ToJson` methods as regular methods on `AssignOp`.
pub extend AssignOp with ToJson::{to_json}

///|
/// Exposes the selected `Debug` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Show::{to_string, output}

///|
/// Exposes the selected `Debug` methods as regular methods on `Keyword`.
pub extend Keyword with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `Keyword`.
pub extend Keyword with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Keyword`.
pub extend Keyword with Show::{to_string, output}

///|
/// Exposes the selected `Debug` methods as regular methods on `ThrowLevel`.
pub extend ThrowLevel with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `Token`.
pub extend Token with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Token`.
pub extend Token with Show::{to_string, output}

///|
/// Exposes the selected `Debug` methods as regular methods on `TokenKind`.
pub extend TokenKind with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `TokenKind`.
pub extend TokenKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `TokenKind`.
pub extend TokenKind with Show::{to_string, output}

///|
/// Exposes the selected `Debug` methods as regular methods on `TokenizeError`.
pub extend TokenizeError with Debug::{to_repr}
