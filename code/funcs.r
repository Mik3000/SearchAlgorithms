# plot worldmap with route per iteration and best route
plotMap = function(xBest, yBest, 
                   x = xBest, 
                   y = yBest, 
                   col= "black", 
                   colBest = "lightgrey", 
                   main = "Plot", rep,
                   createGIF = FALSE){
  plot(newmap, main = main, cex.main=1.5)
  lines(xBest,yBest, col = colBest, cex = .6, lwd = 5)
  lines(x, y, col = "black", cex = .6)
  points(x, y, col = "red", cex = .7, pch = 20)
  
  # Some deliberate duplication of code :-)
  if (createGIF){
    png(paste0(str_pad(rep, 3, pad = 0),'.png'),1280,720)
    plot(newmap, main = main, cex.main=1.5)
    lines(xBest,yBest, col = colBest, cex = .6, lwd = 5)
    lines(x, y, col = "black", cex = .6)
    points(x, y, col = "red", cex = .7, pch = 20)
    dev.off()
  }
}

# delay loop to allow plot to print
delayLoop = function(seconds){
  
  date_time<-Sys.time()
  while((as.numeric(Sys.time()) - as.numeric(date_time))<seconds){}
}

