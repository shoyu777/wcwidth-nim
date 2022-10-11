# Package

version       = "0.1.0"
author        = "shoyu777"
description   = "Implementation of wcwidth with Nim."
license       = "MIT"
srcDir        = "src"
skipDirs      = @["tests", "tools"]
binDir        = "bin"
bin           = @["wcwidth"]

# Dependencies

requires "nim >= 1.6.8"
