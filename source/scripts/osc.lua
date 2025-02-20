import "CoreLibs/object"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Osc").extends(gfx.sprite)

function Osc:init(x, y, phase)
    self.x = x
    self.y = y
    self.phase = phase

    self.image = gfx.image.new(32, 32)
    self.gPoints = table.create(30)
    for i=1, 30 do
        self.gPoints[i] = 15
    end

    self:moveTo(self.x, self.y)
    self:add()
end


function Osc:incrPhase(deg)
    self.phase += deg
    self.amp = math.sin(math.rad(self.phase))

    local mag = (self.amp * 0.5) + 0.5
    local gy = (mag * 29) + 1
    gy = math.floor(gy+0.5)

    table.remove(self.gPoints, 1)
    table.insert(self.gPoints, 30, gy)

    return self.amp
end

function Osc:update()
    gfx.pushContext(self.image)
        self.image:clear(gfx.kColorWhite)
        gfx.setLineWidth(1)
        gfx.drawRect(0, 0, 32, 32)
        for i=1,30 do
            gfx.drawPixel(1+i, 31-self.gPoints[i])
        end
    gfx.popContext()
    self:setImage(self.image)
    self:markDirty()
end