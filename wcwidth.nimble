# Package

version       = "0.1.1"
author        = "shoyu777"
description   = "Implementation of wcwidth with Nim."
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "tools"]
binDir        = "bin"
bin           = @["wcwidth"]

# Dependencies

requires "nim >= 1.6.8"

# Task
task docs, "Generate documents":
  rmDir "docs"
  exec "nim doc --project -o:docs src/wcwidth.nim"

import strformat

task archive, "Create archived assets":
  let app = "wcwidth"
  let assets = &"{app}_{buildOS}"
  let dir = &"dist/{assets}"
  mkDir &"{dir}/bin"
  cpFile &"bin/{app}", &"{dir}/bin/{app}"
  cpFile "LICENSE", &"{dir}/LICENSE"
  cpFile "README.md", &"{dir}/README.md"
  withDir "dist":
    exec &"tar czf {assets}.tar.gz {assets}"