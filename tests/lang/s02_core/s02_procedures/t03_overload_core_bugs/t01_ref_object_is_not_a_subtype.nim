discard """
errormsg: "type mismatch: got <ref Derived>"
"""

##[
Rejects valid code, or this part of the overload resolution is underspecified.

`ref object` in definition is handled differently from `ref T` in the argument
when overload resolution is considered.
]##



# knownIssue: "ref object is not a proper subtype"

# When fixed should be added back to the core overload resolution, "subtype" section
block subtype_ref_object:
  block no_qualifier:
    ## Identical to previous example, but used here to highlight lack of
    ## difference in handling of these cases.
    type
      Base = object of RootObj
      Derived = object of Base

    proc impl(arg: Base) = discard

    impl(Derived())

  block as_qualifier:
    type
      Base = object of RootObj
      Derived = object of Base

    proc impl(arg: ref Base) = discard

    impl((ref Derived)(nil))

  block in_definition:
    type
      Base = ref object of RootObj
      Derived = ref object of Base

    proc impl(arg: Base) = discard

    impl((ref Derived)(nil))