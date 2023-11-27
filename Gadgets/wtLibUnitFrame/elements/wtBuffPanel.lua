--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Element.BuffPanel
	
		Provides a panel that can display buff icons. A panel is created with a configuration object that
		sets the panel up, including the number of rows/columns of buff icons to display, and the direction
		that the icons grow in (e.g. "right_up" means grow to the right, then up).
		
		Also includes a set of filters to determine which buffs this panel will accept. When adding a set of
		buffs to the panel, the filters are checked and only buffs that can be accepted are shown. Any buffs that
		were not displayed are returned to the client. This allows for multiple buff panels to be created, and
		a list of buffs passed to each panel in turn until the client either runs out of buffs or panels.
		
		In addition to the priority and buff/debuff built in filters, a list of buff names to reject can be passed.
		These buffs will always be rejected by the panel.
		
		Alternatively, a list of buff names to accept can be provided. This list overrides all other filters, and
		will only ever show the buffs in the list. Will possibly be used by the wtWardenFrame to show HoTs on the 
		unit.
--]]

local toc, data = ...
local AddonId = toc.identifier

local wtBuffPanel = WT.Element:Subclass("BuffPanel", "Frame")

local tooltipIcon = false

local function ShowTooltip(icon)
	if icon.buffId then
		tooltipIcon = icon
		Command.Tooltip(icon.unitSpec, icon.buffId)
	end
end

local function HideTooltip(icon)
	if tooltipIcon == icon then Command.Tooltip(nil) end
end

function wtBuffPanel:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	self.config = {}

	self.config.id = config.id
	
	--dump(config.acceptBuffs)
	--local x = {}
	if config.acceptBuffs then
	if not next(config.acceptBuffs) then config.acceptBuffs = nil end
	end
	if config.rejectBuffs then
	if not next(config.rejectBuffs) then config.rejectBuffs = nil end
	end
	self.config.acceptBuffs = config.acceptBuffs or nil -- table of buff names mapped to 'true'. If provided, only these buffs will ever be loaded, and all other filters are ignored
	self.config.rejectBuffs = config.rejectBuffs or nil -- table of buff names mapped to 'true'. If provided, these buffs will never be loaded

	self.config.rows = config.rows or 1;
	self.config.cols = config.cols or 5;
	self.config.iconSize = config.iconSize or 16;
	self.config.iconSpacingVertical = config.iconSpacingVertical or config.iconSpacing or 1;
	self.config.iconSpacingHorizontal = config.iconSpacingHorizontal or config.iconSpacing or 1;
	
	self.config.borderThickness = config.borderThickness or 1
	
	self.config.borderColor = config.borderColor or nil
	self.config.stackBackgroundColor = config.stackBackgroundColor or nil
	
	self.config.acceptLowPriorityBuffs = config.acceptLowPriorityBuffs or false;
	self.config.acceptMediumPriorityBuffs = config.acceptMediumPriorityBuffs or false;
	self.config.acceptHighPriorityBuffs = config.acceptHighPriorityBuffs or false;
	self.config.acceptCriticalPriorityBuffs = config.acceptCriticalPriorityBuffs or false;

	self.config.acceptLowPriorityDebuffs = config.acceptLowPriorityDebuffs or false;
	self.config.acceptMediumPriorityDebuffs = config.acceptMediumPriorityDebuffs or false;
	self.config.acceptHighPriorityDebuffs = config.acceptHighPriorityDebuffs or false;
	self.config.acceptCriticalPriorityDebuffs = config.acceptCriticalPriorityDebuffs or false;

	self.config.growthDirection = config.growthDirection or "right_up"

	self.config.auraType = config.auraType or ""

	self.width = (self.config.cols * self.config.iconSize) + (self.config.iconSpacingHorizontal * (self.config.cols - 1)) 
	self.height = (self.config.rows * self.config.iconSize) + (self.config.iconSpacingVertical * (self.config.rows - 1)) 
	self.maxIcons = self.config.cols * self.config.rows 
	self.currIcons = 0

	self.config.selfCast = config.selfCast or false

	self.config.timerSize = config.timerSize or 0
	self.config.timerOffsetX = config.timerOffsetX or 0
	self.config.timerOffsetY = config.timerOffsetY or 7 ------------------------------------------------------------------------------------------------------
	
	self.config.stackSize = config.stackSize or 0
	self.config.stackOffsetX = config.stackOffsetX or 0
	self.config.stackOffsetY = config.stackOffsetY or -3 -----------------------------------------------------------------------------------------------------------------------

	self.config.sweepOverlay = false -- WT.Utility.ToBoolean(config.sweepOverlay)

	self:SetWidth(self.width)
	self:SetHeight(self.height)

	-- For Testing ------------------------------
	 -- self:SetBackgroundColor(0,0,0,1)
	---------------------------------------------

	self.Icons = {}

	-- Pre-create buff icons on the assumption that non-visible textures have minimal overhead
	local row = 0
	local col = 0

	-- Determine the row/column of the first icon on the self
	if (self.config.growthDirection == "right_up") or (self.config.growthDirection == "up_right") then 
		row = self.config.rows - 1
		col = 0
	end
	if (self.config.growthDirection == "right_down") or (self.config.growthDirection == "down_right") then 
		row = 0
		col = 0
	end
	if (self.config.growthDirection == "left_up") or (self.config.growthDirection == "up_left") then 
		row = self.config.rows - 1
		col = self.config.cols - 1
	end
	if (self.config.growthDirection == "left_down") or (self.config.growthDirection == "down_left") then 
		row = 0
		col = self.config.cols - 1
	end
	
	local margin = self.config.borderThickness -- copy the thickness
	for idx = 1, self.maxIcons do
	
		local border = UI.CreateFrame("Frame", WT.UnitFrame.UniqueName(), self)
		border:SetWidth(self.config.iconSize)
		border:SetHeight(self.config.iconSize)
		border:SetLayer(10)
		border:SetVisible(false)

		local bgColor = self.config.borderColor
		if bgColor then			
			border:SetBackgroundColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 1.0)
		else
			border:SetBackgroundColor(0,0,0,1)
		end

		border:SetPoint("TOPLEFT", self, "TOPLEFT", (col * (self.config.iconSize + self.config.iconSpacingHorizontal)), (row * (self.config.iconSize + self.config.iconSpacingVertical)))
	
		local icon = UI.CreateFrame("Texture", WT.UnitFrame.UniqueName(), border)
		icon:SetWidth(self.config.iconSize - (margin*2))
		icon:SetHeight(self.config.iconSize - (margin*2))
		icon:SetLayer(20)
		icon:SetPoint("TOPLEFT", border, "TOPLEFT", margin, margin)
		icon.Row = row
		icon.Col = col
		icon.Border = border
		icon.unitSpec = unitFrame.UnitSpec

		-- Are timers required?
		if self.config.timerSize > 0 then
			icon.txtTimer = UI.CreateFrame("Text", WT.UnitFrame.UniqueName(), border)
			icon.txtTimer:SetLayer(25)
			icon.txtTimer:SetFontSize(self.config.timerSize)
			-------------------outline timer text--------------------------------------------------------------------------------------------------------------------
			 if config.outline then
		      icon.txtTimer:SetEffectGlow({ strength = 3 })
	          end
			-------------------------------------------------------------------------------------------------------------------
			-- Always place the timer text over the center of the icon, and use offsets to move it to where it needs to be in the template
			icon.txtTimer:SetPoint("CENTER", icon, "CENTER", self.config.timerOffsetX, self.config.timerOffsetY)
			
			if not WT.BuffTimers then WT.BuffTimers = {} end
			table.insert(WT.BuffTimers, icon)
		end

		-- Are stack counters required?
		if self.config.stackSize > 0 then			
			icon.txtStack = UI.CreateFrame("Text", WT.UnitFrame.UniqueName(), border)
			icon.txtStack:SetLayer(25)
			icon.txtStack:SetFontSize(self.config.stackSize)
	-----------------------outline stack size-------------------------------------------------------------------------------------------		
			icon.txtStack:SetFontColor(1,1,0,1)
			 if config.outline then
		      icon.txtStack:SetEffectGlow({ strength = 3 })
	          end
	------------------------------------------------------------------------------------------------------------------			  
			local bgColor = self.config.stackBackgroundColor
			if bgColor then			
				icon.txtStack:SetBackgroundColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 1.0)
			end
			-- Always place the timer text over the center of the icon, and use offsets to move it to where it needs to be in the template
			icon.txtStack:SetPoint("CENTER", icon, "CENTER", self.config.stackOffsetX, self.config.stackOffsetY)
		end

		-- Is a sweep overlay required - this could be very expensive in terms of CPU rendering time, as it will add a large ImageSet
		-- element to every single buff icon in the panel. Uses the internal 'forceParent' override when creating the element
		if self.config.sweepOverlay then
			icon.sweepElement = unitFrame:CreateElement({ 
					id = self.config.id .. "_sweep" .. idx, 
					type="ImageSet", 
					texAddon=AddonId, texFile="img/Sweep.png",
					alpha=0.8, 
					rows=10, cols=10, 
					layer=22,					
					width = self.config.iconSize - (margin*2), height = self.config.iconSize - (margin*2),
					 }, border)
			-- Manually set the position of the element
			icon.sweepElement:SetPoint("TOPLEFT", icon, "TOPLEFT")
			--icon.sweepElement:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
			if not WT.BuffSweeps then WT.BuffSweeps = {} end
			table.insert(WT.BuffSweeps, icon)
		end

		self.Icons[idx] = icon
	
		-- Determine next row/col in the list
		if (self.config.growthDirection == "right_up") then
			col = (col + 1) % self.config.cols
			if col == 0 then row = row - 1 end
		end
		if (self.config.growthDirection == "right_down") then
			col = (col + 1) % self.config.cols
			if col == 0 then row = row + 1 end
		end
		if (self.config.growthDirection == "left_up") then
			col = (col - 1) % self.config.cols
			if col == (self.config.cols - 1) then row = row - 1 end
		end
		if (self.config.growthDirection == "left_down") then
			col = (col - 1) % self.config.cols
			if col == (self.config.cols - 1) then row = row + 1 end
		end
		if (self.config.growthDirection == "up_right") then
			row = (row - 1) % self.config.rows
			if row == (self.config.rows - 1) then col = col + 1 end
		end
		if (self.config.growthDirection == "down_right") then
			row = (row + 1) % self.config.rows
			if row == 0 then col = col + 1 end
		end
		if (self.config.growthDirection == "up_left") then
			row = (row - 1) % self.config.rows
			if row == (self.config.rows - 1) then col = col - 1 end
		end
		if (self.config.growthDirection == "down_left") then
			row = (row + 1) % self.config.rows
			if row == 0 then col = col - 1 end
		end
		
		icon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
			ShowTooltip(icon)
		end, "Event.UI.Input.Mouse.Cursor.In")
		icon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
			HideTooltip(icon)
		end, "Event.UI.Input.Mouse.Cursor.Out")
		icon:SetMouseMasking("limited")
	end

	self.buffs = {}

	-- A BuffPanel provides the BuffSet interface
	unitFrame:RegisterBuffSet(self)
	
	if not unitFrame.buffIconMap then
		unitFrame.buffIconMap = {}
	end
	
	-- unitFrame:CreateBinding("id", self, self.Refresh, nil) 

end

-- Display the icon with index 'idx'
function wtBuffPanel:ShowIcon(idx, texture)
	WT.Log.Debug("BuffPanel: Show idx " .. tostring(idx) .. " = " .. texture)
	if (idx < 1) or (idx > self.maxIcons) then
		WT.Log.Warning("Attempt to show invalid icon index: " .. tostring(idx))
		return 
	end 
	self.Icons[idx]:SetTexture("Rift", texture)
	self.Icons[idx].Border:SetVisible(true)
end

function wtBuffPanel:HideIcon(idx)
	if (idx < 1) or (idx > self.maxIcons) then
		WT.Log.Warning("Attempt to hide invalid icon index: " .. tostring(idx))
		return 
	end 
	
	local buffId = self.Icons[idx].buffId
	--if buffId then self.UnitFrame.buffIconMap[buffId] = nil end
	
	self.Icons[idx].Border:SetVisible(false)
	self.Icons[idx].buffId = nil
	self.Icons[idx].buff = nil
end


-- This is a map of TYPE IDs that create buffs we want to track
local additionalHoTs = 
{
	["BFA6FB1BAE463D82B"] = "Link of Agony",
	["BFC515C3AB0F59096"] = "Link of Distress",
	["BFF27EA366EA0638D"] = "Link of Misery",
	["BFD2398235B465FED"] = "Link of Suffering",
}


-- Returns true if the panel can accept the buff based on the configuration options
function wtBuffPanel:CanAccept(buff)

	if self.currIcons >= self.maxIcons then return false end
	
	-- if we have a buff list, we only check against that list
	if self.config.acceptBuffs then
		return self.config.acceptBuffs[buff.name] or false
	end

	-- check the reject list
	if self.config.rejectBuffs and self.config.rejectBuffs[buff.name] then return false end

	if self.config.selfCast then
		if (buff.caster ~= WT.Player.id) then return false end 
	end

	local priority = buff.priority or 2

	if buff.debuff then
		if self.config.auraType == "debuff" then return true end
		if priority == 1 and self.config.acceptLowPriorityDebuffs then return true end
		if priority == 2 and self.config.acceptMediumPriorityDebuffs then return true end
		if priority == 3 and self.config.acceptHighPriorityDebuffs then return true end
		if priority == 4 and self.config.acceptCriticalPriorityDebuffs then return true end
	else
		if self.config.auraType == "buff" then return true end
		if self.config.auraType == "hot" then
			-- print(self.UnitFrame.UnitSpec .. ": " .. buff.name .. " " .. buff.type)
			if buff.type then
				if additionalHoTs[buff.type] then 
					return true 
				end
			end
			if buff.duration and buff.duration > 0 and buff.duration < 61 then
				return true
			end
		end 
		if priority == 1 and self.config.acceptLowPriorityBuffs then return true end
		if priority == 2 and self.config.acceptMediumPriorityBuffs then return true end
		if priority == 3 and self.config.acceptHighPriorityBuffs then return true end
		if priority == 4 and self.config.acceptCriticalPriorityBuffs then return true end
	end

	return false
end


-- Stub, this will be used to make panels more efficient in future
function wtBuffPanel:Done()
end


function wtBuffPanel:Add(buff)

	local buffId = buff.id

	self.buffs[buffId] = buff

	self.currIcons = self.currIcons + 1
	self:ShowIcon(self.currIcons, buff.icon)
	local icon = self.Icons[self.currIcons] 
	icon.buffId = buffId -- store the buffId for when we come to remove it later
	self.UnitFrame.buffIconMap[buffId] = icon -- store a link from buffId to it's icon
	local buffDets = {}
	for k,v in pairs(buff) do buffDets[k] = v end
	icon.buff = buffDets

	if icon.txtStack then 
		if buffDets.stack then
			icon.txtStack:SetVisible(true)
			icon.txtStack:SetText(tostring(buffDets.stack))
		else
			icon.txtStack:SetVisible(false)
		end
	end
	
end

-- Update the stack count text if appropriate. This is probably all that can change?
-- We also update the buff details, which means the tick handler will pick up any duration changes automatically
function wtBuffPanel:Update(buff)

	local buffId = buff.id

	self.buffs[buffId] = buff

	local icon = self.UnitFrame.buffIconMap[buffId]
	if icon then
		icon.buff = buff
		if icon.txtStack then 
			if buff.stack then
				icon.txtStack:SetVisible(true)
				icon.txtStack:SetText(tostring(buff.stack))
			else
				icon.txtStack:SetVisible(false)
			end
		end
	end
end

-- This is the heavyweight call. Removing an icon is going to involve shuffling everything down
-- otherwise the panels will get really odd.
-- However, for performance reasons, this is going to have to be isolated to the panel the buff
-- is found in, which could have odd repercussions for complex frames, but for most cases this
-- is preferable to trying to move icons between panels as they shuffle down
function wtBuffPanel:Remove(buff)

	local buffId = buff.id

	self.buffs[buffId] = nil

	local removeIdx = 0
	self.UnitFrame.buffIconMap[buffId] = nil -- remove the icon mapping if one exists
	for iconIdx, icon in ipairs(self.Icons) do
		if icon.buffId == buffId then
			removeIdx = iconIdx
			break
		end
	end
	if (removeIdx > 0) then	
		for i = removeIdx + 1, self.currIcons do
			self.Icons[i-1]:SetTexture(self.Icons[i]:GetTexture())
			self.Icons[i-1].buffId = self.Icons[i].buffId
			self.Icons[i-1].buff = self.Icons[i].buff
			
			if self.Icons[i-1].txtStack then
				self.Icons[i-1].txtStack:SetText(self.Icons[i].txtStack:GetText())
				self.Icons[i-1].txtStack:SetVisible(self.Icons[i].txtStack:GetVisible())
			end
			
			self.UnitFrame.buffIconMap[self.Icons[i].buffId] = self.Icons[i-1]
		end
		self:HideIcon(self.currIcons)
		self.currIcons = self.currIcons - 1
	end

end

local function BuffTimerTick(hEvent)

	local currTime = Inspect.Time.Frame()
	if WT.BuffTimers then
		for idx, icon in ipairs(WT.BuffTimers) do
			if icon.buff then 
				local txt = ""
				if icon.buff.duration then
					local elapsed = currTime - icon.buff.begin
					local remaining = math.floor(icon.buff.duration - elapsed)
					if remaining < 0 then
						txt = "" 
					elseif remaining < 60 then
-------------------------------delete "s" from timer----------------------------------------------------------------------------------------------
						--txt = remaining .. "s"
						txt = remaining .. ""
					elseif remaining < 3600 then
						txt = math.floor(remaining / 60) .. "m"
					end
				end
				if (not icon.currTimerText) or (icon.currTimerText ~= txt) then
					icon.currTimerText = txt
					icon.txtTimer:SetText(txt)
				end
			end
		end
	end

	if WT.BuffSweeps then
		for idx, icon in ipairs(WT.BuffSweeps) do
			if icon.buff then 
				local percent = 0
				if icon.buff.duration then
					local elapsed = currTime - icon.buff.begin
					local remaining = icon.buff.duration - elapsed
					percent = math.floor((remaining / icon.buff.duration) * 100)
				else
					percent = 99
				end
				if (not icon.currSweepPercent) or (icon.currSweepPercent ~= percent) then
					icon.sweepElement:SetIndex(99-percent)
					icon.currSweepPercent = percent
				end
			end
		end
	end
	
end

Command.Event.Attach(Event.System.Update.Begin, BuffTimerTick, "BuffTimerTick")