Vector = {}

function Vector.distance(x1, y1, x2, y2)
    return math.sqrt(((x1-x2)^2) + ((y1-y2)^2))
end

function Vector.addToPoint(x, y, deg, mag)
    local dx = math.cos(math.rad(deg)) * mag
    local dy = math.sin(math.rad(deg)) * mag
    return x+dx, y+dy
end