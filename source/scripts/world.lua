import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("World").extends(gfx.sprite)

function World:init()
    self.focus = false
    self.sockets = {}
end

function World:setSockets(socket)
    self.sockets = socket
end

function World:setFocus(focus)
    self.focus = focus
end

function World:update()
    -- update
end