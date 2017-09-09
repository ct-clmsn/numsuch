module PeelPropagation {
  use Core,
      LinearAlgebra;

  config const epochs: int,      // Dr. Peel calls this "itr"
               alpha: real,      // damping factor
               steps: int,       // how many steps out to propagate
               epsilon: real;    // convergence criteria

  class PeelPropagationModel {
    var ldom: domain(2),
        dataDom: domain(2),
        Y: [ldom] real,         // Labels
        X: [dataDom] real,      // data
        D: [dataDom] real,      // Diagonal matrix
        Lnorm: [dataDom] real,  // normalized matrix
        compiled: bool =false;

    proc fit(X: [] real, L: LabelMatrix ) {
      //writeln(" X.domain", X.domain);
      //writeln(" L.data.domain", L.data.domain);
      dataDom = X.domain;
      this.X = X;
      this.ldom = L.data.domain;
      if !compiled {
        compile(X, L);
      }
      // Now proceed to do explicitly one calculation
      iterate();
    }
    proc compile(X: [] real, L:LabelMatrix) {
      prepareY(L);
      // @TODO make this simpler.
      var rowSums: [X.domain.dim(2)] real;
      var sqs: [X.domain.dim(2)] real;
      [i in X.domain.dim(2)] rowSums[i] = + reduce X[i,..];
      [i in X.domain.dim(2)] sqs[i] = (rowSums[i]+1e-05)** -.5;
      D = diag(sqs);
      Lnorm = dot(D, dot(X,D));
      //writeln(rowSums);
      //writeln(sqs);
      //writeln(ds);
      //writeln(Lnorm);
      compiled = true;
    }

    proc prepareY(L: LabelMatrix) {
      //writeln(" this.ldom ", this.ldom);
      //writeln(" Y domain ", Y.domain);
      //writeln(" L.ldom ", L.ldom);
      Y = L.data;
    }

    proc iterate() {
      var F: [Y.domain] real = Y,      // The current prediction, called F by Dr. Peel
          Fold: [Y.domain] real = -1.0;
      var err: real = 1.0;
      var e = 0;
      do {
        writeln("\tepoch %n".format(e));
        for s in 1..steps {
          F = dot(Lnorm.T, F);
        }
        F = (1-alpha) * Y + alpha * F;
        err = + reduce abs(matMinus(F, Fold));
        e += 1;
        Fold = F;
        writeln("  epoch %n  error %n".format(e, err));
      } while (e < epochs && err > epsilon);
      var predictions: [ldom] int;
      [i in ldom] predictions[i] = argmax(F[i,..]);
      writeln("predictions\n", predictions);

    }
  }
}
