/*
  Package of Graph-Based Semi-Supervised Learning techniques based partially
  on the work by `Subramanya and Talukdar <http://graph-ssl.wdfiles.com/local--files/blog%3A_start/graph_ssl_acl12_tutorial_slides_final.pdf>`_

  This is collected into the book on `Amazon <https://www.amazon.com/Graph-Based-Semi-Supervised-Synthesis-Artificial-Intelligence/dp/1627052011>`_

  Also, see notes in the /tex folder under main.

 */
module GBSSL {
  use LinearAlgebra;

  class ModifiedAdsorptionModel {
    var vcount: range,
        vdom: domain(1),
        gdom: domain(2),
        edom: sparse subdomain(gdom),// The non-zeroes of the graph
        ldom: domain(2),             // The domain of the labels
        v: [vdom] real,
        e: [edom] real,
        directed: bool,
        A: [gdom] real,              // the data matrix
        Y: [ldom] real,              // The labels, expanded by one column
        pcont: [vdom] real,          // a vector of pContinue
        pabdn: [vdom] real,
        pinj : [vdom] real,
        compiled: bool = false,
        beta: real = 1.1;

    /*
      data: A square matrix with as many rows as vertices in the graph.
      y: labels, must be as long as the number of vertices. Each different category
         gets a column in the Label matrix and records can have more
         than one or zero labels.  E.g.
            [isBlue, isRed, isPurple]
            [1     ,     0,        0]
            [0     ,     1,        0]
            [0     ,     0,        1]
            [0     ,     1,        1]
            [0     ,     0,        0]
     */
    proc fit(data: [], labels: []) {
      if !compiled {
        compile(data, labels);
      }
    }

    /*
      We need three probabilities as each vertex for the MAD algo.
     */
    proc compile(data: [], labels: []) {
      writeln("  ..compiling model");
      calculateProbs();
      prepareA(data);
      prepareY(labels);
      compiled = true;
    }

    /*
     Create the adjacency matrix A internally
     */
    proc prepareA(data: []) {
      if data.shape[1] != data.shape[2] {
        halt("** ERROR:  Data must be square. Data is %n by %n".format(data.shape[1], data.shape[2]));
      } else {
        vcount = 1..data.shape[1];
        vdom = {vcount};
        gdom = {vcount, vcount};
        var xd = data.domain;
        ref Xd = A.reindex(xd);
        for ij in data.domain {
          if data[ij] > 0 {
            edom += ij+(1,1);
            Xd[ij] = data[ij];
          }
        }
      }
    }

    /*
      Organize the labels and add a column for the "unknown" label
     */
    proc prepareY(labels: []) {
      if labels.shape[1 ]!= vdom.size {
        halt("\n\tYou need one label per vertex.\n\t\t#labels: %n\t#vertices: %n".format(labels.shape[1], vdom.shape[1]));
      }
      ldom = {1..labels.shape[1], 1..labels.shape[2]};
      Y = labels;
      ldom = {1..labels.shape[1], 1..labels.shape[2]+1};
    }
    /*
      Find the 3 probs for each vertex
     */
    proc calculateProbs() {
      for v in vdom {
        var ps = cellProbabilities(v);
        pcont[v] = ps[1];
        pinj[v] = ps[2];
        pabdn[v] = ps[3];
      }
    }

    /*
     Try to take advantage of function promotion by doing this one element at a time
     Will need some expert advice.
     */
     proc cellProbabilities(i:int) {
       // Need to remove the diagonal from the expressions m and l below
       var m: real = + reduce A[i,..];
       m = m - A[i,i];
       var l = + reduce xlogx(A[i,..]);
       l = l - xlogx(A[i,i]);
       var h = max(log(m) - l / m,0);
       var c = log(beta) / (log(beta + h));
       var d = (1- c)* sqrt(h);
       var z = max(c+d, 1);
       //writeln(" cell probabilities (%n, %n, %n)".format(c/z, d/z, 1-(c+d)/z));
       return (c/z, d/z, 1-c-d);
     }
  }

   proc xlogx(x: real) {
     if x > 0.0005 {
       return x * log(x);
     } else {
       return 0;
     }
   }
}
