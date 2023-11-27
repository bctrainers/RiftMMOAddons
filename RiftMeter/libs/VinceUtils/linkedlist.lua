local Info, Addon = ...

local Element = Addon.class(function(self, value)
	self.value = value
	self.previous = nil
	self.next = nil
end)
function Element:Remove()
	if self.previous then
		self.previous.next = self.next
	end
end


Addon.LinkedList = Addon.class(function(self)
	self.first = nil
	self.last = nil
	self.size = 0
end)
local LinkedList = Addon.LinkedList
function LinkedList:Add(value)
	local element = Element(value)
	self.size = self.size + 1

	if not self.first then
		self.first = element
		self.last = element
		return element
	end

	element.previous = self.last
	element.previous.next = element
	self.last = element

	return element
end
function LinkedList:Remove(value)
	for element, val in self:Each() do
		if val == value then
			element.previous = element.next
			return val
		end
	end
end
function LinkedList:Each()
	local pos = self.first
	return function()
		if not pos then
			return nil
		end
		local current = pos
		pos = pos.next
		return current, current.value
	end
end
function LinkedList:Size()
	return self.size
end
