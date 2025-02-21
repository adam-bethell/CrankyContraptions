math.clamp = function(x, min, max)
    return math.max(math.min(x, max), min)
end

math.wrap = function(value, lower, upper, change)
    value += change
    
    while value ~= math.clamp(value, lower, upper) do
        if value > upper then
            value = lower + (value - upper)
        end

        if value < lower  then
            value = upper - (lower - value)
        end
    end

    return value
end

--[[ 
function find_third_point(A, B, AC, BC)
    for x3 = -10, 10, 0.1 do
        for y3 = -10, 10, 0.1 do
            local C = {x = x3, y = y3}
            if math.abs(distance(A, C) - AC) < 0.1 and math.abs(distance(B, C) - BC) < 0.1 then
                return C
            end
        end
    end
    return nil
end
]]
math.getIntersectingPoint = function(ax, ay, ac, bx, by, bc)
    -- Calculate the constants
    local ab = vector.distance(ax, ay, bx, by)
    local D = (ab^2 + ac^2 - bc^2) / (2 * ab)
    local h = math.sqrt(ac^2 - D^2)

    -- Calculate the coordinates of the third point C
    local x3_1 = ax + D * (bx - ax) / ab + h * (by - ay) / ab
    local y3_1 = ay + D * (by - ay) / ab - h * (bx - ax) / ab

    local x3_2 = ax + D * (bx - ax) / ab - h * (by - ay) / ab
    local y3_2 = ay + D * (by - ay) / ab + h * (bx - ax) / ab

    return x3_1, y3_1, x3_2, y3_2
end