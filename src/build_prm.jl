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
end

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
