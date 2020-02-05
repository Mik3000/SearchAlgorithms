# This function takes a distance matrix, a vector of coordinates and settings and outputs a tour.
# Also, partial solutions are plotted on a map
solveTspByExtension = function(distance, coords, settings){
  # Read settings
  constructiveHeuristic = settings[["constructiveHeuristic"]]
  localSearch = settings[["localSearch"]]
  random = settings[["random"]]
  rclSize = settings[["rclSize"]]
  nRepetitions = settings[["nRepetitions"]]
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
    candidates = which(!visited)
    candidate_distances = distance[currentNode, candidates]

    # Pick final node if 1 left
    if(nOptions == 1){
      bestNode = candidates
    }
    # If multiple left, use Restricted Candidate List
    else {
      candidate_distances = sort(candidate_distances)
      nOptions = min(rclSize, nCities - iter)
      rcl = candidate_distances[1:nOptions]
      
      if(random){
        # If randomized NN pick randomly from rcl
        randomNode = sample(rcl, 1)
        bestNode = names(randomNode)
      }
      else {
        # Else select best node
        bestNode = names(rcl[1])
      }
    }
    
    # Add the selected node to the tour
    bestNode = as.integer(bestNode)
    visited[bestNode] = TRUE
    tour[iter + 1] = bestNode
    
    # Update the current node
    currentNode = bestNode
    
    # Plot partial tour
    if(plotConstructiveHeuristic){

      x = coords[tour, 2]
      y = coords[tour, 3]
      
      plotMap(xBest = x, yBest = y, colBest = "blue",
              main = paste0(settingname, "\n", iter + 1, " - ", cityNames[bestNode]),
              rep = iter, createGIF = createGIF)
      delayLoop(nSeconds)
    }
  }
  tour[nCities + 1] = 1
  return(tour)
  
}

# This function takes a distance matrix, a vector of coordinates and settings and outputs a tour.
# Also, partial solutions are plotted on a map
solveTspByInsertion = function(distance, coords, settings){
  # Read settings
  random = settings[["random"]]
  rclSize = settings[["rclSize"]]
  nRepetitions = settings[["nRepetitions"]]
  createGIF = settings[["createGIF"]]
  nSeconds = settings[["nSeconds"]]
  
  # Initialize
  nCities = nrow(distance)
  visited = rep(FALSE, nCities)
  currentNode = 1
  tour = currentNode
  visited[currentNode] = TRUE
  nLocationsToVisit = nCities - 1
  
  # Run algorithm
  for(iter in 1:nLocationsToVisit){
    print(iter)
    #browser()
    
    candidates = which(!visited)
    nCandidates = length(candidates)
    bestCandidate = NA
    totalBestPartialTour =NA
    totalBestDistance = Inf
    
    for (i in 1:nCandidates){
      #browser()
      # determine best partial tour for each candidate
      candidate = candidates[i]
      candidateBestDistance = Inf
      candidateBestPartialTour = NA
      tour_length = length(tour)
      
      if(tour_length == 1){
        partialTour = c(tour, candidate)
        distancesPartialTour = distance[head(partialTour, -1), tail(partialTour, -1)]
        candidateBestDistance = sum(distancesPartialTour)
        candidateBestPartialTour = partialTour
      } else {
        for (j in 1:tour_length){
          #browser()
          partialTour = c(head(tour, j), candidate, tail(tour, tour_length - j))
          distancesPartialTour = diag(distance[head(partialTour, -1), tail(partialTour, -1)])
          totalDistance = sum(distancesPartialTour)
          
          if(candidateBestDistance > totalDistance){
            candidateBestDistance = totalDistance
            candidateBestPartialTour = partialTour
          }
        }
      }

    if(candidateBestDistance < totalBestDistance){
      totalBestDistance = candidateBestDistance
      totalBestPartialTour = candidateBestPartialTour
      bestCandidate = candidate
    }
    }
    tour = totalBestPartialTour
    # Add the selected node to the tour
    visited[bestCandidate] = TRUE
    
    # Plot partial tour
    if(plotConstructiveHeuristic){
      
      x = coords[c(tour, tour[1]), 2]
      y = coords[c(tour, tour[1]), 3]
      
      plotMap(xBest = x, yBest = y, colBest = "blue",
              main = paste0(settingname, "\n", iter + 1, " - ", cityNames[bestCandidate]),
              rep = iter, createGIF = createGIF)
      delayLoop(nSeconds)
    }
  }
  tour[nCities + 1] = 1
  return(tour)
  
}

solveTspByGenetic = function(distance, coords, settings){
  # Read settings
  random = settings[["random"]]
  rclSize = settings[["rclSize"]]
  nRepetitions = settings[["nRepetitions"]]
  createGIF = settings[["createGIF"]]
  nSeconds = settings[["nSeconds"]]
  
  # generate population
  citiesToVisit = 2:nCities
  initialPopulationSize = 10
  populationSize = initialPopulationSize
  population = 1:initialPopulationSize
  
  tour = replicate(initialPopulationSize, c(1, sample(citiesToVisit)))
  populationTours = t(matrix(tour, ncol = initialPopulationSize))
  nrep = 5000
  newTours = matrix(NA, nrow = nrep, ncol = nCities)
  populationTours = rbind(populationTours, newTours)
  
  bestChildDistances = rep(NA, nrep)
  
  for (rep in 1:nrep){
    print(paste("rep = ",rep))
    
    # make pairs
    uniqueParents = unique(na.omit(populationTours))
    nUniqueParents = nrow(uniqueParents)
    n_pairs = floor(nUniqueParents/2)
    population = 1:nUniqueParents
    
    fathers = sample(population, n_pairs)
    mothers = sample(population[-fathers], n_pairs)
    
    fatherTour = uniqueParents[fathers, ]
    motherTour = uniqueParents[mothers, ]
    
    # apply cross-over
    crossOverPoint = sample(citiesToVisit[3:nCities - 3], 1)
    fatherSubTour_1 = fatherTour[, 1:crossOverPoint]
    fatherSubTour_2 = fatherTour[, -1:-crossOverPoint]
    
    childTour = matrix(nrow = n_pairs*2, ncol = nCities)
    childTourDistances = rep(NA, n_pairs*2)
    
    for (i in 1:n_pairs){
      #print(paste("i= ",i))
      ind = which(motherTour[i, ] %in% fatherSubTour_2[i, ])
      motherSubTour_1 = motherTour[i, ind]
      child_1 = c(fatherSubTour_1[i, ], motherSubTour_1)
      childTour[i, ] = child_1
      
      tour = child_1
      distances = diag(distance[head(tour, -1), tail(tour, -1)])
      totalDistance = sum(distances)
      childTourDistances[i] = totalDistance
      
      ind = which(motherTour[i, ] %in% fatherSubTour_1[i, ])
      motherSubTour_2 = motherTour[i, ind]
      child_2 = c(motherSubTour_2, fatherSubTour_2[i, ])
      childTour[i + n_pairs, ] = child_2
      
      tour = child_2
      distances = diag(distance[head(tour, -1), tail(tour, -1)])
      totalDistance = sum(distances)
      childTourDistances[i + n_pairs] = totalDistance
      
    }
    
    # select best child
    bestChild = which.min(childTourDistances)
    bestChildDistance = childTourDistances[bestChild]
    bestIter = which.min(bestChildDistances)
    bestChildDistances[rep] = bestChildDistance
    
    # add tour to population
    populationSize = populationSize + 1
    bestChildTour = childTour[bestChild, ]
    populationTours[rep + initialPopulationSize, ] = bestChildTour
    tour = bestChildTour
    
    # Plot partial best tour
    if(plotConstructiveHeuristic){
      
      x = coords[c(bestChildTour, bestChildTour[1]), 2]
      y = coords[c(bestChildTour, bestChildTour[1]), 3]
      
      # best population tour
      #if improvement, plot green lines and replace yBest
      if(bestChildDistance < bestTotalDistance){
        colBest = "green"
        yBest = y
        xBest = x
      } else {
        colBest = "lightgrey"
      }
      
      # Plot the map
      # plotMap(xBest, yBest, x, y, colBest = colBest, 
      #         main = paste(settingname, "\n", "Iteration:", rep, "- ", "Distance:", bestChildDistance, "\n", "bestIteration:", 
      #                      bestIter, "- ", "bestDistance:", bestTotalDistance)
      #         , createGIF = createGIF, rep = rep)
      
      delayLoop(nSeconds)
    }
    
    bestTotalDistance = min(bestChildDistances, na.rm = TRUE)
  }
  tour = c(populationTours[which.min(bestChildDistances), ],1)
  return(tour)
}

# This function takes a distance matrix, an initial tour and settings and outputs a tour.
solveTspBy2Opt = function(distance, initialTour){

  # Initialize
  TwoOptRep = 100
  nCities = nrow(distance)
  
  # Run algorithm
  for(rep in 1:TwoOptRep){
    change = FALSE
    for(i in 1:(nCities - 2)){
      for(j in (i + 2):nCities){
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

# This function takes a distance matrix, an initial tour and settings and outputs a tour.
solveTspBySa = function(distance, initialTour){
  
  # initialTour
  tour = initialTour

  # Compute the length of the initial tour
  distancesTour = diag(distance[head(tour, -1), tail(tour, -1)])
  totalDistance = sum(distancesTour)
  
  iteration = 1
  # The tour lengths are stored for every iteration
  tourLengths = c(totalDistance)
  
  # Parameters of the algorithm
  startTemp = 1000
  alpha = 0.99990
  endTemp = 1
  j = 1
  
  # The current temperature is set to the start temperature
  currentTemp = startTemp
  
  while(currentTemp > endTemp){
    
    # We randomly select two arcs to be removed from the tour
    # These arcs cannot be subsequent. If they would be, we randomly select new arcs
    while(TRUE){
      r = sample.int(nCities, 2, replace=FALSE)
      if(r[1] > r[2]){
        r = rev(r)
      }
      if(r[2] - r[1] > 1){
        break
      }
    }
    # Compute the difference in tour length if the 2-exchane would be executed
    currentLength = distance[tour[r[1]], tour[r[1] + 1]] + distance[tour[r[2]], tour[r[2] + 1]]
    newLength = distance[tour[r[1]], tour[r[2]]] + distance[tour[r[1] + 1], tour[r[2] + 1]]
    difference = newLength - currentLength
    # If the new tour is better, we always accept it.
    if(difference < 0){
      tour[(r[1] + 1):r[2]] = rev(tour[(r[1] + 1):r[2]])
      cat(j, r, difference, totalDistance, "Improving\n")
    }
    # Otherwise, we accept it with a certain probability
    else{
      p = runif(1, 0.0, 1.0) # Draw a random number in [0,1]
      if(p < exp(-difference / currentTemp))
      {
        tour[(r[1] + 1):r[2]] = rev(tour[(r[1] + 1):r[2]])
        cat(j, r, difference, "Non-Improving\n")
      }
    }
    # Comute and store the tour length
    
    distancesTour = diag(distance[head(tour, -1), tail(tour, -1)])
    totalDistance = sum(distancesTour)
    
    iteration = iteration + 1
    tourLengths[iteration] = totalDistance
    
    # Update the temperature
    currentTemp = alpha * currentTemp
    
    j = j + 1
  }
  return(tour)
  plot(tourLengths)
}

# This function takes x/y coordinates and plots points and lines on a worldmap
# If createGIF is set to TRUE it will also create a PNG file of the plot
plotMap = function(xBest, yBest, x = xBest, y = yBest, col = "black", colBest = "lightgrey", main = "Plot", rep, createGIF = FALSE){
  plot(newmap, main = main, cex.main = 1.5)
  lines(xBest, yBest, col = colBest, cex = .6, lwd = 5)
  lines(x, y, col = "black", cex = .6)
  points(x, y, col = "red", cex = .7, pch = 20)
  
  # Some deliberate duplication of code, as base plot does not let me create a single object for this combined plot
  if (createGIF){
    png(paste0("images/",str_pad(rep, 3, pad = 0),'.png'), 1280, 720)
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
