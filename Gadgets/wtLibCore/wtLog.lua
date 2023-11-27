--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-05-20T07:13:55Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

-- Logging
-- Nothing clever, just allows conditional output of messages based on which severities are enabled below
-- Changed to a log level type approach - "/wt log level 5" etc

WT.Log = {}
WT.Log.Level = 0

local wtLogConsoleId = nil

local needScan = true

local function ScanForConsole(hEvent)
	if not needScan then return end
	local list = Inspect.Console.List()
	if list then
		local consoles = Inspect.Console.Detail(list)
		for id, console in pairs(consoles) do
			if console.name == "wtLog" then
				wtLogConsoleId = console.id
			end
		end
		needScan = false
	end		
end

Command.Event.Attach(Event.Unit.Availability.Full, ScanForConsole, "OnAddonStartupEnd")

Command.Event.Attach(Event.Addon.SavedVariables.Load.End,
	function(hEvent, addonId)
		if addonId == AddonId then
			WT.Log.Level = wtxLogLevel or 2
		end
	end,
	"LoadSavedVariables"
)

Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin,
	function(hEvent, addonId)
		if addonId == AddonId then
			wtxLogLevel = WT.Log.Level
		end
	end,
	"SaveSavedVariables"
)

local logColours = {
	VRB = "#888888",
	DBG = "#cccccc",
	INF = "#aaccee",
	WRN = "#ffff00",
	ERR = "#ff0000",
}

-- Write a log entry
-- This just prints the message to the chat console if the relevant severity has been enabled
-- Custom severities can be added by defining WT.Log.<Severity>
local function LogWrite(severity, message)

	if needScan then
		ScanForConsole()
	end

	local colour = logColours[severity] or "#ffffff"
	Command.Console.Display(
		wtLogConsoleId or "general", 
		true,
		string.format("<font color='%s'><b>%s</b>: %s</font>", colour, severity, message),
		true
	)
end

-- Provide explicit calls for the built in severities (for cleaner code)

function WT.Log.Verbose(msg)
	if WT.Log.Level >= 5 then LogWrite("VRB", msg) end
end

function WT.Log.Debug(msg)
	if WT.Log.Level >= 4 then LogWrite("DBG", msg) end
end

function WT.Log.Info(msg)
	if WT.Log.Level >= 3 then LogWrite("INF", msg) end
end

function WT.Log.Warning(msg)
	if WT.Log.Level >= 2 then LogWrite("WRN", msg) end
end

function WT.Log.Error(msg)
	if WT.Log.Level >= 1 then LogWrite("ERR", msg) end
end


function WT.Command.log(args)

	local numArgs = table.getn(args)

	if numArgs == 2 and string.lower(args[1]) == "level" then
		local num =  tonumber(args[2])
		if not num or num > 5 or num < 0 then
			print("Invalid log level specified, must be a number between 0 and 5")
			return
		end
		WT.Log.Level = math.floor(num)
	end

	local level = "None"
	if WT.Log.Level == 1 then level = "Error" end
	if WT.Log.Level == 2 then level = "Warning" end
	if WT.Log.Level == 3 then level = "Information" end
	if WT.Log.Level == 4 then level = "Debug" end
	if WT.Log.Level >= 5 then level = "Verbose" end
	print(string.format("WT Log Level %d - %s", WT.Log.Level, level))

end

