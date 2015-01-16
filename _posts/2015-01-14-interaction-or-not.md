---
title: "A Preference for Interactions? (Know Your Implicit Priors!)"
layout: post
category: posts
draft: true
---

Todo:

- better chart titles (state the conclusion)
- label the predictions charts, e.g. "here we're making predictions about data unlike that seen in the training set"
- draw the trees
- explanation about why `mtry=2`
- bart

Often we think of "interactions" (when the effect of one feature differs depending on the value of another) as interesting/surprising discoveries. Given that, we often use models that prefer not using interactions, introducing them only when the evidence warrants. In this post, I'll use a simple toy example to walk through why decision trees and ensembles of decision trees (Random Forests) do just the opposite: When the evidence is equally consistent with an interaction effect and no interaction, they prefer the interaction effect.

I'll also look at a neat Bayesian machine learning algorithm, [Bayesian Additive Regression Trees](http://cran.r-project.org/web/packages/bartMachine/vignettes/bartMachine.pdf), and show how the parameters controlling the prior distribution affect the model's tendency to learn an interaction effect.

Suppose you're given this data and asked to make a prediction about `$X_1 = 0$, $X_2 = 1$`.

![plot of chunk unnamed-chunk-1](/images/posts/interaction-or-not/unnamed-chunk-1.png) 

<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Jan 16 10:46:50 2015 -->
<TABLE border=1>
<TR> <TH> X1 </TH> <TH> X2 </TH> <TH> Y </TH> <TH> N Training Rows: </TH>  </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 0 </TD> <TD align="center"> 5 + small noise </TD> <TD align="center"> 67 </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 0 </TD> <TD align="center"> 15 + small noise </TD> <TD align="center"> 20 </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 1 </TD> <TD align="center"> 17 + small noise </TD> <TD align="center"> 13 </TD> </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 1 </TD> <TD align="center"> ? </TD> <TD align="center"> 0 </TD> </TR>
   </TABLE>

In practice making an inference at `$X_1 = 0$, $X_2 = 1$` is pretty hopeless. The training data doesn't help much, so your prediction will depend entirely on your priors. But that's exactly why I'm using this example to get at what the priors are in various models. Real problems will have pieces in common with this example, so it helps get a handle on how models will behave for those problems.

(In fact, if for some reason you had this example in real life, you probably wouldn't even bother with a model. It reminds me of an old criticism of Bayesian reasoning: *If you can really know your prior (what you should think given all previous information), why bother with a model rather than just look at the data and report what you think afterward (your new 'prior') as the answer?* In this case, that's probably exactly what you *should* do.)


### A Linear Model


```r
lmFit <- lm(Y ~ X1 + X2, data = train)
```

If you fit a linear model of the form `$\mathbb{E}[Y] = \beta_0 + \beta_1 X_1 + \beta_2 X_2$`, you find

`$$\mathbb{E}[Y] = 5 + 10 X_1 + 2 X_2.$$`

This fits the training data perfectly and extrapolates to the unseen region of feature space using the assumption that effects are additive.

![plot of chunk unnamed-chunk-4](/images/posts/interaction-or-not/unnamed-chunk-4.png) 

The line for `$X_1 = 0$` is parallel to the one for `$X_1 = 1$`, meaning that the influence of `$X_2$` is the same ($+2$) regardless of the value of `$X_1$`


### Random Forest (and decision trees)



Fitting a random forest and plotting its predictions, we see that it makes the same predictions as the linear model where we have training data (which fit the data perfectly), but has decided that `$X_2$` only matters when `$X_1 = 1$`:


```r
rfFit <- randomForest(Y ~ X1 + X2, data = train, mtry=2)
```

![plot of chunk unnamed-chunk-7](/images/posts/interaction-or-not/unnamed-chunk-7.png) 

It's easy to understand from the trees why this happened. In this simple example, all of the trees are the same, so it's just as if we had one decision tree:

(draw tree)

You'll notice I set `mtry=2`. This tells the random forest to consider both variables at each split. ....


```r
# ?randomForest
# library(randomForest)
# rf <- randomForest(train, y = Y, mtry=2, ntree=1)
# 
# test$YHat <- predict(rf, test)
# test
# table(train)
# 
# 
# rf$forest$leftDaughter
# rf$forest$rightDaughter
# 

# Title: An Interaction or Not? Know Your Priors

# chart-- training data (colored by Y... or use numbers), question mark where we don't have any
# 
# Two reasonable possibilities are...:
# 
# I'll use this extreme example to probe a few types of models 
# 
# ## Random Forest
# 
# learns interaction
# 
# ## Linear regression (no interaction)
# 
# 
# ## Linear regression (with interaction)
# 
# ## BART
```


## hi
