# Description: this function takes one or two sets of x/y coordinates and plots them on a worldmap. 
# If createGIF is set to TRUE it will also create a PNG file of the plot
plotMap = function(xBest, yBest, x = xBest, y = yBest, col= "black", colBest = "lightgrey", main = "Plot", rep, createGIF = FALSE){
  plot(newmap, main = main, cex.main=1.5)
  lines(xBest,yBest, col = colBest, cex = .6, lwd = 5)
  lines(x, y, col = "black", cex = .6)
  points(x, y, col = "red", cex = .7, pch = 20)
  
  # Some deliberate duplication of code, as base plot does not let me create a single object for this combined plot
  if (createGIF){
    png(paste0(str_pad(rep, 3, pad = 0),'.png'), 1280, 720)
    plot(newmap, main = main, cex.main = 1.5)
    lines(xBest,yBest, col = colBest, cex = .6, lwd = 5)
    lines(x, y, col = "black", cex = .6)
    points(x, y, col = "red", cex = .7, pch = 20)
    dev.off()
  }
}

# Delay loop to allow plot to print
delayLoop = function(seconds){
  date_time <- Sys.time()
  while((as.numeric(Sys.time()) - as.numeric(date_time)) < seconds){}
}

# This function takes a distance matrix, a vector of coordinates and settings and outputs a tour.
# Intermediate solutions are plotted on a map
solveTspByExtension = function(distance, coords, settings){
  # Read settings
  random = settings[["random"]]
  rclSize = settings[["rclSize"]]
  nRepetitions = settings[["nRepetitions"]]
  twoOpt = settings[["twoOpt"]]
  createGIF = settings[["createGIF"]]
  nSeconds = settings[["nSeconds"]]
  
  # Initialize
  nCities = nrow(distance)
  visited = rep(FALSE, nCities)
  currentNode = 1
  tour = currentNode
  visited[currentNode] = TRUE
  
  # Run algorithm
  for(iter in 1:(nCities - 1)){
    nOptions = nCities - iter
    rcl = matrix(0, nOptions, 2)
    option = 1
    
    # Fill Restricted Candidate List
    for(i in 1:nCities){
      if( ! visited[i] ){
        rcl[option, 1] = distance[currentNode, i]
        rcl[option, 2] = i
        option = option + 1
      }
    }
    
    # Pick final node if 1 left
    if(nOptions == 1){
      bestNode = rcl[nOptions, 2]
    }
    # I multiple left, use Restricted Candidate List
    else {
      rcl = rcl[order(rcl[, 1]), ]
      nOptions = min(rclSize, nCities - iter)
      if(random){
        # If randomized NN pick randomly from rcl
        index <- sample.int(nOptions, 1, replace=TRUE)
        bestNode = rcl[index, 2]
      }
      else {
        # Else select best node
        index <- 1
        bestNode = rcl[index, 2]
      }
    }
    
    # Add the selected node to the tour
    visited[bestNode] = TRUE
    tour[iter + 1] = bestNode
    
    # Update the current node
    currentNode = bestNode
    
    # Plot partial tour
    if(nRepetitions == 1 && !twoOpt){
      x = matrix(-1, nCities)
      y = matrix(-1, nCities)
      tour[nCities + 1] = 1
      
      for(i in 1:nCities){
        x[i] = coords[tour[i], 2]
        y[i] = coords[tour[i], 3]
      }
      
      plotMap(xBest = x, yBest = y, colBest = "blue", 
              main = paste0(settingname, "\n", iter+1, " - ", cityNames[bestNode]), 
              rep = iter, createGIF = createGIF)
      delayLoop(nSeconds)
    }
  }
  tour[nCities + 1] = 1
  return(tour)
  
}

# This function takes a distance matrix, an initial tour and settings and outputs a tour.
solveTspBy2Opt = function(distance, initialTour, settings){
  # Read settings
  random = settings[["random"]]
  rclSize = settings[["rclSize"]]
  nRepetitions = settings[["nRepetitions"]]
  twoOpt = settings[["twoOpt"]]
  createGIF = settings[["createGIF"]]
  nSeconds = settings[["nSeconds"]]
  
  # Initialize
  TwoOptRep = 100
  
  # Run algorithm
  for(lsRep in 1:TwoOptRep){
    change = FALSE
    for(i in 1:(nCities-2)){
      for(j in (i + 2):(nCities)){
        currentCosts = distance[initialTour[i], initialTour[i + 1]] + distance[initialTour[j], initialTour[j + 1]]
        newCosts = distance[initialTour[i], initialTour[j]] + distance[initialTour[i + 1], initialTour[j + 1]]
        difference = newCosts - currentCosts
        if(difference < 0){
          initialTour[(i + 1):j] = rev(initialTour[(i + 1):j])
          change = TRUE
        }
      }
    }
    if(!change){
      break
    }
  }
  tour = initialTour
  return(tour)
}

  