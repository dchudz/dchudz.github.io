---
layout: post
title: Some Old Stuff
category: posts
github: https://github.com/dchudz/Knit3d/blob/master/CreateGraph.py
---


### Simulated Knitting ([post](http://blog.davidchudzicki.com/2011/11/simulated-knitting.html)) [![Knit3D](/images/posts/gh.png)](https://github.com/dchudz/Knit3d/blob/master/CreateGraph.py)


I created a ```KnittedGraph``` class (a subclass of Python's ```igraph``` graph class) with methods like this:

``` python
g = KnittedGraph()
g.AddStitches(n)
g.ConnectToZero() # join with the first stitch for a circular shape	
g.NewRow() # start a new row of stitches
g.Increase() # two stitches in new row connect to one stitch in old
#(etc.)
```

The generated graph is then embedded in 3D using a standard approach. Here's a hat I made this way:

![hat](/images/posts/hat_100_20.png)

This getting [Hacker News'd](https://news.ycombinator.com/item?id=3329533) is how I learned what Hacker News is.

### 2D Embeddings from Unsupervised Random Forests ([1](http://blog.davidchudzicki.com/2012/08/random-forests-for-visualizing-data.html), [2](http://blog.davidchudzicki.com/2012/08/visualize-random-forest-that-classifies.html)) [![random_forest_visualizations](/images/posts/gh.png)](https://github.com/dchudz/misc/tree/master/random_forest_visualizations)

There are all sorts of ways to embed high-dimensional data in low dimensions for visualization. Here's one:

1. Given some set of high dimensional examples, build a random forest to distinguish examples from non-examples.
2. Assign similarities to pairs of examples based on how often they are in leaf nodes together.
3. Map examples to 2D, making similarity inverse to distance as well as possible (I used [multidimensional scaling](https://en.wikipedia.org/wiki/Multidimensional_scaling) for this).

Here's the result of doing this on a set of diamond shapes I constructed. I like how it turned out:

![hat](/images/posts/diamondsRF.png)

### A Bayesian Model for a Function Increasing by Chi-Squared Jumps (in Stan) ([post](http://blog.davidchudzicki.com/2013/10/a-bayesian-model-for-function.html)) [![stan_increasing_function](/images/posts/gh.png)](https://github.com/dchudz/misc/tree/master/stan%20models/increasing%20by%20chi%20square%20increments)

In [this paper](http://www.stat.columbia.edu/~gelman/research/published/deep.pdf), Andrew Gelman mentions a neat example where there's a big problem with the naive approach to putting a Bayesian prior on functions that are constrained to be increasing. So I thought about what sort of prior would make sense for such functions, and fit the models in Stan. 

I enjoyed [Andrew's description of my attempt](http://andrewgelman.com/2013/11/22/bayesian-model-increasing-function-stan/): *"... it has a charming DIY flavor that might make you feel that you too can patch together a model in Stan to do what you need."*

![increasing_uniform](/images/posts/increasing_uniform.png)

### Lissijous Curves [JSFiddle](http://jsfiddle.net/dchudz/yYZZy/embedded/result/))

Some JavaScript I wrote (using d3) to mimick what an oscilloscope I saw at the Exploratorium was doing:

[![lissijous](/images/posts/lissijous.png)](http://jsfiddle.net/dchudz/yYZZy/embedded/result/)

### Visualization of the Weirstrass Elliptic Function as a Sum of Terms

![weierstrass](/images/posts/weierstrass.gif)


http://blogs.ams.org/visualinsight/2014/01/15/weierstrass-elliptic-function/

