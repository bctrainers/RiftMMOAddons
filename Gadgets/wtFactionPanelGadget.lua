--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.7.2
      Project Date (UTC)  : 2014-12-06T23:42:32Z
      File Modified (UTC) : 2013-10-01T20:23:06Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local gadgetIndex = 0
local factionGadgets = {}

local details = nil

local function UpdatePanel(panel, showAll)

	local filters = panel.config.filters
    local texture = panel.config.texture
	local ColorBar = panel.config.ColorBar
	local backColor = panel.config.backColor
	
	if not panel.Categories then panel.Categories = {} end
	for factionId, detail in pairs(details) do
	
		if not panel.Categories[detail.categoryName] then
			local catText = UI.CreateFrame("Text", "categoryText", panel)
			catText:SetText(detail.categoryName)
			catText:SetFontSize(14)
			catText:SetEffectGlow({ strength = 3 })
			catText:SetFontColor(.2, .4, .7 )
			panel.Categories[detail.categoryName] = catText
		end
		local catText = panel.Categories[detail.categoryName]
		if not catText.Factions then catText.Factions = {} end
		if not catText.Factions[detail.name] then
		
			local factionFrame = UI.CreateFrame("Frame", "factionFrame", catText)
			factionFrame:SetBackgroundColor(backColor[1],backColor[2],backColor[3],backColor[4])
			factionFrame:SetHeight(18)
			factionFrame:SetWidth(280)
			factionFrame:SetLayer(1)

			catText.Factions[detail.name] = factionFrame

				  top = UI.CreateFrame("Frame", "TopBorder", factionFrame)
				  top:SetBackgroundColor(0,0,0,1)
				  top:SetLayer(1)
				  top:ClearAll()
				  top:SetPoint("BOTTOMLEFT", factionFrame, "TOPLEFT", -1, 0)
				  top:SetPoint("BOTTOMRIGHT", factionFrame, "TOPRIGHT", 1, 0)
				  top:SetHeight(1)
				  
				  bottom = UI.CreateFrame("Frame", "BottomBorder", factionFrame)
				  bottom:SetBackgroundColor(0,0,0,1)
				  bottom:SetLayer(1)
				  bottom:ClearAll()
				  bottom:SetPoint("TOPLEFT", factionFrame, "BOTTOMLEFT", -1, 0)
				  bottom:SetPoint("TOPRIGHT", factionFrame, "BOTTOMRIGHT",1, 0)
				  bottom:SetHeight(1)
				  
				  left = UI.CreateFrame("Frame", "LeftBorder", factionFrame)
				  left:SetBackgroundColor(0,0,0,1)
				  left:SetLayer(1)
				  left:ClearAll()
				  left:SetPoint("TOPRIGHT", factionFrame, "TOPLEFT", 0, -1)
				  left:SetPoint("BOTTOMRIGHT", factionFrame, "BOTTOMLEFT", 0, 1)
				  left:SetWidth(1)
				  
				  right = UI.CreateFrame("Frame", "RightBorder", factionFrame)
				  right:SetBackgroundColor(0,0,0,1)
				  right:SetLayer(1)
				  right:ClearAll()
				  right:SetPoint("TOPLEFT", factionFrame, "TOPRIGHT", 0, -1)
				  right:SetPoint("BOTTOMLEFT", factionFrame, "BOTTOMRIGHT", 0, 1)
				  right:SetWidth(1)
			
			local factionBar = UI.CreateFrame("Texture", "factionBar", factionFrame)
			factionBar:SetHeight(18)
			Library.Media.SetTexture(factionBar, texture)
			factionBar:SetBackgroundColor(ColorBar[1],ColorBar[2],ColorBar[3],ColorBar[4])--(0,0.6,0,0.8,1)
			factionBar:SetLayer(2)	
			factionBar:SetPoint("TOPLEFT", factionFrame, "TOPLEFT")
			catText.Factions[detail.name].factionBar = factionBar
			
			local factionText = UI.CreateFrame("Text", "factionText", factionFrame)
			factionText:SetText(detail.name)
			factionText:SetFontSize(13)
			factionText:SetEffectGlow({ strength = 3 })
			factionText:SetPoint("CENTERLEFT", factionFrame, "CENTERLEFT", 0, 0)
			factionText:SetLayer(3)
			factionText:SetFontColor(0.9, 0.9, 0.2 )
			
			
			local notorietyText = UI.CreateFrame("Text", "notorietyText", factionFrame)
			notorietyText:SetFontSize(13)
			notorietyText:SetEffectGlow({ strength = 3 })
			catText.Factions[detail.name].NotorietyText = notorietyText
			notorietyText:SetPoint("CENTERRIGHT", factionFrame, "CENTERRIGHT", 0, 0)
			notorietyText:SetLayer(3)
		end
		
		local notor = detail.notoriety - 23000
		
		local notorNames = { "Neutral", "Friendly", "Decorated", "Honored", "Revered", "Glorified", "Venerated" }
		local notorPoints = { 3000, 10000, 20000, 35000, 60000, 90000, 90000 }
		
		local notorIdx = 0
		for idx, name in ipairs(notorNames) do
			local points = notorPoints[idx]
			if notor < points then
				notorIdx = idx
				break
			else
				notor = notor - points
			end
		end
		
		
		local notString = notorNames[notorIdx] .. " " .. tostring(notor) .. "/" .. notorPoints[notorIdx]
		local percent = notor / notorPoints[notorIdx]
		if notor == 0 then
			notString = notorNames[notorIdx]
			percent = 1.0
		end
		
		catText.Factions[detail.name].factionBar:SetWidth((panel:GetWidth() - 20) * percent)
		catText.Factions[detail.name].NotorietyText:SetText(notString)	
	end
	
	local anchor = nil
	
	local sortedCats = {}
	for category in pairs(panel.Categories) do
		table.insert(sortedCats, category)
	end
	table.sort(sortedCats)
	
	for _, category, frame in ipairs(sortedCats) do	
		local frame = panel.Categories[category]
		
		local include = false
		for faction in pairs(frame.Factions) do
			if filters[faction] == true then 
				include = true
				--break
			end
		end
		
		if include or showAll then

		
			frame:SetVisible(true)
		
			if not anchor then
				frame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, 3)
			else
				frame:SetPoint("TOP", anchor, "BOTTOM", nil, 3)
				frame:SetPoint("LEFT", panel, "LEFT", 10, nil)
			end
			anchor = frame
			
			local sortedFacts = {}
			for faction in pairs(frame.Factions) do
				table.insert(sortedFacts, faction)
			end
			table.sort(sortedFacts)
			
			for _, faction in ipairs(sortedFacts) do			
				factFrame = frame.Factions[faction]
				if (filters[faction] == false) and (not showAll) then
					factFrame:SetVisible(false)
				else
					factFrame:SetVisible(true)
					factFrame:SetPoint("TOP", anchor, "BOTTOM", nil, 3)
					factFrame:SetPoint("LEFT", panel, "LEFT", 10, nil)
					factFrame.NotorietyText:SetPoint("TOP", anchor, "BOTTOM", nil, 3)
					factFrame.NotorietyText:SetPoint("RIGHT", panel, "RIGHT", -10, nil)
					anchor = factFrame
				end
			end

		else
		
			frame:SetVisible(false)		
			
		end
		
	end 
	
	if anchor then
		panel:SetHeight(anchor:GetBottom() - panel:GetTop() + 8)
	else
		panel:SetHeight(100)
	end
	
end

local function UpdatePanels(showAll)
	local list = Inspect.Faction.List()
	if list then
		details = Inspect.Faction.Detail(list)
		for idx, panel in ipairs(factionGadgets) do
			UpdatePanel(panel, showAll)	
		end
	end
end


local function OnNotoriety(hEvent, notoriety)
	UpdatePanels()
end


local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtFaction"), WT.Context)
	wrapper:SetWidth(300)
	wrapper:SetHeight(100)
	
	wrapper.config = configuration
	
	if configuration.showBackground == true  then
	    if configuration.TransparentBar == true then 
			wrapper:SetBackgroundColor(0.07,0.07,0.07,0.85) 
		else
			wrapper:SetBackgroundColor(0,0,0,0.4) 
		end
	else
		wrapper:SetBackgroundColor(0,0,0,0)
	end
	
	if not configuration.texture then configuration.texture = Library.Media.GetTexture(configuration.texture) end
	if configuration.ColorBar == nil then configuration.ColorBar = {0,0.6,0,0.8} end 
    if configuration.backColor == nil then configuration.backColor = {0.07,0.07,0.07,0.85} end 
	
	if not configuration.filters then 
		configuration.filters = {} 
	end
	
	
	table.insert(factionGadgets, wrapper)

	UpdatePanels()

	return wrapper
	
end


local dialog = false

local function ConfigDialog(container)	
		
	local lMedia = Library.Media.FindMedia("bar")
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end
	
	dialog = WT.Dialog(container)
		:Label("The Faction Panel has no additional configuration options")
		:TexSelect("texture", "Texture", "wtHealbot", "bar")
		:ColorPicker("ColorBar", "Bar color", 0,0.6,0,0.8)
		:ColorPicker("backColor", "Background Bar Color", 0.07,0.07,0.07,0.85)
		:Checkbox("showBackground", "Show Background frame", false)
		:Checkbox("TransparentBar", "Transparent Background frame", false)
			
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false

	if gadgetConfig.texture ~= config.texture then
		gadgetConfig.texture = config.texture
		gadget.media = Library.Media.GetTexture(config.texture)
	end
	
	if gadgetConfig.TransparentBar ~= config.TransparentBar then
		gadgetConfig.TransparentBar = config.TransparentBar
		requireRecreate = true
	end
	
	
	if gadgetConfig.ColorBar ~= config.ColorBar then
		gadgetConfig.ColorBar = config.ColorBar
		gadget.ColorBar = config.ColorBar
		requireRecreate = true
	end
	
	if gadgetConfig.showBackground ~= config.showBackground then
		gadgetConfig.showBackground = config.showBackground
		requireRecreate = true
	end
	
	if requireRecreate then
		WT.Gadget.Delete(gadgetConfig.id)
		WT.Gadget.Create(gadgetConfig)
	end		
	
end

WT.Gadget.RegisterFactory("FactionPanel",
	{
		name="Faction Panel",
		description="Faction Panel",
		author="Wildtide",
		version="1.0.0",
		texture = "MediaID for the texture, for use with LibMedia",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
		["Reconfigure"] = Reconfigure,
	})

local function OnPlayerAvailable(hEvent)
	UpdatePanels()
end

local function OnUnlocked()
	for idx, panel in ipairs(factionGadgets) do
		-- Create the tick boxes if needed	
		if not panel.filters then
			panel.filters = true
			local filters = panel.config.filters
			for _, category in pairs(panel.Categories) do
				for factionName, bar in pairs(category.Factions) do
					local check = UI.CreateFrame("RiftCheckbox", "check", panel.mvHandle)
					check:SetPoint("CENTERRIGHT", bar, "CENTERLEFT", -2, 0)
					if filters[factionName] == false then
						check:SetChecked(false)
					else
						check:SetChecked(true)
					end
					bar.Filter = check
				end
			end
		end
	end
	UpdatePanels(true)
end

local function OnLocked()
	for idx, panel in ipairs(factionGadgets) do
		if panel.filters then
			for _, category in pairs(panel.Categories) do
				for factionName, bar in pairs(category.Factions) do
					if bar.Filter then
						panel.config.filters[factionName] = bar.Filter:GetChecked()
					end 
				end
			end
		end
	end
	-- Now that the filters have been updated, update the panels
	UpdatePanels()
end

Command.Event.Attach(Event.Faction.Notoriety, OnNotoriety, "OnNotoriety")
Command.Event.Attach(WT.Event.PlayerAvailable, OnPlayerAvailable, "FactionPanel_OnPlayerAvailable")	

Command.Event.Attach(WT.Event.GadgetsUnlocked, OnUnlocked, "FactionPanel_OnUnlocked")
Command.Event.Attach(WT.Event.GadgetsLocked, OnLocked, "FactionPanel_OnLocked")