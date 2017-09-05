"""
  Here to check the performance of calculation of cosine similarity
  Here is an SO on the topic in Python: https://stackoverflow.com/questions/17627219/whats-the-fastest-way-in-python-to-calculate-cosine-similarity-given-sparse-mat

  And it points out I want 1-cs, duh... :)
"""
import numpy as np
import scipy
from scipy import io
from scipy.sparse import csr_matrix
import timeit

def run():
    print("you can never run from yourself")
    A = io.mmread(vector_file)
    A = A.tocsr()
    X = csr_matrix((A.shape[0], A.shape[0]))
    start = timeit.timeit()
    print(" A shape (%s, %s)" % (A.shape[0], A.shape[0]))
    for i in range(0, A.shape[0]):
        print("working row %s" % i)
        #print(np.transpose(A[i,]).shape)
        n1 = np.dot(A[i,], np.transpose(A[i,]))
        for j in range(i+1, (A.shape[0])):
            #print("  working j= %s" % j)
            n2 = np.dot(A[j,], np.transpose(A[j,]))
            c = np.dot(A[i,], np.transpose(A[j,])) / (n1*n2)
            X[i,j] = c
            X[j,i] = c
    end = timeit.timeit()
    print(" elapsed time in cosim loop %s" % end-start)

if __name__=="__main__":
    vector_file = "../data/webkb_vectors.mtx"
    run()
