///|
test "Tokenize Code - 1" {
  let code =
    #|fn add(x: Int, y: Int) -> Int {
    #|  return x + y  // simple addition
    #|}
    #|
  let tokens = tokenize(code)
  assert_true(tokens[0].kind is Keyword(Fn))
  assert_true(tokens[1].kind is Lower("add"))
  assert_true(tokens[2].kind is Bracket('('))
  assert_true(tokens[3].kind is Lower("x"))
  assert_true(tokens[4].kind is Symbol(":"))
  assert_true(tokens[5].kind is Upper("Int"))
  assert_true(tokens[6].kind is Symbol(","))
  assert_true(tokens[7].kind is Lower("y"))
  assert_true(tokens[8].kind is Symbol(":"))
  assert_true(tokens[9].kind is Upper("Int"))
  assert_true(tokens[10].kind is Bracket(')'))
  assert_true(tokens[11].kind is Symbol("->"))
  assert_true(tokens[12].kind is Upper("Int"))
  assert_true(tokens[13].kind is Bracket('{'))
  assert_true(tokens[14].kind is Keyword(Return))
  assert_true(tokens[15].kind is Lower("x"))
  assert_true(tokens[16].kind is BinaryOp(Add))
  assert_true(tokens[17].kind is Lower("y"))
  assert_true(tokens[18].kind is Bracket('}'))
  assert_true(tokens[19].kind is EOF)
}

///|
test "Tokenize Code - 2" {
  let code =
    #|struct Point {
    #|  x: Double;
    #|  y: Double;
    #|}
    #|
    #|fn distance(p1: Point, p2: Point) -> Double {
    #|  let dx = p2.x - p1.x;
    #|  let dy = p2.y - p1.y;
    #|  return sqrt(dx * dx + dy * dy);
    #|}
  let tokens = tokenize(code)
  assert_true(tokens[0].kind is Keyword(Struct))
  assert_true(tokens[1].kind is Upper("Point"))
  assert_true(tokens[2].kind is Bracket('{'))
  assert_true(tokens[3].kind is Lower("x"))
  assert_true(tokens[4].kind is Symbol(":"))
  assert_true(tokens[5].kind is Upper("Double"))
  assert_true(tokens[6].kind is Symbol(";"))
  assert_true(tokens[7].kind is Lower("y"))
  assert_true(tokens[8].kind is Symbol(":"))
  assert_true(tokens[9].kind is Upper("Double"))
  assert_true(tokens[10].kind is Symbol(";"))
  assert_true(tokens[11].kind is Bracket('}'))
  assert_true(tokens[12].kind is Keyword(Fn))
  assert_true(tokens[13].kind is Lower("distance"))
  assert_true(tokens[14].kind is Bracket('('))
  assert_true(tokens[15].kind is Lower("p1"))
  assert_true(tokens[16].kind is Symbol(":"))
  assert_true(tokens[17].kind is Upper("Point"))
  assert_true(tokens[18].kind is Symbol(","))
  assert_true(tokens[19].kind is Lower("p2"))
  assert_true(tokens[20].kind is Symbol(":"))
  assert_true(tokens[21].kind is Upper("Point"))
  assert_true(tokens[22].kind is Bracket(')'))
  assert_true(tokens[23].kind is Symbol("->"))
  assert_true(tokens[24].kind is Upper("Double"))
  assert_true(tokens[25].kind is Bracket('{'))
  assert_true(tokens[26].kind is Keyword(Let))
  assert_true(tokens[27].kind is Lower("dx"))
  assert_true(tokens[28].kind is AssignOp(Assign))
  assert_true(tokens[29].kind is Lower("p2"))
  assert_true(tokens[30].kind is Symbol("."))
  assert_true(tokens[31].kind is Lower("x"))
  assert_true(tokens[32].kind is BinaryOp(Sub))
  assert_true(tokens[33].kind is Lower("p1"))
  assert_true(tokens[34].kind is Symbol("."))
  assert_true(tokens[35].kind is Lower("x"))
  assert_true(tokens[36].kind is Symbol(";"))
  assert_true(tokens[37].kind is Keyword(Let))
  assert_true(tokens[38].kind is Lower("dy"))
  assert_true(tokens[39].kind is AssignOp(Assign))
  assert_true(tokens[40].kind is Lower("p2"))
  assert_true(tokens[41].kind is Symbol("."))
  assert_true(tokens[42].kind is Lower("y"))
  assert_true(tokens[43].kind is BinaryOp(Sub))
  assert_true(tokens[44].kind is Lower("p1"))
  assert_true(tokens[45].kind is Symbol("."))
  assert_true(tokens[46].kind is Lower("y"))
  assert_true(tokens[47].kind is Symbol(";"))
  assert_true(tokens[48].kind is Keyword(Return))
  assert_true(tokens[49].kind is Lower("sqrt"))
  assert_true(tokens[50].kind is Bracket('('))
  assert_true(tokens[51].kind is Lower("dx"))
  assert_true(tokens[52].kind is BinaryOp(Mul))
  assert_true(tokens[53].kind is Lower("dx"))
  assert_true(tokens[54].kind is BinaryOp(Add))
  assert_true(tokens[55].kind is Lower("dy"))
  assert_true(tokens[56].kind is BinaryOp(Mul))
  assert_true(tokens[57].kind is Lower("dy"))
  assert_true(tokens[58].kind is Bracket(')'))
  assert_true(tokens[59].kind is Symbol(";"))
  assert_true(tokens[60].kind is Bracket('}'))
  assert_true(tokens[61].kind is EOF)
}

///|
test "Skip Comments" {
  let code =
    #|fnx fn letp mut  // First line
    #|if else struct // Second line
    #|while return    // Third line
  let tokens = tokenize(code)
  assert_true(tokens.length() is 10)
  assert_true(tokens[0].kind is Lower("fnx"))
  assert_true(tokens[1].kind is Keyword(Fn))
  assert_true(tokens[2].kind is Lower("letp"))
  assert_true(tokens[3].kind is Keyword(Mut))
  assert_true(tokens[4].kind is Keyword(If))
  assert_true(tokens[5].kind is Keyword(Else))
  assert_true(tokens[6].kind is Keyword(Struct))
  assert_true(tokens[7].kind is Keyword(While))
  assert_true(tokens[8].kind is Keyword(Return))
  assert_true(tokens[9].kind is EOF)
}

///|
test "Tokenize Float Number" {
  let code =
    #|3.14 0.0 2.718 1.6180339887 0.57721 42.0
  let tokens = tokenize(code)
  assert_true(tokens.length() is 7)
  assert_true(tokens[0].kind is Double(3.14))
  assert_true(tokens[1].kind is Double(0.0))
  assert_true(tokens[2].kind is Double(2.718))
  assert_true(tokens[3].kind is Double(1.6180339887))
  assert_true(tokens[4].kind is Double(0.57721))
  assert_true(tokens[5].kind is Double(42.0))
  assert_true(tokens[6].kind is EOF)

  // Test scientific notation
  let code2 =
    #|1.0e+01 2.5e-3 3.0e10 1.23e5 5.67E+2 9.81e0
  let tokens2 = tokenize(code2)
  assert_true(tokens2.length() is 7)
  assert_true(tokens2[0].kind is Double(1.0e+01))
  assert_true(tokens2[1].kind is Double(2.5e-3))
  assert_true(tokens2[2].kind is Double(3.0e10))
  assert_true(tokens2[3].kind is Double(1.23e5))
  assert_true(tokens2[4].kind is Double(5.67E+2))
  assert_true(tokens2[5].kind is Double(9.81e0))
  assert_true(tokens2[6].kind is EOF)
}

///|
test "Tokenize Identifiers - 1" {
  let code =
    #|myStruct my_var anotherVar _privateVar
  let tokens = tokenize(code)
  assert_true(tokens.length() is 5)
  assert_true(tokens[0].kind is Lower("myStruct"))
  assert_true(tokens[1].kind is Lower("my_var"))
  assert_true(tokens[2].kind is Lower("anotherVar"))
  assert_true(tokens[3].kind is Lower("_privateVar"))
  assert_true(tokens[4].kind is EOF)
}

///|
test "Tokenize Identifiers - 2" {
  let code =
    #|fnx let_var mutp iffy else_ match1 structc enum2
  let tokens = tokenize(code)
  assert_true(tokens.length() is 9)
  assert_true(tokens[0].kind is Lower("fnx"))
  assert_true(tokens[1].kind is Lower("let_var"))
  assert_true(tokens[2].kind is Lower("mutp"))
  assert_true(tokens[3].kind is Lower("iffy"))
  assert_true(tokens[4].kind is Lower("else_"))
  assert_true(tokens[5].kind is Lower("match1"))
  assert_true(tokens[6].kind is Lower("structc"))
  assert_true(tokens[7].kind is Lower("enum2"))
  assert_true(tokens[8].kind is EOF)
}

///|
test "Tokenize Identifiers - 3" {
  let code =
    #|Int Unit Bool Double DoubeList
  let tokens = tokenize(code)
  assert_true(tokens.length() is 6)
  assert_true(tokens[0].kind is Upper("Int"))
  assert_true(tokens[1].kind is Upper("Unit"))
  assert_true(tokens[2].kind is Upper("Bool"))
  assert_true(tokens[3].kind is Upper("Double"))
  assert_true(tokens[4].kind is Upper("DoubeList"))
  assert_true(tokens[5].kind is EOF)
}

///|
test "Tokenize Int Number" {
  let code =
    #|42 0 65 15899 65355 78451 00012
  let tokens = tokenize(code)
  assert_true(tokens.length() is 8)
  assert_true(tokens[0].kind is Int(42))
  assert_true(tokens[1].kind is Int(0))
  assert_true(tokens[2].kind is Int(65))
  assert_true(tokens[3].kind is Int(15899))
  assert_true(tokens[4].kind is Int(65355))
  assert_true(tokens[5].kind is Int(78451))
  assert_true(tokens[6].kind is Int(12))
  assert_true(tokens[7].kind is EOF)
}

///|
test "Tokenize Hexadecimal Number" {
  let code =
    #|0x1a 0xFF 0x0 0x7FFFFFFF 0XABCD 0x10L 0xDeadBeefL
  let tokens = tokenize(code)
  assert_true(tokens.length() is 8)
  assert_true(tokens[0].kind is Int(26)) // 0x1a = 26
  assert_true(tokens[1].kind is Int(255)) // 0xFF = 255
  assert_true(tokens[2].kind is Int(0)) // 0x0 = 0
  assert_true(tokens[3].kind is Int(2147483647)) // 0x7FFFFFFF = max Int
  assert_true(tokens[4].kind is Int(43981)) // 0XABCD = 43981
  assert_true(tokens[5].kind is Int64(16L)) // 0x10L = 16L
  assert_true(tokens[6].kind is Int64(3735928559L)) // 0xDeadBeefL = 3735928559L
  assert_true(tokens[7].kind is EOF)
}

///|
test "Tokenize Keyword" {
  let code =
    #|fn let mut if else struct return _
  let tokens = tokenize(code)
  assert_true(tokens.length() is 9)
  assert_true(tokens[0].kind is Keyword(Fn))
  assert_true(tokens[1].kind is Keyword(Let))
  assert_true(tokens[2].kind is Keyword(Mut))
  assert_true(tokens[3].kind is Keyword(If))
  assert_true(tokens[4].kind is Keyword(Else))
  assert_true(tokens[5].kind is Keyword(Struct))
  assert_true(tokens[6].kind is Keyword(Return))
  assert_true(tokens[7].kind is Wildcard)
  assert_true(tokens[8].kind is EOF)
}

///|
test "Tokenize Binary Operators" {
  let code =
    #|+ - * / % == != < > <= >= && || & | << >> !
  let tokens = tokenize(code)
  assert_true(tokens.length() is 19)
  assert_true(tokens[0].kind is BinaryOp(Add))
  assert_true(tokens[1].kind is BinaryOp(Sub))
  assert_true(tokens[2].kind is BinaryOp(Mul))
  assert_true(tokens[3].kind is BinaryOp(Div))
  assert_true(tokens[4].kind is BinaryOp(Mod))
  assert_true(tokens[5].kind is BinaryOp(Eq))
  assert_true(tokens[6].kind is BinaryOp(NE))
  assert_true(tokens[7].kind is BinaryOp(LT))
  assert_true(tokens[8].kind is BinaryOp(GT))
  assert_true(tokens[9].kind is BinaryOp(LE))
  assert_true(tokens[10].kind is BinaryOp(GE))
  assert_true(tokens[11].kind is BinaryOp(And))
  assert_true(tokens[12].kind is BinaryOp(Or))
  assert_true(tokens[13].kind is BinaryOp(BitAnd))
  assert_true(tokens[14].kind is BinaryOp(BitOr))
  assert_true(tokens[15].kind is BinaryOp(ShiftLeft))
  assert_true(tokens[16].kind is BinaryOp(ShiftRight))
  assert_true(tokens[17].kind is Not)
  assert_true(tokens[18].kind is EOF)
}

///|
test "Tokenize Assignment Operators" {
  let code =
    #|= += -= *= /= %=
  let tokens = tokenize(code)
  assert_true(tokens.length() is 7)
  assert_true(tokens[0].kind is AssignOp(Assign))
  assert_true(tokens[1].kind is AssignOp(PlusAssign))
  assert_true(tokens[2].kind is AssignOp(MinusAssign))
  assert_true(tokens[3].kind is AssignOp(MultAssign))
  assert_true(tokens[4].kind is AssignOp(DivAssign))
  assert_true(tokens[5].kind is AssignOp(ModAssign))
  assert_true(tokens[6].kind is EOF)
}

///|
test "Tokenize String" {
  let code =
    #|"Hello"
    #|"This is a test string"
    #|"Hello world!"
    #|"MiniMoonbit2025"
  let tokens = tokenize(code)
  assert_true(tokens.length() is 5)
  assert_true(tokens[0].kind is String("Hello"))
  assert_true(tokens[1].kind is String("This is a test string"))
  assert_true(tokens[2].kind is String("Hello world!"))
  assert_true(tokens[3].kind is String("MiniMoonbit2025"))
  assert_true(tokens[4].kind is EOF)
}

///|
test "Tokenize Symbols" {
  let code =
    #|( ) [ ] { } . , : ; -> => ! _ ::
  let tokens = tokenize(code)
  assert_true(tokens.length() is 16)
  assert_true(tokens[0].kind is Bracket('('))
  assert_true(tokens[1].kind is Bracket(')'))
  assert_true(tokens[2].kind is Bracket('['))
  assert_true(tokens[3].kind is Bracket(']'))
  assert_true(tokens[4].kind is Bracket('{'))
  assert_true(tokens[5].kind is Bracket('}'))
  assert_true(tokens[6].kind is Symbol("."))
  assert_true(tokens[7].kind is Symbol(","))
  assert_true(tokens[8].kind is Symbol(":"))
  assert_true(tokens[9].kind is Symbol(";"))
  assert_true(tokens[10].kind is Symbol("->"))
  assert_true(tokens[11].kind is Symbol("=>"))
  assert_true(tokens[12].kind is Not)
  assert_true(tokens[13].kind is Wildcard)
  assert_true(tokens[14].kind is Symbol("::"))
  assert_true(tokens[15].kind is EOF)
}

///|
test "Tokenize Unsigned Int Number" {
  let code =
    #|42U 0U 65U 15899U 65355U
  let tokens = tokenize(code)
  assert_true(tokens.length() is 6)
  assert_true(tokens[0].kind is UInt(42U))
  assert_true(tokens[1].kind is UInt(0U))
  assert_true(tokens[2].kind is UInt(65U))
  assert_true(tokens[3].kind is UInt(15899U))
  assert_true(tokens[4].kind is UInt(65355U))
  assert_true(tokens[5].kind is EOF)
}

///|
test "Tokenize Unsigned Int64 Number" {
  let code =
    #|42UL 0UL 65UL 15899UL 1234567890UL
  let tokens = tokenize(code)
  assert_true(tokens.length() is 6)
  assert_true(tokens[0].kind is UInt64(42UL))
  assert_true(tokens[1].kind is UInt64(0UL))
  assert_true(tokens[2].kind is UInt64(65UL))
  assert_true(tokens[3].kind is UInt64(15899UL))
  assert_true(tokens[4].kind is UInt64(1234567890UL))
  assert_true(tokens[5].kind is EOF)
}

///|
test "Tokenize Hexadecimal Unsigned Numbers" {
  let code =
    #|0x1aU 0xFFU 0xFFFFFFFFU 0x10UL 0xDeadBeefUL
  let tokens = tokenize(code)
  assert_true(tokens.length() is 6)
  assert_true(tokens[0].kind is UInt(26U)) // 0x1aU = 26U
  assert_true(tokens[1].kind is UInt(255U)) // 0xFFU = 255U
  assert_true(tokens[2].kind is UInt(4294967295U)) // 0xFFFFFFFFU = max UInt
  assert_true(tokens[3].kind is UInt64(16UL)) // 0x10UL = 16UL
  assert_true(tokens[4].kind is UInt64(3735928559UL)) // 0xDeadBeefUL = 3735928559UL
  assert_true(tokens[5].kind is EOF)
}
