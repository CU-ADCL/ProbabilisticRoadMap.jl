# ProbabilisticRoadMap

[![Build Status](https://github.com/himanshugupta1009/ProbabilisticRoadMap.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/himanshugupta1009/ProbabilisticRoadMap.jl/actions/workflows/CI.yml?query=branch%3Amain)

This is a Julia package for generating a Probabilistic RoadMap on any given environment.

### Information on the Probabilistic RoadMap algorithm can be found in this paper

* Probabilistic roadmaps for path planning in high-dimensional configuration spaces [(Link)](https://ieeexplore.ieee.org/abstract/document/508439)

## This package provides users with the following functions:

### 1) add_prm_node!
  The function tries to add a new node to the given prm (graph) within the specified time limit.

Function parameters: 

- `prm` -> graph to which a new node (vertex) will be added
- `get_node_values` -> function that returns the values to be stored at that node. It takes in a random number generator as an input and returns the node values \n
    (For a 2D environment, the node values could be a tuple of x and y positions)
```julia-repl
        node_values = get_node_values(rng)
```
- `is_node_valid` -> function that checks if a given node is valid to be added to the PRM. It takes in the prm (graph) and node values as inputs and returns true or false \n
    (This function can be used to check if the node values are in free space or not)
```julia-repl
        is_node_valid(prm,node_values)
```
- `rng` -> a random number generator object
- `time_limit` (optional; default_value=0.2) -> specifies the time limit for adding a new node to the prm (graph)


  Output: 
- `true` if a new node has been successfully added to the prm (graph), else `false`

  Example:
  ```julia-repl
  add_prm_node!(prm, get_node_values, is_node_valid, MersenneTwister(11),1.0)
  ```

### 2) add_prm_edges!
  The function adds edges for a given node in the prm (graph).
    
  Function parameters:
- `prm` -> graph to which new edges will be added
- `src_node_num` -> the node number in the prm (graph) for which new edges will be added
- `max_num_edges` -> the maximum number of edges this node can have in the prm (graph)
- `is_edge_valid` -> function that checks if a given edge is valid to be added to the graph. It takes in the prm (graph), source node values and destination node values as inputs and returns true or false \n
    (This function can be used to check if the edge connecting the node with source node values and the node with destination node values pass through an obstacle in the environment or not)
```julia-repl
        is_edge_valid(prm,src_node_values,des_node_values)
```
- `edge_cost` -> function that computes the cost of an edge between two nodes of the graph. It takes in the prm (graph), source node values and destination node values as inputs and returns the cost of the edge connecting these nodes \n
    (For a 2D environment where the node values are (x,y) positions, this function can return the euclidean distance between the two nodes
```julia-repl
        edge_cost(prm,src_node_values,des_node_values)
```

Example:
```julia-repl
add_prm_edges!(prm, 11, 5, is_edge_valid, edge_cost)
```


### 3) generate_prm
  The function generates and returns a prm (graph) with given number of nodes and connects them to other nodes in the prm.

  Function parameters:  
  - `num_nodes` -> number of nodes to be added in the prm (graph)
- `max_edges` -> maximum number of edges each node can have in the prm (graph)
- `get_node_values` -> function that returns the values to be stored at that node. It takes in a random number generator as an input and returns the node values \n
    (For a 2D environment, the node values could be a tuple of x and y positions)
```julia-repl
        node_values = get_node_values(rng)
```
- `is_node_valid` -> function that checks if a given node is valid to be added to the PRM. It takes in the prm (graph) and node values as inputs and returns true or false \n
    (This function can be used to check if the node values are in free space or not)
```julia-repl
        is_node_valid(prm,node_values)
```
- `is_edge_valid` -> function that checks if a given edge is valid to be added to the graph. It takes in the prm (graph), source node values and destination node values as inputs and returns true or false \n
    (This function can be used to check if the edge connecting the node with source node values and the node with destination node values pass through an obstacle in the environment or not)
```julia-repl
        is_edge_valid(prm,src_node_values,des_node_values)
```
- `edge_cost` -> function that computes the cost of an edge between two nodes of the graph. It takes in the prm (graph), source node values and destination node values as inputs and returns the cost of the edge connecting these nodes \n
    (For a 2D environment where the node values are (x,y) positions, this function can return the euclidean distance between the two nodes
```julia-repl
        edge_cost(prm,src_node_values,des_node_values)
```
- `rng` -> a random number generator object
- `time_limit` (optional; default_value=0.2) -> specifies the time limit for adding a new node to the prm (graph)

  Output:
  - a meta graph with `num_nodes` number of vertices (nodes) where ever vertex is connected to `max_edges` or fewer other vertices\n
        (meta graph because every node has an attribute called `:values` which has the node values in it)

  Example:
```julia-repl
generate_prm(100,5,get_node_values,is_node_valid,is_edge_valid,edge_cost,MersenneTwister(11),1.0)
```

#### A simple example to generate a prm for a square environment that has circular static obstacles can be found in examples/square_env.jl

In case of any queries, feel free to raise a Github Issue or reach out to the author via email at himanshu.gupta@colorado.edu.
