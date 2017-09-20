/*
Behold, the Graph Entropy Module.  A nice introduction to this idea is
available from `Dr. Cho at Baylor University <http://web.ecs.baylor.edu/faculty/cho/Cho-Entropy.pdf>`_
*/
module GraphEntropy {
  use Graph,
      Core;


  /*
    Find the entropy of a given subgraph
   */
  proc subgraphEntropy(G: Graph, verts: domain) {
    var subgraph: [verts] G.Row.eltType,
       adjdom = verts,                         // Will hold the ids of all nodes adjacent to verts
       pints: [adjdom] real = 0,                // Internal edge weights per vertex
       pttls: [adjdom] real = 0,                // Total edge weight per vertex
       entropy: real = 0;

    /*
    Going to need to clean this up to one loop or so
    */
    for s in verts {
     var me = G.Row[s];
     var e = vertexLocalEntropy(me, verts);
     for nv in G.Row[s].neighborList {
       if !verts.member(nv[1]) && !adjdom.member(nv[1]) {
         // Don't calculate it again
         adjdom += nv[1];
         //writeln(" current adjdom: ", adjdom);
         var r = G.Row[nv[1]];
         // Break this out to its own variable for now to see if calcs are right
         var f = vertexLocalEntropy(r, verts);
         //writeln(" Vertex: ", nv[1], " Energy: ", e);
         e += f;
       }
     }
     //writeln(" Vertex: ", s, " Energy: ", e);
     entropy -= e;
    }
    return entropy;
  }

  /*
  Finds the entropy around a specific vertex by calculating the total weight of
  the interior and exterior edges, then applying a log multinomial

.. math::
  x^2

   */
  proc vertexLocalEntropy(v: VertexData, interior: domain) {
    var interiorWeight:real = 0,
       totalWeight:real = 0;

    for n in v.neighborList {
      if interior.member(n[1]) {
       //writeln(" LOCALS ONLY, BRO! ", n, " -> ", n[1]);
       interiorWeight += n[2];
      }
      totalWeight += n[2];
    }
    return xlog2x(interiorWeight/totalWeight) + xlog2x(1-interiorWeight/totalWeight);
  }

  /*
    Try to find the smallest graph to express this set of nodes, eliminating ones that
    don't add entropy

    :param G: The parent Graph object
    :param interior: The vertex ids for the subgraph in question
   */
  proc minimalSubGraph(G: Graph, interior: domain) {
    return 0;
  }
}
