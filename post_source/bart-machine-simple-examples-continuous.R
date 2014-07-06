library(ggplot2)
library(plyr)
library(bartMachine)

Percentile <- function(p) {
  return(function(x) quantile(x, probs=p))
}


# Continuous Example With Correlated Features
set.seed(0)
sigmaTrue <- 1
nTrain <- 300
coef <- 2

underlying <- runif(nTrain)
train <- data.frame(X1 = underlying + runif(nTrain)*.3, X2 = underlying + runif(nTrain)*.3)
test1 <- merge(data.frame(X1=c(0,.5,1)), data.frame(X2=seq(0,1,by=.05)))
test2 <- merge(data.frame(X1=seq(0,1,by=.05)), data.frame(X2=c(0,.5,1)))

qplot(train$X1, train$X2)
y <- coef*train$X1 + coef*train$X2 + rnorm(nrow(train))*sigmaTrue

# Default bartMachine
bartFit <- bartMachine(X = train, y = y)
posteriorSamples1 <- bart_machine_get_posterior(bartFit, test1)$y_hat_posterior_samples
sampleDF1 <- ldply(1:ncol(posteriorSamples1), function(ixSample) {
  testOneSample <- test1
  testOneSample$SampleY <- posteriorSamples1[,ixSample]
  return(testOneSample)
})  

sampleDFSummary1 <- ddply(sampleDF1, c("X1", "X2"), 
                         summarize, 
                         Percentile10 = Percentile(.1)(SampleY),
                         Percentile50 = Percentile(.5)(SampleY),
                         Percentile90 = Percentile(.9)(SampleY),
                         PosteriorYMean = mean(SampleY),
                         PosteriorYStdDev = sd(SampleY))

ggplot(sampleDFSummary1) + geom_line(aes(color=factor(X1), x=X2, y=PosteriorYMean))
ggplot(sampleDFSummary1) + geom_line(aes(color=factor(X1), x=X2, y=PosteriorYStdDev))
ggplot(sampleDFSummary1) + geom_line(aes(color=factor(X1), x=X2, y=Percentile90-Percentile10))

ggplot(sampleDFSummary1) + geom_line(aes(color=factor(X1), x=X2, y=Percentile50)) +
  geom_ribbon(aes(fill=factor(X1), x=X2, ymin=Percentile10, ymax=Percentile90), alpha=.5)

posteriorSamples2 <- bart_machine_get_posterior(bartFit, test2)$y_hat_posterior_samples
sampleDF2 <- ldply(1:ncol(posteriorSamples2), function(ixSample) {
  testOneSample <- test2
  testOneSample$SampleY <- posteriorSamples2[,ixSample]
  return(testOneSample)
})  

sampleDFSummary2 <- ddply(sampleDF2, c("X1", "X2"), 
                         summarize, 
                         Percentile10 = Percentile(.1)(SampleY),
                         Percentile50 = Percentile(.5)(SampleY),
                         Percentile90 = Percentile(.9)(SampleY),
                         PosteriorYMean = mean(SampleY),
                         PosteriorYStdDev = sd(SampleY))

ggplot(sampleDFSummary2) + geom_line(aes(color=factor(X2), x=X1, y=PosteriorYMean))
ggplot(sampleDFSummary2) + geom_line(aes(color=factor(X2), x=X1, y=PosteriorYStdDev))
ggplot(sampleDFSummary2) + geom_line(aes(color=factor(X2), x=X1, y=Percentile90-Percentile10))

ggplot(sampleDFSummary2) + geom_line(aes(color=factor(X2), x=X1, y=Percentile50)) +
  geom_ribbon(aes(fill=factor(X2), x=X1, ymin=Percentile10, ymax=Percentile90), alpha=.5)



# Continuous Example -- one feature, higher uncertainty in the ends
set.seed(1)
sigmaTrue <- 1
nTrain <- 1000
coef <- 2

train <- data.frame(X1 = rnorm(nTrain))
test <- data.frame(X1=seq(-3,3,by=.05))
y <- coef*train$X1 + rnorm(nrow(train))*sigmaTrue

bartFit <- bartMachine(X = train, y = y)
posteriorSamples <- bart_machine_get_posterior(bartFit, test)$y_hat_posterior_samples

sampleDF <- ldply(1:ncol(posteriorSamples), function(ixSample) {
  testOneSample <- test
  testOneSample$SampleY <- posteriorSamples[,ixSample]
  return(testOneSample)
})  

sampleDFSummary <- ddply(sampleDF, "X1", 
                         summarize, 
                         Percentile10 = Percentile(.1)(SampleY),
                         Percentile50 = Percentile(.5)(SampleY),
                         Percentile90 = Percentile(.9)(SampleY),
                         PosteriorYMean = mean(SampleY),
                         PosteriorYStdDev = sd(SampleY))

ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=PosteriorYMean))
ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=PosteriorYStdDev))
ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=Percentile90-Percentile10))

ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=Percentile50)) +
  geom_ribbon(aes(x=X1, ymin=Percentile10, ymax=Percentile90), alpha=.5) +
  geom_line(aes(x=X1, y=coef*X1), data=train)





# Continuous Example -- ten features, higher uncertainty at the ends
set.seed(1)
sigmaTrue <- 1
nTrain <- 1000
coef <- 2
nCol <- 10

train <- data.frame(matrix(rnorm(nCol*nTrain), ncol=nCol))
test <- data.frame(X1=seq(-3,3,by=.05))
for (i in 2:nCol) test[[paste0("X", i)]] <- 0
y <- rnorm(nrow(train))*sigmaTrue # noise
for (col in names(train)) y <- y + coef*train[[col]]

bartFit <- bartMachine(X = train, y = y)
posteriorSamples <- bart_machine_get_posterior(bartFit, test)$y_hat_posterior_samples

sampleDF <- ldply(1:ncol(posteriorSamples), function(ixSample) {
  testOneSample <- test
  testOneSample$SampleY <- posteriorSamples[,ixSample]
  return(testOneSample)
})  

sampleDFSummary <- ddply(sampleDF, "X1", 
                         summarize, 
                         Percentile10 = Percentile(.1)(SampleY),
                         Percentile50 = Percentile(.5)(SampleY),
                         Percentile90 = Percentile(.9)(SampleY),
                         PosteriorYMean = mean(SampleY),
                         PosteriorYStdDev = sd(SampleY))

ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=PosteriorYMean))
ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=PosteriorYStdDev))

ggplot(sampleDFSummary) + geom_line(aes(x=X1, y=Percentile50)) +
  geom_ribbon(aes(x=X1, ymin=Percentile10, ymax=Percentile90), alpha=.5) +
  geom_line(aes(x=X1, y=coef*X1), data=test)




