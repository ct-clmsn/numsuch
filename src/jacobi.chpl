/*
 Based largely on the [Jacobi Page](https://en.wikipedia.org/wiki/Jacobi_eigenvalue_algorithm) on Wikipedia.
 */
module Jacobi {
  use Core;

  proc jacobi(X:[]) {
    writeln(" X domain ", X.domain);
    return 0;
  }

  /*
    Finds the max along the super-diagonal
    returns:
   */
  proc findPivots(X:[]) {
    const T: [X.domain] real = abs(triu(X, k=1));
    writeln("T\n", T);
    var pivots: [{T.domain.dim(1), 1..2}] real;
    for i in {1..T.domain.dim(1).last-1} {
      var idx = maxloc reduce zip(T[i,..], T[i,..].domain);
      pivots[i,..] = idx;
    }
    sort2D(pivots, axis=1, reversed=true);
    return pivots;
  }
}
