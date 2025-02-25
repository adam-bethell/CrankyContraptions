--[[
Copyright (c) 2011 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

--[[
	Adam: I'm making a lot of tweaks and changes here so don't blame the original author for things not working!
]]--

import "HC/shapes"
import "HC/spatialhash"

local newPolygonShape = Shape.newPolygonShape
local newCircleShape  = Shape.newCircleShape
local newPointShape   = Shape.newPointShape

class("HC").extends()
function HC:init(cell_size)
  self:resetHash(cell_size)
end

function HC:hash() return self._hash end -- consistent interface with global HC instance

-- spatial hash management
function HC:resetHash(cell_size)
	self._hash = Spatialhash(cell_size or 100)
	return self
end

function HC:register(shape)
	self._hash:register(shape, shape:bbox())

	-- keep track of where/how big the shape is
	for _, f in ipairs({'move', 'rotate', 'scale'}) do
		local old_function = shape[f]
		shape[f] = function(this, ...)
			local x1,y1,x2,y2 = this:bbox()
			old_function(this, ...)
			self._hash:update(this, x1,y1,x2,y2, this:bbox())
			return this
		end
	end

	return shape
end

function HC:remove(shape)
	self._hash:remove(shape, shape:bbox())
	for _, f in ipairs({'move', 'rotate', 'scale'}) do
		shape[f] = function()
			error(f.."() called on a removed shape")
		end
	end
	return self
end

-- shape constructors
function HC:polygon(...)
	return self:register(newPolygonShape(nil, ...))
end

function HC:rectangle(x,y,w,h)
	return self:polygon(x,y, x+w,y, x+w,y+h, x,y+h)
end

function HC:circle(x,y,r)
	return self:register(newCircleShape(nil,x,y,r))
end

function HC:point(x,y)
	return self:register(newPointShape(nil,x,y))
end

-- collision detection
function HC:neighbors(shape)
	local neighbors = self._hash:inSameCells(shape:bbox())
	rawset(neighbors, shape, nil)
	return neighbors
end

function HC:collisions(shape)
	local candidates = self:neighbors(shape)
	for other in pairs(candidates) do
		local collides, dx, dy = shape:collidesWith(other)
		if collides then
			rawset(candidates, other, {dx,dy, x=dx, y=dy})
		else
			rawset(candidates, other, nil)
		end
	end
	return candidates
end

function HC:raycast(x, y, dx, dy, range)
	local dxr, dyr = dx * range, dy * range
	local bbox = { x + dxr , y + dyr, x, y }
	local candidates = self._hash:inSameCells(table.unpack(bbox))

	for col in pairs(candidates) do
		local rparams = col:intersectionsWithRay(x, y, dx, dy)
		if #rparams > 0 then
			for i, rparam in pairs(rparams) do
				if rparam < 0 or rparam > range then
					rawset(rparams, i, nil)
				else
					local hitx, hity = x + (rparam * dx), y + (rparam * dy)
					rawset(rparams, i, { x = hitx, y = hity })
				end
			end
			rawset(candidates, col, rparams)
		else
			rawset(candidates, col, nil)
		end
	end
	return candidates
end

function HC:shapesAt(x, y)
	local candidates = {}
	for c in pairs(self._hash:cellAt(x, y)) do
		if c:contains(x, y) then
			rawset(candidates, c, c)
		end
	end
	return candidates
end