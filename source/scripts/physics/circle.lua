import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Circle").extends()

function Circle:init(x, y, radius, vx, vy)
    
    self.x = x
    self.y = y
    self.initX = x
    self.initY = y
    self.radius = radius
    self.vX = vx or 0
    self.vY = vy or 0
    self.initVX = vx or 0
    self.initVY = vy or 0
    self.restitution = 1
    self.socket = nil

    self.static = false
end

function Circle:draw()
    gfx.fillCircleAtPoint(self.x,self.y,self.radius)
end

function Circle:applyGravity()
    self.vY += 0.294 -- 9.9 * (1/30fps) = gravity to apply per frame
end

function Circle:move()
    self.x += self.vX
    self.y += self.vY
end

function Circle:update()
    if self.socket ~= nil then
        self:moveTo(self.socket.x, self.socket.y)
    else
        self:applyGravity()
        self:move()
    end
end

function Circle:moveTo(x, y)
    self.x = x
    self.y = y
end

function Circle:resetPosition()
    self.x = self.initX
    self.y = self.initY
end

function Circle:resetVelocity()
    self.vX = self.initVX
    self.vY = self.initVY 
end