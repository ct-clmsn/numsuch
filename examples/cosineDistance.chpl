use NumSuch,
    MatrixMarket,
    Time;

// The file we want to use
var vectorFile = "data/webkb_vectors.mtx";
var W = mmread(real, vectorFile);
var t: Timer;
t.start();
writeln("Running cosine distance on W with itself.  W = (%n,%n)".format(W.shape[1], W.shape[2]));
var V = cosineDistance(W);
t.stop();
writeln("  ..done in %n s".format(t.elapsed()));
