--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2015-07-13T16:47:34Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate




local gadgetId = nil
local previewId = nil
local gadgetConfig = nil
local previewConfig = nil
local gadgetFactory = nil

local ENABLE_RECONFIGURE = true

local function ApplyModification()

	-- Give the creation enough time to run
	WT.WatchdogSleep()

	local gadget = WT.Gadgets[gadgetId]
	
	gadgetConfig.show_Solo = WT.Gadget.CreateGadgetWindow.StandardOptions.chkShow_Solo:GetChecked()
	gadgetConfig.show_Party = WT.Gadget.CreateGadgetWindow.StandardOptions.chkShow_Party:GetChecked()
	gadgetConfig.show_Raid10 = WT.Gadget.CreateGadgetWindow.StandardOptions.chkShow_Raid10:GetChecked()
	gadgetConfig.show_Raid20 = WT.Gadget.CreateGadgetWindow.StandardOptions.chkShow_Raid20:GetChecked()
	gadgetConfig.alpha_IC = WT.Gadget.CreateGadgetWindow.StandardOptions.sldAlphaIC:GetPosition()
	gadgetConfig.alpha_OOC = WT.Gadget.CreateGadgetWindow.StandardOptions.sldAlphaOOC:GetPosition()

	gadget.showGroup.solo = gadgetConfig.show_Solo 
	gadget.showGroup.party = gadgetConfig.show_Party 
	gadget.showGroup.raid10 = gadgetConfig.show_Raid10 
	gadget.showGroup.raid20 = gadgetConfig.show_Raid20
	gadget.alpha_IC = gadgetConfig.alpha_IC
	gadget.alpha_OOC = gadgetConfig.alpha_OOC

	if gadgetFactory.GetConfiguration then
	 	local config = gadgetFactory.GetConfiguration()
	--dump(gadgetId)
		if ENABLE_RECONFIGURE and gadgetFactory.Reconfigure then
			for k,v in pairs(gadgetConfig) do
				if config[k] == nil then config[k] = v end
			end
			gadgetFactory.Reconfigure(config)
			wtxGadgets[gadgetId] = config		
		else
			for k,v in pairs(config) do gadgetConfig[k] = v end
			WT.Gadget.Delete(gadgetId)					
			WT.Gadget.Create(gadgetConfig)
		end

		WT.Gadgets[gadgetId].displayRoot:SetAlpha(gadgetConfig.alpha_OOC / 100)
	end

end


local function OnModifyClick()

	ApplyModification()

	WT.Utility.ClearKeyFocus(WT.Gadget.CreateGadgetWindow)
	WT.Gadget.CreateGadgetWindow:SetVisible(false) 
	WT.Gadget.RecommendReload()	
end


local listItems = {}
local listItemCount = 0

-- This is going to be a biggie!
-- Need to ask the user to select a gadget type (ie. a factory), and then present configuration options
-- that are relevant to that particular gadget type.
-- Then, for things like UnitFrame gadgets, there is a further selection of template and then the template
-- options also need to be displayed. Gets complicated!

function WT.Gadget.ShowCreationUI()

	if not WT.Gadget.CreateGadgetWindow then
		local window  = UI.CreateFrame("Texture", "WTGadgetCreate", WT.Context)

		if not wtxOptions.BackgroundTex then wtxOptions.BackgroundTex = "BackgroundTexTrans" end
		if wtxOptions.BackgroundTex == "BackgroundTexTrans" then		
			window:SetTexture(AddonId, "img/menu4.png")
		else
			window:SetTexture(AddonId, "img/menu3.png")
		end
		
		window:SetPoint("CENTER", UIParent, "CENTER")
		window:SetWidth(900)
		window:SetHeight(900)
		window:SetLayer(9997)
				  
		Library.LibDraggable.draggify(window, nil)	
		
		window.closeButton = UI.CreateFrame("Texture", window:GetName().."CloseButton", window)
		window.closeButton:SetTexture(AddonId, "img/Ignore.png" )
		window.closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -40, 40)
				  
		function window.closeButton.fnc_LeftClick()	
			window:SetVisible(false)
				if window.Event.Close then
				 window.Event.Close(window)
				end		
		end			
		window.closeButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
				window.closeButton.fnc_LeftClick()
			end, "Event.UI.Input.Mouse.Left.Click")
		
		WT.Gadget.CreateGadgetWindow = window
		
		local content = window--UI.CreateContext("wtContext")

		local frameTypeList = UI.CreateFrame("Mask", "WTGadgetCreateTypeList", content)
		frameTypeList:SetPoint("TOPLEFT", content, "TOPLEFT", 100, 100)
		frameTypeList:SetPoint("BOTTOMRIGHT", content, "BOTTOMLEFT", 350, -100) -- 40% of the width given over to the type list
		frameTypeList:SetBackgroundColor(0,0,0,0) -- Set the type list to an almost completely transparent white color, to seperate it from the options panel
		window.frameTypeList = frameTypeList
		
		local frameScrollAnchor = UI.CreateFrame("Frame", "WTGadgetScrollAnchor", content)
		frameScrollAnchor:SetPoint("TOPLEFT", frameTypeList, "TOPLEFT", 0, 0)
		--frameScrollAnchor:SetBackgroundColor(0,0,0,1)
		window.frameScrollAnchor = frameScrollAnchor

		local typeListScrollbar = UI.CreateFrame("RiftScrollbar", "WTGadgetTypeScroll", frameTypeList)
		typeListScrollbar:SetPoint("TOPRIGHT", frameTypeList, "TOPRIGHT", -1, 1)
		typeListScrollbar:SetPoint("BOTTOM", frameTypeList, "BOTTOM", nil, -1)
		typeListScrollbar:SetBackgroundColor(0,0,0,1)
		typeListScrollbar:EventAttach(Event.UI.Scrollbar.Change, function(self, h)
			frameScrollAnchor:SetPoint("TOPLEFT", frameTypeList, "TOPLEFT", 0, -typeListScrollbar:GetPosition())
		end, "Event.UI.Scrollbar.Change")
			
		frameTypeList:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function() typeListScrollbar:Nudge(-40) end, "WheelForward")
		frameTypeList:EventAttach(Event.UI.Input.Mouse.Wheel.Back, function() typeListScrollbar:Nudge(40) end, "WheelBack")		

		local frameModifyOverlay = UI.CreateFrame("Texture", "ModifyOverlay", content)
		frameModifyOverlay:SetAllPoints(frameTypeList)
		frameModifyOverlay:SetLayer(9996)
		frameModifyOverlay:SetTexture("Rift", "Guild_Guardian_bg.png.dds")
		frameModifyOverlay:SetAlpha(1)
		frameModifyOverlay:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 150)
		frameModifyOverlay:SetPoint("BOTTOMRIGHT", content, "BOTTOMLEFT", 400, -100) 
		window.frameModifyOverlay = frameModifyOverlay
		
		local labModifyTitle = UI.CreateFrame("Texture", "ModifyTitle", content)
		labModifyTitle:SetTexture(AddonId, "img/Modify Gadgets.png")
		labModifyTitle:SetPoint("TOPLEFT", content, "TOPRIGHT", -670, 10)
		labModifyTitle:SetLayer(9997)

		local frameOptions = UI.CreateFrame("Frame", "WTGadgetOptions", content)
		frameOptions:SetPoint("TOPLEFT", frameTypeList, "TOPRIGHT", 0, 0)
		frameOptions:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT" ,-75, -100)		
		--frameOptions:SetBackgroundColor(0,0,0,1)
		local framebackground = UI.CreateFrame("Texture", "WTGadgetOptions", frameOptions)
		framebackground:SetPoint("TOPLEFT", frameTypeList, "TOPRIGHT", -10, 110)
		framebackground:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT" ,-60, -125)	
		framebackground:SetTexture(AddonId, "img/background.png")
		
		local btnCancel = UI.CreateFrame("RiftButton", "WTGadgetBtnCancel", frameOptions)
		btnCancel:SetText(TXT.Cancel)
		btnCancel:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
		btnCancel:EventAttach(Event.UI.Button.Left.Press, function(self, h)
			window:SetVisible(false)
			WT.Utility.ClearKeyFocus(window)
		end, "Event.UI.Button.Left.Press")
			
		-- frameOptions will host the dialog provided by the gadget factory assuming one is available

		local frameOptionsHeading = UI.CreateFrame("Text", "WTGadgetOptionsHeading", frameOptions)
		frameOptionsHeading:SetFontSize(18)
		frameOptionsHeading:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		frameOptionsHeading:SetFontColor(1,0.97,0.84,1)
		--frameOptionsHeading:SetFont(AddonId, "blank-Bold")
		frameOptionsHeading:SetText(TXT.SelectGadgetType)
		frameOptionsHeading:SetPoint("TOPLEFT", frameOptions, "TOPLEFT", 8, 8)
		window.frameOptionsHeading = frameOptionsHeading

		local gadgetDetails = UI.CreateFrame("Text", "WTGadgetDetails", frameOptions)
		gadgetDetails:SetFontSize(12)
		gadgetDetails:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		gadgetDetails:SetFontColor(1,0.97,0.84,1)
		gadgetDetails:SetText("Gadgets, " .. TXT.Version .. "0.3.4")
		gadgetDetails:SetPoint("TOPLEFT", frameOptionsHeading, "BOTTOMLEFT", 0, -4)
		gadgetDetails:SetFontColor(0.8, 0.8, 0.8, 1.0)	
		window.gadgetDetails = gadgetDetails
		
		window.frameOptions = frameOptions
		window.btnCancel = btnCancel

		local standardOptions = UI.CreateFrame("Frame", "WTGadgetStandardOptions", frameOptions)
		standardOptions:SetBackgroundColor(0,0,0,0)
		standardOptions:SetPoint("TOPLEFT", gadgetDetails, "BOTTOMLEFT", 0, 4)
		standardOptions:SetHeight(72)
		standardOptions:SetPoint("RIGHT", frameOptions, "RIGHT", -16, nil)
		standardOptions:SetVisible(false)	
		window.StandardOptions = standardOptions
		
		local labVisibility = UI.CreateFrame("Text", "txtVisibility", standardOptions)
		labVisibility:SetText("Visible In Group:")
		labVisibility:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labVisibility:SetFontColor(1,0.97,0.84,1)
		labVisibility:SetFontSize(14)
		labVisibility:SetPoint("TOPLEFT", standardOptions, "TOPLEFT", 4, 2)
		
		local chkShow_Solo = UI.CreateFrame("SimpleLifeCheckbox", "chkShow_Solo", standardOptions)
		chkShow_Solo:SetText("Solo")
		chkShow_Solo:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		chkShow_Solo:SetFontColor(1,0.97,0.84,1)
		chkShow_Solo:SetFontSize(14)
		chkShow_Solo:SetPoint("TOPLEFT", labVisibility, "TOPLEFT", 130, 0)

		local chkShow_Party = UI.CreateFrame("SimpleLifeCheckbox", "chkShow_Party", standardOptions)
		chkShow_Party:SetText("Party")
		chkShow_Party:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		chkShow_Party:SetFontColor(1,0.97,0.84,1)
		chkShow_Party:SetFontSize(14)
		chkShow_Party:SetPoint("TOPLEFT", labVisibility, "TOPLEFT", 210, 0)

		local chkShow_Raid10 = UI.CreateFrame("SimpleLifeCheckbox", "chkShow_Raid10", standardOptions)
		chkShow_Raid10:SetText("Raid (10)")
		chkShow_Raid10:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		chkShow_Raid10:SetFontColor(1,0.97,0.84,1)
		chkShow_Raid10:SetFontSize(14)
		chkShow_Raid10:SetPoint("TOPLEFT", labVisibility, "TOPLEFT", 290, 0)

		local chkShow_Raid20 = UI.CreateFrame("SimpleLifeCheckbox", "chkShow_Raid20", standardOptions)
		chkShow_Raid20:SetText("Raid (20)")
		chkShow_Raid20:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		chkShow_Raid20:SetFontColor(1,0.97,0.84,1)
		chkShow_Raid20:SetFontSize(14)
		chkShow_Raid20:SetPoint("TOPLEFT", labVisibility, "TOPLEFT", 370, 0)
		
		local labAlphaIC = UI.CreateFrame("Text", "labAlphaIC", standardOptions)
		labAlphaIC:SetPoint("TOPLEFT", labVisibility, "BOTTOMLEFT", 0, 4)
		labAlphaIC:SetText("In Combat Opacity:") 
		labAlphaIC:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labAlphaIC:SetFontColor(1,0.97,0.84,1)
		labAlphaIC:SetFontSize(14)

		local labAlphaOOC = UI.CreateFrame("Text", "labAlphaOOC", standardOptions)
		labAlphaOOC:SetPoint("TOPLEFT", labAlphaIC, "BOTTOMLEFT", 0, 4)
		labAlphaOOC:SetText("Out of Combat Opacity:") 
		labAlphaOOC:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labAlphaOOC:SetFontColor(1,0.97,0.84,1)
		labAlphaOOC:SetFontSize(14)
		
		local sldAlphaIC = UI.CreateFrame("SimpleLifeSlider", "sldAlphaIC", standardOptions)
		sldAlphaIC:SetRange(0, 100)
		sldAlphaIC:SetWidth(200)
		sldAlphaIC:SetPoint("TOPLEFT", labAlphaIC, "TOPLEFT", 150, 0)

		local sldAlphaOOC = UI.CreateFrame("SimpleLifeSlider", "sldAlphaOOC", standardOptions)
		sldAlphaOOC:SetRange(0, 100)
		sldAlphaOOC:SetWidth(200)
		sldAlphaOOC:SetPoint("TOPLEFT", labAlphaOOC, "TOPLEFT", 150, 0)
		
		standardOptions.chkShow_Solo = chkShow_Solo
		standardOptions.chkShow_Party = chkShow_Party
		standardOptions.chkShow_Raid10 = chkShow_Raid10
		standardOptions.chkShow_Raid20 = chkShow_Raid20
		standardOptions.sldAlphaOOC = sldAlphaOOC
		standardOptions.sldAlphaIC = sldAlphaIC
		
		
		-- Setup the modify button
		
		local btnModify = UI.CreateFrame("RiftButton", "WTGadgetBtnOK", frameOptions)
		window.btnModify = btnModify
		btnModify:SetText(TXT.Modify)
		btnModify:SetPoint("CENTERRIGHT", btnCancel, "CENTERLEFT", 8, 0)
		btnModify:SetEnabled(true)
		btnModify:EventAttach(Event.UI.Button.Left.Press, function(self, h)
			OnModifyClick()
		end, "Event.UI.Button.Left.Press")

		-- Setup the OK button
		
		local btnOK = UI.CreateFrame("RiftButton", "WTGadgetBtnOK", frameOptions)
		window.btnCreate = btnOK
		btnOK:SetText(TXT.Create)
		btnOK:SetPoint("CENTERRIGHT", btnCancel, "CENTERLEFT", 8, 0)
		btnOK:SetEnabled(false)
		btnOK:EventAttach(Event.UI.Button.Left.Press, function(self, h)
			-- Give the creation enough time to run
			WT.WatchdogSleep()			
		
			local gadget = window.selected.gadgetConfig
			local config = {}
			if gadget.GetConfiguration then
				config = gadget.GetConfiguration()
			end
			
			config.show_Solo = chkShow_Solo:GetChecked()
			config.show_Party = chkShow_Party:GetChecked()
			config.show_Raid10 = chkShow_Raid10:GetChecked()
			config.show_Raid20 = chkShow_Raid20:GetChecked()
			config.alpha_IC = sldAlphaIC:GetPosition()
			config.alpha_OOC = sldAlphaOOC:GetPosition()
			
			config.type = gadget.gadgetType
			-- Generate a unique ID for the gadget
			local idx = 1
			while WT.Gadgets[gadget.gadgetType .. idx] do idx = idx + 1 end
			config.id = gadget.gadgetType .. idx
			
			-- WT.Gadget.InitializePropertyConfig(config)
			
			local newGadget = WT.Gadget.Create(config)
			
			WT.Utility.ClearKeyFocus(window)
			window:SetVisible(false)
			
			WT.Gadget.UnlockAll() -- Always unlock gadgets when adding a new one through the dialog, so it can be moved
			 
			return
		end, "Event.UI.Button.Left.Press")
		
		
		-- Now populate the frameTypeList with all available gadget types.
		-- Let's give gadget factories an icon that can be used in this list to make it prettier 

		local wrapperWidth = frameTypeList:GetWidth() - 16

		-- sort the gadgets into name order ready for display
		local sorted = {}
		for gadgetType, config in pairs(WT.GadgetFactories) do table.insert(sorted, config) end
		table.sort(sorted, function(a,b) return a.name < b.name end)

		local numListItems = 0
		
		local function fnAddGadget(idx, config)
			local gadgetType = config.gadgetType
			local name = config.name
			local description = config.description
			local author = config.author
			local version = config.version
			local iconTexAddon = config.iconTexAddon
			local iconTexFile = config.iconTexFile
						
			numListItems = numListItems + 1						
						
			local wrapper = UI.CreateFrame("Texture", "WTGadgetCreate_wrapper_" .. gadgetType, frameTypeList)
			
			listItemCount = listItemCount + 1
			listItems[listItemCount] = wrapper
			
			if listItemCount == 1 then
				wrapper:SetPoint("TOPLEFT", frameScrollAnchor, "TOPLEFT", 8, 8)
			else
				wrapper:SetPoint("TOPLEFT", listItems[listItemCount-1], "BOTTOMLEFT", 0, 8)
			end
			wrapper:SetWidth(250-30)
			wrapper:SetHeight(45)
			
			local icon = UI.CreateFrame("Texture", "WTGadgetCreate_icon_" .. gadgetType, frameTypeList)
			icon:SetTexture(iconTexAddon, iconTexFile)
			icon:SetWidth(32)
			icon:SetHeight(32)
			icon:SetLayer(100)
			icon:SetPoint("TOPLEFT", wrapper, "TOPLEFT", 4 ,4)
			wrapper.icon = icon
			
			local label = UI.CreateFrame("Text", "WTGadgetCreate_label_" .. gadgetType, frameTypeList)
			label:SetText(name)
			label:SetFontSize(18)
			label:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
			label:SetFontColor(1,0.97,0.84,1)
			label:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -2)
			label:SetLayer(100)
			wrapper.label = label

			local label2 = UI.CreateFrame("Text", "WTGadgetCreate_label2_" .. gadgetType, frameTypeList)
			label2:SetText(description)
			label2:SetFontSize(12)
			label2:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
			label2:SetFontColor(1,0.97,0.84,1)
			label2:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
			label2:SetLayer(100)
			wrapper.label2 = label2
			
			wrapper.gadgetConfig = config
			
			wrapper:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function(self, h)
				typeListScrollbar:Nudge(-40)
			end, "Event.UI.Input.Mouse.Wheel.Forward")

			wrapper:EventAttach(Event.UI.Input.Mouse.Wheel.Back, function(self, h)
				typeListScrollbar:Nudge(40)
			end, "Event.UI.Input.Mouse.Wheel.Back")

			wrapper:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
				if (not window.selected) or (window.selected ~= wrapper) then
					wrapper:SetTexture(AddonId, "img/select.png")
					wrapper:SetAlpha(0.6)
				end 
			end, "Event.UI.Input.Mouse.Cursor.In")

			wrapper:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
				if (not window.selected) or (window.selected ~= wrapper) then
					wrapper:SetTexture(AddonId, "img/select.png")
					wrapper:SetAlpha(0)
				end 
			end, "Event.UI.Input.Mouse.Cursor.Out")

			function wrapper.fn_LeftClick()			
				local gadget = wrapper.gadgetConfig
				if (window.selected) then
					window.selected:SetTexture(AddonId, "img/select.png")
					window.selected:SetAlpha(0)
				end 
				wrapper:SetTexture(AddonId, "img/select.png")
				wrapper:SetAlpha(0.8)
				window.selected = wrapper
				-- dump(WT.Gadget.CreateGadgetWindow.selected.gadgetConfig.gadgetType)

				frameOptionsHeading:SetText(gadget.name)
				gadgetDetails:SetText(TXT.Version .. " " .. gadget.version .. ", " .. TXT.writtenBy .. " " .. gadget.author)
				
				if window.dialog then
					window.dialog:SetVisible(false)
					window.dialog = nil
				end
				
				if gadget.ConfigDialog then
					if not gadget._configDialog then
						local container = UI.CreateFrame("Frame", WT.UniqueName("gadgetOptionsContainer"), frameOptions)
						container:SetPoint("TOPLEFT", standardOptions, "BOTTOMLEFT", 0, 8)
						container:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
						container:SetLayer(100)
						container:SetVisible(false)
						gadget.ConfigDialog(container)
						gadget._configDialog = container
					
					end
					window.dialog = gadget._configDialog 
					if window.dialog.Reset then window.dialog.Reset() end
					window.dialog:SetParent(frameOptions)
					window.dialog:SetPoint("TOPLEFT", standardOptions, "BOTTOMLEFT", 0, 8)
					window.dialog:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
					window.dialog:SetVisible(true)
				end
				
				standardOptions:SetVisible(true)
				chkShow_Solo:SetChecked(true)
				chkShow_Party:SetChecked(true)
				chkShow_Raid10:SetChecked(true)
				chkShow_Raid20:SetChecked(true)
				sldAlphaIC:SetPosition(100)
				sldAlphaOOC:SetPosition(100)
				
				btnOK:SetEnabled(true)
			end
			
			wrapper:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
				wrapper.fn_LeftClick()
			end, "Event.UI.Input.Mouse.Left.Click")

			-- there are 48 pixels per entry in the list (total height of wrapper + margin)
			local wrappersHeight = numListItems * 53
			local listHeight = frameTypeList:GetHeight()
			local maxMoveDistance = math.max(0, wrappersHeight - listHeight)
			typeListScrollbar:SetRange(0, maxMoveDistance + 16)		
		end
		
		function buildLoop()
			for idx, config in ipairs(sorted) do
				fnAddGadget(idx, config)
				coroutine.yield()
			end
		end
		
		co = coroutine.create(buildLoop)
		coroutine.resume(co)
		Command.Event.Attach(Event.System.Update.Begin,
			function()
				if coroutine.status(co) ~= "dead" then
					coroutine.resume(co)
				end 
			end, "GadgetCreateWindowCoroutineEvent"
		)
		

	else
		WT.Gadget.CreateGadgetWindow:SetVisible(true)
	end

	local window = WT.Gadget.CreateGadgetWindow
	--window:SetTitle(TXT.CreateGadget)
	window.btnCreate:SetVisible(true) 
	window.btnModify:SetVisible(false) 
	window.frameModifyOverlay:SetVisible(false)
	window.frameTypeList:SetVisible(true)

	listItems[1].fn_LeftClick()

end




function WT.Gadget.ShowModifyUI(id)
	WT.Gadget.LockAll()
	gadgetId = id
	previewId = id
	previewConfig =  wtxGadgets[gadgetId]
	gadgetConfig =  wtxGadgets[gadgetId]
	gadgetFactory = WT.GadgetFactories[gadgetConfig.type:lower()]
	--dump(gadgetFactory)
	
	local gadget = WT.Gadgets[id]

	WT.Gadget.ShowCreationUI()
	local window = WT.Gadget.CreateGadgetWindow
	window.btnCreate:SetVisible(false) 
	window.btnModify:SetVisible(true)
	window.StandardOptions:SetVisible(true)
	WT.Gadget.CreateGadgetWindow.selected.gadgetConfig.gadgetType = gadgetFactory.gadgetType

	window.frameOptionsHeading:SetText(gadgetFactory.name)
	window.gadgetDetails:SetText(TXT.Version .. " " .. gadgetFactory.version .. ", " .. TXT.writtenBy .. " " .. gadgetFactory.author)

	-- Hide any pre-existing dialog frame
	if window.dialog then
		window.dialog:SetVisible(false)
		window.dialog = nil
	end

	-- Apply the current configuration to the dialog
	if gadgetFactory.ConfigDialog then
		if not gadgetFactory._configDialog then
			local container = UI.CreateFrame("Frame", WT.UniqueName("gadgetOptionsContainer"), window.gadgetDetails)
			container:SetPoint("TOPLEFT", window.gadgetDetails, "TOPLEFT", 0, 8)
			container:SetPoint("BOTTOMRIGHT", window.gadgetDetails, "BOTTOMRIGHT", -8, -8)
			container:SetVisible(false)
			gadgetFactory.ConfigDialog(container)
			gadgetFactory._configDialog = container
		end
		window.dialog = gadgetFactory._configDialog 
		
		window.dialog:SetParent(window.gadgetDetails)
		window.dialog:SetPoint("TOPLEFT", window.StandardOptions, "BOTTOMLEFT", 0, 8)
		window.dialog:SetPoint("BOTTOMRIGHT", window.frameOptions, "BOTTOMRIGHT", -8, -8)
		
		local standardOptions = window.StandardOptions
		standardOptions.chkShow_Solo:SetChecked(gadget.showGroup.solo)
		standardOptions.chkShow_Party:SetChecked(gadget.showGroup.party)
		standardOptions.chkShow_Raid10:SetChecked(gadget.showGroup.raid10)
		standardOptions.chkShow_Raid20:SetChecked(gadget.showGroup.raid20)
		standardOptions.sldAlphaOOC:SetPosition(gadget.alpha_OOC)
		standardOptions.sldAlphaIC:SetPosition(gadget.alpha_IC)
		
				
		if gadgetFactory.SetConfiguration then
			gadgetFactory.SetConfiguration(gadgetConfig)
		end

		window.dialog:SetVisible(true)
		window.frameModifyOverlay:SetVisible(true)
		window.frameTypeList:SetVisible(false)
	end
	 
end



