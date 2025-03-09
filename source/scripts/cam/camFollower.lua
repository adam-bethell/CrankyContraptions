import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamFollower").extends(gfx.sprite)

function CamFollower:init(x, y)
    self.input = 0.0
    self.coeff = 1.0
    self.targetOutput = 0.0
    self.output = 0.0
    self.maxChange = 10

    self.followerX = 0
    self.followerY = 0
    self.followerRotation = 0

    self.followerTipX, self.followerTipY = 0, 0
    self.followerBaseX, self.followerBaseY = 0, 0

    self.x = x
    self.y = y
    self.socket = {
        x = 0,
        y = 0,
        deleted = false
    }

    self.offsetX = self.x
    self.offsetY = 0
    self:adjustFollowerOffset(0,90)

    self.followerImage = gfx.image.new(400, 240)
    self.followerSprite = gfx.sprite.new(self.followerImage)
    self.followerSprite:moveTo(200,120)
    self.followerSprite:add()
    
    self.image = gfx.image.new(47, 240-(240-y))
    self:setImage(self.image)
    self:setZIndex(-1)
    self:moveTo(x, self.image.height / 2)
    self:add()

    self:setScale(0.2)
end

function CamFollower:setInput(val)
    self.input = val
    self:calculateTargetOutput()
end

function CamFollower:setScale(val)
    val = math.floor(val*100)/100
    self.scale = math.clamp(val, 0, 1)
    val = self.scale * (self.image.height - (47/2))
    self:setCoeff(val)
end

function CamFollower:setCoeff(val)
    self.coeff = val
    self:calculateTargetOutput()
end

function CamFollower:calculateTargetOutput()
    local newTargetOutput = self.input * self.coeff
    if newTargetOutput ~= self.targetOutput then
        self.targetOutput = newTargetOutput
        self:draw()
    end
end

function CamFollower:update()
    if self.output ~= self.targetOutput then
        if math.abs(self.output - self.targetOutput) <= self.maxChange then
            self.output = self.targetOutput
        elseif self.output < self.targetOutput then
            self.output += self.maxChange
        else
            self.output -= self.maxChange
        end
        self:draw()
    end
end

function CamFollower:adjustFollowerOffset(x, y)
    self.offsetX = math.clamp(self.offsetX + x, self.x-80, self.x+80)
    self.offsetY = math.clamp(self.offsetY + y, 20, 147)
end

function CamFollower:setFollowerRotation(r)
    assert(r == 0 or r == 90 or r == -90)
    self.followerRotation = r
end

function CamFollower:draw(updateBasePosition)
    if updateBasePosition == nil then
        updateBasePosition = false
    end

    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        gfx.setLineWidth(2)
        -- Box
        local boxTop = self.image.height - (47/2)
        local rect = pd.geometry.rect.new(0, boxTop, 47, (47/2))
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(rect)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(rect)
        rect:inset(2, 2)
        gfx.drawText(tostring(math.floor(self.input*10)), rect)
    gfx.popContext()
    self:markDirty()

    self.followerImage:clear(gfx.kColorClear)
    gfx.pushContext(self.followerImage)
    if updateBasePosition then
        -- Follower rod
        gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
        gfx.setLineWidth(2)
        self.followerTipX, self.followerTipY = 0, 0
        self.followerBaseX, self.followerBaseY = 0, 0
        if self.followerRotation == 0 then
            self.followerTipX = self.offsetX
            self.followerTipY = boxTop - self.output
            self.followerBaseX = self.followerTipX
            self.followerBaseY = boxTop - 4
        elseif self.followerRotation == 90 then
            self.followerTipY = self.offsetY
            self.followerTipX = self.output
            self.followerBaseX = 0
            self.followerBaseY = self.followerTipY
        elseif self.followerRotation == -90 then
            self.followerTipY = self.offsetY
            self.followerTipX = 400 - self.output
            self.followerBaseX = 400
            self.followerBaseY = self.followerTipY
        end
        gfx.drawLine(self.followerBaseX, self.followerBaseY, self.followerTipX, self.followerTipY)
        gfx.fillCircleAtPoint(self.followerTipX, self.followerTipY, 5)
        self.socket.x = self.followerTipX
        self.socket.y = self.followerTipY

        if self.followerRotation == 0 then
            gfx.drawLine(self.x, boxTop - 4, self.followerBaseX, self.followerBaseY)
        elseif self.followerRotation == 90 then
            self.followerBaseX += 4
            gfx.drawLine(self.x, boxTop - 4, 4, boxTop - 4)
            gfx.fillCircleAtPoint(4, boxTop - 4, 4)
            gfx.drawLine(4, boxTop - 4, self.followerBaseX, self.followerBaseY)
        elseif self.followerRotation == -90 then
            self.followerBaseX -= 4
            gfx.drawLine(self.x, boxTop - 4, 400-4, boxTop - 4)
            gfx.fillCircleAtPoint(400-4, boxTop - 4, 4)
            gfx.drawLine(400-4, boxTop - 4, self.followerBaseX, self.followerBaseY)
        end
        gfx.fillCircleAtPoint(self.x, boxTop - 4, 4)
        gfx.fillCircleAtPoint(self.followerBaseX, self.followerBaseY, 4)
    end
    gfx.popContext()
    self.followerSprite:markDirty()
end