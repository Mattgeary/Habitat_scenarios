gc()
output.3 <- paste(getwd(), "Scenario_3", sep="/")

for(j in 1:models){

# Read in potential area layer

potential <- raster(paste(getwd(), "Binary/bin_2.asc", sep="/"),  proj4string="BNG")

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

potential <- raster(paste(getwd(), "Binary/bin_4.asc", sep="/"),  proj4string="BNG")

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
	if(cellStats(new.hab.2, sum) <= 6677.85) new.hab.2 <- f.Exp(new.hab.2, potential.pts, p.trans)
	else new.hab.2 <- new.hab.2
    }

dir.create(paste(getwd(), "/Scenario_3/run_", j, sep=""))

rcl.na <- matrix(c(NA, NA, 0), nrow=1, ncol=3, byrow=T)
new.hab.1 <- reclass(new.hab.1, rcl.na)
new.hab.2 <- reclass(new.hab.2, rcl.na)

hab.2 <- raster(paste(getwd(), "Binary/bin_2.asc", sep="/"))
hab.2 <- hab.2 - new.hab.1
hab.2 <- reclass(hab.2, rcl.na)
projection(hab.2) <- BNG
hab.2 <- focal(hab.2, w=93, mean, na.rm=T, pad=T)
setwd(output.3)
writeRaster(hab.2, paste(paste(getwd(), "/run_", j, sep=""), "/hab_2.asc", sep=""), overwrite=T)
rm(hab.2)
setwd(work)

hab.4 <- raster(paste(getwd(), "Binary/bin_4.asc", sep="/"))
hab.4 <- hab.4 - new.hab.2
hab.2 <- reclass(hab.2, rcl.na)
projection(hab.4) <- BNG
hab.4 <- focal(hab.4, w=93, mean, na.rm=T, pad=T)
setwd(output.3)
writeRaster(hab.4, paste(paste(getwd(), "/run_", j, sep=""), "/hab_4.asc", sep=""), overwrite=T)
rm(hab.4)
setwd(work)

hab.3 <- raster(paste(getwd(), "Binary/bin_3.asc", sep="/"))
hab.3 <- hab.3 + new.hab.1 + new.hab.2
hab.2 <- reclass(hab.2, rcl.na)
projection(hab.3) <- BNG
hab.3<- focal(hab.3, w=93, mean, na.rm=T, pad=T)
setwd(output.3)
writeRaster(hab.3, paste(paste(getwd(), "/run_", j, sep=""), "/hab_3.asc", sep=""), overwrite=T)
rm(hab.3)
setwd(work)

gc()
env.l.new <- stack(raster(paste(getwd(), "Proportion/hab_1.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), paste("Scenario_3/run_", j, sep=""), "hab_2.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), paste("Scenario_3/run_", j, sep=""), "hab_3.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), paste("Scenario_3/run_", j, sep=""), "hab_4.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_5.asc", sep="/"), proj4string=BNG), raster(paste(getwd(), "Proportion/hab_6.asc", sep="/"), proj4string=BNG), raster("studyareadem.asc", proj4string=BNG))

pred <- predict(max_base, env.l.new)
rm(env.l.new)
gc()
writeRaster(pred, filename=(paste(getwd(), "Scenario_3", paste("pred_map", j, ".grd", sep= ""), sep="/")), overwrite=T)

rm(pred)

}

pres.abs <- numeric(10)

BK.pres <- read.csv("BK_pres.csv")

env.l.base <- raster(paste(getwd(), "base_env.grd", sep="/"))

base.map <- raster(paste(getwd(), "base_map.grd", sep="/"))

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

rm(env.l.base, base.map, BK.pres, bg, pred, perf, fpr, tpr, sum, index)

rcl <- matrix(c(0, cutoff-0.0001, 0, cutoff, 1, 1), nrow=3, ncol=3, byrow=T)

for(i in 1:10){

pred.map <- raster(paste(getwd(), "Scenario_3", paste("pred_map", i, ".grd", sep= ""), sep="/"))
pa <- reclass(pred.map, rcl)

pres.abs[i] <- cellStats(pa, mean)

}

write.csv(pres.abs, "Scenario_3.csv", row.names=F)
rm(pres.abs, rcl, pred.map, pa, pres.abs)
