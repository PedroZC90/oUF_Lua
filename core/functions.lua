local T, C, L, G = unpack(select(2, ...))

local gsub = string.gsub
local format = string.format
local floor = math.floor
local ceil = math.ceil

------------------------------------------------------------
-- General Functions
------------------------------------------------------------

-- return a short value of a number.
T.ShortValue = function(value)
	if (value >= 1e6) then
		return gsub(format("%.1fm", value / 1e6), "%.?0+([km])$", "%1")
	elseif (value >= 1e3 or value <= -1e3) then
		return gsub(format("%.1fk", value / 1e3), "%.?0+([km])$", "%1")
	else
		return value
	end
end

-- return a round number
T.RoundValue = function(number, decimals)
	local mult = math.pow(10, decimal or 0)
	return ceil(mult * number) / mult
end

-- convert seconds to day/hour/minute
T.FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	
	if (s >= day) then
		return format("%dd", ceil(s / day))
	elseif (s >= hour) then
		return format("%dh", ceil(s / hour))
	elseif (s >= minute) then
		return format("%dm", ceil(s / minute))
	elseif (s >= (minute / 12)) then
		return format("%d", s)
	else
		return format("%.1f", s)
	end
end

-- return a RGB color between n-colors
-- http://www.wowwiki.com/ColorGradient
T.RGBColorGradient = function(a, b, ...)
	local perc = a / b
	if (perc >= 1) then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif (perc <= 0) then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((3 * segment) + 1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

-- convert color RGB code to Hex code.
T.RGBToHex = function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- function: calculate a integer size for frames as combo-points/runes/chi
-- frame size need to follow the equation: width = number * size + (number - 1) * spacing
T.GetElementSize = function(width, number, spacing)
	-- calculate frame size to fit into the width.
	local size = (width - (number - 1) * spacing) / number
	-- difference between the calculate size and the INT size.
	local delta = T.RoundValue((size - floor(size)) * number, 1)
	return floor(size), delta
end