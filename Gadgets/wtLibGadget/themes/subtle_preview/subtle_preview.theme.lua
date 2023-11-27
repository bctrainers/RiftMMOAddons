--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-06-11T06:19:15Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local theme = {} 
WT.Themes["subtle_preview"] = theme

function theme.ApplyOverlayTheme(frame, createOptions)

	local handle = frame.gadgetOverlay.handle
	local resizer = frame.gadgetOverlay.resizer
	local box = frame.gadgetOverlay.box

	box:SetBackgroundColor(1,1,1,0.2)
	
	--handle:SetTexture(AddonId, "themes/subtle_preview/GadgetHandle.png")
	--handle.NormalMode = function(handle) handle:SetTexture(AddonId, "themes/subtle_preview/GadgetHandle.png") end
	--handle.AlignMode = function(handle) handle:SetTexture(AddonId, "themes/subtle_preview/GadgetHandle_Lit.png") end
	--handle:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, -4)
	handle:SetPoint("TOPLEFT", frame, "TOPLEFT")
	handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	
	if resizer then
		resizer:SetTexture(AddonId, "themes/subtle_preview/GadgetCornerBR_Resize.png")
		resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, 4)		
	else
		local cornerBR = UI.CreateFrame("Texture", "GadgetCornerBR", handle)
		cornerBR:SetTexture(AddonId, "themes/subtle_preview/GadgetCornerBR.png")
		cornerBR:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, 4)
	end

	local cornerTL = UI.CreateFrame("Texture", "GadgetCornerTL", handle)
	cornerTL:SetTexture(AddonId, "themes/subtle_preview/GadgetCornerTL.png")
	cornerTL:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, -4)
	
	local cornerTR = UI.CreateFrame("Texture", "GadgetCornerTR", handle)
	cornerTR:SetTexture(AddonId, "themes/subtle_preview/GadgetCornerTR.png")
	cornerTR:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 4, -4)

	local cornerBL = UI.CreateFrame("Texture", "GadgetCornerBL", handle)
	cornerBL:SetTexture(AddonId, "themes/subtle_preview/GadgetCornerBL.png")
	cornerBL:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -4, 4)
	
	if createOptions.caption then
		local uiCaption = UI.CreateFrame("Text", "wtCaption", handle)
		uiCaption:SetText(createOptions.caption)
		uiCaption:SetPoint("CENTERLEFT", handle, "CENTERRIGHT")
		uiCaption:SetFontSize(10)
	end
			
end
