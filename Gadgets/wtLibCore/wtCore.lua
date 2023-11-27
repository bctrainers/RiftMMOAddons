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

--[[ 
	wtCore
	wtLibrary Core Functionality
	
	Namespaces: 
		WT 
		WT.Event
		WT.Event.Trigger

	Public Events:
		Event.wtLibrary.Tick

	Public Properties:
		WT.FPS <double>
		WT.FrameIndex <integer>
		WT.FrameDeltaTime <double>
		WT.Player <WT.Unit>
		WT.AddonStartTime <double>
		WT.AddonUpTime <double>
--]]

-- Generate the root context for UI elements, and secure it
WT.Context = UI.CreateContext("wtContext")
WT.Context:SetSecureMode("restricted")

-- Hold some standard Frame statistics
WT.FPS = 0
WT.FrameIndex = 0
WT.FrameDeltaTime = 0
WT.AddonStartTime = Inspect.Time.Frame()
WT.AddonUpTime = 0

-- Switch DEBUG mode on
WT.DEBUG = true

-- Events ------------------------------------------------------------------------------
WT.Event.Trigger.Tick, WT.Event.Tick = Utility.Event.Create(AddonId, "Tick")
----------------------------------------------------------------------------------------

-- Private Data
local FPSTimer = 0
local FPSFrameCount = 0
local LastFrameTime = nil


-- Per frame Tick event
-- Calculates FPS every second, and fires off the tick event. 
function WT.Tick()
	FPSTimer = FPSTimer + WT.FrameDeltaTime
	FPSFrameCount = FPSFrameCount + 1
	if (FPSTimer > 1) then
		WT.FPS = FPSFrameCount / FPSTimer
		FPSFrameCount = 0
		FPSTimer = 0 
	end
	WT.Event.Trigger.Tick(WT.FrameDeltaTime, WT.FrameIndex)
	
	-- Process any currently active faders
	for frame, fader in pairs(WT.Faders) do
		fader.elapsed = fader.elapsed + WT.FrameDeltaTime
		local delta = 1.0
		if fader.duration ~= 0 then
			delta = fader.elapsed / fader.duration
		end
		if delta >= 1.0 then
			-- fader has completed, shut it down, and default the alpha to 1.0, even on fade out (in case of a non-fade SetVisible)
			frame:SetAlpha(1.0)
			if fader.direction == "out" then
				frame:SetVisible(false)
			end
			WT.Faders[frame] = nil
		else
			if fader.direction == "out" then
				frame:SetAlpha(1.0 - delta)
			else
				frame:SetAlpha(delta)
			end
		end
	end
	
end


-- Event Handler: Event.System.Update.Begin
function WT.OnSystemUpdateBegin()
	local currFrame = Inspect.Time.Frame()
	local lastFrame = LastFrameTime or currFrame	
	WT.FrameIndex = WT.FrameIndex + 1
	WT.FrameDeltaTime = currFrame - lastFrame
	WT.AddonUpTime = currFrame - WT.AddonStartTime
	WT.Tick()
	LastFrameTime = currFrame
end


-- Event Handler: Event.Addon.Load.End
function WT.OnAddonLoadEnd(hEvent, addonId)
	WT.Log.Info("Addon Loaded: " .. addonId or "<Unnamed>")
end


-- All addons have been executed
-- Runs any functions in the WT.Initializers table. Allows dependent WT addons to defer initialization until everything has loaded 
function WT.OnAddonStartupEnd(hEvent)
	WT.Log.Info("All addons have started up")

	-- Run any initializers
	WT.WatchdogSleep()
	for idx,init in ipairs(WT.Initializers) do
		WT.Log.Info("Running initializer...") 
		init()
	end		
	if WT.DEBUG then
		if WT.Sandpit then
			WT.Log.Info("Sandpit found") 
			WT.Sandpit() 
		end
	end
	initializersRun = true

end


-- Standard command handler for /wt commands
function WT.OnSlashCommand(hEvent, cmd)
	local words = {}
	for word in string.gmatch(cmd, "[^%s]+") do table.insert(words, word) end
	local numWords = table.getn(words)
	if numWords > 0 then
		local command = string.lower(words[1])
		local args = {}
		for i = 2, numWords do table.insert(args, words[i]) end
		WT.Log.Debug("Command received: " .. command .. " with " .. table.getn(args) .. " args")
		if WT.Command[command] then
			WT.Command[command](args)
		end
	end
end


local function dumpFrame(frame, indent)
	local txt = ""
	for i=0,indent do txt = txt .. "  " end
	print(txt .. frame:GetName() .. " <" .. frame:GetType() .. ">")
	for child in pairs(frame:GetChildren()) do
		dumpFrame(child, indent+1)
	end
end

function WT.Command.dumpframes()
	dumpFrame(WT.Context, 0)
end


-- Command /wt cpu [detail]
-- Displays detailed CPU statistics for all addons
function WT.Command.cpu(options)
	for addonId, cpuData in pairs(Inspect.Addon.Cpu()) do
		if cpuData then
			if options[1] == "detail" then
				print("-- " .. TXT.CPUUsage .. " " .. addonId .. " ------------------------------------")
			end
			local total = 0
			for k,v in pairs(cpuData) do
				if options[1] == "detail" then
					print(string.format("  %s = %.3f", k, v * 100))
				end
				total = total + v
			end
			print(TXT.TOTAL .. " " .. addonId .. " " .. string.format("%.3f", total * 100))
		end
	end
end


-- Core utility mechanism for generating unique keys
function WT.UniqueName(prefix, suffix)
	local count = WT.NameCounters[prefix] or 0
	count = count + 1
	WT.NameCounters[prefix] = count
	local name = prefix .. "_" .. count
	if suffix then name = name .. "_" .. suffix end
	return name
end


function WT.OnSavedVariablesLoaded(hEvent, addonId)
end


function WT.FadeIn(frame, duration)
	WT.Faders[frame] = { ["duration"] = duration, direction="in", elapsed=0.0 }
	frame:SetAlpha(0.0)
	frame:SetVisible(true)
end

function WT.FadeOut(frame, duration)
	WT.Faders[frame] = { ["duration"] = duration, direction="out", elapsed=0.0 }
	frame:SetAlpha(1.0)
	frame:SetVisible(true)
end

function WT.WatchdogSleep()
	if not Inspect.System.Secure() then
		Command.System.Watchdog.Quiet()
	end
end

function WT.RegisterInitializer(init)
	table.insert(WT.Initializers, init)
end


-- ADDON INITIALISATION
-------------------------------------------------------------------------------
Command.Event.Attach(Event.System.Update.Begin, WT.OnSystemUpdateBegin, "OnSystemUpdateBegin")
Command.Event.Attach(Event.Addon.Load.End, WT.OnAddonLoadEnd, "OnAddonLoadEnd")
Command.Event.Attach(Event.Addon.Startup.End, WT.OnAddonStartupEnd, "OnAddonStartupEnd")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, WT.OnSavedVariablesLoaded, "OnAddonVariablesLoaded")
Command.Event.Attach(Command.Slash.Register("wt"), WT.OnSlashCommand, "OnSlashCommand")
