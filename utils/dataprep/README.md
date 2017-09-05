# Data Prep Scripts

## Web KB

Downloaded the data from [here](http://www.cs.cmu.edu/~webkb/). The scripts build out the labels
and tfi/idf vectors. This vectorizor is not a general purpose tool, but feel
free to modify it.  It uses only 4 Departments to re-create the results [here](http://graph-ssl.wdfiles.com/local--files/blog%3A_start/graph_ssl_acl12_tutorial_slides_final.pdf)

The vectors are produced in [Matrix Market format](http://math.nist.gov/MatrixMarket/formats.html). The
vector file is 18M, so you will have to build it on your own.  The test will expect files in  `test/data/webkb_vectors.mtx` and `test/data/webkb_labels.txt` but it's not hard to change those locations. 
