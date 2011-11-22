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

f.Exp <- function(map, p.trans){
              mat.0 <- as.matrix(map)
               map.t <- focal(map, w=3, sum, na.rm=T, pad=T) 
              map.t <- map.t + map
                mat.t <- as.matrix(map.t) 
                mat.prob <- apply(mat.t, c(1,2), f.prob, p.trans=p.trans)
               mat.cor <- mat.0 + mat.prob
              mat.cor <- apply(mat.cor, c(1,2), f.correct)
               mat.new <- apply(mat.cor, c(1,2), f.bin)
               map.new <- raster(mat.new, xmn=xmin(map), xmx=xmax(map), ymn=ymin(map), ymx=ymax(map), crs=paste(projection(map)))
}

