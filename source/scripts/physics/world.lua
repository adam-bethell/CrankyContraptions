import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/vector"
import "scripts/physics/circle"
import "scripts/physics/twoPinLine"
import "scripts/physics/collisions"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("World").extends(gfx.sprite)

function World:init()

    self.ball_shoot = gfx.image.new("images/ball_shoot")
    assert(self.ball_shoot)

    self.ball = Circle(50,30,10, 5, 0)
    self.ball.restitution = 0.7

    self.rbs = {}
    -- self.rbs[#self.rbs+1] = TwoPinLine(0,158,300,158,20)
    -- self.rbs[#self.rbs].static = true
    -- self.rbs[#self.rbs+1] = TwoPinLine(50,138,300,138,20)
    -- self.rbs[#self.rbs].static = true
    -- self.rbs[#self.rbs+1] = TwoPinLine(100,118,300,118,20)
    -- self.rbs[#self.rbs].static = true
    -- self.rbs[#self.rbs+1] = TwoPinLine(150,98,300,98,20)
    -- self.rbs[#self.rbs].static = true
    -- self.rbs[#self.rbs+1] = TwoPinLine(200,78,300,78,20)
    -- self.rbs[#self.rbs].static = true

    self.image = gfx.image.new(400,240)
    self:setImage(self.image)
    self:setZIndex(-15)
    self:moveTo(200,120)
    self:add()

    pd.debugDraw = function ()
        Collisions.checkCollisions(self.ball, self.rbs)
    end
end

function World:update()
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        -- Background
        
        self.ball_shoot:draw(self.ball.initX - 15, self.ball.initY - 33)

        -- Logic
        self.ball:update()
        for i, v in ipairs(self.rbs) do
            local deleted = v:update()
            if deleted then
                self.rbs[i] = nil
            end
        end
        Collisions.checkCollisions(self.ball, self.rbs)

        self.ball:draw()
        for i, v in ipairs(self.rbs) do
            v:draw()
        end
    gfx.popContext()
    self:markDirty()
end

function World:addCircle(socket, radius)
    local c = Circle(0, 0, radius)
    c.socket = socket
    self.rbs[#self.rbs+1] = c
end

function World:addPinnedLine(socket1, socket2, lineWidth)
    local l = TwoPinLine(0,0,0,0,lineWidth)
    l.socket1 = socket1
    l.socket2 = socket2
    self.rbs[#self.rbs+1] = l

end

function World:removeAttached(socket)
    for i, v in pairs(self.rbs) do
        if not v.static then
            if v:isa(TwoPinLine) then
                if v.socket1 == socket or v.socket2 == socket then

                    self.rbs[i] = nil
                end
            elseif v:isa(Circle) then
                if v.socket == socket then
                    self.rbs[i] = nil
                end
            end
        end
    end
end

function World:removeUnattached()
    for i, v in pairs(self.rbs) do
        if not v.static then
            if v:isa(TwoPinLine) then
                if v.socket1.deleted or v.socket2.deleted then

                    self.rbs[i] = nil
                end
            elseif v:isa(Circle) then
                if v.socket.deleted then
                    self.rbs[i] = nil
                end
            end
        end
    end
end

function World:resetStage()
    self.ball:resetPosition()
    self.ball:resetVelocity()
end