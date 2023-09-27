"""
    add_prm_node!(prm, get_node_values, is_node_valid, rng, time_limit = 0.2)

The function tries to add a new node to the given PRM within the specified time_limit.

# Arguments

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

# Output

- `true` if a new node has been successfully added to the prm (graph), else `false`

# Example
```julia-repl
add_prm_node!(prm, get_node_values, is_node_valid, MersenneTwister(11),1.0)
```

"""
function add_prm_node!(prm, get_node_values, is_node_valid, rng, time_limit = 0.2)

    node_values = get_node_values(rng)
    node_found = false
    start_time = time()

    while(!node_found && (time()-start_time < time_limit))
        if(is_node_valid(prm,node_values))
            add_vertex!(prm)
            set_prop!(prm, nv(prm), :values, node_values)
            node_found = true
        else
            node_values = get_node_values(rng)
        end
    end
    if(!node_found)
        println("Node couldn't be added within the given time limit.")
    end
    return node_found
end


"""
    add_prm_edges!(prm,src_node_num,max_num_edges,is_edge_valid,edge_cost)

The function adds edges for a given node in the prm (graph).

# Arguments

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

# Example
```julia-repl
add_prm_edges!(prm, 11, 5, is_edge_valid, edge_cost)
```

"""
function add_prm_edges!(prm,src_node_num,max_num_edges,is_edge_valid,edge_cost)

    #=
    1)Initialize a cost_array
    2) For a given prm node, check if a direct path is possible between this node and every other node of the prm and compute the cost of that path
        A) If the path is not possible due to collision, don't put this node in the cost_array list.
        B) If it is possible, use some metric to compute the cost of moving from the given node to this prm node and store it in cost_array.
    3) Sort this list in ascending order to find the closest vertex first.
    4) Add "num_edges" number of edges to the PRM starting from the closest vertex.
    =#

    cost_array = Array{Tuple{Int64,Float64},1}()
    # Can also be initialized like this: cost_array = Tuple{Int64,Float64}[]
    for i in 1:nv(prm)
        if(i == src_node_num)
            continue
        else
            src_node_values = get_prop(prm,src_node_num,:values)
            i_node_values = get_prop(prm,i,:values)
            if(is_edge_valid(prm,src_node_values,i_node_values))
                cost = edge_cost(prm,src_node_values,i_node_values)
                push!(cost_array, (i,cost))
            end
        end
    end
    cost_array = sort(cost_array, by = x->x[2])

    num_edges_added = 0
    iterator = 1
    while(num_edges_added < max_num_edges && iterator<=length(cost_array))
        des_node_num = cost_array[iterator][1]
        if(has_edge(prm,src_node_num,des_node_num))
            num_edges_added += 1
        elseif(length(outneighbors(prm,des_node_num)) >= max_num_edges)
            # continue
        else
            add_edge!(prm,src_node_num,des_node_num)
            num_edges_added += 1
        end
        iterator += 1
    end
end


"""
    generate_prm(num_nodes,max_edges,get_node_values,is_node_valid,is_edge_valid,edge_cost,rng,time_limit=0.2)

The function adds edges for a given node in the prm (graph).

# Arguments

- `num_nodes` -> graph to which new edges will be added
- `max_edges` -> the node number in the prm (graph) for which new edges will be added
- `max_num_edges` -> the maximum number of edges this node can have in the prm (graph)
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


# Example
```julia-repl
generate_prm(100,5,get_node_values,is_node_valid,is_edge_valid,edge_cost,MersenneTwister(11),1.0)
```

"""
function generate_prm(num_nodes,max_edges,get_node_values,is_node_valid,is_edge_valid,edge_cost,rng,time_limit=0.2)

    prm = MetaGraph()
    set_prop!(prm, :description, "A PRM for path planning")

    #Add nodes to the PRM
    for i in 1:num_nodes
        add_prm_node!(prm,get_node_values,is_node_valid,rng,time_limit)
    end

    #Add edges to the PRM
    for i in 1:num_nodes
        add_prm_edges!(prm,i,max_edges,is_edge_valid,edge_cost)
    end

    return prm
end
