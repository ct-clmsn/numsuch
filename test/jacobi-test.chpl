use NumSuch,
    Time;

writeln("testing Jacobi");
var J: [{1..4,1..4}] real = (
  (4, -30, 60, -35),
  (-30, 300, -675, 420),
  (60, -675, 1620, -1050),
  (-35, 420, -1050, 700)
  );

var t: Timer;
t.start();
var r = jacobi(J);
writeln(findPivots(J));

t.stop();
writeln("  elapsed time %n".format(t.elapsed()));
