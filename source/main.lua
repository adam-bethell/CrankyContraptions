import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/cam"

local pd <const> = playdate
local gfx <const> = pd.graphics



local cam = Cam(300, 100)
cam:setPoints({1, 0, 0.1, 0.25, 0.45, 0.7, 0.8, 0.9})

function pd.update()
    local diff = pd.getCrankChange()

    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
