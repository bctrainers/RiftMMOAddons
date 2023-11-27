-- Adelea (Thank you for this)
local addon, shared = ...
local id = addon.identifier

local GJK = {buffID={}}

GJK.AbilityNames = {
	["Unholy Dominion"] = true,
	["Mindsear"] = true,
        ["Infernal Radiance"] = true,
	["Spirit Shackle"] = true,
        ["Ensnaring Creepers"] = true,
        ["Aggressive Infection"] = true,
--	,
}

if WT.Unit.VirtualProperties["alertHealthColor"] ~= nil then
	WT.Unit.VirtualProperties["alertHealthColor"] = nil
end

WT.Unit.CreateVirtualProperty("alertHealthColor", { "id", "cleansable", "buffAlert" },
	function(unit)
		if unit.buffAlert then
			return { r=0.5, g=0.5, b=0, a=1 }
		elseif unit.cleansable then
			return { r=0.2, g=0.15, b=0.4, a=0.85}
		else
			return { r=0.07, g=0.07, b=0.07, a=0.85}
		end	
	end
)

local buffID = ""
local buffUnit = ""

function GJK.Event_Buff_Add(u,t)
	for k,v in pairs(Inspect.Buff.Detail(u,t)) do
		if GJK.AbilityNames[v.name] and WT.Units[u] then
			GJK.buffID[u] = k
			WT.Units[u]["buffAlert"] = true
		end
	end
end

function GJK.Event_Buff_Remove(u,t)
	for k,v in pairs(t) do
		if GJK.buffID[u] == k then
			WT.Units[u]["buffAlert"] = false
			GJK.buffID[u] = nil
		end
	end
end

table.insert(Event.Buff.Add, { GJK.Event_Buff_Add, addon.identifier, "Event.Buff.Add" })
table.insert(Event.Buff.Remove, { GJK.Event_Buff_Remove, addon.identifier, "Event.Buff.Remove" })