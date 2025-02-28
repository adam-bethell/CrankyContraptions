import "scripts/util/vector"

Collisions = {}
function Collisions.resolveCollision(a, b, separatingVector)
    if separatingVector.x == 0 and separatingVector.y == 0 then
        return
    end

    --- Calculating impulse
    -- Calculate relative velocity
    -- rv = a.velocity - b.velocity
    local rv = {}
    rv.x, rv.y = Vector.sub(a.velocity.x, a.velocity.y, b.velocity.x, b.velocity.y)

    -- Calculate relative velocity in terms of the normal direction
    local normal = {}
    normal.x, normal.y = Vector.normalize(separatingVector.x, separatingVector.y)
    local velAlongNormal = Vector.dot(rv.x, rv.y, normal.x, normal.y)

    -- Do not resolve if velocities are separating 
    if (velAlongNormal > 0) then
        return
    end

    --- Move A back outside of the object it colided with
    a.position.x += separatingVector.x
    a.position.y += separatingVector.y

    -- Apply Friction
    a.velocity.x, a.velocity.y = Vector.mul(0.9, a.velocity.x, a.velocity.y)

    -- Calculate the effective mass
    -- This may be used inthe future for handing our impulse to 2 objects
    local effective_mass = a.mass

    -- Calculate impulse scalar
    local impulse_scalar = -((1 + a.restitution) * velAlongNormal)

    -- Calculate impulse vector
    local impulse_vector = {}
    impulse_vector.x, impulse_vector.y = Vector.mul(impulse_scalar, normal.x, normal.y)

    a.velocity.x, a.velocity.y = Vector.add(a.velocity.x, a.velocity.y, impulse_vector.x, impulse_vector.y)
end