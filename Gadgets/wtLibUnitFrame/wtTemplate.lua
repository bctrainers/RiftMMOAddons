--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.UnitFrameTemplate
		Provides a fluent mechanism for creating a set of Elements (ie. building a template)
--]]

WT.UnitFrameTemplate = {}
WT.UnitFrameTemplate_mt = 
{ 
	__index = 
		function(tbl,name)
			if WT.UnitFrameTemplate[name] then return WT.UnitFrameTemplate[name] end
			if tbl.factory and tbl.factory[name] then return tbl.factory[name] end
			return nil 
		end 
} 

-- This declares a template, but does not create an instance of it. The end result is
-- an ordered list of element configuration tables.
function WT.UnitFrameTemplate.Define(id)
	local template = {}
	template.id = id
	template.current = false
	template.Configuration = {}

	template.Configuration.Name = id
	template.Configuration.RaidSuitable = true
	template.Configuration.FrameType = "Frame"
	template.Configuration.Width = 100
	template.Configuration.Height = 50

	template.elements = {}
	setmetatable(template, WT.UnitFrameTemplate_mt)
	WT.UnitFrame.Templates[id] = template
	return template
end

-- Actually creates the unit frame instance, giving it the specified id
function WT.UnitFrameTemplate:Create(unitSpec, options)

	local uf = WT.UnitFrame:Create(unitSpec, options)

	for idx,element in ipairs(self.elements) do
		if options.excludeBuffs and element.type=="BuffPanel" then
			-- Don't add buff panels if excluding them
		else
			uf:CreateElement(element)
		end 
	end
	
	return uf
end

function WT.UnitFrameTemplate:Name(value)
	self.Configuration.Name = value
	return self
end

function WT.UnitFrameTemplate:Size(width, height)
	self.Configuration.Width = width
	self.Configuration.Height = height
	return self
end

function WT.UnitFrameTemplate:RaidSuitable(value)
	self.Configuration.RaidSuitable = value
	return self
end

function WT.UnitFrameTemplate:Element(type, id, config)
	self.current = {}

	if config then
		for k,v in pairs(config) do self.current[k] = v end
	end

	if id then
		self.current.id = id
	else
		-- if an id is not specified, generate a default id. Ids that start with an underscore will be excluded from any user config options
		self.current.id = "_elem_" .. (#self.elements + 1)
	end
	
	self.factory = WT.ElementFactories[type]
	if not self.factory then
		WT.Log.Warning("Template contains unknown element type: " .. type)
		self.factory = WT.ElementFactories["Frame"]
	end
	
	self.current.type = type 
	
	table.insert(self.elements, self.current)
	return self
end

function WT.UnitFrameTemplate:Layer(value)
	self.current.layer = value
	return self
end

function WT.UnitFrameTemplate:Alpha(value)
	self.current.alpha = value
	return self
end

function WT.UnitFrameTemplate:VisibilityBinding(value)
	self.current.visibilityBinding = value
	return self
end

function WT.UnitFrameTemplate:Parent(value)
	self.current.parent = value
	return self
end
 
function WT.UnitFrameTemplate:Anchor(pointFrom, elementId, pointTo, offsetX, offsetY)
	if not self.current.attach then self.current.attach = {} end
	local anchor = {}
	anchor.element = elementId
	anchor.point = pointFrom
	anchor.targetPoint = pointTo
	anchor.offsetX = offsetX
	anchor.offsetY = offsetY
	table.insert(self.current.attach, anchor)
	return self
end
