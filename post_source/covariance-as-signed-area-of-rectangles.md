(Draft)

Bugs to fix before posting:

- [point colors](https://github.com/dcjones/Gadfly.jl/issues/225)
- [point movement on zoom/pan](https://github.com/dcjones/Gadfly.jl/issues/226)

-----------

A colleague at work recently pointed me to a wonderful [stats.stackexchange](https://stats.stackexchange.com/questions/18058/how-would-you-explain-covariance-to-someone-who-understands-only-the-mean) answer with an intuitive explanation of covariance: For each pair of points, draw the rectangle with these points at opposite corners. Treat the rectangle's area as signed, with the same sign as the slope of the line between the two points. If you add up all of the areas, you have the (sample) covariance, up to a constant that depends only on the data set set.

```{.julia hide="true" results="none"}
include(abspath("src/covariance_rectangles.jl"))
```
Here's an example with 4 points. Each spot on the plot is colored by the sum corresponding to that point. For example, the dark space in the lower left has three "positively" signed rectangles going through it, but for the white space in the middle, one positive and one negative rectangle cancel out.

```{.julia hide="true"}
covariance_rectangles_plot(DataFrame(x = [1, 4, 3, 2], y = [1, 5, 2, 4]))
```

In this next example, $x$ and $y$ are drawn from independent normals, so we have roughly an even amount of positive and negative:

```{.julia hide="true"}
n=20
covariance_rectangles_plot(DataFrame(x=randn(n), y=randn(n)))
```

## Formal Explanation

The formal way to speak about multiple draws from a distribution is with a set of independent and identically distributed (i.i.d.) random variables. If we have a random variable $X$, saying that $X_1, X_2, \ldots$ are i.i.d means that they are all independent, but follow the same distribution.

To consider covariance and these rectangles, we need to think of a random variable which is the ordered pair of random variables $(X,Y)$. Suppose that $\{(X_1, Y_1), (X_2, Y_2), \ldots, (X_n, Y_n)\}$ are i.i.d. random variales (each of which consists of a pair of random variables that are *not* assumed to be independent). The (signed) area corresponding to $(X_i,Y_i)$ and $(X_j,Y_j)$ is $(X_j-X_i)(Y_j-Y_i)$. Before considering the sum of areas, let's examine the expected value of the signed area for just one rectangle, given just two different (i.e. $i \neq j$) i.i.d. draws:

$(X_j-X_i)(Y_j-Y_i) = X_j Y_j - X_j Y_i + X_i Y_j - X_i Y_i$

Taking expected values:

$\mathcal{E}[(X_j-X_i)(Y_j-Y_i)] = 2\mathcal{E}[XY] - 2\mathcal{E}[X]\mathcal{E}[Y] = 2\mathcal{Cov}[X,Y]$

This follows by:

- noting that when $i \neq j$, $X_j$ and $Y_i$ are independent so the expect value of their product is the product of their expected values
- applying linearity of $\mathcal{E}$
- simplifying the notation by writing $X$ and $Y$ where we don't need to refer to a particular i.i.d copy
- applying the definition of covariance, $\mathcal{Cov}[X,Y] = \mathcal{E}[XY] - \mathcal{E}[X]\mathcal{E}[Y]$.

## Sum Across Pairs as an Approximation of Single-Pair Expected Value

Since we've seen that the expected signed area for a single pair of points is the covariance, it follows that the average signed area across all our pairs is an estimator for the covariance (in fact it's the usual sample covariance, but I haven't shown that). This means that to go from the sum of areas to the covariance, we need to divide by the number of pairs, $\frac{n(n-1)}{2}$.