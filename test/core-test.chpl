use NumSuch,
    Time,
    MatrixMarket;

//var labelFile = "data/webkb_labels.txt";
//var vectorFile = "data/webkb_vectors.mtx";

//var L = new LabelMatrix();
//L.readFromFile(fn=labelFile, addDummy=true);

// Cosine Distance test
//var W = mmread(real, vectorFile);
// this takes 5 hours on my laptop, holy cow.

writeln("Running cosineDistance");

var X = Matrix(
  [3.0, 0.2, 0.0, 0.7, 0.1],
  [0.2, 2.0, 0.3, 0.0, 0.0],
  [0.0, 0.3, 3.0, 0.9, 0.6],
  [0.7, 0.0, 0.9, 2.0, 0.0],
  [0.1, 0.0, 0.6, 0.0, 2.0]
);

var Y = Matrix(
  [3.0, 0.2, 0.0, 0.7, 0.1],
  [0.2, 2.0, 0.3, 0.0, 0.0],
  [0.0, 0.3, 3.0, 0.9, 0.6],
  [0.7, 0.0, 0.9, 2.0, 0.0],
  [0.7, 0.0, 0.9, 2.0, 0.0],
  [0.1, 0.0, 0.6, 0.0, 2.0]
);

var t: Timer;
writeln("cosineDistance(X,X)");
t.start();
var V = cosineDistance(X);
t.stop();
writeln("  elapsed time %n".format(t.elapsed()));


writeln("cosineDistance(X,Y)");
t.start();
var V2 = cosineDistance(X,Y);
writeln(V2);
t.stop();
writeln("  elapsed time %n".format(t.elapsed()));

// Test LabelMatrix.fromMatrix()
var L = new LabelMatrix();
writeln("Loading L from matrix.");
L.fromMatrix(Y);
writeln(L.data);


var x: [1..3] real = [1.1, 3.3, 2.2];
var y: [1..3,1..3] real = ((1,0,0), (0,0,2), (0,3,0));
writeln(y);
writeln("argmax x: ", argmax(x));
writeln("argmax axis=?: ", argmax(y));
writeln("argmax axis=0: ", argmax(y, axis=0));
writeln("argmax axis=1: ", argmax(y, axis=1));
writeln("argmax axis=2: ", argmax(y, axis=2));
