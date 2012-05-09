library(raster)

bin <- paste(getwd(), "Binary", sep="/")

prop <- paste(getwd(), "Proportion", sep="/")

# Hab 1
setwd(bin)
map <- raster("bin_1.asc")
map <- focal(map, w=71, mean)

setwd(prop)
writeRaster(map, "Hab_1.asc")

# Hab 2
setwd(bin)
map <- raster("bin_2.asc")
map <- focal(map, w=71, mean)

setwd(prop)
writeRaster(map, "Hab_2.asc")

# Hab 3
setwd(bin)
map <- raster("bin_3.asc")
map <- focal(map, w=71, mean)

setwd(prop)
writeRaster(map, "Hab_3.asc")

# Hab 4
setwd(bin)
map <- raster("bin_4.asc")
map <- focal(map, w=71, mean)

setwd(prop)
writeRaster(map, "Hab_4.asc")

# Hab 5
setwd(bin)
map <- raster("bin_5.asc")
map <- focal(map, w=71, mean)

setwd(prop)
writeRaster(map, "Hab_5.asc")

# Hab 6
setwd(bin)
map <- raster("bin_6.asc")
map <- focal(map, w=71, mean)

setwd(prop)
writeRaster(map, "Hab_6.asc")

