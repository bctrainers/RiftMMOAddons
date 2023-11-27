--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.8.2
      Project Date (UTC)  : 2015-04-09T12:07:39Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- wtComboPoints provides a simple bar for the player's charge
-- Only useful for mages, and it only exists because I didn't want to add a charge bar to the standard frame

local deferSetup = {}
local calling = nil

local function OnComboSingle(uf, value)
	 
	uf.Elements["imgCombo01"]:SetVisible(false) 
	uf.Elements["imgCombo02"]:SetVisible(false) 
	uf.Elements["imgCombo03"]:SetVisible(false) 
	uf.Elements["imgCombo04"]:SetVisible(false) 
	uf.Elements["imgCombo05"]:SetVisible(false)
	
	if not value then return end
	
	if value >= 1 then uf.Elements["imgCombo01"]:SetVisible(true) end
	if value >= 2 then uf.Elements["imgCombo02"]:SetVisible(true) end
	if value >= 3 then uf.Elements["imgCombo03"]:SetVisible(true) end
	if value >= 4 then uf.Elements["imgCombo04"]:SetVisible(true) end
	if value >= 5 then uf.Elements["imgCombo05"]:SetVisible(true) end
	 
end

local function Setup(unitFrame, configuration)

	local img = nil
	local addon = AddonId
	 
	local isSingle = false
	 
	if calling == "rogue" then 
		img = "img/wtComboBlue.png"
	else
		img = "img/wtComboRed.png"
	end
	
	if configuration.showTxt == false or nil then
	if configuration.texture then
		local media = Library.Media.GetTexture(configuration.texture)
		if media then
			img = media.filename
			addon = media.addonId
			
			if media.tags["combo_single"] then
				isSingle = true
			end
			
		end
	end
	
	if not isSingle then
	
		unitFrame:CreateElement(
		{
			id="imgCombo", type="ImageSet", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
				{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
			},	
			indexBinding="comboIndex", rows=5, cols=1,
			visibilityBinding="comboIndex",		
			texAddon=addon, texFile=img,
		});
	
	else
	
		-- Need to handle the single icon method differently
	
		unitFrame:CreateElement(
		{
			id="imgCombo01", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.0, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
			},
			media = configuration.texture,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo02", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.2, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.4, 1.0} },
			},
			media = configuration.texture,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo03", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.4, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.6, 1.0} },
			},
			media = configuration.texture,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo04", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.8, 1.0} },
			},
			media = configuration.texture,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo05", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.8, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={1.0, 1.0} },
			},
			media = configuration.texture,
		})
	
		unitFrame:CreateBinding("combo", unitFrame, OnComboSingle, nil)
	
	end

	else
			unitFrame:CreateElement(
		{
				id="labelCombo", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0}},
				visibilityBinding="visibilityCombo",
				text="{combo}", default="", outline=true, fontSize=configuration.fontSize or 25,
				colorBinding="ComboColor",
				font = configuration.font or "ArmWrestler",
		});
	end
	
	unitFrame:ApplyBindings()
	
end


local function Create(configuration)

	calling = Inspect.Unit.Detail("player").calling 

	local comboPoints = WT.UnitFrame:Create("player")
	comboPoints:SetWidth(193)
	comboPoints:SetHeight(36)

	if calling then
		Setup(comboPoints, configuration)
	else
		table.insert(deferSetup, { unitFrame = comboPoints, configuration = configuration })
	end

	return comboPoints, { resizable = { 50, 10, 800, 500 } }
end

local dialog = false

local function ConfigDialog(container)	

	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	
	dialog = WT.Dialog(container)
		:Label("The Combo Points gadget displays current combo (Rogue) or attack (Warrior) points for the player.")
		:Checkbox("showTxt", "Show combo point by text", false)
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 25, true)	
		:ImgSelect("texture", "Texture", "wtComboBlue", "combo")

end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("ComboPoints",
	{
		name=TXT.gadgetComboPoints_name,
		description=TXT.gadgetComboPoints_desc,
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtComboPoints.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})


WT.Unit.CreateVirtualProperty("comboIndex", { "combo", "comboUnit" },
	function(unit)
		if not unit.combo or unit.combo == 0 then
			return nil
		else
			return unit.combo - 1
		end
	end)
	
table.insert(Library.LibUnitChange.Register("player.target"), 
{ 
	function(unitId) 
		if not WT.Player then return end
		if calling ~= "rogue_xx" then return end
		if unitId and unitId == WT.Player.comboUnit and WT.Player.combo and WT.Player.combo > 0 then 
			WT.Player.comboIndex = WT.Player.combo - 1
		else
			WT.Player.comboIndex = nil
		end 
	end,  AddonId, AddonId .. "_ComboUnitChange" 
})

local function OnPlayerAvailable()
	calling = Inspect.Unit.Detail("player").calling
	for idx, entry in ipairs(deferSetup) do
		Setup(entry.unitFrame, entry.configuration)
	end
end

Command.Event.Attach(WT.Event.PlayerAvailable, OnPlayerAvailable, "ComboPointsGadget_OnPlayerAvailable")	
