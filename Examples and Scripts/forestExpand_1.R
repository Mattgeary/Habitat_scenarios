forestExpand.1 <- function(mat.in, ynum, xnum, p.trans) {
  z <- matrix(0, nrow=ynum, ncol=xnum)
  y <- matrix(0, nrow=ynum, ncol=xnum)
  #calculate transition matrix
  for(i in 1:xnum){
   for(j in 1:ynum){
    if(!is.na(mat.in[i,j])){ 
     if(mat.in[i,j]<1 && !is.nan(mat.in[i,j])){
        if(i>1 && j>1 && i<xnum && j<ynum) {
          num.adj <- 0
          num.adj <- num.adj + sum(mat.in[(i-1),(j-1):(j+1)] +
                                   mat.in[(i+1),(j-1):(j+1)] +
                                   mat.in[i,(j-1)] + 
                                   mat.in[i,(j+1)], na.rm=T)
          if(num.adj>0.99) num.adj<-0.99
          z[i,j]<-rbinom(1,1,prob=num.adj*p.trans)
          #if(z[i,j]!=0 && z[i,j]!=1 ) z[i,j]<-0
          
        }
      } 
     }
    }
  }
  return(y <- mat.in + z)
}