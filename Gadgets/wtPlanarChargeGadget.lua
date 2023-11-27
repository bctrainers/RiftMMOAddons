--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-09-14T10:37:55Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local chargeFontSize = 32

local sizeMultiplier = 0.66

-- Displays current Planar Charge count

local function Create(configuration)

	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetWidth(48)
	chargeMeter:SetHeight(48)
	chargeMeter:SetLayer(100)

	chargeMeter.sizeMult = 0.66
	chargeMeter.xPoint = 0.5
	local img_addon = AddonId
	local img_file = "img/wtPlanarCharge.png"

	if configuration.skinAlt then
		img_addon = "Rift"
		img_file = "chargedstone_on.png.dds"
		chargeMeter.sizeMult = 0.44
		chargeMeter.xPoint = 0.57
	end

	chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgCharge", type="Image", parent="frame", layer=0, alpha=0.8,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
		texAddon=img_addon, texFile=img_file,
		backgroundColor={r=0, g=0, b=0, a=0.4}
	});
	chargeMeter.txt03 = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeLabel", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTER", element="imgCharge", targetPoint={ chargeMeter.xPoint, 0.5 } }},
		outline=true,
		text="{planar}", fontSize=chargeFontSize,
	});

	chargeMeter.txtHover = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeHover", type="Label", parent="frame", layer=20,
		attach = {{ point="TOPCENTER", element="frame", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-3 }},
		text="{planar}/{planarMax}", fontSize=12,
	});
	chargeMeter.txtHover:SetVisible(false)

	chargeMeter:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
		chargeMeter.txtHover:SetVisible(true)
	end, "Event.UI.Input.Mouse.Cursor.In")
	chargeMeter:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
		chargeMeter.txtHover:SetVisible(false)
	end, "Event.UI.Input.Mouse.Cursor.Out")

	chargeMeter.OnResize = function(frame, width,height)
		--chargeMeter.txt01:SetFontSize(height*0.66)
		--chargeMeter.txt02:SetFontSize(height*0.66)
		chargeMeter.txt03:SetFontSize(height*chargeMeter.sizeMult)
		chargeMeter.txtHover:SetFontSize(height*0.50)
	end

	chargeMeter:ApplyBindings()

	return chargeMeter, { resizable = { 24,24, 64,64 } }
end


local dialog = false


local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Checkbox("skinAlt", "Use alternate appearance?", false)
end


local function GetConfiguration()
	return dialog:GetValues()
end


local function SetConfiguration(config)
	dialog:SetValues(config)
end



WT.Gadget.RegisterFactory("PlanarCharge",
	{
		name=TXT.gadgetPlanarCharge_name,
		description=TXT.gadgetPlanarCharge_desc,
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtPlanarCharge.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

