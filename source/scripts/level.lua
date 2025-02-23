import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

import "scripts/camShaft"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Level").extends(gfx.sprite)

function Level:init()
    self.camShaft = CamShaft()
    self.camShaft:setFocus(false)

    self.world = World()
    self.world:setFocus(false)

    self.selections = {}
    self.selections.kSelectionCamShaft = 1
    self.selections.kSelectionWorld = 2

    self.selection = self.selections.kSelectionCamShaft
    self.selectionImage = gfx.image.new("images/dither_pattern_400_145")
    assert(self.selectionImage)
    self.selectionPositions = {
        {200, 230},
        {200, 90}
    }
    self.selectionSprite = gfx.sprite.new(self.selectionImage)
    self.selectionSprite:moveTo(self:getSelectionPosition())
    self.selectionSprite:add()
    self.selectionSprite:setVisible(true)

    self:add()

    -- Simulate giving focus to the world object
    self.selection = self.selections.kSelectionWorld
    self.selectionSprite:moveTo(self:getSelectionPosition())
    self:giveFocusToSelection()
end

function Level:getSelectionPosition()
    return table.unpack(self.selectionPositions[self.selection])
end

function Level:giveFocusToSelection()
    self.selectionSprite:setVisible(false)
    if self.selection == self.selections.kSelectionCamShaft then
        self.camShaft:setFocus(true)
    elseif self.selection == self.selections.kSelectionWorld then
        self.world:setFocus(true)
    end
end

function Level:update()
    if self.camShaft:getFocus() then
        if pd.buttonJustPressed(pd.kButtonB) then
            if self.camShaft:canLosefocus() then
                self.camShaft:setFocus(false)
                self.selectionSprite:setVisible(true)
            end
        end
    else -- Not sub components focussed
        if pd.buttonJustPressed(pd.kButtonUp) then
            self.selection = self.selections.kSelectionWorld
            self.selectionSprite:moveTo(self:getSelectionPosition())
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            self.selection = self.selections.kSelectionCamShaft
            self.selectionSprite:moveTo(self:getSelectionPosition())
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            self:giveFocusToSelection()
        end
    end
end