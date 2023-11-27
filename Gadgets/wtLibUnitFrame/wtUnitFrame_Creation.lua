local toc, data = ...
local AddonId = toc.identifier

-- Gadget Factory Function for single UnitFrame
function WT.UnitFrame.CreateFromConfiguration(configuration)
	local template = configuration.template
	local unitSpec = configuration.unitSpec

		--dump(Inspect.Unit.Detail(Inspect.Unit.Lookup("group01")))
	if not template then print("Missing required configuration item: template") return end
	if not unitSpec then print("Missing required configuration item: unitSpec") return end

	local shortname = configuration.shortname or false
	local showname = configuration.showname or false
	local showRadius = configuration.showRadius or false
	local showCombo = configuration.showCombo or false
	local showRankIcon = configuration.showRankIcon or false

	WT.Log.Debug("Creating UnitFrame from configuration: template=" .. template .. " unitSpec=" .. unitSpec)
	return WT.UnitFrame.CreateFromTemplate(template, unitSpec, configuration)
end

local raidFrameGadgets = {}

-- Gadget Factory Function for grid of 20 UnitFrames
function WT.UnitFrame.CreateRaidFramesFromConfiguration(configuration)

	local sequenceDefault =
	{
		"group01","group02","group03","group04","group05",
		"group06","group07","group08","group09","group10",
		"group11","group12","group13","group14","group15",
		"group16","group17","group18","group19","group20",
	}

	local sequenceReverse =
	{
		"group20","group19","group18","group17","group16",
		"group15","group14","group13","group12","group11",
		"group10","group09","group08","group07","group06",
		"group05","group04","group03","group02","group01",
	}

	local sequenceInnerGroupReverse =
	{
		"group05","group04","group03","group02","group01",
		"group10","group09","group08","group07","group06",
		"group15","group14","group13","group12","group11",
		"group20","group19","group18","group17","group16",
	}

	local sequenceGroupReverse =
	{
		"group16","group17","group18","group19","group20",
		"group11","group12","group13","group14","group15",
		"group06","group07","group08","group09","group10",
		"group01","group02","group03","group04","group05",
	}

	local sequence = sequenceDefault

	if configuration.reverseGroups and configuration.reverseUnits then
		sequence = sequenceReverse
	elseif configuration.reverseGroups then
		sequence = sequenceGroupReverse
	elseif configuration.reverseUnits then
		sequence = sequenceInnerGroupReverse
	end

	local template = configuration.template
	local layout = configuration.layout or "4 x 5"
	local growthDirection = configuration.growthDirection or "right"
	WT.Log.Debug("Creating RaidFrames from configuration: template=" .. template)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("RaidFrames"), WT.Context)

	if configuration.showBackground then
		wrapper:SetBackgroundColor(0,0,0,0.2)
	end

	wrapper.hideWhenEmpty = configuration.hideWhenEmpty or false

	wrapper:SetSecureMode("restricted")
	-- Pass through our clickToTarget preference to the template to allow it to set itself up appropriately
	--if not configuration.templateOptions then configuration.templateOptions = {} end
	--configuration.templateOptions.clickToTarget = configuration.clickToTarget

	local frames = {}

	local _debug = false


	--[[for i = 1,20 do
		local unitId = Inspect.Unit.Lookup(sequence[i])
		if unitId ~= nil then
		dump(Inspect.Unit.Detail(unitId))
		end
	end]]


	if WT.GetGroupMode() == "solo" and configuration.show_Solo == true then
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, "player", configuration)
	elseif not _debug then
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, sequence[1], configuration)
	else
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, "player", configuration)
		--local debugDesc = UI.CreateFrame("Text", "TXT", WT.Context)
		--debugDesc:SetText(sequence[1])
		--debugDesc:SetLayer(500)
		--debugDesc:SetPoint("BOTTOMLEFT", frames[1], "BOTTOMLEFT")
	end

	frames[1]:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	frames[1]:SetParent(wrapper)
	frames[1]:SetLayer(1)

	for i = 2,20 do
		if not _debug then
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, sequence[i], configuration)
		else
			if i <= 5 then
				frames[i] = WT.UnitFrame.CreateFromTemplate(template, "player", configuration)
			elseif i <= 10 then
				frames[i] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
			elseif i <= 15 then
				frames[i] = WT.UnitFrame.CreateFromTemplate(template, "player", configuration)
			else
				frames[i] = WT.UnitFrame.CreateFromTemplate(template, "focus", configuration)
			end
		end
		frames[i]:SetParent(wrapper)
		frames[i]:SetLayer(i)
	end

	wrapper.frame01Unit = sequence[1]

	local xCols = 4
	local xRows = 5

	-- Layout the frames appropriately
	if layout == "5 x 4" then
		xCols = 5
		xRows = 4
		for i = 2,20 do
			if ((i-1) % 5) ~= 0 then
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
			else
				frames[i]:SetPoint("TOPLEFT", frames[i-5], "BOTTOMLEFT")
			end
		end
	elseif layout == "2 x 10" then
		xCols = 2
		xRows = 10
		for i = 2,20 do
			if ((i-1) % 10) ~= 0 then
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
			else
				frames[i]:SetPoint("TOPLEFT", frames[i-10], "TOPRIGHT")
			end
		end
	elseif layout == "10 x 2" then
		xCols = 10
		xRows = 2
		for i = 2,20 do
			if ((i-1) % 10) ~= 0 then
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
			else
				frames[i]:SetPoint("TOPLEFT", frames[i-10], "BOTTOMLEFT")
			end
		end
	elseif layout == "1 x 20" then
		xCols = 1
		xRows = 20
		for i = 2,20 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
		end
	elseif layout == "20 x 1" then
		xCols = 20
		xRows = 1
		for i = 2,20 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
		end
	else -- "4 x 5"
		xCols = 4
		xRows = 5
		for i = 2,20 do
			if ((i-1) % 5) ~= 0 then
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
			else
				frames[i]:SetPoint("TOPLEFT", frames[i-5], "TOPRIGHT")
			end
		end
	end

	local left = frames[1]:GetLeft()
	local top = frames[1]:GetTop()
	local right = frames[20]:GetRight()
	local bottom = frames[20]:GetBottom()

	wrapper:SetWidth(right - left + 1)
	wrapper:SetHeight(bottom - top + 1)

	wrapper.OnResize =
		function(frame, width,height)
			local frmWidth = math.ceil(width / xCols)
			local frmHeight = math.ceil(height / xRows)
			wrapper:SetWidth(frmWidth * xCols)
			wrapper:SetHeight(frmHeight * xRows)
			for i=1,20 do
				frames[i]:SetWidth(frmWidth)
				frames[i]:SetHeight(frmHeight)
				frames[i]:OnResize(frmWidth, frmHeight)
			end
		end

	if configuration.macros then
		for i = 1,20 do
			frames[i]:SetMacros(configuration.macros)
		end
	end

	if wrapper.hideWhenEmpty then
		if WT.GetGroupMode() == "solo" then
			WT.HideSecureFrame(wrapper)
		end
	end

	wrapper.frames = frames
	wrapper.macros = configuration.macros
	raidFrameGadgets[wrapper] = true

	return wrapper, { resizable = { right - left + 1, bottom - top + 1, (right - left + 1) * 4, (bottom - top + 1) * 4,  } }
end


local groupFrameGadgets = {}

-- Gadget Factory Function for grid of 20 UnitFrames
function WT.UnitFrame.CreateGroupFramesFromConfiguration(configuration)

	local group = 1
	if configuration.group == "Group 2" then
		group = 2
	elseif configuration.group == "Group 3" then
		group = 3
	elseif configuration.group == "Group 4" then
		group = 4
	end

	local firstId = ((group - 1) * 5) + 1
	local sequence = {}

	if configuration.reverseUnits then
		sequence[1] = "group" .. string.format("%02d", firstId+4)
		sequence[2] = "group" .. string.format("%02d", firstId+3)
		sequence[3] = "group" .. string.format("%02d", firstId+2)
		sequence[4] = "group" .. string.format("%02d", firstId+1)
		sequence[5] = "group" .. string.format("%02d", firstId+0)
	else
		sequence[1] = "group" .. string.format("%02d", firstId+0)
		sequence[2] = "group" .. string.format("%02d", firstId+1)
		sequence[3] = "group" .. string.format("%02d", firstId+2)
		sequence[4] = "group" .. string.format("%02d", firstId+3)
		sequence[5] = "group" .. string.format("%02d", firstId+4)
	end

	local xCols = 1
	local xRows = 5

	local template = configuration.template
	local layout = configuration.layout or "Vertical"
	WT.Log.Debug("Creating GroupFrames from configuration: template=" .. template)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("GroupFrames"), WT.Context)

	if configuration.showBackground then
		wrapper:SetBackgroundColor(0,0,0,0.2)
	end

	wrapper.hideWhenEmpty = configuration.hideWhenEmpty or false

	wrapper:SetSecureMode("restricted")
	-- Pass through our clickToTarget preference to the template to allow it to set itself up appropriately
	--if not configuration.templateOptions then configuration.templateOptions = {} end
	--configuration.templateOptions.clickToTarget = configuration.clickToTarget

	local frames = {}

	local _debug = false

	--[[if Inspect.Unit.Lookup("player") then

	end]]

	if WT.GetGroupMode() == "solo" and configuration.show_Solo == true then
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, "player", configuration)
	elseif not _debug then
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, sequence[1], configuration)
	else
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
	end

	frames[1]:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	frames[1]:SetParent(wrapper)
	frames[1]:SetLayer(1)

	for i = 2,5 do
		if not _debug then
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, sequence[i], configuration)
		else
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
		end
		frames[i]:SetParent(wrapper)
		frames[i]:SetLayer(i)
	end

	-- Layout the frames appropriately
	if layout == "Horizontal" then
		xCols = 5
		xRows = 1
		for i = 2,5 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
		end
	elseif 	layout == "LifeismysteryGroupFrame" then
		xCols = 1
		xRows = 5
		for i = 2,5 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT", 0, 10)
	end
	else
		xCols = 1
		xRows = 5
		for i = 2,5 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
		end
	end

	local left = frames[1]:GetLeft()
	local top = frames[1]:GetTop()
	local right = frames[5]:GetRight()
	local bottom = frames[5]:GetBottom()

	wrapper:SetWidth(right - left + 1)
	wrapper:SetHeight(bottom - top + 1)

	wrapper.OnResize =
		function(frame, width,height)
			local frmWidth = math.ceil(width / xCols)
			local frmHeight = math.ceil(height / xRows)
			wrapper:SetWidth(frmWidth * xCols)
			wrapper:SetHeight(frmHeight * xRows)
			for i=1,5 do
				frames[i]:SetWidth(frmWidth)
				frames[i]:SetHeight(frmHeight)
				frames[i]:OnResize(frmWidth, frmHeight)
			end
		end

	if configuration.macros then
		for i = 1,5 do frames[i]:SetMacros(configuration.macros) end
	end

	-- Store a reference to the gadget, to use in the hide/show events
	groupFrameGadgets[wrapper] = true
	wrapper.groupId = group

	if wrapper.hideWhenEmpty then
		if not WT.GroupExists(wrapper.group) then
			WT.HideSecureFrame(wrapper)
		end
	end

	return wrapper, { resizable = { right - left + 1, bottom - top + 1, (right - left + 1) * 2, (bottom - top + 1) * 2,  }, caption=configuration.group }
end



function WT.UnitFrame.CreateFromTemplate(templateName, unitSpec, options)

	WT.Log.Info("Creating unit frame from template " .. tostring(templateName) .. " for unit " .. tostring(unitSpec))
	local template = WT.UnitFrame.Templates[templateName]
	if not template then return nil end
	local uf, createOptions = template:Create(unitSpec, options)

	if options.ovHealthTexture and options.texHealth then
		if uf.Elements and uf.Elements.barHealth then
			Library.Media.SetTexture(uf.Elements.barHealth.Image, options.texHealth)
		end
	end

	--[[if options.ovHealthColor and options.colHealth then
		if uf.Elements and uf.Elements.barHealth then
			uf.Elements.barHealth:BindColor(unpack(options.colHealth))
		end
	end]]

	if options.ovResourceTexture and options.texResource then
		if uf.Elements and uf.Elements.barResource then
			Library.Media.SetTexture(uf.Elements.barResource.Image, options.texResource)
		end
	end

	if options.ovAbsorbTexture and options.texAbsorb then
		if uf.Elements and uf.Elements.barAbsorb then
			Library.Media.SetTexture(uf.Elements.barAbsorb.Image, options.texAbsorb)
		end
	end

	if options.ovCastTexture and options.texCast then
		if uf.Elements and uf.Elements.barCast then
			Library.Media.SetTexture(uf.Elements.barCast.Image, options.texCast)
		end
	end

	if options.ovHealthBackgroundColor and options.colHealthBackground then
		if uf.Elements and uf.Elements.barHealth then
			uf.Elements.barHealth:SetBackgroundColor(unpack(options.colHealthBackground))
		end
	end
	-- Override any existing mouse handling and add our own
	-- This is a precursor to full macro handling
	uf:SetSecureMode("restricted")
	uf:SetMouseoverUnit(uf.UnitSpec)

	return uf, createOptions
end





-- EVENT HANDLING FOR DYNAMICALLY HIDING AND SHOWING UNIT FRAME GADGETS

local function ApplyGroupFrameVisibility()
	for groupFrame in pairs(groupFrameGadgets) do
		if groupFrame.hideWhenEmpty and not WT.GroupExists(groupFrame.groupId) then
			WT.HideSecureFrame(groupFrame)
		else
			WT.ShowSecureFrame(groupFrame)
		end
	end
end

local function ApplyRaidFrameVisibility()
	for raidFrame in pairs(raidFrameGadgets) do
		if raidFrame.hideWhenEmpty and WT.GetGroupMode() == "solo" then
			WT.HideSecureFrame(raidFrame)
		else
			WT.ShowSecureFrame(raidFrame)
		end
		if WT.GetGroupMode() == "solo" then
		    WT.SecureFunction(
		        function() 
		            raidFrame.frames[1]:TrackUnit("player")
		            if (raidFrame.macros) then raidFrame.frames[1]:SetMacros(raidFrame.macros) end 
		        end)			
		else
		    WT.SecureFunction(
		        function() 
		            raidFrame.frames[1]:TrackUnit(raidFrame.frame01Unit)
		            if (raidFrame.macros) then raidFrame.frames[1]:SetMacros(raidFrame.macros) end 		             
		        end)			
		end
	end
end

local function OnGroupAdded(hEvent, groupId)
	ApplyGroupFrameVisibility()
	ApplyRaidFrameVisibility()
end

local function OnGroupRemoved(hEvent, groupId)
	ApplyGroupFrameVisibility()
	ApplyRaidFrameVisibility()
end

local function OnLocked()
	ApplyGroupFrameVisibility()
	ApplyRaidFrameVisibility()
end

local function OnUnlocked()
	for groupFrame in pairs(groupFrameGadgets) do
		WT.ShowSecureFrame(groupFrame)
	end
	for raidFrame in pairs(raidFrameGadgets) do
		WT.ShowSecureFrame(raidFrame)
	end
end

local function OnGroupModeChanged(hEvent, mode, oldMode)
	ApplyRaidFrameVisibility()
end

Command.Event.Attach(WT.Event.GroupAdded, OnGroupAdded, "OnGroupAdded" )
Command.Event.Attach(WT.Event.GroupRemoved, OnGroupRemoved, "OnGroupRemoved" )
Command.Event.Attach(WT.Event.GadgetsLocked, OnLocked, "OnLocked" )
Command.Event.Attach(WT.Event.GadgetsUnlocked, OnUnlocked, "OnUnlocked" )
Command.Event.Attach(WT.Event.GroupModeChanged, OnGroupModeChanged, "OnGroupModeChanged" )
