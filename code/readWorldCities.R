library(maps)
library(raster)
library(rworldmap)

# Select all capital cities with population of > 1,000,000 but keep Washington + Ottawa + Amsterdam :-)
cities = world.cities
cities = cities[cities$capital == 1,]
cities = cities[cities$pop>1000000 |cities$name %in% c("Washington", "Ottawa", "Amsterdam"), ]
#cities = cities[1:5,]

# start in Amsterdam
cities = rbind(cities[cities$name == "Amsterdam",], cities[cities$name != "Amsterdam",])

# Fill vectors with data
cityNames = cities$name
distance = round(pointDistance(cbind(cities$long, cities$lat), lonlat = TRUE, allpairs=TRUE)/1000)
distance = as.matrix(as.dist(distance))
nCities = nrow(cities)
coords = cbind(1:nCities ,cities$long, cities$lat)

#names(coords) = cities$name
x = cities$long
y = cities$lat
remove(cities)

# Create gif and remove separate .png from working directory
newmap = getMap(resolution = "low")
plot(newmap, main = paste0("Number of cities: ", nCities, "\n", "Start: ", cityNames[1]),cex.main=1.5)
points(x, y, col = "red", cex = .9, pch = 20)
