local Info, Addon = ...

-- Either: Animal = class(function(self, name)
--     self.name = name
-- end)
-- or: Dog = class(Animal, function(self, name)
--     Animal._constructor(self, name)
-- end)
function Addon.class(parent, constructor)
	local mt = {}
	local class = setmetatable({}, mt)
	if type(parent) == "table" then
		for key, value in next, parent do
			class[key] = value
		end
		class._parent = parent
	else
		constructor = parent
	end
	class.__index = class
	class._constructor = constructor
	mt.__call = function(self, ...)
		local instance = setmetatable({}, class)
		if constructor then
			constructor(instance, ...)
		elseif parent._constructor then
			parent._constructor(instance, ...)
		end
		return instance
	end
	return class
end
