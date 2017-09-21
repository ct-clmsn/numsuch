use NumSuch;

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

writeln("** SUBGRAPH ENTROPY");
var G = buildFromSparseMatrix(A, weighted=false, directed=false);
var sud: sparse subdomain(G.vertices);
sud += 1;
sud += 2;
sud += 3;
sud += 4;
var entropy = subgraphEntropy(G, sud);
writeln("   Subgraph Energy: ", entropy);

var min_ent = minimalSubGraph(G, sud);
