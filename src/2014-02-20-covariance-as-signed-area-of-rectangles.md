## bugs:

- point colors
- point movement on zoom/pan

## post

A colleague at work recently pointed me to a wonderful [stats.stackexchange](http://link) answer with an intuitive explanation of covariance: For each pair of points, draw the rectangle with these points at opposite corners. Treat the rectangle's area as signed, with the same sign as the slope of the line between the two points. If you add up all of the areas, you have the (sample) covariance, up to a constant that depends only on the data set set.

```{.julia hide="true" results="none"}
using Gadfly
using DataFrames

# if the numbers are distinct and monotonic, return -1 or 1 depending on the order
# otherwise, return 0
function compare(numbers::Array)
	sorted = unique(sort(numbers))
	if sorted == numbers
		return 1
	elseif sorted == reverse(numbers)
		return -1
	else 
		return 0
	end
end

# the boundaries of our rectangles will conist of all x- and y- coordinates of
# the points. 
function covplot(pointsdf)
	xcutoffs = sort(unique(pointsdf[:x]))
	ycutoffs = sort(unique(pointsdf[:y]))
	griddf = DataFrame(
		ixx=repeat([1:(length(xcutoffs)-1)], inner=[(length(ycutoffs)-1)]), 
		ixy=repeat([1:(length(ycutoffs)-1)], outer=[(length(xcutoffs)-1)]), 
	)
	griddf[:x_min] = xcutoffs[1:(end-1)][griddf[:ixx]]
	griddf[:x_max] = xcutoffs[2:end][griddf[:ixx]]
	griddf[:y_min] = ycutoffs[1:(end-1)][griddf[:ixy]]
	griddf[:y_max] = ycutoffs[2:end][griddf[:ixy]]
	griddf[:xmid] = (griddf[:x_min] + griddf[:x_max])/2
	griddf[:ymid] = (griddf[:y_min] + griddf[:y_max])/2
	griddf[:areasum] = 0
	for (ixpoint1 in 1:nrow(pointsdf))
	    for (ixpoint2 in (ixpoint1+1):nrow(pointsdf))
	        for (ixgrid in 1:nrow(griddf))
	            griddf[ixgrid,:areasum] += 
		            compare([pointsdf[ixpoint1,:x], griddf[ixgrid,:xmid], pointsdf[ixpoint2,:x]]) * 
		            compare([pointsdf[ixpoint1,:y], griddf[ixgrid,:ymid], pointsdf[ixpoint2,:y]])
	        end
	    end
	end
	maxabs = maximum(abs(griddf[:areasum]))
	plot(
		layer(griddf, x_min=:x_min, x_max=:x_max, y_min=:y_min, y_max=:y_max, color=:areasum, Geom.rectbin),
		Scale.ContinuousColorScale(Scale.lab_gradient(color("green"), color("white"), color("red")), 
			minvalue=-maxabs, maxvalue=maxabs),
		layer(pointsdf, x=:x, y=:y, Geom.point),	
		Theme(panel_fill=color("white"), line_width=1mm, default_color=color("black"))
		)
end
```
Here's an example, with each spot on the plot colored by the sum corresponding to that point:

```{.julia hide="true"}
covplot(DataFrame(x = [1, 4, 3, 2], y = [1, 5, 2, 4]))
```

In this example, $x$ and $y$ are drawn from independent normals, so we have roughly an even amount of positive and negative:

```{.julia hide="true"}
n=20
covplot(DataFrame(x=randn(n), y=randn(n)))
```

## Formal Explanation: Expected Value for One Pair

The formal way to speak about multiple draws from a distribution is with a set of independent and identically distributed (i.i.d.) random variables. Suppose that $\{(X_1, Y_1), (X_2, Y_2), \ldots, (X_n, Y_n)\}$ are i.i.d. random variales (each of which consists of a pair of random variables that are *not* assumed to be independent). The (signed) area corresponding to $(X_i,Y_i)$ and $(X_j,Y_j)$ is $(X_j-X_i)(Y_j-Y_i)$. Before considering the sum of areas, let's examine the expected value of the signed area, given two (different, i.e. $i \neq j$) i.i.d. draws:

$(X_j-X_i)(Y_j-Y_i) = X_j Y_j - X_j Y_i + X_i Y_j - X_i Y_i$

Taking expected values:

$\mathcal{E}[(X_j-X_i)(Y_j-Y_i)] = 2\mathcal{E}[XY] - 2\mathcal{E}[X]\mathcal{E}[Y] = 2\mathcal{Cov}[X,Y]$

This follows by:

- noting that when $i \neq j$, $X_j$ and $Y_i$ are independent so the expect value of their product is the product of their expected values
- applying linearity of $\mathcal{E}$
- simplifying the notation by writing $X$ and $Y$ where we don't need to refer to a particular i.i.d copy
- applying the definition of covariance, $\mathcal{Cov}[X,Y] = \mathcal{E}[XY] - \mathcal{E}[X]\mathcal{E}[Y]$.

## Sum Across Pairs as an Approximation of Single-Pair Expected Value

Since we've seen that the expected signed area for a single pair of points is the covariance, it follows that the average signed area across all our pairs is an estimator for the covariance (in fact it's the usual sample covariance). This means that when summing the signed areas, we need to divide by the number of pairs, $\frac{n(n-1)}{2}$.	