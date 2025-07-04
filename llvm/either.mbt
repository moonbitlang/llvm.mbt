///|
pub enum Either[L, R] {
  Left(L)
  Right(R)
}

///|
pub fn[L, R] Either::is_left(self : Either[L, R]) -> Bool {
  match self {
    Left(_) => true
    _ => false
  }
}

///|
pub fn[L, R] Either::is_right(self : Either[L, R]) -> Bool {
  match self {
    Right(_) => true
    _ => false
  }
}

///|
pub fn[L, R] Either::left(self : Either[L, R]) -> L? {
  match self {
    Left(t) => Some(t)
    _ => None
  }
}

///|
pub fn[L, R] Either::right(self : Either[L, R]) -> R? {
  match self {
    Right(k) => Some(k)
    _ => None
  }
}

///|
pub fn[L, R] Either::unwrap_left(self : Either[L, R]) -> L {
  match self {
    Left(t) => t
    _ => abort("Either::unwrap_left: not a left")
  }
}

///|
pub fn[L, R] Either::unwrap_right(self : Either[L, R]) -> R {
  match self {
    Right(k) => k
    _ => abort("Either::unwrap_right: not a right")
  }
}

///|
pub fn[L, R] Either::expect_left(self : Either[L, R], msg : String) -> L {
  match self {
    Left(t) => t
    _ => abort(msg)
  }
}

///|
pub fn[L, R] Either::expect_right(self : Either[L, R], msg : String) -> R {
  match self {
    Right(k) => k
    _ => abort(msg)
  }
}
