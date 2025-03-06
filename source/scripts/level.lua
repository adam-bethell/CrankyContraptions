import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

import "scripts/cam/camShaft"
import "scripts/cam/camFollowerLinkage"
import "scripts/physics/world"
import "scripts/physics/worldUI"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Level").extends(gfx.sprite)

function Level:init()
    self.world = World()
    self.camShaft = CamShaft(self.world)
    self.worldUI = WorldUI(self.camShaft, self.world)

    self:add()

    self.camShaft:setFocus(true)
end

function Level:update()
    if self.camShaft:getFocus() then
        if self.camShaft.swapFocus then
            self.camShaft.swapFocus = false
            self.camShaft:setFocus(false)
            self.worldUI:setSelection(self.camShaft.selection)
            self.worldUI:setFocus(true)

        end
    elseif self.worldUI:getFocus() then
        if self.worldUI.swapFocus then
            self.worldUI.swapFocus = false
            self.worldUI:setFocus(false)
            self.camShaft:setSelectionX(self.worldUI:getSelectionX())
            self.camShaft:setFocus(true)
        end
    end
end