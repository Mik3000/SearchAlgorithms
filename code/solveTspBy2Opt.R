# Initialize
TwoOptRep = 100
for(lsRep in 1:TwoOptRep){
  change = FALSE
  for(i in 1:(nCities-2)){
    for(j in (i+2):(nCities)){
      currentCosts = distance[tour[i],tour[i+1]] + distance[tour[j],tour[j+1]]
      newCosts = distance[tour[i], tour[j]] + distance[tour[i+1],tour[j+1]]
      difference = newCosts - currentCosts
      if(difference < 0){
        tour[(i+1):j] = rev(tour[(i+1):j])
        change = TRUE
      }
    }
  }
  if(!change){
    break
  }
}

totalDistance = 0

# Calculate and store results
for(i in 1:nCities)
  totalDistance = totalDistance + distance[tour[i],tour[i+1]]

results[rep,2]= totalDistance
