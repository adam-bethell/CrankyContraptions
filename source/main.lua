import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

import "scripts/cam"
import "scripts/camShaft"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

local camShaft = CamShaft()
camShaft:focus(true)

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
