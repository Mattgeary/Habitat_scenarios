library(ROCR)
library(vcd)
library(boot) 
work <- "/home/alan/Desktop/Res_28_5m/max_full/Model_tests"
max_out <- "/home/alan/Desktop/Res_28_5m/max_full"

std.e <- function(x){
		 sd(x)/sqrt(length(x))
	}
confusion <- function(thresh) {
     return(cbind(c(length(testpp[testpp>=thresh]), length(testpp[testpp<thresh])),
                  c(length(bb[bb>=thresh]), length(bb[bb<thresh]))))
   }
mykappa <- function(thresh) {
     return(Kappa(confusion(thresh)))
   }

mybinomial <- function(thresh) {
     conf <- confusion(thresh)
     trials <- length(testpp)
     return(binom.test(conf[[1]][[1]], trials, conf[[1,2]] / length(bb), "greater"))
   }

TSS <- function(confusion) {
	a <- confusion[1,1]
	b <- confusion[1,2]
	c <- confusion[2,1]
	d <- confusion[2,2]
	return(((a*d)-(b*c))/((a+c)*(b+d)))
    }

setwd(max_out)

test.results <- data.frame("AUC"  = numeric(10), "TSS" = numeric(10))

for(i in 0:9){
	presence <- read.csv(paste("species", i, "samplePredictions.csv", sep="_"))
	background  <- read.csv(paste("species", i, "backgroundPredictions.csv", sep="_"))
	pp <- presence$Logistic.prediction
	testpp <- pp[presence$Test.or.train=="test"]
	trainpp <- pp[presence$Test.or.train=="train"]
	bb <- background$logistic
	combined <- c(testpp, bb)
	label <- c(rep(1, length(testpp)), rep(0, length(bb)))
	pred <- prediction(combined, label)
	perf <- performance(pred, "tpr", "fpr")
	setwd(work)
	png(paste("species", i, "ROC.png", sep="_"))
	plot(perf, colorize=T)
	dev.off()
	setwd(max_out)
	test.results$AUC[i+1] <- performance(pred, "auc")@y.values[[1]] 
	fpr = perf@x.values[[1]]
	tpr = perf@y.values[[1]]
	sum = tpr + (1-fpr)
	index = which.max(sum)
	cutoff = perf@alpha.values[[1]][[index]]
	conf <- confusion(cutoff)
	test.results$TSS[i+1] <- TSS(conf)
}

avg.results <- data.frame("Test" = c("AUC", "TSS"), "Score" = c(round(mean(test.results$AUC), 3), round(mean(test.results$TSS), 3)), "S.E" = c(round(std.e(test.results$AUC), 3), round(std.e(test.results$TSS), 3)))

setwd(work)
write.csv(avg.results, "MaxEnt_tests.csv", row.names=F)

