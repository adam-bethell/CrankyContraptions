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

local level = Level()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
