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

    self.ball = Circle(50,50,10)
    self.ball.vX = 5
    self.ball.restitution = 0.7

    self.rbs = {}

    self.image = gfx.image.new(400,240)
    self:setImage(self.image)
    self:setZIndex(-15)
    self:moveTo(200,120)
    self:add()
end

function World:update()
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
    -- Logic
    self.ball:update()
    for i, v in ipairs(self.rbs) do
        v:update()
    end
    Collisions.checkCollisions(self.ball, self.rbs)

    -- Graphics
    -- self.image:clear(gfx.kColorClear)
    -- gfx.pushContext(self.image)
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

function World:addPinnedLine(socket1, socket2)
    local l = TwoPinLine(0,0,0,0,15)
    l.socket1 = socket1
    l.socket2 = socket2
    self.rbs[#self.rbs+1] = l

end