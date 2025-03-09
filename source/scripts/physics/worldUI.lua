import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

import "scripts/cam/camShaft"
import "scripts/physics/world"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("WorldUI").extends(gfx.sprite)

function WorldUI:init(camShaft, world)
    self.camShaft = camShaft
    self.world = world

    self.focus = false
    self.swapFocus = false
    self.state = "inactive"
    self.placingItem = 0
    self.placingRadius = 15
    self.placingLocation = {x=200,y=120}

    self.availableSockets = self.camShaft:getSockets()
    self.selectedSocketIndex = 1

    self.addingGridview = pd.ui.gridview.new(130, 15)
    self.addingGridview:setNumberOfRows(4)
    function self.addingGridview:drawCell(section, row, column, selected, x, y, width, height)
        local options = {"New Joint", "Stretch Beam", "Circle", "Remove Attached"}
        local text = options[row]
        if selected then
            gfx.drawText("* " .. text .. "*", x, y, width, height)
        else
            gfx.drawText(text, x, y, width, height)
        end
    end

    self.degs = 0
    self.image = gfx.image.new(400,240)
    self:setImage(self.image)
    self:moveTo(200,120)
    self:setZIndex(50)
    self:add()


    -- pd.debugDraw = function ()
    --     for i, v in ipairs(self.availableSockets) do
    --         gfx.drawCircleAtPoint(v.x, v.y, 10)
    --     end
    -- end

    -- pd.keyPressed = function (k)
    --     if k == "p" then
    --         printTable(self.availableSockets[self.selectedSocketIndex])
    --     end
    -- end
end

function WorldUI:setSelection(newIndex)
    self.selectedSocketIndex = newIndex
end

function WorldUI:getSelectionX()
    return self.availableSockets[self.selectedSocketIndex].x
end

function WorldUI:getFocus()
    return self.focus
end

function WorldUI:canLosefocus()
    return self.state == "selecting"
end

function WorldUI:setFocus(value)
    self.focus = value
    if value == false then
        self.image:clear(gfx.kColorClear)
        self:markDirty()
        self.state = "inactive"
    end
end

function WorldUI:update()
    if self.focus then
        -- Push context here so things can draw
        self.image:clear(gfx.kColorClear)
        gfx.pushContext(self.image)
            if self.state == "inactive" then
                self:updateInactive()
            elseif self.state == "selecting" then
                self:updateSelecting()
            elseif self.state == "adding" then
                self:updateAdding()
            elseif self.state == "removeConfirm" then
                self:updateRemoveConfirm()
            elseif self.state == "placing" then
                self:updatePlacing()
            elseif self.state == "placing2" then
                self:updatePlacing2()
            elseif self.state == "placingMove" then
                self:updatePlacingMove()
            end

            self:drawSelector()
        gfx.popContext()
        self:markDirty()

        self:updateHelpText()
    end
end

function WorldUI:updateInactive()
    self.state = "selecting"
end

function WorldUI:updateSelecting()
    -- Change selection
    local cur = self.availableSockets[self.selectedSocketIndex]

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.selectedSocketIndex -= 1
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.selectedSocketIndex += 1
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.swapFocus = true
    end
    self.selectedSocketIndex = math.wrap(self.selectedSocketIndex, 1, #self.availableSockets, 0)

    if pd.buttonJustPressed(pd.kButtonA) then
        self.state = "adding"
    end
end

function WorldUI:updateAdding()
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.addingGridview:selectNextRow(true, true, true)
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        self.addingGridview:selectPreviousRow(true, true, true)
    end

    local rect = pd.geometry.rect.new(130, 170, 140, 70)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(rect)
    rect:inset(2, 2)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(rect)
    rect:inset(2, 1)
    self.addingGridview:drawInRect(rect.x, rect.y, rect.width, rect.height)

    if pd.buttonJustPressed(pd.kButtonA) then
        self.fromSelectedSocketIndex = self.selectedSocketIndex
        self.placingItem = self.addingGridview:getSelectedRow()
        if self.placingItem <= 2 then
            self.state = "placing"
        elseif self.placingItem == 4 then
            self.state = "removeConfirm"
        else 
            self.placingLocation.x = -50
            self.placingLocation.y = -50
            self.state = "placing2"
        end
    elseif pd.buttonJustPressed(pd.kButtonB) then
        self.state = "selecting"
    end
end

function WorldUI:updateRemoveConfirm()
    local rect = pd.geometry.rect.new(130, 170, 140, 70)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(rect)
    rect:inset(2, 2)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(rect)
    rect:inset(2, 1)
    gfx.drawTextInRect(
        "Are you sure you want to remove all objects attached to this follower?",
        rect,
        nil,
        nil,
        kTextAlignment.center
    )

    if pd.buttonJustPressed(pd.kButtonA) then
        local s = self.availableSockets[self.fromSelectedSocketIndex]
        self.camShaft:removeAttached(s)
        self.world:removeAttached(s)
        self.world:removeUnattached()
        self:sortAvailableSockets()
        self.state = "selecting"
    elseif pd.buttonJustPressed(pd.kButtonB) then
        self.state = "adding"
    end
end

function WorldUI:updatePlacing()
    if self.placingItem == 1 or self.placingItem == 2 then
        -- We require a second socket
        if pd.buttonJustPressed(pd.kButtonLeft) then
            self.selectedSocketIndex -= 1
            if self.selectedSocketIndex == self.fromSelectedSocketIndex then
                self.selectedSocketIndex -= 1
            end
        elseif pd.buttonJustPressed(pd.kButtonRight) then
            self.selectedSocketIndex += 1
            if self.selectedSocketIndex == self.fromSelectedSocketIndex then
                self.selectedSocketIndex += 1
            end
        elseif self.selectedSocketIndex == self.fromSelectedSocketIndex then
            self.selectedSocketIndex += 1
        end
        self.selectedSocketIndex = math.wrap(self.selectedSocketIndex, 1, #self.availableSockets, 0)
    end

    -- Draw previews
    gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    local s1 = self.availableSockets[self.fromSelectedSocketIndex]
    local mx, my = 200, 120
    if self.placingItem == 1 then
        gfx.setLineWidth(3)
        local s2 = self.availableSockets[self.selectedSocketIndex]
        gfx.drawLine(s1.x, s1.y, s2.x, s2.y)
        mx, my = Vector.midpoint(s1.x, s1.y, s2.x, s2.y)
        gfx.fillCircleAtPoint(mx, my, 7)
    elseif self.placingItem == 2 then
        gfx.setLineWidth(15)
        gfx.setLineCapStyle(gfx.kLineCapStyleRound)
        local s2 = self.availableSockets[self.selectedSocketIndex]
        gfx.drawLine(s1.x, s1.y, s2.x, s2.y)
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.placingItem == 2 then
            self.placingLocation.x = -50
            self.placingLocation.y = -50
            self.state = "placing2"
        else
            self.placingLocation.x = mx
            self.placingLocation.y = my
            self.state = "placingMove"
        end
    elseif pd.buttonJustPressed(pd.kButtonB) then
        self.selectedSocketIndex = self.fromSelectedSocketIndex
        self.state = "adding"
    end
end

function WorldUI:updatePlacing2()
    -- Change size
    if pd.buttonJustPressed(pd.kButtonDown) or pd.buttonJustPressed(pd.kButtonLeft) then
        self.placingRadius -= 1
    elseif pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustPressed(pd.kButtonRight) then
        self.placingRadius += 1
    end
    if self.placingItem == 2 then
        self.placingRadius = math.clamp(self.placingRadius, 10, 30)
    else
        self.placingRadius = math.clamp(self.placingRadius, 5, 30)
    end

    -- Draw previews
    local r = self.placingRadius
    gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    local s1 = self.availableSockets[self.fromSelectedSocketIndex]
    local s2 = self.availableSockets[self.selectedSocketIndex]
    if self.placingItem == 2 then
        gfx.setLineWidth(r)
        gfx.setLineCapStyle(gfx.kLineCapStyleRound)
        gfx.drawLine(s1.x, s1.y, s2.x, s2.y)
    elseif self.placingItem == 3 then
        gfx.fillCircleAtPoint(s1.x, s1.y, r)
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.placingItem == 2 then
            self.world:addPinnedLine(s1, s2, r)
        else 
            self.world:addCircle(s1, r)
        end
        self.state = "selecting"
    elseif pd.buttonJustPressed(pd.kButtonB) then
        self.selectedSocketIndex = self.fromSelectedSocketIndex
        self.state = "adding"
    end
end

function WorldUI:updatePlacingMove()
    -- Change location
    local newLocationX = self.placingLocation.x
    local newLocationY = self.placingLocation.y
    if pd.buttonIsPressed(pd.kButtonDown) then
        newLocationY += 1
    end
    if pd.buttonIsPressed(pd.kButtonLeft) then
        newLocationX -= 1
    end
    if pd.buttonIsPressed(pd.kButtonUp) then
        newLocationY -= 1
    end
    if pd.buttonIsPressed(pd.kButtonRight) then
        newLocationX += 1
    end

    local s1 = self.availableSockets[self.fromSelectedSocketIndex]
    local s2 = self.availableSockets[self.selectedSocketIndex]
    local cx, cy = Vector.midpoint(s1.x, s1.y, s2.x, s2.y)
    if Vector.dist(newLocationX, newLocationY, cx, cy) < 150 then
        self.placingLocation.x = math.clamp(newLocationX, 0, 400)
        self.placingLocation.y = math.clamp(newLocationY, 0, 240)
    end

    -- Draw preview
    gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    gfx.setLineWidth(3)
    gfx.drawLine(s1.x, s1.y, self.placingLocation.x, self.placingLocation.y)
    gfx.drawLine(self.placingLocation.x, self.placingLocation.y, s2.x, s2.y)
    gfx.fillCircleAtPoint(self.placingLocation.x, self.placingLocation.y, 7)

    if pd.buttonJustPressed(pd.kButtonA) then
        local newSocket = self.camShaft:addLinkage(s1, s2, self.placingLocation)
        self.availableSockets[#self.availableSockets+1] = newSocket
        self:sortAvailableSockets()
        self.state = "selecting"
    elseif pd.buttonJustPressed(pd.kButtonB) then
        self.selectedSocketIndex = self.fromSelectedSocketIndex
        self.state = "adding"
    end
end

function WorldUI:drawSelector()
    -- Selection image
    local socket = self.availableSockets[self.selectedSocketIndex]
    if self.state == "placingMove" or self.state == "placing2" then
        socket = self.placingLocation
    end
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(5)
    gfx.drawCircleAtPoint(socket.x, socket.y, 15)
    gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    gfx.setLineWidth(3)
    gfx.drawCircleAtPoint(socket.x, socket.y, 15)
    gfx.setColor(gfx.kColorBlack)
    for i=0, 3 do
        gfx.drawArc(socket.x, socket.y, 15, self.degs, self.degs+60)
        self.degs = math.wrap(self.degs, 0, 359, 120)
    end
    self.degs += 2
end

function WorldUI:sortAvailableSockets()
    local currentlySelectedSocket = self.availableSockets[self.selectedSocketIndex]

    for i, v in ipairs(self.availableSockets) do
        if v.deleted then
            self.availableSockets[i] = nil
        end
    end

    -- Sort in x asc, y asc order
    local sortedSockets = {}
    local iMax = 0
    for k, v in pairs(self.availableSockets) do
        iMax += 1
    end
    for i=1, iMax do
        local smallestIndex = 1
        local smallestX = 500
        local smallestY = 300
        for j, w in pairs(self.availableSockets) do
            if w == nil then
                -- do nothing
            else
                if w.x < smallestX then
                    smallestX = w.x
                    smallestY = w.y
                    smallestIndex = j
                elseif w.x == smallestX and w.y < smallestY then
                    smallestX = w.x
                    smallestY = w.y
                    smallestIndex = j
                end
            end
        end
        local socket = self.availableSockets[smallestIndex]
        self.availableSockets[smallestIndex] = nil
        if socket ~= nil then
            sortedSockets[#sortedSockets+1] = socket
        end
    end
    self.availableSockets = sortedSockets

    -- update selection index to match new position
    self.selectedSocketIndex = table.indexOfElement(sortedSockets, currentlySelectedSocket)
    assert(self.selectedSocketIndex, "failed to update index")
end

function WorldUI:updateHelpText()
    if self.state == "selecting" then
        HELPER_UI:setText("navigate", "", "edit", "")
    elseif self.state == "adding" then
        HELPER_UI:setText("navigate", "exit", "choose", "")
    elseif self.state == "removeConfirm" then
        HELPER_UI:setText("", "cancel", "DELETE", "")
    elseif self.state == "placing" then
        HELPER_UI:setText("navigate", "back", "place", "")
    elseif self.state == "placing2" then
        HELPER_UI:setText("size", "back", "place", "")
    elseif self.state == "placingMove" then
        HELPER_UI:setText("move", "back", "place", "")
    end
end