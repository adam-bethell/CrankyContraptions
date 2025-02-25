import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "HC/init"
import "HC/vector-light"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("World").extends(gfx.sprite)

function World:init()
    self.hc = HC()
    -- Floor
    self.floor = {
        x = 200,
        y = 240,
        velocity = {x = 0, y = 0}
    }

    self.rect = self.hc:rectangle(100,200,200,40)

    self.circle = {
        collider = self.hc:circle(100,100,20),
        x = 100,
        y = 100,
        radius = 20,
        rotation = 0,
        
        velocity = {x = 0, y = 0},
        mass = 10,
        restitution = 0.8
    }

    self.mover = {
        collider = self.hc:rectangle(0,0,50,240),
        x = 25,
        y = 120,
        width = 50,
        height = 240,
        rotation = 0,
        velocity = {x = 1, y = 0}
    }
    --self.mover.collider:rotate(-45)

    self.image = gfx.image.new(400,240)
    self:setImage(self.image)
    self:moveTo(200,120)
    self:add()
end

local gravity = {
    x=0*0.03, -- scale for 30fps
    y=4*0.03 -- scale for 30fps
}

function World:update()
    --print("Velocity:",self.circle.velocity.x,self.circle.velocity.y)
    -- Apply gravity to velocity
    self.circle.velocity.y += gravity.y

    -- Move shapes by their own velocity
    self.circle.x += self.circle.velocity.x
    self.circle.y += self.circle.velocity.y

    self.mover.x += self.mover.velocity.x
    self.mover.collider:moveTo(self.mover.x, self.mover.y)
    

    self.circle.collider:moveTo(self.circle.x, self.circle.y)

    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)

        -- Collisions: being done here so debug info can be drawn
        for shape, delta in pairs(self.hc:collisions(self.circle.collider)) do
            -- Circle collided with shape with a separating vector of delta.x, delta.y
            if shape == self.mover.collider then
                ResolveCollision(self.circle, self.mover, delta)
            else
                ResolveCollision(self.circle, self.floor, delta)
            end
        end

        -- Draw
        local x, y, r = self.circle.collider:outcircle()
        gfx.drawCircleAtPoint(x, y, r)
        gfx.drawRect(self.rect:xywh())
        local x1, y1, x2, y2, x3, y3, x4, y4 = self.mover.collider._polygon:unpack()
        gfx.drawLine(x1,y1,x2,y2)
        gfx.drawLine(x2,y2,x3,y3)
        gfx.drawLine(x3,y3,x4,y4)
        gfx.drawLine(x4,y4,x1,y1)
    gfx.popContext()
    self:markDirty()
end



function ResolveCollision(A, B, delta)
    if delta.x == 0 and delta.y == 0 then
        return
    end

    --- Move A back outside of the object it colided with
    A.x += delta.x
    A.y += delta.y

    -- Apply Friction
    A.velocity.x, A.velocity.y = Vector_light.mul(0.9, A.velocity.x, A.velocity.y)

    --- Calculating impulse
    -- Calculate relative velocity
    -- rv = A.velocity - B.velocity
    local rv = {}
    rv.x, rv.y = Vector_light.sub(A.velocity.x, A.velocity.y, B.velocity.x, B.velocity.y)

    -- Calculate relative velocity in terms of the normal direction
    local normal = {}
    normal.x, normal.y = Vector_light.normalize(delta.x, delta.y)
    local velAlongNormal = Vector_light.dot(rv.x, rv.y, normal.x, normal.y)

    -- Do not resolve if velocities are separating 
    if (velAlongNormal > 0) then
        return
    end

    -- Calculate the effective mass
    local effective_mass = A.mass

    -- Calculate impulse scalar
    local impulse_scalar = -((1 + A.restitution) * velAlongNormal)

    -- Calculate impulse vector
    local impulse_vector = {}
    impulse_vector.x, impulse_vector.y = Vector_light.mul(impulse_scalar, normal.x, normal.y)

    A.velocity.x, A.velocity.y = Vector_light.add(A.velocity.x, A.velocity.y, impulse_vector.x, impulse_vector.y)
end
