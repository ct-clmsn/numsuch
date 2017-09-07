/*
  Package of Graph-Based Semi-Supervised Learning techniques based partially
  on the work by `Subramanya and Talukdar <http://graph-ssl.wdfiles.com/local--files/blog%3A_start/graph_ssl_acl12_tutorial_slides_final.pdf>`_

  This is collected into the book on `Amazon <https://www.amazon.com/Graph-Based-Semi-Supervised-Synthesis-Artificial-Intelligence/dp/1627052011>`_

  Also, see notes in the /tex folder under main.

 */
module GBSSL {
  use LinearAlgebra,
      Time,
      Core;

  config const mu1: real,
               mu2: real,
               mu3: real,
               beta: real,
               epsilon: real,
               epochs: int;

  class ModifiedAdsorptionModel {
    var vcount: range,
        vdom: domain(1),
        gdom: domain(2),
        edom: sparse subdomain(gdom),// The non-zeroes of the graph
        ldom: domain(2),             // The domain of the labels
        v: [vdom] real,
        e: [edom] real,
        directed: bool,
        A: [gdom] real,              // the data matrix, or W in the literature, diag(A) = 0
        rowSum: [vdom] real,         // The vector of row sums, used frequently
        Y: [ldom] real,              // The labels, expanded by one column
        pcont: [vdom] real,          // a vector of pContinue
        pabdn: [vdom] real,
        pinj : [vdom] real,
        compiled: bool = false,
        Yhat: [ldom] real,           // The matrix of predicted labels
        R: [ldom] real = 0.0,        // The regularization matrix, 0 or pabdn
        Mvv: [vdom] real;

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
      iterate();
    }

    proc fit(data: [], labels: LabelMatrix) {
      // @TODO fill in the data matrix with labels.data, add a column
      Y = labels.data;
    }

    /*
      We need three probabilities as each vertex for the MAD algo.
     */
    proc compile(data: [], labels: []) {
      writeln("  ..compiling model");
      prepareA(data);
      prepareY(labels);
      calculateProbs();
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
        [i in vdom] A[i,i] = 0.0;
        for ij in data.domain {
          // @TODO: Make this W instead with diag(W) = 0;
          if data[ij] > 0 && ij[1] != ij[2] {
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
      ldom = {vcount, 1..labels.shape[2]};
      Y = labels;
      ldom = {vcount, 1..labels.shape[2]+1};
      writeln("Y \n",Y);
    }
    /*
      Find the 3 probs for each vertex
     */
    proc calculateProbs() {
      for v in vdom {
        var ps = cellProbabilities(v);
        pcont[v] = ps[1];
        //writeln("*  pcont[v] ", pcont[v]);
        pinj[v] = ps[2];
        // Set R for unlabeled vertices
        pabdn[v] = ps[3];
        if max reduce Y[v,..] < 0.1 {
          //writeln("  unlabeled vertex! ", Y[v,..]);
          R[v,R.shape[2]] = pabdn[v];
        }

      }
      writeln("R\n", R);
    }

    /*
     Try to take advantage of function promotion by doing this one element at a time
     Will need some expert advice.
     */
     proc cellProbabilities(i:int) {
       // No need to remove the diagonal from the expressions m and l below
       var m: real = + reduce A[i,..];
       rowSum[i] = m;

       var l = + reduce xlogx(A[i,..]);
       var h = max(log(rowSum[i]) - l / rowSum[i],0);
       var c = log(beta) / (log(beta + h));
       var d: real = 0;
       if max reduce Y[i,..] > 0.1 {
         d = (1- c)* sqrt(h);
       }
       var z = max(c+d, 1);
       writeln(" cell probabilities (%n, %n, %n)".format(c/z, d/z, 1-(c+d)/z));
       return (c/z, d/z, 1-c-d);
     }

     proc iterate() {
       var t: Timer;
       t.start();
       /*
         Initialize Yhat and Mvv once
        */
       Yhat = Y;
       for v in vdom {
           Mvv[v] = mu1 * pinj[v] + mu2 * pcont[v] * rowSum[v] + mu3;
       }
       // Now start the iterations.
       var Dv: [Yhat.domain] real;
       const yones: [Yhat.domain] real = 1.0;
       var err: real = 100;
       var itr: int = 0;
       do {
         // set up Dv = f(Yhat)
         // There is a matrix for this, I'll get to it later.
         for u in vdom {
           var pu = pcont[u];
           var s:[Yhat.domain.dim(2)] real = 0;
           for x in vdom {
             s += (pu * A[u,x] + pcont[x] * A[x,u]) * Yhat[x,..];
           }
           Dv[u,..] = s;
         }
         for v in vdom {
          // Yhat update
          
          Yhat[v,..] = 1/Mvv[v] * (mu1 * pinj[v] * Y[v,..] + mu2 * Dv[v,..] + mu3 * pabdn[v] * R[v,..]);
         }
         itr += 1;
       } while (epsilon > err && itr < epochs);
       t.stop();
       writeln("\telapsed time: %n".format(t.elapsed()));
     }

    proc calcDv(v: int) {
      var pv: [{1..Yhat.shape[2]}] real = 0;
      for x in vdom {
        pv += (pcont[v] * A[v,x] + pcont[x] * A[v,x]) * Yhat[x,..];
      }
      return pv;
    }
  }

   /*
     Simple function to take advantage of promotion, hopefully
    */
   proc xlogx(x: real) {
     if x > 0.0005 {
       return x * log(x);
     } else {
       return 0;
     }
   }

}
