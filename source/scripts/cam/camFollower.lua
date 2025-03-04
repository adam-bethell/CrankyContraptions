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
    self.targetOutput = 0.0
    self.output = 0.0
    self.maxChange = 10

    self.x = x
    self.y = y
    self.socket = {
        x = 0,
        y = 0
    }
    
    self.image = gfx.image.new(47, 240-(240-y))
    self:setImage(self.image)
    self:setZIndex(-1)
    self:moveTo(x, self.image.height / 2)
    self:add()

    self:setScale(0.2)
end

function CamFollower:setInput(val)
    self.input = val
    self:calculateTargetOutput()
end

function CamFollower:setScale(val)
    val = math.floor(val*100)/100
    self.scale = math.clamp(val, 0, 1)
    val = self.scale * (self.image.height - (47/2))
    self:setCoeff(val)
end

function CamFollower:setCoeff(val)
    self.coeff = val
    self:calculateTargetOutput()
end

function CamFollower:calculateTargetOutput()
    local newTargetOutput = self.input * self.coeff
    if newTargetOutput ~= self.targetOutput then
        self.targetOutput = newTargetOutput
        self:draw()
    end
end

function CamFollower:update()
    if self.output ~= self.targetOutput then
        if math.abs(self.output - self.targetOutput) <= self.maxChange then
            self.output = self.targetOutput
        elseif self.output < self.targetOutput then
            self.output += self.maxChange
        else
            self.output -= self.maxChange
        end
        self:draw()
    end
end

function CamFollower:draw()
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        gfx.setLineWidth(2)
        -- Box
        local boxTop = self.image.height - (47/2)
        local rect = pd.geometry.rect.new(0, boxTop, 47, (47/2))
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(rect)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(rect)
        rect:inset(2, 2)
        gfx.drawText(tostring(math.floor(self.input*10)), rect)
        -- Follower rod
        gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
        gfx.drawLine(self.image.width / 2, boxTop, self.image.width / 2, self.socket.y)
        gfx.fillCircleAtPoint(self.image.width / 2, self.socket.y, 5)
        assert(self.x >= 0 and self.x <= 400 and self.socket.y >= 0 and self.socket.y <= 240)
        self.socket.x = self.x
        self.socket.y = boxTop - (self.output)
    gfx.popContext()
    self:markDirty()
end