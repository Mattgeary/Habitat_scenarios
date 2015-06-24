work <- getwd()

gc()
output.2 <- paste(getwd(), "Scenario_2", sep="/")

pres.abs <- data.frame("1st"=numeric(models), "Median"=numeric(models), "3rd"=numeric(models))

cl <- makeCluster(3)
registerDoParallel(cl)

foreach(j = 1:models) %dopar% {

library(raster)
library(dismo)
library(ROCR)

# Read in potential area layer

potential <- raster(paste(getwd(), "Binary/bin_3.asc", sep="/"),  crs=BNG)

rcl <- matrix(c(-1,0.7,NA,0.8,1.2,0), nrow=2, ncol=3, byrow=T)
potential.0 <- reclassify(potential, rcl)

rnd.pts <- randomPoints(potential.0, 10)
rnd.pts <- as.data.frame(rnd.pts)
potential.pts <- rasterize(rnd.pts, potential, background=0)
potential.pts <- potential.0 + potential.pts
projection(potential.pts) <- BNG
rm(potential)

iterations <- 50
p.trans <- 0.25
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
	if(cellStats(new.hab, sum) <= 100118.3) new.hab <- f.Exp(new.hab, potential.pts, p.trans)
	else new.hab <- new.hab
    }

dir.create(paste(getwd(), "/Scenario_2/run_", j, sep=""))

rcl.na <- matrix(c(NA, NA, 0), nrow=1, ncol=3, byrow=T)
new.hab <- reclassify(new.hab, rcl.na)

hab.2 <- raster(paste(getwd(), "Binary/bin_2.asc", sep="/"))
hab.2 <- hab.2 + new.hab
hab.2 <- reclassify(hab.2, rcl.na)
projection(hab.2) <- BNG
hab.2 <- focal(hab.2, w = matrix(c(rep(1, 5041)), mean, na.rm=T, pad=T)
setwd(output.2)
writeRaster(hab.2, paste(paste(getwd(), "/run_", j, sep=""), "/hab_2.asc", sep=""), overwrite=T)
rm(hab.2)
setwd(work)

hab.3 <- raster(paste(getwd(), "Binary/bin_3.asc", sep="/"))
hab.3 <- hab.3 - new.hab
hab.3 <- reclassify(hab.3, rcl.na)
projection(hab.3) <- BNG
hab.3 <- focal(hab.3, w = matrix(c(rep(1, 5041)), mean, na.rm=T, pad=T)
setwd(output.2)
writeRaster(hab.3, paste(paste(getwd(), "/run_", j, sep=""), "/hab_3.asc", sep=""), overwrite=T)
rm(hab.3)
setwd(work)

gc()
env.l.new <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), crs=BNG), raster(paste(getwd(), paste("Scenario_2/run_", j, sep=""), "hab_2.asc", sep="/"), crs=BNG), raster(paste(getwd(), paste("Scenario_2/run_", j, sep=""), "hab_3.asc", sep="/"), crs=BNG), raster(paste(getwd(), "Proportion/hab_4.asc", sep="/"), crs=BNG), raster(paste(getwd(), "Proportion/hab_5.asc", sep="/"), crs=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), crs=BNG), raster("studyareadem.asc", crs=BNG))

pred <- predict(max_base, env.l.new)

writeRaster(pred, filename=(paste(getwd(), "Scenario_2", paste("pred_map_REVISIONS_NULL", j, ".grd", sep= ""), sep="/")), overwrite=T)
rm(env.l.new)
gc()

pa <- reclassify(pred, rcl.1)
pres.abs[j,1] <- cellStats(pa, mean)
pa <- reclassify(pred, rcl.med)
pres.abs[j,2] <- cellStats(pa, mean)
pa <- reclassify(pred, rcl.3)
pres.abs[j,3] <- cellStats(pa, mean)
rm(pa)

}

stopCluster(cl)

setwd(paste(getwd(), "Max_revisions_NULL", sep="/"))
write.csv(pres.abs, "Scenario_2_REVISIONS_NULL.csv", row.names=F)
setwd(work)
