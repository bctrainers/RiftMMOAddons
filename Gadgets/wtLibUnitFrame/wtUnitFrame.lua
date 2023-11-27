--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.UnitFrame
	
		Inherits from Frame
		
		Provides a base class for the implementation of unit frames. A unit frame is linked to a
		unit specifier, and provides a mechanism for binding properties on a unit to function calls
		allowing a unit frame to automatically update itself as the underlying unit state changes.

	API
	
		Static Methods
		
			WT.UnitFrame.CreateFromTemplate(templateName, unitSpec)
				Creates an instance of a unit frame based on the requested template, linked to the requested
				unit specifier.
		
			WT.UnitFrame:Create(unitSpec)
				Create an instance of a unit frame and attach it to @unitSpec

			WT.UnitFrame.UniqueName()
				Generates a unique frame name (utility method to ease creation of frames)

			WT.UnitFrame:Template(templateName)
				Creates a subclass of WT.UnitFrame, which is expected to provide a template for
				new unit frame create.

		Instance Methods

			unitFrame:CreateBinding(property, bindToObject, bindToMethod, default, converter)
				Creates a binding between the property, and a method on an object. Whenever the property
				changes, the binding method will be called with the value of the property, unless the value 
				is nil/false where the default is used.
				If a converter function is provided, any non-default values will be passed through this
				function prior to the method being called. 

			unitFrame:CreateTokenBinding(tokenString, bindToObject, bindToMethod, default, converter)
				Creates a binding between a token string and an object method. The token string can contain
				plain text and tokens wrapped in braces {}. Tokens are replaced by the property with the same 
				name, e.g. {name} will be replaced by the unit's name.
				Note: Every token in the token string must be backed by a property with a value. If any
				of the properties are not available, the default value is returned.
				Example usage: uf:CreateTokenBinding("{health}/{healthMax}", txtHealth, txtHealth.SetText, "") 

			unitFrame:CreateTextField(property, default, parentFrame)
				Creates a new Text frame, automatically bound to the provided property.
				The default value is "" if not provided.
				The parentFrame defaults to the UnitFrame itself.

			unitFrame:CreateTokenField(tokenString, default, parentFrame)
				Creates a new Text frame, automatically bound to the provided token string.
				The default value is "" if not provided.
				The parentFrame defaults to the UnitFrame itself.

			unitFrame:CreateHorizontalBar(width, height, textureAddon, textureFile, parent)
				Creates a bar frame, which can be used to show health/mana etc. The width and height of the bar
				must be provided, along with the details of a texture to apply to the bar.
				The parent is optional, and will default to the WT.UnitFrame if not provided.
				The returned frame is a Mask, with a Texture frame linked to it. This object has the following
				additional methods to effect the bar:
					:SetPercent(percentage)
						This will set the width of the bar to the provided percentage of its full width
					:SetColor(r,g,b,a)
						This will set the background color of the associated Texture frame. Bar textures have to
						be designed with appropriate transparency for this to have an effect. 

		Subclass Override Methods
		
			unitFrame:OnUnitSet(unitId)
			unitFrame:OnUnitCleared()
			unitframe:OnBuffAdded(buffId, buff, priority)
			unitframe:OnBuffChanged(buffId, buff, priority)
			unitframe:OnBuffRemoved(buffId, buff, priority)
			unitframe:OnCastBegin(castbarDetails)
			unitframe:OnCastEnd()
			
		Instance Properties
		
			Unit		References a Unit from the UnitDatabase, or nil if no current unit
			UnitSpec	The UnitSpec associated with the frame. Do not change this value

		Notes
		
			It is not expected that a client addon will directly create a UnitFrame instance. A WT.UnitFrameTemplate
			should be defined that handles the construction of a specific UnitFrame, and it is this template that will
			implement methods as required.
			
			A client will therefore use WT.CreateUnitFrame(templateName, unitSpec) to create an instance of a unit frame.
			
			For complex bindings to multiple source properties, use a virtual property. These are defined within the 
			unit database, using WT.UnitDatabase.CreateVirtualProperty(...)
--]]

local toc, data = ...
local AddonId = toc.identifier

WT.UnitFrame = {}
WT.UnitFrames = {}
WT.UnitFrame.Templates = {}

WT.UnitFrameContext = UI.CreateContext("WTUnitFrameContext")
WT.UnitFrameContext:SetStrata("hud")
WT.UnitFrameContext:SetSecureMode("restricted")

-- namespaces for element implementations
WT.Element = {} 
WT.ElementFactories = {}

WT.UnitFrame_mt = 
{ 	
	__index = function(tbl, name)
		-- Check for a property in the class if one is set
		if tbl._class and tbl._class[name] then return tbl._class[name] end
		-- Otherwise check the UI.Frame class for the name and use it
		if WT.UnitFrame._uiFrame_index[name] then return WT.UnitFrame._uiFrame_index[name] end
		-- Give up, it doesn't exist in any of our superclasses
		return nil
	end
}

local unitFrameCount = 0
local awaitingDetails = {}

-- table to hold unit change functions
-- this is a change to allow unit frames to switch their tracked unit dynamically
local unitChangeTrackers = {}

-- Return a unique name for a frame. Used to ensure all frames are given unique names
function WT.UnitFrame.UniqueName()
	return WT.UniqueName("WT_FRAME")
end


function WT.UnitFrame:Template(templateName)
	local obj = {}
	obj.Template = templateName
	obj.Configuration = {}
	setmetatable(obj, { __index = self })
	WT.UnitFrame.Templates[templateName] = obj
	return obj
end


function WT.UnitFrame:CreateElement(configuration, forceParent)

	if not configuration.type then
		WT.Log.Error("No type specified in element configuration")
		return nil
	end

	if not configuration.id then
		WT.Log.Error("No id specified in element configuration")
		return nil
	end

	if self.Elements[configuration.id] then
		WT.Log.Error("Duplicate element ID " .. tostring(configuration.id))
		return nil
	end

	local factory = WT.ElementFactories[configuration.type]
	if not factory then
		WT.Log.Error("No element factory for type " .. tostring(configuration.type))
		return nil
	end

	local element = factory:Create(self, configuration, forceParent)
	if not element then
		WT.Log.Error("Element factory for " .. tostring(configuration.type) .. " failed to create " .. tostring(configuration.id))
		return nil
	end

	self.Elements[configuration.id] = element
	
	return element

end

--[[ 
local el = frame:CreateElement
{
	id = "buffPanel01",
	type = "BuffPanel",
	binding = "Buffs",
	anchorTo = { element = self, point = "TOPLEFT", targetPoint = "TOPLEFT", offsetX = 5, offsetY = 5 },
	rows=1, cols=5, iconSize=20, iconSpacing=1, borderThickness=1, 
	acceptLowPriorityBuffs=true, acceptMediumPriorityBuffs=true, acceptHighPriorityBuffs=true, acceptCriticalPriorityBuffs=true,
	acceptLowPriorityDebuffs=false, acceptMediumPriorityDebuffs=false, acceptHighPriorityDebuffs=false, acceptCriticalPriorityDebuffs=false,
	growthDirection = "left_up"
}
--]]

function WT.UnitFrame:TrackUnit(unitSpec)

	if Inspect.System.Secure() then
		WT.Log.Warning("Cannot change a unit tracker while in combat")
	end

	if not unitChangeTrackers[unitSpec] then
		unitChangeTrackers[unitSpec] = 
			function(unitId)
				for idx,frame in ipairs(WT.UnitFrames) do
					if frame.UnitSpec == unitSpec then
						frame:PopulateUnit(unitId)
					end
				end
			end
		table.insert(Library.LibUnitChange.Register(unitSpec), { unitChangeTrackers[unitSpec],  AddonId, AddonId .. "_UnitFrame_OnUnitChange_" .. unitSpec })
	end

	self.UnitSpec = unitSpec
	local unitId = Inspect.Unit.Lookup(unitSpec)
	self:PopulateUnit(unitId)
	WT.SecureFunction(function() self:RebuildMacros() end)

end

-- Creates a new instance of a UnitFrame, which inherits from UI.Frame
-- This uses a prototype based approach to inheritance. It inherits from a Frame instance so that
-- a UnitFrame has all of the Layout functionality of a Frame, but it also adds in all of the methods
-- from the UnitFrame class by adding in references
-- If an options table is included in this call, it will be passed to the Construct function to provide options
-- for use by the template.
function WT.UnitFrame:Create(unitSpec, options)

	local frameName = WT.UniqueName("WT_UNITFRAME", unitSpec)
	
	if not self.Configuration then self.Configuration = {} end
	
	local frame = UI.CreateFrame(self.Configuration.FrameType or "Frame", frameName, WT.UnitFrameContext)
	if self.Configuration.Width then frame:SetWidth(self.Configuration.Width) end
	if self.Configuration.Height then frame:SetHeight(self.Configuration.Height) end

	-- store a reference to the subclass that is actually being created
	frame._class = self
	
	if not WT.UnitFrame._uiFrame_index then
		WT.UnitFrame._uiFrame_index = getmetatable(frame).__index
	end
	
	setmetatable(frame, WT.UnitFrame_mt) 
	
	-- Manually add in the UnitFrame methods. This means that the metatable will be used to access the 
	-- base Frame, while also having UnitFrame functionality available. 
	--for k,v in pairs(WT.UnitFrame) do frame[k] = v end
	
	frame.UnitId = false
	frame.UnitSpec = unitSpec
	frame.Bindings = {}
	frame.Elements = {}	
	frame.Animations = {}
	frame.Options = options or {}
	frame.BuffAllocations = {}
	frame.BuffData = {}
		
	frame.Elements["frame"] = frame
		
	-- Store the UnitFrame in the global list of frames
	table.insert(WT.UnitFrames, frame)	

	if frame.Construct then frame:Construct(options) end
	
	frame:ApplyDefaultBindings()
	
	-- Track changes to the linked UnitId, and call into PopulateUnit	
	frame:TrackUnit(unitSpec)	
	-- table.insert(Library.LibUnitChange.Register(unitSpec), { function(unitId) frame:PopulateUnit(unitId) end,  AddonId, AddonId .. "_UnitFrame_OnUnitChange_" .. frameName })
	
	local createOptions = {}
	createOptions.resizable = self.Configuration.Resizable 

	return frame, createOptions
end


function WT.UnitFrame:OnResize(width, height)
	self:ApplyBindings()
end



function WT.UnitFrame:PopulateUnit(unitId)
	self.UnitId = unitId
	if unitId then
		self.Unit = WT.UnitDatabase.GetUnit(unitId)
		if not self.Unit then
			awaitingDetails[self] = true
		else
			self:ApplyBindings()
		end
	else
		self.Unit = nil
		self:ApplyDefaultBindings()
	end
	self:ApplyBuffDelta()
end




-- This is the default implementation of the buff filter method. It will always respond with 2, meaning normal priority.
-- A buff filter takes buff details as a parameter, and returns a number between 0 and 4 as follows:
-- 0 - Ignore this buff
-- 1 - Low priority buff. First to drop off if no space
-- 2 - Medium priority buff. This is a normal buff/debuff. Will take priority over low if necessary.
-- 3 - High priority buff. This takes priority over normal buffs, and may be highlighted/larger if the template allows.
-- 4 - Critical buff. This would usually be a debuff, and the template should highlight it. This should be a debuff that
--     the player needs to respond to urgently. 
function WT.UnitFrame:GetBuffPriority(buff)
	return 2
end



-- Event Handlers --------------------------------------------------------------------------------

local function OnUnitAdded(hEvent, unitId)
	for frame in pairs(awaitingDetails) do
		if frame.UnitId == unitId then
			frame:PopulateUnit(frame.UnitId)
			awaitingDetails[frame] = nil
		end
	end
	-- Need to rescan if a unit has become available again (e.g. after zoning)
	for idx, frame in ipairs(WT.UnitFrames) do
		if frame.UnitId == unitId then
			frame:PopulateUnit(unitId)
		end
	end
end


local function OnUnitPropertySet(hEvent, unit, property, newValue, oldValue)
	-- Execute the bindings for any UnitFrame that is currently linked to this unit
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.Unit.id == unit.id and unitFrame.Bindings[property] then
			for idx, binding in ipairs(unitFrame.Bindings[property]) do
				local value = newValue
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	end
end

local function OnBuffUpdates(hEvent, unitId, changes)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.Unit.id == unitId then
			unitFrame:BuffHandler(changes.add, changes.remove, changes.update)
		end
	end
end

local function OnCastbarShow(hEvent, unitId, castbar)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnCastBegin then
			unitFrame:OnCastBegin(castbar)
		end
	end
end

local function OnCastbarHide(hEvent, unitId)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnCastEnd then
			unitFrame:OnCastEnd()
		end
	end
end


-- Register for change events from the UnitDatabase
Command.Event.Attach(WT.Event.UnitAdded, OnUnitAdded, AddonId .. "_UnitFrame_UnitAdded" )
Command.Event.Attach(WT.Event.UnitPropertySet, OnUnitPropertySet, AddonId .. "_UnitFrame_UnitPropertySet" )
Command.Event.Attach(WT.Event.BuffUpdates, OnBuffUpdates, AddonId .. "_UnitFrame_BuffUpdates" )
Command.Event.Attach(WT.Event.CastbarShow, OnCastbarShow, AddonId .. "_UnitFrame_CastbarShow" )
Command.Event.Attach(WT.Event.CastbarHide, OnCastbarHide, AddonId .. "_UnitFrame_CastbarHide" )

