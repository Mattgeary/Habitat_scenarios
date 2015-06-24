library(raster)
library(dismo)
library(ROCR)
work <- getwd()

BNG <- CRS("+init=epsg:27700")

# Model of black grouse habitat suitability in 1994

BK.pres <- read.csv("BK_pres.csv")

env.l.base <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

#writeRaster(env.l.base, filename=(paste(getwd(), "base_env.grd", sep="/")), overwrite=T)

# Betas 1, 2, 3, 5, 7, 9, 10, 11, 13, 15, 17, and 19

max.beta.1 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_1', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_1', 'outputformat=raw', 'betamultiplier=1')) 
beta.1.map <- predict(max.beta.1, env.l.base)
setwd(paste(work, "Beta_tests/Beta_1", sep="/"))
writeRaster(beta.1.map, "beta_1.asc")
setwd(work)

max.beta.2 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_2', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_2', 'outputformat=raw', 'betamultiplier=2')) 
beta.2.map <- predict(max.beta.2, env.l.base)
setwd(paste(work, "Beta_tests/Beta_2", sep="/"))
writeRaster(beta.2.map, "beta_2.asc")
setwd(work)

max.beta.3 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_3', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_3', 'outputformat=raw', 'betamultiplier=3')) 
beta.3.map <- predict(max.beta.3, env.l.base)
setwd(paste(work, "Beta_tests/Beta_3", sep="/"))
writeRaster(beta.3.map, "beta_3.asc")
setwd(work)

max.beta.5 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_5', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_5', 'outputformat=raw', 'betamultiplier=5')) 
beta.5.map <- predict(max.beta.5, env.l.base)
setwd(paste(work, "Beta_tests/Beta_5", sep="/"))
writeRaster(beta.5.map, "beta_5.asc")
setwd(work)

max.beta.7 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_7', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_7', 'outputformat=raw', 'betamultiplier=7')) 
beta.7.map <- predict(max.beta.3, env.l.base)
setwd(paste(work, "Beta_tests/Beta_7", sep="/"))
writeRaster(beta.3.map, "beta_7.asc")
setwd(work)

max.beta.9<- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_9', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_9', 'outputformat=raw', 'betamultiplier=9')) 
beta.9.map <- predict(max.beta.9, env.l.base)
setwd(paste(work, "Beta_tests/Beta_9", sep="/"))
writeRaster(beta.9.map, "beta_9.asc")
setwd(work)

max.beta.10 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_10', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_10', 'outputformat=raw', 'betamultiplier=10')) 
beta.10.map <- predict(max.beta.10, env.l.base)
setwd(paste(work, "Beta_tests/Beta_10", sep="/"))
writeRaster(beta.10.map, "beta_10.asc")
setwd(work)

max.beta.11 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_11', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_11', 'outputformat=raw', 'betamultiplier=11')) 
beta.11.map <- predict(max.beta.11, env.l.base)
setwd(paste(work, "Beta_tests/Beta_11", sep="/"))
writeRaster(beta.11.map, "beta_11.asc")
setwd(work)

max.beta.13 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_13', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_13', 'outputformat=raw', 'betamultiplier=13')) 
beta.13.map <- predict(max.beta.13, env.l.base)
setwd(paste(work, "Beta_tests/Beta_13", sep="/"))
writeRaster(beta.13.map, "beta_13.asc")
setwd(work)

max.beta.15 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_15', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_15', 'outputformat=raw', 'betamultiplier=15')) 
beta.15.map <- predict(max.beta.15, env.l.base)
setwd(paste(work, "Beta_tests/Beta_15", sep="/"))
writeRaster(beta.15.map, "beta_15.asc")
setwd(work)

max.beta.17 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_17', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_17', 'outputformat=raw', 'betamultiplier=17')) 
beta.17.map <- predict(max.beta.17, env.l.base)
setwd(paste(work, "Beta_tests/Beta_17", sep="/"))
writeRaster(beta.17.map, "beta_17.asc")
setwd(work)

max.beta.19 <- maxent(env.l.base, BK.pres, path='/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_19', args = c('outputgrids=true', 'outputdirectory=/home/alan/Dropbox/Research/Black grouse/Habitat_scenarios/Res_28_5m/Beta_tests/Beta_19', 'outputformat=raw', 'betamultiplier=19')) 
beta.19.map <- predict(max.beta.19, env.l.base)
setwd(paste(work, "Beta_tests/Beta_19", sep="/"))
writeRaster(beta.19.map, "beta_19.asc")
setwd(work)

#base.map <- predict(max_base, env.l.base)


#writeRaster(base.map, filename=(paste(getwd(), "base_map.grd", sep="/")), overwrite=T)


#### AIC calculation code - NEEDS model file as for ENMTools

calAIC <- function(csvfile, grdfile, lambdasfile) {
    nparams = 0
    probsum = 0
    loglikelihood = 0
    AICcscore = 0
    AICscore = 0
    BICscore = 0

    lambdases <- read.csv(lambdasfile, header=FALSE)
    nparams <- nrow(lambdases[lambdases$V2 != 0, ])
    nparams = nparams - 4

    layerRaw <- raster(grdfile)
    probsum <- cellStats(layerRaw, sum)

    points <- read.csv(csvfile)
    npoints <- nrow(points)
    layerValues <- extract(layerRaw, points[, c("LONGITUDE", "LATITUDE")])
    loglikelihood <- sum(log(layerValues / probsum))

    if (nparams >= npoints - 1) {
        AICcscore <- "x"
        AICscore <- "x"
        BICscore <- "x"
    } else {
        AICcscore = (2 * nparams - 2 * loglikelihood) + (2 * (nparams) * (nparams + 1) / (npoints - nparams - 1))
        AICscore = 2 * nparams - 2 * loglikelihood
        BICscore = nparams * log(npoints) - 2 * loglikelihood
    }

    ICs <- c(csvfile, grdfile, loglikelihood, nparams, npoints, AICscore, AICcscore, BICscore)

    return(ICs)
}

getAICs <- function(modelfile) {
    models <- read.csv(modelfile, header=FALSE, as.is=TRUE, col.names=c("csvfile", "grdfile", "lambdasfile"))
    AICs <- mapply(calAIC, models$csvfile, models$grdfile, models$lambdasfile, USE.NAMES=FALSE)
    AICs <- t(AICs)
    colnames(AICs) <- c("Points", "ASCII file", "Log Likelihood", "Parameters", "Sample Size", "AIC score", "AICc score", "BIC score")
    outfile <- gsub(".csv", "_model_select.csv", modelfile)
    write.csv(AICs, outfile, row.names=FALSE)
}

setwd(paste(work, "Beta_tests/AICc_Scores", sep="/"))
getAICs(modelfile = "model_file.csv")
Max.AICc <- read.csv("model_file_model_select.csv")
Max.AICc$d.AICc <- Max.AICc$AICc.score - min(Max.AICc$AICc.score)
setwd(work)
