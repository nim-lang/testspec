##[
Specification of the core overloading resolution algorithm with examples
]##




## In a call `p(args)` the routine `p` that matches best is selected.
## If multiple routines match equally well, the ambiguity is reported
## during semantic analysis.

block integer_literal:
  proc impl(arg: uint32): string = "uint32"
  proc impl(arg: uint8): string = "uint8"

  doAssert impl(10u8) == "uint8", "Exact match always takes precedence"
  doAssert impl(10u16) == "uint32", "When no explicit overload present, widen integer"

block subrange_match:
  ## Subrange - `arg` is a `range[T]` and `T` matches range of the
  ## argment exactly or is a subrange of argument.
  proc impl(arg: range[0 .. 10]): string = "0 .. 10"
  proc impl(arg: range[11 .. 20]): string = "11 .. 20"

  ## Allowed range of the integer values is take into account when overloading
  ## is performed.
  doAssert impl(range[0 .. 10](10)) == "0 .. 10"
  doAssert impl(range[11 .. 20](11)) == "11 .. 20"

  ## expression type can be a subrange of the expected procedure argument type
  doAssert impl(range[0 .. 2](1)) == "0 .. 10"

block subtype_match:
  ## Subtype match - argument is a subtype of the procedure argument. Note that this
  ## requirement is related to inheritance (because of subtyping), but does not
  ## replace `method`'s functionality. It also works with `{.inheritable.}` types and
  ## `object of RootObj` (in addition to `ref object of RootObj`) whereas `method`
  ## requires `ref` to be used.
  block inheritable_pragma:
    ## `{.inheritable.}` provides subtyping capabilities
    type
      Base {.inheritable.} = object
        field: int

      Derived = object of Base
        field2: int

    proc impl(arg: Base) = discard

    impl(Derived())
    impl(Base())

  block subtype_ref_ptr_var:
    ## `ref` and `ptr` and `var` do not affect subtype relation - as a result they
    ## can also be used to call a procedure that expects a supertype.
    type
      Base = object of RootObj
        fbase: int

      Derived = object of Base
        fderived: int

    proc impl(arg: ptr Base): string = "ptr"
    proc impl(arg: ref Base): string = "ref"
    proc impl(arg: var Base): string = arg = Base(fbase: 256); "var"

    doAssert impl((ptr Derived)(nil)) == "ptr"
    doAssert impl((ref Derived)(nil)) == "ref"

    var derived = Derived(fderived: 128)
    doAssert impl(derived) == "var"


  block closest_subtype:
    type
      A = ref object of RootObj
      B = ref object of A
      C = ref object of B

    proc impl(b: B): string = "matched subtype B"
    proc impl(a: A): string = "matched subtype A"

    ## Closest subtype takes precedence
    doAssert impl(C()) == "matched subtype B"
    doAssert impl(B()) == "matched subtype B"




block most_specific_generic_wins:
  ## If multiple overloaded procedures are present, most specific is
  ## always selected.

  block qualifier:
    ## `ref`, `ptr` and other type qualifiers are counted as a part of
    ## the generic procedure definition.

    proc gen[T](x: var ref ref T): string = "var ref ref T"
    proc gen[T](x: ref ref T): string = "ref ref T"
    proc gen[T](x: ref T): string = "ref T"
    proc gen[T](x: T): string = "T"

    var v: ref ref int = nil
    doAssert gen(v) == "var ref ref T"
    doAssert gen((ref ref int)(nil)) == "ref ref T"
    doAssert gen((ref int)(nil)) == "ref T"
    doAssert gen(nil) == "T"


  # QUESTION - it is not possible to select less generic overload?
  # doAssert gen[ref ref ref ref int](nil) == "ref T"

  block regular:
    ## The rule also applied to regular generic types
    proc gen[T](x: var seq[seq[T]]): string = "var seq seq T"
    proc gen[T](x: seq[seq[T]]): string = "seq seq T"
    proc gen[T](x: seq[T]): string = "seq T"
    proc gen[T](x: T): string = "T"

    var v: seq[seq[int]]
    doAssert gen(v) == "var seq seq T"
    doAssert gen(newSeq[seq[int]]()) == "seq seq T"
    doAssert gen(newSeq[int]()) == "seq T"
    doAssert gen(nil) == "T"


block conversion_match:
  ## Conversion match: a is convertible to f, possibly via a user defined converter.

## Next example requires presence of the implicit user-defined converter,
## and those must be declared on the toplevel in the file.
converter toString(i8: uint8): string = $i8

block consider_all_arguments:
  ## Overload resolution considers all existing arguments and selects best
  ## matching overload from the list of the candidates. Selection is not done
  ## using "weighted" approach - instead it simply counts number of matches
  ## for each category in passes.

  proc impl(exact: uint8, conv: string): string = "exact+conv"
  proc impl(widen1: uint32, widen2: uint32): string = "widen+widen"

  ## `impl` is called with `0u8` for both arguments, which means it would
  ## have one exact match and one conversion match. All other overload
  ## alternatives have no matches in the "exact" category, so `exact+conv`
  ## is selected.
  doAssert impl(0u8, 0u8) == "exact+conv"

  ## If two procedures have the same counts for each category of arguments matches
  ## it leads to the "ambiguous overload" error -
  ##  :idx:`t03_overload_core_ambiguous_fail.nim`

block generic_vs_subtype:
  ## Generic overloading match comes before subtype relation match, so maybe code
  ## like this would seem unexpected.
  #
  # Example taken from the https://github.com/nim-lang/Nim/issues/18314
  #
  type
    A = ref object of RootObj
    B = ref object of A
    C = ref object of B

  block regular_procs:
    proc impl[T: A](a: T): string = "matched generic"
    proc impl(b: B): string = "matched subtype B"

    ## subtype vs generic - wins generic
    doAssert impl(C()) == "matched generic"

    ## generic vs exact match - wins exact match
    doAssert impl(B()) == "matched subtype B"

block subtype_constaints_for_generic:
  ## When subtype is used as a constraint for the generic parameter it
  ## functions the same way as if it was written directly in the argument.

  type
    A  = ref object of RootObj
    B1 = ref object of A
    B2 = ref object of A

  proc impl[T](a: T): string = "T"
  proc impl[T: A](a: T): string = "A"
  proc impl[T: B1](a: T): string = "B1"
  proc impl[T: B2](a: T): string = "B2"
  proc impl[T: B1 | B2](a: T): string = "B1|B2"

  doAssert impl(B1()) == "B1"
  doAssert impl(B2()) == "B2"

  ## Note that `B1 | B2` is not reported as an ambiguous overload since constaints
  ## with alternatives have a lower precedence compared to the simple `SomeType`.


## Conveter must be defined on the toplevel - it is only used in the `varargs_overloading`
## example

type C = object

converter toC(i: int): C = C()

block varargs_overloading:
  ## When procedure with `varargs` is called each argument is treated as if
  ## procedure with needed number of parameters existed -  alternatives are
  ## still compared on argument-by-argument basis.

  block:
    ## No ambiguity here - converter exists but exact match has a higher
    ## precedence compared to the converter match.
    proc impl(args: C): string = "C"
    proc impl(args: int): string = "int"

    doAssert impl(1) == "int"

