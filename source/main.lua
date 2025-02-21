import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/cam"
import "scripts/util/math"
import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

local cam1 = Cam(100, 100)
local cam2 = Cam(350, 190)
local points = table.create(24)
local delta = 0.041
local val = 0
for i=1, 24 do
    points[i] = val
    val += delta
end
cam1:setPoints(points)
cam2:setPoints(table.shallowcopy(points))

local index = 1
local amp = 1

cam1:setPoints(points)
cam1:setWidthAndHeight(200)
cam2:setWidthAndHeight(100)
cam1:draw()
cam2:draw()

local image = gfx.image.new(400, 240)
local s = gfx.sprite.new(image)
s:moveTo(200, 120)
s:add()

local ax, ay = 200, 100
local bx, by = 350, 140
local gx, gy = 270, 100
local ab = vector.distance(ax, ay, bx, by)
local ac = vector.distance(ax, ay, gx, gy)
local bc = vector.distance(bx, by, gx, gy)


function pd.update()

    if pd.buttonJustPressed(pd.kButtonLeft) then
        index = index - 1 < 1 and #points or index - 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        index = index + 1 > #points and 1 or index + 1
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        cam1:scalePoints(1.2)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        cam1:scalePoints(0.8)
    end
    --print(index)
    cam1:setUISelection(index)
    amp = points[index]


    local diff = pd.getCrankChange() / 359
    amp = math.clamp(amp + diff, 0, 1)
    points[index] = amp
    
    cam1:rotate(2)
    cam1:draw()
    cam2:rotate(6)
    cam2:draw()

    local pos1 = cam1:getEdgePosition(90)
    local pos2 = cam2:getEdgePosition(0)

    gfx.pushContext(image)
        image:clear(gfx.kColorClear)
        gfx.setLineWidth(8)
        
        
        local cx, cy, dx, dy = math.getIntersectingPoint(ax+pos1, ay, ac, bx, by-pos2, bc)

        gfx.drawLine(ax, ay, ax+pos1, ay)
        gfx.drawLine(bx, by, bx, by-pos2)
        gfx.drawLine(ax+pos1, ay, cx, cy)
        gfx.drawLine(bx, by-pos2, cx, cy)
        --image:clear(gfx.kColorClear)
    gfx.popContext()
    s:setImage(image)
    s:markDirty()

    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
