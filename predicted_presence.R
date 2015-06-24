library(raster)
library(dismo)
library(ROCR)

work <- getwd()

pres.abs <- numeric(10)

BK.pres <- read.csv("BK_pres.csv")

env.l.base <- raster(paste(getwd(), "Scenario_6/base_env.grd", sep="/"))

base.map <- raster(paste(getwd(), "Scenario_6/base_map.grd", sep="/"))

bg <- randomPoints(env.l.base, 1000)
pres.pp <- extract(base.map, BK.pres)
bg.pp <- extract(base.map, bg)
combined <- c(pres.pp, bg.pp)
label <- c(rep(1,length(pres.pp)),rep(0,length(bg.pp)))

pred <- prediction(combined, label)                
perf <- performance(pred, "tpr", "fpr")
fpr <- perf@x.values[[1]]
tpr <- perf@y.values[[1]]
sum <- tpr + (1-fpr)
index <- which.max(sum)
cutoff <- perf@alpha.values[[1]][[index]]

rm(c(env.l.base, base.map, BK.pres, bg, pred, perf, fpr, tpr, sum, index)

rcl <- matrix(c(0, cutoff-0.0001, 0, cutoff, 1, 1), nrow=3, ncol=3, byrow=T)

for(i in 1:10){

pred.map <- raster(paste(getwd(), "Scenario_6", paste("pred_map", i, ".grd", sep= ""), sep="/"))
pa <- reclass(pred.map, rcl)

pres.abs[i] <- cellStats(pa, mean)

}

write.csv(pres.abs, "Scenario_6.csv", row.names=F)


