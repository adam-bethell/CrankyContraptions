Vector = {}

function Vector.addToPoint(x, y, deg, mag)
    deg -= 90
    local dx = math.cos(math.rad(deg)) * mag
    local dy = math.sin(math.rad(deg)) * mag
    return x+dx, y+dy
end

--[[
    The below vector functions where taken from HC
    https://github.com/vrld/HC
]]

-- Multiply a vector by a scalar.
function Vector.mul(s, x,y)
	return s*x, s*y
end

-- Devide a vector by a scalar.
function Vector.div(s, x,y)
	return x/s, y/s
end

-- Add 2 vectors together.
function Vector.add(x1,y1, x2,y2)
	return x1+x2, y1+y2
end

-- Vector subtraction. Can by used to get a vector going from x2y2 to x1y1. 
function Vector.sub(x1,y1, x2,y2)
	return x1-x2, y1-y2
end

-- Vector multiplication.
function Vector.permul(x1,y1, x2,y2)
	return x1*x2, y1*y2
end

-- Get the dot product of 2 vectors.
function Vector.dot(x1,y1, x2,y2)
	return x1*x2 + y1*y2
end

function Vector.det(x1,y1, x2,y2)
	return x1*y2 - y1*x2
end

function Vector.eq(x1,y1, x2,y2)
	return x1 == x2 and y1 == y2
end

function Vector.lt(x1,y1, x2,y2)
	return x1 < x2 or (x1 == x2 and y1 < y2)
end

function Vector.le(x1,y1, x2,y2)
	return x1 <= x2 and y1 <= y2
end

-- Get the squared magnitude of a vector
function Vector.len2(x,y)
	return x*x + y*y
end

-- Get the magnitude of a vector
function Vector.len(x,y)
	return math.sqrt(x*x + y*y)
end

-- Get the distance between 2 vectors
function Vector.dist(x1,y1, x2,y2)
	return Vector.len(x1-x2, y1-y2)
end

-- Normalize a vector so it's magnitude  is 1
function Vector.normalize(x,y)
	local l = Vector.len(x,y)
	return x/l, y/l
end

function Vector.rotate(phi, x, y)
	local c, s = math.cos(phi), math.sin(phi)
	return c*x - s*y, s*x + c*y
end

function Vector.perpendicular(x,y)
	return -y, x
end

function Vector.project(x,y, u,v)
	local s = (x*u + y*v) / (u*u + v*v)
	return s*u, s*v
end

function Vector.mirror(x,y, u,v)
	local s = 2 * (x*u + y*v) / (u*u + v*v)
	return s*u - x, s*v - y
end
