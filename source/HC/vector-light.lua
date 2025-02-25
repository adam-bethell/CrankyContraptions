--[[
This software is a Playdate SDK port by Adam Bethell of HC, the general purpose collision library for the LOVE framework.
HC was originally written by Matthias Richter and his licence "Original GC license.rst"
]]

local sqrt, cos, sin = math.sqrt, math.cos, math.sin

Vector_light = {}

function Vector_light.str(x,y)
	return "("..tonumber(x)..","..tonumber(y)..")"
end

function Vector_light.mul(s, x,y)
	return s*x, s*y
end

function Vector_light.div(s, x,y)
	return x/s, y/s
end

function Vector_light.add(x1,y1, x2,y2)
	return x1+x2, y1+y2
end

function Vector_light.sub(x1,y1, x2,y2)
	return x1-x2, y1-y2
end

function Vector_light.permul(x1,y1, x2,y2)
	return x1*x2, y1*y2
end

function Vector_light.dot(x1,y1, x2,y2)
	return x1*x2 + y1*y2
end

function Vector_light.det(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end

function Vector_light.eq(x1,y1, x2,y2)
	return x1 == x2 and y1 == y2
end

function Vector_light.lt(x1,y1, x2,y2)
	return x1 < x2 or (x1 == x2 and y1 < y2)
end

function Vector_light.le(x1,y1, x2,y2)
	return x1 <= x2 and y1 <= y2
end

function Vector_light.len2(x,y)
	return x*x + y*y
end

function Vector_light.len(x,y)
	return sqrt(x*x + y*y)
end

function Vector_light.dist(x1,y1, x2,y2)
	return Vector_light.len(x1-x2, y1-y2)
end

function Vector_light.normalize(x,y)
	local l = Vector_light.len(x,y)
	return x/l, y/l
end

function Vector_light.rotate(phi, x,y)
	local c, s = cos(phi), sin(phi)
	return c*x - s*y, s*x + c*y
end

function Vector_light.perpendicular(x,y)
	return -y, x
end

function Vector_light.project(x,y, u,v)
	local s = (x*u + y*v) / (u*u + v*v)
	return s*u, s*v
end

function Vector_light.mirror(x,y, u,v)
	local s = 2 * (x*u + y*v) / (u*u + v*v)
	return s*u - x, s*v - y
end
