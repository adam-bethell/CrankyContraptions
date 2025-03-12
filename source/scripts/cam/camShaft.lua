import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "scripts/util/vector"
import "scripts/util/math"

import "scripts/cam/cam"
import "scripts/cam/camInfoPanel"
import "scripts/cam/camFollower"
import "scripts/cam/camFollowerInfoPanel"

import "scripts/physics/world"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamShaft").extends(gfx.sprite)

function CamShaft:init(world)
    self.world = world
    local x = 32
    self.cams = {}
    self.followers = {}
    for i=1, 4 do
        self.cams[i] = Cam(x, 216)
        self.cams[i]:setPoints(table.shallowcopy(CamInfoPanel.presets[i+1].points))
        self.cams[i]:setRotationsPerCrank(math.random() * 0.6 + 0.4)
        self.followers[i] = CamFollower(x, 216-(47/2))
        self.followers[i]:setScale(math.random() * 0.4 + 0.1)
        self.followers[i]:draw()
        self.cams[i]:setFollower(self.followers[i])
        self.cams[i]:rotate(math.random(0, 359))
        self.cams[i]:draw()
        x += (48*2)
    end

    self.followers[1]:setFollowerRotation(90)
    self.followers[4]:setFollowerRotation(-90)

    self.linkages = {}
    self.linkagesImage = gfx.image.new(400, 240)
    self.linkagesSprite = gfx.sprite.new(self.linkagesImage)
    self.linkagesSprite:moveTo(200, 120)
    self.linkagesSprite:setZIndex(-10)
    self.linkagesSprite:add()
    
    self.selectionRow = 1
    self.selection = 5
    self.sDegs = 0
    self.selectImage = gfx.image.new(400, 240)
    self.selectImageX = {0, 96, 192, 288, 336}
    self.selectImageY = {182, 162}
    self.selectImageW = 62
    self.selectImageH = {66, 36}
    self.selector = gfx.sprite.new(self.selectImage)
    self.selector:moveTo(200, 120)
    self.selector:setZIndex(10)
    self.selector:add()
    self.selector:setVisible(false)

    self.inUpdateShaft = false
    self.editorSelection = 1
    self.camEditor = nil
    self.ampEditor = nil

    self.hasFocus = false
    self.swapFocus = false

    self.backgroundCogs = gfx.imagetable.new("images/gears")
    assert(self.backgroundCogs)
    self.backgroundCogsSprite = gfx.sprite.new(self.backgroundCogs[1])
    self.backgroundCogsSprite:setCenter(1, 1)
    self.backgroundCogsSprite:moveTo(400,240)
    self.backgroundCogsSprite:setZIndex(-10)
    self.backgroundCogsSprite:add()

    self.bg = gfx.image.new("images/background")
    assert(self.bg)
    self:setImage(self.bg)
    self:moveTo(200, 120)
    self:setZIndex(-20)
    self:add()
end

function CamShaft:setSelectionX(x)
    self.selectionRow = 2
    if x < 81 then
        self.selection = 1
    elseif x < 176 then
        self.selection = 2
    elseif x < 273 then
        self.selection = 3
    else
        self.selection = 4
    end
end

function CamShaft:setFocus(focus)
    self.focus = focus
    if focus then
        self:updateShaft()
    end
    self.selector:setVisible(focus)
end

function CamShaft:getFocus()
    return self.focus
end

function CamShaft:canLosefocus()
    return self.inUpdateShaft
end

function CamShaft:update()
    if self.focus then
        if self.camEditor ~= nil then
            self.inUpdateShaft = false
            self:updateCamEditor()
        elseif self.ampEditor ~= nil then
            self.inUpdateShaft = false
            self:updateAmpEditor()
        else
            self.inUpdateShaft = true
            self:updateShaft()
        end
        self:updateHelpText()
    end
end


function CamShaft:updateShaft()
    if pd.buttonJustPressed(pd.kButtonUp) then
        if self.selection == 5 then
            self.selection = 4
        end

        if self.selectionRow == 2 then
            self.swapFocus = true
        else
            self.selectionRow = 2
        end
        
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.selectionRow = 1
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.selection -= 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.selection += 1
    end
    
    local change = math.clamp(pd.getCrankChange(), -12, 12)

    if self.selectionRow == 1 then
        self.selection = math.clamp(self.selection, 1, 5)

        if self.selection == 5 then
            --crank
            for i=1, 4 do
                self.cams[i]:rotate(change)
                self.cams[i]:draw()
                self.followers[i]:draw()
            end
            self:drawLinkages()
            self:drawBackgroudCogs()
        else
            -- cam
            self.cams[self.selection]:rotate(change)
            self.cams[self.selection]:draw()
            self.followers[self.selection]:draw()
            self:drawLinkages()
        end
    
        if pd.buttonJustPressed(pd.kButtonA) then
            if self.selection < 5 then
                self.camEditor = Cam(110, 120, 20)
                self.camEditor:setWidthAndHeight(200)
                self.camEditor:setPoints(self.cams[self.selection]:clonePoints())
                self.camEditor:setRotationsPerCrank(self.cams[self.selection].rotationCoeff)
                self.camEditor:setHideFollower(true)
                self.camEditor.showBG = true
                self.camEditor:draw()

                self.camInfoPanel = CamInfoPanel(self.camEditor, 305, 120, 160, 200, 10)
            else
                -- Reset ball
                self.world:resetStage()
            end
        end
    else -- Selection row is 2 - Amp sections
        if self.selection == 5 then
            self.selectionRow = 1
        else
            self.selection = math.clamp(self.selection, 1, 4)
            if change ~= 0 then
                if self.selection == 1 or self.selection == 4 then
                    self.followers[self.selection]:adjustFollowerOffset(0, change *0.5)
                else
                    self.followers[self.selection]:adjustFollowerOffset(change *0.5, 0)
                end
                self.followers[self.selection]:draw()
                self:drawLinkages()
            end
        end
        
        if pd.buttonJustPressed(pd.kButtonA) then
            local value = self.followers[self.selection].scale
            self.ampEditor = CamFollowerInfoPanel(value)
        end
    end
    self.selectImage:clear(gfx.kColorClear)
    gfx.pushContext(self.selectImage)
        local rect = pd.geometry.rect.new(
            self.selectImageX[self.selection],
            self.selectImageY[self.selectionRow],
            self.selectImageW,
            self.selectImageH[self.selectionRow]
        )
        rect:inset(3, 3)
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(5)
        gfx.drawEllipseInRect(rect)
        gfx.setLineWidth(3)
        gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
        gfx.drawEllipseInRect(rect)
        gfx.setColor(gfx.kColorBlack)
        for i=0, 6 do
            gfx.drawEllipseInRect(rect, self.sDegs, self.sDegs+60)
            self.sDegs = math.wrap(self.sDegs, 0, 359, 120)
        end
        self.sDegs = math.wrap(self.sDegs, 0, 359, 2)
    gfx.popContext()
    self.selector:markDirty()
end

function CamShaft:updateAmpEditor()
    local change = pd.getCrankChange() / 359
    self.ampEditor:updateEditor(change)
    self.followers[self.selection]:setScale(self.ampEditor:getValue())
    self:drawLinkages()

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
    elseif s == 2 then
        self.editorSelection = 0
        if r == 1 then
            self.camEditor:scalePoints(1+change)
        elseif r == 2 then
            self.camEditor:sizePoints(change)
        elseif r == 3 then
            self.camEditor:adjustRotationsPerCrank(change)
        end
    elseif s == 3 then
        self.editorSelection = 0
    end
    self.camEditor:setUISelection(self.editorSelection)
    self.camEditor:draw()

    if pd.buttonIsPressed(pd.kButtonB) then
        local cam = self.cams[self.selection]
        cam:setPoints(self.camEditor:clonePoints())
        cam:setRotationsPerCrank(self.camEditor.rotationCoeff)
        cam:draw()
        self:drawLinkages()
        self.camEditor:remove()
        self.camEditor = nil
        self.camInfoPanel:remove()
        self.camInfoPanel = nil
    end
end

function CamShaft:getSockets()
    local s = {}
    for i=1, #self.followers do
        s[#s+1] = self.followers[i].socket
    end
    return s
end

function CamShaft:addLinkage(s1, s2, goal)
    local linkage = CamFollowerLinkage(s1, s2, goal)
    self.linkages[#self.linkages+1] = linkage
    self:drawLinkages()
    return linkage.s3
end

function CamShaft:drawLinkages()
    self.linkagesImage:clear(gfx.kColorClear)
    gfx.pushContext(self.linkagesImage)
        gfx.setPattern({0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55})
        gfx.setLineWidth(2)
        for i, v in ipairs(self.linkages) do
            v:updateAndDraw()
        end
    gfx.popContext()
    self.linkagesSprite:markDirty()
end

function CamShaft:drawBackgroudCogs()
    local i = math.clamp(math.floor(pd.getCrankPosition() / 2), 1, 180)
    self.backgroundCogsSprite:setImage(self.backgroundCogs[i])
end

function CamShaft:updateHelpText()
    if self.camEditor ~= nil then
        local s, r = self.camInfoPanel:getSelection()
        local aButtonText = ""
        local crankText = "adjust value"
        if s == 3 then
            aButtonText = "apply"
            crankText = ""
        end
        HELPER_UI:setText("navigate", "exit", aButtonText, crankText)
    elseif self.ampEditor ~= nil then
        HELPER_UI:setText("", "exit", "", "adjust value")
    else
        if self.selectionRow == 1 then
            if self.selection == 5 then
                HELPER_UI:setText("navigate", "", "reset ball", "turn camshaft")
            else
                HELPER_UI:setText("navigate", "", "edit", "turn cam")
            end
        else
            HELPER_UI:setText("navigate", "", "edit", "move")
        end
    end
end

function CamShaft:removeAttached(socket)
    local s3s = {}
    local linkagesRemoved = false
    for i, v in pairs(self.linkages) do
        if v.s1 == socket or v.s2 == socket then
            v.s3.deleted = true
            v:remove()
            self.linkages[i] = nil
            linkagesRemoved = true
        end
    end

    while linkagesRemoved do
        linkagesRemoved = false
        for i, v in pairs(self.linkages) do
            if v.s1.deleted or v.s2.deleted then
                v.s3.deleted = true
                v:remove()
                self.linkages[i] = nil
                linkagesRemoved = true
            end
        end
    end

    self:drawLinkages()
end