import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Cam").extends(gfx.sprite)

function Cam:init(x, y, zIndex)
    if zIndex == nil then
        zIndex = 0
    end
    self.points = {1, 1, 1, 1, 1, 1, 1, 1}
    self.x = x
    self.y = y
    self.rotationsPerCrank = 1.0
    self.rotationCoeff = 1.0
    self.phase = 0
    self.selectionIndex = 0
    self.camShapeChanged = true

    self.follower = nil
    self.hideFollower = false

    self.lineWidth = 1
    self.camImage = nil
    self.boxImage = nil
    self.showBG = false
    self.shaftImage = nil
    self.selectionImage = nil
    self.newImageTable = false
    self.imageTablePopulationIndex = 2
    
    self.camSprite = gfx.sprite.new()
    self.camSprite:moveTo(self.x, self.y)
    self.camSprite:setZIndex(zIndex)
    self.camSprite:add()

    self.selectionSprite = gfx.sprite.new()
    self.selectionSprite:moveTo(self.x, self.y)
    self.selectionSprite:setZIndex(zIndex)
    self.selectionSprite:add()

    self.boxSprite = gfx.sprite.new()
    self.boxSprite:moveTo(self.x, self.y)
    self.boxSprite:setZIndex(zIndex-1)
    self.boxSprite:add()

    self.shaftSprite = gfx.sprite.new()
    self.shaftSprite:moveTo(self.x, self.y)
    self.shaftSprite:setZIndex(zIndex)
    self.shaftSprite:add()

    self:setWidthAndHeight(47)
    self:moveTo(self.x, self.y)
    self:add()
end

function Cam:setWidthAndHeight(value)
    self.w = value
    self.h = value
    self.lineWidth = math.floor((value / 60) + 0.5)
    self.camImage = gfx.image.new(self.w, self.h)
    self.selectionImage = gfx.image.new(self.w, self.h)
    self.boxImage = gfx.image.new(self.w, self.h)
    self.shaftImage = gfx.image.new(self.w, self.h)
    self.shaftSprite:moveTo(self.x, self.y - (self.h / 2))
    self:generateCamImageTable()
end

function Cam:setPoints(points)
    self.points = points
    self:generateCamImageTable()
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
    self:generateCamImageTable()
end

function Cam:sizePoints(value)
    local max = 0
    local min = 1
    for i=1, #self.points do
        if self.points[i] > max then
            max = self.points[i]
        end
        if self.points[i] < min then
            min = self.points[i]
        end
    end
    max = 1 - max
    min = -min

    value = math.clamp(value, min, max)

    for i=1, #self.points do
       self.points[i] =  self.points[i] + value
    end
    self:generateCamImageTable()
end

function Cam:setUISelection(index)
    self.selectionIndex = index
end

function Cam:adjustPoint(index, change)
    local val = math.clamp(self.points[index] + change, 0, 1)
    if self.points[index] ~= val then
        self.points[index] = val
        self:generateCamImageTable()
    end
end

function Cam:generateCamImageTable()
    self.camImage:clear(gfx.kColorClear)
    gfx.pushContext(self.camImage)
        gfx.setLineWidth(self.lineWidth)
        local v = 1
        local verticies = table.create(360)
        local centre = math.floor(self.h / 2)
        local i = 0
        local v = 1
        for i=0, 359 do
            local x, y = Vector.addToPoint(centre, centre, i, centre * self:magAtDeg(i))
            verticies[v] = math.floor(x)
            verticies[v+1] = math.floor(y)
            v += 2
        end
        gfx.setColor(gfx.kColorWhite)
        gfx.fillPolygon(table.unpack(verticies))
        gfx.setColor(gfx.kColorBlack)
        gfx.drawPolygon(table.unpack(verticies))
    gfx.popContext()
    
    self.camImageTable = gfx.imagetable.new(360)
    self.camImageTable:setImage(1, self.camImage)
    self.camImageTable:setImage(2, self.camImage)
    self.imageTablePopulationIndex = 2
    self.newImageTable = true
end

function Cam:generateCamRotation(phase)
    if phase % 2 == 1 then
        phase -= 1
    end
    local img = self.camImage:rotatedImage(phase)
    self.camImageTable:setImage(phase+1, img)
    self.camImageTable:setImage(phase+2, img)
    return img
end

function Cam:update()
    if self.newImageTable then
        if self.imageTablePopulationIndex <= 358 then
            local img = self.camImageTable:getImage(self.imageTablePopulationIndex)
            if img == nil then
                self:generateCamRotation(self.imageTablePopulationIndex)
            end
            self.imageTablePopulationIndex +=2
        else
            self.newImageTable = false
        end
    end
end

function Cam:draw()
    -- Box
    if self.showBG == true then
        self.boxImage:clear(gfx.kColorWhite)
        gfx.pushContext(self.boxImage)
            gfx.setLineWidth(self.lineWidth)
            gfx.setPattern({0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF})
            gfx.fillRect(0, 0, self.boxImage.width, self.boxImage.height)
            gfx.fillRect(self.h / 2, self.h / 2, 3, 3)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(0, 0, self.w, self.h)
        gfx.popContext()
        self.boxSprite:setImage(self.boxImage)
        self.boxSprite:markDirty()
    end

    -- Selection
    self.selectionImage:clear(gfx.kColorClear)
    gfx.pushContext(self.selectionImage)
        -- Selection circle
        if self.selectionIndex > 0 and self.selectionIndex < #self.points+1 then
            local centre = math.floor(self.h / 2)
            local mag = self.points[self.selectionIndex]
            local x, y = Vector.addToPoint(centre, centre, self:pointToDeg(self.selectionIndex), centre * mag)
            gfx.drawCircleAtPoint(x,y, 10)
        end
    gfx.popContext()
    self.selectionSprite:setImage(self.selectionImage)
    self.selectionSprite:markDirty()
    
    -- Shaft
    self.shaftImage:clear(gfx.kColorClear)
    if not self.hideFollower then
        gfx.pushContext(self.shaftImage)
            gfx.setLineWidth(self.lineWidth * 2)
            gfx.drawLine(self.w/2, self.h - self:getEdgePosition(0), self.w/2, self.h - self:getEdgePosition(0) - (self.h / 2))
        gfx.popContext()
    end
    self.shaftSprite:setImage(self.shaftImage)
    self.shaftSprite:markDirty()

    -- Change image
    local rotationalPhase = math.wrap(-self.phase, 0, 359, 0)
    local imageTableIndex = rotationalPhase + 1
    local img = self.camImageTable:getImage(imageTableIndex)
    if img == nil then
        img = self:generateCamRotation(rotationalPhase)
    end
    self.camSprite:setImage(self.camImageTable:getImage(math.wrap(-self.phase, 0, 359, 0) + 1))
    self.camSprite:markDirty()
    
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

function Cam:setRotationsPerCrank(val)
    self.rotationsPerCrank = math.clamp(val, 0.1, 1)
    self.rotationCoeff = math.floor(self.rotationsPerCrank * 10) / 10
end

function Cam:adjustRotationsPerCrank(val)
    self.rotationsPerCrank = math.clamp(self.rotationsPerCrank + val, 0.1, 1)
    self.rotationCoeff = math.floor(self.rotationsPerCrank * 10) / 10
end

function Cam:rotate(val)
    val *= self.rotationCoeff
    self.phase = math.floor(math.wrap(self.phase, 0, 359, val) + 0.5)

    if self.follower ~= nil then
        self.follower:setInput(self:magAtDeg(self.phase))
    end
end

function Cam:getEdgePosition(rotation)
    if rotation == nil then
        rotation = 0
    end
    local deg = math.wrap(self.phase, 0, 359, rotation)
    local pos = self:magAtDeg(deg) * (self.h / 2)
    return pos
end

function Cam:clonePoints()
    return table.shallowcopy(self.points)
end

function Cam:remove()
    self.camSprite:remove()
    self.selectionSprite:remove()
    self.boxSprite:remove()
    self.shaftSprite:remove()
    Cam.super.remove(self)
end

function Cam:setFollower(follower)
    self.follower = follower
end

function Cam:setHideFollower(v)
    self.hideFollower = v
end