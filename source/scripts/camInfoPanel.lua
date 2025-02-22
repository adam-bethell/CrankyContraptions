import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/ui"


import "scripts/util/vector"
import "scripts/util/math"

import "scripts/cam"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamInfoPanel").extends(gfx.sprite)

function CamInfoPanel:init(cam, x, y, width, height, zindex)
    self.cam = cam
    self.x, self.y, self.width, self.height = x, y, width, height

    self.optionsPoints = pd.ui.gridview.new(math.floor(self.width / 2), 20)
    self.optionsPoints:setNumberOfColumns(1)
    self.optionsPoints:setContentInset(5, 5, 5, 5)
    self.optionsPoints:setNumberOfRowsInSection(1, #cam.points)
    function self.optionsPoints:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setFont(gfx.getSystemFont("bold"))
        else
            gfx.setFont(gfx.getSystemFont("normal"))
        end
        gfx.drawText("Point " .. row, x, y, width, height)
    end

    self.optionsOther = pd.ui.gridview.new(width / 2, 20)
    self.optionsOther:setNumberOfColumns(1)
    self.optionsOther:setContentInset(5, 5, 5, 5)
---@diagnostic disable-next-line: inject-field
    self.optionsOther.editOptions = {"Scale", "Size", "Speed"}
    self.optionsOther:setNumberOfRows(#self.optionsOther.editOptions)
    function self.optionsOther:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setFont(gfx.getSystemFont("bold"))
        else
            gfx.setFont(gfx.getSystemFont("normal"))
        end
        gfx.drawText(self.editOptions[row], x, y, width, height)
    end
    self.optionsOther:setSelection(2, 1, 1)

    self.img = gfx.image.new(width, height)
    self:setImage(self.img)
    self:moveTo(x, y)
    self:setZIndex(zindex)
    self:add()
end

function CamInfoPanel:update()
    self.img:clear(gfx.kColorWhite)
    gfx.pushContext(self.img)
        gfx.setLineWidth(self.cam.lineWidth)
        gfx.drawRect(0, 0, self.width, self.height)
        self.optionsPoints:drawInRect(0, 0, self.width, self.height)
        self.optionsOther:drawInRect(self.width / 2, 0, self.width, self.height)
    gfx.popContext()
    self:setImage(self.img)
    self:markDirty()


    local pS, pR, pC = self.optionsPoints:getSelection()
    local oS, oR, oC = self.optionsOther:getSelection()

    if pS == 1 then
        if pd.buttonJustPressed(pd.kButtonUp) then
            self.optionsPoints:selectPreviousRow(true)
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            self.optionsPoints:selectNextRow(true)
        end
    else
        if pd.buttonJustPressed(pd.kButtonUp) then
            self.optionsOther:selectPreviousRow(true)
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            self.optionsOther:selectNextRow(true)
        end
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.optionsPoints:setSelection(1, pR, pC)
        self.optionsOther:setSelection(2, oR, oC)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        local s, r, c = self.optionsPoints:getSelection()
        self.optionsPoints:setSelection(2, pR, pC)
        local s, r, c = self.optionsOther:getSelection()
        self.optionsOther:setSelection(1, oR, oC)
    end
end

function CamInfoPanel:getSelection()
    local pS, pR, pC = self.optionsPoints:getSelection()
    local oS, oR, oC = self.optionsOther:getSelection()
    if pS == 1 then
        return 1, pR
    end
    return 2, oR
end