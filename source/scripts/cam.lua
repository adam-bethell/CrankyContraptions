import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Cam").extends(gfx.sprite)

function Cam:init(x, y)
    self.points = {1, 1, 1, 1, 1, 1, 1, 1}
    self.x = x
    self.y = y
    self.w = 35
    self.h = 35
    self.lineWidth = 1
    self.phase = 0
    self.selectionIndex = 0
    self.image = gfx.image.new(self.w, self.h)
    self:moveTo(self.x, self.y)
    self:add()
end

function Cam:setWidthAndHeight(value)
    self.w = value
    self.h = value
    self.lineWidth = math.floor((value / 70) + 0.5)
    self.image = gfx.image.new(self.w, self.h)
end

function Cam:setPoints(points)
    self.points = points
    --printTable(points)
    
end

function Cam:setUISelection(index)
    self.selectionIndex = index
end

function Cam:scalePoints(value)
    local max = 0
    for i=1, #self.points do
        if self.points[i] > max then
            max = self.points[i]
        end

    end
    
    max = 1 / max
    local min = 0.1

    value = math.clamp(value, min, max)

    for i=1, #self.points do
       self.points[i] =  self.points[i] * value
    end
end

function Cam:draw()
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        gfx.setLineWidth(self.lineWidth)
        local centre = math.floor(self.h / 2)
        gfx.fillRect(centre-1, centre-1, 3, 3)
        local i = 0
        local x, y = Vector.addToPoint(centre, centre, i, centre * self:magAtDeg(i))
        local fx, fy = x, y
        local px, py = x, y
        for i=1, 359 do
            x, y = Vector.addToPoint(centre, centre, i, centre * self:magAtDeg(i))
            if Vector.distance(px, py, x, y) > 2 then
                gfx.drawLine(px, py, x, y)
            else
                gfx.fillCircleAtPoint(x, y, self.lineWidth / 2)
            end
            px, py = x, y
        end
        if Vector.distance(px, py, fx, fy) > 2 then
            gfx.drawLine(px, py, fx, fy)
        end

        -- DEBUG LINE
        if self.selectionIndex > 0 and self.selectionIndex < #self.points+1 then
            --print(self.selectionIndex)
            local mag = self.points[self.selectionIndex]
            --print(mag)
            x, y = Vector.addToPoint(centre, centre, self:pointToDeg(self.selectionIndex), centre * mag)
            gfx.drawCircleAtPoint(x,y, 10)
        end
    gfx.popContext()
    self:setImage(self.image)
    self:markDirty()
end

function Cam:magAtDeg(deg)
    local interval = 360 / #self.points
    local index = math.floor(deg/interval) + 1
    local nextIndex = index + 1 > #self.points and 1 or index + 1
    local position = (deg % interval) / interval
    return self.points[index] + ((self.points[nextIndex] - self.points[index]) * position)
end

function Cam:pointToDeg(index)
    local interval = 360 / #self.points
    return interval * (index - 1)
end

function Cam:rotate(val)
    self.phase = math.wrap(self.phase, 0, 359, val)
    self:setRotation(-self.phase)
end

function Cam:getMagnitude(rotation)
    rotation = nil and 0 or rotation
    local deg = math.wrap(self.phase, 0, 359, rotation)
    return self:magAtDeg(deg)
end