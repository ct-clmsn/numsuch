# NumSuch
Porting little bits of code I need from NumPy over to Chapel

Documents, such as they are, should be available [here](https://buddha314.github.io/numsuch/).

This is an attempt to collect numerical tools into [Chapel](https://github.com/chapel-lang/chapel) libraries.
It's a purely amateur effort, since I am by no means a numerical programmer.

Let's be bold.  Let's do [NumPy](https://github.com/numpy/numpy) + [SciPy](https://github.com/scipy/scipy) + [Keras](https://keras.io/) all at once.

Hopefully we can get the algorithms documented in the [tex](tex/) directory.  Trust the raw TeX for recency, not the PDFs.

## Why Chapel?

Because it works. I'm finding myself laughing out loud at 2 AM saying "I can't believe that worked the first time!".  And it feels like the love child of Python (mom) and Fortran (dad), the two greatest languages
ever invented.

## NNModels

Algorithms are based on Section 6.5 of "Deep Learning" by Goodfellow, Bengio and Courville.  See 1st Ed. page 202

Quick example from the [MLP tests](test/mlp-test.chpl)

```
use NN;
writeln("How do you run tests in Chapel?");

writeln("Hola Mundo!");
var X = Matrix(
   [1.0,0.0,1.0,0.0],
   [1.0,0.0,1.0,1.0],
   [0.0,1.0,0.0,1.0]);
var y = Vector([1.0,1.0,0.0]);

const epochs:int = 5000,
      lr: real = 0.1;
var model = new Sequential();
model.add(new Dense(units=2, inputDim=4, batchSize=3));
model.add(new Dense(units=1));
//model.add(new Dense(units=6));
model.add(new Activation(name="relu"));

var o = model.fit(xTrain=X,yTrain=y, epochs=epochs, lr=lr);
```

## GBSSL

Based mostly on the [PPT by Talukdar and Subramanya](http://graph-ssl.wdfiles.com/local--files/blog%3A_start/graph_ssl_acl12_tutorial_slides_final.pdf)
