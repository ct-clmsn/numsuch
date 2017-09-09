use NumSuch,
    LinearAlgebra,
    MatrixMarket,
    Path,
    Time;

var edgeFile = "data/karate.mtx";
var labelFile= "data/karate-fac_labels.txt";

var X = mmread(real, edgeFile);
// Data in file is only sub-diagonal, so add back super
X = matPlus(X,transpose(X));
//writeln(X);
var Y = new LabelMatrix();
Y.readFromFile(labelFile);
//writeln("Y.data\n", Y.data);

var subY = subSampleLabels(Y, sampleSize=5, replacementMethod=labelReplacementType.inverseDegree);
//writeln("subY.data\n\t", subY.data);

var model = new PeelPropagationModel();
var preds = model.fit(X,subY);
writeln(preds);
