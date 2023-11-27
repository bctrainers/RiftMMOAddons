--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.51
      Project Date (UTC)  : 2013-10-16T12:02:13Z
      File Modified (UTC) : 2013-09-16T20:29:23Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


Library.Media.AddTexture("wtCastInterruptable", AddonId, "img/wtCastInterruptable.png", {"bar"})
Library.Media.AddTexture("wtCastUninterruptable", AddonId, "img/wtCastUninterruptable.png", {"bar"})
Library.Media.AddTexture("wtComboBlue", AddonId, "img/wtComboBlue.png", {"combo"})
Library.Media.AddTexture("wtComboBlueSmall", AddonId, "img/wtComboBlueSmall.png", {"combo"})
Library.Media.AddTexture("wtComboRed", AddonId, "img/wtComboRed.png", {"combo"})
Library.Media.AddTexture("wtVitality", AddonId, "img/wtVitality.png", {"vitality"})
Library.Media.AddTexture("wtPlanarCharge", AddonId, "img/wtPlanarCharge.png", {"planar"})
Library.Media.AddTexture("wtOrbBrightRed", AddonId, "img/wtOrbBrightRed.png", {"orb"})
Library.Media.AddTexture("wtOrbBrightGreen", AddonId, "img/wtOrbBrightGreen.png", {"orb"})
Library.Media.AddTexture("wtOrbBrightBlue", AddonId, "img/wtOrbBrightBlue.png", {"orb"})
Library.Media.AddTexture("wtOrbDarkRed", AddonId, "img/wtOrbDarkRed.png", {"orb"})
Library.Media.AddTexture("wtOrbDarkGreen", AddonId, "img/wtOrbDarkGreen.png", {"orb"})
Library.Media.AddTexture("wtOrbDarkBlue", AddonId, "img/wtOrbDarkBlue.png", {"orb"})

Library.Media.AddTexture("gradientD2L", AddonId, "img/gradientD2L.png", {"bar"})
Library.Media.AddTexture("gradientL2D", AddonId, "img/gradientL2D.png", {"bar"})

Library.Media.AddTexture("background", AddonId, "img/background.png", {})
Library.Media.AddTexture("raid_icon_leader", AddonId, "img/raid_icon_leader.png", {})
Library.Media.AddTexture("raid_icon_masterlooter", AddonId, "img/raid_icon_masterlooter.png", {})

Library.Media.AddTexture("HealerBackdrop01", "Rift", "mtx_window_medium_bg_(blue).png.dds", {"backdrop"})
Library.Media.AddTexture("RaidFrameBackdrop01", "Rift", "window_conquest_dominion.png.dds", {"backdrop"})

Library.Media.AddTexture("CP Biohazard", AddonId, "img/combo/combo_Biohazard.png", {"combo"})
Library.Media.AddTexture("CP Bullet Holes", AddonId, "img/combo/combo_BulletHole.png", {"combo"})
Library.Media.AddTexture("CP Cupcakes", AddonId, "img/combo/combo_Cupcake.png", {"combo"})
Library.Media.AddTexture("CP Lips", AddonId, "img/combo/combo_Lips.png", {"combo"})
Library.Media.AddTexture("CP Pink Skulls", AddonId, "img/combo/combo_PinkSkull.png", {"combo"})
Library.Media.AddTexture("CP Target", AddonId, "img/combo/combo_Target.png", {"combo"})
Library.Media.AddTexture("CP Rogue1_ckau", AddonId, "img/combo/Rogue1_ckau.png", {"combo"})
Library.Media.AddTexture("CP Rogue2_ckau", AddonId, "img/combo/Rogue2_ckau.png", {"combo"})
Library.Media.AddTexture("CP Warrior1_ckau", AddonId, "img/combo/Warrior1_ckau.png", {"combo"})
Library.Media.AddTexture("CP Warrior2_ckau", AddonId, "img/combo/Warrior2_ckau.png", {"combo"})
Library.Media.AddTexture("CP Number", AddonId, "img/combo/combo_number.png", {"combo"})
Library.Media.AddTexture("Warrior_CkauD3", AddonId, "img/combo/Warrior_CkauD3.png", {"combo"})
Library.Media.AddTexture("Rogue_CkauD3", AddonId, "img/combo/Rogue_CkauD3.png", {"combo"})

Library.Media.AddTexture("CP Rogue", "Rift", "target_portrait_roguepoints_on.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Warrior", "Rift", "target_portrait_warrior_hp.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Skull", "Rift", "vfx_ui_mob_tag_skull.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Twitter", "Rift", "twitter.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Red Sword", "Rift", "vfx_ui_mob_tag_damage.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Squirrel", "Rift", "vfx_ui_mob_tag_squirrel.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Red", "Rift", "ControlPoint_Respawn_Red_XtraLarge.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Blue", "Rift", "ControlPoint_Respawn_Blue_XtraLarge.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP 1", "Rift", "MainMap_I100.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP 2", "Rift", "MainMap_I123.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP 3", "Rift", "MainMap_I107.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP 4", "Rift", "MainMap_I10E.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP 5", "Rift", "MainMap_I11C.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP 6", "Rift", "icon_menu_achievements.png.dds", {"combo", "combo_single"})


Library.Media.AddTexture("Vitality_Gray", "Rift", "death_icon_(grey).png.dds", {"vitality"})
Library.Media.AddTexture("Vitality_Red", "Rift", "death_icon_(red).png.dds", {"vitality"})
Library.Media.AddTexture("Vitality_Zero", "Rift", "death_icon_(glow).png.dds", {"vitality"})
-----------------------------------Life-------------------------------------------------------------
Library.Media.AddTexture("1bar", "Rift", "Bank_110.dds", {"bar"})
Library.Media.AddTexture("CharacterSheet", "Rift", "CharacterSheet_I2B.dds", {"bar"})
Library.Media.AddTexture("Merchant", "Rift", "Merchant_I257.dds", {"bar"})
Library.Media.AddTexture("BarBkgnd", "Rift", "BarBkgnd.png.dds", {"bar"})
Library.Media.AddTexture("ControlPoint_BarGrey", "Rift", "ControlPoint_BarGrey.png.dds", {"bar"})
Library.Media.AddTexture("castbar_orange", "Rift", "castbar_orange.png.dds", {"bar"})
Library.Media.AddTexture("ControlPoint_BarBlue", "Rift", "ControlPoint_BarBlue.png.dds", {"bar"})
Library.Media.AddTexture("ControlPoint_BarRed", "Rift", "ControlPoint_BarRed.png.dds", {"bar"})
Library.Media.AddTexture("inner_black_subwin_Light", "Rift", "inner_black_subwin_Light.png.dds", {"bar"})
Library.Media.AddTexture("mini_healthbar", "Rift", "mini_healthbar.png.dds", {"bar"})
Library.Media.AddTexture("raid_healthbar", "Rift", "raid_healthbar.png.dds", {"bar"})
Library.Media.AddTexture("raid_healthbar_red", "Rift", "raid_healthbar_red.png.dds", {"bar"})
Library.Media.AddTexture("bagslot", "Rift", "bagslot.png.dds", {"bar"})
Library.Media.AddTexture("coins_credits", AddonId, "img/coins_credits.png.dds", {"credits"})
----------------------------------Life----------------------------------------------------------
Library.Media.AddTexture("BantoBar", AddonId, "img/BantoBar.png", {"bar"})
Library.Media.AddTexture("Bumps", AddonId, "img/Bumps.png", {"bar"})
Library.Media.AddTexture("Diagonal", AddonId, "img/Diagonal.png", {"bar"})
Library.Media.AddTexture("Frost", AddonId, "img/Frost.png", {"bar"})
Library.Media.AddTexture("Glamour", AddonId, "img/Glamour.png", {"bar"})
Library.Media.AddTexture("Grid", AddonId, "img/Grid.tga", {"bar"})
Library.Media.AddTexture("Healbot", AddonId, "img/Healbot.png", {"bar"})
Library.Media.AddTexture("Ruben", AddonId, "img/Ruben.png", {"bar"})
Library.Media.AddTexture("Runes", AddonId, "img/Runes.png", {"bar"})
Library.Media.AddTexture("Steel", AddonId, "img/Steel.png", {"bar"})
Library.Media.AddTexture("shadow", AddonId, "img/shadow.tga", {"bar"})
Library.Media.AddTexture("wtGlaze", AddonId, "img/wtGlaze.png", {"bar"})

----------------------------------Font----------------------------------------------------------
Library.Media.AddFont("ArmWrestler", AddonId, "font/ArmWrestler.ttf", {"font"})
Library.Media.AddFont("Bazooka", AddonId, "font/Bazooka.ttf", {"font"})
Library.Media.AddFont("blank-Bold", AddonId, "font/blank-Bold.ttf", {"font"})
Library.Media.AddFont("Bloodlust", AddonId, "font/Bloodlust.ttf", {"font"})
Library.Media.AddFont("CelestiaMediumRedux", AddonId, "font/CelestiaMediumRedux.ttf", {"font"})
Library.Media.AddFont("Collegia", AddonId, "font/Collegia.ttf", {"font"})
Library.Media.AddFont("Disko", AddonId, "font/Disko.ttf", {"font"})
Library.Media.AddFont("DorisPP", AddonId, "font/DorisPP.ttf", {"font"})
Library.Media.AddFont("DroidSans", AddonId, "font/DroidSans.ttf", {"font"})
Library.Media.AddFont("DroidSansBold", AddonId, "font/DroidSansBold.ttf", {"font"})
Library.Media.AddFont("electric", AddonId, "font/electric.ttf", {"font"})
Library.Media.AddFont("Enigma", AddonId, "font/Enigma.ttf", {"font"})
Library.Media.AddFont("LiberationSans", AddonId, "font/LiberationSans.ttf", {"font"})
Library.Media.AddFont("MinecraftFont", AddonId, "font/MinecraftFont.ttf", {"font"})
Library.Media.AddFont("Nasalization", AddonId, "font/Nasalization.ttf", {"font"})
Library.Media.AddFont("Open-24-Display-St", AddonId, "font/Open-24-Display-St.ttf", {"font"})
Library.Media.AddFont("Orbitron-Medium", AddonId, "font/Orbitron-Medium.ttf", {"font"})
Library.Media.AddFont("Roboto-BoldItalic", AddonId, "font/Roboto-BoldItalic.ttf", {"font"})
Library.Media.AddFont("RobotoCondensed-Regular", AddonId, "font/RobotoCondensed-Regular.ttf", {"font"})
Library.Media.AddFont("Roboto-Regular", AddonId, "font/Roboto-Regular.ttf", {"font"})
Library.Media.AddFont("RobotoSlab-Regular", AddonId, "font/RobotoSlab-Regular.ttf", {"font"})
Library.Media.AddFont("SFAtarianSystem", AddonId, "font/SFAtarianSystem.ttf", {"font"})
Library.Media.AddFont("SquareRoman", AddonId, "font/SquareRoman.ttf", {"font"})
Library.Media.AddFont("standard", AddonId, "font/standard.ttf", {"font"})
Library.Media.AddFont("standard_medium", AddonId, "font/standard_medium.ttf", {"font"})
Library.Media.AddFont("standard_regular", AddonId, "font/standard_regular.ttf", {"font"})
Library.Media.AddFont("Visitor1", AddonId, "font/Visitor1.ttf", {"font"})
