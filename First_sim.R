library(raster)
library(dismo)

BNG <- CRS("+init=epsg:27700")

f.prob <- function(x, p.trans){
+          x*p.trans
+ }

f.bin <- function(x){
    if(!is.na(x)) x <- rbinom(1,1,x)
    else x <- NA
 }

f.correct <- function(x){
  if(!is.na(x) && x > 1) x <- 1
  else x
}

### Needs fixing, currently changes NAs

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

env.l.base <- stack(raster(paste(getwd(), "Env_94/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

max_base <- maxent(env.l.base, BK.pres, args=c("replicates=10", "replicatetype=crossvalidate", "outputgrids=FALSE"))

base.map <- predict(max_base, env.l.base

# Read in potential area layer

potential <- raster(paste(getwd(), "Potential/Scenario_6.asc", sep="/"),  proj4string="BNG")

rcl <- matrix(c(0.8,1.2,0), nrow=1, ncol=3, byrow=T)
potential.0 <- reclass(potential, rcl)

rnd.pts <- randomPoints(potential, 50)
rnd.pts <- as.data.frame(rnd.pts)
potential.pts <- rasterize(rnd.pts, potential, background=0)
potential.pts <- potential.0 + potential.pts
projection(potential.pts) <- BNG
rm(potential)

## Iterative forest growth. Need percentage value to stop.

iterations <- 50
p.trans <- 0.25
new.hab <- f.Env(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
	if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp(new.hab, potential.pts  p.trans)
	else newhab <- new.hab
}

######
# Need to create proportional habitat data
#
# May need to alter so that scenarios can be set up independently
#
######

env.l.new <- stack(raster(paste(getwd(), "Env_94/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "scot_test/hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "scot_test/hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "scot_test/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Env_94/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

