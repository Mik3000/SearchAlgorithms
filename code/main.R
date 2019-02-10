# Store the code in a single folder and set as working directory
#setwd()

# Load packages and functions
source("funcs.r")
library(stringr)

# Read data
source("readWorldCities.r")

# Set random to TRUE to use randomized extension
random = TRUE
set.seed(19051983)
rclSize = 3 # set candidate list length

# Set twoOpt to TRUE to apply 2opt algoritm to each instance of extension
twoOpt = TRUE

# Set createGIF to TRUE to create PNG files of each plot and transform those to GIF
# IMPORTANT: only works you have ImageMagick installed on your machine
createGIF = FALSE

# Initialize
nRepetitions = 100
bestTotalDistance = Inf
bestIter = NA
results = matrix(NA,nRepetitions,3)
nSeconds = 0.1 # delay loop by n seconds to allow plots to load

# Store settings + create gif names
settings = paste0(
  if(random){"RandNN"} else {"NN"}
  , if(twoOpt){"2Opt"}
  , "Rep"
  , nRepetitions
  , "nCities"
  , nCities)
gifname = paste0(settings,".gif")

# Start optimzation cycle
for (rep in 1:nRepetitions){
  # Nearest Neighboars algoritm
  source('solveTspByExtension.R')

  # Optionally: run 2Opt algoritm
  if (twoOpt) {
    source('solveTspBy2Opt.R')
  results[rep,1]= totalDistance
  }
  
  # Print result of each iteration
  cat(rep, totalDistance, bestTotalDistance, "\n")
  
  #plot the results of each iteration
  x = matrix(-1, nCities)
  y = matrix(-1, nCities)
  tour[nCities+1] = 1
  
  for(i in 1:nCities){
    x[i] = coords[tour[i], 2]
    y[i] = coords[tour[i], 3]
  }

  #if improvement, plot green lines and replace yBest
  if(totalDistance < bestTotalDistance){
    colBest = "green"
    yBest = y
    xBest = x
    results[rep, 3] = totalDistance
  } else {
    colBest = "lightgrey"
    }
  
  if (nRepetitions!=1){
    # Plot results
    plotMap(xBest, yBest,x,y, colBest = colBest, main = paste(settings
                                                              , "\n"
                                                              , "Iteration:"
                                                              , rep
                                                              , "- "
                                                              ,"Distance:"
                                                              , totalDistance
                                                              , "\n"
                                                              , "bestIteration:"
                                                              , bestIter
                                                              , "- "
                                                              , "bestDistance:"
                                                              , bestTotalDistance
                                                              )
            , createGIF = createGIF
            , rep = rep) # Worldmap
  }
  
  # delay loop to allow plot to print
  delayLoop(nSeconds)

  # update bestTotalDistance
  if (bestTotalDistance == Inf || bestTotalDistance > totalDistance){
    bestTotalDistance = totalDistance
    bestIter = rep
  }
}

if (createGIF){
  # Create GIF for all repetitions
  syscall = paste0("convert -delay 20 *.png ", gifname)
  system(syscall)
}


# Plot final solution
plotMap(xBest, yBest, x = xBest, y = yBest
        , main = paste(settings
                       , "\n"
                       , "bestIteration:"
                       , bestIter
                       , "- "
                       ,"bestDistance:"
                       , bestTotalDistance)
        , colBest = "green", rep = "last", createGIF = createGIF)

if (createGIF){
  # Add PNG with final solution to GIF 
  syscall = paste0("convert ", gifname, " -delay 200 last.png ", gifname)
  system(syscall)
}

# cleaning up png files in WD
file.remove(list.files(pattern=".png"))

# plot repetitions
if (nRepetitions!=1){
  matplot(1:nRepetitions, cbind(results[,2], results[,3])
          , type = "p", pch=16
          , xlab = "Iteration"
          , ylab = "KM"
          , main = settings
          , cex.main=1.5
          , col = c("grey", "green")
          , cex = 2)
}
    