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


local chargeFontSize = 18

-- Displays current Planar Charge count

local function Create(configuration)

	local vitalityMeter = WT.UnitFrame:Create("player")
	vitalityMeter:SetWidth(48)
	vitalityMeter:SetHeight(48)
	vitalityMeter:SetLayer(100)

	--[[
	vitalityMeter.img = vitalityMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgCharge", type="ImageSet", parent="frame", layer=0, alpha=1.0,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
		},
		texAddon=AddonId, texFile="img/wtVitality.png", rows=10,cols=1,
		indexBinding="vitalityIndex", visibilityBinding="vitalityIndex",width=48,height=48,
	});
	--]]

	vitalityMeter.img = vitalityMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgCharge", type="MediaSet", parent="frame", layer=0, alpha=1.0,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
		},
		rows=10,cols=1,
		nameBinding="vitalityTier", 
		names={ 
			["Vitality_Gray"] = "Vitality_Gray", 
			["Vitality_Red"] = "Vitality_Red", 
			["Vitality_Zero"] = "Vitality_Red" 
		},
		visibilityBinding="vitalityTier",width=77,height=77,
	});

	vitalityMeter.imgZero = vitalityMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgZero", type="Image", parent="frame", layer=10, alpha=1.0,
		attach = {
			{ point="TOPLEFT", element="imgCharge", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="imgCharge", targetPoint="BOTTOMRIGHT" },
		},
		media="Vitality_Zero", visibilityBinding="zeroVitality",
	});

	vitalityMeter.txtVitality = vitalityMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="txtVitality", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 }},
		text="{vitality}%", fontSize=chargeFontSize,
	});
	vitalityMeter.txtVitality:SetVisible(false)

	vitalityMeter:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
		if vitalityMeter.img:GetVisible() then
			vitalityMeter.txtVitality:SetVisible(true) 
		end
	end, "Event.UI.Input.Mouse.Cursor.In")
	vitalityMeter:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
		vitalityMeter.txtVitality:SetVisible(false)
	end, "Event.UI.Input.Mouse.Cursor.Out")

	vitalityMeter.OnResize = function(frame, width, height)
		-- Size * 1.6 to account for image only filling quarter of the texture
		vitalityMeter.txtVitality:SetFontSize(height*0.35)
		vitalityMeter.img:SetWidth(width * 1.6)
		vitalityMeter.img:SetHeight(height * 1.6)
		vitalityMeter.img.Configuration.width = width * 1.6
	end

	vitalityMeter:ApplyBindings()

	return vitalityMeter, { resizable = { 24,24, 64,64 } }
end


WT.Gadget.RegisterFactory("SoulVitality",
	{
		name=TXT.gadgetSoulVitality_name,
		description=TXT.gadgetSoulVitality_desc,
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtSoulVitality.png",
		["Create"] = Create,
	})

WT.Unit.CreateVirtualProperty("vitalityIndex", {"vitality", "vitalityMax"}, 
	function(unit)
		local vitality = unit.vitality
		if not vitality then return nil end 
		if vitality > 90 then 
			return nil
			elseif vitality > 80 then return 0
			elseif vitality > 70 then return 1
			elseif vitality > 60 then return 2
			elseif vitality > 50 then return 3
			elseif vitality > 40 then return 4
			elseif vitality > 30 then return 5
			elseif vitality > 20 then return 6
			elseif vitality > 10 then return 7
			elseif vitality > 0 then return 8
			else return 9
		end
	end)

WT.Unit.CreateVirtualProperty("vitalityTier", {"vitality", "vitalityMax"}, 
	function(unit)
		local vitality = unit.vitality
		if not vitality then return nil end 
		if vitality > 90 then 
			return nil
			elseif vitality >= 20 then return "Vitality_Gray"
			elseif vitality > 0 then return "Vitality_Red"
			elseif vitality > 0 then return "Vitality_Zero"
			else return "Vitality_Zero"
		end
	end)

WT.Unit.CreateVirtualProperty("zeroVitality", {"vitality" },
	function(unit)
		if unit.vitality and unit.vitality > 0 then
			return false
		else
			return true
		end
	end)
