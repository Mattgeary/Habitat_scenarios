install.packages("raster", dependencies=T)
library(raster)

#make spatial data
cols<-20
rows<-20
myForest0<-matrix(rbinom(400,1,prob=0.03),nrow=rows, ncol=cols)

#initialize future gens to 0
myForest1<-matrix(0, nrow=rows, ncol=cols)
myForest2<-matrix(0, nrow=rows, ncol=cols)
myForest3<-matrix(0, nrow=rows, ncol=cols)
  
#put in raster format
myForestRast0 <- raster(myForest0)
plot(myForestRast0)

#transition probability
#the cum. prob of bare land near forest edge becoming forest
myProbability <- 0.25   

forestExpand <- function(mat.in, ynum, xnum, p.trans) {
  z <- matrix(0, nrow=ynum, ncol=xnum)
  y <- matrix(0, nrow=ynum, ncol=xnum)
  #calculate transition matrix
  for(i in 1:xnum){
   for(j in 1:ynum){
     if(mat.in[i,j]<1 && !is.nan(mat.in[i,j])){
        if(i>1 && j>1 && i<xnum && j<ynum) {
          num.adj <- 0
          num.adj <- num.adj + sum(mat.in[(i-1),(j-1):(j+1)] +
                                   mat.in[(i+1),(j-1):(j+1)] +
                                   mat.in[i,(j-1)] + 
                                   mat.in[i,(j+1)])
          if(num.adj>0.99) num.adj<-0.99
          z[i,j]<-rbinom(1,1,prob=num.adj*p.trans)
          #if(z[i,j]!=0 && z[i,j]!=1 ) z[i,j]<-0
          
        }
      } 
     
    }
  }
  return(y <- mat.in + z)
}

x<-NaN
!is.nan(x)

#run the function
myForest1<-forestExpand(mat.in=myForest0, ynum=rows, xnum=cols, 
             p.trans=myProbability)
#plot gen 1
myForestRast1 <- raster(myForest1)
plot(myForestRast1)

#gen2
myForest2<-forestExpand(mat.in=myForest1, ynum=rows, xnum=cols, 
             p.trans=myProbability)

myForestRast2 <- raster(myForest2)
plot(myForestRast2)

#gen3
myForest3<-forestExpand(mat.in=myForest2, ynum=rows, xnum=cols, 
             p.trans=myProbability)

myForestRast3 <- raster(myForest3)
plot(myForestRast3)

# Set up par
par(bty="l"); par(ps=10)
par(mfrow=c(2,2))           
plot(myForestRast0)
plot(myForestRast1)
plot(myForestRast2)
plot(myForestRast3)
main("Transition probability = 0.25")
