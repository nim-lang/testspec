discard """
errormsg: "wrong number of variables"
"""

##[
Unpacking tuples into the wrong number of variables will error with
`Error: wrong number of variables`.

This can be fixed by using the placeholder `_` to increase the number of
elements in target assignment.
]##


block validTupleUnpackingAssignment:
  ## No error here - assigning three elements to three targets
  let (a, b, _) = (12, 3, 4)

block invalidTupleUnpackingAssignment:
  ## Error here - assigning three elements to two targets
  let (a, b) = (12, 3, 4)