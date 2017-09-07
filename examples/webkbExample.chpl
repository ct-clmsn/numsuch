/*
 Using Modified Adsoprtion on WebKB data
 */

use NumSuch,
    Time,
    MatrixMarket;

var labelFile = "data/webkb_labels.txt";
var vectorFile = "data/webkb_vectors.mtx";
var L = new LabelMatrix();
L.readFromFile(fn=labelFile, addDummy=true);
//writeln(L.names);

var W = mmread(real, vectorFile);
// Make sure to do this with --fast
var t: Timer;
writeln("Calculating Cosine Similarity");
t.start();
var V = cosineSimilarity(W);
t.stop();
writeln("Elapsed time ", t.elapsed());
