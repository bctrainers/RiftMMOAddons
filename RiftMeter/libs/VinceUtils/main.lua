local Info, Addon = ...

Library.VinceUtils = Library.VinceUtils or Addon

local floor = math.floor

function Addon.round(num, digits)
	local mult = 10^(digits or 0)
	return floor(num * mult + .5) / mult
end
