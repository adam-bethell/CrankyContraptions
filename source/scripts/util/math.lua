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

math.getIntersectingPoint = function(ax, ay, ac, bx, by, bc)
    --Calculate the length AB.
    local ab = Vector.dist(ax, ay, bx, by)
    if (ac+bc<ab) then
        -- No intersecting point possible. Strecth instead to midpoint of ab
        local vx = bx-ax
        local vy = by-ay
        local c = ac/(ac+bc)
        vx *= c
        vy *= c
        return ax+vx, ay+vy
    end
    --Picture a line that goes straight from A to B.
    --The length D tells you how far along this line C would be if it were directly on this line. 
    --This helps us find the first part of C's position. 
    local D = (ab^2 + ac^2 - bc^2) / (2 * ab)
    --Now, imagine a line that's perpendicular (at a right angle) to the line AB. 
    --The length h tells you how far away C is from AB along this perpendicular line.
    local h = math.sqrt(ac^2 - D^2)

    -- Calculate the coordinates of the third point C
    local cx1 = ax + D * (bx - ax) / ab + h * (by - ay) / ab
    local cy1 = ay + D * (by - ay) / ab - h * (bx - ax) / ab

    local cx2 = ax + D * (bx - ax) / ab - h * (by - ay) / ab
    local cy2 = ay + D * (by - ay) / ab + h * (bx - ax) / ab

    return cx1, cy1, cx2, cy2
end