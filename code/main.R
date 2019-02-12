# Load packages and functions
source("funcs.r")
library(stringr)

# Read data
source("readWorldCities.r")

# Settings
random = TRUE # Set random to TRUE to apply randomized extension
set.seed(19051983)
rclSize = 3 # Set candidate list length of randomized extension
twoOpt = TRUE # Set twoOpt to TRUE to apply 2opt algoritm
nRepetitions = 100 # Set number of repetetitions
nSeconds = 0.2 # delay loop by n seconds to allow plots to load

# IMPORTANT: only works you have ImageMagick installed on your machine
createGIF = TRUE # Set createGIF to TRUE to create PNG files of each plot and transform those to GIF

# store settings + create output names
settings = list(random, rclSize, nRepetitions, twoOpt, createGIF, nSeconds)
names(settings) = c("random", "rclSize", "nRepetitions", "twoOpt", "createGIF", "nSeconds")
settingname = paste0(if(random){"RandNN"} else {"NN"}, if(twoOpt){"2Opt"}, "Rep", nRepetitions, "nCities", nCities)
gifname = paste0(settingname, ".gif")

# Initialize
bestTotalDistance = Inf
bestIter = NA
results = matrix(NA, nRepetitions, 2)

# Start optimzation cycle
for (rep in 1:nRepetitions){
  
  # Run Nearest Neighboars algorithm
  tour = solveTspByExtension(distance, coords, settings)
  
  # Optionally: run 2Opt algorithm
  if (twoOpt) {
    tour = solveTspBy2Opt(distance, initialTour = tour, settings)
    totalDistance = 0
    
    # Calculate and store results
    for(i in 1:nCities){
      totalDistance = totalDistance + distance[tour[i], tour[i+1]]
    }
    results[rep,1]= totalDistance
    
    # Print result of each iteration
    cat(rep, totalDistance, bestTotalDistance, "\n")
  }
  
  # Plot the results of each iteration
  x = matrix(-1, nCities)
  y = matrix(-1, nCities)

  for(i in 1:nCities){
    x[i] = coords[tour[i], 2]
    y[i] = coords[tour[i], 3]
  }

  # Plot intermediate results, only if there are multiple iterations
  if (nRepetitions!=1){
    #if improvement, plot green lines and replace yBest
    if(totalDistance < bestTotalDistance){
      colBest = "green"
      yBest = y
      xBest = x
      results[rep, 2] = totalDistance
    } else {
      colBest = "lightgrey"
    }
    # Plot the map
    plotMap(xBest, yBest, x, y, colBest = colBest, 
            main = paste(settingname, "\n", "Iteration:", rep, "- ", "Distance:", totalDistance, "\n", "bestIteration:", 
                         bestIter, "- ", "bestDistance:", bestTotalDistance)
            , createGIF = createGIF, rep = rep)
    
    # Delay loop to allow plot to print
    delayLoop(nSeconds)
  }
  
  # Update bestTotalDistance
  if (bestTotalDistance == Inf || bestTotalDistance > totalDistance){
    bestTotalDistance = totalDistance
    bestIter = rep
  }
}

# Create GIF for all intermediate solutions if createGIF is set to TRUE
if (createGIF){
  syscall = paste0("convert -delay 20 *.png ", gifname)
  system(syscall)
}

# Plot final solution
plotMap(xBest, yBest, x = xBest, y = yBest, 
        main = paste(settingname, "\n", "bestIteration:", bestIter, "- ","bestDistance:", bestTotalDistance), 
        colBest = "green", rep = "last", createGIF = createGIF)

# Create GIF for final solution if createGIF is set to TRUE
if (createGIF){
  # Add PNG with final solution to GIF 
  syscall = paste0("convert ", gifname, " -delay 200 last.png ", gifname)
  system(syscall)
}

# Remove png files from WD
# file.remove(list.files(pattern=".png"))

# Plot distances of intermediate solutions
if (nRepetitions != 1){
  matplot(1:nRepetitions, cbind(results[, 1], results[, 2]), 
          type = "p", pch=16, xlab = "Iteration", ylab = "KM", 
          main = settingname, cex.main=1.5, col = c("grey", "green"), cex = 2)
}
    