module Core {
  use Random;
  enum labelReplacementType {none, inverseDegree};

  /*
   Class to hold labels for data.  Has names in names
   */
  class LabelMatrix {
    var ldom: domain(1) = {1..0},
        dataDom: domain(2),                         // # records X # distinct labels
        nLabelValues: int = 0,                      // How many different labels are there?
        data: [dataDom] real,
        names: [ldom] string,
        trainingLabelDom: sparse subdomain(ldom);   // Which labels are training labels, for error analysis

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
         // Getting integers for labels, then expanding to columns as new values arise
         ldom = {1..0};
         dataDom = {1..ldom.last, 1..1};
         var nLabels = 1;
         for line in lFile.lines() {
           ldom = {1..ldom.last+1};
           var fields = line.split("\t");
           names[ldom.last] = fields[1]:string;
           if fields[2]:int > nLabels {
             nLabels += 1;
             //writeln("..new label %n".format(fields[2]));
           }
           dataDom = {ldom.dim(1), 1..nLabels};
           data[ldom.last, fields[2]:int] = 1;
         }
         nLabelValues = nLabels;
       }
    }

    proc fromMatrix(y:[]) {
      writeln(y.domain.first);
      dataDom = {1..#y.shape[1], 1..#y.shape[2]};
      ref tmpD = data.reindex(y.domain);
      for ij in y.domain {
        tmpD[ij] = y[ij];
      }
      nLabelValues = y.shape[2];
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

  /*
   */
  proc subSampleLabels(L: LabelMatrix, sampleSize: int
      , replacementMethod: labelReplacementType = labelReplacementType.none) {
    var M = new LabelMatrix();
    M.ldom = L.ldom;
    M.dataDom = L.dataDom;
    [ij in L.dataDom] M.data[ij] = L.data[ij];
    var ids = [i in M.ldom] i;
    shuffle(ids);
    for i in sampleSize+1..ids.size{
      if replacementMethod ==  labelReplacementType.none {
        M.data[ids[i],..] = 0;
      } else if replacementMethod == labelReplacementType.inverseDegree {
        M.data[ids[i],..] = 1.0 / L.nLabelValues;
      }
      M.trainingLabelDom += ids[i];
    }
    return M;
  }

  proc argmax1d(x:[]) {
    var idx: int = 1,
        currentMax: real = x[1];
    for i in x.domain {
      if x[i] > currentMax {
        currentMax = x[i];
        idx = i;
      }
    }
    return idx;
  }


  /*
   axis = 0: argmax over whole object array (default)
          1: argmax for every row
          2: argmax for every column

   returns: tuple.  In the case of axis=0 this is the (i,j) coordinate of the max.
   */

  proc argmax(x: [], axis:int = 0 ) {
    //writeln(x.domain);
    //writeln(x.shape.size);
    var idom: domain(1) = {1..1};
    var idx: [idom] int;
    if x.shape.size == 1 {
      return argmax1d(x);
    } else if x.shape.size == 2 && axis==1 {
      idom = {1..#x.shape[1]};
      for i in x.domain.dim(1) {
        var y: [x.domain.dim(1)] real = x[i,..];
        idx[i] = argmax1d(y);
      }
      //writeln(idx);
      return idx;
    } else if  x.shape.size == 2 && axis==2 {
      idom = {1..#x.shape[2]};
      for j in x.domain.dim(2) {
        var y: [x.domain.dim(2)] real = x[..,j];
        idx[j] = argmax1d(y);
      }
      //writeln(idx);
      return idx;
    } else if x.shape.size == 2 && axis==0 {
      idom = {1..2};
      idx = (0,0);
      var currentMax: real = x[1,1];
      for (i,j) in x.domain {
        if x[i,j] > currentMax {
          idx = (i,j);
          currentMax = x[i,j];
        }
      }
      return idx;
    } else {
      halt("cannot resolve input dimension!");
    }
  }

  proc xlog2x(x: real) {
    if x > 0 {
      return x * log2(x);
    } else {
      return 0;
    }
  }
}
