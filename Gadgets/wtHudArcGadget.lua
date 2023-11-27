--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-06-11T06:19:15Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local skins = {}
local function AddSkin(skinTable)
	skins[skinTable.pack] = skinTable
end

-- Copied from the Archimedes addon, which is also where the textures are from:

AddSkin({
  pack = "DefaultSkin",
  packName = "Default Skin",
  addon = AddonId,
  dir = "img/hud",
  textures = {
    -- textureid = {<DisplayName>, <filename>, <format>}
    red = {"Red", "red", "png"},
    green = {"Green", "green", "png"},
    blue = {"Blue", "blue", "png"},
    purple = {"Purple", "purple", "png"},
    teal = {"Teal", "teal", "png"},
    yellow = {"Yellow", "yellow", "png"},
  },
  background = {"Transparent", "transparent", "png"}
})

AddSkin({
  pack = "NeutralSkin",
  packName = "Neutral Skin",
  addon = AddonId,
  dir = "img/hud",
  textures = {
    red = {"Neutral Red", "old_red", "png"},
    green = {"Neutral Green", "old_green", "png"},
    blue = {"Neutral Blue", "old_blue", "png"},
    purple = {"Neutral Purple", "old_purple", "png"},
    teal = {"Neutral Teal", "old_teal", "png"},
    yellow = {"Neutral Yellow", "old_yellow", "png"},
  },
  background = {"Neutral Transparent", "old_transparent", "png"}
})

AddSkin({
  pack = "CleanCurves",
  packName = "Clean Curves",
  addon = AddonId,
  dir = "img/hud",
  textures = {
    red = {"Red", "CleanCurves_red", "png"},
    green = {"Green", "CleanCurves_green", "png"},
    blue = {"Blue", "CleanCurves_blue", "png"},
    purple = {"Purple", "CleanCurves_purple", "png"},
    teal = {"Teal", "CleanCurves_teal", "png"},
    yellow = {"Yellow", "CleanCurves_yellow", "png"},
  },
  background = {"Background", "CleanCurves_transparent", "png"}
})


local chargeFontSize = 18

-- Displays an arc on the screen

local function Create(configuration)

	local skinPack = configuration.skin or "DefaultSkin"
	local skin = skins[skinPack] or skins["DefaultSkin"]

	local side = (configuration.side or "Left"):lower()
	local color = (configuration.color or "green"):lower()
	local value = (configuration.value or "health"):lower() .. "Percent"

	if color == "auto" then
		if value == "health" then 
			color = "green"
		elseif value == "charge" then
			color = "teal"
		elseif value == "resource" then
			color = "blue"
		else
			color = "purple" -- should never happen
		end		
	end

	local hudArc = WT.UnitFrame:Create(configuration.unitSpec or "player")
	hudArc.config = configuration
	
	hudArc.background = hudArc:CreateElement(
	{
		id = "imgBackground",
		type = "Image",
		parent = "frame",
		layer = 0,
		alpha = 1,
		texAddon = skin.addon,
		texFile = skin.dir .. "/" .. skin.background[2] .. "_" .. side .. "." .. skin.background[3],
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
	})
	
	hudArc.bar = hudArc:CreateElement(
	{
		id = "barHud",
		type = "Bar",
		parent = "imgBackground",
		layer = 0,
		alpha = 1.0,
		texAddon = skin.addon,
		texFile = skin.dir .. "/" .. skin.textures[color][2] .. "_" .. side .. "." .. skin.textures[color][3],
		growthDirection = "up",
		binding = value,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
	})
	
	function hudArc:OnResourceChanged(resourceName)
		if resourceName == "mana" then
			local color = "blue"
			self.bar.Image:SetTexture(skin.addon, skin.dir .. "/" .. skin.textures[color][2] .. "_" .. side .. "." .. skin.textures[color][3])
		end
		if resourceName == "power" then
			local color = "yellow"
			self.bar.Image:SetTexture(skin.addon, skin.dir .. "/" .. skin.textures[color][2] .. "_" .. side .. "." .. skin.textures[color][3])
		end
		if resourceName == "energy" then
			local color = "purple"
			self.bar.Image:SetTexture(skin.addon, skin.dir .. "/" .. skin.textures[color][2] .. "_" .. side .. "." .. skin.textures[color][3])
		end
	end
	
	if configuration.color == "Auto" then
		hudArc:CreateBinding("resourceName", hudArc, hudArc.OnResourceChanged, "", nil)
	end
	
	hudArc:SetWidth(96)
	hudArc:SetHeight(486)
	hudArc:ApplyBindings()

	return hudArc, { resizable = { 16,16, 500, 2000 } }
end


local dialog = nil

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The HUD Arc gadget allows you to add arc shaped bars as HUD elements")
		:Label("To create arcs with matching sizes, please use the 'Copy Gadget' option, which is available when gadgets are unlocked")
		:Combobox("unitSpec", TXT.UnitToTrack, "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false) 
		:Select("skin", "Skin", "DefaultSkin", { "DefaultSkin", "CleanCurves", "NeutralSkin" }, false)
		:Select("side", "Side of the Screen", "Left", { "Left", "Right" }, false)
		:Select("value", "Value to Display", "Health", { "Health", "Resource", "Charge" }, false)
		:Select("color", "Bar Color", "Auto", { "Auto", "Green", "Blue", "Red", "Purple", "Teal", "Yellow" }, false)
	return dialog
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("HUDArc",
	{
		name="HUD Arc",
		description="An arc shaped HUD meter",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 	
	})
