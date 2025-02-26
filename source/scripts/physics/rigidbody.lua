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

function Rigidbody:init(x, y, radius, width, height, rotate, velocity, restitution, collider, type)
    self.collider = collider
    self.type = type
    self.position = {x = x, y = y}
    self.radius = radius
    self.width = width
    self.height = height
    self.rotation = 0 + rotate
    self.velocity = velocity
    self.restitution = restitution
    self.isStatic = false

    -- Drawing
    self.visible = true
end

function Rigidbody.newCircle(x, y, radius, rotate, velocity, restitution, hc)
    local col = hc:circle(x, y, radius)
    col:rotate(math.rad(rotate))
    return Rigidbody(x, y, radius, nil, nil, rotate, velocity, restitution, col, Rigidbody.type.kCircle)
end

function Rigidbody.newRectangle(x, y, width, height, rotate, velocity, restitution, hc)
    local col = hc:rectangle(x - width/2, y - height/2, width, height)
    col:rotate(math.rad(rotate))
    return Rigidbody(x, y, nil, width, height, rotate, velocity, restitution, col, Rigidbody.type.kRectangle)
end

function Rigidbody:moveBy(dx, dy)
    self.position.x += dx
    self.position.y += dy
    self.collider:moveTo(self.position.x, self.position.y)
end

function Rigidbody:rotate(degrees)
    self.rotation += degrees
    self.collider:rotate(math.rad(degrees))
end

function Rigidbody:setRotation(degrees)
    self.rotation = degrees
    self.collider:setRotation(math.rad(degrees))
end

function Rigidbody:update()
    if self.isStatic then
        self.collider:moveTo(self.position.x, self.position.y)
    else
        self.velocity.x += Rigidbody.gravity.x
        self.velocity.y += Rigidbody.gravity.y
        self:moveBy(self.velocity.x, self.velocity.y)
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

    if self.type == Rigidbody.type.kCircle then
        gfx.fillCircleAtPoint(self.position.x, self.position.y, self.radius)
        return
    elseif self.type == Rigidbody.type.kRectangle then
        gfx.fillPolygon(self.collider._polygon:unpack())
        return
    end
end