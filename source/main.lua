import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/osc"
import "scripts/scope"

local pd <const> = playdate
local gfx <const> = pd.graphics

local osc1 = Osc(150, 100, 0)
local osc2 = Osc(150, 150, 0)

local scope = Scope(200, 100, 0)

local monDegs = 0
local monImage = gfx.image.new(32,32)
gfx.pushContext(monImage)
    gfx.setLineWidth(1)
    gfx.drawCircleInRect(0, 0, 32, 32)
    gfx.setLineWidth(2)
    gfx.drawLine(16, 16, 16, 0)
gfx.popContext()
local monitor = gfx.sprite.new(monImage)
monitor:moveTo(100,100)
monitor:add()

function pd.update()
    local diff = pd.getCrankChange()
    monDegs += diff
    monitor:setRotation(monDegs)

    local amp = 0
    amp += osc1:incrPhase(diff)
    amp += osc2:incrPhase(diff * 2)
    amp *= 0.5

    scope:updateAmp(amp)

    gfx.sprite.update()
    pd.timer.updateTimers()

    pd.drawFPS(0, 0)
end
