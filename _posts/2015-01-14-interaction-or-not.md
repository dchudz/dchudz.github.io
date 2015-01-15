---
title: "A Preference for Interactions? (Know Your Implicit Priors!)"
layout: post
category: posts
draft: true
---

Often we think of "interactions" (when the effect of one feature differs depending on the value of another) as interesting/surprising discoveries. Given that, we often use models that prefer not using interactions, introducing them only when the evidence warrants. In this post, I'll use a simple toy example to walk through why decision trees and ensembles of decision trees (Random Forests) do just the opposite: When the evidence is equally consistent with an interaction effect and no interaction, they prefer the interaction effect.

I'll also look at a neat Bayesian machine learning algorithm, [Bayesian Additive Regression Trees](http://cran.r-project.org/web/packages/bartMachine/vignettes/bartMachine.pdf), and show how the parameters controlling the prior distribution affect the model's tendency to learn an interaction effect.

Suppose you're given this data and asked to make a prediction about `$X_1 = 0$, $X_2 = 1$`.

![plot of chunk unnamed-chunk-1](/images/posts/interaction-or-not/unnamed-chunk-1.png) 

<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Jan 15 10:34:20 2015 -->
<TABLE border=1>
<TR> <TH> X1 </TH> <TH> X2 </TH> <TH> Y </TH>  </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 0 </TD> <TD align="center"> 15 + small noise </TD> </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 0 </TD> <TD align="center"> 5 + small noise </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 1 </TD> <TD align="center"> 17 + small noise </TD> </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 1 </TD> <TD align="center"> ? </TD> </TR>
   </TABLE>

This example is probably so simple that in practice a model wouldn't be useful. It reminds me of an old criticism of Bayesian reasoning: *If you can really know your prior (what you should think given all previous information), why bother with a model rather than just look at the data and report what you think afterward (your new 'prior') as the answer?* In this case, that's probably exactly what you *should* do.

### A Linear Model

If you fit a linear model of the form `$\mathbb{E}[Y] = \beta_0 + \beta_1 X_1 + \beta_2 X_2$`, you find

`$$\mathbb{E}[Y] = 5 + 10 X_1 + 2 X_2$$`

and this fits the data very well. 



### Random Forest





```r
test <- expand.grid(X1 = 0:1,  X2 = 0:1)
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
