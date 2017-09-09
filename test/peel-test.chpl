use NumSuch,
    LinearAlgebra,
    MatrixMarket,
    Path,
    Time;

var edgeFile = "data/karate.mtx";
var labelFile= "data/karate-fac_labels.txt";

var t: Timer;
var X = mmread(real, edgeFile);
// Data in file is only sub-diagonal, so add back super
X = matPlus(X,transpose(X));
//writeln(X);
var Y = new LabelMatrix();
Y.readFromFile(labelFile);
//writeln("Y.data\n", Y.data);

writeln("Predicting labels");
t.start();
var model = new PeelPropagationModel();
var subY: LabelMatrix;
/*
 Because of the small data size, the accuracy can go up and down dramatically.
 */
for n in 1..10 {
  subY = subSampleLabels(Y, sampleSize=5, replacementMethod=labelReplacementType.inverseDegree);
  var preds = model.fit(X,subY);
  writeln("\t trial (%n) accuracy: %n".format(n, calculateError(Y, preds)));
}
t.stop();
writeln("elapsed time ", t.elapsed());
