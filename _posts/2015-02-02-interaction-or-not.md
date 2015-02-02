---
title: "Understanding Five Different Algorithms Using One Toy Example"
layout: post
category: posts
draft: true
---

We describe a model as having an "interaction" when the influence of one feature differs depending on the value of another. Interactions are often real and important, but in many contexts we treat interaction effects as likely to small without evidence otherwise. In this post, I'll use a simple toy example to walk through why decision trees and ensembles of decision trees (random forests) can make the opposite assumption: they can strongly prefer an interaction, even when the evidence is equally consistent with including or not including an interaction.

I'll look at point estimates from:

- a linear model
- decision trees and bagged decision trees (random forest), using R's `randomForest` package
- boosted decision trees, using the R's `gbm` package

I'll also look at two models that capture **uncertainty** about whether there's an interaction:

- Bayesian linear model with an interaction term
- [Bayesian Additive Regression Trees](http://cran.r-project.org/web/packages/bartMachine/vignettes/bartMachine.pdf) (BART) 

BART has the advantage of expressing uncertainty while still being a "machine learning" type model that learns interactions, non-linearities, etc. without the user having to decide which terms to include or the particular functional form.

Whenever possible, I recommend using models like BART that explicitly allow for uncertainty.

# The Example

Suppose you're given this data and asked to make a prediction at `$X_1 = 0$, $X_2 = 1$` (where we don't have any training data).



![plot of chunk unnamed-chunk-2](/images/posts/interaction-or-not/unnamed-chunk-2.png) 

<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Mon Feb  2 10:23:42 2015 -->
<TABLE border=1>
<TR> <TH> X1 </TH> <TH> X2 </TH> <TH> Y </TH> <TH> N Training Rows: </TH>  </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 0 </TD> <TD align="center"> Y = 5 + noise </TD> <TD align="center"> 52 </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 0 </TD> <TD align="center"> Y = 15 + noise </TD> <TD align="center"> 23 </TD> </TR>
  <TR> <TD align="center"> 1 </TD> <TD align="center"> 1 </TD> <TD align="center"> Y = 19 + noise </TD> <TD align="center"> 25 </TD> </TR>
  <TR> <TD align="center"> 0 </TD> <TD align="center"> 1 </TD> <TD align="center"> ? </TD> <TD align="center"> 0 </TD> </TR>
   </TABLE>

Or another view of the training data:

![plot of chunk unnamed-chunk-4](/images/posts/interaction-or-not/unnamed-chunk-4.png) 


In practice, making an inference at `$X_1 = 0$, $X_2 = 1$` would be pretty hopeless. The training data doesn't help much, so your prediction will depend almost entirely on your priors. But that's exactly why I'm using this example to get at what the biases are in various models. Real problems will have elements in common with this example, so it helps get a handle on how models will behave for those problems.

# A Linear Model


```r
lmFit <- lm(Y ~ X1 + X2, data = train)
```

If you fit a linear model of the form `$\mathbb{E}[Y] = \beta_0 + \beta_1 X_1 + \beta_2 X_2$`, you find



`$$\mathbb{E}[Y] = 5 + 10 X_1 + 4 X_2.$$`

This fits the training data perfectly and extrapolates to the unseen region of feature space using the assumption that effects are additive.

![plot of chunk unnamed-chunk-7](/images/posts/interaction-or-not/unnamed-chunk-7.png) 

The line for `$X_1 = 0$` is parallel to the one for `$X_1 = 1$`, meaning that the influence of `$X_2$` is the same (+4) regardless of the value of `$X_1$`


# Decision Trees (and Random Forest)



Random forests are build from decision trees using an ensembling technique called *bagging*, which averages a number of independent decision trees. To make the trees different, different trees use different random subsets of the training data. (Additional randomness is usually introduced by allowing each tree to consider a random subset of the features at each split.)

Fitting a random forest and plotting its predictions, we see that where it has training data, it fits that data perfectly (making the same predictions as the linear model), but has decided that `$X_2$` only matters when `$X_1 = 1$`:


```r
rfFit <- randomForest(Y ~ X1 + X2, data = train, mtry=2)
```

![plot of chunk unnamed-chunk-10](/images/posts/interaction-or-not/unnamed-chunk-10.png) 

It's easy to understand from the trees why this happened. In this simple example, all of the trees are the same, so it's just as if we had one decision tree. `$X_1$` is the most important variable, so first we split on that. Then only the right side splits again on `$X_2$` (since the left side has no training set variation in `$X_2$`):

![tree](/images/posts/interaction-or-not-trees/tree.png)

Aside: You'll notice when I trained the random forest, I set `mtry=2`. This tells the random forest to consider both variables at each split (normally you consider only a randomly chosen subset of the variables for each split). This choice makes the example clearer, but I'm not really "cheating" because in this example, `mtry=2` would be the parameter you choose as optimal based on the training data (e.g. through cross-validation). With the default settings, the random forest would fail to replicate even the training data (where there should be no question which predictions are correct).

# Boosted Decision Trees

*Boosting* is an ensembling technique in which each tree is built based on the residuals from the previous one. Unlike with bagging, this allows the model to add together effects that are each chosen whole controlling for the others, giving the model a bit of an additive charactaristic. 

It's possible to represent a well-fitting model as a sum of only two depth-1 trees (this is the same as the linear model):

![two-trees](/images/posts/interaction-or-not-trees/two-trees.png)

But the `gbm` can't get to this answer with only two trees, because first tree (with a split on `$X_1$`) would attribute too much of the effect to `$X_1$` ($12$ instead of $10$), and the second tree (with a split on `$X_2$`) has no way to correct that. We'd get these trees, which make bad predictions:

![two-trees](/images/posts/interaction-or-not-trees/two-trees-wrong.png)



```r
library(gbm)
gbmFit1 <- gbm(Y ~ X1 + X2, data = train, n.trees=2, shrinkage = 1, distribution = "gaussian")
```

![plot of chunk unnamed-chunk-12](/images/posts/interaction-or-not/unnamed-chunk-12.png) 

Instead, boosting generally fits only a small amount of the signal at each stage, making only very small adjustments in the direction of fitting the residuals. This works much better:


```r
library(gbm)
gbmFit2 <- gbm(Y ~ X1 + X2, data = train, n.trees=10000, shrinkage = .01, distribution = "gaussian")
```

![plot of chunk unnamed-chunk-14](/images/posts/interaction-or-not/unnamed-chunk-14.png) 

But this is using the default `interaction.depth=1`, which forces the model to be linear. If we set `interaction.depth=2`, the results are similar to what we would get with only one decision tree:



```r
library(gbm)
gbmFit3 <- gbm(Y ~ X1 + X2, data = train, n.trees=10000, shrinkage = .01, distribution = "gaussian", interaction.depth = 2)
```

![plot of chunk unnamed-chunk-16](/images/posts/interaction-or-not/unnamed-chunk-16.png) 

Is it possible for `gbm` to result in a middle ground between the linear model and the one-tree model? Yes! Two parameters we can tweak for this are: 

- `n.minobsinnode` (default: $10$), the minimum number of observations for a leaf node.
- `bag.fraction` (default: $0.5$), the number of randomly selected training observations to use for each tree

To get the second (deeper) split, we need at least `n.minobsinnode` in each of the smaller groups (`$X_1 = 1$, $X_2 = 0$` or  `$X_1 = 1$, $X_2 = 1$`). As we increase `n.minobsinnode`, we decrease the number of trees that meet the threshold for a second split:

![plot of chunk unnamed-chunk-17](/images/posts/interaction-or-not/unnamed-chunk-17.png) 

Varying `bag.fraction` would have a similar effect.

# Linear Regression with Regularized Interaction Term

Going back to the linear regression, we can add an interaction term to let the model consider interactions. The model is:

`$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_{12} X_1 X_2 + N(0,\sigma).$$`

Without regularization this would be too many free parameters, so I'll put a prior on `$\beta_{12}$` (pushing it toward zero). All parameters except `$\beta_{12}$` have improper flat priors while `$$\beta_{12} \sim N(0,2).$$`

Such a simple model doesn't need a flexible tool like Stan, but I like how clear and explicit a model is when you write it down in the Stan language. Stan fits Bayesian models using Markov Chain Monte Carlo (MCMC), so the output is a set of parameter samples from the posterior distribution.

Here's what the model looks like in Stan:


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




Now instead of one prediction for each point in feature space, we have a set of posterior samples. Each line represents the predictions for one posterior sample, at either `$X_1=0$` or `$X_1=1$`:


```
## Error: object 'stan1Predictions' not found
```

For points like the ones we saw in the training data, there is very little uncertainty. But there is a lot of uncertainty about the predicted effect of `$X_2$` when `$X_1 = 0$`.

The posterior for the interaction term `$\beta_{12}$` is actually the same as the prior, which makes sense because the data don't tell you anything about whether there's an interaction:


```
## Error: object 'samples1' not found
```

Looking at histograms of posterior samples for predictions is another way to see that there's basically no variation at the points where we have training data:


```
## Error: object 'stan1Predictions' not found
```

Looking closer at the posterior samples for `$X_1 = 0$, $X_2 = 1$`, we see that the predictions are centered on 9 (the prediction from our model with no interaction), but has substantial variation in both directions:


```
## Error: object 'stan1Predictions' not found
```

The interaction term can be positive or negative. When the interaction term `$\beta_{12}$` is high, `$\beta_2$` makes up for it by being low (and vice versa):


```
## Error: object 'samples1' not found
```

Note that if we were to regularize the main effects as well as the interaction term, the predictions at `$X_1 = 0$, $X_2 = 1$` would shift to the left. Imagine a prior on `$\beta_2$` centered on $0$ as well as the prior we already have on `$\beta_{12}$`. In that case, parameters choices with a negative interaction term would be penalized twice: once for the negative `$\beta_{12}$`, and again for forcing `$\beta_2$` higher than it otherwise had to be.

In summary, the Bayesian linear regression (with an interaction term) is appropriately uncertain about predictions in the unseen region of feature space. The particular details of the posterior would depend on how you feel about main effects as compared with to interaction terms: If only the interaction term is pushed toward 0, the predictions are centered around the "no interaction" case. If main effects are pushed toward zero as well, predictions are shifted toward the "positive interaction" case.

# Bayesian Additive Regression Trees (BART)

BART is a Bayesian model that's fit using MCMC, so just like with the previous example, we'll get samples from a posterior. The BART model consists of a sum of trees, where we have a prior distribution over the depth of the splits, the values at the leaf nodes, and so on. I don't want to fully describe BART in detail here, so if you're interested have a look at [the vignette](http://cran.r-project.org/web/packages/bartMachine/vignettes/bartMachine.pdf) for the `bartMachine` R package.

For now, the important thing about BART is that it's a *sum of trees*, where each tree is fitted in the context of the rest. In the iterative algorithm, each tree is modified one by one based on the residuals from the other trees (unlike random forests, where each tree is independent). This allows BART to better capture additive effects. If the trees all had just one split, we would *only* capture additive effects. 

For example, the linear model above (with no interaction) would be the same as a model that comes from two trees, each with one split: one splitting on `$X_1$` and the other on `$X_2$`.


Trees that are deeper than one split would allow BART to introduce interactions.


```r
library(bartMachine)
nIterAfterBurnIn <- 100000
bartFit <- bartMachine(train[c("X1","X2")], train$Y, 
                       num_burn_in=50000, 
                       num_trees=10, 
                       num_iterations_after_burn_in=nIterAfterBurnIn)
```



```
## Error: No running JVM detected. Maybe .jinit() would help.
```



```
## Error: object 'bartPredictions' not found
```

As with all of the previous examples, the model is both correct and confident in the regions where we have training examples.

The predictions in the new region of feature space are similar to the situation we had with the Bayesian linear model with a prior on the interaction term. There's a fair amount of uncertainty, with the posterior distribution centered near  the no-interaction case (corresponding to predictions of 9) but allowing positive or negative interactions.

# Controlling BART's Settings

To get a sense for how BART's settings affect the inference, consider that the tree depths are controlled by the prior probability of a split occurring at any given node, which is 

`$$\alpha(1+d)^{-\beta}.$$`

The default settings are $\alpha=.95$ and $\beta=2$. This means that BART can allow very deep trees, but deep trees need to overcome this prior against splitting when a node is already deep and so are less common unless the data require them.

In this case, as we increase $\beta$ we tend to get more trees with only one split (especially since more splits aren't necessary to explain the training data), leading to a posterior that's more like the no-interaction situation.

BART has other settings that it's good to understand and control them as appropriate, but it can also be used out-of-the-box without thinking too much about those at first.


# Implications for Choosing a Model

Decisions trees and random forests aren't additive models, so from their perspective the "interaction" explanation for the train data is simpler than the explanation with no interaction. 

As a separate matter, your forecasts could have lots of uncertainty that you're not thinking about if you just use point estimates. This is true **even if your training error is low** because in applications you might be forecasting for data in new regions of feature space. A high dimensional feature space has a lot of space, so you'll generally be looking at new regions in applications. With 20 binary features, there's 1 million possible inputs. That's fine since the goal of modeling is to generalize. We expect to have to generalize -- but we should be aware there's uncertainty in how we generalize.

So when possible, use models that capture uncertainty rather than just point estimates. The linear models in this example made it relatively straightforward to capture uncertainty and think about the relationship between your prior distribution and the posterior. BART is a "machine learning"-style Bayesian model. In this case it did a good job correctly capturing uncertainty without having to think much about the particulars of the situation.

