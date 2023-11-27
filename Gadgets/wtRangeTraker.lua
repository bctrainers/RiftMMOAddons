--[[
                                G A D G E T S
      -----------------------------------------------------------------
                           lifeismystery@yandex.ru
                           lifeismystery: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.10.11-beta
      Project Date (UTC)  : 2015-12-06T0:0:0Z
      File Modified (UTC) : 2015-12-06T0:0:0Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate
local txtNames = {}


callingColors = { warrior = { 1.0, 0.15, 0.15 }, rogue = { 1.0, 0.86, 0.04 }, mage = { 0.8, 0.36, 1.0 }, cleric = { 0.47, 0.94, 0.0 }, primalist = { 0.29, 0.83, 0.98 } }

-- Provides a simple button that reloads the UI when clicked

local function Create(configuration)
	
	local radarFrame = UI.CreateFrame("Frame", "RangeCheckRadar", WT.Context)
	radarFrame:SetHeight(128)
	radarFrame:SetWidth(128)
	
	radarFrame.fontEntry = Library.Media.GetFont(configuration.font)
	radarFrame.fontSize = configuration.fontSize or 14
	radarFrame.rangeDistanse = configuration.rangeDistanse or 5
	radarFrame.totalPlayers = configuration.totalPlayers or 20
			
	local lastName = radarFrame
	for i = 1,radarFrame.totalPlayers do
		local txtName = UI.CreateFrame("Text", "txtName", radarFrame)
		txtName:SetText("")
		txtName:SetEffectGlow({ strength = 3 })
		txtName:SetFontSize(radarFrame.fontSize or 14)
		txtName:SetFont(radarFrame.fontEntry.addonId, radarFrame.fontEntry.filename)
		txtName:SetPoint("TOPLEFT", lastName, "TOPLEFT", 0, 14)
		txtNames[i] = txtName
		lastName = txtNames[i]
	end		
	
	local lr=0
	
function calcRange (p, t)
	 if p and t then 
	    local dx, dy, dz = (p.coordX or 0) - (t.coordX or 0), (p.coordY or 0) - (t.coordY or 0), (p.coordZ or 0) - (t.coordZ or 0)
	 return math.max(0, math.sqrt(dx * dx + dy * dy + dz * dz))
	 end
	 return -1
end



	local function l(player)
		local pplInRange = {}
		for k, v in ipairs(Inspect.Unit.Detail({"group01", "group02", "group03", "group04", "group05", "group06", "group07", "group08", "group09", "group10", "group11", "group12", "group13", "group14", "group15", "group16", "group17", "group18", "group19", "group20"})) do 
		 local range = calcRange(player, v)
		 if range >= 0 and range < radarFrame.rangeDistanse and v.name ~= player.name then
		  table.insert(pplInRange, { name = v.name, calling = v.calling })
		  else
				
		 end
		end
		return pplInRange
	end

	local  function r()
		if(Inspect.Time.Frame()-lr>0.2) then 

			pplInRange = l(Inspect.Unit.Detail('player'))
			--for k,v in pairs(l(Inspect.Unit.Detail('player'))) do
			for i = 1, radarFrame.totalPlayers do
				 txtNames[i]:SetVisible(pplInRange[i] ~= nil)
				 if pplInRange[i] then
				  local color = callingColors[pplInRange[i].calling] or { 1, 1, 1 }
				  txtNames[i]:SetFontColor(color[1], color[2], color[3], 1)
				  txtNames[i]:SetText(pplInRange[i].name)
				end
			end
			lr=Inspect.Time.Frame()
		end 
	end 
	
	table.insert(Event.System.Update.Begin,{r,'Rift','r'})

	return radarFrame, { resizable={50, 500, 1000, 1000} }
end


local dialog = false

local function ConfigDialog(container)
	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	
	dialog = WT.Dialog(container)
		:Label("RangeTraker")
		:Select("font", "Font", "#Default", lfont, true)
		:SliderRange("fontSize", "Font Size", 5, 50, 14, true)
		:SliderRange("rangeDistanse", "Range Distance", 5, 20, 5, true)
		:SliderRange("totalPlayers", "Show total players", 1, 20, 20, true)
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("RangeTraker",
{
	name="RangeTraker",
	description="RangeTraker",
	author="Nevponya,lifeismystery, Fallenagel",
	version="1.0.0",
	iconTexAddon=AddonId,
	iconTexFile="img/wtReload.png",
	["Create"] = Create,
	["ConfigDialog"] = ConfigDialog,
	["GetConfiguration"] = GetConfiguration, 
	["SetConfiguration"] = SetConfiguration, 
})
