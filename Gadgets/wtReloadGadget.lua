--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-09-16T13:46:30Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- Provides a simple button that reloads the UI when clicked

local function Create(configuration)
	local control = UI.CreateFrame("RiftButton", WT.UniqueName("wtRELOAD"), WT.Context)
	control:SetText(TXT.ReloadUI)
	control:SetSecureMode("restricted")
	control:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "reloadui")
	return control
end


local dialog = false

local function ConfigDialog(container)
	dialog = WT.Dialog(container)
		:Label("The Reload UI button is useful for addon development. You probably don't want to use this if you're not a developer.")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("ReloadUI",
{
	name=TXT.gadgetReloadUI_name,
	description=TXT.gadgetReloadUI_desc,
	author="Wildtide",
	version="1.0.0",
	iconTexAddon=AddonId,
	iconTexFile="img/wtReload.png",
	["Create"] = Create,
	["ConfigDialog"] = ConfigDialog,
	["GetConfiguration"] = GetConfiguration, 
	["SetConfiguration"] = SetConfiguration, 
})
