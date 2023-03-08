discard """
  targets: "c cpp js"
"""

import std/assertions

block integers:
  ## There are several kinds of integers in Nim.

  ## Integer literals without type suffix are of int type
  doAssert 1 is int

  ## Integer types with number suffix have platform-independent sizes
  doAssert sizeof(int8) == 1
  doAssert sizeof(int16) == 2
  doAssert sizeof(int32) == 4
  doAssert sizeof(int64) == 8
  doAssert sizeof(uint8) == 1
  doAssert sizeof(uint16) == 2
  doAssert sizeof(uint32) == 4
  doAssert sizeof(uint64) == 8
