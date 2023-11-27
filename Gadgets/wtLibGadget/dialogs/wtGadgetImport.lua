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

local window = nil

local function OnWindowClosed()
	WT.Utility.ClearKeyFocus(window)
end

function WT.Gadget.ShowImportDialog()

	if (Inspect.System.Secure()) then
		print("Cannot import settings while in combat")
		return
	end

	if not window then
			
		window  = UI.CreateFrame("Texture", "WTGadgetCreate", WT.Context)
		if wtxOptions.BackgroundTex == "BackgroundTexTrans" then		
			window:SetTexture(AddonId, "img/menu4.png")
		else
			window:SetTexture(AddonId, "img/menu3.png")
		end	
		window:SetBackgroundColor(0.07,0.07,0.07,0)		
		window:SetPoint("CENTER", UIParent, "CENTER")
		window:SetWidth(400)
		--window:SetHeight(650)
		window:SetLayer(11000)
		window:SetAlpha(0.98)
		window:SetSecureMode("restricted")
		
	   Library.LibDraggable.draggify(window, nil)	
		
		local closeButton = UI.CreateFrame("Texture", window:GetName().."CloseButton", window)
		closeButton:SetTexture(AddonId, "img/Ignore.png" )
		closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 60)
		closeButton:SetWidth(25)
		closeButton:SetHeight(25)
		
		function closeButton.fnc1_LeftClick()	
			window:SetVisible(false)
				if window.Event.Close then
				 window.Event.Close(window)
				end		
		end			
		closeButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
				closeButton.fnc1_LeftClick()
			end, "Event.UI.Input.Mouse.Left.Click")
			
		local content = window
		
		local contentImportSettings = UI.CreateFrame("Frame", "contentImportSettings", window)
		contentImportSettings:SetAllPoints(content)
		contentImportSettings:SetSecureMode("restricted")
		
		local labImport = UI.CreateFrame("Texture", "txtImportHeader", content)
		labImport:SetPoint("TOPLEFT", content, "TOPLEFT", 16, 8)
		labImport:SetTexture(AddonId, "img/Import Layout.png")
		labImport:SetLayer(10000)

		local lastButton = nil
		local maxWidth = 0
		local charList = {}
	
		if wtxLayouts then
			for charId in pairs(wtxLayouts) do table.insert(charList, charId) end
			table.sort(charList)
		end
		
		for idx, charId in ipairs(charList) do
		
			local btnImport = UI.CreateFrame("Texture", "btnFrame", contentImportSettings)
			btnImport:SetWidth(220)
			btnImport:SetHeight(30)
			btnImport:SetTexture(AddonId, "img/select2.png")
			btnImport:SetSecureMode("restricted")
			local w = btnImport:GetWidth()
			if w > maxWidth then maxWidth = w end 
		
			if lastButton then
				btnImport:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 4)
			else
				btnImport:SetPoint("TOPLEFT", labImport, "BOTTOMLEFT", 20, 20)
			end

			local fillImport = UI.CreateFrame("Texture", "btnFrame", contentImportSettings)
			fillImport:SetPoint("TOPLEFT", btnImport, "TOPLEFT", 2, 2)
			fillImport:SetPoint("BOTTOMRIGHT", btnImport, "BOTTOMRIGHT", -2, -2)
			
			local txtImport = UI.CreateFrame("Text", "txtFrame", btnImport)
			txtImport:SetText(charId)
			txtImport:SetFontSize(14)
			txtImport:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
			txtImport:SetFontColor(1,0.97,0.84,1)
			--txtImport:SetFont(AddonId, "blank-Bold")
			txtImport:SetPoint("CENTER", btnImport, "CENTER")

			btnImport:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "gadget import " .. charId .. "\nreloadui")
			btnImport:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
				fillImport:SetTexture(AddonId, "img/select.png")
				fillImport:SetAlpha(0.6)
			end, "Event.UI.Input.Mouse.Cursor.In")
			btnImport:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
					fillImport:SetTexture(AddonId, "img/select.png")
					fillImport:SetAlpha(0)
			end, "Event.UI.Input.Mouse.Cursor.Out")
			
			fillImport:SetTexture(AddonId, "img/select.png")
			fillImport:SetAlpha(0)
			lastButton = btnImport
	
		end		
		
	local top = window:GetTop()
	local bottom = lastButton:GetBottom() + 60 
	window:SetHeight(bottom-top)
	window:SetWidth(maxWidth + 70)
		
	end
	
	window:SetVisible(true)
end
