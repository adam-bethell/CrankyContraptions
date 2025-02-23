import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/ui"


import "scripts/util/vector"
import "scripts/util/math"

import "scripts/camFollower"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamFollowerInfoPanel").extends(gfx.sprite)

function CamFollowerInfoPanel:init(value)
    self.value = value
    self.formattedValue = math.floor(value*100)/100

    self.image = gfx.image.new(100, 50)
    self:setImage(self.image)
    self:moveTo(200, 120)
    self:add()

    self:draw()
end

function CamFollowerInfoPanel:getValue()
    return self.value
end

function CamFollowerInfoPanel:updateEditor(change)
    if change ~= 0 then
        self.value = math.clamp(self.value + change, 0, 1)
        self.formattedValue = math.floor(self.value*100)/100

        self:draw()
    end
end

function CamFollowerInfoPanel:draw()
    self.image:clear(gfx.kColorWhite)
    gfx.pushContext(self.image)
        gfx.setLineWidth(2)
        gfx.drawRect(0, 0, 100, 50)
        gfx.setFont(gfx.getFont(), "bold")
        gfx.drawText("Scale: " .. self.formattedValue, 10, 10, 80, 30)
    gfx.popContext()
    self:markDirty()
end