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
if  calling == "rogue" or calling == "warrior" then
	uf.Elements["imgCombo01"]:SetVisible(false) 
	uf.Elements["imgCombo02"]:SetVisible(false) 
	uf.Elements["imgCombo03"]:SetVisible(false) 
	uf.Elements["imgCombo04"]:SetVisible(false) 
	uf.Elements["imgCombo05"]:SetVisible(false)
	if calling == "rogue" then 
	uf.Elements["imgCombo001"]:SetVisible(true) 
	uf.Elements["imgCombo002"]:SetVisible(true) 
	uf.Elements["imgCombo003"]:SetVisible(true) 
	uf.Elements["imgCombo004"]:SetVisible(true) 
	uf.Elements["imgCombo005"]:SetVisible(true)
	elseif calling == "warrior" then 
	uf.Elements["imgCombo001"]:SetVisible(true) 
	uf.Elements["imgCombo002"]:SetVisible(true) 
	uf.Elements["imgCombo003"]:SetVisible(true)
	uf.Elements["imgCombo004"]:SetVisible(false) 
	uf.Elements["imgCombo005"]:SetVisible(false)
	end
	if not value then return end
	
	if value >= 1 then uf.Elements["imgCombo01"]:SetVisible(true) end
	if value >= 2 then uf.Elements["imgCombo02"]:SetVisible(true) end
	if value >= 3 then uf.Elements["imgCombo03"]:SetVisible(true) end
	if value >= 4 then uf.Elements["imgCombo04"]:SetVisible(true) end
	if value >= 5 then uf.Elements["imgCombo05"]:SetVisible(true) end
else
end	 
end

local function Setup(unitFrame, configuration)

	local img = nil
	local addon = AddonId
	--"bagslot.png.dds"
	--"bg_image_frame_loyalty.png.dds"
	--"bg_seasonal_loyalty.png.dds"

	
	configuration.texture = "target_portrait_roguepoints_on.png.dds"
	configuration.texture2 = "target_portrait_roguepoints_off.png.dds"
	
	if configuration.simple == false or configuration.simple == nil then

		if calling == "rogue" then 
					unitFrame:CreateElement(
					{
						id="imgCombo001", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.0, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_roguepoints_off.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo002", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.15, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_roguepoints_off.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo003", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.3, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.6, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_roguepoints_off.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo004", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.45, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.8, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_roguepoints_off.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo005", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={1.0, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_roguepoints_off.png.dds",
						width = 70, height=70,
					})
			unitFrame:CreateElement(
		{
			id="imgCombo01", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.0, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_roguepoints_on.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo02", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.15, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.4, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_roguepoints_on.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo03", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.3, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.6, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_roguepoints_on.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo04", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.45, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.8, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_roguepoints_on.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo05", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={1.0, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_roguepoints_on.png.dds",
			width = 70, height=70,
		})
		
		elseif calling == "warrior" then 
					unitFrame:CreateElement(
					{
						id="imgCombo001", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.0, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_warrior_hp_glow.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo002", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.2, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.4, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_warrior_hp_glow.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo003", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.4, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.6, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_warrior_hp_glow.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo004", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.8, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_warrior_hp_glow.png.dds",
						width = 70, height=70,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo005", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.8, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={1.0, 1.0} },
						},
						texAddon = "Rift", texFile = "target_portrait_warrior_hp_glow.png.dds",
						width = 70, height=70,
					})	

		unitFrame:CreateElement(
		{
			id="imgCombo01", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.0, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_warrior_hp.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo02", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.2, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.4, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_warrior_hp.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo03", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.4, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.6, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_warrior_hp.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo04", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={0.8, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_warrior_hp.png.dds",
			width = 70, height=70,
		})
		unitFrame:CreateElement(
		{
			id="imgCombo05", type="Image", parent="frame", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
				{ point="BOTTOMRIGHT", element="frame", targetPoint={1.0, 1.0} },
			},
			texAddon = "Rift", texFile = "target_portrait_warrior_hp.png.dds",
			width = 70, height=70,
		})
		end
	else 

					unitFrame:CreateElement(
					{
						id="imgCombo001", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.0, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.2, 1.0} },
						},
						texAddon = "Rift", texFile = "bagslot.png.dds",
						width = 34, height=34,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo002", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.2, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.4, 1.0} },
						},
						texAddon = "Rift", texFile = "bagslot.png.dds",
						width = 34, height=34,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo003", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.4, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.6, 1.0} },
						},
						texAddon = "Rift", texFile = "bagslot.png.dds",
						width = 34, height=34,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo004", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.6, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={0.8, 1.0} },
						},
						texAddon = "Rift", texFile = "bagslot.png.dds",
						width = 34, height=34,
					})
					unitFrame:CreateElement(
					{
						id="imgCombo005", type="Image", parent="frame", layer=1,
						attach = {
							{ point="TOPLEFT", element="frame", targetPoint={0.8, 0.0} },
							{ point="BOTTOMRIGHT", element="frame", targetPoint={1.0, 1.0} },
						},
						texAddon = "Rift", texFile = "bagslot.png.dds",
						width = 34, height=34,
					})	

			unitFrame:CreateElement(
		{
			id="imgCombo01", type="Frame", parent="frame", layer=10,
			attach = {		
				{ point="CENTER", element="imgCombo001", targetPoint="CENTER", offsetX=0, offsetY=0 }
			},
			width = 28, height=28,
			color={r=0.98, g=0.66, b=0.13, a=0.8},
		})
		unitFrame:CreateElement(
		{
			id="imgCombo02", type="Frame", parent="frame", layer=10,
			attach = {
				{ point="CENTER", element="imgCombo002", targetPoint="CENTER", offsetX=0, offsetY=0 }
			},
			width = 28, height=28,
			color={r=0.98, g=0.66, b=0.13, a=0.8},
		})
		unitFrame:CreateElement(
		{
			id="imgCombo03", type="Frame", parent="frame", layer=10,
			attach = {
				{ point="CENTER", element="imgCombo003", targetPoint="CENTER", offsetX=0, offsetY=0 }
			},
			width = 28, height=28,
			color={r=0.98, g=0.66, b=0.13, a=0.8},
		})
		unitFrame:CreateElement(
		{
			id="imgCombo04", type="Frame", parent="frame", layer=10,
			attach = {
				{ point="CENTER", element="imgCombo004", targetPoint="CENTER", offsetX=0, offsetY=0 }
			},
			width = 28, height=28,
			color={r=0.98, g=0.66, b=0.13, a=0.8},
		})
		unitFrame:CreateElement(
		{
			id="imgCombo05", type="Frame", parent="frame", layer=10,
			attach = {
				{ point="CENTER", element="imgCombo005", targetPoint="CENTER", offsetX=0, offsetY=0 }
			},
			width = 28, height=28,
			color={r=0.98, g=0.66, b=0.13, a=0.8},
		})
		
	end
		unitFrame:CreateBinding("combo", unitFrame, OnComboSingle, nil)

	
	unitFrame:ApplyBindings()
	
end


local function Create(configuration)

	calling = Inspect.Unit.Detail("player").calling 

	local comboPoints = WT.UnitFrame:Create("player")
	comboPoints:SetWidth(193)
	comboPoints:SetHeight(70)

	if calling then
		Setup(comboPoints, configuration)
	else
		table.insert(deferSetup, { unitFrame = comboPoints, configuration = configuration })
	end

	return comboPoints, { resizable = { 50, 10, 800, 500 } }
end

local dialog = false

local function ConfigDialog(container)	
	
	dialog = WT.Dialog(container)
		:Label("The Combo Points gadget displays current combo (Rogue) or attack (Warrior) points for the player.")
		:Checkbox("simple", "Show simple combo point", false)

end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("LIfeComboPoints",
	{
		name="LIfeComboPoints",
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


WT.Unit.CreateVirtualProperty("comboIndex_Life", { "combo", "comboUnit" },
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
			WT.Player.comboIndex_Life = WT.Player.combo - 1
		else
			WT.Player.comboIndex_Life = nil
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
