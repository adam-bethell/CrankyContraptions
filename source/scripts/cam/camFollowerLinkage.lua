import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamFollowerLinkage").extends(gfx.sprite)

function CamFollowerLinkage:init(s1, s2, goal)
    self.s1, self.s2 = s1, s2
    self.g = {x=goal.x, y=goal.y}
    self.l1 = Vector.dist(s1.x, s1.y, self.g.x, self.g.y)
    self.l2 = Vector.dist(s2.x, s2.y, self.g.x, self.g.y)

    self.image = gfx.image.new(400, 240)
    self.s3 = {deleted = false}
    self.s3.x, self.s3.y = self:getIntersectingPoint()
end

function CamFollowerLinkage:updateAndDraw()
    self.s3.x, self.s3.y = self:getIntersectingPoint()
    gfx.drawLine(self.s1.x, self.s1.y, self.s3.x, self.s3.y)
    gfx.drawLine(self.s2.x, self.s2.y, self.s3.x, self.s3.y)
    gfx.fillCircleAtPoint(self.s3.x, self.s3.y, 5)
end

function CamFollowerLinkage:getIntersectingPoint()
    local x1, y1, x2, y2 = math.getIntersectingPoint(self.s1.x, self.s1.y, self.l1, self.s2.x, self.s2.y, self.l2)
    local d1 = Vector.dist(self.g.x, self.g.y, x1, y1)
    local d2 = Vector.dist(self.g.x, self.g.y, x2, y2)
    if d1 < d2 then
        self.g.x, self.g.y = x1, y1
        return x1, y1
    end
    self.g.x, self.g.y = x2, y2
    return x2, y2
end