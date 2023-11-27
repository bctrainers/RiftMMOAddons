local addon, shared = ...
local id = addon.identifier

GJK = {buffID={}}

GJK.AbilityNames = {
	["Unholy Dominion"] = true,
	["Mindsear"] = true,
    ["Infernal Radiance"] = true,
	["Spirit Shackle"] = true,
    ["Ensnaring Creepers"] = true,
    ["Aggressive Infection"] = true,
	["Blinding Radiance"] = true,
	["Tides of Insanity"] = true,
	["Infernal Tether"] = true,
	["Pulsar"] = true,
	["Toxin"] = true,
	["Sapping Cold"] = true,
	["The Contained Depths"] = true,
	["Unbounded Consciousness"] = true,	
	["Absolute Zero"] = true,	
	["Conduit of Martrodraum"] = true,	
	["Akvan Parasite"] = true,		
	["Overcharged"] = true,	
	["Tow Cable"] = true,	
	["Demonic Leash"] = true,
    ["Soul Siphon"] = true,	
	["Ancient Flames"] = true,
	["Lightning Rod"] = true,
	["Soul Purification"] = true,
	["Gaze of Akylios"] = true,
	["Abyssal Torrent"] = true,	
	["Explosive Venom"] = true,
	["Curse of Greed"] = true,
	["The Point Protection"] = true,	
	["Protection of Dance"] = true,		
--[""] = true,	
--	,
}


if WT.Unit.VirtualProperties["alertHealthColor"] ~= nil then
	WT.Unit.VirtualProperties["alertHealthColor"] = nil
end

WT.Unit.CreateVirtualProperty("alertHealthColor", { "id", "cleansable", "buffAlert" },
	function(unit)
		if unit.buffAlert then
			if wtxGadgets.RaidFrames1 then
			if wtxGadgets.RaidFrames1.AlertColor then
				return {r=wtxGadgets.RaidFrames1.AlertColor[1],g=wtxGadgets.RaidFrames1.AlertColor[2],b=wtxGadgets.RaidFrames1.AlertColor[3],a=wtxGadgets.RaidFrames1.AlertColor[4]}
			else return { r=0.5, g=0.5, b=0, a=0.85 }  end
			else return { r=0.5, g=0.5, b=0, a=0.85 }  end

		elseif unit.cleansable then
			if wtxGadgets.RaidFrames1 then
			if wtxGadgets.RaidFrames1.CleanseColor then
			return {r=wtxGadgets.RaidFrames1.CleanseColor[1],g=wtxGadgets.RaidFrames1.CleanseColor[2],b=wtxGadgets.RaidFrames1.CleanseColor[3],a=wtxGadgets.RaidFrames1.CleanseColor[4]}
			else return { r=0.2, g=0.15, b=0.4, a=0.85} end
			else return { r=0.2, g=0.15, b=0.4, a=0.85} end
		else
			if wtxGadgets.RaidFrames1 then
			if wtxGadgets.RaidFrames1.colHealth and wtxGadgets.RaidFrames1.ovHealthColor then
				return {r=wtxGadgets.RaidFrames1.colHealth[1],g=wtxGadgets.RaidFrames1.colHealth[2],b=wtxGadgets.RaidFrames1.colHealth[3],a=wtxGadgets.RaidFrames1.colHealth[4]}
			else 
				return  { r=0.07, g=0.07, b=0.07, a=0.85} end
				
			else 
			return  { r=0.07, g=0.07, b=0.07, a=0.85} end	
		end	
	end
)

if WT.Unit.VirtualProperties["alertHealthColor2"] ~= nil then
	WT.Unit.VirtualProperties["alertHealthColor2"] = nil
end

WT.Unit.CreateVirtualProperty("alertHealthColor2", { "id", "cleansable", "buffAlert" },
	function(unit)
		if unit.offline then
			return {r=0.07,g=0.07,b=0.09, a=0.85}
		elseif unit.buffAlert then
			if wtxGadgets.RaidFrames1 then
			if wtxGadgets.RaidFrames1.AlertColor then
			return {r=wtxGadgets.RaidFrames1.AlertColor[1],g=wtxGadgets.RaidFrames1.AlertColor[2],b=wtxGadgets.RaidFrames1.AlertColor[3],a=wtxGadgets.RaidFrames1.AlertColor[4]}
			else return { r=0.5, g=0.5, b=0, a=0.85 } end
			else return { r=0.5, g=0.5, b=0, a=0.85 } end
		elseif unit.cleansable then
		if wtxGadgets.RaidFrames1 then
			if wtxGadgets.RaidFrames1.CleanseColor then
				return {r=wtxGadgets.RaidFrames1.CleanseColor[1],g=wtxGadgets.RaidFrames1.CleanseColor[2],b=wtxGadgets.RaidFrames1.CleanseColor[3],a=wtxGadgets.RaidFrames1.CleanseColor[4]}
			else return { r=0.2, g=0.15, b=0.4, a=0.85 } end
			else return { r=0.2, g=0.15, b=0.4, a=0.85 } end
			else
			if wtxGadgets.RaidFrames1 then
			if wtxGadgets.RaidFrames1.colHealth and wtxGadgets.RaidFrames1.ovHealthColor then
				return {r=wtxGadgets.RaidFrames1.colHealth[1],g=wtxGadgets.RaidFrames1.colHealth[2],b=wtxGadgets.RaidFrames1.colHealth[3],a=wtxGadgets.RaidFrames1.colHealth[4]}
			else 
				return  {r=0.22,g=0.55,b=0.06, a=0.85}  end
			else 
			return  {r=0.22,g=0.55,b=0.06, a=0.85}  end	
		end
	end
)

local buffID = ""
local buffUnit = ""
if not wtxOptions.buffsAlertlist then wtxOptions.buffsAlertlist = {} end

function GJK.Event_Buff_Add(u,t)
	for k,v in pairs(Inspect.Buff.Detail(u,t)) do
		if (GJK.AbilityNames[v.name] or wtxOptions.buffsAlertlist[v.name])and WT.Units[u] then
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