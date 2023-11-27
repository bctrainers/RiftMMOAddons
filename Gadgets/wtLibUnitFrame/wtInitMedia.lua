--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- Load all of the built in media -----------------------------------------------------------------
Library.Media.AddTexture("wtBantoBar", AddonId, "img/BantoBar.png", {"bar", "colorize"})
Library.Media.AddTexture("wtDiagonal", AddonId, "img/Diagonal.png", {"bar", "colorize"})
Library.Media.AddTexture("wtGlaze2", AddonId, "img/Glaze2.png", {"bar", "colorize"})
Library.Media.AddTexture("wtHealbot", AddonId, "img/Healbot.png", {"bar", "colorize"})
Library.Media.AddTexture("wtOrbGreen", AddonId, "img/orb_green.tga", {"orb"})
Library.Media.AddTexture("wtOrbBlue", AddonId, "img/orb_blue.tga", {"orb"})
Library.Media.AddTexture("wtReadyCheck", AddonId, "img/wtReady.png", {"imgset", "readycheck"})
Library.Media.AddTexture("wtRankPips", AddonId, "img/wtRankPips.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtRanks24", AddonId, "img/wtRanks24.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtRanks38", AddonId, "img/wtRanks38.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtSweep", AddonId, "img/Sweep.png", {"imgset", "sweep"})

-----------------------------------Life------------------------------------------------------------
Library.Media.AddTexture("octanusHeal", "Rift", "raid_icon_role_heal.png.dds", {"roleHeal"})
Library.Media.AddTexture("octanusDPS", "Rift", "raid_icon_role_dps.png.dds", {"roleDPS"})
Library.Media.AddTexture("octanusTank", "Rift", "raid_icon_role_tank.png.dds", {"roleTank"})
Library.Media.AddTexture("octanusSupport", "Rift", "raid_icon_role_support.png.dds", {"roleSupport"})

Library.Media.AddTexture("iconRoleHeal", "Rift", "vfx_ui_mob_tag_heal_mini.png.dds", {"roleHeal"})
Library.Media.AddTexture("iconRoleDPS", "Rift", "vfx_ui_mob_tag_damage_mini.png.dds", {"roleDPS"})
Library.Media.AddTexture("iconRoleTank", "Rift", "vfx_ui_mob_tag_tank_mini.png.dds", {"roleTank"})
Library.Media.AddTexture("iconRoleSupport", "Rift", "vfx_ui_mob_tag_support_mini.png.dds", {"roleSupport"})
-----------------------------------Life------------------------------------------------------------
Library.Media.AddTexture("octanusHP", AddonId, "img/octanusHP.png", {"bar", "healthBar"})
Library.Media.AddTexture("OctanusHP_red", AddonId, "img/octanusHP_red.png", {"bar", "healthBar"})
Library.Media.AddTexture("octanusMana", AddonId, "img/octanusMana.png", {"bar", "manaBar"})
Library.Media.AddTexture("octanusEnergy", AddonId, "img/octanusEnergy.png", {"bar", "energyBar"})

Library.Media.AddTexture("riftRaidHealthBar", "Rift", "raid_healthbar.png.dds", {"bar"})
Library.Media.AddTexture("riftRaidRoleHeal", "Rift", "raid_icon_role_heal.png.dds", {"roleHeal"})
Library.Media.AddTexture("riftRaidRoleDPS", "Rift", "raid_icon_role_dps.png.dds", {"roleDPS"})
Library.Media.AddTexture("riftRaidRoleTank", "Rift", "raid_icon_role_tank.png.dds", {"roleTank"})
Library.Media.AddTexture("riftRaidRoleSupport", "Rift", "raid_icon_role_support.png.dds", {"roleSupport"})

Library.Media.AddTexture("riftRaidRoleHeal_Medium", "Rift", "role_heal_big.png.dds", {"roleHealMedium"})
Library.Media.AddTexture("riftRaidRoleDPS_Medium", "Rift", "role_dps_big.png.dds", {"roleDPSMedium"})
Library.Media.AddTexture("riftRaidRoleTank_Medium", "Rift", "role_tank_big.png.dds", {"roleTankMedium"})
Library.Media.AddTexture("riftRaidRoleSupport_Medium", "Rift", "role_support_big.png.dds", {"roleSupportMedium"})

Library.Media.AddTexture("riftRaidRoleHeal_Large", "Rift", "LFP_Roles_Heal_(normal).png.dds", {"roleHealLarge"})
Library.Media.AddTexture("riftRaidRoleDPS_Large", "Rift", "LFP_Roles_DPS_(normal).png.dds", {"roleDPSLarge"})
Library.Media.AddTexture("riftRaidRoleTank_Large", "Rift", "LFP_Roles_Tank_(normal).png.dds", {"roleTankLarge"})
Library.Media.AddTexture("riftRaidRoleSupport_Large", "Rift", "LFP_Roles_Support_(normal).png.dds", {"roleSupportLarge"})

Library.Media.AddTexture("riftMark01", "Rift", "vfx_ui_mob_tag_01.png.dds", {})
Library.Media.AddTexture("riftMark02", "Rift", "vfx_ui_mob_tag_02.png.dds", {})
Library.Media.AddTexture("riftMark03", "Rift", "vfx_ui_mob_tag_03.png.dds", {})
Library.Media.AddTexture("riftMark04", "Rift", "vfx_ui_mob_tag_04.png.dds", {})
Library.Media.AddTexture("riftMark05", "Rift", "vfx_ui_mob_tag_05.png.dds", {})
Library.Media.AddTexture("riftMark06", "Rift", "vfx_ui_mob_tag_06.png.dds", {})
Library.Media.AddTexture("riftMark07", "Rift", "vfx_ui_mob_tag_07.png.dds", {})
Library.Media.AddTexture("riftMark08", "Rift", "vfx_ui_mob_tag_08.png.dds", {})
Library.Media.AddTexture("riftMark09", "Rift", "vfx_ui_mob_tag_tank.png.dds", {})
Library.Media.AddTexture("riftMark10", "Rift", "vfx_ui_mob_tag_heal.png.dds", {})
Library.Media.AddTexture("riftMark11", "Rift", "vfx_ui_mob_tag_damage.png.dds", {})
Library.Media.AddTexture("riftMark12", "Rift", "vfx_ui_mob_tag_support.png.dds", {})
Library.Media.AddTexture("riftMark13", "Rift", "vfx_ui_mob_tag_arrow.png.dds", {})
Library.Media.AddTexture("riftMark14", "Rift", "vfx_ui_mob_tag_skull.png.dds", {})
Library.Media.AddTexture("riftMark15", "Rift", "vfx_ui_mob_tag_no.png.dds", {})
Library.Media.AddTexture("riftMark16", "Rift", "vfx_ui_mob_tag_smile.png.dds", {})
Library.Media.AddTexture("riftMark17", "Rift", "vfx_ui_mob_tag_squirrel.png.dds", {})
Library.Media.AddTexture("riftMark18", "Rift", "vfx_ui_mob_tag_crown.png.dds", {})
Library.Media.AddTexture("riftMark22", "Rift", "vfx_ui_mob_tag_heart.png.dds", {})
Library.Media.AddTexture("riftMark23", "Rift", "vfx_ui_mob_tag_heart_leftside.png.dds", {})
Library.Media.AddTexture("riftMark24", "Rift", "vfx_ui_mob_tag_heart_rightside.png.dds", {})
Library.Media.AddTexture("riftMark25", "Rift", "vfx_ui_mob_tag_radioactive.png.dds", {})
Library.Media.AddTexture("riftMark26", "Rift", "vfx_ui_mob_tag_sad.png.dds", {})
Library.Media.AddTexture("riftMark30", "Rift", "vfx_ui_mob_tag_clover.png.dds", {})

Library.Media.AddTexture("riftMark01_mini", "Rift", "vfx_ui_mob_tag_01_mini.png.dds", {})
Library.Media.AddTexture("riftMark02_mini", "Rift", "vfx_ui_mob_tag_02_mini.png.dds", {})
Library.Media.AddTexture("riftMark03_mini", "Rift", "vfx_ui_mob_tag_03_mini.png.dds", {})
Library.Media.AddTexture("riftMark04_mini", "Rift", "vfx_ui_mob_tag_04_mini.png.dds", {})
Library.Media.AddTexture("riftMark05_mini", "Rift", "vfx_ui_mob_tag_05_mini.png.dds", {})
Library.Media.AddTexture("riftMark06_mini", "Rift", "vfx_ui_mob_tag_06_mini.png.dds", {})
Library.Media.AddTexture("riftMark07_mini", "Rift", "vfx_ui_mob_tag_07_mini.png.dds", {})
Library.Media.AddTexture("riftMark08_mini", "Rift", "vfx_ui_mob_tag_08_mini.png.dds", {})
Library.Media.AddTexture("riftMark09_mini", "Rift", "vfx_ui_mob_tag_tank_mini.png.dds", {})
Library.Media.AddTexture("riftMark10_mini", "Rift", "vfx_ui_mob_tag_heal_mini.png.dds", {})
Library.Media.AddTexture("riftMark11_mini", "Rift", "vfx_ui_mob_tag_damage_mini.png.dds", {})
Library.Media.AddTexture("riftMark12_mini", "Rift", "vfx_ui_mob_tag_support_mini.png.dds", {})
Library.Media.AddTexture("riftMark13_mini", "Rift", "vfx_ui_mob_tag_arrow_mini.png.dds", {})
Library.Media.AddTexture("riftMark14_mini", "Rift", "vfx_ui_mob_tag_skull_mini.png.dds", {})
Library.Media.AddTexture("riftMark15_mini", "Rift", "vfx_ui_mob_tag_no_mini.png.dds", {})
Library.Media.AddTexture("riftMark16_mini", "Rift", "vfx_ui_mob_tag_smile_mini.png.dds", {})
Library.Media.AddTexture("riftMark17_mini", "Rift", "vfx_ui_mob_tag_squirrel_mini.png.dds", {})
Library.Media.AddTexture("riftMark18_mini", "Rift", "vfx_ui_mob_tag_crown_mini.png.dds", {})
Library.Media.AddTexture("riftMark22_mini", "Rift", "vfx_ui_mob_tag_heart_mini.png.dds", {})
Library.Media.AddTexture("riftMark23_mini", "Rift", "vfx_ui_mob_tag_heart_leftside_mini.png.dds", {})
Library.Media.AddTexture("riftMark24_mini", "Rift", "vfx_ui_mob_tag_heart_rightside_mini.png.dds", {})
Library.Media.AddTexture("riftMark25_mini", "Rift", "vfx_ui_mob_tag_radioactive_mini.png.dds", {})
Library.Media.AddTexture("riftMark26_mini", "Rift", "vfx_ui_mob_tag_sad_mini.png.dds", {})
Library.Media.AddTexture("riftMark30_mini", "Rift", "vfx_ui_mob_tag_clover_mini.png.dds", {})

Library.Media.AddTexture("FactionDefiant", AddonId, "img/FactionDefiant.dds", {})
Library.Media.AddTexture("FactionGuardian", AddonId, "img/FactionGuardian.dds", {})
Library.Media.AddTexture("FactionDominion", "Rift", "Icon_Dominion_sm.png.dds", {}) --"NPCDialog_conquest_dominion.png.dds"
Library.Media.AddTexture("FactionNightfall", "Rift", "Icon_Nightfall_sm.png.dds", {}) --"NPCDialog_conquest_nightfall.png.dds"
Library.Media.AddTexture("FactionOathsworn", "Rift", "Icon_Oathsworn_sm.png.dds", {}) --"NPCDialog_conquest_oathsworn.png.dds"

Library.Media.AddTexture("Portrait_BG_Friendly", AddonId, "img/Portrait_BG_Friendly.png", {})
Library.Media.AddTexture("Portrait_BG_Hostile", AddonId, "img/Portrait_BG_Hostile.png", {})
Library.Media.AddTexture("Portrait_BG_Neutral", AddonId, "img/Portrait_BG_Neutral.png", {})
Library.Media.AddTexture("Portrait_Calling_Cleric", AddonId, "img/Portrait_Calling_Cleric.png", {})
Library.Media.AddTexture("Portrait_Calling_Mage", AddonId, "img/Portrait_Calling_Mage.png", {})
Library.Media.AddTexture("Portrait_Calling_Rogue", AddonId, "img/Portrait_Calling_Rogue.png", {})
Library.Media.AddTexture("Portrait_Calling_Warrior", AddonId, "img/Portrait_Calling_Warrior.png", {})

Library.Media.AddTexture("Mentoring", "Rift", "TargetPortrait_Mentor.png.dds", {"Mentoring"})
Library.Media.AddTexture("icon_boss", AddonId, "img/icon_boss.png", {})
Library.Media.AddTexture("icon_defiant", AddonId, "img/icon_defiant.png", {})


Library.Media.AddTexture("Icon_normal", "Rift", "emblem_normal.png.dds", {"normal"})
Library.Media.AddTexture("Icon_group", "Rift", "emblem_boss.png.dds", {"group"})
Library.Media.AddTexture("Icon_raid", "Rift", "UpgradableNPC_I18.dds", {"raid"})
Library.Media.AddTexture("Icon_raid", "Rift", "emblem_elite.png.dds", {"raid"})

Library.Media.AddTexture("Icon_neutral", "Rift", "indicator_hostile_unflagged.png.dds", {"neutral"})
Library.Media.AddTexture("Icon_hostil", "Rift", "indicator_hostile_flagged.png.dds", {"hostile"})
Library.Media.AddTexture("Icon_friendly", "Rift", "indicator_friendly_flagged.png.dds", {"friendly"})

Library.Media.AddTexture("RareMob", "Rift", "target_portrait_LootPinata.png.dds", {})

Library.Media.AddTexture("jnhOrb_RED", AddonId, "img/jnhOrb_red.png", {"orb"})
Library.Media.AddTexture("jnhOrb2_BLEU", AddonId, "img/jnhOrb2_blue.png", {"orb"})

Library.Media.AddTexture("borderPortrait", "Rift", "BarberShop_I50.dds", {""})

Library.Media.AddTexture("Portrait_Race_Kelari", "Rift", "charactercreate_darkelf_female.tga", {""})
Library.Media.AddTexture("Portrait_Race_Eth", "Rift", "charactercreate_ethian_female.tga", {""})
Library.Media.AddTexture("Portrait_Race_Dwarf", "Rift", "charactercreate_female_dwarf.tga", {""})
Library.Media.AddTexture("Portrait_Race_Mathosian", "Rift", "charactercreate_mathosian_female.tga", {""})
Library.Media.AddTexture("Portrait_Race_HighElf", "Rift", "charactercreate_highelf_female.tga", {""})
Library.Media.AddTexture("Portrait_Race_Bahmi", "Rift", "charactercreate_bahmi_female.tga", {""})

Library.Media.AddTexture("Portrait_Cleric", "Rift", "CharacterSheet_I1BA.dds", {"cleric"})
Library.Media.AddTexture("Portrait_Mage", "Rift", "CharacterSheet_I1BB.dds", {"mage"})
Library.Media.AddTexture("Portrait_Rogue", "Rift", "CharacterSheet_I1BD.dds", {"rogue"})
Library.Media.AddTexture("Portrait_Warrior", "Rift", "CharacterSheet_I1BF.dds", {"warrior"})