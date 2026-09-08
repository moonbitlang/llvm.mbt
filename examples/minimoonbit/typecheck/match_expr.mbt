///|
/// Represents the MiniMoonBit typed AST node or context `MatchExpr`.
pub struct MatchExpr {
  cond : Expr
  arms : Array[MatchArm]
  ty : TypeKind
}

///|
/// Formats `MatchExpr` using MiniMoonBit typed AST notation.
pub impl Show for MatchExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `MatchExpr` value with optional ANSI coloring.
pub fn MatchExpr::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "match expression"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  let ty_str = self.ty.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  let prefix_with_type = "\{prefix} (\{ty_str})"

  // Format condition
  let cond_str = self.cond.to_string(color~)
  let cond_lines = cond_str.split("\n").map(sv => sv.to_owned()).to_array()
  let cond_formatted = @parser.format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )
  let mut result = "\{prefix_with_type}\n\{cond_formatted}"

  // Format arms
  for i = 0; i < self.arms.length(); i = i + 1 {
    let arm = self.arms[i]
    let arm_str = arm.to_string(color~)
    let arm_lines = arm_str.split("\n").map(sv => sv.to_owned()).to_array()
    let is_last = i == self.arms.length() - 1
    let arm_formatted = if is_last {
      @parser.format_lines(arm_lines, head_with="└-", continue_with="  ")
    } else {
      @parser.format_lines(arm_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{arm_formatted}"
  }
  result
}

///|
/// Represents the MiniMoonBit typed AST node or context `MatchArm`.
pub struct MatchArm {
  pattern : Pattern
  match_guard : Expr?
  body : Expr
  toks : ArrayView[Token]
}

///|
/// Formats `MatchArm` using MiniMoonBit typed AST notation.
pub impl Show for MatchArm with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `MatchArm` value with optional ANSI coloring.
pub fn MatchArm::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "match arm"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format pattern
  let pattern_str = self.pattern.to_string(color~)
  let pattern_lines = pattern_str
    .split("\n")
    .map(sv => sv.to_owned())
    .to_array()
  match self.match_guard {
    None => {
      let pattern_formatted = @parser.format_lines(
        pattern_lines,
        head_with="├-pattern: ",
        continue_with="│          ",
      )
      let body_str = self.body.to_string(color~)
      let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
      let body_formatted = @parser.format_lines(
        body_lines,
        head_with="└-body: ",
        continue_with="        ",
      )
      "\{prefix}\n\{pattern_formatted}\n\{body_formatted}"
    }
    Some(guard_expr) => {
      let pattern_formatted = @parser.format_lines(
        pattern_lines,
        head_with="├-pattern: ",
        continue_with="│          ",
      )
      let guard_str = guard_expr.to_string(color~)
      let guard_lines = guard_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let guard_formatted = @parser.format_lines(
        guard_lines,
        head_with="├-guard: ",
        continue_with="│        ",
      )
      let body_str = self.body.to_string(color~)
      let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
      let body_formatted = @parser.format_lines(
        body_lines,
        head_with="└-body: ",
        continue_with="        ",
      )
      "\{prefix}\n\{pattern_formatted}\n\{guard_formatted}\n\{body_formatted}"
    }
  }
}

///|
/// Type-checks the corresponding parser AST form through `check_match_expr`.
pub fn Context::check_match_expr(
  self : Context,
  match_expr : @parser.MatchExpr,
) -> MatchExpr {
  // Step 1. Type Check for Match Expression
  let checked_match_expr = self.check_match_expr_type(match_expr)

  // Step 2. Exhaustiveness Check
  checked_match_expr.check_match_exhaustiveness(self) catch {
    TypeCheckError(err) => self.throw_(match_expr.cond.toks[0], "\{err}", Error)
  }
  checked_match_expr
}

///|
/// Type-checks the corresponding parser AST form through `check_match_expr_type`.
pub fn Context::check_match_expr_type(
  self : Context,
  match_expr : @parser.MatchExpr,
) -> MatchExpr {
  let checked_cond = self.check_expr(match_expr.cond)
  let checked_cond_ty = self.ensure_type(checked_cond.ty)
  if checked_cond_ty is TypeVar(_) {
    self.throw_(
      match_expr.cond.toks[0],
      "Cannot match on expression with unresolved type variable",
      Error,
    )
  }
  let checked_arms : Array[MatchArm] = []
  for arm in match_expr.arms {
    let pattern = try self.from_parser_pattern(arm.pattern) catch {
      err => {
        self.throw_(
          arm.toks[0],
          "Failed to parse pattern in match arm: \{repr(err)}",
          Error,
        )
        Pattern::{ kind: Wildcard, }
      }
    } noraise {
      pat => pat
    }
    self.enter_scope()
    self.bind_pattern_type(pattern, checked_cond.ty) catch {
      err =>
        self.throw_(
          arm.toks[0],
          "Pattern type binding error in match arm: \{repr(err)}",
          Error,
        )
    }
    let checked_guard = match arm.match_guard {
      Some(guard_expr) => {
        let guard_ty = self.check_expr(guard_expr)
        let guard_ty_ty = self.ensure_type(guard_ty.ty)
        if !(guard_ty_ty is Bool) {
          self.throw_(
            guard_expr.toks[0],
            "Match arm guard expression must be of type `Bool`",
            Error,
          )
          None
        } else {
          Some(guard_ty)
        }
      }
      None => None
    }
    let checked_body = self.check_expr(arm.body)
    self.exit_scope()
    let checked_arm = MatchArm::{
      pattern,
      match_guard: checked_guard,
      body: checked_body,
      toks: arm.toks,
    }
    checked_arms.push(checked_arm)
  }
  let tykind = if checked_arms.length() == 0 {
    TypeKind::Unit
  } else {
    let arm_types = checked_arms.map(a => a.body.ty)
    for i, arm_ty in arm_types {
      if !self.is_type_compatible(arm_types[0], arm_ty) {
        self.throw_(
          match_expr.arms[i].toks[0],
          "Type mismatch between match arms: expected \{arm_types[0]}, got \{arm_ty}",
          Error,
        )
      }
    }
    self.ensure_type(arm_types[0])
  }
  MatchExpr::{ cond: checked_cond, arms: checked_arms, ty: tykind, }
}

///|
/// Enumerates the typed forms represented by `PatternSet`.
pub(all) enum PatternSet {
  /// Represents the `Empty` typed AST form.
  Empty
  /// Represents the `Single` typed AST form.
  Single(PatternKind)
  // Represents the universal set of a type - all possible values of that type
  // Used for types that cannot be enumerated (like Double, String, etc.)
  // Can only be reduced by Wildcard or Ident patterns
  /// Represents the `Universal` typed AST form.
  Universal(TypeKind)
  // Only Integer `Int` (Not Support UInt, UInt64, Int64 for now)
  // Integer Complement, e.g. NumberComplement{1, 3, 5}
  // represents all integers except 1, 3, 5
  // if arr is empty, it means all integers
  /// Represents the `NumberComplement` typed AST form.
  NumberComplement(Array[Int])
  /// Represents the `Union` typed AST form.
  Union(Array[PatternSet])
  // tag, name, subpatterns
  /// Represents the `EnumConstructor` typed AST form.
  EnumConstructor(String, String, Array[PatternSet])
  /// Represents the `TupleConstructor` typed AST form.
  TupleConstructor(Array[PatternSet])
} derive(Eq)

///|
/// Formats a `PatternSet` using constructor notation.
pub impl Show for PatternSet with fn output(self, logger) {
  match self {
    Empty => logger.write_string("Empty")
    Single(pattern) => {
      logger.write_string("Single(")
      logger.write_object(pattern)
      logger.write_string(")")
    }
    Universal(ty) => {
      logger.write_string("Universal(")
      logger.write_object(ty)
      logger.write_string(")")
    }
    NumberComplement(values) => {
      logger.write_string("NumberComplement([")
      for index, value in values {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(value)
      }
      logger.write_string("])")
    }
    Union(sets) => {
      logger.write_string("Union([")
      for index, set in sets {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(set)
      }
      logger.write_string("])")
    }
    EnumConstructor(tag, name, subsets) => {
      logger.write_string("EnumConstructor(")
      logger.write_object(tag)
      logger.write_string(", ")
      logger.write_object(name)
      logger.write_string(", [")
      for index, subset in subsets {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(subset)
      }
      logger.write_string("])")
    }
    TupleConstructor(subsets) => {
      logger.write_string("TupleConstructor([")
      for index, subset in subsets {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(subset)
      }
      logger.write_string("])")
    }
  }
}

///|
fn Context::full_pattern_set_of_type(
  self : Self,
  ty : TypeKind,
) -> PatternSet raise TypeCheckError {
  // Use a set to track types being processed to detect cycles
  let visiting : @hashset.HashSet[String] = @hashset.HashSet([])
  self.full_pattern_set_of_type_impl(ty, visiting)
}

///|
fn Context::full_pattern_set_of_type_impl(
  self : Self,
  ty : TypeKind,
  visiting : @hashset.HashSet[String],
) -> PatternSet raise TypeCheckError {
  match ty {
    Int => NumberComplement([])
    Bool => Union([Single(Boolean(true)), Single(Boolean(false))])
    Enum(enum_name) => {
      // Check for recursive types
      if visiting.contains(enum_name) {
        // Recursive type detected, return Universal to break the cycle
        return Universal(ty)
      }
      match self.enum_defs.get(enum_name) {
        Some(enum_def) => {
          // Mark this enum as being visited
          visiting.add(enum_name)
          let variants = []
          for field in enum_def.enum_fields {
            let { name, types, } = field
            let sub_pattern_sets = types.map(t => {
              self.full_pattern_set_of_type_impl(t, visiting)
            })
            variants.push(EnumConstructor(enum_name, name, sub_pattern_sets))
          }
          // Remove from visiting set after processing
          visiting.remove(enum_name)
          Union(variants)
        }
        None =>
          raise TypeCheckError(
            "Cannot get full pattern set for Unknown enum type: \{enum_name} during pattern exhaustiveness check",
          )
      }
    }
    Tuple(elem_types) => {
      let sub_pattern_sets = elem_types.map(t => {
        self.full_pattern_set_of_type_impl(t, visiting)
      })
      TupleConstructor(sub_pattern_sets)
    }
    // For types that cannot be enumerated (Double, String, Float, etc.),
    // return Universal set which can only be matched by Wildcard or Ident
    _ => Universal(ty)
  }
}

///|
fn PatternSet::subtract(
  self : Self,
  pat : PatternKind,
) -> PatternSet raise TypeCheckError {
  match (self, pat) {
    (Empty, _) => Empty
    (_, Wildcard | Ident(_)) => Empty
    // Universal can only be matched by Wildcard or Ident (handled above)
    // Any other pattern on Universal is a type error
    (Universal(_), _) => self
    (Single(pk), pat) if pk == pat => Empty
    (Single(_), _) => self
    (NumberComplement(excluded), Integer(n)) => {
      let new_excluded = excluded.copy()
      new_excluded.push(n)
      NumberComplement(new_excluded)
    }
    // for TupleConstructor(P1, P2, ..., Pn) - Tuple(pat1, pat2, ..., patn)
    // it should be:
    //   (P1 - pat1, P2, ..., Pn) U
    //   (pat1, P2 - Pat2, ..., Pn) U
    //   (pat1, pat2, P3 - pat3, ..., Pn) U
    //   ...
    //   (pat1, pat2, ..., Pn - patn)
    (TupleConstructor(subsets), Tuple(pats)) => {
      // First check if any fixed position (Single) doesn't match the pattern
      // If so, the pattern doesn't overlap with this tuple, return self
      // Note: Ident patterns match everything, so we don't check them
      for i in 0..<subsets.length() {
        match (subsets[i], pats[i].kind) {
          // Wildcard or Ident matches everything
          // this branch is for in case of `pat_kind` being Wildcard or Ident
          (_, Wildcard | Ident(_)) => ()
          (Single(pk), pat_kind) if pk != pat_kind => return self
          _ => ()
        }
      }
      let unioned_sets = []
      for i in 0..<subsets.length() {
        let new_subsets = []
        for k in 0..<i {
          new_subsets.push(Single(pats[k].kind))
        }
        let subs = subsets[i].subtract(pats[i].kind)
        if subs is Empty {
          continue
        }
        new_subsets.push(subs)
        for j in (i + 1)..<subsets.length() {
          new_subsets.push(subsets[j])
        }
        unioned_sets.push(TupleConstructor(new_subsets))
      }
      match unioned_sets.length() {
        0 => Empty
        1 => unioned_sets[0]
        _ => Union(unioned_sets)
      }
    }
    (EnumConstructor(tag, name, subsets), EnumVariant(tag2, name2, pats)) if tag ==
      tag2 &&
      name == name2 => {
      // Special case: pattern like Variant(_) matches all fields
      if pats is [{ kind: Wildcard, }] {
        return Empty
      }
      // Check if pattern length matches subset length
      guard subsets.length() == pats.length() else {
        raise TypeCheckError(
          "Pattern length mismatch: enum variant \{name} expects \{subsets.length()} arguments but got \{pats.length()}",
        )
      }
      // First check if any fixed position (Single) doesn't match the pattern
      // If so, the pattern doesn't overlap with this enum, return self
      // Note: Ident patterns match everything, so we don't check them
      for i in 0..<subsets.length() {
        match (subsets[i], pats[i].kind) {
          // Wildcard or Ident matches everything
          // this branch is for in case of `pat_kind` being Wildcard or Ident
          (_, Wildcard | Ident(_)) => ()
          (Single(pk), pat_kind) if pk != pat_kind => return self
          _ => ()
        }
      }
      let unioned_sets = []
      for i in 0..<subsets.length() {
        let new_subsets = []
        for k in 0..<i {
          new_subsets.push(Single(pats[k].kind))
        }
        let subs = subsets[i].subtract(pats[i].kind)
        if subs is Empty {
          continue
        }
        new_subsets.push(subs)
        for j in (i + 1)..<subsets.length() {
          new_subsets.push(subsets[j])
        }
        unioned_sets.push(EnumConstructor(tag, name, new_subsets))
      }
      match unioned_sets.length() {
        0 => Empty
        1 => unioned_sets[0]
        _ => Union(unioned_sets)
      }
    }
    // If enum constructor and variant have different names, they don't overlap
    (EnumConstructor(_, _, _), EnumVariant(_, _, _)) => self
    (Union(sets), pat) => {
      let new_sets = []
      for s in sets {
        let subtracted = s.subtract(pat)
        if subtracted is Empty {
          continue
        }
        new_sets.push(subtracted)
      }
      match new_sets.length() {
        0 => Empty
        1 => new_sets[0]
        _ => Union(new_sets)
      }
    }
    _ =>
      raise TypeCheckError(
        "TypeMismatch during pattern set subtraction: cannot subtract \{pat} from \{self}",
      )
  }
}

///|
fn PatternSet::to_pattern_hints(self : Self) -> Array[String] {
  match self {
    Empty => []
    Single(pk) => [pk.to_string()]
    Universal(_) => ["_"]
    NumberComplement(_) => ["_"]
    Union(sets) => {
      let hints = []
      for s in sets {
        hints.append(s.to_pattern_hints())
      }
      hints
    }
    EnumConstructor(_, name, subsets) =>
      if subsets.length() == 0 {
        [name]
      } else {
        let sub_hints = subsets.map(s => s.to_pattern_hints())
        let patterns = []
        generate_enum_patterns(name, sub_hints, 0, [], patterns)
        patterns
      }
    TupleConstructor(subsets) => {
      let sub_hints = subsets.map(s => s.to_pattern_hints())
      let patterns = []
      generate_tuple_patterns(sub_hints, 0, [], patterns)
      patterns
    }
  }
}

///|
fn join_strings(arr : Array[String], sep : String) -> String {
  if arr.length() == 0 {
    return ""
  }
  let mut result = arr[0]
  for i = 1; i < arr.length(); i = i + 1 {
    result = result + sep + arr[i]
  }
  result
}

///|
fn generate_enum_patterns(
  name : String,
  sub_hints : Array[Array[String]],
  index : Int,
  current : Array[String],
  result : Array[String],
) -> Unit {
  if index == sub_hints.length() {
    let joined = join_strings(current, ", ")
    let pattern_str = "\{name}(\{joined})"
    result.push(pattern_str)
    return
  }
  for hint in sub_hints[index] {
    let new_current = current.copy()
    new_current.push(hint)
    generate_enum_patterns(name, sub_hints, index + 1, new_current, result)
  }
}

///|
fn generate_tuple_patterns(
  sub_hints : Array[Array[String]],
  index : Int,
  current : Array[String],
  result : Array[String],
) -> Unit {
  if index == sub_hints.length() {
    let joined = join_strings(current, ", ")
    let pattern_str = "(\{joined})"
    result.push(pattern_str)
    return
  }
  for hint in sub_hints[index] {
    let new_current = current.copy()
    new_current.push(hint)
    generate_tuple_patterns(sub_hints, index + 1, new_current, result)
  }
}

///|
fn MatchExpr::check_match_exhaustiveness(
  self : Self,
  ctx : Context,
) -> Unit raise TypeCheckError {
  let ty = ctx.ensure_type(self.cond.ty)
  let full_set = ctx.full_pattern_set_of_type(ty)
  let mut remaining_set = full_set
  for arm in self.arms.filter(arm => arm.match_guard is None) {
    remaining_set = remaining_set.subtract(arm.pattern.kind)
  }
  match remaining_set {
    Empty => ()
    _ => {
      let hints = remaining_set.to_pattern_hints()
      let hint_str = if hints.length() <= 5 {
        join_strings(hints, "\n")
      } else {
        let first_five = []
        for i = 0; i < 5; i = i + 1 {
          first_five.push(hints[i])
        }
        let first_part = join_strings(first_five, "\n")
        let remaining_count = hints.length() - 5
        "\{first_part}\n... and \{remaining_count} more patterns"
      }
      raise TypeCheckError(
        "Non-exhaustive match expression, some patterns are not covered:\n\{hint_str}",
      )
    }
  }
}

///|
test "MatchExpr to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false, })
  let code =
    #|match x { 0 => 1 ; 1 => 2 ; _ => 3 }
  let tokens = @lexer.tokenize(code)

  // Test simple match
  let (parsed, _) = @parser.parse_match_expr(tokens[:])
  let checked = ctx.check_match_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|match expression (Int)
      #|├-cond: variable x (Int)
      #|├-match arm
      #|│ ├-pattern: int pattern 0
      #|│ └-body: int literal 1 (Int)
      #|├-match arm
      #|│ ├-pattern: int pattern 1
      #|│ └-body: int literal 2 (Int)
      #|└-match arm
      #|  ├-pattern: _
      #|  └-body: int literal 3 (Int)
    ),
  )
}

///|
test "MatchExpr to_string Test - With Guard" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false, })
  let code =
    #|match x { n if n > 0 => 1 ; _ => 0 }
  let tokens = @lexer.tokenize(code)

  // Test match with guard
  let (parsed, _) = @parser.parse_match_expr(tokens[:])
  let checked = ctx.check_match_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|match expression (Int)
      #|├-cond: variable x (Int)
      #|├-match arm
      #|│ ├-pattern: ident pattern n
      #|│ ├-guard: binary expr: > (Bool)
      #|│ │        ├-variable n (Int)
      #|│ │        └-int literal 0 (Int)
      #|│ └-body: int literal 1 (Int)
      #|└-match arm
      #|  ├-pattern: _
      #|  └-body: int literal 0 (Int)
    ),
  )
}

///|
test "MatchExpr to_string Test - Tuple Pattern" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("pair", {
    kind: TypeKind::Tuple([TypeKind::Int, TypeKind::Int]),
    mutable: false,
  })
  let code =
    #|match pair { (a, b) => a + b; _ => 0 }
  let tokens = @lexer.tokenize(code)

  // Test match with tuple pattern
  let (parsed, _) = @parser.parse_match_expr(tokens[:])
  let checked = ctx.check_match_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|match expression (Int)
      #|├-cond: variable pair ((Int, Int))
      #|├-match arm
      #|│ ├-pattern: tuple pattern
      #|│ │          ├-ident pattern a
      #|│ │          └-ident pattern b
      #|│ └-body: binary expr: + (Int)
      #|│         ├-variable a (Int)
      #|│         └-variable b (Int)
      #|└-match arm
      #|  ├-pattern: _
      #|  └-body: int literal 0 (Int)
    ),
  )
}
