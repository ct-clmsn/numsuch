CC=chpl
ZMQ_BASE=/usr/local/Cellar/zeromq/4.2.2
BLAS_HOME= /usr/local/Cellar/openblas/0.2.20
INCLUDES=-I${ZMQ_BASE}/include -I$(BLAS_HOME)/include
LIBS=-L${ZMQ_BASE}/lib -lzmq -L${BLAS_HOME}/lib -lblas
MODULES=-M../src
FLAGS=--fast

all: mlp core

mlp: mlp-test.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o mlp-test $<
	./mlp-test
	rm mlp-test

core: core-test.chpl
	$(CC) $(MODULES) $(INCLUDES) $(LIBS) -o core-test $<
	./core-test
	rm core-test

peel: peel-test.chpl
	#$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o peel-test $<
	$(CC) $(MODULES) $(INCLUDES) $(LIBS) -o peel-test $<
	./peel-test
	rm peel-test
