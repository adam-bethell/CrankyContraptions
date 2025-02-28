import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

import "scripts/level"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

--local level = Level()

import "scripts/physics/rigidbody"

local function intersects(circle_x, circle_y, radius, rect_x_min, rect_x_max, rect_y_min, rect_y_max)
    -- Find the closest point on the rectangle to the circle's center
    --print(circle_x, rect_x_min, rect_x_max)
    --print(circle_y, rect_y_min, rect_y_max)
    local closest_x = math.clamp(circle_x, rect_x_min, rect_x_max)
    local closest_y = math.clamp(circle_y, rect_y_min, rect_y_max)
    --print(closest_x, closest_y)

    -- Calculate the distance between the circle's center and the closest point
    local distance_x = circle_x - closest_x
    local distance_y = circle_y - closest_y
    local distance_squared = distance_x * distance_x + distance_y * distance_y

    -- Check if the distance is less than or equal to the radius squared
    return distance_squared <= radius * radius
end


local canvasImage = gfx.image.new(400, 240)
local canvas = gfx.sprite.new(canvasImage)
canvas:moveTo(200, 120)
canvas:add()

local circle = Rigidbody.newCircle(107, 90, 10, {x=0,y=0}, 0.7, 1)
local box = Rigidbody.newRectangle(100, 130, 50, 10, {x=0,y=0}, 1, 1)
box:rotate(-140)
function pd.update()
    local gx, gy = circle:nextMove()
    


    canvasImage:clear(gfx.kColorClear)
    gfx.pushContext(canvasImage)
        gfx.drawCircleAtPoint(circle.position.x, circle.position.y, 2)
        --gfx.drawLine(circle.position.x, circle.position.y, gx, gy)
        --gfx.drawLine(box.vertices[1], box.vertices[2], gx, gy)

        local results = Rigidbody.detectCollision(circle, box, gx, gy)
        if results ~= nil then -- collision detected
            gfx.drawRect(results.touch.x+200, results.touch.y+120, circle.radius*2, circle.radius*2)

            local r = intersects(
                results.itemRect.x+200+circle.radius+2,
                results.itemRect.y+120+circle.radius+2,
                circle.radius,
                0 + 200,
                50 + 200,
                0 + 120,
                10 + 120
            )

            if r then
                printTable(results.normal)
                Rigidbody.resolveCollision(circle, box, results.normal)
            end
        end
        

        circle:draw()
        box:draw()
    gfx.popContext()
    canvas:markDirty()

    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(0, 0)

    circle:moveByVelocity()
end

