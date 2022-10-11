import unittest
import
  std/unicode
import wcwidth

test "wcswidth":
  check "コンニチハ".wcswidth == 10
  check "cafe\u0301".wcswidth == 4
  check "café".wcswidth == 4

test "wcwidth":
  check "\u0301".runeAt(0).wcwidth == 0