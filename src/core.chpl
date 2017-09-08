module Core {

  /*
   Class to hold labels for data.  Has names in names
   */
  class LabelMatrix {
    var ldom: domain(1) = {1..0},
        dataDom: domain(2),
        data: [dataDom] real,
        names: [ldom] string;
    /*
    Loads a label file into a Matrix.  Labels should be binary indicators
    useCols: use columns for the labels, as in an indicator for each column.
             default is to have an integer representing the label
             <TAB> separated
    <record id: string> <category 1 indicator> ... <category L indicator>
     */
    proc readFromFile(fn: string, addDummy: bool = false, useCols=false) {
      var lFile = open(fn, iomode.r).reader(),
          x: [1..0] real,
          nFields: int,
          line: string,
          //ldom: domain(1),
          xline: [ldom] real,
          nRows: int = 1,
          firstLine: bool = true;
      if useCols {
        for line in lFile.lines() {
           var fields = line.split("\t");
           if firstLine {
             nFields = fields.size;
             if addDummy {
               // Add a dummy column
               ldom = {1..nFields};
             } else {
               ldom = {1..nFields-1};
             }
             dataDom = {1..0, 1..nFields};
             firstLine = false;
           } else {
             if fields.size != nFields {
               halt("Unequal number of fields in label file");
             }
           }
           ldom = {1..ldom.last+1};
           names[ldom.last] = fields[1];
           dataDom = { 1..#nRows, ldom.dim(1)};
           var xline: [ldom] real;
           for v in 2..fields.size {
             xline = fields[v]:real;
           }
           data[dataDom.last(1), ..] = xline;
           nRows += 1;
         }
       } else {
         // Getting integers for labels
         ldom = {1..2};
         var nLabels = 1;
         for line in lFile.lines() {
           ldom = {1..ldom.last+1};
           dataDom = {1..ldom.last, 1..1};
           var fields = line.split("\t");
           names[ldom.last] = fields[1]:string;
           if fields[2]:int > nLabels {
             nLabels += 1;
           }
           data[dataDom.last(1), 1] = fields[2]:int;
           //writeln(fields[1]);
           nRows += 1;
         }
       }
    }

    proc fromMatrix(y:[]) {
      writeln(y.domain.first);
      dataDom = {1..#y.shape[1], 1..#y.shape[2]};
      ref tmpD = data.reindex(y.domain);
      for ij in y.domain {
        tmpD[ij] = y[ij];
      }
    }
  }

  /*
   Does the pairwise cosine distance between rows of X.
   Dimensions must be conformable
   */
  proc cosineDistance(X:[?Xdom], denseOutput=true) {
    // TODO
    if !denseOutput then halt('denseOutput=false not yet supported');

    var cosDistDom: domain(2) = {Xdom.dim(1), Xdom.dim(1)},
        cosDist: [cosDistDom] real;

    // TODO: verbose output
    //writeln(" Got V: ", V.shape);
    //writeln(" cosDistDom.dims(1) ", cosDistDom.dims());

    // Pre-compute repeated cosim's
    var Xii: [Xdom.dim(1)] real;
    [i in Xdom.dim(1)] Xii[i] = dot(X[i,..], X[i,..]);

    //forall i in Xdom.dim(1) {
    forall i in Xdom.dim(1).first..Xdom.dim(1).last {
      const x1 = Xii[i];
      //for j in i+1..Xdom.dim(1).size {
      for j in i+1..Xdom.dim(1).last {
        // Do cosim
        const x2 = Xii[j];
        const c = 1 - dot(X[i,..], X[j,..]) / (x1 * x2);
        cosDist[i,j] = c;
        cosDist[j,i] = c;
      }
    }
    return cosDist;
  }

  /*
   Does the pairwise cosine distance between rows of X and rows of Y.
   Dimensions must be conformable
   */
  proc cosineDistance(X:[?Xdom], Y:[?Ydom], denseOutput=true) {
    // TODO
    if !denseOutput then halt('denseOutput=false not yet supported');

    if X.shape[2] != Y.shape[2] {
      halt(" dimension mismatch: X = (%n,%n)  Y = (%n,%n)".format(X.shape[1], X.shape[2], Y.shape[1], Y.shape[2]));
    }

    var cosDistDom: domain(2) = {Xdom.dim(1), Ydom.dim(1)},
        cosDist: [cosDistDom] real;

    // TODO: verbose output
    //writeln(" Got V: ", V.shape);
    //writeln(" cosDistDom.dims(1) ", cosDistDom.dims());

    // Pre-compute norms
    var Xii: [Xdom.dim(1)] real;
    var Yii: [Ydom.dim(1)] real;
    [i in Xdom.dim(1)] Xii[i] = dot(X[i,..], X[i,..]);
    [i in Ydom.dim(1)] Yii[i] = dot(Y[i,..], Y[i,..]);

    //forall i in Xdom.dim(1) {
    forall i in Xdom.dim(1).first..Xdom.dim(1).last {
      const x2 = Xii[i];
      //for j in i+1..Xdom.dim(1).size {
      // Cannot take advantage of symmetry, must walk the whole thing :(
      for j in Ydom.dim(1).first..Ydom.dim(1).last {
        // Do cosim
        const y2 = Yii[j];
        const c = 1 - dot(X[i,..], Y[j,..]) / (y2 * x2);
        cosDist[i,j] = c;
      }
    }
    return cosDist;
  }
}
