---
title: "Stuff"
layout: post
category: posts
draft: true
---

![plot of chunk unnamed-chunk-1](/images/posts/interaction-or-not/unnamed-chunk-1.png) 


```r
library(xtable)
print(xtable(uniques, align=rep("c", 4)), type="html", include.rownames=FALSE)
```

<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Wed Jan 14 09:46:24 2015 -->
<TABLE border=1>
<TR> <TH> X1 </TH> <TH> X2 </TH> <TH> Y </TH>  </TR>
  <TR> <TD align="center"> A </TD> <TD align="center"> C </TD> <TD align="center"> 0 + very small noise </TD> </TR>
  <TR> <TD align="center"> B </TD> <TD align="center"> D </TD> <TD align="center"> 12 + very small noise </TD> </TR>
  <TR> <TD align="center"> B </TD> <TD align="center"> C </TD> <TD align="center"> 10 + very small noise </TD> </TR>
  <TR> <TD align="center"> A </TD> <TD align="center"> D </TD> <TD align="center"> ? </TD> </TR>
   </TABLE>



```r
# test <- expand.grid(X1 = c("A", "B"),  X2 = c("C", "D"))
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
