Vector = {}

function Vector.distance(x1, y1, x2, y2)
    return math.sqrt(((x1-x2)^2) + ((y1-y2)^2))
end

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

function Vector.mul(s, x,y)
	return s*x, s*y
end

function Vector.div(s, x,y)
	return x/s, y/s
end

function Vector.add(x1,y1, x2,y2)
	return x1+x2, y1+y2
end

function Vector.sub(x1,y1, x2,y2)
	return x1-x2, y1-y2
end

function Vector.permul(x1,y1, x2,y2)
	return x1*x2, y1*y2
end

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

function Vector.len2(x,y)
	return x*x + y*y
end

function Vector.len(x,y)
	return math.sqrt(x*x + y*y)
end

function Vector.dist(x1,y1, x2,y2)
	return Vector.len(x1-x2, y1-y2)
end

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
