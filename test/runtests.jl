using ProbabilisticRoadMap
using Test
using Graphs

function check_prm(prm)

    expected_node_values = [
    PRMNodeState(40.81692590363648, 51.595291733725055),
    PRMNodeState(86.03462665489386, 63.485622120651676),
    PRMNodeState(58.28199336036355, 69.55492562954907),
    PRMNodeState(96.1567156782461, 18.774735921078943),
    PRMNodeState(16.46442417471747, 56.30896022795546)
    ]

    expected_edges = [
    Edge(1,3),
    Edge(1,5),
    Edge(2,3),
    Edge(2,4),
    Edge(4,5)
    ]

    received_node_values = [get_prop(prm,i,:state) for i in vertices(prm)]
    received_edges = collect(edges(prm))

    return ( (expected_edges==received_edges) && (expected_node_values==received_node_values))
end

@testset "ProbabilisticRoadMap.jl" begin

    include("../examples/square_env.jl")
    @test check_prm(prm)

end
