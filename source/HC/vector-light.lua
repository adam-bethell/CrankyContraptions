--[[
Copyright (c) 2012 Matthias Richter

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
