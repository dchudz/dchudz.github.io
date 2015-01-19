---
title: "A Preference for Interactions? (Know Your Implicit Priors!)"
layout: post
category: posts
draft: true
---

We describe a model as having an "interaction" when the influence of one feature differs depending on the value of another. Interactions are often real and important, but in many contexts we treat "no interaction" (or "small interactions") as a natural default assumption unless there's evidence of an interaction. However, (ensembles of) decision trees can do just the opposite. 

In this post, I'll use a simple toy example to walk through why decision trees and ensembles of decision trees (random forests) can strongly prefer an interaction, even when the evidence is equally consistent with including or not including an interaction.

I'll also look at other models, including a neat Bayesian machine learning algorithm, [Bayesian Additive Regression Trees](http://cran.r-project.org/web/packages/bartMachine/vignettes/bartMachine.pdf) (BART). BART is the advantage of being **appropriately uncertain** about the interaction effect while being a "machine learning" type model that learns interactions, non-linearities, etc. without the user having to decide which terms to include or the particular functional form.

## The Example

Suppose you're given this data and asked to make a prediction at `$X_1 = 0$, $X_2 = 1$` (where we don't have any training data).

![plot of chunk unnamed-chunk-1](/images/posts/interaction-or-not/unnamed-chunk-1.png) 

<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Mon Jan 19 10:44:34 2015 -->
<TABLE border=1>
<TR> <TH> X1 </TH> <TH> X2 </TH> <TH> Y </TH> <TH> N Training Rows: </TH>  </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 0 </TD> <TD align="center"> Y = 5 + small noise </TD> <TD align="center"> 53 </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 0 </TD> <TD align="center"> Y = 15 + small noise </TD> <TD align="center"> 20 </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 1 </TD> <TD align="center"> Y = 17 + small noise </TD> <TD align="center"> 27 </TD> </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 1 </TD> <TD align="center"> ? </TD> <TD align="center"> 0 </TD> </TR>
   </TABLE>

In practice making an inference at `$X_1 = 0$, $X_2 = 1$` is pretty hopeless. The training data doesn't help much, so your prediction will depend entirely on your priors. But that's exactly why I'm using this example to get at what the biases are in various models. Real problems will have elements in common with this example, so it helps get a handle on how models will behave for those problems.

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

It's easy to understand from the trees why this happened. In this simple example, all of the trees are the same, so it's just as if we had one decision tree. `$X_1$` is the most important variable, so first we split on that. Then only the right side splits again on `$X_2$` (since the left side has no training set variation in `$X_2$`):

![tree](/images/posts/tree.png)


Aside: You'll notice when I trained the random forest, I set `mtry=2`. This tells the random forest to consider both variables at each split (normally you consider only a randomly chosen subset of the variables for each split). This choice makes the example clearer. I don't consider that "cheating" because with the default settings, the random forest fails to replicate even the training data (where there should be no question what predictions are correct).

## Linear Regression with Regularized Interaction Term

Going back to the linear regression, we can add an interaction term to let the model consider interactions. The model is:

`$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_{23} X_2 X_3 + N(0,\sigma).$$`

Without regularization this would be too many free parameters, so I'll put a prior on `$\beta_{23}$` pushing it toward zero). All parameters except `$\beta_{23}$` have improper flat priors while `$$\beta_{23} \sim N(0,2).$$`

Such a simple model doesn't need a flexible tool like Stan, but I like how clear and explicit a model is when you write it down in the Stan language. Stan fits Bayesian models using Markov Chain Monte Carlo (MCMC), so the output is a set of parameter samples from the posterior distribution.


```r
library(rstan)

stanModel1 <- "
data {
int<lower=0> N;
vector[N] X1;
vector[N] X2;
vector[N] Y;
}
parameters {
real beta0;
real beta1;
real beta2;
real beta12;
real<lower=0> sigma;
}
model {
beta12 ~ normal(0, 2);
Y ~ normal(beta0 + beta1*X1 + beta2*X2 + beta12*X1 .* X2, sigma);
}
"
```




Now instead of one prediction for each point in feature space, we have a set of posterior samples:


```r
ggplot(stan1Predictions) + 
  geom_line(aes(x=factor(X2), y=SamplePredictedY, color=factor(X1), group=paste(X1, SampleNumber)), alpha=.2) +
  ggtitle("Posterior Samples") + 
  xlab("X2") +
  scale_color_discrete(name = "X1")
```

![plot of chunk unnamed-chunk-10](/images/posts/interaction-or-not/unnamed-chunk-10.png) 

The posterior has very little variation in the predictions for points in feature space that we saw in the training data, which is good. But there is a lot of uncertainty about the predicted effect of `$X_2$` varies a lot when `$X_1 = 0$`.

The posterior for the interaction term `$\beta_{23}$` is actually the same as the prior, which makes sense because the data don't tell you anything about whether there's an interaction:


```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-11](/images/posts/interaction-or-not/unnamed-chunk-11.png) 

Looking at histograms of posterior samples for predictions, we again see basically no variation at the points where we have training data:


```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-12](/images/posts/interaction-or-not/unnamed-chunk-12.png) 

Looking closer at the posterior samples at `$X_1 = 0$, $X_2 = 1$`, we see that the predictions are centered on $7$ (the prediction from our model with no interaction), but has substantial variation in both directions:


```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-13](/images/posts/interaction-or-not/unnamed-chunk-13.png) 

The interaction term can be positive or negative. When the interaction term `$\beta_{12}$` is high, `$\beta_2$` makes up for it by being low (and vice versa):


```r
qplot(beta2, beta12, data=samples1)
```

![plot of chunk unnamed-chunk-14](/images/posts/interaction-or-not/unnamed-chunk-14.png) 

Note that if we were to regularize the main effects as well as the interaction term, the predictions at `$X_1 = 0$, $X_2 = 1$` would shift to the left. Imagine a prior on `$\beta_2$` centered on $0$ as well as the prior we already have on `$\beta_{12}$`. In that case, parameters choices with a negative interaction term would be penalized twice: once for the negative `$\beta_{12}$`, and again for forcing `$\beta_2$` higher than it otherwise had to be.

In summary, the Bayesian linear regression (with an interaction term) is appropriately uncertain about predictions in the unseen region of feature space. The particular details of the posterior would depend on how you feel about main effects as compared with to interaction terms: If only the interaction term is pushed toward 0, the predictions are centered around the "no interaction" case. If main effects are pushed toward zero as well, predictions are shifted toward the "positive interaction" case.

## BART

BART is a Bayesian model that's fit using MCMC, so just like with the previous example, we'll get samples from a posterior. The BART model consists of a sum of trees, where we have a prior distribution over the depth of the splits, the values at the leaf nodes, and so on. For more detail, have a look at [the vignette](http://cran.r-project.org/web/packages/bartMachine/vignettes/bartMachine.pdf) for the `bartMachine` R package.

For now, the important thing about BART is that it's a *sum of trees*, where each tree is fitted in the context of the rest (unlike random forests, which are an average of independent trees). This allows BART to better capture additive effects. If the trees all had just one split, we would *only* capture additive effects. 

For example, the linear model above (with no interaction) would be the same as a model that comes from two trees, each with one split: one splitting on `$X_1$` and the other on `$X_2$`.

![two-trees](/images/posts/two-trees.png)

Trees that are deeper than one split would allow BART to introduce interactions.


```r
library(bartMachine)
nIterAfterBurnIn <- 100000
bartFit <- bartMachine(train[c("X1","X2")], train$Y, 
                       num_burn_in=50000, 
                       num_trees=10, 
                       num_iterations_after_burn_in=nIterAfterBurnIn)
```





![plot of chunk unnamed-chunk-17](/images/posts/interaction-or-not/unnamed-chunk-17.png) 

As with all of the previous examples, the model has very little uncertainty in the regions where we have training examples.

The predictions in the new region of feature space are similar to the situation we had with the Bayesian linear model with a prior on the interaction term. There's a fair amount of uncertainty, with the posterior distribution centered near  the no-interaction case (corresponding to predictions of $7$) but allowing positive or negative interactions.

## Implications for Model Selection

