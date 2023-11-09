# ProbabilisticRoadMap

[![Build Status](https://github.com/himanshugupta1009/ProbabilisticRoadMap.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/himanshugupta1009/ProbabilisticRoadMap.jl/actions/workflows/CI.yml?query=branch%3Amain)

This is a Julia package for generating a Probabilistic RoadMap (PRM) on any given environment.

### Information on the Probabilistic RoadMap algorithm can be found in this paper

* Probabilistic roadmaps for path planning in high-dimensional configuration spaces [(Link)](https://ieeexplore.ieee.org/abstract/document/508439)

#### A randomly sampled PRM with 100 nodes for a square environment with circular obstacles using the ProbabilisticRoadMap.jl package  
![prm_img](https://github.com/himanshugupta1009/ProbabilisticRoadMap.jl/blob/main/media/prm_100_nodes_7_edges.png)

## This package provides users with the following functions:

### 1) `generate_prm`

    generate_prm(100,5,get_node_state,is_node_valid,is_edge_valid,edge_cost,MersenneTwister(11),1.0)  
  
  The function generates and returns a prm (graph) with the given number of nodes and connects them to other nodes in the prm.

#### Arguments 
- `num_nodes::Int` -> number of nodes to be added in the prm (graph)
- `max_edges::Int` -> maximum number of edges each node can have in the prm (graph)
- `get_node_state::Function` -> function that returns the state to be stored at that node. It takes in a random number generator as an input and returns the node state
    (For a 2D environment, the node state could be a tuple of x and y positions). It will be called like this: `node_state = get_node_state(rng)`
- `is_node_valid::Function` -> function that checks if a given node is valid to be added to the PRM. It takes in the prm (graph) and node state as inputs and returns true or false
    (This function can be used to check if the node state is in free space or not). It will be called like this: `is_node_valid(prm,node_state)`
- `is_edge_valid::Function` -> function that checks if a given edge is valid to be added to the graph. It takes in the prm (graph), source node state and destination node state as inputs and returns true or false
    (This function can be used to check if the edge connecting the node with source node state and the node with destination node state passes through an obstacle in the environment or not). It will be called like this: `is_edge_valid(prm,src_node_state,des_node_state)`
- `edge_cost::Function` -> function that computes the cost of an edge between two nodes of the graph. It takes in the prm (graph), source node state and destination node state as inputs and returns the cost of the edge connecting these nodes
    (For a 2D environment where the node state is (x,y) positions, this function can return the euclidean distance between the two nodes.
  It will be called like this:`edge_cost(prm,src_node_state,des_node_state)`
- `rng::AbstractRNG` -> a random number generator object. It will be used as an input to the `get_node_state` function to generate the state for a new node in the PRM.
- `time_limit::Real=0.2` -> specifies the time limit for adding a new node to the prm (graph)

#### Output
  - an object of type MetaGraph with `num_nodes` number of vertices (nodes) where every vertex is connected to `max_edges` or fewer other vertices
        (meta graph because every node has an attribute called `:state` which has the node state in it)


### 2) `add_prm_node!`

    add_prm_node!(prm, get_node_state, is_node_valid, MersenneTwister(11),1.0)
  
  The function tries to add a new node to the given prm (graph) within the specified time limit.

#### Arguments

- `prm::MetaGraph` -> graph to which a new node (vertex) will be added
- `get_node_state::Function` -> function that returns the state to be stored at that node. It takes in a random number generator as an input and returns the node state
    (For a 2D environment, the node state could be a tuple of x and y positions). It will be called like this: `node_state = get_node_state(rng)`
- `is_node_valid::Function` -> function that checks if a given node is valid to be added to the PRM. It takes in the prm (graph) and node state as inputs and returns true or false
    (This function can be used to check if the node state is in free space or not). It will be called like this: `is_node_valid(prm,node_state)`
- `rng::AbstractRNG` -> a random number generator object. It will be used as an input to the `get_node_state` function to generate the state for a new node in the PRM.
- `time_limit::Real=0.2` -> specifies the time limit for adding a new node to the prm (graph)


#### Output
- `true` if a new node has been successfully added to the prm (graph), else `false`


### 3) `add_prm_edges!`
    
    add_prm_edges!(prm, 11, 5, is_edge_valid, edge_cost)

  The function adds edges for a given node in the prm (graph).

#### Arguments
  
- `prm::MetaGraph` -> graph to which new edges will be added
- `src_node_num::Int` -> the node number in the prm (graph) for which new edges will be added
- `max_num_edges::Int` -> the maximum number of edges this node can have in the prm (graph)
- `is_edge_valid::Function` -> function that checks if a given edge is valid to be added to the graph. It takes in the prm (graph), source node state and destination node state as inputs and returns true or false
    (This function can be used to check if the edge connecting the node with source node state and the node with destination node state passes through an obstacle in the environment or not). It will be called like this: `is_edge_valid(prm,src_node_state,des_node_state)`
- `edge_cost::Function` -> function that computes the cost of an edge between two nodes of the graph. It takes in the prm (graph), source node state and destination node state as inputs and returns the cost of the edge connecting these nodes
    (For a 2D environment where the node state is (x,y) positions, this function can return the euclidean distance between the two nodes).
  It will be called like this: `edge_cost(prm,src_node_state,des_node_state)`

***

#### Examples

1) A simple example to generate a prm for a circular environment that has a circular static obstacle can be found in examples/square_env.jl
2) A complex example to generate a prm for a square environment that has two circular static obstacles can be found in examples/square_env.jl

***

## Find the shortest path between nodes in the PRM:

Since the generated prm is of type MetaGraph, all the functions provided by Graphs.jl to find the shortest path in a graph can be used for the prm as well.
For instance, the shortest path from node number 2 to all other nodes in the prm using Dijkstra's algorithm can be computed like this:
```
    using Graphs
    ds = dijkstra_shortest_paths(prm,2)
```
Further information can be found in the [documentation](https://juliagraphs.org/Graphs.jl/stable/) for Graphs.jl package.


#### In case of any queries, feel free to raise a Github Issue or reach out to the author via email at himanshu.gupta@colorado.edu.
