module PeelPropagation {
  use Core,
      LinearAlgebra;

  var epochs: int,      // Dr. Peel calls these "steps"
      alpha: real;      // damping factor

  class PeelPropagationModel {
    var ldom: domain(1),
        dataDom: domain(2),
        Y: [ldom] real,         // Labels
        X: [dataDom] real,      // data
        D: [dataDom] real,      // Diagonal matrix
        Lnorm: [dataDom] real,  // normalized matrix
        compiled: bool =false;

    proc fit(X: [] real, L: LabelMatrix ) {
      writeln(" X.domain", X.domain);
      writeln(" L.data.domain", L.data.domain);
      dataDom = X.domain;
      this.X = X;
      this.ldom = L.ldom;
      if !compiled {
        compile();
      }

      // Now proceed to do explicitly one calculation
    }
    proc compile() {
      prepareY();
      var rowSums: [X.domain.dim(2)] real;
      [i in X.domain.dim(2)] rowSums[i] = + reduce X[i,..];
      //writeln(diag(X));
      writeln(rowSums);
      //D = diags(X);
      compiled = true;
    }

    proc prepareY() {
    }

    proc iterate() {

    }
  }
}
