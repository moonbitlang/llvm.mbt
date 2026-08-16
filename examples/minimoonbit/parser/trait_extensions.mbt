///|
/// Exposes the selected `Eq` methods as regular methods on `ApplyExpr`.
pub extend ApplyExpr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ApplyExpr`.
pub extend ApplyExpr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `ApplyExprKind`.
pub extend ApplyExprKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ApplyExprKind`.
pub extend ApplyExprKind with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `AssignOp`.
pub extend AssignOp with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `AssignOp`.
pub extend AssignOp with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `AssignStmt`.
pub extend AssignStmt with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `AssignStmt`.
pub extend AssignStmt with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `AtomExpr`.
pub extend AtomExpr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `AtomExpr`.
pub extend AtomExpr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `AtomExprKind`.
pub extend AtomExprKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `AtomExprKind`.
pub extend AtomExprKind with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `BinaryOp`.
pub extend BinaryOp with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `BlockExpr`.
pub extend BlockExpr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `BlockExpr`.
pub extend BlockExpr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `EnumDef`.
pub extend EnumDef with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `EnumDef`.
pub extend EnumDef with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `EnumField`.
pub extend EnumField with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `EnumField`.
pub extend EnumField with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `Expr`.
pub extend Expr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Expr`.
pub extend Expr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `ExprKind`.
pub extend ExprKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ExprKind`.
pub extend ExprKind with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `ExternFunction`.
pub extend ExternFunction with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ExternFunction`.
pub extend ExternFunction with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `ForStmt`.
pub extend ForStmt with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ForStmt`.
pub extend ForStmt with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `IfExpr`.
pub extend IfExpr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `IfExpr`.
pub extend IfExpr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `LeftValue`.
pub extend LeftValue with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `LeftValue`.
pub extend LeftValue with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `LeftValueKind`.
pub extend LeftValueKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `LeftValueKind`.
pub extend LeftValueKind with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `LetMutStmt`.
pub extend LetMutStmt with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `LetMutStmt`.
pub extend LetMutStmt with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `LetStmt`.
pub extend LetStmt with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `LetStmt`.
pub extend LetStmt with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `LocalFunction`.
pub extend LocalFunction with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `LocalFunction`.
pub extend LocalFunction with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `MatchArm`.
pub extend MatchArm with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `MatchArm`.
pub extend MatchArm with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `MatchExpr`.
pub extend MatchExpr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `MatchExpr`.
pub extend MatchExpr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `Param`.
pub extend Param with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Param`.
pub extend Param with Show::{output}

///|
/// Exposes the selected `Debug` methods as regular methods on `ParseError`.
pub extend ParseError with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `Pattern`.
pub extend Pattern with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Pattern`.
pub extend Pattern with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `PatternKind`.
pub extend PatternKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `PatternKind`.
pub extend PatternKind with Show::{to_string, output}

///|
/// Exposes the selected `Show` methods as regular methods on `Program`.
pub extend Program with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `Stmt`.
pub extend Stmt with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Stmt`.
pub extend Stmt with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `StmtKind`.
pub extend StmtKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `StmtKind`.
pub extend StmtKind with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `StructConstructExpr`.
pub extend StructConstructExpr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `StructConstructExpr`.
pub extend StructConstructExpr with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `StructDef`.
pub extend StructDef with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `StructDef`.
pub extend StructDef with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `StructField`.
pub extend StructField with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `StructField`.
pub extend StructField with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `TopFunction`.
pub extend TopFunction with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `TopFunction`.
pub extend TopFunction with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `TopLet`.
pub extend TopLet with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `TopLet`.
pub extend TopLet with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `Type`.
pub extend Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `Type`.
pub extend Type with Show::{output}

///|
/// Exposes the selected `Eq` methods as regular methods on `TypeKind`.
pub extend TypeKind with Eq::{not_equal, equal}

///|
/// Exposes the selected `Hash` methods as regular methods on `TypeKind`.
pub extend TypeKind with Hash::{hash, hash_combine}

///|
/// Exposes the selected `Show` methods as regular methods on `TypeKind`.
pub extend TypeKind with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `WhileStmt`.
pub extend WhileStmt with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `WhileStmt`.
pub extend WhileStmt with Show::{output}
