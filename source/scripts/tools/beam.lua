import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Beam").extends(gfx.sprite)

function Beam:init()
    self.length = 50
    self.sockets = {}
end

function Beam:draw()
    
end