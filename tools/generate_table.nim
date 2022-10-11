import
  std/os,
  std/times,
  std/strutils

proc genTable(filePath: string) =
  var fi : File = open(filePath , FileMode.fmRead)
  defer : close(fi)

  let fileName = fi.readLine()
  var valuesFW: seq[tuple[first, last: int, text: string]]
  var valuesA: seq[tuple[first, last: int, text: string]]

  while fi.endOfFile == false :
    let line = fi.readLine()
    if line.startsWith("#") or line == "":
      continue
    let addrs = line.split(';')[0]
    let details = line.split(';')[1]
    if details.startsWith("F") or details.startsWith("W") or details.startsWith("A"):
      var first, last: string = addrs
      if addrs.contains(".."):
        first = addrs.split("..")[0]
        last = addrs.split("..")[1]
      
      let description = if details.split("#")[1].len > 35:
          "#" & details.split("#")[1][11..34]
        else:
          "#" & details.split("#")[1].alignLeft(35)[11..34]

      if details.startsWith("A"):
        valuesA.add((first.parseHexInt, last.parseHexInt, description))
      else:
        valuesFW.add((first.parseHexInt, last.parseHexInt, description))

  var fo : File = open(getAppDir() & "/../src/unicode_table.nim", FileMode.fmWrite)
  fo.writeLine fileName
  fo.writeLine "# This file is auto generated by src/tools/generate_table.nim"
  fo.writeLine "const TABLE_F_W* = ["
  var prevFirst, prevLast: int = 0
  var prevFirstText, prevLastText: string = ""
  for value in valuesFW:
    if prevFirst == 0:
      prevFirst = value.first
      prevLast = value.last
      prevFirstText = value.text
      prevLastText = value.text
      continue

    if prevLast + 1 == value.first:
      prevLast = value.last
      prevLastText = value.text
    else:
      fo.writeLine "  (0x" & prevFirst.toHex(6) & ".int32, 0x" & prevLast.toHex(6) & ".int32), " & prevFirstText & ".." & prevLastText
      prevFirst = value.first
      prevLast = value.last
      prevFirstText = value.text
      prevLastText = value.text
  fo.writeLine "  (0x" & prevFirst.toHex(6) & ".int32, 0x" & prevLast.toHex(6) & ".int32), " & prevFirstText & ".." & prevLastText
  fo.writeLine "]"
  fo.writeLine ""
  fo.writeLine "const TABLE_A* = ["
  prevFirst = 0
  prevLast = 0
  prevFirstText = ""
  prevLastText = ""
  for value in valuesA:
    if prevFirst == 0:
      prevFirst = value.first
      prevLast = value.last
      prevFirstText = value.text
      prevLastText = value.text
      continue

    if prevLast + 1 == value.first:
      prevLast = value.last
      prevLastText = value.text
    else:
      fo.writeLine "  (0x" & prevFirst.toHex(6) & ".int32, 0x" & prevLast.toHex(6) & ".int32), " & prevFirstText & ".." & prevLastText
      prevFirst = value.first
      prevLast = value.last
      prevFirstText = value.text
      prevLastText = value.text
  fo.writeLine "  (0x" & prevFirst.toHex(6) & ".int32, 0x" & prevLast.toHex(6) & ".int32), " & prevFirstText & ".." & prevLastText
  fo.writeLine "]"
  fo.writeLine ""
  defer : close(fo)

let filePath = getAppDir() & "/EastAsianWidth.txt"
genTable(filePath)