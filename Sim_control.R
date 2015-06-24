library(raster)
library(dismo)
library(ROCR)
work <- getwd()

BNG <- CRS("+init=epsg:27700")

models <- 30
iterations <- 50
p.trans <- 0.25
n.points <- 20

f.prob <- function(x, p.trans){
          x*p.trans
 }

f.bin <- function(x){
    if(!is.na(x)) x <- rbinom(1,1,x)
    else x <- NA
 }

f.correct <- function(x){
  if(!is.na(x) && x > 1) x <- 1
  else x
}

### Function to grow new habitat

f.Exp <- function(map, base.map, p.trans){
              mat.0 <- as.matrix(map)
               map.t <- focal(map, w=3, sum, na.rm=T, pad=T) 
              map.t <- map.t + base.map
                mat.t <- as.matrix(map.t) 
                mat.prob <- apply(mat.t, c(1,2), f.prob, p.trans=p.trans)
               mat.cor <- mat.0 + mat.prob
              mat.cor <- apply(mat.cor, c(1,2), f.correct)
               mat.new <- apply(mat.cor, c(1,2), f.bin)
               map.new <- raster(mat.new, xmn=xmin(map), xmx=xmax(map), ymn=ymin(map), ymx=ymax(map), crs=paste(projection(map)))
}

# Model of black grouse habitat suitability in 1994

BK.pres <- read.csv("BK_pres.csv")

env.l.base <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

writeRaster(env.l.base, filename=(paste(getwd(), "base_env.grd", sep="/")), overwrite=T)

max_base <- maxent(env.l.base, BK.pres) 


base.map <- predict(max_base, env.l.base)
writeRaster(base.map, filename=(paste(getwd(), "base_map.grd", sep="/")), overwrite=T)

rm(base.map)
rm(env.l.base)

source("Sim_scenario_1.R")

source("Sim_scenario_2.R")

source("Sim_scenario_3.R")

source("Sim_scenario_6.R")

source("Sim_scenario_7.R")

