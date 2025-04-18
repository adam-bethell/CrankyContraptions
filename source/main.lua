import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/util/math"
import "scripts/util/vector"

import "scripts/level"
import "scripts/helperUI"

local pd <const> = playdate
local gfx <const> = pd.graphics

pd.display.setRefreshRate(20)

math.randomseed(pd.getSecondsSinceEpoch())
local normalFont = gfx.font.new("fonts/Bookxel_16")
assert(normalFont)
local boldFont = gfx.font.new("fonts/Bookxel_Bold_16")
assert(boldFont)
local fontPaths = {
    [playdate.graphics.font.kVariantNormal] = normalFont,
    [playdate.graphics.font.kVariantBold] = boldFont
}
gfx.setFontFamily(fontPaths)

HELPER_UI = HelperUI()
local level = Level()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(0, 0)
end

