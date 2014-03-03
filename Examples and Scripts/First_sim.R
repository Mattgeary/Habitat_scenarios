library(raster)
library(dismo)
work <- getwd()
output.6 <- paste(getwd(), "Scenario_6", sep="/")

BNG <- CRS("+init=epsg:27700")

ind <- rep(1, 10)


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

writeRaster(env.l.new, filename=(paste(getwd(), "Scenario_6/base_env.grd", sep="/")))

max_base <- maxent(env.l.base, BK.pres, args=c("replicates=10", "replicatetype=crossvalidate", "outputgrids=FALSE"))

base.map <- predict(max_base, env.l.base)
writeRaster(base.map, filename=(paste(getwd(), "Scenario_6/base_map.grd", sep="/"))

stackApply(base.map, ind, mean, filename=paste(getwd(), "Scenario_6/mean.base.map", sep="/"), format="ascii)

rm(base.map)
rm(env.l.base)


# Read in potential area layer

potential <- raster(paste(getwd(), "Potential/Scenario_6.asc", sep="/"),  proj4string="BNG")

rcl <- matrix(c(0.8,1.2,0), nrow=1, ncol=3, byrow=T)
potential.0 <- reclass(potential, rcl)

rnd.pts <- randomPoints(potential, 10)
rnd.pts <- as.data.frame(rnd.pts)
potential.pts <- rasterize(rnd.pts, potential, background=0)
potential.pts <- potential.0 + potential.pts
projection(potential.pts) <- BNG
rm(potential)

## Iterative forest growth. Need percentage value to stop.

iterations <- 50
p.trans <- 0.25
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
	if(cellStats(new.hab, sum) <= 1848731) new.hab <- f.Exp(new.hab, potential.pts, p.trans)
	else new.hab <- new.hab
}

hab.3 <- raster(paste(getwd(), "Binary/bin_3.asc", sep="/"))
hab.3 <- hab.3 - new.hab
projection(hab.3) <- BNG
hab.3 <- focal(hab.3, w=93, sum, na.rm=T, pad=T)
setwd(output.6)
writeRaster(hab.3, "hab_3.asc")
rm(hab.3)
setwd(work)

hab.4 <- raster(paste(getwd(), "Binary/bin_4.asc", sep="/"))
hab.4 <- hab.4 - new.hab
projection(hab.4) <- BNG
hab.4 <- focal(hab.4, w=93, sum, na.rm=T, pad=T)
setwd(output.6)
writeRaster(hab.4, "hab_4.asc")
rm(hab.4)
setwd(work)

hab.5 <- raster(paste(getwd(), "Binary/bin_5.asc", sep="/"))
hab.5 <- hab.5 + new.hab
projection(hab.5) <- BNG
hab.5 <- focal(hab.5, w=93, sum, na.rm=T, pad=T)
setwd(output.6)
writeRaster(hab.5, "hab_5.asc", overwrite=T)
rm(hab.5)
setwd(work)

env.l.new <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Scenario_6/hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Scenario_6/hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Scenario_6/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

pred <- predict(max_base, env.l.new)
writeRaster(pred, filename=(paste(getwd(), "Scenario_6/pred_map.grd", sep="/"))

ind <- rep(1, 10)

stackApply(pred, ind, mean, na.rm=T, filename=paste(getwd(), "Scenario_6/new.1.asc", sep="/")
rm(pred)
writeRaster(pred, "Pred_MaxEnt.asc")
