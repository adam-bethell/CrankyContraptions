import "scripts/util/vector"
import "scripts/physics/circle"
import "scripts/physics/twoPinLine"

import "CoreLibs/graphics"
local gfx <const> = playdate.graphics

-- Helper function to calculate the squared distance between two points
local function squared_distance(x1, y1, x2, y2)
    return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

-- Function to calculate the distance between a point and a line segment
local function distancePointToLine(x0, y0, x1, y1, x2, y2)
    -- Calculate the squared length of the segment
    local segment_length_squared = squared_distance(x1, y1, x2, y2)

    if segment_length_squared == 0 then
        -- The segment is actually a point
        return math.sqrt(squared_distance(x0, y0, x1, y1))
    end

    -- Calculate the projection of point onto the segment
    local t = ((x0 - x1) * (x2 - x1) + (y0 - y1) * (y2 - y1)) / segment_length_squared
    t = math.max(0, math.min(1, t))

    -- Find the projection point on the segment
    local projection_x = x1 + t * (x2 - x1)
    local projection_y = y1 + t * (y2 - y1)

    -- Calculate the distance from the point to the projection point
    return math.sqrt(squared_distance(x0, y0, projection_x, projection_y))
end

local function closestPointOnLine(px, py, x1, y1, x2, y2)
    -- Direction vector of the line
    local dir_x, dir_y = Vector.sub(x2, y2, x1, y1)

    -- Vector from the point to the line point
    local vec_x, vec_y = px - x1, py - y1

    -- Projection scale factor
    local t = (vec_x * dir_x + vec_y * dir_y) / (dir_x * dir_x + dir_y * dir_y)

    -- Calculate the closest point
    local closest_x = x1 + t * dir_x
    local closest_y = y1 + t * dir_y

    return closest_x, closest_y
end

Collisions = {}
function Collisions.checkCollisions(rb, cols)
    -- Check colliders
    for i, c in ipairs(cols) do
        if c:isa(Circle) then
            local d = Vector.dist(rb.x, rb.y, c.x, c.y)
            d = d - rb.radius - c.radius
            if d <= 0 then -- Collision
                -- Separating vector
                local svX, svY = Vector.sub(rb.x, rb.y, c.x, c.y)
                svX, svY = Vector.normalize(svX, svY)
                svX, svY = Vector.mul(math.abs(d), svX, svY)

                -- Resolve
                Collisions.resolveCollision(rb, c, svX, svY)
            end
        elseif c:isa(TwoPinLine) then
            local d = distancePointToLine(rb.x, rb.y, c.x1, c.y1, c.x2, c.y2)
            d = d - rb.radius - (c.lineWidth / 2)
            if d <= 0 then
                -- Separating vector
                local px, py = closestPointOnLine(rb.x, rb.y, c.x1, c.y1, c.x2, c.y2)
                local svX, svY = Vector.sub(rb.x, rb.y, px, py)
                svX, svY = Vector.normalize(svX, svY)
                svX, svY = Vector.mul(math.abs(d), svX, svY)
                -- print("Collision Data")
                -- print("in:", rb.vX, rb.vY)
                -- print("sv:", svX, svY)

                 -- Resolve
                Collisions.resolveCollision(rb, c, svX, svY)
                -- print("out:", rb.vX, rb.vY)
                -- assert(true)
            end
        end
    end

    -- Check bounds
    local sumSvX, sumSvY = 0, 0
    if rb.x - rb.radius < 0 then
        sumSvX -= rb.x - rb.radius
    elseif rb.x + rb.radius > 400 then
        sumSvX -= rb.x + rb.radius - 400
    end
    if rb.y - rb.radius < 0 then
        sumSvY -= rb.y - rb.radius
    elseif rb.y + rb.radius > 168 then
        sumSvY -= rb.y + rb.radius - 168
    end
    if sumSvX ~= 0 or sumSvY ~= 0 then
        -- Resolve
        Collisions.resolveCollision(rb, {vX=0,vY=0}, sumSvX, sumSvY)
    end
end

function Collisions.resolveCollision(b, o, svX, svY)
    if svX == 0 and svY == 0 then
        return
    end

    --- Calculating impulse
    -- Calculate relative velocity
    -- rv = a.velocity - b.velocity
    local rvX, rvY = Vector.sub(b.vX, b.vY, o.vX, o.vY)

    -- Calculate relative velocity in terms of the normal direction
    local nX, nY = Vector.normalize(svX, svY)
    local velAlongNormal = Vector.dot(rvX, rvY, nX, nY)

    -- Do not resolve if velocities are separating 
    --if (velAlongNormal > 0) then
    --    return
    --end

    --- Move A back outside of the object it colided with
    b.x += svX
    b.y += svY

    -- Apply Friction
    b.vX, b.vY = Vector.mul(0.9, b.vX, b.vY)

    -- Calculate impulse scalar
    local impulse_scalar = -((1 + b.restitution) * velAlongNormal)

    -- Calculate impulse vector
    local impvX, impvY = Vector.mul(impulse_scalar, nX, nY)

    b.vX, b.vY = Vector.add(b.vX, b.vY, impvX, impvY)
end


