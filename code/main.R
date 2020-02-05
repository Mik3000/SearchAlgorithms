# Clear environment and set WD
rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc()
cat("\014")  
setwd("~/Documents/Data Science/SearchAlgorithms-master")

# Load packages and functions
source("code/funcs.r")
library(stringr)

# Read data
source("code/readWorldCities.r")

# Set parameters
constructiveHeuristic = "insertion" # can be "insertion" or "extension" or "genetic"
plotConstructiveHeuristic = TRUE #set to TRUE to plot intermediate tours
random = FALSE      # Set random to TRUE to apply randomized extension
set.seed(19051983) # Set seed for reproducability if random = TRUE
rclSize = 3        # Set candidate list length of randomized extension
localSearch = "noLocalSearch" # can be "twoOpt", "SimulatedAnnealing" or "noLocalSearch"
nRepetitions = 1  # Set number of repetetitions
nSeconds = 0.1     # Delay loop by n seconds to allow plots to load

# IMPORTANT: only works you have ImageMagick installed on your machine
createGIF = TRUE   # Set createGIF to TRUE to create PNG files of each plot and transform those to GIF

# store settings + create output names
settings = list(constructiveHeuristic = constructiveHeuristic, random = random, rclSize = rclSize, nRepetitions = nRepetitions, 
                localSearch = localSearch, createGIF = createGIF, nSeconds = nSeconds)
settingname = paste0(if(random){"Randomized_"} else {""}, 
                     constructiveHeuristic, "_",  localSearch, "_", "Rep", 
                     nRepetitions, "_", "nCities", nCities)
gifname = paste0(settingname, ".gif")

# Initialize
bestTotalDistance = Inf
bestIter = NA
results = matrix(NA, nRepetitions, 2)

# Start optimzation cycle
for (rep in 1:nRepetitions){
  
  # run constructive heurstics
  if (constructiveHeuristic == "insertion"){
    tour = solveTspByInsertion(distance, coords, settings)
  } else if (constructiveHeuristic == "extension"){
    tour = solveTspByExtension(distance, coords, settings)
  } else if (constructiveHeuristic == "genetic"){
    tour = solveTspByGenetic(distance, coords, settings)
  }

  # run local search
  if (localSearch == "twoOpt"){
    tour = solveTspBy2Opt(distance, initialTour = tour)
  } 
  if (localSearch == "SimulatedAnnealing"){
    tour = solveTspBySa(distance, initialTour = tour)
  }
  
  # Calculate and store results
  distances = diag(distance[head(tour, -1), tail(tour, -1)])
  totalDistance = sum(distances)
  results[rep,1] = totalDistance
    
  # Print result of each iteration
  cat(rep, totalDistance, bestTotalDistance, "\n")
  
  # Plot the results of each iteration
  x = coords[tour, 2]
  y = coords[tour, 3]

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
  
  # Update bestTotalDistance
  if (bestTotalDistance == Inf || totalDistance < bestTotalDistance){
    bestTotalDistance = totalDistance
    bestIter = rep
  }
}

# Create GIF for all intermediate solutions if createGIF is set to TRUE
if (createGIF){
  syscall = paste0("convert -delay 20 images/*.png ", "images/", gifname)
  system(syscall)
}

# Plot final solution
plotMap(xBest, yBest, x = xBest, y = yBest, 
        main = paste(settingname, "\n", "bestIteration:", bestIter, "- ","bestDistance:", bestTotalDistance), 
        colBest = "green", rep = "last", createGIF = createGIF)

# Create GIF for final solution if createGIF is set to TRUE
if (createGIF){
  # Add PNG with final solution to GIF 
  syscall = paste0("convert ", gifname, " -delay 200 images/last.png ", "images/", gifname)
  system(syscall)
}

# Remove png files from WD
file.remove(paste0("images/", list.files(path = "images/", pattern=".png")))
#file.remove(paste0("images/", list.files(path = "images/", pattern=".gif")))

# Plot distances of intermediate solutions
if (nRepetitions != 1){
  matplot(1:nRepetitions, cbind(results[, 1], results[, 2]), 
          type = "p", pch=16, xlab = "Iteration", ylab = "KM", 
          main = settingname, cex.main=1.5, col = c("grey", "green"), cex = 2)
}
    
