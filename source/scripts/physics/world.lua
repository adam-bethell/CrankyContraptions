import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "HC/init"
import "HC/vector-light"
import "scripts/physics/rigidbody"
import "scripts/physics/collisions"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("World").extends(gfx.sprite)



function World:init()
    self.hc = HC()

    self.floor = Rigidbody.newRectangle(200, 204, 400, 72, 0, {x=0, y=0}, 1, self.hc)
    self.floor:setVisible(false)
    self.circle = Rigidbody.newCircle(100, 100, 10, 0, {x=0, y=0}, 0.7, self.hc)
    --printTable(self.circle)
    self.rbs = {
        self.floor,
        self.circle
    }

    self.image = gfx.image.new(400,240)
    self:setImage(self.image)
    self:moveTo(200,120)
    self:add()
end

function World:update()
    --print("Velocity:",self.circle.velocity.x,self.circle.velocity.y)
    -- Apply gravity to velocity
    self.circle:update()

    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        -- Collisions: being done here so debug info can be drawn
        for shape, delta in pairs(self.hc:collisions(self.circle.collider)) do
            Collisions.resolveCollision(self.circle, self:getRigibodyWithCollider(shape), delta)
        end

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