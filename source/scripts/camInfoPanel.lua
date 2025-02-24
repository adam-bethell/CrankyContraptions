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
    self.optionsPoints:setSectionHeaderHeight(23)
    self.optionsPoints:setContentInset(5, 5, 5, 5)
    self.optionsPoints:setNumberOfRowsInSection(1, #cam.points)
    function self.optionsPoints:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setFont(gfx.getSystemFont("bold"))
        else
            gfx.setFont(gfx.getSystemFont("normal"))
        end
        gfx.drawText("Point " .. row, x, y+2, width, height)
    end

    function self.optionsPoints:drawSectionHeader(section, x, y, width, height)
        gfx.setFont(gfx.getSystemFont("italic"))
        gfx.drawTextInRect("Points", x, y+2, width, height)
    end

    self.optionsOther = pd.ui.gridview.new(width / 2, 20)
    self.optionsOther:setNumberOfColumns(1)
    self.optionsOther:setSectionHeaderHeight(23)
    self.optionsOther:setContentInset(5, 5, 5, 5)
---@diagnostic disable-next-line: inject-field
    self.optionsOther.editOptions = {"Scale", "Size", "Speed " .. self.cam.rotationsPerCrank}
    self.optionsOther:setNumberOfRowsInSection(1, #self.optionsOther.editOptions)
    self.optionsOther:setNumberOfRowsInSection(2, #CamInfoPanel.presets)
    
    function self.optionsOther:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.setFont(gfx.getSystemFont("bold"))
        else
            gfx.setFont(gfx.getSystemFont("normal"))
        end
        if section == 1 then
            gfx.drawText(self.editOptions[row], x, y, width, height)
        elseif section == 2 then
            gfx.drawText(CamInfoPanel.presets[row].name, x, y, width, height)
        end
    end

    function self.optionsOther:drawSectionHeader(section, x, y, width, height)
        gfx.setFont(gfx.getSystemFont("italic"))
        gfx.setLineWidth(2)
        if section == 1 then
            gfx.drawText("Cam", x, y+2, width, height)
        elseif section == 2 then
            gfx.drawLine(x, y, x + width, y)
            gfx.drawText("Presets", x, y+2, width, height)
        end
    end

    self.optionsOther:setSelection(101, 1, 1)

    self.img = gfx.image.new(width, height)
    self:setImage(self.img)
    self:setZIndex(20)
    self:moveTo(x, y)
    self:setZIndex(zindex)
    self:add()

    function pd.keyPressed(key)
        if key == "p" then
            print(table.concat(self.cam.points, ", "))
        end
    end
end

function CamInfoPanel:update()
---@diagnostic disable-next-line: inject-field
    self.optionsOther.editOptions[3] = "Speed: " .. self.cam.rotationCoeff

    self.img:clear(gfx.kColorWhite)
    gfx.pushContext(self.img)
        gfx.setLineWidth(self.cam.lineWidth)
        gfx.drawRect(0, 0, self.width, self.height)
        self.optionsPoints:drawInRect(0, 0, self.width, self.height)
        self.optionsOther:drawInRect(self.width / 2 - 10, 0, self.width, self.height)
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

    pS, pR, pC = self.optionsPoints:getSelection()
    oS, oR, oC = self.optionsOther:getSelection()

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.optionsPoints:setSelection(1, pR, pC)
        self.optionsOther:setSelection(oS+100, oR, oC)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.optionsPoints:setSelection(5, pR, pC)
        self.optionsOther:setSelection(oS-100, oR, oC)
    end

    if oS == 2 then
        if pd.buttonJustPressed(pd.kButtonA) then
            self.cam:setPoints(table.shallowcopy(CamInfoPanel.presets[oR].points))
        end
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


CamInfoPanel.presets = {
    {
        name="Circle",
        points={0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5}
    },
    {
        name="Snail",
        points={0.0603785, 0.1205367, 0.180255, 0.2393157, 0.2975031, 0.3546049, 0.4104128, 0.4647232, 0.5173379, 0.5680647, 0.6167189, 0.6631227, 0.7071068, 0.7485108, 0.7871835, 0.8229839, 0.8557813, 0.8854561, 0.9118999, 0.9350163, 0.9547209, 0.9709418, 0.9836199, 0.9927089}
    },
    {
        name="Heart",
        points={0.1205367, 0.2393157, 0.3546049, 0.4647232, 0.5680647, 0.6631227, 0.7485108, 0.8229839, 0.8854561, 0.9350163, 0.9709418, 0.9927089, 1.0, 0.9927089, 0.9709418, 0.9350162, 0.885456, 0.8229837, 0.7485108, 0.6631227, 0.5680647, 0.4647231, 0.3546049, 0.2393157}
    },
    {
        name="Egg",
        points={1.0, 0.97, 0.88, 0.79, 0.71, 0.62, 0.53, 0.44, 0.35, 0.28, 0.26, 0.23, 0.22, 0.23, 0.26, 0.28, 0.35, 0.44, 0.53, 0.62, 0.71, 0.79, 0.88, 0.97}
    },
    {
        name="Figure 8",
        points={0.0, 0.258819, 0.5, 0.7071068, 0.8660254, 0.9659258, 1.0, 0.9659258, 0.8660254, 0.7071068, 0.5000001, 0.2588189, 8.742278e-08, 0.2588193, 0.5, 0.7071069, 0.8660254, 0.9659259, 1.0, 0.9659257, 0.8660254, 0.7071065, 0.4999998, 0.2588188}
    },
    {
        name="Off centre",
        points={0, 0.002223786, 0.01733759, 0.0560427, 0.125, 0.2256012, 0.3535534, 0.4993441, 0.6495191, 0.7885804, 0.901221, 0.9745536, 1.0, 0.9745534, 0.901221, 0.7885804, 0.649519, 0.4993441, 0.3535534, 0.225601, 0.125, 0.05604262, 0.01733756, 0.00222378}
    }
}