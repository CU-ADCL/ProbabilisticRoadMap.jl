using Random

#A domain environment with square shape and static circular obstacle in it

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

struct PRMNodeValues
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
    return PRMNodeValues(x,y)
end

struct IsNodeValid
    env::SquareEnvironment
end

function (obj::IsNodeValid)(prm,node_value)
    padding = 1.0
    for o in obj.env.obstacles
        dist = sqrt((node_value.x - o.x)^2+(node_value.y - o.y)^2)
        if(dist<=o.r+padding)
            return false
        end
    end
    return true
end

struct IsEdgeValid
    env::SquareEnvironment
end

#Given a circle's center and radius and a line segment, find if they intersect
function circle_line_intersect(cx,cy,cr,ex,ey,lx,ly)
    dx = lx-ex
    dy = ly-ey
    fx = ex-cx
    fy = ey-cy

    #Quadratic equation is  t^2 ( d · d ) + 2t ( d · f ) +  (f · f - r^2) = 0
    #Refer to this link if needed - https://stackoverflow.com/questions/1073336/circle-line-segment-collision-detection-algorithm
    #Standard form is a.t^2 + b.t + c = 0

    a = (dx^2 + dy^2)
    b = 2*(dx*fx + dy*fy)
    c = (fx^2 + fy^2) - (cr^2)
    discriminant = (b^2 - 4*a*c)

    if(discriminant<0)
        return false
    elseif (discriminant == 0)
        t = -b/(2*a)
        if(t>=0 && t<=1)
            return true
        end
    else
        discriminant = sqrt(discriminant)
        t = (-b-discriminant)/(2*a)
        if(t>=0 && t<=1)
            return true
        end
        t = (-b+discriminant)/(2*a)
        if(t>=0 && t<=1)
            return true
        end
    end
    return false
end

function (obj::IsEdgeValid)(prm,src_node_values,des_node_values)

    padding = 1.0
    for o in obj.env.obstacles
        if(circle_line_intersect(o.x,o.y,o.r+padding,src_node_values.x,src_node_values.y,des_node_values.x,des_node_values.y))
            return false
        end
    end
    return true
end


struct EdgeCost
    env::SquareEnvironment
end

function (obj::EdgeCost)(prm,src_node_values,des_node_values)
    dist = sqrt((src_node_values.x - des_node_values.x)^2+(src_node_values.y - des_node_values.y)^2)
    return dist
end



e = SquareEnvironment(100.0,100.0,CircularObstacle[CircularObstacle(30.0,30.0,15.0),CircularObstacle(70.0,60.0,15.0)])
const MAX_NUM_NODES = 10
const MAX_NUM_EDGES = 5
get_node_values = SamplePoint(e)
is_node_valid = IsNodeValid(e)
is_edge_valid = IsEdgeValid(e)
edge_cost = EdgeCost(e)
rng_seed = 11
rng = MersenneTwister(rng_seed)
prm = generate_prm(MAX_NUM_NODES,MAX_NUM_EDGES,get_node_values,is_node_valid,is_edge_valid,edge_cost,rng,10)
