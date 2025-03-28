import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/ui"


import "scripts/util/vector"
import "scripts/util/math"

import "scripts/cam/camFollower"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamFollowerInfoPanel").extends(gfx.sprite)

function CamFollowerInfoPanel:init(value)
    self.value = value
    self.formattedValue = math.floor(value*100)/100

    self.image = gfx.image.new(100, 50)
    self:setImage(self.image)
    self:moveTo(200, 204)
    self:setZIndex(20)
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
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        local rect = pd.geometry.rect.new(0, 0, self.image:getSize())
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(rect)
        rect:inset(2, 2)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(rect)
        rect:inset(10, 10)
        gfx.drawText("Scale: *" .. self.formattedValue .. "*", rect)
    gfx.popContext()
    self:markDirty()
end