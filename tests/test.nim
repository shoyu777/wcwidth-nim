import
  std/unittest,
  std/unicode,
  wcwidth

test "wcswidth":
  check "コンニチハ".wcswidth == 10
  check "cafe\u0301".wcswidth == 4
  check "café".wcswidth == 4
  check "コンニチハ123１２３".wcswidth == 19
  check "Pokémon GETだぜ！".wcswidth == 17

test "wcwidth":
  check "\u0301".runeAt(0).wcwidth == 0
  check "\u0301".runeAt(0).wcwidth(ambiguousIsWide = true) == 2