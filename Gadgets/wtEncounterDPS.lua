--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Icewatch (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT=Library.Translate

-- wtFPSGadget creates a really simple "FPS" gadget for displaying Frames Per Second

local gadgetIndex = 0
local dpsGadgets = {}

local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtFPS"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(52)
	wrapper:SetBackgroundColor(0,0,0,0.4)

	local dpsHeading = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	dpsHeading:SetText("ENCOUNTER DPS")
	dpsHeading:SetFontSize(10)

	local dpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	dpsFrame:SetText("0")
	dpsFrame:SetFontSize(24)
	dpsFrame.currText = ""

	dpsHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	dpsFrame:SetPoint("TOPCENTER", dpsHeading, "BOTTOMCENTER", 0, -5)

	table.insert(dpsGadgets, dpsFrame)
	return wrapper, { resizable={150, 52, 150, 70} }
	
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("This gadget displays a measure of the player's DPS in the current/last encounter")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("EncounterDPS",
	{
		name="DPS:Encounter",
		description="Displays Encounter DPS",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtDPS.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})


local lastDamageTime = 0
local encounterStart = 0
local damage = 0

local function OnDamage(hEvent, info)

	if not info.damage then return end

	local isPlayer = false

	if info.caster == WT.Player.id then
		isPlayer = true
	else
		local playerPet = Inspect.Unit.Lookup("player.pet")
		if playerPet and info.caster == playerPet then
			isPlayer = true
		end
	end

	if not isPlayer then return end

	local currTime = Inspect.Time.Frame()
	if (currTime - lastDamageTime) > 8.0 then
		-- new encounter
		damage = 0
		encounterStart = currTime
	end
	
	lastDamageTime = currTime
	damage = damage + info.damage  + (info.damageAbsorbed or 0)

	local encounterDuration = currTime - encounterStart
	if encounterDuration > 0 then
		local encounterDPS = math.floor((damage / encounterDuration) + 0.5)
		for idx, frame in ipairs(dpsGadgets) do
			frame:SetText(tostring(encounterDPS))
		end
	end

end

Command.Event.Attach(Event.Combat.Damage, OnDamage, "OnEncounterDamage")