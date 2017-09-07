CC=chpl
ZMQ_BASE=/usr/local/Cellar/zeromq/4.2.2
BLAS_HOME= /usr/local/Cellar/openblas/0.2.20
INCLUDES=-I${ZMQ_BASE}/include -I$(BLAS_HOME)/include
LIBS=-L${ZMQ_BASE}/lib -lzmq -L${BLAS_HOME}/lib -lblas
MODULES=-M../src
FLAGS=--fast

all: test

labels: labelmatrix-from-file.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o labels $<
	./labels
	rm labels

cos: cosineDistance.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o cos $<
	./cos
	rm cos	
