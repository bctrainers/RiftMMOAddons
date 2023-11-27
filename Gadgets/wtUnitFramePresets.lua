--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.10.0
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-16T14:06:04Z (lifeismystery)
      -----------------------------------------------------------------     
--]]
--for k,v in pairs(WT) do print(tostring(k).."="..tostring(v)) end
local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local dialog, dialog2 = false
local preview = nil

local listItems = {}
local listItemCount = 0
--[[
local testUnitFrame = 
{
	id = A3C5AEC64D3793518,
	icon = "Data/\\UI\\ability_icons\\soulbind.dds",
	idNew = A3C5AEC64D3793518,
	name= "Soul Recall",
	castingTime = "8.0s",
}

local function OnCastName(unitFrame, castname)
	if castname  then
	if unitFrame.showcastName == true then unitFrame.labelCast:SetText(castname) else end
	if unitFrame.showIcon == false then return 
	else	
		local unit = unitFrame.Unit
		if unitFrame.icon then
			local cbd = Inspect.Unit.UnitFrame(unit.id)
			if cbd then
				if cbd.abilityNew then
					local ad = Inspect.Ability.New.Detail(cbd.abilityNew)
					if ad and ad.icon then
						if ad.icon == PHICON then
						unitFrame.icon:SetVisible(false)
						else
						unitFrame.icon:SetTexture("Rift", ad.icon)
						unitFrame.icon:SetVisible(true)
						end
					else
						unitFrame.icon:SetVisible(false)
					end
				else
					unitFrame.icon:SetVisible(false)
				end
			else
				WT.UnitDatabase.Casting[unit.id] = nil
				WT.Units[unit.id].castName = nil
			end
			if unit.castUninterruptible then
				unitFrame.bar_HP:SetShape(unitFrame.canvasSettings.pathCastbar, unitFrame.canvasSettings.fillCastbarNonInt, unitFrame.canvasSettings.strokeCastbar)
			else
				unitFrame.bar_HP:SetShape(unitFrame.canvasSettings.pathCastbar, unitFrame.canvasSettings.fillCastbar, unitFrame.canvasSettings.strokeCastbar)
			end
		end
		end
	else
		unitFrame.icon:SetVisible(false)
	end
end
local function OncastTime(unitFrame, castTime)
	if castTime then		
	if unitFrame.TimeFormat == "castTime" then
		unitFrame.labelTime:SetText(castTime)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastTime_s(unitFrame, castTime_s)
	if castTime_s then		
	if unitFrame.TimeFormat == "castTime_s" then
		unitFrame.labelTime:SetText(castTime_s)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastTimeShot(unitFrame, castTimeShot)
	if castTimeShot then		
	if unitFrame.TimeFormat == "castTimeShot" then
		unitFrame.labelTime:SetText(castTimeShot)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastTimeShot_s(unitFrame, castTimeShot_s)
	if castTimeShot_s then		
	if unitFrame.TimeFormat == "castTimeShot_s" then
		unitFrame.labelTime:SetText(castTimeShot_s)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastPercent(unitFrame, castPercent)
	if castPercent then
		if unitFrame.bar_HP and unitFrame.Backdrop then	
			local delta = (100 - castPercent) / 100 * unitFrame.realWidth
			if unitFrame.HP_bar_insert == false then delta = -delta end
			unitFrame.bar_HP:SetPoint("TOPLEFT", unitFrame.barMask, "TOPLEFT", delta, 0)
			unitFrame.bar_HP:SetPoint("BOTTOMRIGHT", unitFrame.barMask, "BOTTOMRIGHT", delta, 0)

			unitFrame.bar_HP:SetVisible(true)
			unitFrame.Backdrop:SetVisible(true)
		end
	else
		if unitFrame.bar_HP and unitFrame.Backdrop then
			unitFrame.bar_HP:SetVisible(false)
			unitFrame.Backdrop:SetVisible(false)
		end
	end	
end

function UpdatePreview(configuration)

	local configuration = data.Castbar_GetConfiguration()
	preview.config = configuration
	configuration.iconPositionX = WT.Preview["CastbarPreview_icon"].config.iconPositionX
	configuration.iconPositionY = WT.Preview["CastbarPreview_icon"].config.iconPositionY
	configuration.namePositionX = WT.Preview["CastbarPreview_name"].config.namePositionX
	configuration.namePositionY = WT.Preview["CastbarPreview_name"].config.namePositionY
	configuration.timePositionX = WT.Preview["CastbarPreview_time"].config.timePositionX
	configuration.timePositionY = WT.Preview["CastbarPreview_time"].config.timePositionY

	preview:SetWidth(350)
	preview:SetHeight(80)

	UpdateSliders ()
	data.LayoutCast(preview.frmCast, configuration)
	data.UpdateCast(preview, preview.frmCast, testCast)
	
	preview.frmCast:SetPoint("CENTER", preview, "CENTER")
end

WT.Control.UpdatePreview_Cast = UpdatePreview
]]

local function OnhealthPercent(unitFrame, healthPercent)
	if healthPercent then
		if unitFrame.bar_HP and unitFrame.Backdrop_HP then	
		local unit = unitFrame.Unit
			local delta = (1 - healthPercent) / 100 * (unitFrame.realWidth_HP + 1)
			if unitFrame.HP_bar_insert == false then delta = -delta end
			if healthPercent >= 99.7 then delta = unitFrame.realWidth_HP + 1  end
			unitFrame.bar_HP:SetPoint("TOPLEFT", unitFrame.barMask_HP, "TOPLEFT", delta, 0)
			unitFrame.bar_HP:SetPoint("BOTTOMRIGHT", unitFrame.barMask_HP, "BOTTOMRIGHT", delta, 0)

			unitFrame.bar_HP:SetVisible(true)
			unitFrame.Backdrop_HP:SetVisible(true)
		if unit.calling == "mage" then
			unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r = 0.8, g = 0.36, b = 1.0, a = 0.8 }
			if unitFrame.F1_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox1, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
			if unitFrame.F2_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox2, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
		elseif unit.calling == "cleric" then
			unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r = 0.47, g = 0.94, b = 0.0, a = 0.8}
			if unitFrame.F1_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox1, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
			if unitFrame.F2_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox2, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
		elseif unit.calling == "rogue" then
			unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r=  1.0, g = 0.86, b = 0.04, a = 0.8}
			if unitFrame.F1_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox1, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
			if unitFrame.F2_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox2, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
		elseif unit.calling == "warrior" then
			unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid",r = 1.0, g = 0.15, b = 0.15, a = 0.8}
			if unitFrame.F1_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox1, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
			if unitFrame.F2_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox2, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
		elseif unit.calling == "primalist" then
			unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid",r = 0.29, g = 0.83, b = 0.98, a = 0.8}
			if unitFrame.F1_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox1, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
			if unitFrame.F2_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox2, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end	
		else
			--[[if 	unit.relation == "hostile" then
					unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r = 0.81, g = 0.02, b = 0.04, a = 1.0  }
			elseif 	unit.relation == "friendly" then
					unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r = 0.17, g = 1.0, b = 0.01, a = 1.0  }					
			elseif not unit.relation then
					unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r = 1.0, g = 0.93, b = 0, a = 1.0  }
			end	 ]]	
			unitFrame.canvasSettings.fill_EndBox_Bar = { type = "solid", r = 0.8, g = 0.8, b = 0.8, a = 0.8  }
			if unitFrame.F1_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox1, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F1_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
			if unitFrame.F2_EndBox_Bar then
				if unitFrame.Show_MPE == true then
				unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_EndBox2, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				else
				--unitFrame.F2_EndBox_Bar:SetShape(unitFrame.canvasSettings.path_HP, unitFrame.canvasSettings.fill_EndBox_Bar, unitFrame.canvasSettings.strokeBack)
				end
			end
		end	
			
		end
	else
		if unitFrame.bar_HP and unitFrame.Backdrop_HP then
			unitFrame.bar_HP:SetVisible(false)
			unitFrame.Backdrop_HP:SetVisible(false)
		end
	end	
end

local function OnresourcePercent(unitFrame, resourcePercent)
	if resourcePercent and unitFrame.Show_MPE then
		if unitFrame.bar_MPE and unitFrame.Backdrop_MPE then
			local unit = unitFrame.Unit
			if unit["resourceText"] == TXT.Mana then
			unitFrame.canvasSettings.fill_MPE_back = { type = "solid", r = 0.24, g = 0.49, b = 1.0, a = 1.0  }
			unitFrame.bar_MPE:SetShape(unitFrame.canvasSettings.path_MPEmask, unitFrame.canvasSettings.fill_MPE_back, unitFrame.canvasSettings.stroke_HP)
			elseif unit["resourceText"] == TXT.Energy then 
			unitFrame.canvasSettings.fill_MPE_back = { type = "solid", r = 0.86, g = 0.43, b = 0.88, a = 1.0  }
			unitFrame.bar_MPE:SetShape(unitFrame.canvasSettings.path_MPEmask, unitFrame.canvasSettings.fill_MPE_back, unitFrame.canvasSettings.stroke_HP)
			elseif unit["resourceText"] == TXT.Power then 
			unitFrame.canvasSettings.fill_MPE_back = { type = "solid", r = 0.81, g = 0.58, b = 0.16, a = 1.0 }
			unitFrame.bar_MPE:SetShape(unitFrame.canvasSettings.path_MPEmask, unitFrame.canvasSettings.fill_MPE_back, unitFrame.canvasSettings.stroke_HP)
			elseif unit["resourceText"] == "" then
			unitFrame.canvasSettings.fill_MPE_back = { type = "solid", r = 0.31, g = 0.31, b = 0.31, a = 1.0 }
			unitFrame.bar_MPE:SetShape(unitFrame.canvasSettings.path_MPEmask, unitFrame.canvasSettings.fill_MPE_back, unitFrame.canvasSettings.stroke_HP)
			end		
			local delta = (1 - resourcePercent) / 100 * unitFrame.realWidth_MPE + 1
			if resourcePercent >= 99.7 then delta = unitFrame.realWidth_MPE + 1 end
			if unitFrame.MPE_bar_insert == false then delta = -delta end
			unitFrame.bar_MPE:SetPoint("TOPLEFT", unitFrame.barMask_MPE, "TOPLEFT", delta, 0)
			unitFrame.bar_MPE:SetPoint("BOTTOMRIGHT", unitFrame.barMask_MPE, "BOTTOMRIGHT", delta, 0)
			unitFrame.bar_MPE:SetVisible(true)
			unitFrame.Backdrop_MPE:SetVisible(true)
		end
	elseif unitFrame.Show_MPE and unitFrame.bar_MPE and unitFrame.Backdrop_MPE then	
		local unit = unitFrame.Unit
		if unit and unit["resourceText"] == "" then
			unitFrame.canvasSettings.fill_MPE_back = { type = "solid", r = 0.31, g = 0.31, b = 0.31, a = 1.0 }
			unitFrame.bar_MPE:SetShape(unitFrame.canvasSettings.path_MPEmask, unitFrame.canvasSettings.fill_MPE_back, unitFrame.canvasSettings.stroke_HP)			
			unitFrame.bar_MPE:SetVisible(true)
			unitFrame.Backdrop_MPE:SetVisible(true)
			unitFrame.bar_MPE:SetPoint("TOPLEFT", unitFrame.barMask_MPE, "TOPLEFT", 0, 0)
			unitFrame.bar_MPE:SetPoint("BOTTOMRIGHT", unitFrame.barMask_MPE, "BOTTOMRIGHT", 0, 0)
		else
				if unitFrame.bar_MPE and unitFrame.Backdrop_MPE then
			unitFrame.bar_MPE:SetVisible(false)
			unitFrame.Backdrop_MPE:SetVisible(false)
		end
	end	
	else
		if unitFrame.bar_MPE and unitFrame.Backdrop_MPE then
			unitFrame.bar_MPE:SetVisible(false)
			unitFrame.Backdrop_MPE:SetVisible(false)
		end
	end	
end

local function OnhealthCapPercent(unitFrame, healthCapPercent)
	if healthCapPercent then
		if unitFrame.bar_HealthCap and unitFrame.bar_HP then	
			local delta = (100 - healthCapPercent) / 100 * unitFrame.realWidth_HP
			if unitFrame.HP_bar_insert == true then delta = -delta end
			--if healthCapPercent == 100 then delta = unitFrame.realWidth_HP end
			unitFrame.bar_HealthCap:SetPoint("TOPLEFT", unitFrame.barMask_HealthCap, "TOPLEFT", delta, 0)
			unitFrame.bar_HealthCap:SetPoint("BOTTOMRIGHT", unitFrame.barMask_HealthCap, "BOTTOMRIGHT", delta, 0)

			unitFrame.bar_HealthCap:SetVisible(true)
		end
	else
		if unitFrame.bar_HealthCap and unitFrame.bar_HP then
			unitFrame.bar_HealthCap:SetVisible(false)
		end
	end	
end

local function OnnameShort(unitFrame, nameShort)
	if nameShort then	
		local unit = unitFrame.Unit	
		if unit.level then 
			unitFrame.labelName:SetText(" "..nameShort)
		if unit.blocked and not unit.health and not unit.healthMax and not unit.offline then
				unitFrame.labelName:SetFontColor(1, 1, 1, 1.0)
		else	
			if unit.player then
				if unit.offline	then
					unitFrame.labelName:SetFontColor(0.3, 0.3, 0.3, 1.0 )
				elseif unit.calling == "mage" then
					unitFrame.labelName:SetFontColor(0.8, 0.36, 1.0, 1.0 )
				elseif  unit.calling == "cleric" then
					unitFrame.labelName:SetFontColor(0.47, 0.94, 0.0, 1.0 )
				elseif  unit.calling == "rogue" then
					unitFrame.labelName:SetFontColor( 1.0, 0.86, 0.04, 1.0 )
				elseif  unit.calling == "warrior" then
					unitFrame.labelName:SetFontColor(1.0, 0.15, 0.15, 1.0 )
				elseif  unit.calling == "primalist" then
					unitFrame.labelName:SetFontColor(0.29, 0.83, 0.98, 1.0 )
				end
			else
				if 	unit.relation == "hostile" then
					unitFrame.labelName:SetFontColor(0.81, 0.02, 0.04, 1.0)
				elseif 	unit.relation == "friendly" then
					unitFrame.labelName:SetFontColor(0.17, 1.0, 0.01,1.0)
				elseif not unit.relation then
					unitFrame.labelName:SetFontColor(1.0, 0.93, 0, 1.0)
				end
			end
		end	
			unitFrame.labellvl:SetText(unit.level.."")
			local lvl = WT.Player.level or 1
		    if lvl == 0 then unitFrame.labellvl:SetFontColor(0.9, 0.9, 0.9, 1.0) end
			if unit.level == "??" then unitFrame.labellvl:SetFontColor(0.9, 0, 0, 1.0) 
			else
			local xpLevel = unit.level - lvl
			if 	xpLevel == 0  and unit.player then 
				unitFrame.labellvl:SetFontColor(1.0, 1.0, 1.0, 1.0)
			elseif xpLevel >= 5 then
				unitFrame.labellvl:SetFontColor(0.9 , 0, 0, 1.0)
			elseif xpLevel > 2 and xpLevel <= 4 then
				unitFrame.labellvl:SetFontColor(0.9 ,0.5 , 0, 1.0)
			elseif xpLevel >= -2 and xpLevel <= 2 then
				unitFrame.labellvl:SetFontColor(0.9 , 0.9, 0, 1.0)
			elseif xpLevel < -2 and xpLevel >= -5 then
				unitFrame.labellvl:SetFontColor(0, 0.9, 0, 1.0)
			else
				unitFrame.labellvl:SetFontColor(0.9, 0.9, 0.9, 1.0)
			end
			end
		else
			unitFrame.labelName:SetText("")
			unitFrame.labellvl:SetText("")
		end
	end
end

local function CommaFormat(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function OnHP(unitFrame, healthPercent)
	if healthPercent then
	local unit = unitFrame.Unit	
		if unitFrame.labelHP then	
		local HP = string.format("%0.0f", healthPercent)
		local health = unit.health
		if (health >= 1000000) then 
			health = CommaFormat(string.format("%.1f", health / 1000000)) .. "M" 
		elseif health >= 10000 then
			health = CommaFormat(string.format("%.1f", health / 1000)) .. "K"
		end 
		if healthPercent == 100 then 
		unitFrame.labelHP:SetText(""..health)
		else
		unitFrame.labelHP:SetText(HP.."%".." ".."-".." "..health)
		end
		else
		end
	else
	unitFrame.labelHP:SetText("")	
	end
end

local function OnMPE(unitFrame, resourcePercent)
	if resourcePercent then
		if unitFrame.labelMPE then	
			local unit = unitFrame.Unit
			local MPE = string.format("%0.0f", resourcePercent)
			if unit["resourceText"] == TXT.Mana then
				local mana = unit.mana
				if (mana >= 1000000) then 
					mana = CommaFormat(string.format("%.1f", mana / 1000000)) .. "M" 
				elseif mana >= 1000 then
					mana = CommaFormat(string.format("%.1f", mana / 1000)) .. "K"
				end 
				if resourcePercent == 100 then
				unitFrame.labelMPE:SetText(" "..mana)
				else
				unitFrame.labelMPE:SetText(MPE.."%".." ".."-".." "..mana)
				end
			elseif unit["resourceText"] == TXT.Energy then 
			unitFrame.labelMPE:SetText(string.format("%0.0f", unit.energy))
			elseif unit["resourceText"] == TXT.Power then 
			unitFrame.labelMPE:SetText(string.format("%0.0f", unit.power))
			else 
			unitFrame.labelMPE:SetText("")
			end
		else
		unitFrame.labelMPE:SetText("")
		end
	else
	unitFrame.labelMPE:SetText("")	
	end
end

local function OnInCombat(unitFrame, inCombat)
	if inCombat then
		unitFrame.Combat:SetVisible(true)
	else
		unitFrame.Combat:SetVisible(false)
	end
end

local function OnPvP(unitFrame, pvp)
	if pvp then
		unitFrame.bar_PvP:SetVisible(true)
		unitFrame.bar_PvP:SetShape(unitFrame.canvasSettings.path_PvP, unitFrame.canvasSettings.fill_PvP, unitFrame.canvasSettings.strokeBack)
	else
		unitFrame.bar_PvP:SetVisible(true)
		unitFrame.bar_PvP:SetShape(unitFrame.canvasSettings.path_PvP, unitFrame.canvasSettings.fill_Grey, unitFrame.canvasSettings.strokeBack)
	end
end

local function OnAggro(unitFrame, aggro)
	if aggro then
		unitFrame.bar_aggro:SetVisible(true)
		unitFrame.bar_aggro:SetShape(unitFrame.canvasSettings.path_aggro, unitFrame.canvasSettings.fill_aggro, unitFrame.canvasSettings.strokeBack)
	else
		unitFrame.bar_aggro:SetVisible(false)
		unitFrame.bar_aggro:SetShape(unitFrame.canvasSettings.path_aggro, unitFrame.canvasSettings.fill_Grey, unitFrame.canvasSettings.strokeBack)
	end
end

local function OnguaranteedLoot(unitFrame, guaranteedLoot)
	if guaranteedLoot then
		unitFrame.bar_Rare:SetVisible(true)
		unitFrame.bar_Rare:SetShape(unitFrame.canvasSettings.path_Rare, unitFrame.canvasSettings.fill_Rare, unitFrame.canvasSettings.strokeBack)
	else
		unitFrame.bar_Rare:SetVisible(true)
		unitFrame.bar_Rare:SetShape(unitFrame.canvasSettings.path_Rare, unitFrame.canvasSettings.fill_Grey, unitFrame.canvasSettings.strokeBack)
	end
end

local function OntierColor(unitFrame, tierColor)
	if tierColor == "group" then
		unitFrame.bar_Rare:SetVisible(true)
		unitFrame.bar_Rare:SetShape(unitFrame.canvasSettings.path_Rare, unitFrame.canvasSettings.fill_tierGroup, unitFrame.canvasSettings.strokeBack)
	elseif tierColor == "raid" then
		unitFrame.bar_Rare:SetVisible(true)
		unitFrame.bar_Rare:SetShape(unitFrame.canvasSettings.path_Rare, unitFrame.canvasSettings.fill_tierRaid, unitFrame.canvasSettings.strokeBack)
	else
		unitFrame.bar_Rare:SetShape(unitFrame.canvasSettings.path_Rare, unitFrame.canvasSettings.fill_Grey, unitFrame.canvasSettings.strokeBack)
	end
end

local function OnRangeChange(unitFrame, range)
    if range and unitFrame.text_range == true then

		local unit = unitFrame.Unit
		if unit.id ~= WT.Player.id then	
			if unitFrame.RangeFormat == "rangeShot" then
				Range = string.format("%.0f", range)
			else
				Range = string.format("%.1f", range)
			end
			if range <= 2.9 then
			unitFrame.txtRange:SetText(Range)
			unitFrame.txtRange:SetFontColor(0.6, 1, 0.6, 1)
			unitFrame.Range:SetVisible(true)
			unitFrame.txtRange:SetVisible(true)
			elseif range <= 20 then
			unitFrame.txtRange:SetText(Range)
			unitFrame.txtRange:SetFontColor(1, 1, 0.6, 1)
			unitFrame.Range:SetVisible(true)
			unitFrame.txtRange:SetVisible(true)
			elseif range <= 28 then
			unitFrame.txtRange:SetText(Range)
			unitFrame.txtRange:SetFontColor(1, 1, 0.6, 1)
			unitFrame.Range:SetVisible(true)
			unitFrame.txtRange:SetVisible(true)
			elseif range <= 30 then
			unitFrame.txtRange:SetText(Range)
			unitFrame.txtRange:SetFontColor(1, 0.7, 0.4, 1)
			unitFrame.Range:SetVisible(true)
			unitFrame.txtRange:SetVisible(true)
			elseif range <= 35 then
			unitFrame.txtRange:SetText(Range)
			unitFrame.txtRange:SetFontColor(1, 0.2, 0.2, 1)
			unitFrame.Range:SetVisible(true)
			unitFrame.txtRange:SetVisible(true)
			else            
			unitFrame.txtRange:SetText(Range)
			unitFrame.txtRange:SetFontColor(1, 0.2, 0.2, 1)
			unitFrame.Range:SetVisible(true)
			unitFrame.txtRange:SetVisible(true)
			end
		else
			unitFrame.txtRange:SetText(" ")
			unitFrame.Range:SetVisible(false)
			unitFrame.txtRange:SetVisible(false)
		end
	else
		unitFrame.txtRange:SetText(" ")
		unitFrame.Range:SetVisible(false)
		unitFrame.txtRange:SetVisible(false)
	end
end

local function OnAbsorb(unitFrame, absorbPercent)
	if absorbPercent and unitFrame.bar_absorb then	
		local unit = unitFrame.Unit
			local delta = (absorbPercent/100) * unitFrame.realWidth_HP
			unitFrame.bar_absorb:SetWidth(delta)
			if unitFrame.HP_bar_insert == false then delta = -delta end

			if unitFrame.ToLeft == true then
				unitFrame.bar_absorb:SetPoint("BOTTOMLEFT", unitFrame.Backdrop_HP, "BOTTOMLEFT", unitFrame.offset_absorb, unitFrame.offset_MPE)
			else
				unitFrame.bar_absorb:SetPoint("BOTTOMRIGHT", unitFrame.Backdrop_HP, "BOTTOMRIGHT", -unitFrame.offset_absorb, unitFrame.offset_MPE)
			end

			unitFrame.bar_absorb:SetVisible(true)
	else
		if unitFrame.bar_absorb then
			unitFrame.bar_absorb:SetVisible(false)
		end
	end	
end

local function GetConfiguration()
	--[[local config = {}
	config.unitSpec = dialog.fields[1].control:GetText()
	
	config.HP_bar_Width = dialog.fields[3].control.slider:GetPosition() 
	config.HP_bar_Height = dialog.fields[4].control.slider:GetPosition()
	config.HP_bar_angle = dialog.fields[5].control.slider:GetPosition() 
	config.HP_asy_angles = dialog.fields[6].control:GetChecked()	
	config.HP_bar_color = {dialog.fields[7].control:GetColor() }
	config.HP_bar_backgroundColor = {dialog.fields[8].control:GetColor() }
	config.HP_bar_insert = dialog.fields[9].control:GetChecked()
	
	config.Show_MPE = dialog.fields[11].control:GetChecked()
	config.MPE_bar_Width = dialog.fields[12].control.slider:GetPosition() 
	config.MPE_bar_Height = dialog.fields[13].control.slider:GetPosition()
	config.MPE_bar_angle = dialog.fields[14].control.slider:GetPosition() 
	config.MPE_asy_angles = dialog.fields[15].control:GetChecked()		
	config.MPE_bar_color = {dialog.fields[16].control:GetColor() }
	config.MPE_bar_backgroundColor = {dialog.fields[17].control:GetColor() }
	config.MPE_bar_insert = dialog.fields[18].control:GetChecked()
	config.offset_MPE = dialog.fields[19].control.slider:GetPosition() 
	config.ToLeft = dialog.fields[20].control:GetChecked() 
	
	config.text_name = dialog2.fields[2].control:GetChecked()
	config.textFontSize_name = dialog2.fields[3].control.slider:GetPosition()
	config.font_name = dialog2.fields[4].control:GetText()
	config.text_HP = dialog2.fields[5].control:GetChecked()
	config.textFontSize_HP = dialog2.fields[6].control.slider:GetPosition() 
	config.font_HP = dialog2.fields[7].control:GetText()
	config.text_MPE = dialog2.fields[8].control:GetChecked()
	config.textFontSize_MPE = dialog2.fields[9].control.slider:GetPosition() 
	config.font_MPE = dialog2.fields[10].control:GetText()
	config.text_range = dialog2.fields[11].control:GetChecked()
	config.textFontSize_range = dialog2.fields[12].control.slider:GetPosition() 
	config.font_range = dialog2.fields[13].control:GetText()

	return config]]
	
	local config = dialog:GetValues()
	local config2 = dialog2:GetValues()
	for k,v in pairs(config2) do
		config[k] = v
	end
	return config
end

local function SetConfiguration(config)
	dialog:SetValues(config)
	dialog2:SetValues(config)
	--[[
	WT.Preview["CastbarPreview"].config = config
	WT.Preview["CastbarPreview_icon"].config = config
	WT.Preview["CastbarPreview_time"].config = config
	WT.Preview["CastbarPreview_name"].config = config
	]]
	--UpdatePreview()
end
	
local function ConfigDialog(container)

	--if WT.Preview["CastbarPreview"] == nil then WT.Preview["CastbarPreview"] = {} end
	local lMedia = Library.Media.FindMedia("bar")
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end
	
	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end

	local tabs = UI.CreateFrame("SimpleLifeTabView", "tabs", container)
	tabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	tabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	local frmOptions = UI.CreateFrame("Frame", "frmOptions", tabs.tabContent)
	frmOptions:SetPoint("TOPLEFT", container, "TOPLEFT")
	frmOptions:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	local frmText = UI.CreateFrame("Frame", "frmText", tabs.tabContent)
	frmText:SetPoint("TOPLEFT", container, "TOPLEFT")
	frmText:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	
	tabs:SetTabPosition("top")
	tabs:AddTab("Options", frmOptions)
	tabs:AddTab("Text", frmText)

	
	dialog = WT.Dialog(frmOptions)
		:Checkbox("ToLeft", "Growth direction to left", false)--19
		:Combobox("unitSpec", "Unit to track", "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false)			--1	
		:Title("HP bar Options") --2
		:SliderRange("HP_bar_Width", "HP bar width", 150, 400, 259, true) --3
		:SliderRange("HP_bar_Height", "HP bar height", 10, 100, 15, true)--4
		:SliderRange("HP_bar_angle", "Angle of the HP bar", 0, 180, 135, true)--5	
		:Checkbox("HP_asy_angles", "Asymmetry angles for HP", false)--6		
		:ColorPicker("HP_bar_color", "HP bar color", 0.07, 0.07, 0.07, 0.85 )--7
		:ColorPicker("HP_bar_backgroundColor", "HP bar background color", 0.66, 0.22, 0.22, 1 )--8
		:Checkbox("HP_bar_insert", "HP bar insert", false)--9 
		:Title("Mana/Power/Energy bar Options") --10
		--:Checkbox("Show_MPE", "Show MPE bar", true)--11
		:SliderRange("MPE_bar_Width", "MPE bar width", 150, 400, 230, true) --11
		:SliderRange("MPE_bar_Height", "MPE bar height", 10, 50, 10, true)--12
		:SliderRange("MPE_bar_angle", "Angle of the MPE bar", 0, 180, 45, true)--13	
		:Checkbox("MPE_asy_angles", "Asymmetry angles for MPE", false)--14	
		:ColorPicker("MPE_bar_color", "MPE bar color", 0.07, 0.07, 0.07, 0.85 )--15
		:ColorPicker("MPE_bar_backgroundColor", "MPE bar background color", 0.00, 0.50, 0.94, 1 )--16
		:Checkbox("MPE_bar_insert", "MPE bar insert", false)--17
		:SliderRange("offset_MPE", "MPE offset from HP bar", 0, 10, 3, true) --18
		
	dialog2 = WT.Dialog(frmText)	
		:Title("Text Options") --1
		:Checkbox("text_name", "Show name", true)--2
		:SliderRange("textFontSize_name", "Font Size Name", 6, 50, 12, true)  --3
		:Select("font_name", "Font name", "#Default", lfont, true, onchange) --4
		:Checkbox("text_HP", "Show HP", true)--5
		:SliderRange("textFontSize_HP", "Font Size HP", 6, 50, 12, true)  --6
		:Select("font_HP", "Font hp", "#Default", lfont, true, onchange) --7
		:Checkbox("text_MPE", "Show MPE", true) --8
		:SliderRange("textFontSize_MPE", "Font Size MPE", 6, 50, 12, true)  --9
		:Select("font_MPE", "Font mpe", "#Default", lfont, true, onchange) --10
		:Checkbox("text_range", "Show Range", true) --11
		:SliderRange("textFontSize_range", "Font Size Range", 6, 50, 12, true)  --12
		:Select("font_range", "Font range", "#Default", lfont, true, onchange) --13
		:Combobox("RangeFormat", "Range Format", "rangeShot",
			{
				{text="5", value="rangeShot"},
				{text="5.3", value="rangeFull"},
			}, false) --14
end

local function Create(configuration)

	local UnitFrame = WT.UnitFrame:Create(configuration.unitSpec)	
	UnitFrame.ToLeft = configuration.ToLeft
	
	UnitFrame.HP_bar_Width = configuration.HP_bar_Width
	UnitFrame.HP_bar_Height = configuration.HP_bar_Height
	UnitFrame.HP_bar_angle = configuration.HP_bar_angle
	UnitFrame.HP_bar_color = configuration.HP_bar_color
	UnitFrame.HP_bar_backgroundColor = configuration.HP_bar_backgroundColor
	UnitFrame.HP_bar_insert = configuration.HP_bar_insert
	UnitFrame.HP_asy_angles = configuration.HP_asy_angles
	
	UnitFrame.MPE_bar_Width = configuration.MPE_bar_Width
	UnitFrame.MPE_bar_Height = configuration.MPE_bar_Height
	UnitFrame.MPE_bar_angle = configuration.MPE_bar_angle
	UnitFrame.MPE_bar_color = configuration.MPE_bar_color or {0, 0, 0, 0.85}
	UnitFrame.MPE_bar_backgroundColor = configuration.MPE_bar_backgroundColor or {0.5, 0, 0, 0.85}
	UnitFrame.MPE_bar_insert = configuration.MPE_bar_insert
	UnitFrame.offset_MPE = configuration.offset_MPE
	UnitFrame.MPE_asy_angles = configuration.MPE_asy_angles
	UnitFrame.Show_MPE = configuration.Show_MPE or true
	
	UnitFrame.text_name = configuration.text_name
	UnitFrame.textFontSize_name = configuration.textFontSize_name
	UnitFrame.fontEntry_name = Library.Media.GetFont(configuration.font_name)
	
	UnitFrame.text_HP = configuration.text_HP
	UnitFrame.textFontSize_HP = configuration.textFontSize_HP
	UnitFrame.fontEntry_HP = Library.Media.GetFont(configuration.font_HP)	
	
	UnitFrame.text_MPE = configuration.text_MPE
	UnitFrame.textFontSize_MPE = configuration.textFontSize_MPE
	UnitFrame.fontEntry_MPE = Library.Media.GetFont(configuration.font_MPE)
	
	UnitFrame.text_range = configuration.text_range
	UnitFrame.textFontSize_range = configuration.textFontSize_range
	UnitFrame.fontEntry_range = Library.Media.GetFont(configuration.font_range or "#Default")
	UnitFrame.RangeFormat = configuration.RangeFormat or "rangeShot"
	
	UnitFrame.clickToTarget = configuration.clickToTarget or true
	UnitFrame.contextMenu = configuration.contextMenu or true
				
	UnitFrame.canvasSettings = {
		angle_HP = configuration.HP_bar_angle or 0, -- угол наклона в градусах, 0 - вертикально, 45/135 - по диагонали, допустимые значения 0-180
		angle_MPE = configuration.MPE_bar_angle or 0,
		unitFrameIndent = 0, -- размер отступа от бека до бара
		strokeBack = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		stroke_HP = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		stroke_step = { r = 0.7, g = 0.7, b = 0.7, a = 1, thickness = 0.85 },
		stroke_HealthCap = { r = 0, g = 0, b = 0, a = 1, thickness = 0},
		fill_HP = { type = "solid", r = UnitFrame.HP_bar_color[1], g = UnitFrame.HP_bar_color[2], b = UnitFrame.HP_bar_color[3], a = UnitFrame.HP_bar_color[4] },
		fill_HP_back = { type = "solid", r = UnitFrame.HP_bar_backgroundColor[1], g = UnitFrame.HP_bar_backgroundColor[2], b = UnitFrame.HP_bar_backgroundColor[3], a = UnitFrame.HP_bar_backgroundColor[4] },
		fill_HealthCap = { type = "texture", wrap = "clamp", smooth = true, source = AddonId ,  texture = "img/wtGlaze.png" },
		fill_MPE = { type = "solid", r = UnitFrame.MPE_bar_color[1], g = UnitFrame.MPE_bar_color[2], b = UnitFrame.MPE_bar_color[3], a = UnitFrame.MPE_bar_color[4] },
		fill_MPE_back = { type = "solid", r = UnitFrame.MPE_bar_backgroundColor[1], g = UnitFrame.MPE_bar_backgroundColor[2], b = UnitFrame.MPE_bar_backgroundColor[3], a = UnitFrame.MPE_bar_backgroundColor[4] },
		fill_EndBox_Bar = { type = "solid", r = 0.2, g = 0.4, b = 0.6, a = 1.0  },
		fill_PvP = { type = "solid", r = 1.0, g = 0, b = 0, a = 1.0  },
		fill_Rare = { type = "solid", r = 0, g = 0.7, b = 0.7, a = 1.0  },
		fill_absorb = { type = "solid", r = 0.1, g = 0.79, b = 0.79, a = 1.0  } ,
		fill_Grey= { type = "solid", r = 0.3, g = 0.3, b = 0.3, a = 0.85  },
		fill_tierGroup= { type = "solid", r = 1.0, g = 1.0, b = 0, a = 1.0  },
		fill_tierRaid= { type = "solid", r = 1.0, g = 0.5, b = 0, a = 1.0  }, 
		
	}
	
	UnitFrame:SetWidth(UnitFrame.HP_bar_Width)
	UnitFrame:SetHeight(UnitFrame.HP_bar_Height + UnitFrame.MPE_bar_Height + UnitFrame.offset_MPE)

	UnitFrame.Backdrop_HP = UI.CreateFrame("Canvas", "Backdrop_HP", UnitFrame)
	UnitFrame.Backdrop_MPE = UI.CreateFrame("Canvas", "Backdrop_MPE", UnitFrame)
	
	UnitFrame.Backdrop_HP:SetPoint("TOPLEFT", UnitFrame, "TOPLEFT", 0, 0)
	UnitFrame.Backdrop_HP:SetPoint("BOTTOMRIGHT", UnitFrame, "BOTTOMRIGHT", 0, -UnitFrame.MPE_bar_Height -UnitFrame.offset_MPE )
	UnitFrame.Backdrop_HP:SetLayer(1)
	UnitFrame.Backdrop_HP:SetVisible(true)
	UnitFrame.Backdrop_HP:SetWidth(UnitFrame.HP_bar_Width)
	UnitFrame.Backdrop_HP:SetHeight(UnitFrame.HP_bar_Height)
	
	UnitFrame.Backdrop_MPE:SetLayer(1)
	UnitFrame.Backdrop_MPE:SetVisible(true)
	UnitFrame.Backdrop_MPE:SetWidth(UnitFrame.MPE_bar_Width)
	UnitFrame.Backdrop_MPE:SetHeight(UnitFrame.MPE_bar_Height)

	if UnitFrame.HP_bar_angle == 0 and UnitFrame.MPE_bar_angle == 0  then
			UnitFrame.Backdrop_MPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "BOTTOMLEFT", 0, UnitFrame.offset_MPE )
	else
		if UnitFrame.HP_bar_angle > 90 and UnitFrame.MPE_bar_angle < 90 then
			UnitFrame.offset_x = UnitFrame.HP_bar_Height*math.tan(math.rad(180-UnitFrame.HP_bar_angle)) - UnitFrame.MPE_bar_Height*math.tan(math.rad(180-(90+UnitFrame.MPE_bar_angle)))
			UnitFrame.Backdrop_MPE:SetPoint("TOPRIGHT", UnitFrame.Backdrop_HP, "BOTTOMRIGHT", -UnitFrame.offset_x, UnitFrame.offset_MPE )
		elseif UnitFrame.HP_bar_angle < 90 and UnitFrame.MPE_bar_angle > 90 then
			UnitFrame.offset_x = UnitFrame.HP_bar_Height*math.tan(math.rad(180-(90+UnitFrame.HP_bar_angle))) - UnitFrame.MPE_bar_Height*math.tan(math.rad(180-UnitFrame.MPE_bar_angle))
			UnitFrame.Backdrop_MPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "BOTTOMLEFT", UnitFrame.offset_x, UnitFrame.offset_MPE )
		elseif UnitFrame.HP_bar_angle < 90 and UnitFrame.MPE_bar_angle < 90 then
			UnitFrame.offset_x = UnitFrame.HP_bar_Height*math.tan(math.rad(180-(90+UnitFrame.HP_bar_angle))) -- UnitFrame.MPE_bar_Height*math.tan(math.rad(180-(90+UnitFrame.HP_bar_angle)))
			UnitFrame.Backdrop_MPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "BOTTOMLEFT", UnitFrame.offset_x, UnitFrame.offset_MPE )	
		elseif UnitFrame.HP_bar_angle > 90 and UnitFrame.MPE_bar_angle > 90 then
			UnitFrame.offset_x = UnitFrame.HP_bar_Height*math.tan(math.rad(180-UnitFrame.HP_bar_angle)) -- UnitFrame.MPE_bar_Height*math.tan(math.rad(180-(90+UnitFrame.HP_bar_angle)))
			UnitFrame.Backdrop_MPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "BOTTOMLEFT", -UnitFrame.offset_x, UnitFrame.offset_MPE )		
		else
			UnitFrame.Backdrop_MPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "BOTTOMLEFT", 0, UnitFrame.offset_MPE )		
		end

	end

	UnitFrame.barMask_HP = UI.CreateFrame("Mask", "barMask_HP", UnitFrame.Backdrop_HP)
	UnitFrame.barMask_HP:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "TOPLEFT", UnitFrame.canvasSettings.unitFrameIndent, UnitFrame.canvasSettings.unitFrameIndent)
	UnitFrame.barMask_HP:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_HP, "BOTTOMRIGHT", -UnitFrame.canvasSettings.unitFrameIndent, -UnitFrame.canvasSettings.unitFrameIndent)
	UnitFrame.barMask_HP:SetLayer(3)

	UnitFrame.bar_HP = UI.CreateFrame("Canvas", "bar_HP", UnitFrame.barMask_HP)
	UnitFrame.bar_HP:SetPoint("TOPLEFT", UnitFrame.barMask_HP, "TOPLEFT")
	UnitFrame.bar_HP:SetPoint("BOTTOMRIGHT", UnitFrame.barMask_HP, "BOTTOMRIGHT")
	UnitFrame.bar_HP:SetLayer(3)
	
	UnitFrame.barMask_HealthCap = UI.CreateFrame("Mask", "barMask_HealthCap", UnitFrame.Backdrop_HP)
	UnitFrame.barMask_HealthCap:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "TOPLEFT",  UnitFrame.canvasSettings.unitFrameIndent, UnitFrame.canvasSettings.unitFrameIndent)
	UnitFrame.barMask_HealthCap:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_HP, "BOTTOMRIGHT", -UnitFrame.canvasSettings.unitFrameIndent, -UnitFrame.canvasSettings.unitFrameIndent)
	UnitFrame.barMask_HealthCap:SetLayer(4)

	UnitFrame.bar_HealthCap = UI.CreateFrame("Canvas", "bar_HealthCap", UnitFrame.barMask_HealthCap)
	UnitFrame.bar_HealthCap:SetPoint("TOPLEFT", UnitFrame.barMask_HealthCap, "TOPLEFT")
	UnitFrame.bar_HealthCap:SetPoint("BOTTOMRIGHT", UnitFrame.barMask_HealthCap, "BOTTOMRIGHT")
	
	UnitFrame.barMask_MPE = UI.CreateFrame("Mask", "barMask_MPE", UnitFrame.Backdrop_MPE)
	UnitFrame.barMask_MPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_MPE, "TOPLEFT", UnitFrame.canvasSettings.unitFrameIndent, UnitFrame.canvasSettings.unitFrameIndent)
	UnitFrame.barMask_MPE:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_MPE, "BOTTOMRIGHT", -UnitFrame.canvasSettings.unitFrameIndent, -UnitFrame.canvasSettings.unitFrameIndent)
	UnitFrame.barMask_MPE:SetLayer(1)

	UnitFrame.bar_MPE = UI.CreateFrame("Canvas", "bar_MPE", UnitFrame.barMask_MPE)
	UnitFrame.bar_MPE:SetPoint("TOPLEFT", UnitFrame.barMask_MPE, "TOPLEFT")
	UnitFrame.bar_MPE:SetPoint("BOTTOMRIGHT", UnitFrame.barMask_MPE, "BOTTOMRIGHT")
	UnitFrame.bar_MPE:SetLayer(1)

	UnitFrame.F1_EndBox_Bar = UI.CreateFrame("Canvas", "Backdrop_HP", UnitFrame.Backdrop_HP)
	UnitFrame.F1_EndBox_Bar:SetLayer(5)
	UnitFrame.F1_EndBox_Bar:SetVisible(false)

	UnitFrame.bar_PvP = UI.CreateFrame("Canvas", "bar_PvP", UnitFrame.Backdrop_HP)
	UnitFrame.bar_PvP:SetLayer(5)
	UnitFrame.bar_PvP:SetVisible(false)
	UnitFrame.bar_PvP:SetHeight(UnitFrame.Backdrop_HP:GetHeight() * 0.85)

	UnitFrame.bar_Rare = UI.CreateFrame("Canvas", "bar_Rare", UnitFrame.Backdrop_HP)
	UnitFrame.bar_Rare:SetLayer(5)
	UnitFrame.bar_Rare:SetVisible(false)
	UnitFrame.bar_Rare:SetHeight(UnitFrame.Backdrop_HP:GetHeight() * 0.85)
	
	if UnitFrame.HP_bar_angle > 0 then
		UnitFrame.bar_PvP:SetWidth(8)
		UnitFrame.bar_Rare:SetWidth(8)
	else
		UnitFrame.bar_PvP:SetWidth(4)
		UnitFrame.bar_Rare:SetWidth(4)
	end
	
	UnitFrame.bar_step1_HP = UI.CreateFrame("Canvas", "bar_step1_HP", UnitFrame.Backdrop_HP)
	UnitFrame.bar_step1_HP:SetLayer(5)
	UnitFrame.bar_step1_HP:SetVisible(true)
	UnitFrame.bar_step1_HP:SetHeight(UnitFrame.Backdrop_HP:GetHeight() * 0.4)
	UnitFrame.bar_step1_HP:SetWidth(1)

	UnitFrame.bar_step2_HP = UI.CreateFrame("Canvas", "bar_step2_HP", UnitFrame.Backdrop_HP)
	UnitFrame.bar_step2_HP:SetLayer(5)
	UnitFrame.bar_step2_HP:SetVisible(true)
	UnitFrame.bar_step2_HP:SetHeight(UnitFrame.Backdrop_HP:GetHeight() * 0.4)
	UnitFrame.bar_step2_HP:SetWidth(1)
	
	UnitFrame.bar_step1_MPE = UI.CreateFrame("Canvas", "bar_step1_MPE", UnitFrame.Backdrop_MPE)
	UnitFrame.bar_step1_MPE:SetLayer(5)
	UnitFrame.bar_step1_MPE:SetVisible(true)
	UnitFrame.bar_step1_MPE:SetHeight(UnitFrame.Backdrop_MPE:GetHeight() * 0.4)
	UnitFrame.bar_step1_MPE:SetWidth(1)

	UnitFrame.bar_step2_MPE = UI.CreateFrame("Canvas", "bar_step2_MPE", UnitFrame.Backdrop_MPE)
	UnitFrame.bar_step2_MPE:SetLayer(5)
	UnitFrame.bar_step2_MPE:SetVisible(true)
	UnitFrame.bar_step2_MPE:SetHeight(UnitFrame.Backdrop_MPE:GetHeight() * 0.4)
	UnitFrame.bar_step2_MPE:SetWidth(1)
	
	if UnitFrame.HP_bar_angle < 90 then
		UnitFrame.bar_Rare:SetPoint("TOPLEFT", UnitFrame, "TOPLEFT", 20, -1)
		UnitFrame.bar_PvP:SetPoint("TOPLEFT", UnitFrame, "TOPLEFT", 30, -1)
		UnitFrame.bar_step1_HP:SetPoint("TOPRIGHT", UnitFrame, "TOPRIGHT", -UnitFrame.Backdrop_HP:GetWidth()*0.35, 1)
		UnitFrame.bar_step2_HP:SetPoint("TOPRIGHT", UnitFrame, "TOPRIGHT", -UnitFrame.Backdrop_HP:GetWidth()*0.25, 1)

	else
		UnitFrame.bar_Rare:SetPoint("TOPRIGHT", UnitFrame, "TOPRIGHT", -20, -1)
		UnitFrame.bar_PvP:SetPoint("TOPRIGHT", UnitFrame, "TOPRIGHT", -30, -1)
		UnitFrame.bar_step1_HP:SetPoint("TOPLEFT", UnitFrame, "TOPLEFT", UnitFrame.Backdrop_HP:GetWidth()*0.35, 1)
		UnitFrame.bar_step2_HP:SetPoint("TOPLEFT", UnitFrame, "TOPLEFT", UnitFrame.Backdrop_HP:GetWidth()*0.25, 1)
	end

	if UnitFrame.MPE_bar_angle > 90 then
		UnitFrame.bar_step1_MPE:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_MPE, "BOTTOMRIGHT", -UnitFrame.Backdrop_MPE:GetWidth()*0.35, -1)
		UnitFrame.bar_step2_MPE:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_MPE, "BOTTOMRIGHT", -UnitFrame.Backdrop_MPE:GetWidth()*0.25, -1)
	else
		UnitFrame.bar_step1_MPE:SetPoint("BOTTOMLEFT", UnitFrame.Backdrop_MPE, "BOTTOMLEFT", UnitFrame.Backdrop_MPE:GetWidth()*0.35, -1)
		UnitFrame.bar_step2_MPE:SetPoint("BOTTOMLEFT", UnitFrame.Backdrop_MPE, "BOTTOMLEFT", UnitFrame.Backdrop_MPE:GetWidth()*0.25, -1)
	end
	
	UnitFrame.bar_aggro = UI.CreateFrame("Canvas", "bar_aggro", UnitFrame.Backdrop_MPE)
	UnitFrame.bar_aggro:SetLayer(5)
	UnitFrame.bar_aggro:SetVisible(false)
	UnitFrame.bar_aggro:SetHeight(UnitFrame.Backdrop_MPE:GetHeight())
	
	if UnitFrame.MPE_bar_angle ==  UnitFrame.HP_bar_angle and  UnitFrame.MPE_bar_angle > 0 then
		UnitFrame.bar_aggro:SetPoint("CENTER", UnitFrame.bar_MPE, "CENTERRIGHT", -9 + UnitFrame.Backdrop_MPE:GetWidth(), 0)
	elseif UnitFrame.MPE_bar_angle > 90 then
		UnitFrame.bar_aggro:SetPoint("CENTER", UnitFrame.bar_MPE, "CENTERLEFT", 10, 0)
	elseif UnitFrame.HP_bar_angle > 0 then
		UnitFrame.bar_aggro:SetPoint("CENTER", UnitFrame.bar_MPE, "CENTERRIGHT", -10, 0)
	else 
		UnitFrame.bar_aggro:SetPoint("CENTER", UnitFrame.bar_MPE, "CENTERRIGHT", 5+ UnitFrame.Backdrop_MPE:GetWidth(), 0)	
	end
	
	if UnitFrame.HP_bar_angle > 0 then
		UnitFrame.bar_aggro:SetWidth(15)
	else
		UnitFrame.bar_aggro:SetWidth(4)
	end
	
	UnitFrame.bar_absorb = UI.CreateFrame("Canvas", "bar_absorb", UnitFrame)
	UnitFrame.bar_absorb:SetVisible(false)
	UnitFrame.bar_absorb:SetHeight(3)	
	if UnitFrame.HP_bar_angle == 0 then
		UnitFrame.offset_absorb = 0
	elseif UnitFrame.HP_bar_angle > 90 then
		UnitFrame.offset_absorb = UnitFrame.HP_bar_Height*math.tan(math.rad(180-UnitFrame.HP_bar_angle))
	else 
		UnitFrame.offset_absorb = UnitFrame.HP_bar_Height*math.tan(math.rad(180-(90+UnitFrame.HP_bar_angle)))			
	end
	
	if UnitFrame.ToLeft == true then	
		UnitFrame.bar_absorb:SetPoint("BOTTOMLEFT", UnitFrame.Backdrop_HP, "BOTTOMLEFT", UnitFrame.offset_absorb, UnitFrame.offset_MPE)
	else
		UnitFrame.bar_absorb:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_HP, "BOTTOMRIGHT", -UnitFrame.offset_absorb, UnitFrame.offset_MPE)
	end

	if UnitFrame.Show_MPE == true then
		UnitFrame.F1_EndBox_Bar:SetHeight(UnitFrame:GetHeight() + 8)
		UnitFrame.F1_EndBox_Bar:SetWidth(UnitFrame:GetHeight() + 8)
	else
		UnitFrame.F1_EndBox_Bar:SetHeight(UnitFrame.Backdrop_HP:GetHeight())
		UnitFrame.F1_EndBox_Bar:SetWidth(5)
	end
	
	UnitFrame.F2_EndBox_Bar = UI.CreateFrame("Canvas", "Backdrop_HP", UnitFrame.Backdrop_HP)
	UnitFrame.F2_EndBox_Bar:SetLayer(5)
	UnitFrame.F2_EndBox_Bar:SetVisible(false)
	
	if UnitFrame.Show_MPE == true then
		UnitFrame.F2_EndBox_Bar:SetHeight(UnitFrame:GetHeight() + 8)
		UnitFrame.F2_EndBox_Bar:SetWidth(UnitFrame:GetHeight() + 8)
	else
		UnitFrame.F2_EndBox_Bar:SetHeight(UnitFrame.Backdrop_HP:GetHeight())
		UnitFrame.F2_EndBox_Bar:SetWidth(15)
	end
	UnitFrame.Backdrop_HP:SetVisible(false)
	UnitFrame.Backdrop_MPE:SetVisible(false)
	UnitFrame.bar_HealthCap:SetVisible(false)
	
	if UnitFrame.Show_MPE == true then
		if UnitFrame.HP_bar_angle == 0 and UnitFrame.MPE_bar_angle == 0  then
			UnitFrame.F1_EndBox_Bar:SetVisible(false)
			UnitFrame.F2_EndBox_Bar:SetVisible(false)
	else
		if UnitFrame.HP_bar_angle > 90 and UnitFrame.MPE_bar_angle < 90 then
			UnitFrame.F1_EndBox_Bar:SetPoint("BOTTOMLEFT", UnitFrame, "BOTTOMRIGHT", -10, 3)
			UnitFrame.F1_EndBox_Bar:SetVisible(true)
			UnitFrame.F2_EndBox_Bar:SetVisible(false)
		elseif UnitFrame.HP_bar_angle < 90 and UnitFrame.MPE_bar_angle > 90 then
			UnitFrame.F2_EndBox_Bar:SetPoint("BOTTOMRIGHT", UnitFrame, "BOTTOMLEFT", 10, 3)
			UnitFrame.F1_EndBox_Bar:SetVisible(false)
			UnitFrame.F2_EndBox_Bar:SetVisible(true)
		elseif UnitFrame.HP_bar_angle < 90 and UnitFrame.MPE_bar_angle < 90 then
			--
		elseif UnitFrame.HP_bar_angle > 90 and UnitFrame.MPE_bar_angle > 90 then
			--	
		else

		end

	end
	else
		if UnitFrame.ToLeft == true then
			UnitFrame.F2_EndBox_Bar:SetPoint("BOTTOMRIGHT", UnitFrame, "BOTTOMLEFT", 10, 3)
			--UnitFrame.F2_EndBox_Bar:SetVisible(true)
			UnitFrame.F1_EndBox_Bar:SetVisible(false)
		else
			UnitFrame.F1_EndBox_Bar:SetPoint("BOTTOMLEFT", UnitFrame, "BOTTOMRIGHT", -10, 3)
			--UnitFrame.F1_EndBox_Bar:SetVisible(true)
			UnitFrame.F2_EndBox_Bar:SetVisible(false)
		end
	end
	
	--UnitFrame.OnResize = function()
	-----------------------HP---------------------------------------------------
		local tg_HP = math.tan(UnitFrame.canvasSettings.angle_HP * math.pi / 180)
		local offset_HP = tg_HP * UnitFrame.Backdrop_HP:GetHeight() / UnitFrame:GetWidth() / 2
		local indentOffset_HP = tg_HP * UnitFrame.canvasSettings.unitFrameIndent / UnitFrame:GetWidth()
		UnitFrame.realWidth_HP = UnitFrame.Backdrop_HP:GetWidth() - math.abs(tg_HP * UnitFrame.Backdrop_HP:GetHeight()) - UnitFrame.canvasSettings.unitFrameIndent * 2
		
		local tg_HP_ass = math.tan(UnitFrame.canvasSettings.angle_HP * math.pi / 180)
		local offset_HP_ass = tg_HP_ass * UnitFrame.Backdrop_HP:GetHeight() / UnitFrame:GetWidth() / 2
		local indentOffset_HP_ass = tg_HP_ass * UnitFrame.canvasSettings.unitFrameIndent / UnitFrame:GetWidth()

		UnitFrame.canvasSettings.path_HP = { 
			{ xProportional = math.abs(offset_HP) - offset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) - offset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) + offset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) + offset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) - offset_HP, yProportional = 0 }
		}
		UnitFrame.canvasSettings.path_HPmask = { 
			{ xProportional = math.abs(offset_HP) - offset_HP + indentOffset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) - offset_HP + indentOffset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) + offset_HP - indentOffset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) + offset_HP - indentOffset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) - offset_HP + indentOffset_HP, yProportional = 0 }
		}
		UnitFrame.canvasSettings.path_HP_ass = { 
		   { xProportional = math.abs(offset_HP_ass) - offset_HP_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_HP_ass) + offset_HP_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_HP_ass) - offset_HP_ass, yProportional = 1 },
		   { xProportional = math.abs(offset_HP_ass) + offset_HP_ass, yProportional = 1 }
		  }	
		UnitFrame.canvasSettings.path_HP_ass_mask = { 
		   { xProportional = math.abs(offset_HP_ass) - offset_HP_ass + indentOffset_HP_ass +offset_HP_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_HP_ass) + offset_HP_ass - indentOffset_HP_ass , yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_HP_ass) - offset_HP_ass - indentOffset_HP_ass, yProportional = 1 },
		   { xProportional = math.abs(offset_HP_ass) + offset_HP_ass + indentOffset_HP_ass + offset_HP_ass, yProportional = 1 }
		}
		-----------------------MPE---------------------------------------------------
		local tg_MPE = math.tan(UnitFrame.canvasSettings.angle_MPE * math.pi / 180)
		local offset_MPE = tg_MPE * UnitFrame.Backdrop_MPE:GetHeight() / UnitFrame:GetWidth() / 2
		local indentOffset_MPE = tg_MPE * UnitFrame.canvasSettings.unitFrameIndent / UnitFrame:GetWidth()
		UnitFrame.realWidth_MPE = UnitFrame.Backdrop_MPE:GetWidth() - math.abs(tg_MPE * UnitFrame.Backdrop_MPE:GetHeight()) - UnitFrame.canvasSettings.unitFrameIndent * 2
		
		local tg_MPE_ass = math.tan(UnitFrame.canvasSettings.angle_MPE * math.pi / 180)
		local offset_MPE_ass = tg_MPE_ass * UnitFrame.Backdrop_MPE:GetHeight() / UnitFrame:GetWidth() / 2
		local indentOffset_MPE_ass = tg_MPE_ass * UnitFrame.canvasSettings.unitFrameIndent / UnitFrame:GetWidth()
		
		UnitFrame.canvasSettings.path_MPE = { 
			{ xProportional = math.abs(offset_MPE) - offset_MPE, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_MPE) - offset_MPE, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_MPE) + offset_MPE, yProportional = 1 },
			{ xProportional = math.abs(offset_MPE) + offset_MPE, yProportional = 1 }
		}
		UnitFrame.canvasSettings.path_MPEmask = { 
			{ xProportional = math.abs(offset_MPE) - offset_MPE + indentOffset_MPE, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_MPE) - offset_MPE + indentOffset_MPE, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_MPE) + offset_MPE - indentOffset_MPE, yProportional = 1 },
			{ xProportional = math.abs(offset_MPE) + offset_MPE - indentOffset_MPE, yProportional = 1 }
		}
		UnitFrame.canvasSettings.path_MPE_ass = { 
		   { xProportional = math.abs(offset_MPE_ass) - offset_MPE_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_MPE_ass) + offset_MPE_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_MPE_ass) - offset_MPE_ass, yProportional = 1 },
		   { xProportional = math.abs(offset_MPE_ass) + offset_MPE_ass, yProportional = 1 }
		  }		  
		UnitFrame.canvasSettings.path_MPE_ass_mask = { 
		   { xProportional = math.abs(offset_MPE_ass) - offset_MPE_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_MPE_ass) + offset_MPE_ass, yProportional = 0 },
		   { xProportional = 1 - math.abs(offset_MPE_ass) - offset_MPE_ass, yProportional = 1 },
		   { xProportional = math.abs(offset_MPE_ass) + offset_MPE_ass, yProportional = 1 }
		}				
		-----------------------EndBox---------------------------------------------------
		UnitFrame.canvasSettings.path_EndBox1 = { 
			{ xProportional = 0, yProportional = 0.6 }, --1
			{ xProportional = 0.6, yProportional = 0 },  --2
			{ xProportional = 0.6, yProportional = 0.25 },--3
			{ xProportional = 0.25, yProportional = 0.6 },--4
			{ xProportional = 0.4, yProportional = 0.75 },--5
			{ xProportional = 0.4, yProportional = 1 },--6
			{ xProportional = 0, yProportional = 0.6 }--7
		}
		UnitFrame.canvasSettings.path_EndBox2 = { 
			{ xProportional = 0.4, yProportional = 0.25 }, --1
			{ xProportional = 0.4, yProportional = 0 },  --2
			{ xProportional = 1, yProportional = 0.6 },--3
			{ xProportional = 0.6, yProportional = 1 },--4
			{ xProportional = 0.6, yProportional = 0.75 },--5
			{ xProportional = 0.75, yProportional = 0.6 },--6
			{ xProportional = 0.4, yProportional = 0.25}--7
		}
		if UnitFrame.canvasSettings.angle_HP == UnitFrame.canvasSettings.angle_MPE then
			if UnitFrame.Show_MPE == false then
			UnitFrame.F1_EndBox_Bar:SetShape(UnitFrame.canvasSettings.path_HP, UnitFrame.canvasSettings.fill_EndBox_Bar, UnitFrame.canvasSettings.strokeBack)
			UnitFrame.F2_EndBox_Bar:SetShape(UnitFrame.canvasSettings.path_HP, UnitFrame.canvasSettings.fill_EndBox_Bar, UnitFrame.canvasSettings.strokeBack)
			end
		else
			if UnitFrame.Show_MPE == true then
			UnitFrame.F1_EndBox_Bar:SetShape(UnitFrame.canvasSettings.path_EndBox1, UnitFrame.canvasSettings.fill_EndBox_Bar, UnitFrame.canvasSettings.strokeBack)
			UnitFrame.F2_EndBox_Bar:SetShape(UnitFrame.canvasSettings.path_EndBox2, UnitFrame.canvasSettings.fill_EndBox_Bar, UnitFrame.canvasSettings.strokeBack)
			elseif UnitFrame.Show_MPE == false then
			UnitFrame.F1_EndBox_Bar:SetShape(UnitFrame.canvasSettings.path_HP, UnitFrame.canvasSettings.fill_EndBox_Bar, UnitFrame.canvasSettings.strokeBack)
			UnitFrame.F2_EndBox_Bar:SetShape(UnitFrame.canvasSettings.path_HP, UnitFrame.canvasSettings.fill_EndBox_Bar, UnitFrame.canvasSettings.strokeBack)
			end
		end

		if UnitFrame.HP_asy_angles == true then
				UnitFrame.Backdrop_HP:SetShape(UnitFrame.canvasSettings.path_HP_ass, UnitFrame.canvasSettings.fill_HP, UnitFrame.canvasSettings.strokeBack)
				UnitFrame.barMask_HP:SetShape(UnitFrame.canvasSettings.path_HP_ass_mask)
				UnitFrame.bar_HP:SetShape(UnitFrame.canvasSettings.path_HP_ass_mask, UnitFrame.canvasSettings.fill_HP_back, UnitFrame.canvasSettings.stroke_HP)
				UnitFrame.barMask_HealthCap:SetShape(UnitFrame.canvasSettings.path_HP_ass_mask)
				UnitFrame.bar_HealthCap:SetShape(UnitFrame.canvasSettings.path_HP_ass_mask, UnitFrame.canvasSettings.fill_HealthCap, UnitFrame.canvasSettings.stroke_HealthCap)
		else
				UnitFrame.Backdrop_HP:SetShape(UnitFrame.canvasSettings.path_HP, UnitFrame.canvasSettings.fill_HP, UnitFrame.canvasSettings.strokeBack)
				UnitFrame.barMask_HP:SetShape(UnitFrame.canvasSettings.path_HPmask)
				UnitFrame.bar_HP:SetShape(UnitFrame.canvasSettings.path_HPmask, UnitFrame.canvasSettings.fill_HP_back, UnitFrame.canvasSettings.stroke_HP)
				UnitFrame.barMask_HealthCap:SetShape(UnitFrame.canvasSettings.path_HPmask)
				UnitFrame.bar_HealthCap:SetShape(UnitFrame.canvasSettings.path_HPmask, UnitFrame.canvasSettings.fill_HealthCap, UnitFrame.canvasSettings.stroke_HealthCap)
		
		end
			
		if UnitFrame.MPE_asy_angles == true then
			UnitFrame.Backdrop_MPE:SetShape(UnitFrame.canvasSettings.path_MPE_ass, UnitFrame.canvasSettings.fill_MPE, UnitFrame.canvasSettings.strokeBack)
			UnitFrame.barMask_MPE:SetShape(UnitFrame.canvasSettings.path_MPE_ass_mask)
			UnitFrame.bar_MPE:SetShape(UnitFrame.canvasSettings.path_MPE_ass_mask, UnitFrame.canvasSettings.fill_MPE_back, UnitFrame.canvasSettings.stroke_HP)
		else
			UnitFrame.Backdrop_MPE:SetShape(UnitFrame.canvasSettings.path_MPE, UnitFrame.canvasSettings.fill_MPE, UnitFrame.canvasSettings.strokeBack)
			UnitFrame.barMask_MPE:SetShape(UnitFrame.canvasSettings.path_MPEmask)
			UnitFrame.bar_MPE:SetShape(UnitFrame.canvasSettings.path_MPEmask, UnitFrame.canvasSettings.fill_MPE_back, UnitFrame.canvasSettings.stroke_HP)
		end
		-----------------------PvP---------------------------------------------------
		local offset_PvP = tg_HP * UnitFrame.bar_PvP:GetHeight() / UnitFrame.bar_PvP:GetWidth() / 2
		UnitFrame.canvasSettings.path_PvP = { 
			{ xProportional = math.abs(offset_PvP) - offset_PvP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_PvP) - offset_PvP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_PvP) + offset_PvP, yProportional = 1 },
			{ xProportional = math.abs(offset_PvP) + offset_PvP, yProportional = 1 },
			{ xProportional = math.abs(offset_PvP) - offset_PvP, yProportional = 0 }
		}
		UnitFrame.bar_PvP:SetShape(UnitFrame.canvasSettings.path_PvP, UnitFrame.canvasSettings.fill_PvP, UnitFrame.canvasSettings.strokeBack)
		-----------------------Rare---------------------------------------------------				
		local offset_Rare = tg_HP * UnitFrame.bar_Rare:GetHeight() / UnitFrame.bar_Rare:GetWidth() / 2
		UnitFrame.canvasSettings.path_Rare = { 
			{ xProportional = math.abs(offset_Rare) - offset_Rare, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_Rare) - offset_Rare, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_Rare) + offset_Rare, yProportional = 1 },
			{ xProportional = math.abs(offset_Rare) + offset_Rare, yProportional = 1 },
			{ xProportional = math.abs(offset_Rare) - offset_Rare, yProportional = 0 }
		}
		UnitFrame.bar_Rare:SetShape(UnitFrame.canvasSettings.path_Rare, UnitFrame.canvasSettings.fill_Rare, UnitFrame.canvasSettings.strokeBack)
		-----------------------Aggro---------------------------------------------------				
		local offset_aggro = tg_MPE * UnitFrame.bar_MPE:GetHeight() / UnitFrame.bar_aggro:GetWidth() / 2
		UnitFrame.canvasSettings.path_aggro = { 
			{ xProportional = math.abs(offset_aggro) - offset_aggro, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_aggro) - offset_aggro, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_aggro) + offset_aggro, yProportional = 1 },
			{ xProportional = math.abs(offset_aggro) + offset_aggro, yProportional = 1 },
			{ xProportional = math.abs(offset_aggro) - offset_aggro, yProportional = 0 }
		}
		UnitFrame.bar_aggro:SetShape(UnitFrame.canvasSettings.path_aggro, UnitFrame.canvasSettings.fill_PvP, UnitFrame.canvasSettings.strokeBack)	
		-----------------------StepHP---------------------------------------------------
		local offset_step1_HP = tg_HP * UnitFrame.bar_step1_HP:GetHeight() / 1 / 2
		UnitFrame.canvasSettings.path_step1_HP = { 
			{ xProportional = math.abs(offset_step1_HP) - offset_step1_HP, yProportional = 0 },
			{ xProportional = math.abs(offset_step1_HP) + offset_step1_HP, yProportional = 1 },
		}
		UnitFrame.bar_step1_HP:SetShape(UnitFrame.canvasSettings.path_step1_HP, nil, UnitFrame.canvasSettings.stroke_step)	
		local offset_step2_HP = tg_HP * UnitFrame.bar_step2_HP:GetHeight() / 1 / 2
		UnitFrame.canvasSettings.path_step2_HP = { 
			{ xProportional = math.abs(offset_step2_HP) - offset_step2_HP, yProportional = 0 },
			{ xProportional = math.abs(offset_step2_HP) + offset_step2_HP, yProportional = 1 },
		}
		UnitFrame.bar_step2_HP:SetShape(UnitFrame.canvasSettings.path_step2_HP, nil, UnitFrame.canvasSettings.stroke_step)		
		-----------------------StepMPE---------------------------------------------------
		local offset_step1_MPE = tg_MPE * UnitFrame.bar_step1_MPE:GetHeight() / 1 / 2
		UnitFrame.canvasSettings.path_step1_MPE = { 
			{ xProportional = math.abs(offset_step1_MPE) - offset_step1_MPE, yProportional = 0 },
			{ xProportional = math.abs(offset_step1_MPE) + offset_step1_MPE, yProportional = 1 },
		}
		UnitFrame.bar_step1_MPE:SetShape(UnitFrame.canvasSettings.path_step1_MPE, nil, UnitFrame.canvasSettings.stroke_step)	
		local offset_step2_MPE = tg_MPE * UnitFrame.bar_step2_MPE:GetHeight() / 1 / 2
		UnitFrame.canvasSettings.path_step2_MPE = { 
			{ xProportional = math.abs(offset_step2_MPE) - offset_step2_MPE, yProportional = 0 },
			{ xProportional = math.abs(offset_step2_MPE) + offset_step2_MPE, yProportional = 1 },
		}
		UnitFrame.bar_step2_MPE:SetShape(UnitFrame.canvasSettings.path_step2_MPE, nil, UnitFrame.canvasSettings.stroke_step)	
------------------------------Absorb---------------------------------
		
		local offset_absorb = tg_HP * UnitFrame.bar_absorb:GetHeight() / UnitFrame:GetWidth() / 2
		local indentOffset_HP = tg_HP * UnitFrame.canvasSettings.unitFrameIndent / UnitFrame:GetWidth()
		UnitFrame.realWidth_absorb = UnitFrame:GetWidth() - math.abs(tg_HP * UnitFrame.bar_absorb:GetHeight()) - UnitFrame.canvasSettings.unitFrameIndent * 2

		UnitFrame.canvasSettings.path_absorb = { 
			{ xProportional = math.abs(offset_absorb) - offset_absorb, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_absorb) - offset_absorb, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_absorb) + offset_absorb, yProportional = 1 },
			{ xProportional = math.abs(offset_absorb) + offset_absorb, yProportional = 1 },
			{ xProportional = math.abs(offset_absorb) - offset_absorb, yProportional = 0 }
		}	
		UnitFrame.bar_absorb:SetShape(UnitFrame.canvasSettings.path_absorb, UnitFrame.canvasSettings.fill_absorb, UnitFrame.canvasSettings.stroke_HP)		
		
	--end
	--UnitFrame.OnResize()
	
	if UnitFrame.text_name == true then 
		UnitFrame.labelName = UI.CreateFrame("Text", "labelName", UnitFrame.Backdrop_HP)
		UnitFrame.labelName:SetLayer(6)
		UnitFrame.labelName:SetText("")
		UnitFrame.labelName:SetEffectGlow({ strength = 3 })
		UnitFrame.labelName:SetFontSize(UnitFrame.textFontSize_name or 12)
		UnitFrame.labelName:SetFont(UnitFrame.fontEntry_name.addonId, UnitFrame.fontEntry_name.filename)
		
		if UnitFrame.HP_bar_angle == 0 then
			UnitFrame.offset_name = 0
		elseif UnitFrame.HP_bar_angle > 90 then
			UnitFrame.offset_name = UnitFrame.HP_bar_Height*math.tan(math.rad(180-UnitFrame.HP_bar_angle))
		else 
			UnitFrame.offset_name = UnitFrame.HP_bar_Height*math.tan(math.rad(180-(90+UnitFrame.HP_bar_angle)))			
		end
	
		if UnitFrame.ToLeft == false then
			UnitFrame.labelName:SetPoint("BOTTOMLEFT", UnitFrame.Backdrop_HP, "TOPLEFT", UnitFrame.HP_bar_Height + UnitFrame.offset_name, 0)
		else
			UnitFrame.labelName:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_HP, "TOPRIGHT", -UnitFrame.HP_bar_Height, 0)
		end
				
		UnitFrame.labellvl = UI.CreateFrame("Text", "labellvl", UnitFrame.Backdrop_HP)
		UnitFrame.labellvl:SetLayer(6)
		UnitFrame.labellvl:SetText("")
		UnitFrame.labellvl:SetEffectGlow({ strength = 3 })
		UnitFrame.labellvl:SetFontSize(UnitFrame.textFontSize_name or 12)
		UnitFrame.labellvl:SetFont(UnitFrame.fontEntry_name.addonId, UnitFrame.fontEntry_name.filename)
		UnitFrame.labellvl:SetPoint("TOPRIGHT", UnitFrame.labelName, "TOPLEFT", 0, 0)
		
		UnitFrame:CreateBinding("nameShort", UnitFrame, OnnameShort, nil)
	end
	if UnitFrame.text_HP == true then 
		UnitFrame.labelHP = UI.CreateFrame("Text", "labelHP", UnitFrame.Backdrop_HP)
		UnitFrame.labelHP:SetLayer(6)
		UnitFrame.labelHP:SetText("")
		UnitFrame.labelHP:SetEffectGlow({ strength = 3 })
		UnitFrame.labelHP:SetFontSize(UnitFrame.textFontSize_HP or 12)
		UnitFrame.labelHP:SetFont(UnitFrame.fontEntry_HP.addonId, UnitFrame.fontEntry_HP.filename)
		if UnitFrame.ToLeft == true then
		UnitFrame.labelHP:SetPoint("BOTTOMLEFT", UnitFrame.Backdrop_HP, "TOPLEFT", 0, 2)
		else
		UnitFrame.labelHP:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_HP, "TOPRIGHT", 2, 2)
		end
		UnitFrame:CreateBinding("healthPercent", UnitFrame, OnHP, nil)
	end
	if UnitFrame.text_MPE == true then 
		UnitFrame.labelMPE = UI.CreateFrame("Text", "labelMPE", UnitFrame.Backdrop_HP)
		UnitFrame.labelMPE:SetLayer(6)
		UnitFrame.labelMPE:SetText("")
		UnitFrame.labelMPE:SetEffectGlow({ strength = 3 })
		UnitFrame.labelMPE:SetFontSize(UnitFrame.textFontSize_MPE or 12)
		UnitFrame.labelMPE:SetFont(UnitFrame.fontEntry_MPE.addonId, UnitFrame.fontEntry_MPE.filename)
		if UnitFrame.ToLeft == true then
		UnitFrame.labelMPE:SetPoint("TOPLEFT", UnitFrame.Backdrop_MPE, "BOTTOMLEFT", 0, 0 )
		else
		UnitFrame.labelMPE:SetPoint("TOPRIGHT", UnitFrame.Backdrop_MPE, "BOTTOMRIGHT", 2, 0 )
		end
		UnitFrame:CreateBinding("resourcePercent", UnitFrame, OnMPE, nil)
	end
	if UnitFrame.text_range == true then
		UnitFrame.Range = UI.CreateFrame("Texture", "Range", UnitFrame)
		UnitFrame.Range:SetLayer(1)
		UnitFrame.Range:SetHeight(20)
		UnitFrame.Range:SetWidth(20)
		if UnitFrame.ToLeft == true then
			UnitFrame.Range:SetPoint("TOPLEFT", UnitFrame.Backdrop_HP, "TOPLEFT", -UnitFrame.F2_EndBox_Bar:GetWidth() + 10, -10)
			UnitFrame.Range:SetTexture(AddonId, "img/icons/DoubleArrow.png")
			else
			UnitFrame.Range:SetPoint("TOPRIGHT", UnitFrame.Backdrop_HP, "TOPRIGHT", UnitFrame.F1_EndBox_Bar:GetWidth() - 10, -10)
			UnitFrame.Range:SetTexture(AddonId, "img/icons/DoubleArrow2.png")
			end		
		UnitFrame.txtRange = UI.CreateFrame("Text", "txtRange", UnitFrame)
		UnitFrame.txtRange:SetLayer(1)
		UnitFrame.txtRange:SetText("")
		UnitFrame.txtRange:SetEffectGlow({ strength = 3 })
		UnitFrame.txtRange:SetFontSize(UnitFrame.textFontSize_range or 12)
		UnitFrame.txtRange:SetFont(UnitFrame.fontEntry_range.addonId, UnitFrame.fontEntry_range.filename)
		if UnitFrame.ToLeft == true then
			UnitFrame.txtRange:SetPoint("TOPRIGHT", UnitFrame.Range, "TOPRIGHT", -20, 3)
			else
			UnitFrame.txtRange:SetPoint("TOPLEFT", UnitFrame.Range, "TOPLEFT", 20, 3)
			end
		UnitFrame.Range:SetVisible(false)
		
		UnitFrame:CreateBinding("range", UnitFrame, OnRangeChange, nil)
	end
	
	UnitFrame.Combat = UI.CreateFrame("Texture", "Combat", UnitFrame)
	UnitFrame.Combat:SetLayer(1)
	UnitFrame.Combat:SetVisible(false)	
	if UnitFrame.ToLeft == true then
		UnitFrame.Combat:SetPoint("BOTTOMLEFT", UnitFrame.Backdrop_MPE, "BOTTOMLEFT", -UnitFrame.F2_EndBox_Bar:GetWidth() + 10, 0)
		UnitFrame.Combat:SetTexture(AddonId, "img/icons/Sword.png")
	else
		UnitFrame.Combat:SetPoint("BOTTOMRIGHT", UnitFrame.Backdrop_MPE, "BOTTOMRIGHT", UnitFrame.F1_EndBox_Bar:GetWidth() - 10, 0)
		UnitFrame.Combat:SetTexture(AddonId, "img/icons/Sword2.png")
	end

	UnitFrame:CreateBinding("healthPercent", UnitFrame, OnhealthPercent, nil)
	UnitFrame:CreateBinding("resourcePercent", UnitFrame, OnresourcePercent, nil)
	UnitFrame:CreateBinding("healthCapPercent", UnitFrame, OnhealthCapPercent, nil)
	UnitFrame:CreateBinding("inCombat", UnitFrame, OnInCombat, nil)
	UnitFrame:CreateBinding("pvp", UnitFrame, OnPvP, nil)
	UnitFrame:CreateBinding("guaranteedLoot", UnitFrame, OnguaranteedLoot, nil)
	UnitFrame:CreateBinding("tierColor", UnitFrame, OntierColor, nil)
	UnitFrame:CreateBinding("aggro", UnitFrame, OnAggro, nil)
	UnitFrame:CreateBinding("absorbPercent", UnitFrame, OnAbsorb, nil)

	UnitFrame:SetSecureMode("restricted")
	UnitFrame:SetMouseoverUnit(UnitFrame.UnitSpec)

	if UnitFrame.clickToTarget then
		UnitFrame.Event.LeftClick = "target @" .. UnitFrame.UnitSpec
	end
	
	if UnitFrame.contextMenu then 
		UnitFrame.Event.RightClick = 
			function() 
				if UnitFrame.UnitId then 
					Command.Unit.Menu(UnitFrame.UnitId) 
				end 
			end 
	end
	
	return UnitFrame --, { resizable = { 200, 30, 1000, 100 } }
end

local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	assert(gadgetConfig.type == "UnitFramePresets", "Reconfigure Gadget is not a UnitFramePresets")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false
	
	if gadgetConfig.unitSpec ~= config.unitSpec then
		gadgetConfig.unitSpec = config.unitSpec
		requireRecreate = true
	end
		
	if gadgetConfig.HP_bar_Width ~= config.HP_bar_Width then
		gadgetConfig.HP_bar_Width = config.HP_bar_Width
		requireRecreate = true
	end	
	if gadgetConfig.HP_bar_Height ~= config.HP_bar_Height then
		gadgetConfig.HP_bar_Height = config.HP_bar_Height
		requireRecreate = true
	end
	if gadgetConfig.HP_bar_angle ~= config.HP_bar_angle then
		gadgetConfig.HP_bar_angle = config.HP_bar_angle
		requireRecreate = true
	end
	if gadgetConfig.HP_asy_angles ~= config.HP_asy_angles then
		gadgetConfig.HP_asy_angles = config.HP_asy_angles
		requireRecreate = true
	end	
	if gadgetConfig.HP_bar_color ~= config.HP_bar_color then
		gadgetConfig.HP_bar_color = config.HP_bar_color
		requireRecreate = true
	end
	if gadgetConfig.HP_bar_backgroundColor ~= config.HP_bar_backgroundColor then
		gadgetConfig.HP_bar_backgroundColor = config.HP_bar_backgroundColor
		requireRecreate = true
	end
	if gadgetConfig.HP_bar_insert ~= config.HP_bar_insert then
		gadgetConfig.HP_bar_insert = config.HP_bar_insert
		requireRecreate = true
	end
	if gadgetConfig.MPE_bar_Width ~= config.MPE_bar_Width then
		gadgetConfig.MPE_bar_Width = config.MPE_bar_Width
		requireRecreate = true
	end
	if gadgetConfig.MPE_bar_Height ~= config.MPE_bar_Height then
		gadgetConfig.MPE_bar_Height = config.MPE_bar_Height
		requireRecreate = true
	end
	if gadgetConfig.MPE_bar_angle ~= config.MPE_bar_angle then
		gadgetConfig.MPE_bar_angle = config.MPE_bar_angle
		requireRecreate = true
	end
	if gadgetConfig.MPE_asy_angles ~= config.MPE_asy_angles then
		gadgetConfig.MPE_asy_angles = config.MPE_asy_angles
		requireRecreate = true
	end
	if gadgetConfig.MPE_bar_color ~= config.MPE_bar_color then
		gadgetConfig.MPE_bar_color = config.MPE_bar_color
		requireRecreate = true
	end
	if gadgetConfig.MPE_bar_backgroundColor ~= config.MPE_bar_backgroundColor then
		gadgetConfig.MPE_bar_backgroundColor = config.MPE_bar_backgroundColor
		requireRecreate = true
	end	
	if gadgetConfig.MPE_bar_insert ~= config.MPE_bar_insert then
		gadgetConfig.MPE_bar_insert = config.MPE_bar_insert
		requireRecreate = true
	end
	if gadgetConfig.offset_MPE ~= config.offset_MPE then
		gadgetConfig.offset_MPE = config.offset_MPE
		requireRecreate = true
	end

	if gadgetConfig.text_name ~= config.text_name then
		gadgetConfig.text_name = config.text_name
		requireRecreate = true
	end	
	if gadgetConfig.textFontSize_name ~= config.textFontSize_name then
		gadgetConfig.textFontSize_name = config.textFontSize_name
		requireRecreate = true
	end
	if gadgetConfig.font_name ~= config.font_name then
		gadgetConfig.font_name = config.font_name
		requireRecreate = true
	end
	if gadgetConfig.text_HP ~= config.text_HP then
		gadgetConfig.text_HP = config.text_HP
		requireRecreate = true
	end	
	if gadgetConfig.textFontSize_HP ~= config.textFontSize_HP then
		gadgetConfig.textFontSize_HP = config.textFontSize_HP
		requireRecreate = true
	end
	if gadgetConfig.font_HP ~= config.font_HP then
		gadgetConfig.font_HP = config.font_HP
		requireRecreate = true
	end
	if gadgetConfig.text_MPE ~= config.text_MPE then
		gadgetConfig.text_MPE = config.text_MPE
		requireRecreate = true
	end
	if gadgetConfig.textFontSize_MPE ~= config.textFontSize_MPE then
		gadgetConfig.textFontSize_MPE = config.textFontSize_MPE
		requireRecreate = true
	end
	if gadgetConfig.text_range ~= config.text_range then
		gadgetConfig.text_range = config.text_range
		requireRecreate = true
	end
	if gadgetConfig.textFontSize_range ~= config.textFontSize_range then
		gadgetConfig.textFontSize_range = config.textFontSize_range
		requireRecreate = true
	end
	if gadgetConfig.font_range ~= config.font_range then
		gadgetConfig.font_range = config.font_range
		requireRecreate = true
	end
	if gadgetConfig.RangeFormat ~= config.RangeFormat then
		gadgetConfig.RangeFormat = config.RangeFormat
		requireRecreate = true
	end
			
	if requireRecreate then
		WT.Gadget.Delete(gadgetConfig.id)
		WT.Gadget.Create(gadgetConfig)
	end		
end
	
WT.Gadget.RegisterFactory("UnitFramePresets",
	{
		name="UnitFrame Presets",
		description="UnitFrame Presets",
		author="Lifeismystery",
		version="1.1.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCastBar.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
		["Reconfigure"] = Reconfigure,
	})