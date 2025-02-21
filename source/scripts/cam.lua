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
    
    self.camImage = gfx.image.new(self.w, self.h)
    self.camSprite = gfx.sprite.new()
    self.camSprite:moveTo(self.x, self.y)
    self.camSprite:add()

    self.boxImage = gfx.image.new(self.w, self.h)
    self.boxSprite = gfx.sprite.new()
    self.boxSprite:moveTo(self.x, self.y)
    self.boxSprite:add()
end

function Cam:setWidthAndHeight(value)
    self.w = value
    self.h = value
    self.lineWidth = math.floor((value / 60) + 0.5)
    self.camImage = gfx.image.new(self.w, self.h)
    self.boxImage = gfx.image.new(self.w, self.h)
end

function Cam:setPoints(points)
    self.points = points
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
    self.camImage:clear(gfx.kColorClear)
    gfx.pushContext(self.camImage)
        gfx.setLineWidth(self.lineWidth)

        -- Cam
        local centre = math.floor(self.h / 2)
        gfx.fillRect(centre-1, centre-1, 3, 3)
        local i = 0
        local x, y = vector.addToPoint(centre, centre, i, centre * self:magAtDeg(i))
        local fx, fy = x, y
        local px, py = x, y
        for i=1, 359 do
            x, y = vector.addToPoint(centre, centre, i, centre * self:magAtDeg(i))
            if vector.distance(px, py, x, y) > 2 then
                gfx.drawLine(px, py, x, y)
            else
                gfx.fillCircleAtPoint(x, y, self.lineWidth / 2)
            end
            px, py = x, y
        end
        if vector.distance(px, py, fx, fy) > 2 then
            gfx.drawLine(px, py, fx, fy)
        end

        -- Selection circle
        if self.selectionIndex > 0 and self.selectionIndex < #self.points+1 then
            local mag = self.points[self.selectionIndex]
            x, y = vector.addToPoint(centre, centre, self:pointToDeg(self.selectionIndex), centre * mag)
            gfx.drawCircleAtPoint(x,y, 10)
        end
    gfx.popContext()
    self.camSprite:setImage(self.camImage)
    self.camSprite:markDirty()

    self.boxImage:clear(gfx.kColorClear)
    gfx.pushContext(self.boxImage)
        -- Box
        gfx.setLineWidth(self.lineWidth)
        gfx.drawRect(0, 0, self.w, self.h)

        -- Followers
        gfx.setLineWidth(self.lineWidth * 2)
        gfx.drawLine(self.w/2, 0, self.w/2, self.h/2 - self:getEdgePosition(0))
        gfx.drawLine(self.w / 2, self.h, self.w / 2, self.h/2 + self:getEdgePosition(180))
        gfx.drawLine(0, self.h / 2, self.w/2-self:getEdgePosition(270), self.h / 2)
        gfx.drawLine(self.w, self.h / 2, self.w/2+self:getEdgePosition(90), self.h / 2)
    gfx.popContext()
    self.boxSprite:setImage(self.boxImage)
    self.boxSprite:markDirty()
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
    self.camSprite:setRotation(-self.phase)
end

function Cam:getEdgePosition(rotation)
    if rotation == nil then
        rotation = 0
    end
    local deg = math.wrap(self.phase, 0, 359, rotation)
    local pos = self:magAtDeg(deg) * (self.h / 2)
    return pos
end