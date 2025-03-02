import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("TwoPinLine").extends()

function TwoPinLine:init(x1, y1, x2, y2, w)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2

    self.lineWidth = w

    self.socket1 = nil
    self.socket2 = nil

    self.vX = 0
    self.vY = 0
end

function TwoPinLine:update()
    if self.socket1 ~= nil and self.socket2 ~= nil then
        self.x1, self.y1 = self.socket1.x, self.socket1.y
        self.x2, self.y2 = self.socket2.x, self.socket2.y
    end
end

function TwoPinLine:draw()
    gfx.setLineCapStyle(gfx.kLineCapStyleRound)
    gfx.setLineWidth(self.lineWidth)
    gfx.drawLine(self.x1, self.y1, self.x2, self.y2)
end