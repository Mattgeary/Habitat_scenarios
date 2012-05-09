gc()
output.6 <- paste(getwd(), "Scenario_6", sep="/")

pres.abs <- data.frame("1st"=numeric(models), "Median"=numeric(models), "3rd"=numeric(models))

for(j in 1:models){

# Read in potential area layer

potential <- raster(paste(getwd(), "Binary/bin_3.asc", sep="/"),  crs=BNG)

rcl <- matrix(c(-1,0.7,NA,0.8,1.2,0), nrow=2, ncol=3, byrow=T)
potential.0 <- reclass(potential, rcl)

rnd.pts <- randomPoints(potential.0, 10)
rnd.pts <- as.data.frame(rnd.pts)
potential.pts <- rasterize(rnd.pts, potential, background=0)
potential.pts <- potential.0 + potential.pts
projection(potential.pts) <- BNG
rm(potential)

iterations <- 50
p.trans <- 0.25
new.hab.1 <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
	if(cellStats(new.hab.1, sum) <= 23856.91) new.hab.1 <- f.Exp(new.hab.1, potential.pts, p.trans)
	else new.hab.1 <- new.hab.1
    }

potential <- raster(paste(getwd(), "Binary/bin_4.asc", sep="/"),  crs=BNG)

rcl <- matrix(c(-1,0.7,NA,0.8,1.2,0), nrow=2, ncol=3, byrow=T)
potential.0 <- reclass(potential, rcl)

rnd.pts <- randomPoints(potential.0, 10)
rnd.pts <- as.data.frame(rnd.pts)
potential.pts <- rasterize(rnd.pts, potential, background=0)
potential.pts <- potential.0 + potential.pts
projection(potential.pts) <- BNG
rm(potential)

iterations <- 50
p.trans <- 0.25
new.hab.2 <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
	if(cellStats(new.hab.2, sum) <= 30035.49) new.hab.2 <- f.Exp(new.hab.2, potential.pts, p.trans)
	else new.hab.2 <- new.hab.2
    }

dir.create(paste(getwd(), "/Scenario_6/run_", j, sep=""))

rcl.na <- matrix(c(NA, NA, 0), nrow=1, ncol=3, byrow=T)
new.hab.1 <- reclass(new.hab.1, rcl.na)
new.hab.2 <- reclass(new.hab.2, rcl.na)

hab.3 <- raster(paste(getwd(), "Binary/bin_3.asc", sep="/"))
hab.3 <- hab.3 - new.hab.1
hab.3 <- reclass(hab.3, rcl.na)
projection(hab.3) <- BNG
hab.3 <- focal(hab.3, w=71, mean, na.rm=T, pad=T)
setwd(output.6)
writeRaster(hab.3, paste(paste(getwd(), "/run_", j, sep=""), "/hab_3.asc", sep=""), overwrite=T)
rm(hab.3)
setwd(work)

hab.4 <- raster(paste(getwd(), "Binary/bin_4.asc", sep="/"))
hab.4 <- hab.4 - new.hab.2
hab.4 <- reclass(hab.4, rcl.na)
projection(hab.4) <- BNG
hab.4 <- focal(hab.4, w=71, mean, na.rm=T, pad=T)
setwd(output.6)
writeRaster(hab.4, paste(paste(getwd(), "/run_", j, sep=""), "/hab_4.asc", sep=""), overwrite=T)
rm(hab.4)
setwd(work)

hab.5 <- raster(paste(getwd(), "Binary/bin_5.asc", sep="/"))
hab.5 <- hab.5 + new.hab.1 + new.hab.2
hab.5 <- reclass(hab.5, rcl.na)
projection(hab.5) <- BNG
hab.5 <- focal(hab.5, w=71, mean, na.rm=T, pad=T)
setwd(output.6)
writeRaster(hab.5, paste(paste(getwd(), "/run_", j, sep=""), "/hab_5.asc", sep=""), overwrite=T)
rm(hab.5)
setwd(work)

gc()
env.l.new <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), crs=BNG), raster(paste(getwd(), "Proportion/hab_2.asc", sep="/"), crs=BNG), raster(paste(getwd(), paste("Scenario_6/run_", j, sep=""), "hab_3.asc", sep="/"), crs=BNG), raster(paste(getwd(), paste("Scenario_6/run_", j, sep=""), "hab_4.asc", sep="/"), crs=BNG), raster(paste(getwd(), paste("Scenario_6/run_", j, sep=""), "hab_5.asc", sep="/"), crs=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), crs=BNG), raster("studyareadem.asc", crs=BNG))

pred <- predict(max_base, env.l.new)

writeRaster(pred, filename=(paste(getwd(), "Scenario_6", paste("pred_map", j, ".grd", sep= ""), sep="/")), overwrite=T)
rm(env.l.new)
gc()

pa <- reclass(pred, rcl.1)
pres.abs[j,1] <- cellStats(pa, mean)
pa <- reclass(pred, rcl.med)
pres.abs[j,2] <- cellStats(pa, mean)
pa <- reclass(pred, rcl.3)
pres.abs[j,3] <- cellStats(pa, mean)
rm(pa)

}

write.csv(pres.abs, "Scenario_6.csv", row.names=F)
