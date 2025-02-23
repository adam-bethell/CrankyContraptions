import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "scripts/util/vector"
import "scripts/util/math"

import "scripts/cam"
import "scripts/camInfoPanel"
import "scripts/camFollower"
import "scripts/camFollowerInfoPanel"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamShaft").extends(gfx.sprite)

function CamShaft:init(n)
    if n == nil then
        n = 7
    end
    self.points = {}
    self.delta = 0.041
    self.val = 0
    for i=1, 24 do
        self.points[i] = self.val
        self.val += self.delta
    end
    
    local x = 32
    self.cams = {}
    self.followers = {}
    for i=1, 7 do
        if i > n then
            break
        end
        self.cams[i] = Cam(x, 216)
        self.cams[i]:setPoints(table.shallowcopy(self.points))
        self.cams[i]:rotate(math.random(0, 359))
        self.cams[i]:setRotationsPerCrank(math.random())
        self.cams[i]:draw()

        self.followers[i] = CamFollower(x, 216-(47/2))
        self.followers[i]:setScale(math.random())
        self.cams[i]:setFollower(self.followers[i])

        x += 48
    end
    
    self.selectionRow = 1
    self.selection = 8
    self.selectorRowImages = {
        gfx.image.new("images/dither_pattern_47_47"),
        gfx.image.new("images/dither_pattern_47_47_masked")
    }
    self.selector = gfx.sprite.new(self.selectorRowImages[1])
    self.selector:moveTo(x, 216)
    self.selector:add()
    
    self.editorSelection = 1
    self.camEditor = nil
    self.ampEditor = nil

    self.hasFocus = false

    self.flywheelRotation = 1
    self.flywheelImage = gfx.imagetable.new("images/flywheel")
    self.flywheel = gfx.sprite.new(self.flywheelImage:getImage(1))
    self.flywheel:moveTo(368, 216)
    self.flywheel:add()

    self:add()
end

function CamShaft:setFocus(focus)
    self.hasFocus = focus
end

function CamShaft:update()
    if self.hasFocus then
        if self.camEditor ~= nil then
            self:updateCamEditor()
        elseif self.ampEditor ~= nil then
            self:updateAmpEditor()
        else
            self:updateShaft()
        end
    end
end


function CamShaft:updateShaft()
    if pd.buttonJustPressed(pd.kButtonUp) then
        self.selectionRow = 2
        self.selector:setImage(self.selectorRowImages[self.selectionRow])
        if self.selection == 8 then
            self.selection = 7
        end
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.selectionRow = 1
        self.selector:setImage(self.selectorRowImages[self.selectionRow])
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.selection -= 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.selection += 1
    end
    
    local change = pd.getCrankChange()

    if self.selectionRow == 1 then
        self.selection = math.clamp(self.selection, 1, 8)

        if self.selection == 8 then
            --crank
            self.flywheelRotation = math.wrap(self.flywheelRotation, 1, 48, change/48)
            self.flywheel:setImage(self.flywheelImage:getImage(math.floor(self.flywheelRotation + 0.5)))
            self.selector:moveTo(368, 216)
            for i=1, 7 do
                self.cams[i]:rotate(change)
                self.cams[i]:draw()
            end
        else
            -- cam
            self.selector:moveTo(self.cams[self.selection]:getPosition())
            self.cams[self.selection]:rotate(change)
            self.cams[self.selection]:draw()
        end
    
        if pd.buttonJustPressed(pd.kButtonA) then
            self.camEditor = Cam(110, 120, 10)
            self.camEditor:setWidthAndHeight(200)
            self.camEditor:setPoints(self.cams[self.selection]:clonePoints())
            self.camEditor:setRotationsPerCrank(self.cams[self.selection].rotationCoeff)
            self.camEditor:draw()

            self.camInfoPanel = CamInfoPanel(self.camEditor, 305, 120, 160, 200, 10)
        end
    else
        self.selection = math.clamp(self.selection, 1, 7)
        local x, y = self.cams[self.selection]:getPosition()
        self.selector:moveTo(x, y-(47/2))

        if pd.buttonJustPressed(pd.kButtonA) then
            local value = self.followers[self.selection].scale
            self.ampEditor = CamFollowerInfoPanel(value)
        end
    end
end

function CamShaft:updateAmpEditor()
    local change = pd.getCrankChange() / 359
    self.ampEditor:updateEditor(change)
    self.followers[self.selection]:setScale(self.ampEditor:getValue())

    if pd.buttonIsPressed(pd.kButtonB) then
        self.ampEditor:remove()
        self.ampEditor = nil
    end
end

function CamShaft:updateCamEditor()
    local change = pd.getCrankChange() / 359
    
    local s, r = self.camInfoPanel:getSelection()
    if s == 1 then
        self.editorSelection = r
        self.camEditor:adjustPoint(self.editorSelection, change)
    else
        self.editorSelection = 0
        if r == 1 then
            self.camEditor:scalePoints(1+change)
        elseif r == 2 then
            self.camEditor:sizePoints(change)
        elseif r == 3 then
            self.camEditor:adjustRotationsPerCrank(change)
        end
    end
    self.camEditor:setUISelection(self.editorSelection)
    self.camEditor:draw()

    if pd.buttonIsPressed(pd.kButtonB) then
        local cam = self.cams[self.selection]
        cam:setPoints(self.camEditor:clonePoints())
        cam:setRotationsPerCrank(self.camEditor.rotationCoeff)
        cam:draw()
        self.camEditor:remove()
        self.camEditor = nil
        self.camInfoPanel:remove()
        self.camInfoPanel = nil
    end
end