import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/vector"
import "scripts/util/math"

import "scripts/cam"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamShaft").extends(gfx.sprite)

function CamShaft:init()
    self.points = {}
    self.delta = 0.041
    self.val = 0
    for i=1, 24 do
        self.points[i] = self.val
        self.val += self.delta
    end
    
    local x = 32
    local r = 0
    self.cams = {}
    for i=1, 7 do
        self.cams[i] = Cam(x, 216)
        self.cams[i]:setPoints(table.shallowcopy(self.points))
        self.cams[i]:rotate(r)
        r += 20
        self.cams[i]:setRotationMultiplyer(0.5)
        self.cams[i]:draw()
        x += 48
    end
    
    self.selection = 8
    self.selector = gfx.sprite.new(gfx.image.new("images/dither_pattern_47_47"))
    self.selector:moveTo(x, 216)
    self.selector:add()
    
    self.editorSelection = 1
    self.camEditor = nil

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
        if self.camEditor == nil then 
            self:updateShaft()
        else
            self:updateEditor() 
        end
    end
end


function CamShaft:updateShaft()
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.selection -= 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.selection += 1
    end
    self.selection = math.clamp(self.selection, 1, 8)
    
    if self.selection == 8 then
        --crank
        local change = pd.getCrankChange()
        for i=1, 7 do
            self.cams[i]:rotate(change)
            self.cams[i]:draw()
        end
        self.flywheelRotation = math.wrap(self.flywheelRotation, 1, 48, change/48)
        self.flywheel:setImage(self.flywheelImage:getImage(math.floor(self.flywheelRotation + 0.5)))
        self.selector:moveTo(368, 216)
    else
        -- cam
        self.selector:moveTo(self.cams[self.selection]:getPosition())
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self.camEditor = Cam(200, 120, 10)
        self.camEditor:setWidthAndHeight(200)
        self.camEditor:setPoints(self.cams[self.selection]:clonePoints())
        self.camEditor:draw()
    end
end

function CamShaft:updateEditor()
    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.editorSelection -= 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.editorSelection += 1
    end
    self.editorSelection = math.wrap(self.editorSelection, 1, 24, 0)
    self.camEditor:setUISelection(self.editorSelection)

    local change = pd.getCrankChange() / 359
    self.camEditor:adjustPoint(self.editorSelection, change)

    self.camEditor:draw()

    if pd.buttonIsPressed(pd.kButtonB) then
        self.cams[self.selection]:setPoints(self.camEditor:clonePoints())
        self.cams[self.selection]:draw()
        self.camEditor:remove()
        self.camEditor = nil
    end
end