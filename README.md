# testspec

Language Specification Tests.

## Structure

Tests are under the `tests/spec` directory, which is devided into
three levels. The first level starts with directory with a prefixc `s`, such as `s01_basic`, `s02_core` etc. The number following the prefix `s` decides the order of sections. The second level starts with a prefix `c`, such as `c01_primitive_types`, `c01_variables` etc. The third level are actual tests files, which should start with a prefix `t`.

## Format

The project uses `testament` to verify the correctness of specifications. Here is a simple example how a test file should look like.

```nim
discard """
  targets: "c cpp js"
"""

import std/assertions

block boolean:
  ## False and true are boolean types. Boolean types are called `bool` in Nim
  doAssert false is bool
  doAssert true is bool
```

You are encouraged to write detailed documentation and cover every usage.
