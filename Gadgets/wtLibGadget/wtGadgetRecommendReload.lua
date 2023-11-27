--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-09-14T09:22:53Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- A gadget can call this function to recommend to the user that they reload the UI (/reloadui)
-- This could be called every time a gadget is deleted, for example
-- It will display a small window somewhere not *too* obtrusive, with a button to reload the UI
function WT.Gadget.RecommendReload()

	if not WT.Gadget.ReloadDialog then
		local dialog = UI.CreateFrame("Texture", "WTReloadDialog", WT.Context)
		dialog:SetLayer(9000)
		dialog:SetTexture(AddonId, "img/wtGoldFrame.png")
		dialog:SetPoint("TOPCENTER", UIParent, "TOPCENTER", 0, 25)
		dialog:SetSecureMode("restricted")
		
		local heading = UI.CreateFrame("Text", "WTReloadDialog", dialog)
		heading:SetFontSize(17)
		heading:SetText(TXT.ReloadInterface)
		heading:SetPoint("TOPCENTER", dialog, "TOPCENTER", 0, 17)
		
		local detail =  UI.CreateFrame("Text", "WTReloadDialog", dialog)
		detail:SetFontSize(12)
		detail:SetWordwrap(true)
		detail:SetText(TXT.ReloadUIMessage)
		detail:SetPoint("TOP", heading, "BOTTOM")
		detail:SetPoint("LEFT", dialog, "LEFT", 16, nil)
		detail:SetPoint("RIGHT", dialog, "RIGHT", -16, nil)
		
		local btnReload = UI.CreateFrame("RiftButton", "WTReloadDialog", dialog)
		btnReload:SetText(TXT.ReloadUI)
		btnReload:SetPoint("TOPCENTER", detail, "BOTTOMCENTER", 0, 3) 
		btnReload:SetSecureMode("restricted")
		btnReload:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "reloadui")

		WT.Gadget.ReloadDialog = dialog
	end

	-- Fade the dialog in
	WT.FadeIn(WT.Gadget.ReloadDialog, 0.5)

end