---
layout: post
title: Some Old Stuff
category: posts
github: https://github.com/dchudz/Knit3d/blob/master/CreateGraph.py
---

This is my first post in this new location/format. Any posts dated earlier than this are migrated from the other blog.

Here are the posts I'm intending to migrate:

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

### 2D Embeddings Based on Random Forest Proximity ([1](http://blog.davidchudzicki.com/2012/08/random-forests-for-visualizing-data.html), [2](http://blog.davidchudzicki.com/2012/08/visualize-random-forest-that-classifies.html)) [![random_forest_visualizations](/images/posts/gh.png)](https://github.com/dchudz/misc/tree/master/random_forest_visualizations)

There are all sorts of ways to embed high-dimensional data in low dimensions for visualization. 

- [](http://blog.davidchudzicki.com/2012/08/random-forests-for-visualizing-data.html)
- [http://blog.davidchudzicki.com/2012/08/visualize-random-forest-that-classifies.html](http://blog.davidchudzicki.com/2012/08/visualize-random-forest-that-classifies.html)

![hat](/images/posts/diamondsRF.png)


### Stan...

- [http://blog.davidchudzicki.com/2013/10/a-bayesian-model-for-function.html](http://blog.davidchudzicki.com/2013/10/a-bayesian-model-for-function.html)


- [http://blog.davidchudzicki.com/2013/10/dithering.html](http://blog.davidchudzicki.com/2013/10/dithering.html)


- [http://blog.davidchudzicki.com/2014/01/interactive-lissijous-curves-in-d3.html](http://blog.davidchudzicki.com/2014/01/interactive-lissijous-curves-in-d3.html)


### Visualization of the Weirstrass Elliptic Function as a Sum of Terms

![weierstrass](/images/posts/weierstrass.gif)


http://blogs.ams.org/visualinsight/2014/01/15/weierstrass-elliptic-function/

