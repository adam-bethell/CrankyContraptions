import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/cam"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics



local cam = Cam(200, 120)
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
function pd.update()

    if pd.buttonJustPressed(pd.kButtonLeft) then
        index = index - 1 < 1 and #points or index - 1
        print(index)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        index = index + 1 > #points and 1 or index + 1
        print(index)
    end
    --print(index)
    cam:setUISelection(index)
    amp = points[index]


    local diff = pd.getCrankChange() / 359
    amp = math.clamp(amp + diff, 0, 1)
    points[index] = amp
    cam:setPoints(points)
    cam:draw()

    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
