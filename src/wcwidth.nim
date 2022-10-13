import
  std/unicode,
  wcwidth/[wc_table, combining_table]

type
  Interval = tuple[first, last: int32]

# auxiliary function for binary search in interval table
proc bisearch(ucs: int32, table: openArray[Interval]): bool =
  var max = table.len - 1
  var min = 0
  var mid: int

  if ucs < table[0].first or ucs > table[max].last:
    return false

  while max >= min:
    mid = (min + max) div 2
    if ucs > table[mid].last:
      min = mid + 1
    elif ucs < table[mid].first:
      max = mid - 1
    else: return true

  result = false

proc wcwidth*(c: Rune, ambiguousIsWide: bool = false): int =
  ## return the width of a single unicode character
  ## if `ambiguousIsWide = true`, ambiguous character will be 2.
  runnableExamples:
    import std/unicode
    doAssert "a".runeAt(0).wcwidth == 1
    doAssert "湯".runeAt(0).wcwidth == 2
    doAssert "\u0301".runeAt(0).wcwidth == 0
    doAssert "\u0301".runeAt(0).wcwidth(ambiguousIsWide = true) == 2

  let ucs = c.int32

  # test for 8-bit control characters
  if ucs == 0: return 0
  if ucs < 32 or (ucs >= 0x7f and ucs < 0xa0): return -1

  # binary search in table of W and F
  if bisearch(ucs, TABLE_F_W): return 2

  # binary search in table of A
  if ambiguousIsWide and bisearch(ucs, TABLE_A): return 2

  # binary search in table of non-spacing characters
  if bisearch(ucs, TABLE_COM): return 0

  # if we arrive here, ucs is not a combining or C0/C1 control character
  result = 1 +
    (ucs >= 0x1100 and
    (ucs <= 0x115f or                    # Hangul Jamo init. consonants
     ucs == 0x2329 or ucs == 0x232a or
    (ucs >= 0x2e80 and ucs <= 0xa4cf and
     ucs != 0x303f) or                   # CJK ... Yi
    (ucs >= 0xac00 and ucs <= 0xd7a3) or # Hangul Syllables
    (ucs >= 0xf900 and ucs <= 0xfaff) or # CJK Compatibility Ideographs
    (ucs >= 0xfe10 and ucs <= 0xfe19) or # Vertical forms
    (ucs >= 0xfe30 and ucs <= 0xfe6f) or # CJK Compatibility Forms
    (ucs >= 0xff00 and ucs <= 0xff60) or # Fullwidth Forms
    (ucs >= 0xffe0 and ucs <= 0xffe6) or
    (ucs >= 0x20000 and ucs <= 0x2fffd) or
    (ucs >= 0x30000 and ucs <= 0x3fffd))).int

proc wcswidth*(str: string, ambiguousIsWide: bool = false): int =
  ## return the width of string
  ## if `ambiguousIsWide = true`, ambiguous character will be counted as 2.
  runnableExamples:
    doAssert "コンニチハ世界".wcswidth == 14
    doAssert "Pokémon GETだぜ！".wcswidth == 17

  let splitStr: seq[Rune] = str.toRunes
  for c in splitStr:
    let w = wcwidth(c, ambiguousIsWide)
    if w < 0: return -1
    else: inc(result, w)
