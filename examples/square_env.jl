#A complex domain environment with square shape and two static circular obstacles in it

using Random
using Graphs
using MetaGraphs
import ProbabilisticRoadMap as P
include("utils.jl")

struct CircularObstacle
    x::Float64
    y::Float64
    r::Float64 #Radius of the obstacle which is assumed to be a circle
end

struct SquareEnvironment
    length::Float64
    breadth::Float64
    obstacles::Array{CircularObstacle,1}
end

struct PRMNodeState
    x::Float64
    y::Float64
end

struct SamplePoint
    env::SquareEnvironment
end

function (obj::SamplePoint)(rng)
    rand_for_x = rand(rng)
    x = rand_for_x * obj.env.length
    rand_for_y = rand(rng)
    y = rand_for_y * obj.env.breadth
    return PRMNodeState(x,y)
end

struct IsNodeValid
    env::SquareEnvironment
end

function (obj::IsNodeValid)(prm,node_state)
    padding = 1.0
    for o in obj.env.obstacles
        dist = sqrt((node_state.x - o.x)^2+(node_state.y - o.y)^2)
        if(dist<=o.r+padding)
            return false
        end
    end
    return true
end

struct IsEdgeValid
    env::SquareEnvironment
end


function (obj::IsEdgeValid)(prm,src_node_state,des_node_state)

    padding = 1.0
    for o in obj.env.obstacles
        if(circle_line_intersect(o.x,o.y,o.r+padding,src_node_state.x,src_node_state.y,des_node_state.x,des_node_state.y))
            return false
        end
    end
    return true
end


struct EdgeCost
    env::SquareEnvironment
end

function (obj::EdgeCost)(prm,src_node_state,des_node_state)
    dist = sqrt((src_node_state.x - des_node_state.x)^2+(src_node_state.y - des_node_state.y)^2)
    return dist
end

#=
Function to visualize the generated prm in the given square environment
Add Plots.jl to be able to use this function
=#
function visualize(env::SquareEnvironment, prm)

    plot_size = 100
    p = plot(legend=false,grid=false,axis=([], false))
    # p = plot([0.0],[0.0],legend=false,grid=false)

    #Plot the rectangular environment
    plot!([0.0, env.length],[0.0,0.0], color="grey", lw=2)
    plot!([env.length, env.length],[0.0,env.breadth], color="grey", lw=2)
    plot!([0.0, env.length],[env.breadth,env.breadth], color="grey", lw=2)
    plot!([0.0, 0.0],[0.0,env.breadth], color="grey", lw=2)

    #Plot Obstacles
    for obs in env.obstacles
        plot!(circleShape(obs.x,obs.y,obs.r), lw=0.5, linecolor = :black,
                                        legend=false, fillalpha=1.0, aspect_ratio=1,c= :black, seriestype = [:shape,])
    end

    #Plot PRM nodes
    for i in 1:nv(prm)
        node_state = get_prop(prm,i,:state)
        scatter!([node_state.x], [node_state.y],color="Grey",shape=:circle, msize=0.3*plot_size/env.length)
    end

    #Plot PRM edges
    prm_edges = collect(edges(prm))
    for e in prm_edges
        src_node_state = get_prop(prm,e.src,:state)
        des_node_state = get_prop(prm,e.dst,:state)
        plot!( [src_node_state.x,des_node_state.x], [src_node_state.y,des_node_state.y], color="LightGrey")
    end

    display(p)
end


e = SquareEnvironment(100.0,100.0,CircularObstacle[CircularObstacle(30.0,30.0,15.0),CircularObstacle(70.0,60.0,5.0)])
const MAX_NUM_NODES = 5
const MAX_NUM_EDGES = 2
get_node_state = SamplePoint(e)
is_node_valid = IsNodeValid(e)
is_edge_valid = IsEdgeValid(e)
edge_cost = EdgeCost(e)
rng_seed = 11
rng = MersenneTwister(rng_seed)
prm = P.generate_prm(MAX_NUM_NODES,MAX_NUM_EDGES,get_node_state,is_node_valid,is_edge_valid,edge_cost,rng,10)

#=
To visualize the PRM and the environment, use the visualize function above.
using Plots
visualize(e,prm)
=#
