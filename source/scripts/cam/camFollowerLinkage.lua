import "CoreLibs/object"
import "CoreLibs/graphics"

import "scripts/util/vector"
import "scripts/util/math"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CamFollowerLinkage").extends(gfx.sprite)

function CamFollowerLinkage:init(s1, l1, s2, l2)
    self.s1, self.s2, self.l1, self.l2 = s1, s2, l1, l2
    self.image = gfx.image.new(400, 240)
    self.s3 = {}
    self.s3.x, self.s3.y = math.getIntersectingPoint(self.s1.x, self.s1.y, self.l1, self.s2.x, self.s2.y, self.l2)
end

function CamFollowerLinkage:updateAndDraw()
    self.s3.x, self.s3.y = math.getIntersectingPoint(self.s1.x, self.s1.y, self.l1, self.s2.x, self.s2.y, self.l2)
    gfx.drawLine(self.s1.x, self.s1.y, self.s3.x, self.s3.y)
    gfx.drawLine(self.s2.x, self.s2.y, self.s3.x, self.s3.y)
    gfx.fillCircleAtPoint(self.s3.x, self.s3.y, 5)
end