///|
test "MiniMoonBit source reaches KNF" {
  let source =
    #|fn choose(n : Int) -> Int {
    #|  let next = n + 1;
    #|  if next > 10 {
    #|    next
    #|  } else {
    #|    10
    #|  }
    #|}
  let tokens = @lexer.tokenize(source, source_file="frontend_pipeline.mbt")
  let parsed = @parser.parse(tokens)
  let typed = @typecheck.typecheck(parsed)
  let lowered = @knf.knf_transform(typed)
  inspect(
    lowered,
    content=(
      #|;; KnfProgram: frontend_pipeline.mbt
      #|
      #|fn choose(n: Int) -> Int {
      #|  let tmp : Int = 1;
      #|  let next : Int = n + tmp;
      #|  let tmp$1 : Int = 10;
      #|  if next > tmp$1 {
      #|    next;
      #|  } else {
      #|    10;
      #|  };
      #|}
      #|
    ),
  )
}
