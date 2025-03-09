import "CoreLibs/object"
import "CoreLibs/graphics"
import "scripts/util/math"
import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

local buttonDpad <const> = "▲"
local buttonA <const> = "◆"
local buttonB <const> = "◇"
local buttonCrank <const> = "\u{25ef}"

class("HelperUI").extends(gfx.sprite)

function HelperUI:init()
    self.helpInfo = ""

    self.image = gfx.image.new(400, 20)
    self:setImage(self.image)
    self:setZIndex(40)
    self:moveTo(200, 10)
    self:add()
end

function HelperUI:setText(dPadText, bButtonText, aButtonText, crankText)
    self.helpInfo = ""
    if dPadText ~= "" then
        self.helpInfo = self.helpInfo .. buttonDpad .. " " .. dPadText .. " "
    end
    if bButtonText ~= "" then
        self.helpInfo = self.helpInfo .. buttonB .. " " .. bButtonText .. " "
    end
    if aButtonText ~= "" then 
        self.helpInfo = self.helpInfo .. buttonA .. " " .. aButtonText .. " "
    end
    if crankText ~= "" then
        self.helpInfo = self.helpInfo .. buttonCrank .. " " .. crankText .. " "
    end
end

function HelperUI:update()
    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        local w, h = gfx.drawTextInRect(self.helpInfo, 0, 0, 400, 20, nil, nil, kTextAlignment.center)
        gfx.setColor(gfx.kColorClear)
        gfx.fillRect(0, 0, 200-w/2, h)
        gfx.fillRect(200+w/2, 0, 200-w/2, h)
    gfx.popContext()
    self:markDirty()
end