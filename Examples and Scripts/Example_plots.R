par(mfcol=c(4,2))
iterations <- 50
p.trans <- 0.1
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)

iterations <- 50
p.trans <- 0.25
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp(new.hab, potential.pts, p.trans)
	else new.hab <- new.hab
}
plot(new.hab)

iterations <- 50
p.trans <- 0.5
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)

iterations <- 50
p.trans <- 0.75
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)


iterations <- 50
p.trans <- 0.1
new.hab <- f.Exp(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp.5(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)

iterations <- 50
p.trans <- 0.25
new.hab <- f.Exp.5(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp.5(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)

iterations <- 50
p.trans <- 0.5
new.hab <- f.Exp.5(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp.5(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)


iterations <- 50
p.trans <- 0.75
new.hab <- f.Exp.5(potential.pts, potential.pts, p.trans)
for(i in 1:iterations){
  if(cellStats(new.hab, sum) <= 15324.9) new.hab <- f.Exp.5(new.hab, potential.pts, p.trans)
  else new.hab <- new.hab
}
plot(new.hab)