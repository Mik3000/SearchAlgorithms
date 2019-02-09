# Around the world in 90414 kilometers
## The fastest route to visit all capital cities with over 1 mln inhabitants
This project compares several search heuristics applied to a Traveling Salesman Problem with 85 points. The goal of this project is to show intuition behind some well known and effective search heuristics to people new to the subject of optimization. If you are interested you can run the algoritms yourself using the supplied R code or create your own adaptation. 

## Traveling Salesman Problem
Given a collection of cities and the cost of travel between each pair of them, the traveling salesman problem, or TSP for short, is to find the cheapest way of visiting all of the cities and returning to your starting point. The simplicity of the statement of the problem is deceptive -- the TSP is one of the most intensely studied problems in computational mathematics and yet no effective solution method is known for the general case ([source](http://www.math.uwaterloo.ca/tsp/problem/index.html)). For this project cost is defined as the direct (i.e Euclidian) distance between two points.

## Dataset
The dataset contains all the capital cities around the world with over 1 mln inhabitants as per 2006. Nowawadays, there might me more capital cities with over 1 mln people, but that is not relevant to the optimization problem itself. I made an exception for the capitals of the US (Washington), Canada (Ottawa) and the Netherlands (Amsterdam). They did not have more than 1 mln inhabitants, but I added them just for fun. The set contains data on a total of 85 cities. The dataset is freely available in the 'maps' package in R and has information on over 40.000 cities. The city where I start all routes Amsterdam.
![](dataset.png)

## Approach
One approach could be to calculate all possible routes and choose the optimal one. For this instance of TSP with 85 cities the number of possible solutions can be calculated as (n-1)!/2 which translates to 1.65712e+126, or 1657120067282643529694317127122958783813299277197483101064623714896696398713440263618419048770174788491009133122012443658158080 routes. It would take many years and a quantum computer to solve the problem using this approach. Since I don't have either at my disposal this approach is not feasible. 

Another approach could be to use exact algoritms like branch-and-bound or simplex. These are very robust methods that will find the optimum solution for TSP problems of up to +/-200 (on the average PC). However, visualising these in an intuitive way is challenging, if not impossible. As the main goal of this project is to show intuition of algoritms to people who are fresh on the subject, these are not suitable. Also, these methods do not scale well so applying them to more cities (the dataset contains 40000 in total) is not feasible. Hence, less opportunity to play around with larger sets.

Instead, I will use another powerfull line of attack to this problem: search heuristics. The advantage of these methods is that you can keep them relatively simpel and intuitive, while they are still able to find solutions that are (close to) the optimum. Also, they scale better so applying them to a 500 city TSP will less likely crash your machine. A disadvantage is that you will not know how far you are from the optimimum. The search heursistics I used include Nearest Neighbours, Randomized Nearest Neighbours and (repeated) 2-Opt. As I will show you, these are relatively simple but also very effective and intuitive, especially when applied in combination. 

## Nearest Neighbour
This is one of the simplest search heuristics out there. It is part of the family of constructive search heuristics, meaning that it gradually builds a route, starting with 1 city and stopping only when all cities have been visited. It is greedy in nature; at each step it chooses the location that is closest to the current location. Applied to our problem it finds a route with a total distance of 112.881 KM. Everytime we run the algoritm, it will generate exactly the same solution. This might seem reassuring, but it is also a big downside of this algoritm. Because of its greedy nature, it will always go for immediate gains and miss out on opportunities that will pay out in a longer term. 
![](NNRep1nCities85.gif)
Nearest Neighbour has given us a feasible solution that does not look bad at all for a first try. But can we improve further on it?
## Nearest Neighbors with 2-Opt
2-Opt is an algoritm from the local search family. These algoritms generate a final solution by starting at an initial and  solution and iteratively looking for improvement opportunities in the neighourhood of that solution. This initial solution can be any type of solution as long as it is a feasible one. For example the outcome of a constructive algoritm or a solution build from expert knowledge. The implementation of this 2-opt algoritm works as follows: take 2 arcs from the route and reconnect these arcs with each other. If this modification has led to a shorter total travel time, the route is modified. The algoritm continues to build on the improved route. This process can be repeated until no more improvements are found or untill a pre-specified number of iterations are completed (100 in this implementation). 

For example, let us take the following route: Amsterdam - Brussels - Paris - Berlin - Copenhagen - Helsinki - London - Amsterdam. One arch could be Brussel-Paris, another could be Copenhagen-Helsinki. 2-Opt exchanges the connections in these arches, i.e. the route now runs from Brussel-Copenhagen and from Paris-Helsinki. Next, new travel distance is calculated and compared with the old one. In case of improvement, the new route is accepted and taken as new starting point. 

Old route: Amsterdam - Brussels - Paris - Berlin - Copenhagen - Helsinki - London - Amsterdam
New route: Amsterdam - Brussels - Copenhagen - Berlin - Paris - Helsinki - London - Amsterdam

Below GIF shows the intuition of this algoritm. The visualisation shows just 1 iteration (i.e. the London-Amsterdam arc), but there could be up to 700000 of these iterations in the current set-up. Hence, the final solution could look drastically different from the initial solution. 
![](NN2OptRep1nCities85.gif)

## Randomized Nearest Neighbours
One way to 



