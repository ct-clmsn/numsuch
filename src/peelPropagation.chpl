module PeelPropagation {
  use Core,
      LinearAlgebra;

  config const epochs: int,      // Dr. Peel calls this "itr"
               alpha: real,      // damping factor
               steps: int,       // how many steps out to propagate
               epsilon: real;    // convergence criteria

  class PeelPropagationModel {
    var ldom: domain(1),          // As long as the number of labels
        dataDom: domain(2),
        D: [dataDom] real,        // Diagonal matrix
        Lnorm: [dataDom] real,    // normalized matrix
        Predictions: LabelMatrix = new LabelMatrix(), // The output of "fit()"
        compiled: bool =false;

    proc fit(X: [] real, L: LabelMatrix ) {
      dataDom = X.domain;
      if !compiled {
        compile(X, L);
      }
      // Now proceed to do explicitly one calculation
      return iterate(L);
    }
    proc compile(X:[] real, L: LabelMatrix) {
      // @TODO make this simpler.
      var rowSums: [X.domain.dim(2)] real;
      var sqs: [X.domain.dim(2)] real;
      [i in X.domain.dim(2)] rowSums[i] = + reduce X[i,..];
      [i in X.domain.dim(2)] sqs[i] = (rowSums[i]+1e-05)** -.5;
      D = diag(sqs);
      Lnorm = dot(D, dot(X,D));
      compiled = true;
    }


    /*
     Runs the iterations and returns the predictions
     */
    proc iterate(L: LabelMatrix) {
      var F: [L.data.domain] real = L.data,      // The current prediction, called F by Dr. Peel
          Fold: [L.data.domain] real = -1.0;
      var err: real = 1.0;
      var e = 0;
      do {
        for s in 1..steps {
          F = dot(Lnorm.T, F);
        }
        F = (1-alpha) * L.data + alpha * F;
        err = + reduce abs(matMinus(F, Fold));
        e += 1;
        Fold = F;
        //writeln("  epoch %n  error %n".format(e, err));
      } while (e < epochs && err > epsilon);
      Predictions.dataDom = L.dataDom;
      Predictions.trainingLabelDom = L.trainingLabelDom;
      [i in L.ldom] Predictions.data[i,argmax(F[i,..])] = 1;
      return Predictions;
    }
  }

  /*
   Calculates error on unlabled data
   */
  proc calculateError(Ygold: LabelMatrix, Ypred: LabelMatrix) {
    var mm: [Ypred.dataDom] real = abs(matMinus(Ygold.data, Ypred.data));
    var e = 0.0;
    for s in Ypred.trainingLabelDom {
      e += + reduce mm[s,..];
    }
    e = 1 - e / Ypred.trainingLabelDom.size;
    return e;
  }
}
