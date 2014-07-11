---
title: "Bayesian Trees: Looking for Sensible Results in Simple Examples [source]()"
layout: post
category: posts
draft: true
---




The Bayesian Additive Regression Trees (BART) model consists of a sum of trees, along with values at the leaf notes. I'm attracted to the method as a way to obtain similar out-of-the-box (no hand tuning or model selection needed) performance to common machine learning methods (random forests, gradient boosting machines, etc.), but also provide **uncertainties** along with each individual prediction. BART is an MCMC method, meaning that we receive a series of draws from the posterior distribution, each of which is a set of tree structures along with values at the leaf nodes.

The purpose of this post is to explore how appropriate the resulting uncertainties seem in a few simple simulated examples where we know the truth. For this, I use the [`bartMachine`]() implementation by SOMEONE and SOMEONEELSE. The above description of the algorithm might be enough to follow along with this post, but I highly recommend reading at least the first page of the package authors' [vignette](), which provides a very clear description of the algorithm.

### Simplest possible example:

In this example, $X_1$ (which is $0$ for 10 observations and $1$ for 100) is the only input, and 

$$y = X_1 + 5 + \mathcal{N}(0,1)$$

The model assumes that the noise is independent of everything, which is consistent with the example. You can see that the mean of $y$ depends on $X_1$, and that we have much more data with $X_1=1$ than $X_1=0$ 

![plot of chunk unnamed-chunk-2](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-2.png) 


# Default bartMachine (behavior would be the same with only one tree)

```r
bartFit <- bartMachine(X = train, y = y)
```

```
## bartMachine initializing with 50 trees...
## Java initialized with 1.14GB maximum memory (the default).
## Now building bartMachine for regression ...
## evaluating in sample data...done
```

```r
sigmaPosterior <- get_sigsqs(bartFit)
qplot(sigmaPosterior)
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-3](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-3.png) 

```r
mean(sigmaPosterior)
```

```
## [1] 0.868
```

```r
posteriorSamples <- bart_machine_get_posterior(bartFit, test)$y_hat_posterior_samples

sampleDF <- ldply(1:ncol(posteriorSamples), function(ixSample) {
    testOneSample <- test
    testOneSample$SampleY <- posteriorSamples[, ixSample]
    return(testOneSample)
})
```



# As you'd expect, uncertainty is higher for the 0's (where we have fewer observations)

```r
ggplot(sampleDF) + geom_point(aes(x = factor(X1), y = SampleY), alpha = 0.5)
```

![plot of chunk unnamed-chunk-4](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-41.png) 

```r
ggplot(sampleDF) + geom_histogram(aes(fill = factor(X1), x = SampleY))
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

```
## Warning: position_stack requires constant width: output may be incorrect
```

![plot of chunk unnamed-chunk-4](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-42.png) 


<!--more-->


# A little bit more noise shows the difference between one tree and two trees more clearly


```r
set.seed(0)
sigmaTrue <- 3
nTrain <- 300
coef <- 2
test <- merge(data.frame(X1 = c(0, 1)), data.frame(X2 = c(0, 1)))
train <- test[sample(c(rep(1, nTrain * 0.45), rep(2, nTrain * 0.05), rep(3, 
    nTrain * 0.05), rep(4, nTrain * 0.45))), ]
ggplot(train) + geom_bar(aes(x = factor(X1), fill = factor(X2)))
```

![plot of chunk unnamed-chunk-5](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-5.png) 

```r
y <- coef * train$X1 + coef * train$X2 + rnorm(nrow(train)) * sigmaTrue
numTreesList <- c(1, 2, 100)
names(numTreesList) <- numTreesList
# Default bartMachine
bartFitByNumTrees <- Map(function(numTrees) bartMachine(X = train, y = y, num_trees = numTrees), 
    numTreesList)
```

```
## bartMachine initializing with 1 trees...
## Now building bartMachine for regression ...
## evaluating in sample data...done
## bartMachine initializing with 2 trees...
## Now building bartMachine for regression ...
## evaluating in sample data...done
## bartMachine initializing with 100 trees...
## Now building bartMachine for regression ...
## evaluating in sample data...done
```

```r
posteriorSamplesByNumTrees <- Map(function(bartFit) bart_machine_get_posterior(bartFit, 
    test)$y_hat_posterior_samples, bartFitByNumTrees)

sampleDFByNumTrees <- Map(function(posteriorSamples) {
    return(ldply(1:ncol(posteriorSamples), function(ixSample) {
        testOneSample <- test
        testOneSample$SampleY <- posteriorSamples[, ixSample]
        return(testOneSample)
    }))
}, posteriorSamplesByNumTrees)

sampleDF <- ldply(names(sampleDFByNumTrees), function(numTreesString) {
    oneSampleDF <- sampleDFByNumTrees[[numTreesString]]
    oneSampleDF$NumTrees <- as.integer(numTreesString)
    return(oneSampleDF)
})
```



```r
ggplot(sampleDF) + geom_histogram(aes(fill = factor(X1), x = SampleY), alpha = 0.6, 
    position = position_identity()) + # geom_vline(aes(xintercept = SampleY, color=factor(X1)),
# data=ddply(sampleDF, c('X1', 'X2', 'NumTrees'), summarize, SampleY =
# median(SampleY))) +
facet_grid(X2 + NumTrees ~ ., labeller = function(variable, value) sprintf("%s: %s", 
    variable, value))
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-6](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-6.png) 



# With only 1 tree, the posterior for the X1!=X2 cases is very diffuse and even multi-modal
# This is the right answer when your prior doesn't have an additive structure:
# If X1=1, X2=0... will it behave like X1? Like X2? Or like the X1=1, X2=0 cases you saw in the training data? All of these are possible.

# Most of the trees in the single-tree model have depth 2, which is as you'd expect: 
# That's the right depth to capture the relevant variation

```r
qplot(factor(as.vector(bartMachine:::get_tree_depths(bartFitByNumTrees[["1"]])))) + 
    ggtitle("Distribution of Tree Depths for Single-Tree Model")
```

![plot of chunk unnamed-chunk-7](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-7.png) 


# 1/1 ("correct" model) is most common distribution of tree depths, 

```r
qplot(apply(bartMachine:::get_tree_depths(bartFitByNumTrees[["2"]]), 1, function(numbers) do.call(paste, 
    as.list(sort(numbers))))) + ggtitle("Distribution of Tree Depths for Two-Tree Model")
```

![plot of chunk unnamed-chunk-8](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-8.png) 


# Harder to fully understand the distribution of tree depths in the 100-tree model, but here's one example:

```r
bartMachine:::get_tree_depths(bartFitByNumTrees[["100"]])[1, ]
```

```
##   [1] 1 2 1 2 1 1 1 1 2 1 1 1 2 2 1 2 1 1 1 2 1 1 2 2 1 1 1 1 2 2 2 1 1 2 1
##  [36] 1 1 1 1 1 1 1 1 2 1 1 2 1 2 2 1 1 1 1 1 1 1 1 2 1 2 1 2 2 1 1 2 1 1 1
##  [71] 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 2 1 2 1 2 2 2 1 1 1 1 1 1 0 1
```


# You might ask why more than 2 of the trees need to have any splits at all. 
# The answer is that the prior for the leafs scales with the number of trees, so that with 100 trees it's very concentrated on 0.
# So it's only the sum of a larger number of trees that can get us away from 0 at all
# For each iteration, we can count how many trees we have at each possible depth. Then look at the distribution of those numbers:


```r
treeDepthDF <- ldply(0:2, function(depth) {
    return(data.frame(Depth = depth, NumTreesAtDepth = apply(bartMachine:::get_tree_depths(bartFitByNumTrees[["100"]]), 
        1, function(numbers) sum(numbers == depth))))
})

ggplot(treeDepthDF) + geom_histogram(aes(x = NumTreesAtDepth, fill = factor(Depth)), 
    position = position_identity()) + ggtitle("Distribution Across Iteration of Number of Trees at Each Depth")
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-10](/images/posts/bart-machine-simple-examples-discrete/unnamed-chunk-10.png) 


# We see that for all of the iterations, at least half the trees are of depth one which is consistent with the (correct) linear model. 
# A decent number have depth 2, though. Note that for the X1 != X2 observations, these depth-2 trees will have very little influence on the final result: The leafs' prior is strongly concentrated on 0, and the likelihood function will be very diffuse.
