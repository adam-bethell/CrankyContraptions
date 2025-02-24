import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/tools/beam"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("World").extends(gfx.sprite)

function World:init()
    self.focus = false
    self.sockets = {}
    self.bodies = {}

    self.image = gfx.image.new(400, 168)
    self:setImage(self.image)
    self:moveTo(200, 84)
    self:add()
end

function World:setSockets(socket)
    self.sockets = socket
end

function World:setFocus(focus)
    self.focus = focus
end

function World:getFocus()
    return self.focus
end

function World:canLosefocus()
    return true
end

function World:update()
    if self.focus then
        if pd.buttonJustPressed(pd.kButtonA) then
            local beam = Beam()
            table.insert(beam.sockets, self.sockets[1])
            table.insert(beam.sockets, self.sockets[2])
            self.bodies[#self.bodies+1] = beam
        end
    end

    self.image:clear(gfx.kColorClear)
    gfx.pushContext(self.image)
        for i=1, #self.bodies do
            self.bodies[i]:draw()
        end
    gfx.popContext()
    self:markDirty()
end