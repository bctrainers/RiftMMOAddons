local toc, data = ...
local AddonId = toc.identifier


-- Creates a binding from a property to an object method
function WT.UnitFrame:CreateBinding(property, bindToObject, bindToMethod, default, converter)
	WT.Log.Debug(self.UnitSpec .. ": Creating binding for " .. property)
	-- Create the binding object
	local binding = {}
	binding.property = property
	binding.object = bindToObject
	binding.method = bindToMethod
	binding.default = default
	binding.converter = converter
	-- Add the binding to the UnitFrame's bindings list
	if not self.Bindings[property] then self.Bindings[property] = {} end	
	table.insert(self.Bindings[property], binding)
end


local function CommaFormat(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end


local function NumberFormat(tokenValue)

	local numFormat = wtxOptions.numberFormat or "short"

	tokenValue = math.ceil(tokenValue)
	
	if numFormat == "long" then
		tokenValue = CommaFormat(tokenValue)
	end
	
	if numFormat == "short" then
		if (tokenValue >= 1000000) then 
			tokenValue = CommaFormat(string.format("%.1f", tokenValue / 1000000)) .. "M" 
		elseif tokenValue >= 10000 then
			tokenValue = CommaFormat(string.format("%.1f", tokenValue / 1000)) .. "K"
		end 
	end
	
	return tokenValue
	
end


-- Creates a binding from a token string
function WT.UnitFrame:CreateTokenBinding(tokenString, bindToObject, bindToMethod, default, maxLength)

	local tokens = {}
	local tokenCount = 0
	for token in string.gmatch(tokenString, "{(%w+)}") do
		tokens[token] = true
		tokenCount = tokenCount + 1
	end
	
	if tokenCount == 0 then
		-- This is just a static text label, there are no tokens in it
		bindToObject:SetText(tokenString)
		return
	end
	
	local function fn(bindingObject, dummyValue)
		if not self.Unit then 
			bindToMethod(bindToObject, default)
			return 
		end
		local text = tokenString
		for token in pairs(tokens) do
			if not self.Unit[token] then 
				bindToMethod(bindToObject, default)
				return 
			end
			local tokenValue = self.Unit[token]
			if type(tokenValue) == "number" then 
				tokenValue = NumberFormat(tokenValue)
			end
			if not tokenValue then tokenValue = "" end
			text = text:gsub("{" .. token .. "}", tokenValue)
		end
		if maxLength and (text:len() > maxLength) then
			text = text:sub(1, maxLength)
		end
		bindToMethod(bindToObject, text)
	end

	for dependency in pairs(tokens) do
		-- This is where we need to register the dependencies to trigger this binding
		-- Uses standard bindings to trigger the binding function above
		self:CreateBinding(dependency, bindToObject, fn, default)
	end

end

-- Applies the default values to all bindings on this unit frame
function WT.UnitFrame:ApplyDefaultBindings()
	if self.Bindings then
		for property, bindings in pairs(self.Bindings) do
			for idx, binding in pairs(bindings) do
				WT.Log.Debug("AppyDefaultBinding: " .. binding.property)
				binding.method(binding.object, binding.default)
			end
		end
	end
end


-- Applies the bindings on this unit frame
function WT.UnitFrame:ApplyBindings()
	self.rebinding = true
	if self.Unit and self.Bindings then
		for property, bindings in pairs(self.Bindings) do
			for idx, binding in pairs(bindings) do
				local value = self.Unit[property]
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	else
		self:ApplyDefaultBindings()
	end
	self.rebinding = false
end


function WT.UnitFrame.RefreshAllBindings(hEvent)
	for idx, uf in ipairs(WT.UnitFrames) do
		uf:ApplyBindings()
	end
end

Command.Event.Attach(WT.Event.SettingsChanged, WT.UnitFrame.RefreshAllBindings, "SettingsChanged")
