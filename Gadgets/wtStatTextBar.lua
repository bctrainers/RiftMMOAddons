--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            Lifeismystery@yandex.ru
                           Lifeismystery: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.4.92
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local StatsTemp = {}
local Stats = Inspect.Stat()
	
local function Create(configuration)	

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtStatText"), WT.Context)
	wrapper:SetHeight(30)
	wrapper:SetWidth(700)
	wrapper:SetSecureMode("restricted")
	
	if configuration.showBackground == nil then
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		wrapper:SetBackgroundColor(0.07,0.07,0.07,0.85)		
	elseif configuration.showBackground == true then
			Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		if configuration.BackgroundColor == nil then
			configuration.BackgroundColor = {0.07,0.07,0.07,0.85}
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		else 
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		end
	else 	
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", wrapper, 1, 0, 0, 0, 0)
		wrapper:SetBackgroundColor(0,0,0,0)
	end
--------------------------------------------------------------------------------------------------------------
------------------------------MANE_STAT-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
------------------------------Stat_Strength-------------------------------------------------------------------
	local StatStrength = UI.CreateFrame("Text", WT.UniqueName("wtStatStrength"), wrapper)
	StatStrength:SetText("")
	StatStrength:SetFontSize(configuration.fontSize or 13)
	StatStrength:SetFontColor(1,0.97,0.84,1)
	StatStrength:SetPoint("CENTERLEFT", wrapper, "CENTERLEFT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatStrength:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatStrength:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatStrength:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatStrength, configuration.font)
	end
------------------------------Stat_Dexterity-------------------------------------------------------------------
	local StatDexterity = UI.CreateFrame("Text", WT.UniqueName("wtStatDexterity"), wrapper)
	StatDexterity:SetText("")
	StatDexterity:SetFontSize(configuration.fontSize or 13)
	StatDexterity:SetFontColor(1,0.97,0.84,1)
	StatDexterity:SetPoint("CENTERLEFT", StatStrength , "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatDexterity:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatDexterity:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatDexterity:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatDexterity, configuration.font)
	end		    
------------------------------Stat_Intelligence-------------------------------------------------------------------
	local StatIntelligence = UI.CreateFrame("Text", WT.UniqueName("wtStatIntelligence"), wrapper)
	StatIntelligence:SetText("")
	StatIntelligence:SetFontSize(configuration.fontSize or 13)
	StatIntelligence:SetFontColor(1,0.97,0.84,1)
	StatIntelligence:SetPoint("CENTERLEFT", StatDexterity , "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatIntelligence:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatIntelligence:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatIntelligence:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatIntelligence, configuration.font)
	end	 		
------------------------------Stat_Wisdom,-------------------------------------------------------------------
	local StatWisdom = UI.CreateFrame("Text", WT.UniqueName("wtStatWisdom"), wrapper)
	StatWisdom:SetText("")
	StatWisdom:SetFontSize(configuration.fontSize or 13)
	StatWisdom:SetFontColor(1,0.97,0.84,1)
	StatWisdom:SetPoint("CENTERLEFT", StatIntelligence , "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatWisdom:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatWisdom:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatWisdom:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatWisdom, configuration.font)
	end	 	
------------------------------Stat_Endurance-------------------------------------------------------------------
	local StatEndurance = UI.CreateFrame("Text", WT.UniqueName("wtStatEndurance"), wrapper)
	StatEndurance:SetText("")
	StatEndurance:SetFontSize(configuration.fontSize or 13)
	StatEndurance:SetFontColor(1,0.97,0.84,1)
	StatEndurance:SetPoint("CENTERLEFT", StatWisdom , "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatEndurance:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatEndurance:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatEndurance:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatEndurance, configuration.font)
	end	 	
------------------------------Stat_Armor-------------------------------------------------------------------
	local StatArmor = UI.CreateFrame("Text", WT.UniqueName("wtStatArmor"), wrapper)
	StatArmor:SetText("")
	StatArmor:SetFontSize(configuration.fontSize or 13)
	StatArmor:SetFontColor(1,0.97,0.84,1)
	StatArmor:SetPoint("CENTERLEFT", StatEndurance , "CENTERRIGHT", 10, 0)
	if configuration.outlineTextLight == true then
		StatArmor:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatArmor:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatArmor:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatArmor, configuration.font)
	end	 				
-----------------------------------------------------------------------------------------------------------
------------------------------OFFINSE_STAT--------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------		
------------------------------Stat_PowerAttack-------------------------------------------------------------------
	local StatPowerAttack = UI.CreateFrame("Text", WT.UniqueName("wtStatPowerAttack"), wrapper)
	StatPowerAttack:SetText("")
	StatPowerAttack:SetFontSize(configuration.fontSize or 13)
	StatPowerAttack:SetFontColor(1,0.97,0.84,1)
	StatPowerAttack:SetPoint("CENTERLEFT", StatArmor, "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatPowerAttack:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatPowerAttack:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatPowerAttack:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatPowerAttack, configuration.font)
	end
------------------------------Stat_CritAttack-------------------------------------------------------------------
	local StatCritAttack = UI.CreateFrame("Text", WT.UniqueName("wtStatCritAttack"), wrapper)
	StatCritAttack:SetText("")
	StatCritAttack:SetFontSize(configuration.fontSize or 13)
	StatCritAttack:SetFontColor(1,0.97,0.84,1)
	StatCritAttack:SetPoint("CENTERLEFT", StatPowerAttack, "CENTERRIGHT", 10, 0)		
	if configuration.outlineTextLight == true then
		StatCritAttack:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatCritAttack:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatCritAttack:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatCritAttack, configuration.font)
	end
------------------------------Stat_PowerSpell-------------------------------------------------------------------
	local StatPowerSpell = UI.CreateFrame("Text", WT.UniqueName("wtStatPowerSpell"), wrapper)
	StatPowerSpell:SetText("")
	StatPowerSpell:SetFontSize(configuration.fontSize or 13)
	StatPowerSpell:SetFontColor(1,0.97,0.84,1)
	StatPowerSpell:SetPoint("CENTERLEFT", StatCritAttack, "CENTERRIGHT", 10, 0)		
	if configuration.outlineTextLight == true then
		StatPowerSpell:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatPowerSpell:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatPowerSpell:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatPowerSpell, configuration.font)
	end			
------------------------------Stat_CritSpell-------------------------------------------------------------------
	local StatCritSpell = UI.CreateFrame("Text", WT.UniqueName("wtStatCritSpell"), wrapper)
	StatCritSpell:SetText("")
	StatCritSpell:SetFontSize(configuration.fontSize or 13)
	StatCritSpell:SetFontColor(1,0.97,0.84,1)
	StatCritSpell:SetPoint("CENTERLEFT", StatPowerSpell, "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatCritSpell:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatCritSpell:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatCritSpell:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatCritSpell, configuration.font)
	end			
------------------------------Stat_CritPower-------------------------------------------------------------------
	local StatCritPower = UI.CreateFrame("Text", WT.UniqueName("wtStatCritPower"), wrapper)
	StatCritPower:SetText("")
	StatCritPower:SetFontSize(configuration.fontSize or 13)
	StatCritPower:SetFontColor(1,0.97,0.84,1)
	StatCritPower:SetPoint("CENTERLEFT", StatCritSpell, "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatCritPower:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatCritPower:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatCritPower:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatCritPower, configuration.font)
	end		
------------------------------Stat_Hit-------------------------------------------------------------------
	local StatHit = UI.CreateFrame("Text", WT.UniqueName("wtStatHit"), wrapper)
	StatHit:SetText("")
	StatHit:SetFontSize(configuration.fontSize or 13)
	StatHit:SetFontColor(1,0.97,0.84,1)
	StatHit:SetPoint("CENTERLEFT", StatCritPower, "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatHit:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatHit:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatHit:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatHit, configuration.font)
	end		
-----------------------------------------------------------------------------------------------------------
------------------------------DEFENSE_STAT--------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------	
------------------------------Stat_Block-------------------------------------------------------------------
	local StatBlock = UI.CreateFrame("Text", WT.UniqueName("wtStatBlock"), wrapper)
	StatBlock:SetText("")
	StatBlock:SetFontSize(configuration.fontSize or 13)
	StatBlock:SetFontColor(1,0.97,0.84,1)
	StatBlock:SetPoint("CENTERLEFT", StatHit, "CENTERRIGHT", 10, 0)	
	if configuration.outlineTextLight == true then
		StatBlock:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatBlock:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatBlock:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatBlock, configuration.font)
	end	
------------------------------Stat_Guard-------------------------------------------------------------------
	local StatGuard = UI.CreateFrame("Text", WT.UniqueName("wtStatGuard"), wrapper)
	StatGuard:SetText("")
	StatGuard:SetFontSize(configuration.fontSize or 13)
	StatGuard:SetFontColor(1,0.97,0.84,1)
	StatGuard:SetPoint("CENTERLEFT", StatBlock, "CENTERRIGHT", 10, 0)
	if configuration.outlineTextLight == true then
		StatGuard:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatGuard:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatGuard:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatGuard, configuration.font)
	end		
------------------------------Stat_Dodge-------------------------------------------------------------------
	local StatDodge = UI.CreateFrame("Text", WT.UniqueName("wtStatDodge"), wrapper)
	StatDodge:SetText("")
	StatDodge:SetFontSize(configuration.fontSize or 13)
	StatDodge:SetFontColor(1,0.97,0.84,1)
	StatDodge:SetPoint("CENTERLEFT", StatHit, "CENTERRIGHT", 10, 0)	--3.0
	if configuration.outlineTextLight == true then
		StatDodge:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatDodge:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatDodge:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatDodge, configuration.font)
	end	
-----------------------------------------------------------------------------------------------------------
------------------------------RESISTENCE_STAT--------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------		
------------------------------Stat_ResistLife-------------------------------------------------------------------
	local StatResistLife = UI.CreateFrame("Text", WT.UniqueName("wtStatResistLife"), wrapper)
	StatResistLife:SetText("")
	StatResistLife:SetFontSize(configuration.fontSize or 13)
	StatResistLife:SetFontColor(1,0.97,0.84,1)
	StatResistLife:SetPoint("CENTERLEFT", StatDodge, "CENTERRIGHT", 10, 0)			
	if configuration.outlineTextLight == true then
		StatResistLife:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatResistLife:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatResistLife:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatResistLife, configuration.font)
	end
------------------------------Stat_ResistDeath-------------------------------------------------------------------
	local StatResistDeath = UI.CreateFrame("Text", WT.UniqueName("wtStatResistDeath"), wrapper)
	StatResistDeath:SetText("")
	StatResistDeath:SetFontSize(configuration.fontSize or 13)
	StatResistDeath:SetFontColor(1,0.97,0.84,1)
	StatResistDeath:SetPoint("CENTERLEFT", StatResistLife, "CENTERRIGHT", 10, 0)			
	if configuration.outlineTextLight == true then
		StatResistDeath:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatResistDeath:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatResistDeath:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatResistDeath, configuration.font)
	end	
------------------------------Stat_ResistFire-------------------------------------------------------------------
	local StatResistFire = UI.CreateFrame("Text", WT.UniqueName("wtStatResistFire"), wrapper)
	StatResistFire:SetText("")
	StatResistFire:SetFontSize(configuration.fontSize or 13)
	StatResistFire:SetFontColor(1,0.97,0.84,1)
	StatResistFire:SetPoint("CENTERLEFT", StatResistDeath, "CENTERRIGHT", 10, 0)			
	if configuration.outlineTextLight == true then
		StatResistFire:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatResistFire:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatResistFire:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatResistFire, configuration.font)
	end	
------------------------------Stat_ResistWater-------------------------------------------------------------------
	local StatResistWater = UI.CreateFrame("Text", WT.UniqueName("wtStatResistWater"), wrapper)
	StatResistWater:SetText("")
	StatResistWater:SetFontSize(configuration.fontSize or 13)
	StatResistWater:SetFontColor(1,0.97,0.84,1)
	StatResistWater:SetPoint("CENTERLEFT", StatResistFire, "CENTERRIGHT", 10, 0)				
	if configuration.outlineTextLight == true then
		StatResistWater:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatResistWater:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatResistWater:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatResistWater, configuration.font)
	end	
------------------------------Stat_ResistEarth-------------------------------------------------------------------
	local StatResistEarth = UI.CreateFrame("Text", WT.UniqueName("wtStatResistEarth"), wrapper)
	StatResistEarth:SetText("")
	StatResistEarth:SetFontSize(configuration.fontSize or 13)
	StatResistEarth:SetFontColor(1,0.97,0.84,1)
	StatResistEarth:SetPoint("CENTERLEFT", StatResistWater, "CENTERRIGHT", 10, 0)		
	if configuration.outlineTextLight == true then
		StatResistEarth:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatResistEarth:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatResistEarth:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatResistEarth, configuration.font)
	end	
------------------------------Stat_ResistAir-------------------------------------------------------------------
	local StatResistAir = UI.CreateFrame("Text", WT.UniqueName("wtStatResistAir"), wrapper)
	StatResistAir:SetText("")
	StatResistAir:SetFontSize(configuration.fontSize or 13)
	StatResistAir:SetFontColor(1,0.97,0.84,1)
	StatResistAir:SetPoint("CENTERLEFT", StatResistEarth, "CENTERRIGHT", 10, 0)		
	if configuration.outlineTextLight == true then
		StatResistAir:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else
		StatResistAir:SetEffectGlow({ strength = 3 })
	end
	if configuration.font == nil or configuration.font == "#Default" then
		StatResistAir:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(StatResistAir, configuration.font)
	end	
----------------------------------------------------------------------------------------------------------------
	if configuration.showStrength == false then
	    StatStrength:SetVisible(false)	
		StatStrength:SetWidth(-10)
	end	
	
	if configuration.showDexterity == false then
	    StatDexterity:SetVisible(false)
		StatDexterity:SetWidth(-10)
	end
	
	if configuration.showIntelligence == false then
	    StatIntelligence:SetVisible(false)
		StatIntelligence:SetWidth(-10)	
	end	
	
	if configuration.showWisdom == false then
	    StatWisdom:SetVisible(false)	
		StatWisdom:SetWidth(-10)
	end	
		
	if configuration.showEndurance == false then
	    StatEndurance:SetVisible(false)	
		StatEndurance:SetWidth(-10)
	end

	if configuration.showArmor == false then
	    StatArmor:SetVisible(false)
		StatArmor:SetWidth(-10)
	end

	if configuration.showPowerAttack == false then
	    StatPowerAttack:SetVisible(false)
		StatPowerAttack:SetWidth(-10)
	end	

	if configuration.showCritAttack == false then
	    StatCritAttack:SetVisible(false)
		StatCritAttack:SetWidth(-10)
	end	
		
	if configuration.showPowerSpell == false then
	    StatPowerSpell:SetVisible(false)
		StatPowerSpell:SetWidth(-10)
	end
	
	if configuration.showCritSpell == false then
	    StatCritSpell:SetVisible(false)
		StatCritSpell:SetWidth(-10)
	end	
	
	if configuration.showCritPower == false then
	    StatCritPower:SetVisible(false)
		StatCritPower:SetWidth(-10)
	end	
	
	if configuration.showHit == false then
	    StatHit:SetVisible(false)
		StatHit:SetWidth(-10)
	end	
	
	if configuration.showBlock == false then
	    StatBlock:SetVisible(false)
		StatBlock:SetWidth(-10)
	end	
	
	if configuration.showGuard == false then
	    StatGuard:SetVisible(false)
		StatGuard:SetWidth(-10)
	end
	
	if configuration.showDodge == false then
	    StatDodge:SetVisible(false)
		StatDodge:SetWidth(-10)
	end	
	
	--[[if configuration.showToughness == false then
	    StatToughness:SetVisible(false)
		StatToughness:SetWidth(-10)
	end	]]   -- 3.0
	
	if configuration.showResistLife == false then
	    StatResistLife:SetVisible(false)
		StatResistLife:SetWidth(-10)
	end	
	
	if configuration.showResistDeath == false then
	    StatResistDeath:SetVisible(false)
		StatResistDeath:SetWidth(-10)
	end
	
	if configuration.showResistFire == false then
	    StatResistFire:SetVisible(false)
		StatResistFire:SetWidth(-10)
	end	

	if configuration.showResistWater == false then
	    StatResistWater:SetVisible(false)
		StatResistWater:SetWidth(-10)
	end	
	
	if configuration.showResistEarth == false then
	    StatResistEarth:SetVisible(false)
		StatResistEarth:SetWidth(-10)
	end	
	
	if configuration.showResistAir == false then
	    StatResistAir:SetVisible(false)
		StatResistAir:SetWidth(-10)
	end	
	
	--[[if configuration.showVengeance == false then
	    StatVengeance:SetVisible(false)
		StatVengeance:SetWidth(-10)
	end]]
	
	--[[if configuration.showValor == false then
	    StatValor:SetVisible(false)
		StatValor:SetWidth(-10)
	end	]]	
	
	--[[if configuration.showDeflect == false then
	    StatDeflect:SetVisible(false)
		StatDeflect:SetWidth(-10)
	end]]-- 3.0

	Stats = Inspect.Stat()
	if Stats ~= nil then	
			Strength = Inspect.Stat("strength")
			Dexterity = Inspect.Stat("dexterity")
			Intelligence = Inspect.Stat("intelligence")
			Wisdom = Inspect.Stat("wisdom")
			Endurance = Inspect.Stat("endurance")
			Armor = Inspect.Stat("armor")
			PowerAttack = Inspect.Stat("powerAttack")
			CritAttack = Inspect.Stat("critAttack")
			PowerSpell = Inspect.Stat("powerSpell")
			CritSpell = Inspect.Stat("critSpell")
			CritPower = Inspect.Stat("critPower")
			Hit = Inspect.Stat("hit")
			Block = Inspect.Stat("block")
			Guard = Inspect.Stat("guard")
			Dodge = Inspect.Stat("dodge")
			--Toughness = Inspect.Stat("toughness")   -- 3.0
			ResistLife = Inspect.Stat("resistLife")
			ResistDeath = Inspect.Stat("resistDeath")
			ResistFire = Inspect.Stat("resistLife")
			ResistWater = Inspect.Stat("resistWater")
			ResistEarth = Inspect.Stat("resistEarth")
			ResistAir = Inspect.Stat("resistAir")
			--Vengeance = Inspect.Stat("vengeance")
			--Valor = Inspect.Stat("valor")
			--Deflect = Inspect.Stat("deflect") -- 3.0
		
			if configuration.showStrength == true then
				StatStrength:SetText("Strength:" .. " " .. Strength)
			end
			if configuration.showDexterity == true then
				StatDexterity:SetText("Dexterity:" .. " " .. Dexterity)	
			end
			if configuration.showIntelligence == true then
				StatIntelligence:SetText("Intelligence:" .. " " .. Intelligence)
			end
			if configuration.showWisdom == true then
				StatWisdom:SetText("Wisdom:" .. " " .. Wisdom)	
			end
			if configuration.showEndurance == true then	
				StatEndurance:SetText("Endurance:" .. " " .. Endurance)
			end
			if configuration.showArmor == true then
				StatArmor:SetText("Armor:" .. " " .. Armor)
			end
			if configuration.showPowerAttack == true then
				StatPowerAttack:SetText("AP:" .. " " .. PowerAttack)
			end
			if configuration.showCritAttack == true then
				StatCritAttack:SetText("Physical Crit:" .. " " .. CritAttack)
			end
			if configuration.showPowerSpell == true then
				StatPowerSpell:SetText("SP:" .. " " .. PowerSpell)
			end
			if configuration.showCritSpell == true then
				StatCritSpell:SetText("Spell Crit:" .. " " .. CritSpell)
			end
			if configuration.showCritPower == true then
				StatCritPower:SetText("CP:" .. " " .. CritPower)
			end
			if configuration.showHit == true then
				StatHit:SetText("Hit:" .. " " .. Hit)
			end
			if configuration.showBlock == true then
				StatBlock:SetText("Block:" .. " " .. Armor)
			end
			if configuration.showGuard == true then
				StatGuard:SetText("Guard:" .. " " .. Guard)
			end
			if configuration.showDodge == true then
				StatDodge:SetText("Dodge:" .. " " .. Dodge)
			end
			--[[if configuration.showToughness == true then
				StatToughness:SetText("Toughness:" .. " " .. Toughness)
			end]]   -- 3.0
			if configuration.showResistLife == true then
				StatResistLife:SetText("Life Resist:" .. " " .. ResistLife)
			end
			if configuration.showResistDeath == true then
				StatResistDeath:SetText("Death Resist:" .. " " .. ResistDeath)
			end
			if configuration.showResistFire == true then
				StatResistFire:SetText("Fire Resist:" .. " " .. ResistFire)
			end
			if configuration.showResistWater == true then
				StatResistWater:SetText("Water Resist:" .. " " .. ResistWater)
			end
			if configuration.showResistEarth == true then
				StatResistEarth:SetText("Earth Resist:" .. " " .. ResistEarth)
			end
			if configuration.showResistAir == true then
				StatResistAir:SetText("Air Resist:" .. " " .. ResistAir)
			end
			--[[if configuration.showVengeance == true then
				StatVengeance:SetText("Vengeance:" .. " " .. Vengeance)
			end]]
			--[[if configuration.showValor == true then
				StatValor:SetText("Valor:" .. " " .. Valor)
			end]]
			--[[if configuration.showDeflect == true then
				StatDeflect:SetText("Deflect:" .. " " .. Deflect)
			end]]-- 3.0
			local width = 10
			width = width + StatStrength:GetWidth()	+ 10
			width = width + StatDexterity:GetWidth() + 10
			width = width + StatIntelligence:GetWidth() + 10
			width = width + StatWisdom:GetWidth() + 10
			width = width + StatEndurance:GetWidth() + 10
			width = width + StatArmor:GetWidth() + 10
			width = width + StatPowerAttack:GetWidth()	+ 10
			width = width + StatCritAttack:GetWidth() + 10
			width = width + StatPowerSpell:GetWidth() + 10
			width = width + StatCritSpell:GetWidth() + 10
			width = width + StatCritPower:GetWidth() + 10
			width = width + StatHit:GetWidth() + 10
			width = width + StatBlock:GetWidth() + 10
			width = width + StatGuard:GetWidth() + 10
			width = width + StatDodge:GetWidth() + 10
			--width = width + StatToughness:GetWidth() + 10
			width = width + StatResistLife:GetWidth() + 10
			width = width + StatResistDeath:GetWidth() + 10	
			width = width + StatResistFire:GetWidth() + 10
			width = width + StatResistWater:GetWidth() + 10
			width = width + StatResistEarth:GetWidth() + 10	
			width = width + StatResistAir:GetWidth() + 10
			--width = width + StatVengeance:GetWidth() + 10
			--width = width + StatValor:GetWidth() + 10
			--width = width + StatDeflect:GetWidth() + 10	 -- 3.0

		if not  configuration.width then	
			configuration.width = width 	
		elseif width > configuration.width then 
			configuration.width = width 
		end	
	end		
	
function stat (handle, stat)

	Stats = Inspect.Stat()
	if Stats ~= nil then
			Strength = Inspect.Stat("strength")
			Dexterity = Inspect.Stat("dexterity")
			Intelligence = Inspect.Stat("intelligence")
			Wisdom = Inspect.Stat("wisdom")
			Endurance = Inspect.Stat("endurance")
			Armor = Inspect.Stat("armor")
			PowerAttack = Inspect.Stat("powerAttack")
			CritAttack = Inspect.Stat("critAttack")
			PowerSpell = Inspect.Stat("powerSpell")
			CritSpell = Inspect.Stat("critSpell")
			CritPower = Inspect.Stat("critPower")
			Hit = Inspect.Stat("hit")
			Block = Inspect.Stat("block")
			Guard = Inspect.Stat("guard")
			Dodge = Inspect.Stat("dodge")
			--Toughness = Inspect.Stat("toughness") --3.0
			ResistLife = Inspect.Stat("resistLife")
			ResistDeath = Inspect.Stat("resistDeath")
			ResistFire = Inspect.Stat("resistLife")
			ResistWater = Inspect.Stat("resistWater")
			ResistEarth = Inspect.Stat("resistEarth")
			ResistAir = Inspect.Stat("resistAir")
			--Vengeance = Inspect.Stat("vengeance")
			--Valor = Inspect.Stat("valor")
			--Deflect = Inspect.Stat("deflect")   -- 3.0
			
			if configuration.showStrength == true then
				StatStrength:SetText("Strength:" .. " " .. Strength)
			end
			if configuration.showDexterity == true then
				StatDexterity:SetText("Dexterity:" .. " " .. Dexterity)	
			end
			if configuration.showIntelligence == true then
				StatIntelligence:SetText("Intelligence:" .. " " .. Intelligence)
			end
			if configuration.showWisdom == true then
				StatWisdom:SetText("Wisdom:" .. " " .. Wisdom)	
			end
			if configuration.showEndurance == true then	
				StatEndurance:SetText("Endurance:" .. " " .. Endurance)
			end
			if configuration.showArmor == true then
				StatArmor:SetText("Armor:" .. " " .. Armor)
			end
			if configuration.showPowerAttack == true then
				StatPowerAttack:SetText("AP:" .. " " .. PowerAttack)
			end
			if configuration.showCritAttack == true then
				StatCritAttack:SetText("Physical Crit:" .. " " .. CritAttack)
			end
			if configuration.showPowerSpell == true then
				StatPowerSpell:SetText("SP:" .. " " .. PowerSpell)
			end
			if configuration.showCritSpell == true then
				StatCritSpell:SetText("Spell Crit:" .. " " .. CritSpell)
			end
			if configuration.showCritPower == true then
				StatCritPower:SetText("CP:" .. " " .. CritPower)
			end
			if configuration.showHit == true then
				StatHit:SetText("Hit:" .. " " .. Hit)
			end
			if configuration.showBlock == true then
				StatBlock:SetText("Block:" .. " " .. Armor)
			end
			if configuration.showGuard == true then
				StatGuard:SetText("Guard:" .. " " .. Guard)
			end
			if configuration.showDodge == true then
				StatDodge:SetText("Dodge:" .. " " .. Dodge)
			end
			--[[if configuration.showToughness == true then
				StatToughness:SetText("Toughness:" .. " " .. Toughness)
			end]]   -- 3.0
			if configuration.showResistLife == true then
				StatResistLife:SetText("Life Resist:" .. " " .. ResistLife)
			end
			if configuration.showResistDeath == true then
				StatResistDeath:SetText("Death Resist:" .. " " .. ResistDeath)
			end
			if configuration.showResistFire == true then
				StatResistFire:SetText("Fire Resist:" .. " " .. ResistFire)
			end
			if configuration.showResistWater == true then
				StatResistWater:SetText("Water Resist:" .. " " .. ResistWater)
			end
			if configuration.showResistEarth == true then
				StatResistEarth:SetText("Earth Resist:" .. " " .. ResistEarth)
			end
			if configuration.showResistAir == true then
				StatResistAir:SetText("Air Resist:" .. " " .. ResistAir)
			end
			--[[if configuration.showVengeance == true then
				StatVengeance:SetText("Vengeance:" .. " " .. Vengeance)
			end]]
			--[[if configuration.showValor == true then
				StatValor:SetText("Valor:" .. " " .. Valor)
			end]]
			--[[if configuration.showDeflect == true then
				StatDeflect:SetText("Deflect:" .. " " .. Deflect)
			end]]-- 3.0
	end		
end	
	
	table.insert(StatsTemp, Stats)
	table.insert(Event.Stat,{ stat, AddonId, "_stat" })
	
	return wrapper, { resizable={50, 30, 2560, 30} }
	
end

	
local dialog = false

local function ConfigDialog(container)	

	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	local statTabs = UI.CreateFrame("SimpleLifeTabView", "statTabs", container)
	statTabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	statTabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)
	
	local frmStats = UI.CreateFrame("Frame", "StatsDialog", statTabs.tabContent)
	local frmStatsInner = UI.CreateFrame("Frame", "ufConfigInner", frmStats)
	frmStatsInner:SetPoint("TOPLEFT", frmStats, "TOPLEFT", 12, 12)
	frmStatsInner:SetPoint("BOTTOMRIGHT", frmStats, "BOTTOMRIGHT", -12, -12)
	
	local frmOptions = UI.CreateFrame("Frame", "frmOptions", statTabs.tabContent)
	local frmOptionsInner = UI.CreateFrame("Frame", "frmOverrideInner", frmOptions)
	frmOptionsInner:SetPoint("TOPLEFT", frmOptions, "TOPLEFT", 4, 4)
	frmOptionsInner:SetPoint("BOTTOMRIGHT", frmOptions, "BOTTOMRIGHT", -4, -4)

	statTabs:SetTabPosition("top")
	statTabs:AddTab("Stats", frmStats)
	statTabs:AddTab("Options", frmOptions)	
	
	StatsDialog = WT.Dialog(frmStatsInner, 150)
		:TitleY("MANE ")	
		:Checkbox("showStrength", "Show strength", true)
		:Checkbox("showDexterity", "Show dexterity", true)		
		:Checkbox("showIntelligence", "Show intelligence", true)		
		:Checkbox("showWisdom", "Show wisdom", true)
		:Checkbox("showEndurance", "Show endurance", true)
		:Checkbox("showArmor", "Show armor", true)
		:TitleY("OFFINSE")			
		:Checkbox("showPowerAttack", "Show Attack Power", true)
		:Checkbox("showCritAttack", "Show Physical Crit", false)
		:Checkbox("showPowerSpell", "Show Spell Power", true)
		:Checkbox("showCritSpell", "Show Spell Crit", false)
		:Checkbox("showCritPower", "Show Crit Power", true)
		:Checkbox("showHit", "Show Hit", true)
		:Title("")
		:Title("")
		:Title("")
		:Title("")
		:Title("")
		:Title("")
		:TitleY("DEFENSE")			
		:Checkbox("showBlock", "Show Block", false)
		:Checkbox("showGuard", "Show Guard", false)
		:Checkbox("showDodge", "Show dodge", false)
		:TitleY("RESISTENCE")			
		:Checkbox("showResistLife", "Show Life resist", false)		
		:Checkbox("showResistDeath", "Show Death resist", false)		
		:Checkbox("showResistFire", "Show Fire resist", false)
		:Checkbox("showResistWater", "Show Water resist", false)
		:Checkbox("showResistEarth", "Show Earth resist", false)
		:Checkbox("showResistAir", "Show Air resist", false)

	StatsOption = WT.Dialog(frmOptionsInner)	
		:TitleY("Gadgets Options")					
		:Checkbox("showBackground", "Show Background frame", true)
		:ColorPicker("BackgroundColor", "Background Color", 0.07,0.07,0.07,0.85)
		:Checkbox("outlineTextLight", "Show outline(light) text", false)
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 14, true)

end

local function GetConfiguration()
	local config = StatsDialog:GetValues()
	local config2 = StatsOption:GetValues()
	for k,v in pairs(config2) do
		config[k] = v
	end
	return config
end

local function SetConfiguration(config)
	StatsDialog:SetValues(config)
	StatsOption:SetValues(config)
end

	
WT.Gadget.RegisterFactory("StatTextBar",
	{
		name=TXT.gadgetStatTextBar_name,
		description=TXT.gadgetStatTextBar_desc,
		author="Lifeismystery",
		version="1.0.0",
		iconTexAddon="Rift",
		iconTexFile="tumblr.png.dds",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})