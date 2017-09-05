/*
 Designed to test the Modified Adsoprtion routine
 */
use NumSuch,
    MatrixMarket;


var X = Matrix(
  [3.0, 0.2, 0.0, 0.7, 0.1],
  [0.2, 2.0, 0.3, 0.0, 0.0],
  [0.0, 0.3, 3.0, 0.9, 0.6],
  [0.7, 0.0, 0.9, 2.0, 0.0],
  [0.1, 0.0, 0.6, 0.0, 2.0]
);

var y = Matrix(
  [1,0,0],
  [0,1,0],
  [0,0,1],
  [1,0,1],
  [0,0,0]
  );

var labelFile = "data/webkb_labels.txt";
var vectorFile = "data/webkb_vectors.mtx";
//var L = new LabelMatrix();
//L.readFromFile(fn=labelFile, addDummy=true);
//writeln(L.names);

var W = mmread(real, vectorFile);
// this takes 5 hours on my laptop, holy cow.
var V = cosineDistance(W);


/*
var model = new ModifiedAdsorptionModel();
model.fit(data=X, labels=y);
writeln(model.A);
 */
