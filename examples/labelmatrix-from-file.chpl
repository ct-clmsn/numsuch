use NumSuch,
    Time;

var labelFile = "data/webkb_labels.txt";
var vectorFile = "data/webkb_vectors.mtx";

var L = new LabelMatrix();
writeln("Reading labels into a LabelMatrix from %s".format(labelFile));
var t: Timer;
t.start();
L.readFromFile(fn=labelFile, addDummy=true);
t.stop();
writeln("  ..read %n %n-dimensional records in %n s".format(L.data.shape[1], L.data.shape[2], t.elapsed()));
