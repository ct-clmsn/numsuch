CC=chpl
ZMQ_BASE=/usr/local/Cellar/zeromq/4.2.2
BLAS_HOME= /usr/local/Cellar/openblas/0.2.20
INCLUDES=-I${ZMQ_BASE}/include -I$(BLAS_HOME)/include
LIBS=-L${ZMQ_BASE}/lib -lzmq -L${BLAS_HOME}/lib -lblas
MODULES=-M../src
FLAGS=--fast

all: test

mad: gbssl-test.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o gbssl-test $<
	./gbssl-test
	rm gbssl-test


test: mlp-test.chpl
	$(CC) $(MODULES) $(INCLUDES) $(LIBS) -o mlp-test $<
	./mlp-test
	rm mlp-test

core: core-test.chpl
	$(CC) $(FLAGS) $(MODULES) $(INCLUDES) $(LIBS) -o core-test $<
	./core-test
	rm core-test
