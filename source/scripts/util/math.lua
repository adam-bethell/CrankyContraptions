math.clamp = function(x, min, max)
    return math.max(math.min(x, max), min)
end

math.wrap = function(value, lower, upper, change)
    value += change
    
    while value ~= math.clamp(value, lower, upper) do
        if value > upper then
            value = lower + (value - upper)
        end

        if value < lower  then
            value = upper - (lower - value)
        end
    end

    return value
end