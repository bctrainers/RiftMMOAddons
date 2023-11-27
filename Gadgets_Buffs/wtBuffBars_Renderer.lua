--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.1.3
      Project Date (UTC)  : 2012-08-07T01:23:40Z
      File Modified (UTC) : 2012-08-07T01:23:40Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local buffBars = {}
local started = false
local needsRefresh = {}

-- BEGIN BUFFSET INTERFACE IMPLEMENTATION --

local BuffSet_CanAccept = data.CheckBuffFilter

local function BuffSet_Add(gadget, buff)
	if gadget.config.usePriority then
		if buff.debuff then
			if buff.caster == WT.Player.id then
				buff.displayPriority = gadget.config.myDebuffPriority
			elseif buff.caster == gadget.UnitID then
				buff.displayPriority = gadget.config.unitDebuffPriority
			else
				buff.displayPriority = gadget.config.otherDebuffPriority
			end
		else
			if buff.caster == WT.Player.id then
				buff.displayPriority = gadget.config.myBuffPriority
			elseif buff.caster == gadget.UnitID then
				buff.displayPriority = gadget.config.unitBuffPriority
			else
				buff.displayPriority = gadget.config.otherBuffPriority
			end
		end
	else
		buff.displayPriority = 1
	end
	gadget.buffs[buff.id] = buff
end

local function BuffSet_Remove(gadget, buff)
	gadget.buffs[buff.id] = nil
end

local function BuffSet_Update(gadget, buff)
	gadget.buffs[buff.id].stack = buff.stack
end

local function BuffSet_Done(gadget)
	needsRefresh[gadget.id] = true
end

-- END BUFFSET INTERFACE IMPLEMENTATION --

-- Calculate the remaining time on a buff, and populate additional values in the detail structure
local function CalculateRemaining(buff)
	local remaining = 999999
	local remainingPercent = 1.0
	local txt = ""
	local currTime = Inspect.Time.Frame()
	if buff.duration then
		local elapsed = currTime - buff.begin
		remaining = buff.duration - elapsed
		if remaining <= 0 then
			txt = "" 
			remaining = 0
			remainingPercent = 0
		elseif remaining < 60 then
			txt = math.floor(remaining) .. "s"
			remainingPercent = remaining / buff.duration
		elseif remaining < 3600 then
			txt = math.floor(remaining / 60) .. "m"
			remainingPercent = remaining / buff.duration
		elseif remaining > 3600 and remaining < 7200  then
			txt = "1h"
			remainingPercent = remaining / buff.duration
		elseif remaining > 7200 and remaining < 10800  then
			txt = "2h"
			remainingPercent = remaining / buff.duration	
		elseif remaining > 10800 and remaining < 14400  then
			txt = "3h"
			remainingPercent = remaining / buff.duration
		elseif remaining > 14400 and remaining < 18000  then
			txt = "4h"
			remainingPercent = remaining / buff.duration
		elseif remaining > 18000 and remaining < 21600  then
			txt = "5h"
			remainingPercent = remaining / buff.duration			
		end
	end
	buff.timerText = txt
	buff.remaining = remaining
	buff.remainingPercent = remainingPercent		
end

-- Reverse the sequence of an indexed table
local function ReverseTable(tab)
    local size = #tab
    local newTable = {}
    for i,v in ipairs(tab) do
        newTable[(size-i)+1] = v
    end
    return newTable
end

-- Update a bar, given a buff detail structure
local function UpdateBar(gadget, bar, buff)
	bar:SetVisible(true)
	bar.buffId = buff.id
	bar.buff = buff
	bar.icon:SetTexture("Rift", buff.icon)
	
	local bName = buff.name or ""
	
	if (buff.stack and buff.stack > 1) then
		bName = "[" .. tostring(buff.stack) .. "] " .. bName
	end
	
	bar.text:SetText(bName)
	bar.textTime:SetText(buff.timerText or "")
	bar.fill:SetPoint("RIGHT", bar.fillMeasure, buff.remainingPercent or 1.0, nil)
	bar:SetBackgroundColor(unpack(gadget.config.buffBackground))	
	if buff.debuff then
		bar.text:SetFontColor(unpack(gadget.config.debuffFontColour))
		bar.textTime:SetFontColor(unpack(gadget.config.debuffFontColour))
		bar.fill:SetBackgroundColor(unpack(gadget.config.debuffColour))				
	else
		bar.text:SetFontColor(unpack(gadget.config.buffFontColour))
		bar.textTime:SetFontColor(unpack(gadget.config.buffFontColour))
		bar.fill:SetBackgroundColor(unpack(gadget.config.buffColour))
	end
end				

-- Clear (hide) a bar
local function ClearBar(bar)
	if bar then
		bar:SetVisible(false)
		bar.buffId = false
		bar.buff = nil
	end
end

-- Refresh a gadget, recalculating the allocation of buffs to bars
local function Refresh(gadget)
	-- we can now rely on gadget.BuffData as populated by the Gadgets Framework to fill the panel
	-- start by sorting into ascending order of time remaining...
	
	local currTime = Inspect.Time.Frame()
	local configuration = gadget.config

	local seconds = 0 

	-- Do we have a time limit for buff display?
	if gadget.config.limitRemaining then
		seconds = tonumber(gadget.config.limitRemainingSeconds) or 0
		if seconds > 0 then 
			seconds = seconds + 0.99
		end 
	end  

	-- One-time iteration to calculate the remaining time of each buff, and add all buffs to be shown to the sort list
	local sortList = {}
	for buffId, buff in pairs(gadget.buffs) do
		CalculateRemaining(buff)
		if seconds == 0 or (buff.remaining <= seconds) then
			table.insert(sortList, buff.remaining)
		else
			local timeBuffBecomesVisible = currTime + (buff.remaining - seconds)
			if (not gadget.forceRefreshTime) or (gadget.forceRefreshTime > timeBuffBecomesVisible) then
				gadget.forceRefreshTime = timeBuffBecomesVisible
			end  
		end
	end
	table.sort(sortList)
	
	-- sortList contains an entry for every buff's remaining time, in ascending order of remaining time
	-- we can now use this list to assign a buff to each bar slot in the gadget by matching the remaining time
	local masterList = {{},{},{},{},{},{}}
	local buffList = {}
	for k,v in pairs(gadget.buffs) do buffList[k] = v end
	for idk = 1, #sortList do
		for buffId, buff in pairs(buffList) do
			if buff.remaining == sortList[idk] then
				table.insert(masterList[buff.displayPriority], buff)
				buffList[buffId] = nil
				break
			end
		end
	end
	
	sortList = {}
	for subListIndex = 1, 6 do
		subList = masterList[subListIndex]
		if subList then
			for idk = 1, #subList do
				table.insert(sortList, subList[idk])
				
				if #sortList == configuration.maxBars then break end
			end
			
			if #sortList == configuration.maxBars then break end
		end
	end
	
	-- table has a list of buffs in ascending order, reverse if we're sorting in descending order
	-- note this is done at this point and not sooner, so that short duration buffs are still allocated bar 
	-- slots before long duration buffs, even if sorting descending
	if gadget.config.sortDescending then
		sortList = ReverseTable(sortList)
	end
	
	-- now we need to assign each buff in the list to the correct bar slot. If growth direction is upwards,
	-- and the gadget is not full, we have to leave the right number of empty slots
	local totalSlots = configuration.maxBars
	local emptySlots = totalSlots - #sortList
	local firstBar = 1

	-- Clear out the empty slots
	if emptySlots > 0 then
		if configuration.grow == "up" then
			firstBar = firstBar + emptySlots
			for idx = 1, emptySlots do
				ClearBar(gadget.bars[idx])
			end
		else
			for idx = totalSlots - emptySlots, totalSlots do
				ClearBar(gadget.bars[idx])
			end		
		end
	end
	
	-- Fill the populated slots
	for idx, buff in ipairs(sortList) do
		UpdateBar(gadget, gadget.bars[(firstBar + idx) - 1], sortList[idx])
	end

end


local function OnResize(gadget, width, height)

	local config = gadget.config
	
	local barSpacing = config.barSpacing

	-- Work out the most appropriate bar height based on the new size, and apply it
	local totalSpacing = (config.maxBars - 1) * barSpacing
	local newBarHeight = math.ceil((height - totalSpacing) / config.maxBars)
	
	config.barHeight = newBarHeight
	
	local fontSize = math.ceil(newBarHeight * 0.75)
	
	-- Adjust the bar heights
	for idx, bar in ipairs(gadget.bars) do 
		bar:SetHeight(newBarHeight)
		bar.fill:SetHeight(newBarHeight)
		bar.icon:SetHeight(newBarHeight)
		bar.icon:SetWidth(newBarHeight)
		bar.text:SetFontSize(fontSize)
		bar.textTime:SetFontSize(fontSize)
		bar:SetPoint("TOPLEFT", gadget, "TOPLEFT", 0, (idx - 1) * (newBarHeight + config.barSpacing))
	end
	
	gadget.heading:SetFontSize(fontSize)
	
	local gadgetHeight = (config.maxBars * newBarHeight) + totalSpacing
	gadget:SetHeight(gadgetHeight)
	
	config.height = gadgetHeight
	
end


local function UpdateTimers(gadget)

	local currTime = Inspect.Time.Frame()
	local configuration = gadget.config
	
	for idx, bar in pairs(gadget.bars) do
		local buffId = bar.buffId
		if buffId and gadget.buffs[buffId] then
			local buff = gadget.buffs[buffId]
			local remaining = 999999
			local remainingPercent = 1.0
			local txt = ""
			if buff.duration then
				local elapsed = currTime - buff.begin
				remaining = math.floor(buff.duration - elapsed)
				local remainingReal = buff.duration - elapsed
				if remainingReal <= 0 then
					txt = "" 
					remaining = 0
					remainingPercent = 0
				elseif remaining < 60 then
					txt = remaining .. "s"
					remainingPercent = remainingReal / buff.duration
				elseif remaining < 3600 then
					txt = math.floor(remaining / 60) .. "m"
					remainingPercent = remainingReal / buff.duration
				elseif remaining > 3600 and remaining < 7200  then
					txt = "1h"
					remainingPercent = remaining / buff.duration
				elseif remaining > 7200 and remaining < 10800  then
					txt = "2h"
					remainingPercent = remaining / buff.duration	
				elseif remaining > 10800 and remaining < 14400  then
					txt = "3h"
					remainingPercent = remaining / buff.duration
				elseif remaining > 14400 and remaining < 18000  then
					txt = "4h"
					remainingPercent = remaining / buff.duration		
				elseif remaining > 18000 and remaining < 21600  then
					txt = "5h"
					remainingPercent = remaining / buff.duration						
				end
		
			end
			if bar.textTime:GetText() ~= txt then 
				buff.timerText = txt
				bar.textTime:SetText(txt)
			end
			buff.remaining = remaining
			buff.remainingPercent = remainingPercent
			bar.fill:SetPoint("RIGHT", bar.fillMeasure, buff.remainingPercent or 1.0, nil)
		end		
	end

end


local function ConstructBar(gadget)

	local bar = UI.CreateFrame("Frame", "barBackground", gadget)
	
	if gadget.config.border then
		bar.border = UI.CreateFrame("Frame", "barBorder", bar)
	
		bar.border.top = UI.CreateFrame("Frame", "TopBorder", bar)
		bar.border.top:SetBackgroundColor(0,0,0,1)
		bar.border.top:SetLayer(1)
		bar.border.top:ClearAll()
		bar.border.top:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", -1, 0)
		bar.border.top:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 1, 0)
		bar.border.top:SetHeight(1)
				  
		bar.border.bottom = UI.CreateFrame("Frame", "BottomBorder", bar)
		bar.border.bottom:SetBackgroundColor(0,0,0,1)
		bar.border.bottom:SetLayer(1)
		bar.border.bottom:ClearAll()
		bar.border.bottom:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", -1, 0)
		bar.border.bottom:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT",1, 0)
		bar.border.bottom:SetHeight(1)
				  
		bar.border.left = UI.CreateFrame("Frame", "LeftBorder", bar)
		bar.border.left:SetBackgroundColor(0,0,0,1)
		bar.border.left:SetLayer(1)
		bar.border.left:ClearAll()
		bar.border.left:SetPoint("TOPRIGHT", bar, "TOPLEFT", 0, -1)
		bar.border.left:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", 0, 1)
		bar.border.left:SetWidth(1)
				  
		bar.border.right = UI.CreateFrame("Frame", "RightBorder", bar)
		bar.border.right:SetBackgroundColor(0,0,0,1)
		bar.border.right:SetLayer(1)
		bar.border.right:ClearAll()
		bar.border.right:SetPoint("TOPLEFT", bar, "TOPRIGHT", 0, -1)
		bar.border.right:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 0, 1)
		bar.border.right:SetWidth(1)
	end
	
	bar.fillMeasure = UI.CreateFrame("Frame", "barFillBackground", bar)
	bar.fillMeasure:SetPoint("TOPLEFT", bar, "TOPLEFT", gadget.config.barHeight, 0)
	bar.fillMeasure:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
	bar.fillMeasure:SetVisible(false) -- used to measure the fill itself, never actually visible

	bar.fill = UI.CreateFrame("Frame", "barFill", bar)
	bar.fill:SetPoint("TOPLEFT", bar, "TOPLEFT")
	
	bar.icon = UI.CreateFrame("Texture", "barIcon", bar)
	bar.icon:SetPoint("TOPLEFT", bar, "TOPLEFT")
	bar.icon:SetLayer(10)
	
	bar.text = UI.CreateFrame("Text", "barText", bar)
	bar.text:SetPoint("CENTERLEFT", bar.icon, "CENTERRIGHT", 0, 0)
	bar.text:SetLayer(10)

	bar.textTime = UI.CreateFrame("Text", "barTextTime", bar)
	bar.textTime:SetPoint("CENTERRIGHT", bar, "CENTERRIGHT", -4, 0)
	bar.textTime:SetLayer(10)

	bar.text:SetPoint("RIGHT", bar.textTime, "LEFT", -8, nil)
	
	bar.ghost = UI.CreateFrame("Frame", "ghost", gadget.ghosts)
	bar.ghost:SetBackgroundColor(0,0,0,0.4)
	bar.ghost:SetAllPoints(bar)
	
	if gadget.config.outline then
		bar.text:SetEffectGlow({ strength = 3 }) -- text outline
		bar.textTime:SetEffectGlow({ strength = 3 }) -- text outline
	end
	
	bar.Event.MouseIn = 
		function()
			if gadget.config.tooltips then
				data.ShowBuffTooltip(gadget.UnitSpec, bar.buffId)
			end
		end

	bar.Event.MouseOut = 
		function()
			data.HideBuffTooltip(bar.buffId)
		end
	
	bar.Event.RightDown =
		function()
			-- only try if it's the player we're looking at
			if (gadget.config.cancel and (WT.Player.id == gadget.UnitId)) then
				if bar.buff and bar.buff.name then
					Command.Buff.Cancel(bar.buffId)
					if not data.playerCancelled then
						data.playerCancelled = {}
					end
					if not data.playerCancelled[bar.buff.type] then
						data.playerCancelled[bar.buff.type] = bar.buff.name
					end
					
				end
			end
		end
		
	return bar
end


function WT.Gadget.ConfigureBuffBars(configuration)

	-- StartUp the gadget the first time it's needed
	if not started then data.wtBuffBars_StartUp() end

	local gadgetId = configuration.id
	local gadget = buffBars[gadgetId]
	
	if not gadget then
		gadget = WT.UnitFrame:Create(configuration.unitSpec)
		gadget.buffs = {}
		gadget.buffsPending = {}
		gadget.id = configuration.id
		
		buffBars[gadgetId] = gadget

		gadget.heading = UI.CreateFrame("Text", "txtHeading", gadget)
		gadget.heading:SetPoint("RIGHT", gadget, "RIGHT")
		gadget.heading:SetVisible(false)

		gadget.bars = {}
		gadget.ghosts = UI.CreateFrame("Frame", "ghosts", gadget)
		gadget.ghosts:SetLayer(-10)
		gadget.ghosts:SetVisible(false)

		-- Register as a buff handler
		gadget.CanAccept = BuffSet_CanAccept
		gadget.Add = BuffSet_Add
		gadget.Remove= BuffSet_Remove
		gadget.Update = BuffSet_Update
		gadget.Done = BuffSet_Done
		gadget:RegisterBuffSet(gadget)
		
		gadget.OnResize = OnResize
	else
		-- Clear out any existing bindings
		gadget.Bindings = {}
		-- Set the unit tracker to the correct unit
		gadget:TrackUnit(configuration.unitSpec)
	end
		
	gadget.config = configuration
		
	configuration.barHeight = configuration.barHeight or 14 -- default the barHeight 
	local gadgetHeight = (configuration.maxBars * configuration.barHeight) + ((configuration.maxBars - 1) * configuration.barSpacing) 

	local nextElementOffset = 0
	
	-- Configure: Heading
	if configuration.heading and (configuration.heading ~= "") then
		gadget:CreateTokenBinding(configuration.heading, gadget.heading, gadget.heading.SetText, "") 
		--gadget.heading:SetText(configuration.heading)
		gadget.heading:SetFontColor(unpack(configuration.headingFontColour))
		gadget.heading:ClearAll()
		if configuration.grow == "up" then
			gadget.heading:SetPoint("TOPLEFT", gadget, "BOTTOMLEFT")
		else
			gadget.heading:SetPoint("BOTTOMLEFT", gadget, "TOPLEFT")
		end
		gadget.heading:SetVisible(true)
	else
		gadget.heading:SetVisible(false)
	end
	
	-- Ensure there are enough bar elements available to display the max number of bars
	while #gadget.bars < configuration.maxBars do	
		table.insert(gadget.bars, ConstructBar(gadget))		
	end
	
	-- Hide all bars and set their position (including any extra bars that are no longer needed) 
	for idx, bar in ipairs(gadget.bars) do
		bar:SetVisible(false)		
		bar:ClearAll()
		bar:SetPoint("TOPLEFT", gadget, "TOPLEFT", 0, nextElementOffset)
		bar:SetPoint("RIGHT", gadget, "RIGHT")
		bar:SetHeight(configuration.barHeight)
		bar.fill:SetPoint("TOPLEFT", bar, "TOPLEFT", configuration.barHeight, 0)
		bar.fill:SetHeight(configuration.barHeight)
		bar.icon:SetHeight(configuration.barHeight)
		bar.icon:SetWidth(configuration.barHeight)
		bar.text:SetText("")
		bar.textTime:SetText("")
		
		if idx <= configuration.maxBars then
			bar.ghost:SetVisible(true)
		else
			bar.ghost:SetVisible(false)
		end
		
		nextElementOffset = nextElementOffset + configuration.barHeight + configuration.barSpacing
	end
	
	gadget:SetWidth(configuration.width or 200)
	gadget:SetHeight(gadgetHeight)

	-- Setup any wildcard filters
	gadget.wildcards = {}
	for filter in pairs(configuration.filters) do
		if filter:find("%*") then
			local pattern = "^" .. filter:lower():gsub("%*", "%.%*")
			gadget.wildcards[pattern] = true
		end
	end
	
	needsRefresh[gadget.id] = true
	gadget:ReapplyBuffDelta()
	gadget:ApplyBindings()
	
	OnResize(gadget, configuration.width or 200, gadgetHeight)

	return gadget, { resizable = { 170, (configuration.maxBars * 10) + ((configuration.maxBars - 1) * configuration.barSpacing), 800, 800 } }
	
end


local function OnUpdateBegin(hEvent)
	
	local currTime = Inspect.Time.Frame()
	
	for gadgetId, gadget in pairs(buffBars) do
		if needsRefresh[gadgetId] or (gadget.forceRefreshTime and (gadget.forceRefreshTime <= currTime)) then
			Refresh(gadget)
		else
			UpdateTimers(gadget)
		end
	end
	needsRefresh = {}
	
end


local function OnUnlocked()
	for gadgetId, gadget in pairs(buffBars) do
		gadget.ghosts:SetVisible(true)
	end
end

local function OnLocked()
	for gadgetId, gadget in pairs(buffBars) do
		gadget.ghosts:SetVisible(false)
	end
end

-- This is called when the first gadget is created in order to defer event
-- registration until it's needed
function data.wtBuffBars_StartUp()
	-- Register for event handlers
	Command.Event.Attach(Event.System.Update.Begin, OnUpdateBegin, "UpdateBegin")
	table.insert(WT.Event.GadgetsUnlocked, { OnUnlocked, AddonId, "BuffBars_OnUnlocked" })
	table.insert(WT.Event.GadgetsLocked, { OnLocked, AddonId, "BuffBars_OnLocked" })
	started = true
end

