# Around the world in 90414 kilometers
This project investigates several search heuristics applied to a Traveling Salesman Problem with 85 points. The goal of this project is to show intuition behind some well known and effective search heuristics to people new to the subject of optimization. 

## The Traveling Salesman Problem
Given a collection of cities and the cost of travel between each pair of them, the traveling salesman problem, or TSP for short, is to find the cheapest way of visiting all of the cities and returning to your starting point. The simplicity of the statement of the problem is deceptive -- the TSP is one of the most intensely studied problems in computational mathematics and yet no effective solution method is known for the general case ([source](http://www.math.uwaterloo.ca/tsp/problem/index.html)).

## Dataset
The dataset I used contains all the capital cities per country around the world consisting of over 1 mln inhabitants as per 2006. Nowawadays, in 2019, there might me more capital cities with over 1 mln people, but that is not relevant to the optimization problem itself. I made an exception for the capitals of the US (Washington), Canada (Ottawa) and the Netherlands (Amsterdam). They did not have more than 1 mln inhabitants, but I added them just for fun. The dataset is freely available in the 'maps' package in R and has information on over 40.000 cities. The city where I start is my own capital city: Amsterdam.
![](dataset.png)

## Approach
One approach would be to calculate all possible routes and choose the optimal one. For this instance of TSP with 85 cities the number of possible solutions can be calculated as (n-1)!/2 which translates to 1.65712e+126, or 1657120067282643529694317127122958783813299277197483101064623714896696398713440263618419048770174788491009133122012443658158080 routes. It would take (1) many years and (2) a quantum computer to solve the problem using this approach. Since I don't have either at my disposal this approach is not feasible. 

Another approach would be to use exact algoritms like branch-and-bound or simplex. These are very robust methods that work well TSP problems of up to 200 or more cities. However, visualising these in an intuitive way is challenging, if not impossible. As the main goal of this project is to show intuition of algoritms to people who are fresh on the subject, these are not suitable. Also, these methods do not scale well and applying them to more cities (the dataset contains 40000 in total) is not feasible. So less opportunity to play around.

Therefore I will use another powerfull line of attack to this problem: search heuristics. The advantage these methods is that you can keep them relatively simpel and intuitive, while they are still able to find solutions that are (close to) the optimum. A disadvantage is that you will never know how far you are from the optimimum. The search heursistics I used and combined include Nearest Neighbours, Randomized Nearest Neighbours and (repeated) 2-Opt. As I will show you, these are relatively easy in use but also very effective and intuitive, especially when applied in combination. 

## Nearest Neighboars


![](NN2OptRep1nCities85.gif)
