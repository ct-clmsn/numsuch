module PeelPropagation {
  var epochs: int,      // Dr. Peel calls these "steps"
      alpha: real;      // damping factor

  class PeelPropagationModel {
    var ldom: domain(1),
        dataDom: domain(2),
        Y: [ldom] real,      // Labels
        X: [dataDom] real;      // data

    proc fit(X: [] real, Y:[] real ) {
      writeln(" X.shape ", X.shape);
      writeln(" Y.shape ", Y.shape);

    }
  }
}
