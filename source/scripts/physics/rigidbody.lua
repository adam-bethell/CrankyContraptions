import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/physics/bump_light"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Rigidbody").extends()

Rigidbody.type = {
    kCircle = 1,
    kRectangle = 2
}
Rigidbody.gravity = {
    x=0*0.03, -- scale for 30fps
    y=9.8*0.03 -- scale for 30fps
}

function Rigidbody:init(x, y, radius, width, height, velocity, restitution, collider, type)
    self.type = type
    self.position = {x=x,y=y}
    self.radius = radius
    self.width = width
    self.height = height
    self.vertices = {}
    self.rotation = 0
    self.velocity = velocity
    self.restitution = restitution
    self.isStatic = false

    -- Drawing
    self.visible = true
end

function Rigidbody.newCircle(x, y, radius, velocity, restitution, collidesWith)
    return Rigidbody(x, y, radius, nil, nil, velocity, restitution, collidesWith, Rigidbody.type.kCircle)
end

function Rigidbody.newRectangle(x, y, width, height, velocity, restitution, collidesWith)
    local rb = Rigidbody(x, y, nil, width, height, velocity, restitution, collidesWith, Rigidbody.type.kRectangle)
    rb.vertices = {
        x, y,
        x, y + height,
        x + width, y + height,
        x + width, y
    }
    return rb
end

function Rigidbody:moveBy(dx, dy)
    self.position.x += dx
    self.position.y += dy
end

function Rigidbody:moveByVelocity()
    self:moveBy(self.velocity.x, self.velocity.y)
end

function Rigidbody:rotate(degrees)
    self.rotation = math.wrap(self.rotation, 0, 359, degrees)
    if self.type == Rigidbody.type.kRectangle then
        self:rotateRect(math.rad(degrees))
    end
end

function Rigidbody:setRotation(degrees)
	self:rotate(degrees - self.rotation)
end

function Rigidbody:nextMove()
    if not self.isStatic then
        self.velocity.x += Rigidbody.gravity.x
        self.velocity.y += Rigidbody.gravity.y

        return Vector.add(self.position.x, self.position.y, self.velocity.x, self.velocity.y)
    end
end

function Rigidbody:setVisible(visible)
    self.visible = visible
end

function Rigidbody:setStatic(value)
    self.isStatic = value
end

function Rigidbody:setPosition(x, y)
    self.position.x = x
    self.position.y = y
end

function Rigidbody:draw()
    if not self.visible then
        return
    end

    --gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    if self.type == Rigidbody.type.kCircle then
        gfx.drawCircleAtPoint(self.position.x, self.position.y, self.radius)
    elseif self.type == Rigidbody.type.kRectangle then
        gfx.drawPolygon(table.unpack(self.vertices))
    end
    --gfx.setColor(gfx.kColorBlack)
end

function Rigidbody:rotateRect(rads)
    -- Rotate vertices
    local cx = self.position.x + (self.width / 2)
    local cy = self.position.y + (self.height / 2)

	for i=1, #self.vertices, 2 do
		local vx = self.vertices[i]
        local vy = self.vertices[i+1]
		vx, vy = Vector.add(cx, cy, Vector.rotate(rads, vx-cx, vy-cy))
        self.vertices[i] = vx
        self.vertices[i+1] = vy
	end
end

function Rigidbody.detectCollision(rbA, rbB, gx, gy)
    assert(rbA.type + rbB.type == 3, "rbA and rbB must be a circle and square")

    -- Rotate so Bump can be used
    local rect = rbA
    local cir = rbB
    if rbA.type == Rigidbody.type.kCircle then
        cir = rbA
        rect = rbB
    end

    local rectRads = math.rad(rect.rotation)

    local cx, cy = cir.position.x - cir.radius, cir.position.y - cir.radius
    local cw = cir.radius * 2
    local rx, ry, rw, rh = rect.vertices[1], rect.vertices[2], rect.width, rect.height
    if rect.rotation ~= 0 then
        local r2cX, r2cY = Vector.sub(cir.position.x, cir.position.y, rect.vertices[1], rect.vertices[2])
        gfx.drawLine(rect.vertices[1], rect.vertices[2], rect.vertices[1]+r2cX, rect.vertices[2]+r2cY)
        gfx.drawLine(rect.vertices[1], rect.vertices[2], gx, gy)
        cx, cy = Vector.rotate(-rectRads, r2cX, r2cY)
        gfx.drawLine(200, 120, 200+cx, 120+cy)
        cx -= cir.radius
        cy -= cir.radius
        --gfx.drawLine(200, 120, 200+cx+cir.radius, 120+cy+cir.radius)
        rx, ry = 0, 0
        local r2gX, r2gY = Vector.sub(gx, gy, rect.vertices[1], rect.vertices[2])
        gx, gy = Vector.rotate(-rectRads, r2gX, r2gY)
        gx -= cir.radius
        gy -= cir.radius
        gfx.drawLine(200, 120, 200+gx, 120+gy)
    end

    gfx.drawRect(200+cx,120+cy, cir.radius*2, cir.radius*2)
    gfx.drawRect(rx + 200, ry + 120, rw, rh)

    local info = nil
    if rbA == rect then
        info = Bump.detectCollision(rx, ry, rw, rh, cx, cy, cw, cw, gx, gy)
    else
        info = Bump.detectCollision(cx, cy, cw, cw, rx, ry, rw, rh, gx, gy)
    end
    if info ~= nil then
        info.normal.oldX, info.normal.oldY = info.normal.x, info.normal.y
        info.normal.x, info.normal.y = Vector.rotate(rectRads, info.normal.x, info.normal.y)
    end
    return info
    --[[ -- Cast ray from the circles frame of reference
    if rbA == rect then
        gx, gy = Vector.add(cx, cy, -gx, -gy)
    end

    -- Collition based on raycast
    local ti1, ti2, nx, ny = Bump.raycast(rx, ry, rw, rh, cx, cy, gx, gy, 0, 1)
    if ti1 == nil then return nil end
    print(nx, ny)

    local dx, dy = gx-cx, gy-cy
    local ix = cx + dx * ti1
    local iy = cy + dy * ti1
    gfx.drawCircleAtPoint(200+ix, 120+iy, 3)

    -- Rotate back
    ix, iy = Vector.rotate(rectRads, ix, iy)
    ix = rect.vertices[1] + ix
    iy = rect.vertices[2] + iy
    gfx.drawCircleAtPoint(ix, iy, 3)
    return ix, iy ]]
end

function Rigidbody.resolveCollision(cir, rect, normal)
    --- Calculating impulse
    -- Calculate relative velocity
    -- rv = a.velocity - b.velocity
    local rv = {}
    rv.x, rv.y = Vector.sub(cir.velocity.x, cir.velocity.y, rect.velocity.x, rect.velocity.y)

    -- Calculate relative velocity in terms of the normal direction
    local velAlongNormal = Vector.dot(rv.x, rv.y, normal.x, normal.y)

    -- Do not resolve if velocities are separating 
    if (velAlongNormal > 0) then
        return
    end

    --- Move A back outside of the object it colided with
    --a.position.x += separatingVector.x
    --a.position.y += separatingVector.y

    -- Apply Friction
    cir.velocity.x, cir.velocity.y = Vector.mul(0.9, cir.velocity.x, cir.velocity.y)

    -- Calculate the effective mass
    -- This may be used inthe future for handing our impulse to 2 objects
    --local effective_mass = a.mass

    -- Calculate impulse scalar
    local impulse_scalar = -((1 + cir.restitution) * velAlongNormal)

    -- Calculate impulse vector
    local impulse_vector = {}
    impulse_vector.x, impulse_vector.y = Vector.mul(impulse_scalar, normal.x, normal.y)

    cir.velocity.x, cir.velocity.y = Vector.add(cir.velocity.x, cir.velocity.y, impulse_vector.x, impulse_vector.y)
end