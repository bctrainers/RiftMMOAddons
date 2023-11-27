--[[
                                 GX LIBRARY
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-05-21T15:53:02Z (Wildtide)
      -----------------------------------------------------------------     
--]]

--[[
		Note: This file has been borrowed from LibGX and retrofitted
		to Gadgets. It therefore creates the GX namespace if necessary.

		The GX namespace will replace the WT namespace when LibGX is
		complete.
--]]

local toc, data = ...
local AddonId = toc.identifier

GX = GX or {}
GX.Settings = GX.Settings or {}
GX.Settings.Colors = GX.Settings.Colors or {}
GX.Constants = GX.Constants or {}
GX.Constants.Colors = GX.Constants.Colors or {}

local function ColorString(col)
	if col:sub(1, 1) == "#" then
		col = col:sub(2)
	end
	if col:len() == 6 then
		col = "FF" .. col
	end
	if col:len() ~= 8 then
		error("Invalid colour string")
	end

	return {
		a = tonumber(col:sub(1,2), 16) / 255,
		r = tonumber(col:sub(3,4), 16) / 255,
		g = tonumber(col:sub(5,6), 16) / 255,
		b = tonumber(col:sub(7,8), 16) / 255,
	}
	
end

-- Colours are defined as tables { r, g, b, a }

GX.Settings.Colors.CallingCleric = ColorString("#77ef00")
GX.Settings.Colors.CallingMage = ColorString("#c85eff")
GX.Settings.Colors.CallingRogue = ColorString("#ffdb00")
GX.Settings.Colors.CallingWarrior = ColorString("#ff2828")
GX.Settings.Colors.CallingNone = ColorString("#446688")

GX.Settings.Colors.ResourceEnergy = ColorString("#cd64da")
GX.Settings.Colors.ResourceMana = ColorString("#46ade8")
GX.Settings.Colors.ResourcePower = ColorString("#d8d24a")

GX.Settings.Colors.FactionGuardian = ColorString("#806fe6")
GX.Settings.Colors.FactionDefiant = ColorString("#368dee")
GX.Settings.Colors.FactionNeutral = ColorString("#bbbab4")

GX.Settings.Colors.RelationHostile = ColorString("#f30000")
GX.Settings.Colors.RelationNeutral = ColorString("#fde72b")
GX.Settings.Colors.RelationFriendly = ColorString("#65e200")

GX.Settings.Colors.ItemTrash = ColorString("#888888")
GX.Settings.Colors.ItemCommon = ColorString("#ffffff")
GX.Settings.Colors.ItemUncommon = ColorString("#00cc00")
GX.Settings.Colors.ItemRare = ColorString("#2681fe")
GX.Settings.Colors.ItemEpic = ColorString("#b049ff")
GX.Settings.Colors.ItemRelic = ColorString("#ff9900")
GX.Settings.Colors.ItemQuest = ColorString("#fff600")

GX.Settings.Colors.DifficultyImpossible = ColorString("#cf1313")
GX.Settings.Colors.DifficultyHard = ColorString("#de8e03")
GX.Settings.Colors.DifficultyMedium = ColorString("#d5c300")
GX.Settings.Colors.DifficultyEasy = ColorString("#51c412")
GX.Settings.Colors.DifficultyTrivial = ColorString("#b4b4b4")

GX.Settings.Colors.Aggro = ColorString("#aa0000")
GX.Settings.Colors.Target = ColorString("#ffffff")

GX.Constants.Colors.Black = ColorString("#000000")
GX.Constants.Colors.White = ColorString("#ffffff")
GX.Constants.Colors.Red = ColorString("#ff0000")
GX.Constants.Colors.Green = ColorString("#00ff00")
GX.Constants.Colors.Blue = ColorString("#0000ff")
GX.Constants.Colors.Yellow = ColorString("#ffff00")
GX.Constants.Colors.Orange = ColorString("#ffa500")
GX.Constants.Colors.Purple = ColorString("#800080")
GX.Constants.Colors.Brown = ColorString("#a52a2a")
GX.Constants.Colors.Cyan = ColorString("#00ffff")
GX.Constants.Colors.Gray = ColorString("#888888")
GX.Constants.Colors.LightGray = ColorString("#cccccc")
GX.Constants.Colors.DarkGray = ColorString("#444444")
GX.Constants.Colors.Transparent = ColorString("#00000000")
