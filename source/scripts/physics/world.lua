import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "HC/init"
import "HC/vector-light"
import "scripts/physics/rigidbody"
import "scripts/physics/pinnedRect"
import "scripts/physics/collisions"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("World").extends(gfx.sprite)



function World:init()
    self.hc = HC(150)

    self.floor = Rigidbody.newRectangle(200, 204, 400, 72, 0, {x=0, y=0}, 1, self.hc)
    self.floor:setVisible(false)
    self.floor:setStatic(true)
    self.ceiling = Rigidbody.newRectangle(200, -50, 400, 100, 0, {x=0, y=0}, 1, self.hc)
    self.ceiling:setVisible(false)
    self.ceiling:setStatic(true)
    self.leftWall = Rigidbody.newRectangle(-50, 120, 100, 240, 0, {x=0, y=0}, 1, self.hc)
    self.leftWall:setVisible(false)
    self.leftWall:setStatic(true)
    self.rightWall = Rigidbody.newRectangle(450, 120, 100, 240, 0, {x=0, y=0}, 1, self.hc)
    self.rightWall:setVisible(false)
    self.rightWall:setStatic(true)
    self.circle = Rigidbody.newCircle(25, 25, 10, 0, {x=3, y=0}, 0.9, self.hc)

    self.rbs = {
        self.floor,
        self.ceiling,
        self.leftWall,
        self.rightWall,
        self.circle
    }

    self.image = gfx.image.new(400,240)
    self:setImage(self.image)
    self:setZIndex(-2)
    self:moveTo(200,120)
    self:add()
end

function World:addCircle(socket, radius)
    local c = Rigidbody.newCircle(socket.x, socket.y, radius, 0, {x=0, y=0}, 1, self.hc)
    c:setStatic(true)
    c.position = socket
    self.rbs[#self.rbs+1] = c
end
function World:addRect(socket, width, height, rotation)
    local c = Rigidbody.newRectangle(socket.x, socket.y, width, height, rotation, {x=0, y=0}, 1, self.hc)
    c:setStatic(true)
    c.position = socket
    self.rbs[#self.rbs+1] = c
end

function World:addPinnedRect(s1, s2, length, height)
    local c = PinnedRect(s1, s2, length, height, self.hc)
    self.rbs[#self.rbs+1] = c
end

function World:update()
    --print("Velocity:",self.circle.velocity.x,self.circle.velocity.y)
    -- Apply gravity to velocity
    for i, v in ipairs(self.rbs) do
        v:update()
    end
    
    -- To save on performance, we only check collisions every other frame
    for shape, delta in pairs(self.hc:collisions(self.circle.collider)) do
        local rb = self:getRigibodyWithCollider(shape)
        if rb ~= nil then
            assert(rb.velocity ~= nil)
            Collisions.resolveCollision(self.circle, rb, delta)
        end
    end

    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        self:drawRigidbodies()
    gfx.popContext()
    self:markDirty()
end

function World:getRigibodyWithCollider(collider)
    for i=1, #self.rbs do
        if self.rbs[i].collider == collider then
            return self.rbs[i]
        end
    end
    return nil
end

function World:drawRigidbodies()
    for i=1, #self.rbs do
        self.rbs[i]:draw()
    end
end