local toc, data = ...
local AddonId = toc.identifier

-- Set up standard virtual properties

WT.Unit.CreateVirtualProperty("resource", { "mana", "power", "energy" }, 
	function(unit) 
		return unit.mana or unit.energy or unit.power 
	end)
	
WT.Unit.CreateVirtualProperty("resourceMax", { "manaMax", "power", "energyMax" }, 
	function(unit)
		if unit.power then
			return 100
		else 
			return unit.manaMax or unit.energyMax
		end 
	end)

WT.Unit.CreateVirtualProperty("healthPercent", { "health", "healthMax" ,"blocked", "offline"} ,
	function(unit)
	    if unit.blocked and not unit.health and not unit.healthMax and not unit.offline then
			return 100
		elseif unit.health and unit.healthMax and unit.healthMax > 0 then
			return (unit.health / unit.healthMax) * 100 
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("healthCapPercent", { "healthCap", "healthMax" }, 
	function(unit)
		if unit.healthCap and unit.healthMax and unit.healthCap > 0 then
			return (1 - unit.healthCap / unit.healthMax) * 100 
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("chargePercent", { "charge", "chargeMax" }, 
	function(unit)
		if unit.charge then
			return (unit.charge / (unit.chargeMax or 100)) * 100 
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("primalistFocus", { "focus"}, 
	function(unit)
		if unit.focus then
			return unit.focus
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("resourcePercent", { "mana", "power", "energy", "manaMax", "energyMax" }, 
	function(unit)
		if unit.mana and unit.manaMax and unit.manaMax > 0 then
			return (unit.mana / unit.manaMax) * 100 
		elseif unit.energy and unit.energyMax and unit.energyMax > 0 then
			return (unit.energy / unit.energyMax) * 100 
		elseif unit.power then
			return unit.power 
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("readyStatus", { "ready" }, 
	function(unit)
		if unit.ready == true then 
			return "ready"
		elseif unit.ready == false then
			return "notready"
		else
			return nil
		end
	end)
	
WT.Unit.CreateVirtualProperty("aggroColor", { "aggro", "combat" },
	function(unit)
		if unit.aggro then
			return { r = 0.8, g=0, b = 0, a=1 }
		--elseif unit.combat then
			--return { r = 0.8, g=0.8, b = 0, a=0.6 }
		else
			return { r = 0, g=0, b = 0, a=0.8 }
		end
	end)

WT.Unit.CreateVirtualProperty("dead", { "health", "combat" },
	function(unit)
		if unit.health and unit.health == 0 then
			return "Dead"
		else
			return nil
		end
	end)

WT.Unit.CreateVirtualProperty("rank", { "relation", "tier" },
	function(unit)
		local rel = unit.relation or "neutral"
		local tier = unit.tier or "normal"
		return rel .. tier
	end)
	
WT.Unit.CreateVirtualProperty("tier", { "id", "tier" },
	function(unit)
		local tier = unit.tier or "normal"
		return tier
	end)
	
	WT.Unit.CreateVirtualProperty("tierColor", { "id", "tier" },
	function(unit)
		local tier = unit.tier or "normal"
		if tier == "group" then
		return "group"
		elseif tier == "raid" then
		return "raid"
		end
		
	end)

WT.Unit.CreateVirtualProperty("hostility", { "id", "relation" },
	function(unit)
		if not unit.id then return nil end
		return unit.relation or "neutral"
	end)

WT.Unit.CreateVirtualProperty("pvpAlliance", { "alliance", "pvp" },
	function(unit)
		if not unit.pvp then
			return nil
		else
			return unit.alliance
		end
	end)

WT.Unit.CreateVirtualProperty("pvp", { "id", "pvp" },
	function(unit)
		if unit.pvp then
			return true
		else
			return false
		end
	end)
	
WT.Unit.CreateVirtualProperty("taggedColor", { "tagged", "relation" },
	function(unit)
		if unit.tagged == "other" and unit.relation == "hostile" then
			return { r = 0.4, g = 0.4, b = 0.4, a = 1.0 }
		else
			return { r = 0, g = 0.7, b = 0, a = 1.0 }
		end
	end)
	
WT.Unit.CreateVirtualProperty("absorbPercent", { "absorb", "healthMax" },
	function(unit)
		if unit.absorb and unit.healthMax and unit.healthMax > 0 then
			local absorb = (unit.absorb / unit.healthMax) * 100
			if absorb > 100 then
				return 100
			else
				return absorb
			end
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("healthAbsorbPercent", { "health", "healthMax", "absorb", "absorbPercent" }, 
	function(unit)
		if unit.health and unit.healthMax and unit.absorbPercent and unit.healthMax > 0 and unit.absorbPercent > 0 then
			return ((unit.health / unit.healthMax) * 100 ) + unit.absorbPercent
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("healthAbsorbPercent2", { "health", "healthMax", "absorb", "absorbPercent" }, 
    function(unit)
      if unit.health and unit.healthMax and unit.healthMax > 0 then
         if unit.absorbPercent and unit.absorbPercent > 0 then
            return ((unit.health / unit.healthMax) * 100 ) + unit.absorbPercent
         else 
            return (unit.health / unit.healthMax) * 100
         end
      else
         return nil
      end 
   end)

   -----------------------------------------------------------
   
WT.Unit.CreateVirtualProperty("BorderTextureAggroVisible", {"id", "aggro"},
	function(unit)
		if not unit.id then
			return false
		elseif unit.aggro then
			return true
		else 
			return false
		end
    end)
	
WT.Unit.CreateVirtualProperty("BorderColor", { "playerTarget", "id", "aggro"},
	function(unit)			
		if unit.playerTarget and unit.calling == "mage" then
			return { r = 0.8, g = 0.36, b = 1.0, a = 1.0 }
		elseif unit.playerTarget and unit.calling == "cleric" then
			return { r = 0.47, g = 0.94, b = 0.0, a = 1.0 }
		elseif unit.playerTarget and unit.calling == "rogue" then
			return { r = 1.0, g = 0.86, b = 0.04, a = 1.0 }
		elseif unit.playerTarget and unit.calling == "warrior" then
			return { r = 1.0, g = 0.15, b = 0.15, a = 1.0 }
		elseif  unit.playerTarget  and unit.calling == "primalist" then
			return { r = 0.29, g = 0.83, b = 0.98, a = 1.0  }	
		elseif not unit.playerTarget and unit.id then
		    if unit.aggro then return { r=1, g=0, b =0, a=1 }
			else return { r=0, g=0, b=0, a=1 } end
		else
			return { r=0, g=0, b=0, a=0 }
		end
	end)
	
WT.Unit.CreateVirtualProperty("BorderColorUnitFrame", { "id", "aggro" },
	function(unit)
		if not unit.id then
			return { r = 0, g=0, b = 0, a=0 }
		elseif unit.aggro  then
			return { r=1, g=0, b =0, a=1 }
		elseif not unit.aggro and unit.id then
			return { r = 0, g=0, b = 0, a=1 }
		end
	end)	
	
WT.Unit.CreateVirtualProperty("BorderColorUnitFrame2", { "id", "aggro" },
	function(unit)
		if not unit.id then
			return { r = 0, g=0, b = 0, a=0 }
		elseif unit.id then
			return { r = 0, g=0, b = 0, a=1 }
		end
	end)	
	   
WT.Unit.CreateVirtualProperty("BorderTextureTargetVisible", {"playerTarget"},
	function(unit)
		if unit.playerTarget then	
			return true
		else 
			return false
		end
    end)

WT.Unit.CreateVirtualProperty("backgroundColorUnit", { "id", "cleansable", "playerId"},
	function(unit)
		if unit.id == playerId then 
			if unit.cleansable then
				return { r=0.2, g=0.15, b=0.4, a=0.85 } 	
			else
				return {r=0.07,g=0.07,b=0.07, a=0.85}
			end
		else return {r=0.07,g=0.07,b=0.07, a=0.85}
		end	
	end)
	
WT.Unit.CreateVirtualProperty("backgroundColorRaid", { "id", "cleansable"},
	function(unit)
		if unit.cleansable then
			return { r=0.2, g=0.15, b=0.4, a=0.85 }
		elseif unit.id then
			return {r=0.07,g=0.07,b=0.07, a=0.85}
		end
	end)	

WT.Unit.CreateVirtualProperty("FrameAlpha", { "id", "blockedOrOutOfRange"},
	function(unit)
		if unit.blockedOrOutOfRange then
			return {alpha=0.4}	
		else	
			return {alpha=1}
		end
	end)

WT.Unit.CreateVirtualProperty("UnitStatus", { "offline", "afk", "health", "blocked" },
	function(unit)
		if unit.offline then
			return "offline"
		elseif unit.blocked and not unit.health and not unit.healthMax then
			return "-1"
		elseif unit.afk then
			return "afk"
		elseif unit.health and unit.health == 0 then
			return "dead"
		else
			return ""
		end
	end)

WT.Unit.CreateVirtualProperty("Radius", { "id", "radius" },
	function(unit)
		if unit.id and unit.radius then
			return string.format("%.01f", unit.radius) .. "m"
		else
			return ""
		end
	end)
	
WT.Unit.CreateVirtualProperty("borderWigth", { "id" }, 
	function(unit)
		if unit.id then
			return 100 
		else 
			return 100
		end 
	end)

WT.Unit.CreateVirtualProperty("healthPercentColor", { "health", "healthMax", "cleansable", "offline", "blocked" }, 
	function(unit)
		if unit.blocked and not unit.health and not unit.healthMax and not unit.offline then
				return { r=0.22,g=0.55,b=0.06, a=0.85 }	
		elseif unit.offline then
				return {r=0.07,g=0.07,b=0.09, a=0.85}
				
		elseif unit.health and unit.healthMax and unit.healthMax > 0 then
			local healthcalc = (unit.health / unit.healthMax)
			local healthcalcInverse = 1.0 - healthcalc
			
			if  unit.cleansable then
				return { r=0.2, g=0.15, b=0.4, a=0.95 }
			else				
				return  { r = 1.0 * healthcalcInverse , g = 0.55 * healthcalc, b=0.06, a=0.95}
			end	
		end 
	end)	
	
WT.Unit.CreateVirtualProperty("HealthColor", { "id", "cleansable", "health","healthMax" , "offline"},
	function(unit)
		if unit.offline then
			return {r=0.07,g=0.07,b=0.09, a=0.85}
		elseif unit.cleansable then
			return { r=0.2, g=0.15, b=0.4, a=0.85 }
		else
			return  {r=0.22,g=0.55,b=0.06, a=0.85}
		end
	end)

WT.Unit.CreateVirtualProperty("HealthUnitColor", { "id", "cleansable", "playerId" },
	function(unit)
		if unit.id == playerId then 
			if unit.cleansable then
				return { r=0.2, g=0.15, b=0.4, a=0.85 }
			else
				return  {r=0.22,g=0.55,b=0.06, a=0.85}
			end
		else
			return  {r=0.22,g=0.55,b=0.06, a=0.85}
		end
	end)	

WT.Unit.CreateVirtualProperty("HealthCallingColor", { "id", "cleansable", "offline", "calling", "relation", "player"},
	function(unit)
		if unit.player then
				if unit.offline	then
					return { r = 0.3, g = 0.3, b = 0.3, a = 1.0 }
				elseif unit.cleansable then
					return { r=0.2, g=0.15, b=0.4, a=1.0 }	
				elseif unit.calling == "mage" then
					return { r = 0.7, g = 0.26, b = 0.9, a = 0.85}
				elseif  unit.calling == "cleric" then
					return { r = 0.47, g = 0.94, b = 0.0, a = 0.85 }
				elseif  unit.calling == "rogue" then
					return { r = 0.9, g = 0.76, b = 0.04, a = 0.85 }
				elseif  unit.calling == "warrior" then
					return { r = 0.9, g = 0.05, b = 0.05, a = 0.85}
				elseif  unit.calling == "primalist" then
					return { r = 0.29, g = 0.83, b = 0.98, a = 0.85}	
				end	
			else
				if 	unit.relation == "hostile" then
					return { r = 0.81, g = 0.02, b = 0.04, a = 0.85 }
				elseif 	unit.relation == "friendly" then
					return { r = 0.17, g = 1.0, b = 0.01, a = 0.85 }	
				elseif not unit.relation then
					return { r = 1.0, g = 0.93, b = 0, a = 0.85 }
				end
			end
	end)	

WT.Unit.CreateVirtualProperty("NameColor", { "id", "calling", "relation", "offline", "health", "healthMax", "blocked", "player"},
	function(unit)	
		if unit.blocked and not unit.health and not unit.healthMax and not unit.offline then
				return { r = 1, g = 1, b = 1, a = 1.0 }	
		else	
			if unit.player then
				if unit.offline	then
					return { r = 0.3, g = 0.3, b = 0.3, a = 1.0 }
				elseif unit.calling == "mage" then
					return { r = 0.8, g = 0.36, b = 1.0, a = 1.0 }
				elseif  unit.calling == "cleric" then
					return { r = 0.47, g = 0.94, b = 0.0, a = 1.0 }
				elseif  unit.calling == "rogue" then
					return { r = 1.0, g = 0.86, b = 0.04, a = 1.0 }
				elseif  unit.calling == "warrior" then
					return { r = 1.0, g = 0.15, b = 0.15, a = 1.0 }
				elseif  unit.calling == "primalist" then
					return { r = 0.29, g = 0.83, b = 0.98, a = 1.0 }
				end	
			else
				if 	unit.relation == "hostile" then
					return { r = 0.81, g = 0.02, b = 0.04, a = 1.0 }
				elseif 	unit.relation == "friendly" then
					return { r = 0.17, g = 1.0, b = 0.01, a = 1.0 }	
				elseif not unit.relation then
					return { r = 1.0, g = 0.93, b = 0, a = 1.0 }
				end
			end
		end	
	end)
	
WT.Unit.CreateVirtualProperty("NameColor2", { "id", "calling", "relation", "offline", "health", "healthMax", "blocked", "player"},
	function(unit)	
		if unit.blocked and not unit.health and not unit.healthMax and not unit.offline then
			return { r = 1, g = 1, b = 1, a = 1.0 }	
		elseif unit.offline	then
			return { r = 0.3, g = 0.3, b = 0.3, a = 1.0 }
		else 
			return { r = 0.9, g = 0.9, b = 0.9, a = 1.0}
		end		
	end)	
	
WT.Unit.CreateVirtualProperty("visibilityCombo", { "combo", "player"},
	function(unit)	
		if unit.combo then	
			if unit.combo >= 1 then
				return true
			else
				return false	
			end	
		end		
	end)
	
WT.Unit.CreateVirtualProperty("ComboColor", { "combo", "player", "calling"},
	function(unit)	
	if unit.calling == "rogue" then
		if unit.combo == 1 then
			return { r = 0.72, g = 0.98, b = 0.04, a = 1.0 }	
		elseif unit.combo == 2	then
			return { r = 0, g = 1.0, b = 0, a = 1.0 }
		elseif unit.combo == 3	then
			return { r = 1.0, g = 1.0, b = 0, a = 1.0 }
		elseif unit.combo == 4	then
			return { r = 0.98, g = 0.5, b = 0.04, a = 1.0 }
		elseif unit.combo == 5	then
			return { r = 1.0, g = 0, b = 0, a = 1.0 }		
		end	
	elseif 	unit.calling == "warrior" then	
		if unit.combo == 1 then
			return { r = 1.0, g = 1.0, b = 0, a = 1.0 }
		elseif unit.combo == 2	then
			return { r = 0.98, g = 0.5, b = 0.04, a = 1.0 }
		elseif unit.combo == 3	then
			return { r = 1.0, g = 0, b = 0, a = 1.0 }
		end	
	end
	end)	
	
WT.Unit.CreateVirtualProperty("lvlColor", { "id", "level", "lvl", "player"},
	function(unit)	
		if unit.level then
		    if lvl == 0 then return {r = 0.9, g = 0.9, b = 0.9, a = 1.0 } end
			if unit.level == "??" then return {r = 0.9, g = 0, b = 0, a = 1.0 } end
			local xpLevel = unit.level - lvl
			if 	xpLevel == 0  and unit.player then 
				return {r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
			elseif xpLevel >= 5 then
				return {r =0.9 , g = 0, b = 0, a = 1.0 }
			elseif xpLevel > 2 and xpLevel <= 4 then
				return{r =0.9 , g =0.5 , b = 0, a = 1.0 }
			elseif xpLevel >= -2 and xpLevel <= 2 then
				return {r =0.9 , g = 0.9, b = 0, a = 1.0 }
			elseif xpLevel < -2 and xpLevel >= -5 then
				return {r = 0, g = 0.9, b = 0, a = 1.0 }
			else
				return {r = 0.9, g = 0.9, b = 0.9, a = 1.0 }
			end
		end				
	end)	

WT.Unit.CreateVirtualProperty("Tanks", { "id", "role"},
	function(unit)		
		if unit.role == "tank" then
			return true
		else	
			return false
		end	
	end)
	
WT.Unit.CreateVirtualProperty("UnitHealthColorMini", { "id"},
	function(unit)
		if unit.id then
			return { r=1, g=1, b=1, a=1 }
		else
			return {r=0,g=0,b=0, a=0}
		end
end)

WT.Unit.CreateVirtualProperty("inCombat", { "id", "combat" },
	function(unit)
		if unit.combat then
			return true
		else
			return false
		end
	end)
	
WT.Unit.CreateVirtualProperty("notInCombat", { "id", "combat" },
	function(unit)
		if unit.combat then
			return false
		else
			return true
		end
	end)	