use NumSuch,
    LinearAlgebra,
    MatrixMarket,
    Time;

var labelFile = "data/karate.mtx";
var edgeFile = "data/kata-fac_edges.txt";

var X = mmread(real, labelFile);
// Data in file is only sub-diagonal, so add back super
X = matPlus(X,transpose(X));
writeln(X);

var model = new PeelPropagationModel();
