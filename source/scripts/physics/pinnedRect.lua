import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("PinnedRect").extends(Rigidbody)

function PinnedRect:init(pin1, pin2, width, height)
    self.pin1 = pin1
    self.pin2 = pin2
    local pin2pinX, pin2pinY = Vector.sub(self.pin2.x, self.pin2.y, self.pin1.x, self.pin1.y)
    --local x, y = col:center()
    --PinnedRect.super.init(self, x, y, nil, width, height, 0, {x=0,y=0}, 1, col, Rigidbody.type.kRectangle)
    self:setStatic(true)
end

function PinnedRect:update()
    if self.isStatic then
        self:calculatePosition()
        PinnedRect.super.update(self)
    else
        assert(false)
    end
end

function PinnedRect:calculatePosition()
    local pin2pinX, pin2pinY = Vector.sub(self.pin2.x, self.pin2.y, self.pin1.x, self.pin1.y)
    self:setPosition(self.pin1.x + pin2pinX / 2, self.pin1.y + pin2pinY / 2)
    local r = math.deg(math.atan(pin2pinY, pin2pinX))
    self:setRotation(r)
end

function PinnedRect:draw()
    PinnedRect.super.draw(self)
    gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    gfx.drawLine(self.pin1.x, self.pin1.y, self.pin2.x, self.pin2.y)
    gfx.fillCircleAtPoint(self.pin1.x, self.pin1.y, 5)
    gfx.fillCircleAtPoint(self.pin2.x, self.pin2.y, 5)
    gfx.setColor(gfx.kColorBlack)
end