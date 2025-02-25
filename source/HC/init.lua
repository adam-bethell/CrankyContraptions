--[[
This software is a Playdate SDK port by Adam Bethell of HC, the general purpose collision library for the LOVE framework.
HC was originally written by Matthias Richter and his licence "Original GC license.rst"
]]

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