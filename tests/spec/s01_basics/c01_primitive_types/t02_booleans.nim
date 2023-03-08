discard """
  targets: "c cpp js"
"""

import std/assertions

block boolean:
  ## False and true are boolean types. Boolean types are called `bool` in Nim
  doAssert false is bool
  doAssert true is bool
