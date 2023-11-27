local Info, Addon = ...

local RaidManager = {}
Addon.RaidManager = RaidManager

local PlayerID = ""
local Grouped = false
local Units = {} -- used for fast O(1) UnitExists() calls. Keys are unit ids, values are groupXY identifiers
local Raid = {} -- vice versa. Keys are groupXY identifiers, values are unit ids
RaidManager.Units = Units
RaidManager.Raid = Raid

local GroupJoinTrigger = Utility.Event.Create(Info.identifier, "Group.Join")
local GroupChangeTrigger = Utility.Event.Create(Info.identifier, "Group.Change")
local GroupLeaveTrigger = Utility.Event.Create(Info.identifier, "Group.Leave")

local PlayerJoinTrigger = Utility.Event.Create(Info.identifier, "Player.Join")
local PlayerLeaveTrigger = Utility.Event.Create(Info.identifier, "Player.Leave")


function RaidManager.UnitExists(unit)
	return Units[unit] ~= nil
end

function RaidManager.Grouped()
	return Grouped
end

local function InitialRegister()
	for i = 1, 20 do
		local identifier = ("group%02d"):format(i)
		Command.Event.Attach(Library.LibUnitChange.Register(identifier), function(handle, unit)
			local previous = Raid[identifier]
			unit = unit and unit or nil -- cast false unit to nil
			
			if previous then
				Units[previous] = nil
			end
			
			Raid[identifier] = unit
			if unit then
				Units[unit] = identifier
			end
			
			if not unit then
				GroupLeaveTrigger(previous, identifier)
				if previous == PlayerID then
					Grouped = false
					PlayerLeaveTrigger()
				end
			elseif not previous then
				GroupJoinTrigger(unit, identifier)
				if not Grouped then
					Grouped = true
					PlayerJoinTrigger()
				end
			else
				GroupChangeTrigger(unit, identifier)
			end
		end, identifier .. " changed")
		
		local identifierPet = identifier .. ".pet"
		Command.Event.Attach(Library.LibUnitChange.Register(identifierPet), function(handle, unit)
			local previous = Raid[identifierPet]
			unit = unit and unit or nil -- cast false unit to nil
			
			if previous then
				Units[previous] = nil
			end
			
			Raid[identifierPet] = unit
			if unit then
				Units[unit] = identifierPet
			end
		end, identifierPet .. " changed")
	end
end
InitialRegister()

local function InitialScan()
	local identifiers = {}
	for i = 1, 20 do
		identifiers[("group%02d"):format(i)] = true
	end
	local details = Inspect.Unit.Detail(identifiers)
	for identifier, detail in pairs(details) do
		Raid[identifier] = detail.id
		Units[detail.id] = identifier
	end
end

local function EventUnitAvailabilityFull(handle, units)
	PlayerID = Inspect.Unit.Lookup("player")
	InitialScan()
	Command.Event.Detach(Event.Unit.Availability.Full, EventUnitAvailabilityFull)
end
Command.Event.Attach(Event.Unit.Availability.Full, EventUnitAvailabilityFull, "Unit Availability Startup")
