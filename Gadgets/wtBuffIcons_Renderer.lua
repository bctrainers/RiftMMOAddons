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

local buffIcons = {}
local started = false
local needsRefresh = {}

local exampleBuff = "Data/\\UI\\ability_icons\\discombobulate2a.dds"

-- BEGIN BUFFSET INTERFACE IMPLEMENTATION --

local buffSort = 99999999

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
	if not buff.sequence then
		-- buff.sequence = string.format("%08i", buffSort) .. buff.id:sub(10,17)
		buff.sequence = buff.id:sub(10,17)
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
	buffSort = buffSort - 1
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

-- Update a icon, given a buff detail structure
local function UpdateIcon(gadget, icon, buff)
	icon:SetVisible(true)
	icon.buffId = buff.id
	icon.buff = buff
	icon.icon:SetTexture("Rift", buff.icon)

	local txtStack = ""	
	if (buff.stack and buff.stack > 1) then
 		txtStack = tostring(buff.stack) or ""
	end
	if icon.textStack:GetText() ~= txtStack then 
		icon.textStack:SetText(txtStack)
	end
	
	icon.textTime:SetText(buff.timerText or "")
	if buff.debuff then
		icon:SetBackgroundColor(unpack(gadget.config.debuffBackground))	
		icon.textTime:SetFontColor(unpack(gadget.config.debuffFontColour))
		icon.border:SetBackgroundColor(unpack(gadget.config.debuffBorderColour))				
	else
		icon:SetBackgroundColor(unpack(gadget.config.buffBackground))	
		icon.textTime:SetFontColor(unpack(gadget.config.buffFontColour))
		icon.border:SetBackgroundColor(unpack(gadget.config.buffBorderColour))
	end
	
	icon.textTime:SetVisible(WT.Utility.ToBoolean(gadget.config.showTimer))
	icon.textStack:SetVisible(WT.Utility.ToBoolean(gadget.config.showStack))
end				
data.UpdateIcon = UpdateIcon

-- Clear (hide) a icon
local function ClearIcon(icon)
	if icon then
		icon:SetVisible(false)
		icon.buffId = false
		icon.buff = nil
	end
end

-- Refresh a gadget, recalculating the allocation of buffs to icons
local function Refresh(gadget)
	-- we can now rely on gadget.BuffData as populated by the Gadgets Framework to fill the panel
	-- start by sorting into ascending order of time remaining...
	
	local currTime = Inspect.Time.Frame()
	local configuration = gadget.config
	local splitDebuffs = configuration.splitDebuffs

	-- Make sure there are at least 2 rows before we try to split
	if configuration.rows == 1 then splitDebuffs = false end

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
			if gadget.config.sortByTime then
				table.insert(sortList, buff.remaining)
			else
				table.insert(sortList, buff.sequence) -- begin or -999999)
			end
		else
			local timeBuffBecomesVisible = currTime + (buff.remaining - seconds)
			if (not gadget.forceRefreshTime) or (gadget.forceRefreshTime > timeBuffBecomesVisible) then
				gadget.forceRefreshTime = timeBuffBecomesVisible
			end  
		end

	end
	table.sort(sortList)
	
	-- sortList contains an entry for every buff's remaining time, in ascending order of remaining time
	-- we can now use this list to assign a buff to each icon slot in the gadget by matching the remaining time
	local masterList = {{},{},{},{},{},{}}
	local buffList = {}
	for k,v in pairs(gadget.buffs) do buffList[k] = v end
	for idx = 1, #sortList do
		for buffId, buff in pairs(buffList) do
			if gadget.config.sortByTime then
				if buff.remaining == sortList[idx] then
					table.insert(masterList[buff.displayPriority], buff)
					buffList[buffId] = nil
					break
				end
			else
				if buff.sequence == sortList[idx] then
					table.insert(masterList[buff.displayPriority], buff)
					buffList[buffId] = nil
					break
				end
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
	
	-- Split the sortlist into buffs and debuffs if user has chosen to split
	-- Otherwise, leave everything sat in the buffs list
	
	local lstBuffs = {}
	local lstDebuffs = {}
	
	for idx,buff in ipairs(sortList) do
		if splitDebuffs and buff.debuff then
			table.insert(lstDebuffs, buff)
		else
			table.insert(lstBuffs, buff)
		end
	end
	
	local buffRows = math.ceil(#lstBuffs / configuration.cols)
	local debuffRows = math.ceil(#lstDebuffs / configuration.cols)
	
	-- Throw away whatever we have the most of until we no longer have too many rows
	while (buffRows + debuffRows) > configuration.rows do
		if #lstBuffs > #lstDebuffs then
			lstBuffs[#lstBuffs] = nil
		else
			lstDebuffs[#lstDebuffs] = nil
		end
		buffRows = math.ceil(#lstBuffs / configuration.cols)
		debuffRows = math.ceil(#lstDebuffs / configuration.cols)
	end
	
	-- table has a list of buffs in ascending order, reverse so that longer ones stay still
	if gadget.config.sortByTime then
		lstBuffs = ReverseTable(lstBuffs)
		lstDebuffs = ReverseTable(lstDebuffs)
	end
	
	-- now we need to assign each buff in the list to the correct icon slot. If growth direction is upwards,
	-- and the gadget is not full, we have to leave the right number of empty slots
	local totalSlots = configuration.rows * configuration.cols
	local emptySlots = totalSlots - #lstBuffs - #lstDebuffs 
	local firstIcon = 1

	-- Clear out all of the slots
	for idx = 1, totalSlots do
		ClearIcon(gadget.icons[idx])
	end

	
	-- Fill the populated slots
	for idx, buff in ipairs(lstBuffs) do
		UpdateIcon(gadget, gadget.icons[idx], lstBuffs[idx])
	end
	
	local offset = (buffRows * configuration.cols) 

	for idx, buff in ipairs(lstDebuffs) do
		UpdateIcon(gadget, gadget.icons[idx + offset], lstDebuffs[idx])
	end

end


local function OnResize(gadget, width, height)

	local config = gadget.config
	
end


local function UpdateTimers(gadget)

	local currTime = Inspect.Time.Frame()
	local configuration = gadget.config

	local pulse = (currTime % 2.0) * math.pi
	local pulseAlpha = (math.sin(pulse) + 1.0) / 2.0
	
	for idx, icon in pairs(gadget.icons) do
		local buffId = icon.buffId
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
					remainingPercent = remainingReal / buff.duration
				elseif remaining > 7200 and remaining < 10800  then
					txt = "2h"
					remainingPercent = remainingReal / buff.duration	
				elseif remaining > 10800 and remaining < 14400  then
					txt = "3h"
					remainingPercent = remainingReal / buff.duration
				elseif remaining > 14400 and remaining < 18000  then
					txt = "4h"
					remainingPercent = remainingReal / buff.duration	
				elseif remaining > 18000 and remaining < 21600  then
					txt = "5h"
					remainingPercent = remainingReal / buff.duration					
				end
				
				if (gadget.config.enableFlashing) and (remainingReal > 0) and (remainingReal <= 5.0) then
					icon.icon:SetAlpha(pulseAlpha)
				else
					icon.icon:SetAlpha(1.0)
				end
				
			end
			if icon.textTime:GetText() ~= txt then 
				buff.timerText = txt
				icon.textTime:SetText(txt)
			end
			
			local stack = buff.stack or 0
			if stack > 1 then
				stack = tostring(stack)
			else
				stack = ""
			end
			if icon.textStack:GetText() ~= stack then
				icon.textStack:SetText(stack)
			end
			
			buff.remaining = remaining
			buff.remainingPercent = remainingPercent
			--icon.fill:SetPoint("RIGHT", icon.fillMeasure, buff.remainingPercent or 1.0, nil)
		end		
	end

end


local function LayoutIcon(icon, config)

	icon:SetWidth(config.iconSize + (config.borderWidth * 2) + config.paddingLeft + config.paddingRight)
	icon:SetHeight(config.iconSize + (config.borderWidth * 2) + config.paddingTop + config.paddingBottom)
	icon:SetBackgroundColor(unpack(config.buffBackground))
		
	icon.border:SetLayer(5)
	icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", config.paddingLeft, config.paddingTop)
	icon.border:SetWidth(config.iconSize + (config.borderWidth * 2))
	icon.border:SetHeight(config.iconSize + (config.borderWidth * 2))

	icon.icon:SetPoint("TOPLEFT", icon.border, "TOPLEFT", config.borderWidth, config.borderWidth)
	icon.icon:SetWidth(config.iconSize)
	icon.icon:SetHeight(config.iconSize)
	icon.icon:SetLayer(10)
	icon.icon:SetTexture("Rift", exampleBuff)
	
	config.timerAnchor = config.timerAnchor or "TOPCENTER"
	config.stackAnchor = config.stackAnchor or "TOPCENTER"
	
	icon.textTime:SetPoint(config.timerAnchor, icon, config.timerAnchor, config.timerX or 0, config.timerY or 0)
	icon.textTime:SetFontSize(config.timerFontSize or 10)
	icon.textTime:SetLayer(20)

	icon.textStack:SetPoint(config.stackAnchor, icon, config.stackAnchor, config.stackX or 0, config.stackY or 0)
	icon.textStack:SetFontSize(config.stackFontSize or 10)
	icon.textStack:SetLayer(20)

	if icon.ghost then
		icon.ghost:SetBackgroundColor(0,0,0,0.4)
		icon.ghost:SetAllPoints(icon)
	end

end


local function SetupIconMouseHandlers(icon, gadget)

	local config = gadget.config

	icon.Event.MouseIn = 
		function()
			if config.tooltips then
				data.ShowBuffTooltip(gadget.UnitSpec, icon.buffId)
			end
		end

	icon.Event.MouseOut = 
		function()
			data.HideBuffTooltip(icon.buffId)
		end
	
	icon.Event.RightDown =
		function()
			-- only try if it's the player we're looking at
			if (config.cancel and (WT.Player.id == gadget.UnitId)) then
				if icon.buff and icon.buff.name then
					Command.Buff.Cancel(icon.buffId)
					if not data.playerCancelled then
						data.playerCancelled = {}
					end
					if icon.buff.type then 
						if not data.playerCancelled[icon.buff.type] then
							data.playerCancelled[icon.buff.type] = icon.buff.name
						end
					end					
				end
			end
		end
		
end


local function ConstructIcon(gadget, isPreview)

	local icon = UI.CreateFrame("Frame", "iconBackground", gadget)
	icon.border = UI.CreateFrame("Frame", "iconBorder", icon)
	icon.icon = UI.CreateFrame("Texture", "iconIcon", icon)
	icon.textStack = UI.CreateFrame("Text", "iconText", icon)
	icon.textTime = UI.CreateFrame("Text", "iconTextTime", icon)
	
	icon.textStack:SetEffectGlow({ strength = 3 })
	icon.textTime:SetEffectGlow({ strength = 3 })
	
	if gadget.ghosts then
		icon.ghost = UI.CreateFrame("Frame", "ghost", gadget.ghosts)
	end
	icon.icon:SetLayer(5)

	LayoutIcon(icon, gadget.config)
	if not isPreview then
		SetupIconMouseHandlers(icon, gadget)
	end

	return icon
end


-- Make the construction functions available to other chunks
data.ConstructIcon = ConstructIcon
data.LayoutIcon = LayoutIcon


function WT.Gadget.ConfigureBuffIcons(configuration)

	-- StartUp the gadget the first time it's needed
	if not started then data.wtBuffIcons_StartUp() end

	local gadgetId = configuration.id
	local gadget = buffIcons[gadgetId]
	
	if not gadget then
		gadget = WT.UnitFrame:Create(configuration.unitSpec)
		gadget.buffs = {}
		gadget.buffsPending = {}
		gadget.id = configuration.id
		
		buffIcons[gadgetId] = gadget

		gadget.icons = {}
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
		
	local slotHeight = configuration.iconSize + (configuration.borderWidth * 2) + configuration.paddingTop + configuration.paddingBottom 
	local slotWidth = configuration.iconSize + (configuration.borderWidth * 2) + configuration.paddingLeft + configuration.paddingRight
	local totalSlotHeight = configuration.rows * slotHeight
	local totalSlotWidth = configuration.cols * slotWidth
	local totalMarginHeight = (configuration.rows - 1) * configuration.marginVertical
	local totalMarginWidth = (configuration.cols - 1) * configuration.marginHorizontal
	 
	local gadgetHeight = totalSlotHeight + totalMarginHeight 
	local gadgetWidth = totalSlotWidth + totalMarginWidth 

	local nextElementOffset = 0
	
	-- Ensure there are enough icon elements available to display the max number of icons
	while #gadget.icons < (configuration.rows * configuration.cols) do	
		table.insert(gadget.icons, ConstructIcon(gadget))		
	end
	
	-- Hide all icons and set their position (including any extra icons that are no longer needed)
	
	local col = 0
	local row = 0
	local idx = 0
	 
	for idx, icon in ipairs(gadget.icons) do
	
		icon:SetVisible(false)
		LayoutIcon(icon, gadget.config)
		
		local tcol = col
		local trow = row 
		
		if gadget.config.fillFrom == "TOPRIGHT" then
			tcol = gadget.config.cols - col - 1
		elseif gadget.config.fillFrom == "BOTTOMLEFT" then
			trow = gadget.config.rows - row - 1
		elseif gadget.config.fillFrom == "BOTTOMRIGHT" then
			tcol = gadget.config.cols - col - 1
			trow = gadget.config.rows - row - 1
		end
		
		icon:SetPoint("TOPLEFT", gadget, "TOPLEFT", (tcol * (slotWidth + configuration.marginHorizontal)), (trow * (slotHeight + configuration.marginVertical)))
		icon.textStack:SetText("")
		icon.textTime:SetText("")
		
		if idx <= (configuration.rows * configuration.cols)  then
			icon.ghost:SetVisible(true)
		else
			icon.ghost:SetVisible(false)
		end
		
		col = col + 1
		if col >= configuration.cols then
			col = 0
			row = row + 1
		end
		idx = idx + 1
		
	end
	
	gadget:SetWidth(gadgetWidth)
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
	
	-- OnResize(gadget, configuration.width or 200, gadgetHeight)

	return gadget -- , { resizable = { 170, (configuration.maxIcons * 10) + ((configuration.maxIcons - 1) * configuration.iconSpacing), 800, 800 } }
	
end


local function OnUpdateBegin(hEvent)
	
	local currTime = Inspect.Time.Frame()
	
	for gadgetId, gadget in pairs(buffIcons) do
		if needsRefresh[gadgetId] or (gadget.forceRefreshTime and (gadget.forceRefreshTime <= currTime)) then
			Refresh(gadget)
		else
			UpdateTimers(gadget)
		end
	end
	needsRefresh = {}
	
end


local function OnUnlocked()
	for gadgetId, gadget in pairs(buffIcons) do
		gadget.ghosts:SetVisible(true)
	end
end

local function OnLocked()
	for gadgetId, gadget in pairs(buffIcons) do
		gadget.ghosts:SetVisible(false)
	end
end

-- This is called when the first gadget is created in order to defer event
-- registration until it's needed
function data.wtBuffIcons_StartUp()
	-- Register for event handlers
	Command.Event.Attach(Event.System.Update.Begin, OnUpdateBegin, "UpdateBegin")
	table.insert(WT.Event.GadgetsUnlocked, { OnUnlocked, AddonId, "BuffIcons_OnUnlocked" })
	table.insert(WT.Event.GadgetsLocked, { OnLocked, AddonId, "BuffIcons_OnLocked" })
	started = true
end

