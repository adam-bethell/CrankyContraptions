import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/cam"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics



local cam = Cam(100, 120)
local points = table.create(24)
local delta = 0.041
local val = 0
for i=1, 24 do
    points[i] = val
    --points[i] = 1
    val += delta
end
--points[1] = 0

local index = 1
local amp = 1

cam:setPoints(points)
cam:setWidthAndHeight(200)
cam:draw()

local image = gfx.image.new(400, 240)
local s = gfx.sprite.new(image)
s:moveTo(200, 120)
s:add()

function pd.update()

    if pd.buttonJustPressed(pd.kButtonLeft) then
        index = index - 1 < 1 and #points or index - 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        index = index + 1 > #points and 1 or index + 1
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        cam:scalePoints(1.2)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        cam:scalePoints(0.8)
    end
    --print(index)
    cam:setUISelection(index)
    amp = points[index]


    local diff = pd.getCrankChange() / 359
    amp = math.clamp(amp + diff, 0, 1)
    points[index] = amp
    cam:setPoints(points)
    cam:draw()

    cam:rotate(1)
    local mag = cam:getMagnitude(90)

    gfx.pushContext(image)
        image:clear(gfx.kColorClear)
        gfx.setLineWidth(10)
        gfx.drawLine(100 + (mag*100), 120, 250 + (mag*100), 120)
    gfx.popContext()
    s:setImage(image)
    s:markDirty()

    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
