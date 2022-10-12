# wcwidth

Determine columns needed for a fixed-size wide-character string

---

wcwidth is a simple Nim port of [wcwidth](http://man7.org/linux/man-pages/man3/wcswidth.3.html) implemented in C by Markus Kuhn.

## Example

```nim
import wcwidth
doAssert "コンニチハ世界".wcswidth == 14      # while "コンニチハ世界".runelen == 7
doAssert "Pokémon GETだぜ！".wcswidth == 17 # while "Pokémon GETだぜ！".runelen == 21
```

## Document

[here]()

## Unicode Version

This library use Unicode v12.0.0 which is the same as Nim supporting version.
[std/unicode](https://nim-lang.org/docs/unicode.html)

##

## (memo)Tool to generate table

```
nim c -r tools/generate_table.nim
```
