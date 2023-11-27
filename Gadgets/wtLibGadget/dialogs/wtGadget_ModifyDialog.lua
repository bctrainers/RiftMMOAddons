--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2015-07-13T08:46:59Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local gadgetDetails = false
local frameOptions = false
local gadgetFactory = false
local gadgetConfig = false
local gadgetId = false

local ENABLE_RECONFIGURE = true

local function ApplyModification()

	-- Give the creation enough time to run
	WT.WatchdogSleep()

	if gadgetFactory.GetConfiguration then
	 	local config = gadgetFactory.GetConfiguration()
	
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
	end

end


local function OnModifyClick()

	ApplyModification()

	WT.Utility.ClearKeyFocus(WT.Gadget.ModifyGadgetWindow)
	WT.Gadget.ModifyGadgetWindow:SetVisible(false) 

end

local function OnApplyClick()

	ApplyModification()

end


function WT.Gadget.ShowModifyUI(id)

	gadgetId = id
	gadgetConfig =  wtxGadgets[gadgetId]
	gadgetFactory = WT.GadgetFactories[gadgetConfig.type:lower()]

	if not WT.Gadget.ModifyGadgetWindow then
	
	 	WT.Gadget.ShowCreationUI()
	 	WT.Gadget.ModifyGadgetWindow = WT.Gadget.CreateGadgetWindow

		
		local btnOK = UI.CreateFrame("RiftButton", "WTGadgetBtnOK", WT.Gadget.ModifyGadgetWindow.frameOptions)
		btnOK:SetText(TXT.Modify)
		btnOK:SetPoint("CENTERRIGHT", WT.Gadget.ModifyGadgetWindow.btnCancel, "CENTERLEFT", 8, 0)
		btnOK:SetEnabled(true)
		btnOK:EventAttach(Event.UI.Button.Left.Press, function(self, h)
			OnModifyClick()
		end, "Event.UI.Button.Left.Press")


	
		local window  = UI.CreateFrame("SimpleLifeWindow", "WTGadgetModify", WT.Context)
		window:SetPoint("CENTER", UIParent, "CENTER")
		--window:SetController("content")
		window:SetCloseButtonVisible(true)
		window:SetWidth(800)
		window:SetHeight(700) -- added 100 pixels to make room for standard gadget options
		window:SetLayer(1000)
		window:SetTitle(TXT.ModifyGadget)
		WT.Gadget.ModifyGadgetWindow = window
		
		local content = window:GetContent()

		frameOptions = UI.CreateFrame("Frame", "WTGadgetOptions", content)
		frameOptions:SetPoint("TOPLEFT", content, "TOPLEFT", 8, 8)
		frameOptions:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT" ,0, 0)		

		local btnCancel = UI.CreateFrame("RiftButton", "WTGadgetBtnCancel", frameOptions)
		btnCancel:SetText(TXT.Cancel)
		btnCancel:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
		btnCancel.Event.LeftPress = function() window:SetVisible(false); WT.Utility.ClearKeyFocus(window); end
		
		local btnOK = UI.CreateFrame("RiftButton", "WTGadgetBtnOK", frameOptions)
		btnOK:SetText(TXT.Modify)
		btnOK:SetPoint("CENTERRIGHT", btnCancel, "CENTERLEFT", 8, 0)
		btnOK:SetEnabled(true)
		btnOK.Event.LeftPress = OnModifyClick 

		local btnApply = UI.CreateFrame("RiftButton", "WTGadgetBtnApply", frameOptions)
		btnApply:SetText(TXT.Apply)
		btnApply:SetPoint("CENTERRIGHT", btnOK, "CENTERLEFT", 8, 0)
		btnApply:SetEnabled(true)
		btnApply:SetVisible(false)
		btnApply.Event.LeftPress = OnApplyClick 
		
		-- frameOptions will host the dialog provided by the gadget factory assuming one is available

		local frameOptionsHeading = UI.CreateFrame("Text", "WTGadgetOptionsHeading", frameOptions)
		frameOptionsHeading:SetFontSize(18)
		frameOptionsHeading:SetText(TXT.ModifyGadget)
		frameOptionsHeading:SetPoint("TOPLEFT", frameOptions, "TOPLEFT", 8, 8)

		gadgetDetails = UI.CreateFrame("Text", "WTGadgetDetails", frameOptions)
		gadgetDetails:SetFontSize(10)
		gadgetDetails:SetText(TXT.ModifyMessage)
		gadgetDetails:SetPoint("TOPLEFT", frameOptionsHeading, "BOTTOMLEFT", 0, -4)
		gadgetDetails:SetFontColor(0.8, 0.8, 0.8, 1.0)
	else
	
	end
 
	WT.Gadget.ModifyGadgetWindow:SetVisible(true)

	local window = WT.Gadget.ModifyGadgetWindow
	gadgetDetails = window.gadgetDetails
	window:SetTitle(TXT.ModifyGadget)

	window.StandardOptions:SetVisible(true)

	-- Hide any pre-existing dialog frame
	if window.dialog then
		window.dialog:SetVisible(false)
		window.dialog = nil
	end
	
	-- Apply the current configuration to the dialog
	if gadgetFactory.ConfigDialog then
		if not gadgetFactory._configDialog then
			local container = UI.CreateFrame("Frame", WT.UniqueName("gadgetOptionsContainer"), gadgetDetails)
			container:SetPoint("TOPLEFT", gadgetDetails, "TOPLEFT", 0, 8)
			container:SetPoint("BOTTOMRIGHT", gadgetDetails, "BOTTOMRIGHT", -8, -8)
			container:SetVisible(false)
			gadgetFactory.ConfigDialog(container)
			gadgetFactory._configDialog = container
		end
		window.dialog = gadgetFactory._configDialog 
		
		window.dialog:SetParent(gadgetDetails)
		window.dialog:SetPoint("TOPLEFT", window.StandardOptions, "BOTTOMLEFT", 0, 8)
		window.dialog:SetPoint("BOTTOMRIGHT", window.frameOptions, "BOTTOMRIGHT", -8, -8)
		
		if gadgetFactory.SetConfiguration then
			gadgetFactory.SetConfiguration(gadgetConfig)
		end

		window.dialog:SetVisible(true)
	end

end