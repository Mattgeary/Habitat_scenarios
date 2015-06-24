library(raster)
library(dismo)
library(ROCR)
work <- getwd()

BNG <- CRS("+init=epsg:27700")

models <- 30
# iterations <- 50

# Model of black grouse habitat suitability in 1994

BK.pres <- read.csv("BK_pres.csv")

env.l.base <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

writeRaster(env.l.base, filename=(paste(getwd(), "base_env_REVISIONS_AIC.grd", sep="/")), overwrite=T)

max_base <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Max_revisions_AIC', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Max_revisions_AIC', 'betamultiplier=7')) 

base.map <- predict(max_base, env.l.base)
writeRaster(base.map, filename=(paste(getwd(), "base_map_REVISIONS_AIC.grd", sep="/")), overwrite=T)

BK.sp <- SpatialPoints(BK.pres, proj4string=BNG)
BK.scores <- extract(base.map, BK.sp)
cutoff.1 <- summary(BK.scores)[[2]]
cutoff.med <- summary(BK.scores)[[3]] 
cutoff.3 <- summary(BK.scores)[[5]]

#bg <- randomPoints(env.l.base, 1000)
#pres.pp <- extract(base.map, BK.pres)
#bg.pp <- extract(base.map, bg)
#combined <- c(pres.pp, bg.pp)
#label <- c(rep(1,length(pres.pp)),rep(0,length(bg.pp)))

#pred <- prediction(combined, label)                
#perf <- performance(pred, "tpr", "fpr")
#fpr <- perf@x.values[[1]]
#tpr <- perf@y.values[[1]]
#sum.v <- tpr + (1-fpr)
#index <- which.max(sum.v)
#cutoff <- perf@alpha.values[[1]][[index]]

rcl.1 <- matrix(c(0, cutoff.1-0.0001, 0, cutoff.1, 1, 1), nrow=3, ncol=3, byrow=T)
rcl.med <- matrix(c(0, cutoff.med-0.0001, 0, cutoff.med, 1, 1), nrow=3, ncol=3, byrow=T)
rcl.3 <- matrix(c(0, cutoff.3-0.0001, 0, cutoff.3, 1, 1), nrow=3, ncol=3, byrow=T)

pa.1 <- reclassify(base.map, rcl.1)
pa.med <- reclassify(base.map, rcl.med)
pa.3 <- reclassify(base.map, rcl.3)
rm(base.map)
max_scores <- data.frame("Model"=c("1st", "Median", "3rd"),"Proportion"=numeric(3), "Cutoff"=numeric(3))
max_scores[1,3] <- cutoff.1
max_scores[2,3] <- cutoff.med
max_scores[3,3] <- cutoff.3
max_scores[1,2] <- cellStats(pa.1, mean)
max_scores[2,2] <- cellStats(pa.med, mean)
max_scores[3,2] <- cellStats(pa.3, mean)


setwd(paste(getwd(), "Max_revisions_AIC", sep="/"))

write.csv(max_scores, "max_models_REVISIONS_AIC.csv", row.names=F)

setwd(work)

source("Sim_scenario_1_REVISIONS_AIC.R")

source("Sim_scenario_2_REVISIONS_AIC.R")

source("Sim_scenario_3_REVISIONS_AIC.R")

source("Sim_scenario_6_REVISIONS_AIC.R")

source("Sim_scenario_7_REVISIONS_AIC.R")

