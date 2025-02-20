import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Cam").extends(gfx.sprite)

function Cam:init(x, y)
    self.points = {1, 1, 1, 1, 1, 1, 1, 1}
    self.x = x
    self.y = y
    self.phase = 0
    self.image = gfx.image.new(35, 35)
    self:moveTo(self.x, self.y)
    self:add()
end

function Cam:setPoints(points)
    self.points = points
    self:draw()
end

function Cam:draw()
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
    gfx.fillRect(16, 16, 3, 3)
        for i=0, 359 do
            local x, y = Vector.addToPoint(17, 17, i, 17 * self:magAtDeg(i))
            gfx.drawPixel(x, y)
        end
    gfx.popContext()
    self:setImage(self.image)
    self:markDirty()
end

function Cam:magAtDeg(deg)
    local index = math.floor(deg/45) + 1
    local nextIndex = index + 1 > 8 and 1 or index + 1
    local position = (deg % 45) / 45
    return self.points[index] + ((self.points[nextIndex] - self.points[index]) * position)
end

