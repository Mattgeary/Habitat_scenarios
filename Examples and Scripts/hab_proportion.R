library(raster)

bin <- paste(getwd(), "Binary", sep="/")
prop <- paste(getwd(), "Proportion", sep="/")


setwd(bin)
b1 <- raster("bin_1.asc")
b1 <- focal(b1, mean, w=93, na.rm=T, pad=T)
setwd(prop)
projection(b1) <- BNG
writeRaster(b1, "hab_1.asc", overwrite=T)
rm(b1)

setwd(bin)
b1 <- raster("bin_2.asc")
b1 <- focal(b1, mean, w=93, na.rm=T, pad=T)
setwd(prop)
projection(b1) <- BNG
writeRaster(b1, "hab_2.asc", overwrite=T)
rm(b1)

setwd(bin)
b1 <- raster("bin_3.asc")
b1 <- focal(b1, mean, w=93, na.rm=T, pad=T)
setwd(prop)
projection(b1) <- BNG
writeRaster(b1, "hab_3.asc", overwrite=T)
rm(b1)

setwd(bin)
b1 <- raster("bin_4.asc")
b1 <- focal(b1, mean, w=93, na.rm=T, pad=T)
setwd(prop)
projection(b1) <- BNG
writeRaster(b1, "hab_4.asc", overwrite=T)
rm(b1)

setwd(bin)
b1 <- raster("bin_5.asc")
b1 <- focal(b1, mean, w=93, na.rm=T, pad=T)
setwd(prop)
projection(b1) <- BNG
writeRaster(b1, "hab_5.asc", overwrite=T)
rm(b1)

setwd(bin)
b1 <- raster("bin_6.asc")
b1 <- focal(b1, mean, w=93, na.rm=T, pad=T)
setwd(prop)
projection(b1) <- BNG
writeRaster(b1, "hab_6.asc", overwrite=T)
rm(b1)

setwd(scenarios)
