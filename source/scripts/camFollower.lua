import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamFollower").extends(gfx.sprite)

function CamFollower:init(x, y)
    self.input = 0.0
    self.coeff = 1.0
    self.output = 0.0

    self.x = x
    self.y = y
    self.socket = {
        x = 0, 
        y = 0
    }
    
    self.image = gfx.image.new(47, 240-(240-y))
    self:setImage(self.image)
    self:setZIndex(-10)
    self:moveTo(x, self.image.height / 2)
    self:add()

    self:setScale(0.2)
end

function CamFollower:setInput(val)
    self.input = val
    self:calculateOutput()
end

function CamFollower:setScale(val)
    val = math.floor(val*100)/100
    self.scale = math.clamp(val, 0, 1)
    val = self.scale * (self.image.height - (47/2))
    self:setCoeff(val)
end

function CamFollower:setCoeff(val)
    self.coeff = val
    self:calculateOutput()
end

function CamFollower:calculateOutput()
    local newOutput = self.input * self.coeff
    if newOutput ~= self.output then
        self.output = newOutput
        self:draw()
    end
end

function CamFollower:draw()
    self.image:clear(gfx.kColorWhite)
    gfx.pushContext(self.image)
        gfx.setLineWidth(2)
        -- Box
        local boxTop = self.image.height - (47/2)
        local rect = pd.geometry.rect.new(0, boxTop, 47, (47/2))
        gfx.drawRect(rect)
        rect:inset(2, 2)
        gfx.drawText(tostring(math.floor(self.input*10)), rect)
        -- Follower rod
        local rodHeight = boxTop - (self.output)
        gfx.drawLine(self.image.width / 2, boxTop, self.image.width / 2, rodHeight)
        self.socket.x = self.x
        self.socket.y = rodHeight
    gfx.popContext()
    self:markDirty()
end