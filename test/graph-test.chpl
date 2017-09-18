use NumSuch,
    LayoutCS;

//var g = new Graph();


// Graph Entropy Graph
/*
var Pairs: domain((int, int));
Pairs += (1,2);
Pairs += (1,4);
Pairs += (1,5);
writeln(Pairs);

record Triple {
  var from: int(32);
  var to: int(32);
  proc weight return 1:int(32);
}


var triples: [domain(1)] Triple;
triples += new Triple(1,2);
triples += new Triple(1,3);
triples += new Triple(1,4);
triples += new Triple(2,3);

var max_nid: int;
max_nid = max reduce [r in triples] max(r.from, r.to);

var G = buildUndirectedGraph(triples, false, {1..max_nid} );
 */

 /*
const vertices: domain(1) = {1..5};
var G = new Graph(nodeIdType = int,
                  edgeWeightType = real,
                  vertices = vertices,
                  initialLastAvail=0);
  */

// See slide 5 of http://web.ecs.baylor.edu/faculty/cho/Cho-Entropy.pdf for visual
var nv: int = 8,
    D: domain(2) = {1..nv, 1..nv},
    SD: sparse subdomain(D) dmapped CS(),
    A: [SD] real;

SD += (1,2); A[1,2] = 1;
SD += (1,3); A[1,3] = 1;
SD += (1,4); A[1,4] = 1;
SD += (2,4); A[2,4] = 1;
SD += (3,4); A[3,4] = 1;
SD += (4,5); A[4,5] = 1;
SD += (5,6); A[5,6] = 1;
SD += (6,7); A[6,7] = 1;
SD += (6,8); A[6,8] = 1;
SD += (7,8); A[7,8] = 1;

writeln("DIRECTED");
var G = buildFromSparseMatrix(A, weighted=false, directed=true);
for v in G.vertices {
  writeln(" vertex ", v, "  #neighbors ", G.Row[v].neighborList);
}

writeln("UNDIRECTED");
var H = buildFromSparseMatrix(A, weighted=false, directed=false);
for v in H.vertices {
  writeln(" vertex ", v, "  #neighbors ", H.Row[v].neighborList);
}
