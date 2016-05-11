<h2>
	Leveraging Stan for One-Line Bayesian Models in Python:
</h2>
<h4>
(Stan Users - Boston/Camberville, May 2016)
</h4>
<small>
	<a href="http://davidchudzicki.com.com">David Chudzicki</a>
	/
	<a href="http://twitter.com/dchudz">@dchudz</a>
</small>

--

Python is nice

--

Python package ecosystem is way behind R for statistics

--

... but is catching up (`pandas`, etc.)

--

Not much for Bayesian models in Python that work right out of the box

--

Bayesian Models in Python

<ul>
	<li class="fragment">PyStan</li>
	<li class="fragment">PyMC3</li>
	<li class="fragment">Edward (variational Bayes)</li>
	<li class="fragment">scikit-learn</li>
</ul>


--

Compare with e.g. `arm` and other R packages - what makes these easy to use?

<p class="fragment">
One factor: R's formulas!
</p>

-- 
```
glm(y ~ x1 + x2, family=binomial(link="logit"))
```

--

Python packages (e.g. scikit-learn) are mostly set up to expect matrices

--

`patsy` introduced formulas to Python users

--

```
In [1]: import patsy

In [2]: import pandas as pd

In [3]: data = {'a': ['a1', 'a1', 'a2', 'a2', 'a3', 'a1', 'a2', 'a2'],
        'b': ['b1', 'b2', 'b1', 'b2', 'b1', 'b2', 'b1', 'b2'],
        'x1': [1.76405235, 0.40015721, 0.97873798, 2.2408932, 1.86755799, -0.97727788, 0.95008842, -0.15135721],
        'x2': [-0.10321885, 0.4105985, 0.14404357, 1.45427351, 0.76103773, 0.12167502, 0.44386323, 0.33367433],
        'y': [1.49407907, -0.20515826, 0.3130677, -0.85409574, -2.55298982, 0.6536186, 0.8644362, -0.74216502]}

In [4]: df = pd.DataFrame(data)

In [5]: df
Out[5]:
    a   b        x1        x2         y
0  a1  b1  1.764052 -0.103219  1.494079
1  a1  b2  0.400157  0.410598 -0.205158
2  a2  b1  0.978738  0.144044  0.313068
3  a2  b2  2.240893  1.454274 -0.854096
4  a3  b1  1.867558  0.761038 -2.552990
5  a1  b2 -0.977278  0.121675  0.653619
6  a2  b1  0.950088  0.443863  0.864436
7  a2  b2 -0.151357  0.333674 -0.742165

In [6]: patsy.dmatrices("y ~ x1 + x2 + a", data)
Out[6]:
(DesignMatrix with shape (8, 1)
          y
    1.49408
   -0.20516
    0.31307
   -0.85410
   -2.55299
    0.65362
    0.86444
   -0.74217
   Terms:
     'y' (column 0),
 DesignMatrix with shape (8, 5)
   Intercept  a[T.a2]  a[T.a3]        x1        x2
           1        0        0   1.76405  -0.10322
           1        0        0   0.40016   0.41060
           1        1        0   0.97874   0.14404
           1        1        0   2.24089   1.45427
           1        0        1   1.86756   0.76104
           1        0        0  -0.97728   0.12168
           1        1        0   0.95009   0.44386
           1        1        0  -0.15136   0.33367
   Terms:
     'Intercept' (column 0)
     'a' (columns 1:3)
     'x1' (column 3)
     'x2' (column 4))

```

--

Idea: Combine `patsy` and `pystan`!

--

Generate Stan model from something like this:

```
fit1 = stan_glm("switch ~ dist100", wells, 
                 family = family.bernoulli_logit(), 
                 priors = {"Intercept": t_prior, "dist100": t_prior})
```

[Example Jupyter Notebook](https://github.com/dchudz/BayesGLM/blob/master/examples/output/binomial.ipynb)

--

Plug into this Stan code:


```
data {{
	int<lower=1> K;
	int<lower=0> N;
	{y_type} y[N];
	matrix[N,K] x;
}}
parameters {{
	vector[K] beta;
	{parameter_statement}
}}
model {{
	real mu[N];
	vector[N] eta   ;
	eta <- x*beta;
	for (i in 1:N) {{
	   mu[i] <- {link_function}(eta[i]);
	}};
	{model_statement}
	{beta_priors}
}}
```
--

Lots to do

- polish the interface
- more models
- nicely formatted output
- saved model objects and predictions

--

Going back to what I said about the R package ecosystem for statistics being ahead of Python...

`rstanarm`

--