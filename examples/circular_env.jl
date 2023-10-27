#A simple domain environment with circular shape and a static circular obstacle in it

using StaticArrays: SA
using Random
using LazySets: Ball2
using Graphs
using MetaGraphs
import ProbabilisticRoadMap as P
include("utils.jl")

const MAX_NUM_NODES = 5
const MAX_NUM_EDGES = 2

e = Ball2(SA[10.0,0.0],5.0)
obs = Ball2(SA[12.0,0.0],2.0)

function GetNodeState(rng)
    x = e.center[1] + (rand(rng)-0.5)*e.radius
    y = e.center[2] + (rand(rng)-0.5)*e.radius
    return SA[x,y]
end

IsNodeValid(prm,node_state) = !(node_state in obs) && (node_state in e)
IsEdgeValid(prm,s,d) = !circle_line_intersect(obs.center[1],obs.center[2],obs.radius,s[1],s[2],d[1],d[2])
EdgeCost(prm,s,d) = sqrt((s[1]-d[1])^2+(s[2]-d[2])^2)

#=
Function to visualize the generated prm in the given circular environment
Add Plots.jl to be able to use this function
=#
function visualize(env::Ball2, prm::MetaGraph)

    plot_size = 100
    p = plot(legend=false,grid=false,axis=([], false))

    #Plot the circular environment
    plot!(circleShape(env.center[1],env.center[2],env.radius), lw=0.5, linecolor = :black,
                legend=false, fillalpha=0.1, aspect_ratio=1,c= :black, seriestype = [:shape,])

    #Plot Obstacles
    plot!(circleShape(obs.center[1],obs.center[2],obs.radius), lw=0.5, linecolor = :black,
                legend=false, fillalpha=1.0, aspect_ratio=1,c= :black, seriestype = [:shape,])

    #Plot PRM nodes
    for i in 1:nv(prm)
        node_state = get_prop(prm,i,:state)
        scatter!([node_state[1]], [node_state[2]],color="Grey",shape=:circle, msize=0.3*plot_size/env.radius)
    end

    #Plot PRM edges
    prm_edges = collect(edges(prm))
    for e in prm_edges
        src_node_state = get_prop(prm,e.src,:state)
        des_node_state = get_prop(prm,e.dst,:state)
        plot!( [src_node_state[1],des_node_state[1]], [src_node_state[2],des_node_state[2]], color="LightGrey")
    end

    display(p)
end


rng = MersenneTwister(29)
prm = P.generate_prm(MAX_NUM_NODES,MAX_NUM_EDGES,GetNodeState,IsNodeValid,IsEdgeValid,EdgeCost,rng,10)

#=
To visualize the PRM and the environment, use the visualize function above.
using Plots.jl
visualize(e,prm)
=#
