library(raster)

map1 <- raster("C:/Users/Alan/Desktop/PAT V2/example_range/matt_eg.txt")
plot(map1)

#create a 3x3 function to count the number of 'black' pixels around focal pixel
pix9<-matrix(c(1,1,1,1,1,1,1,1,1), nrow=3)

map2 <- (focal(map1, w=pix9))
freq(map2)
plot(map2)

iterations<-10
for (i in 1:iterations) {
 map2 <- (focal(map2, w=pix9))
 map2[map2<threshold]<-0
 map2[map2>=threshold]<-1
 # the freq and plot functions are only needed for debugging
 freq(map2)
 plot(map2)
}

#this is a 5 x 5 function which allows a spread of 2 pixels
#pix25<-matrix(c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), nrow=5)
#map2 <- focal(map1, w=pix25)