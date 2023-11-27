--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.6
      Project Date (UTC)  : 2013-11-03T06:56:55Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- wtFPSGadget creates a really simple "FPS" gadget for displaying Frames Per Second

local gadgetIndex = 0
local fpsGadgets = {}

local function Create(configuration)

	local fpsHeight = 52
    local fpsWidth = 150
	
	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtFPS"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(52)
		
	if configuration.showBackground then
		wrapper:SetBackgroundColor(0,0,0,0.4)
	end 
	
	
	local fpsHeading = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	fpsHeading:SetText("FRAMES PER SECOND")
	fpsHeading:SetFontSize(10)
	
	if not configuration.showTitle then
		fpsHeading:SetHeight(0) 
		fpsHeight = fpsHeight - 17
		fpsWidth = fpsWidth - 100
	end

	local fpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	fpsFrame:SetText("")
	fpsFrame:SetFontSize(24)
	fpsFrame:SetEffectGlow({ strength = 3 })
	fpsFrame.currText = ""

	fpsHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	fpsFrame:SetPoint("TOPCENTER", fpsHeading, "BOTTOMCENTER", 0, -5)

	if not configuration.smallFont then
         fpsFrame:SetFontSize(24)
	else
		 fpsFrame:SetFontSize(16)
		fpsHeight = fpsHeight - 10
		fpsWidth = fpsWidth - 15
	end
	
	if not configuration.changefontColor then
         fpsFrame:SetFontColor(1.0, 1.0, 1.0, 1.0)
		 fpsHeading:SetFontColor(1.0, 1.0, 1.0, 1.0)
		 else
		 	local fontColor = configuration.fontColor 
		 fpsFrame:SetFontColor(fontColor[1],fontColor[2],fontColor[3],fontColor[4])
		 fpsHeading:SetFontColor(fontColor[1],fontColor[2],fontColor[3],fontColor[4])
	end
	
	wrapper:SetHeight(fpsHeight)
	wrapper:SetWidth(fpsWidth)
	
	table.insert(fpsGadgets, fpsFrame)
	return wrapper, { resizable={150, 52, 150, 70} }
	
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("This gadget displays the current number of Frames Per Second for the Rift client, updated once per second.")
		:Checkbox("showTitle", TXT.ShowTitle, true)
		:Checkbox("showBackground", TXT.ShowBackground, true)
		:Checkbox("smallFont", TXT.smallFont, false)
		:Checkbox("changefontColor", "Change FPS font color", false)	
		:ColorPicker("fontColor", "FPS font color", 1.0, 1.0, 1.0, 1.0)
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("FPS",
	{
		name=TXT.gadgetFPS_name,
		description=TXT.gadgetFPS_desc,
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtFPS.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function OnTick(hEvent, frameDeltaTime, frameIndex)
	local fpsText = tostring(math.ceil(WT.FPS))
	for idx, gadget in ipairs(fpsGadgets) do
		if gadget.currText ~= fpsText then
			gadget:SetText(fpsText)
			gadget.currText = fpsText
		end
	end
end

Command.Event.Attach(WT.Event.Tick, OnTick, AddonId .. "_OnTick" )