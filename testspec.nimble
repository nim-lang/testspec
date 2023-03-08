# Package

version       = "0.1.0"
author        = "nim-lang"
description   = "A testable spec for Nim."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

task tests, "Tests":
  exec "testament all"
