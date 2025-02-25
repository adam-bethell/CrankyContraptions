import "CoreLibs/object"
import "CoreLibs/graphics"

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

function Rigidbody:init(x, y, radius, width, height, rotate, velocity, restitution)
    self.collider = nil
    self.type = nil
    self.x = x
    self.y = y
    self.radius = radius
    self.width = width
    self.height = height
    self.rotation = 0 + rotate
    self.velocity = velocity
    self.restitution = restitution

    -- Drawing
    self.visible = true
end

function Rigidbody.newCircle(x, y, radius, rotate, velocity, restitution, hc)
    local rb = Rigidbody(x, y, radius, nil, nil, rotate, velocity, restitution)
    rb.collider = hc:circle(x, y, radius)
    rb.collider:rotate(rotate)
    rb.type = Rigidbody.type.kCircle
    return rb
end

function Rigidbody.newRectangle(x, y, width, height, rotate, velocity, restitution, hc)
    local rb = Rigidbody(x, y, nil, width, height, rotate, velocity, restitution)
    rb.collider = hc:rectangle(x - width/2, y - height/2, width, height)
    rb.collider:rotate(rotate)
    rb.type = Rigidbody.type.kRectangle
    return rb
end

function Rigidbody:moveBy(dx, dy)
    self.x += dx
    self.y += dy
    self.collider:moveTo(self.x, self.y)
end

function Rigidbody:rotate(degrees)
    self.rotation += degrees
    self.collider:rotate(degrees)
end

function Rigidbody:update()
    self.velocity.x += Rigidbody.gravity.x
    self.velocity.y += Rigidbody.gravity.y
    self:moveBy(self.velocity.x, self.velocity.y)
end

function Rigidbody:setVisible(visible)
    self.visible = visible
end

function Rigidbody:draw()
    if not self.visible then
        return
    end

    if self.type == Rigidbody.type.kCircle then
        gfx.fillCircleAtPoint(self.x, self.y, self.radius)
    elseif self.type == Rigidbody.type.kRectangle then
        gfx.fillPolygon(self.collider._polygon:unpack())
    end
end