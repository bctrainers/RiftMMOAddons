--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-01-04T22:17:01Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local theme = {} 
WT.Themes["classic"] = theme

function theme.ApplyOverlayTheme(frame, createOptions)

	local handle = frame.gadgetOverlay.handle
	local resizer = frame.gadgetOverlay.resizer
	local box = frame.gadgetOverlay.box

	box:SetBackgroundColor(1,1,1,0.2)

	handle:SetTexture(AddonId, "themes/classic/GadgetHandle.png")
	handle.NormalMode = function(handle) handle:SetTexture(AddonId, "themes/classic/GadgetHandle.png") end
	handle.AlignMode = function(handle) handle:SetTexture(AddonId, "themes/classic/GadgetHandle_Lit.png") end
	handle:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, -12)
	
	if resizer then
		resizer:SetTexture(AddonId, "themes/classic/GadgetResizeHandle.png")
		resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, 2)
	end

	if createOptions.caption then
		local uiCaption = UI.CreateFrame("Text", "wtCaption", mvHandle)
		uiCaption:SetText(createOptions.caption)
		uiCaption:SetPoint("CENTERLEFT", handle, "CENTERRIGHT")
		uiCaption:SetFontSize(10)
	end
			
end
