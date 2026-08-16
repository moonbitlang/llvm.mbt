///|
/// Exposes the selected `Debug` methods as regular methods on `LexError`.
pub extend LexError with Debug::{to_repr}

///|
/// Exposes the selected `Debug` methods as regular methods on `SourcePos`.
pub extend SourcePos with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `SourcePos`.
pub extend SourcePos with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `SourcePos`.
pub extend SourcePos with Show::{to_string, output}

///|
/// Exposes the selected `Debug` methods as regular methods on `Token`.
pub extend Token with Debug::{to_repr}

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
