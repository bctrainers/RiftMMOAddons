--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Icewatch (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT=Library.Translate

-- wtFPSGadget creates a really simple "HPS" gadget for displaying Live Heal Per Second

local gadgetIndex = 0
local dpsGadgets = {}

local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtHPS"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(52)
	wrapper:SetBackgroundColor(0,0,0,0.4)

	local dpsHeading = UI.CreateFrame("Text", WT.UniqueName("wtHPS"), wrapper)
	dpsHeading:SetText("LIVE HPS")
	dpsHeading:SetFontSize(10)

	local dpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtHPS"), wrapper)
	dpsFrame:SetText("")
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
		:Label("This gadget displays a live measure of the player's HPS")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("HPS",
	{
		name="HPS:Live",
		description="Displays Live HPS",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtDPS.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})


local dmgAccum = 0
local healAccum = 0
local runningSeconds = 10
local runningCursor = 1
local runningDamage = {}
local runningHeal = {}
local lastSecond = math.floor(Inspect.Time.Frame())
for i = 1,runningSeconds do runningDamage[i] = 0 end
for i = 1,runningSeconds do runningHeal[i] = 0 end

local function OnTick(hEvent)
	local currSecond = math.floor(Inspect.Time.Frame())
	if currSecond ~= lastSecond then
		runningDamage[runningCursor] = dmgAccum
		runningHeal[runningCursor] = healAccum
		dmgAccum = 0
		healAccum = 0
		runningCursor = runningCursor + 1
		if runningCursor > runningSeconds then runningCursor = 1 end
		local total = 0
		local totalHeal = 0
		for i = 1, runningSeconds do
			total = total + runningDamage[i]
			totalHeal = totalHeal + runningHeal[i]
		end
		local dps = math.floor((total / runningSeconds) + 0.5)
		local hps = math.floor((totalHeal / runningSeconds) + 0.5)
		for idx, frame in ipairs(dpsGadgets) do
			frame:SetText(tostring(dps))
			frame:SetText(tostring(hps))
		end
		lastSecond = currSecond
	end
end


local function OnDamage(hEvent, info)

	if not info.damage then return end
	
	if info.caster == WT.Player.id then
		dmgAccum = dmgAccum + info.damage
	else
		local playerPet = Inspect.Unit.Lookup("player.pet")
		if playerPet and info.caster == playerPet then
			dmgAccum = dmgAccum + info.damage
		end
	end
	
end

local function OnHeal(hEvent, info)

	if not info.heal then return end

	if info.caster == WT.Player.id then
		healAccum = healAccum + info.heal
	else
		local playerPet = Inspect.Unit.Lookup("player.pet")
		if playerPet and info.caster == playerPet then
			healAccum = healAccum + info.heal
		end
	end
	
end

Command.Event.Attach(Event.System.Update.Begin, OnTick, "OnTick")
Command.Event.Attach(Event.Combat.Damage, OnDamage, "OnDamage")
Command.Event.Attach(Event.Combat.Heal, OnHeal, "OnHeal")
