local addonInfo, private = ...

-- Default settings
local RH_settings = {
	bx=UIParent:GetWidth()/2,
	by=UIParent:GetHeight()/2,
	ba=true,
	wx=UIParent:GetWidth()/2,
	wy=UIParent:GetHeight()/2,
	size=1,
}

-- Main map window, tabs
RH_window = private.InitWindow(RH_settings)
RH_button = private.InitButton(RH_settings, RH_window)

RH_map = private.InitMapTab(RH_settings, RH_window)
RH_munch = private.InitMunchTab(RH_settings, RH_window)

RH_window.AddTab(RH_map)
RH_window.AddTab(RH_munch)

local function RH_Place()
	RH_button.frame:SetPoint(0,0, UIParent, 0,0, RH_settings.bx, RH_settings.by)
	
	RH_window.frame:SetPoint(0,0, UIParent, 0,0, RH_settings.wx, RH_settings.wy)
	RH_window.frame:SetWidth(RH_settings.size*500)
	RH_window.frame:SetHeight(RH_settings.size*500)
end

-- Slash command
local function OnSlashCommand(h, arg)
	if arg == nil or arg == "" then 
		print("/rathunter {scale} - changes the size of main window. {scale} is a number between 0.5 and 2")
		print("/rathunter munch - reset the munch maze pellets")
	elseif tonumber(arg) then 
		local size_arg = tonumber(arg)
		size_arg = math.min(math.max(0.5, size_arg), 2)
		RH_settings.size = size_arg
		RH_Place()
	elseif arg == "munch" then
		RH_munch.ResetTiles()
	else 
		print("Uncexpected input. Use the command \"/rathunter\" to see available commands.") 
	end
end

-- Global things
local function TableMerge(a,b) 
	for k,v in pairs(b) do
		a[k]=v
	end
end

local function OnVariableSaveBegin(h, idef)
	if idef == "RatHunter" then
		TableMerge(RHSettings,RH_settings) 
	end
end

local function OnVariableLoadEnd(h, idef)
	if idef == "RatHunter" then
		if RHSettings==nil then 
			RHSettings = RH_settings 
		else 
			TableMerge(RH_settings,RHSettings) 
		end
		RH_Place()
	end
end

Command.Event.Attach(Command.Slash.Register("rathunter"), OnSlashCommand, "RH_OnSlashCommand")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, OnVariableSaveBegin, "Saving global settings.")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, OnVariableLoadEnd, "Saved variable import, then window placement.")

-- Welcome message
print("Rat Hunter successifully loaded.")
print("Use the command \"/rathunter\" to see available commands.")

