# We start at the first node
visited = rep(FALSE, nCities)
currentNode = 1
tour = c(currentNode)
visited[currentNode] = TRUE

for(iter in 1:(nCities-1)){
  #browser()
  nOptions = nCities - iter
  rcl = matrix(0, nOptions, 2)
  option = 1
  
  for(i in 1:nCities){
    if( ! visited[i] ){
      # Store the distances in the matrix with options
      rcl[option, 1] = distance[currentNode, i]
      rcl[option, 2] = i
      option = option + 1
    }
  }
  
  if(nOptions == 1){
    bestNode = rcl[nOptions, 2]
    
  }
  else {
    rcl = rcl[order(rcl[,1]),]
    nOptions = min(rclSize, nCities - iter)
    if(random){
      # Order the restriced candidate list and select a random option
      index <- sample.int(nOptions, 1, replace=TRUE)
      bestNode = rcl[index,2]
    }
    else {
      # Select best node
      index <- 1
      bestNode = rcl[index,2]
    }
  }
  
  # Add the selected node to the tour
  visited[bestNode] = TRUE
  tour[iter+1] = bestNode
  
  # Update the current node
  currentNode = bestNode
  
  # Plot partial tour
  if(nRepetitions == 1 && !twoOpt){
    #plot the results of each iteration
    x = matrix(-1, nCities)
    y = matrix(-1, nCities)
    tour[nCities+1] = 1
    
    for(i in 1:nCities){
      x[i] = coords[tour[i], 2]
      y[i] = coords[tour[i], 3]
    }
    plotMap(xBest = x
            , yBest = y
            , colBest = "blue"
            , main = paste0(settings
                            , "\n"
                            , iter+1
                            , " - "
                            , cityNames[bestNode])
            , rep = iter, createGIF = createGIF)
    delayLoop(nSeconds)
  }
}

totalDistance = 0
tour[nCities + 1] = 1

# Calculate total distance of tour
for(i in 1:nCities)
  totalDistance = totalDistance + distance[tour[i],tour[i+1]]

