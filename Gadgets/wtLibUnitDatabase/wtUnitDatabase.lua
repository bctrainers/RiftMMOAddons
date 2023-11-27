--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.51
      Project Date (UTC)  : 2013-10-16T12:02:13Z
      File Modified (UTC) : 2013-09-29T19:33:56Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

--[[
	WT.UnitDatabase
	
		Manages a collection of all currently available units, and maintains unit properties to automatically
		keep them in sync with the client. 

	API
	
		Static Methods
		
			WT.UnitDatabase.GetUnit(unitId)
				Returns a unit from the database, or nil if the unit was not found
				
			WT.UnitDatabase.CreateVirtualProperty(propertyName, dependencies, fn)
				Create a virtual unit property. This will appear to be a normal property to the client.
				propertyName: the unique name of the virtual property to create.
				dependencies: an array of property IDs. A change in any of these properties will trigger the 
				              calculation of the virtual property.
				fn:           a function that returns the value of the property. The function receives the
				              Unit instance as it's only argument.
				              
		Events
		
			WT.Event.UnitAdded(unitId)
				A unit was added to the database

			WT.Event.UnitRemoved(unitId)
				A unit was removed from the database

			WT.Event.BuffAdded(unitId, buffId)
				A buff was added to a unit

			WT.Event.BuffChanged(unitId, buffId)
				A buff was changed on a unit

			WT.Event.BuffRemoved(unitId, buffId)
				A buff was removed from a unit

			WT.Event.CastbarShow(unitId, castbarDetails)
				A unit's castbar has changed or become visible

			WT.Event.CastbarHide(unitId)
				A unit's castbar was hidden

--]]


-- Global store of all WT.Unit instances
WT.Units = {}

WT.PlayerBuffs = {}

-- Hold a reference to the player
playerId = Inspect.Unit.Lookup("player")
WT.Player = { id = playerId }
lvl = WT.Player.level or 0
-- Container for database methods
WT.UnitDatabase = {}
WT.UnitDatabase.Casting = {}




-- Events --------------------------------------------------------------------
WT.Event.Trigger.UnitAdded, WT.Event.UnitAdded = Utility.Event.Create(AddonId, "UnitAdded")
WT.Event.Trigger.UnitRemoved, WT.Event.UnitRemoved = Utility.Event.Create(AddonId, "UnitRemoved")
WT.Event.Trigger.PlayerAvailable, WT.Event.PlayerAvailable = Utility.Event.Create(AddonId, "PlayerAvailable")
WT.Event.Trigger.BuffUpdates, WT.Event.BuffUpdates = Utility.Event.Create(AddonId, "BuffUpdates")
WT.Event.Trigger.CastbarShow, WT.Event.CastbarShow = Utility.Event.Create(AddonId, "CastbarShow")
WT.Event.Trigger.CastbarHide, WT.Event.CastbarHide = Utility.Event.Create(AddonId, "CastbarHide")

WT.Event.Trigger.GroupAdded, WT.Event.GroupAdded = Utility.Event.Create(AddonId, "GroupAdded")
WT.Event.Trigger.GroupRemoved, WT.Event.GroupRemoved = Utility.Event.Create(AddonId, "GroupRemoved")
WT.Event.Trigger.GroupModeChanged, WT.Event.GroupModeChanged = Utility.Event.Create(AddonId, "GroupModeChanged")

local function IsBlackListed(buff)
	if wtxOptions.buffsBlacklist and wtxOptions.buffsBlacklist[buff.name] then
		return true
	else
		return false
	end 
end


local numHotTrackers = 3
local hotTrackers =
{
	role3 = 
	{
		"Motif of Bravery",
		"Motif of Tenacity",
		"Motif of Regeneration",
	},
	role6 = 
	{
		"Soothing Stream",
		"Healing Spray",
		"Healing Flood",
	}
}

local function TriggerBuffUpdates(unitId, changes)
	local unit = WT.Units[unitId]
	WT.Unit.UpdateCleanseStatus(unit)
	WT.Event.Trigger.BuffUpdates(unitId, changes)

	-- Buffs have changed on the unit, update the HoT tracking data	
	-- HoT tracking is restricted to friendly units to save processing
	if unit.relation == "friendly" then
		local role = Inspect.TEMPORARY.Role()
		if role then 
			local htrack = hotTrackers["role" .. role]
			if not htrack then
				for idx = 1,numHotTrackers do
					unit["HoT" .. idx .. "Percent"] = nil
				end
			else
				unit.HoTs = {}
				for idx, hotName in ipairs(htrack) do
					unit.HoTs[idx] = false
					for buffId, buff in pairs(unit.Buffs) do
						if buff.name == hotName then
							unit.HoTs[idx] = buff
						end
					end
				end
			end
		end
	end

end


local function OnBuffAdd(hEvent, unitId, buffs)

	if not buffs then return end
	if not WT.Units[unitId] then return end

	local bdesc = Inspect.Buff.Detail(unitId, buffs)
	--dump(Inspect.Buff.Detail(unitId, buffs))
	local changes = { add = {} }
	
	for buffId, buff in pairs(bdesc) do
	--dump(buff.name, buff.icon)
		buff.unitId = unitId
	
		-- We learn all of the buffs the player is capable of casting in their current role, and store them
		if buff.caster == WT.Player.id and buff.type then
			local roleId = Inspect.TEMPORARY.Role()
			if roleId then
				if not WT.PlayerBuffs[roleId] then
					WT.PlayerBuffs[roleId] = {}
				end
				if not WT.PlayerBuffs[roleId][buff.type] then
					WT.PlayerBuffs[roleId][buff.type] = buff
					WT.Log.Info("Learned player buff for role " .. roleId .. ": " .. buff.name)
				end
			end		
		end
		-- End Buff Learning Logic
	
		if not IsBlackListed(buff) then 
			if not WT.Units[unitId].Buffs[buffId] then
				changes.add[buffId] = buff
				WT.Units[unitId].Buffs[buffId] = buff
			end
		end
	end

	TriggerBuffUpdates(unitId, changes)

end


local function OnBuffRemove(hEvent, unitId, buffs)

	if not buffs then return end
	if not WT.Units[unitId] then return end

	local changes = { remove = {} }
	
	for buffId in pairs(buffs) do
		if WT.Units[unitId].Buffs[buffId] then
			changes.remove[buffId] = WT.Units[unitId].Buffs[buffId]
			WT.Units[unitId].Buffs[buffId] = nil
		end
	end

	TriggerBuffUpdates(unitId, changes)

end


local function OnBuffChange(hEvent, unitId, buffs)

	if not buffs then return end
	if not WT.Units[unitId] then return end

	local changes = { update = {} }

	local bdesc = Inspect.Buff.Detail(unitId, buffs)
	
	for buffId, buff in pairs(bdesc) do
		if not IsBlackListed(buff) then 
			changes.update[buffId] = buff
			WT.Units[unitId].Buffs[buffId] = buff
		end
	end

	TriggerBuffUpdates(unitId, changes)

end


local castColorUninterruptable = { r=0.9, g=0.7, b=0.3, a=1 }
local castColorInterruptable = { r=0.42, g=0.69, b=0.81, a=1 }

local castbarRefresh = {}

local function UpdateCastbarDetails(unitId, cb)
	if cb then
		local unit = WT.Units[unitId] 
		unit.castUninterruptible = cb.uninterruptible or false
		if cb.uninterruptible then
			unit.castColor = castColorUninterruptable
		else
			unit.castColor = castColorInterruptable
		end
		-- Need to store some extra data to handle pushback properly
		WT.Units[unitId].castUpdated = Inspect.Time.Frame()		
		WT.Units[unitId].castRemaining = cb.remaining	
		WT.Units[unitId].castDuration = cb.duration
		unit.castName = cb.abilityName or ""
	else
		WT.Units[unitId].castPercent = nil
		WT.Units[unitId].castColor = nil
		WT.Units[unitId].castUninterruptible = nil
		WT.Units[unitId].castUpdated = nil
		WT.Units[unitId].castDuration = nil
		WT.Units[unitId].castRemaining = nil
		WT.Units[unitId].castExpired = nil
		WT.Units[unitId].castName = nil
	end
end


local function CalculateCastChanges()

	for unitId in pairs(castbarRefresh) do
		WT.UnitDatabase.Casting[unitId] = Inspect.Unit.Castbar(unitId)
		castbarRefresh[unitId] = nil 
	end

	local currTime = Inspect.Time.Frame()
	for unitId, castbar in pairs(WT.UnitDatabase.Casting) do
		local unit = WT.Units[unitId]			
		if unit then
			castbar.remaining = castbar.duration - (Inspect.Time.Frame() - castbar.begin)
			UpdateCastbarDetails(unitId, castbar)
			local percent = 0
			pcall(
				function() 
					if castbar.remaining < 0.05 then castbar.remaining = 0 end
					percent = (1 - (castbar.remaining / castbar.duration)) * 100 
					
					if castbar.channeled then percent = 100 - percent end
					unit.castTime = string.format("%.1f/%.1fs", castbar.duration - castbar.remaining, castbar.duration)
					unit.castTime_s = string.format("%.1f/%.1f", castbar.duration - castbar.remaining, castbar.duration)
					unit.castTimeShot = string.format("%.1f", castbar.remaining)
					unit.castTimeShot_s = string.format("%.1fs", castbar.remaining)
				end)
				--dump(unit.castTime)
			unit.castPercent = percent
			if percent > 99.95 then percent = 100 end
			if percent < 0.05 then percent = 0 end
		end
	end
end


local function OnUnitCastbar(hEvent, units)
	for unitId, cbVisible in pairs(units) do
		if WT.Units[unitId] then
			if cbVisible then
				castbarRefresh[unitId] = true
				--local cb = Inspect.Unit.Castbar(unitId)
				--dump(cb)
				--cb.elapsed = 0
				--cb.remaining = cb.duration
				--cb.begin = Inspect.Time.Frame()
				--[[
				if cb then 
					WT.Units[unitId]._castbar = cb
					WT.Event.Trigger.CastbarShow(unitId, cb)
					WT.UnitDatabase.Casting[unitId] = cb
					UpdateCastbarDetails(unitId, cb)
				end
				--]]
			else
				castbarRefresh[unitId] = nil
				WT.Units[unitId]._castbar = nil
				WT.Event.Trigger.CastbarHide(unitId)
				WT.UnitDatabase.Casting[unitId] = nil
				WT.Units[unitId].castPercent = nil
				WT.Units[unitId].castName = nil
				WT.Units[unitId].castColor = nil
				WT.Units[unitId].castUninterruptible = nil
				WT.Units[unitId].castUpdated = nil
				WT.Units[unitId].castDuration = nil
				WT.Units[unitId].castRemaining = nil
				WT.Units[unitId].castExpired = nil
			end
		end
	end
end


local playerAvailableFired = false

-- This is where the Unit instance is created if unitObject == nil
local function PopulateUnit(unitId, unitObject, omitBuffScan)

	local detail = Inspect.Unit.Detail(unitId)
	if detail then
		local unit = ((unitObject or WT.Units[unitId]) or WT.Unit:Create(unitId)) 
			
		for k,v in pairs(detail) do
			unit[k] = v
		end 
		if not unit.healthMax then 
			unit.partial = true
		else
			unit.partial = false
		end
	--[[
			if detail.focus < 100 then
				unit["primalistFocus"] = detail.focus - 0
				unit["primalistColor"] = { r = 0.66, g = 0.09, b = 0.09, a = 1.0 }
			elseif detail.focus == 100  then
				unit["primalistFocus"] = detail.focus - 100
				unit["primalistColor"] = { r = 0.20, g = 0.15, b = 0.09, a = 1.0 }
			elseif detail.focus > 100  then
				unit["primalistFocus"] = detail.focus - 100
				unit["primalistColor"] = { r = 0.26, g = 0.63, b = 0.73, a = 1.0 }
			end
		]]

		if detail["manaMax"] then 
			unit["resourceName"] = "mana"
			unit["resourceText"] = TXT.Mana
			unit["resourceColor"] = { r = 0.24, g = 0.49, b = 1.0, a = 1.0 }
		elseif detail["energyMax"] then 
			unit["resourceName"] = "energy" 
			unit["resourceText"] = TXT.Energy
			unit["resourceColor"] = { r = 0.86, g = 0.43, b = 0.88, a = 1.0 }
		elseif detail["power"] then 
			unit["resourceName"] = "power"
			unit["resourceText"] = TXT.Power
			unit["resourceColor"] = { r = 0.81, g = 0.58, b = 0.16, a = 1.0 }
		else 
			unit["resourceName"] = "" 
			unit["resourceText"] = ""
			unit["resourceColor"] = { r = 0.31, g = 0.31, b = 0.31, a = 1.0 }
		end

		if detail.calling == "mage" then
			unit.callingColor = { r = 0.8, g = 0.36, b = 1.0, a = 1.0 }
			unit.callingText = TXT.Mage
		elseif detail.calling == "cleric" then
			unit.callingColor = { r = 0.47, g = 0.94, b = 0.0, a = 1.0 }
			unit.callingText = TXT.Cleric
		elseif detail.calling == "rogue" then
			unit.callingColor = { r = 1.0, g = 0.86, b = 0.04, a = 1.0 }
			unit.callingText = TXT.Rogue
		elseif detail.calling == "warrior" then
			unit.callingColor = { r = 1.0, g = 0.15, b = 0.15, a = 1.0 }
			unit.callingText = TXT.Warrior	
		elseif detail.calling == "primalist" then
			unit.callingColor = { r = 0.29, g = 0.83, b = 0.98, a = 1.0 }
			unit.callingText = TXT.Primalist	
		else	
			unit.callingColor = { r = 0.2, g = 0.4, b = 0.6, a = 1.0 }
			unit.callingText = ""

		end

		if unit.name:len() > 20 then
			unit.nameShort = unit.name:sub(1, 15) .. "..."
		else
			unit.nameShort = unit.name
		end
		
		-- remap the coordinate fields into a single table property
		unit.coord = { detail.coordX or 0, detail.coordY or 0, detail.coordZ or 0 }
		WT.Units[unitId] = unit
		
		if not unit.Buffs then unit.Buffs = {} end
					
		-- Fire player available if required
		if unitId == Inspect.Unit.Lookup("player") then 
			WT.Player = unit		
			lvl = WT.Player.level
			if not playerAvailableFired then
				WT.Event.Trigger.PlayerAvailable()
				playerAvailableFired = true
			end 
		end
		
		if unitId == Inspect.Unit.Lookup("player.target") then
			unit.playerTarget = true
					
		--[[local targets = Inspect.Unit.Detail(Inspect.Unit.List()).name)
		for k,v in pairs(targets) do
			unit[k] = v
		end]]
		--dump(Inspect.Unit.Detail(Inspect.Unit.List()).name)
		end 
		--dump(Inspect.Unit.Detail("player").vitality)
		
		-- Add all buffs currently on the unit
		if not omitBuffScan then
			OnBuffRemove(nil, unitId, unit.Buffs)
			OnBuffAdd(nil, unitId, Inspect.Buff.List(unitId))
		end		

		local needsCleanse = false	
		for buffId, buffDetail in pairs(unit.Buffs) do	
		--dump(buffDetail)
			if buffDetail.curse or buffDetail.disease or buffDetail.poison then
				needsCleanse = true
			end
		end
		unit.cleansable = needsCleanse

		return unit
	else
		return nil
	end
end


function WT.UnitDatabase.GetUnit(unitId)

	if WT.Units[unitId] then 
		return WT.Units[unitId]
	else
		return PopulateUnit(unitId)
	end 
	
end

local function OnUnitAvailablePartial(hEvent, units)
	for unitId, spec in pairs(units) do
		if not WT.Units[unitId] then
			local unit = PopulateUnit(unitId, nil, true)
			if unit then 
				WT.Event.Trigger.UnitAdded(unitId) 	
			end
		else
			WT.Units[unitId].partial = true
		end
	end		
end

local function OnUnitAvailable(hEvent, units)
	for unitId, spec in pairs(units) do		
		local unit = PopulateUnit(unitId)
		if unit then
			WT.Event.Trigger.UnitAdded(unitId)			
		end
	end
end

local function OnUnitUnavailable(hEvent, units)
	for unitId in pairs(units) do
		WT.Units[unitId] = nil
		WT.Event.Trigger.UnitRemoved(unitId)
	end
end


-- Sets the property against the relevant unit in the database
local function SetProperty(unitId, property, value)
	if WT.Units[unitId] then
		if property == "healthMax" and WT.Units[unitId].partial then
			-- We now have the full detail for a partially populated unit 
			WT.Units[unitId].partial = false -- we clear the partial details flag when we get healthMax
			PopulateUnit(unitId, WT.Units[unitId]) 
		end 
		WT.Units[unitId][property] = value	
	end
end

local function OnUnitDetailAbsorb(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "absorb", value) end
end

local function OnUnitDetailHealth(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "health", value) end
end

local function OnUnitDetailHealthCap(hEvent, units)
	local unitsValue = Inspect.Unit.Detail(units)
	for unitId,value in pairs(unitsValue) do
		if WT.Units[unitId] then
			WT.Units[unitId].healthCap = value.healthCap
		end
	end
end

local function OnUnitDetailHealthMax(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "healthMax", value) end
end

local function OnUnitDetailMana(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "mana", value) end
end

local function OnUnitDetailManaMax(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "manaMax", value) end
end

local function OnUnitDetailPower(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "power", value) end
end

local function OnUnitDetailEnergy(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "energy", value) end
end

local function OnUnitDetailEnergyMax(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "energyMax", value) end
end

local function OnUnitDetailCharge(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "charge", value) end
end

local function OnUnitDetailChargeMax(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "chargeMax", value) end
end

local function OnUnitDetailAfk(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "afk", value) end
end

local function OnUnitDetailAggro(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "aggro", value) end
end

local function OnUnitDetailBlocked(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "blocked", value) end
end

local function OnUnitDetailCombat(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "combat", value) end
end

local function OnUnitDetailCombo(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "combo", value) end
end

local function OnUnitDetailComboUnit(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "comboUnit", value) end
end

local function OnUnitDetailGuild(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "guild", value) end
end

local function OnUnitDetailLevel(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "level", value) end
end

local function OnUnitDetailLocationName(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "locationName", value) end
end

local function OnUnitDetailMark(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "mark", value) end
end

local function OnUnitDetailName(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "name", value) end
end

local function OnUnitDetailOffline(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "offline", value) end
end

local function OnUnitDetailPlanar(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "planar", value) end
end

local function OnUnitDetailPlanarMax(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "planarMax", value) end
end

local function OnUnitDetailPublicSize(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "publicSize", value) end
end

local function OnUnitDetailPvp(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "pvp", value) end
end

local function OnUnitDetailReady(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "ready", value) end
end

local function OnUnitDetailRole(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "role", value) end
end

local function OnUnitDetailRaceName(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "raceName", value) end
end

local function OnUnitDetailRadius(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "radius", value) end
end

local function OnUnitDetailTagged(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "tagged", value) end
end

local function OnUnitDetailTitlePrefix(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titlePrefix", value) end
end

local function OnUnitDetailTitlePrefixId(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titlePrefixId", value) end
end

local function OnUnitDetailTitlePrefixName(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titlePrefixName", value) end
end

local function OnUnitDetailTitleSuffix(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titleSuffix", value) end
end

local function OnUnitDetailTitleSuffixId(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titleSuffixId", value) end
end

local function OnUnitDetailTitleSuffixName(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titleSuffixName", value) end
end

local function OnUnitDetailVitality(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "vitality", value) end
end

local function OnUnitDetailWarfront(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "warfront", value) end
end

local function OnUnitDetailMentoring(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "mentoring", value) end
end

local function OnUnitDetailZone(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "zone", value) end
end

local function OnUnitDetailCoord(hEvent, xValues, yValues, zValues)
	--local maps = {}	
	for unitId,value in pairs(xValues) do
		SetProperty(unitId, "coord", {xValues[unitId], yValues[unitId], zValues[unitId]}) -- map[1],map[2],map[3]}) -- create an additional property to allow single property position tracking
--		SetProperty(unitId, "coordX", xValues[unitId])
--		SetProperty(unitId, "coordY", yValues[unitId])
--		SetProperty(unitId, "coordZ", zValues[unitId])
	end
end

local function OnUnitDetailRelation(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "relation", value) end
end

local lastRangeCalc = nil
local rangeThrottle = 0.1

local function CalculateRanges()

	if (lastRangeCalc and ((Inspect.Time.Frame() - lastRangeCalc) < rangeThrottle)) then
		return
	end

	lastRangeCalc = Inspect.Time.Frame()

	if not WT.Player or not WT.Player.coord then return end

	local px = WT.Player.coord[1]
	local py = WT.Player.coord[2]
	local pz = WT.Player.coord[3]
	
	for unitId,details in pairs(WT.Units) do
	
	    -- Force a recalculation of the cleansable status
	    WT.Unit.UpdateCleanseStatus(details)
	
		if details.coord then
		
			local ux = details.coord[1] 			
			local uy = details.coord[2] 			
			local uz = details.coord[3]

			local radiusDiff = (WT.Player.radius or 0.5) + (details.radius or 0.5)	
			--dump(radiusDiff)

			local dx = px - ux  			
			local dy = py - uy 			
			local dz = pz - uz			

			local rangeSqr = (dx * dx + dy * dy + dz * dz)
			local oor = not (rangeSqr < ((35+radiusDiff)*(35+radiusDiff)))
			
			if oor and not details.outOfRange then
				details.outOfRange = true
			end
			if not oor and details.outOfRange then
				details.outOfRange = nil
			end
			
			local blocked = details.blocked or details.outOfRange
			if not details.blockedOrOutOfRange and blocked then
				details.blockedOrOutOfRange = true
			end
			if details.blockedOrOutOfRange and not blocked then
				details.blockedOrOutOfRange = nil
			end
			
			local rng = math.sqrt(rangeSqr) - radiusDiff
			if rng < 0 then rng = 0 end
			
			local rngCenter = math.sqrt(rangeSqr) - (WT.Player.radius or 0.5)
			if rngCenter < 0 then rngCenter = 0 end
			
			details.rangeSqr = rangeSqr
			details.range = rng
			details.rangeCenter = rngCenter
		end
	end
end


local function CalculateHoTTrackers()

	local currTime = Inspect.Time.Frame()

	for unitId, unit in pairs(WT.Units) do
		if unit.HoTs then
			for idx, buff in ipairs(unit.HoTs) do
				if not buff then
					unit["HoT" .. idx .. "Percent"] = nil
				else
					if buff.duration then
						local elapsed = currTime - buff.begin
						local remaining = math.floor(buff.duration - elapsed)
						if remaining > 0 then
							local percent = (remaining / buff.duration) * 100
							unit["HoT" .. idx .. "Percent"] = percent
						else
							unit["HoT" .. idx .. "Percent"] = 0
						end
					end	
				end
			end			
		end
	end

end

local function OnSystemUpdateBegin(hEvent)
	CalculateCastChanges()
	CalculateRanges()
	CalculateHoTTrackers()
end

-- Setup Event Handlers
Command.Event.Attach(Event.Unit.Availability.Full,		OnUnitAvailable, "OnUnitAvailable")
Command.Event.Attach(Event.Unit.Availability.Partial,	OnUnitAvailablePartial, "OnUnitAvailablePartial")
Command.Event.Attach(Event.Unit.Availability.None,		OnUnitUnavailable, "OnUnitUnavailable")


-- Register the handlers that will deal with groups being added and removed
local groupMode = "solo"
local groupExists = { }

local function OnGroupMemberChange(unitId)
	local g = {}
	for i = 1,20 do
		local grpid = math.floor(((i-1)/5)+1)
		local uid = Inspect.Unit.Lookup("group" .. string.format("%02d", i))
		if uid then
			g[grpid] = true
		end  
	end
	for grp = 1,4 do
		if g[grp] and not groupExists[grp] then 
			groupExists[grp] = true
			WT.Event.Trigger.GroupAdded(grp)
		end
		if not g[grp] and groupExists[grp] then 
			groupExists[grp] = false
			WT.Event.Trigger.GroupRemoved(grp)
		end
	end

	local mode = "solo"
	if groupExists[1] then mode = "party" end
	if groupExists[2] then mode = "raid10" end
	if groupExists[3] or groupExists[4] then mode = "raid20" end
	
	if mode ~= groupMode then
		local oldMode = groupMode
		groupMode = mode
		WT.Event.Trigger.GroupModeChanged(groupMode, oldMode) -- changed(newMode, oldMode)			
	end 

end

WT.RegisterInitializer(OnGroupMemberChange)

local groupEventTables = {}
for i = 1,20 do 
	groupEventTables[i] = Library.LibUnitChange.Register("group" .. string.format("%02d", i))
	table.insert(groupEventTables[i], { OnGroupMemberChange, AddonId, "OnGroupMemberChange" } )
end


function WT.GroupExists(groupId)
	if groupExists[groupId] then
		return true
	else
		return false
	end
end

function WT.GetGroupMode()
	return groupMode
end

local playerTargetId = nil
local function OnPlayerTargetChange(hEvent, unitId)
	if playerTargetId and WT.Units[playerTargetId] then
		WT.Units[playerTargetId].playerTarget = nil
	end
	playerTargetId = unitId
	if playerTargetId and WT.Units[playerTargetId] then
		WT.Units[playerTargetId].playerTarget = true
	end
end

local function OnCastbarChange(hEvent, unitsValue)
		if WT.Units[unitId] then
			if cbVisible then 
				WT.Units[unitId].castName = true
				else 
				WT.Units[unitId].castName = false
			end
		end
end


-- Register the event handlers for every changeable property

Command.Event.Attach(Event.Unit.Detail.Absorb,	OnUnitDetailAbsorb, "OnUnitDetailAbsorb")
Command.Event.Attach(Event.Unit.Detail.Afk,	OnUnitDetailAfk, "OnUnitDetailAfk")
Command.Event.Attach(Event.Unit.Detail.Aggro, OnUnitDetailAggro, "OnUnitDetailAggro")
Command.Event.Attach(Event.Unit.Detail.Blocked, OnUnitDetailBlocked, "OnUnitDetailBlocked")
Command.Event.Attach(Event.Unit.Detail.Charge, OnUnitDetailCharge, "OnUnitDetailCharge")
--Command.Event.Attach(Event.Unit.Detail.Focus, OnUnitDetailFocus, "OnUnitDetailFocus")
Command.Event.Attach(Event.Unit.Detail.ChargeMax, OnUnitDetailChargeMax, "OnUnitDetailChargeMax")
Command.Event.Attach(Event.Unit.Detail.Combat, OnUnitDetailCombat, "OnUnitDetailCombat")
Command.Event.Attach(Event.Unit.Detail.Combo, OnUnitDetailCombo, "OnUnitDetailCombo")
Command.Event.Attach(Event.Unit.Detail.Energy, OnUnitDetailEnergy, "OnUnitDetailEnergy")
Command.Event.Attach(Event.Unit.Detail.EnergyMax, OnUnitDetailEnergyMax, "OnUnitDetailEnergyMax")
Command.Event.Attach(Event.Unit.Detail.Guild, OnUnitDetailGuild, "OnUnitDetailGuild")
Command.Event.Attach(Event.Unit.Detail.Health, OnUnitDetailHealth, "OnUnitDetailHealth")
Command.Event.Attach(Event.Unit.Detail.HealthCap, OnUnitDetailHealthCap, "OnUnitDetailHealthCap")
Command.Event.Attach(Event.Unit.Detail.HealthMax, OnUnitDetailHealthMax, "OnUnitDetailHealthMax")
Command.Event.Attach(Event.Unit.Detail.Level, OnUnitDetailLevel, "OnUnitDetailLevel")
Command.Event.Attach(Event.Unit.Detail.LocationName, OnUnitDetailLocationName, "OnUnitDetailLocationName")
Command.Event.Attach(Event.Unit.Detail.Mana, OnUnitDetailMana, "OnUnitDetailMana")
Command.Event.Attach(Event.Unit.Detail.ManaMax, OnUnitDetailManaMax, "OnUnitDetailManaMax")
Command.Event.Attach(Event.Unit.Detail.Mark, OnUnitDetailMark, "OnUnitDetailMark")
Command.Event.Attach(Event.Unit.Detail.Name, OnUnitDetailName, "OnUnitDetailName")
Command.Event.Attach(Event.Unit.Detail.Offline, OnUnitDetailOffline, "OnUnitDetailOffline")
Command.Event.Attach(Event.Unit.Detail.Planar, OnUnitDetailPlanar, "OnUnitDetailPlanar")
Command.Event.Attach(Event.Unit.Detail.PlanarMax, OnUnitDetailPlanarMax, "OnUnitDetailPlanarMax")
Command.Event.Attach(Event.Unit.Detail.Power, OnUnitDetailPower, "OnUnitDetailPower")
Command.Event.Attach(Event.Unit.Detail.PublicSize, OnUnitDetailPublicSize, "OnUnitDetailPublicSize")
Command.Event.Attach(Event.Unit.Detail.Pvp, OnUnitDetailPvp, "OnUnitDetailPvp")
Command.Event.Attach(Event.Unit.Detail.Ready, OnUnitDetailReady, "OnUnitDetailReady")
Command.Event.Attach(Event.Unit.Detail.Role, OnUnitDetailRole, "OnUnitDetailRole")
Command.Event.Attach(Event.Unit.Detail.Radius, OnUnitDetailRadius, "OnUnitDetailRadius")
Command.Event.Attach(Event.Unit.Detail.Tagged, OnUnitDetailTagged, "OnUnitDetailTagged")
Command.Event.Attach(Event.Unit.Detail.TitlePrefixId, OnUnitDetailTitlePrefixId, "OnUnitDetailTitlePrefixId")
Command.Event.Attach(Event.Unit.Detail.TitleSuffixId, OnUnitDetailTitleSuffixId, "OnUnitDetailTitleSuffixId")
Command.Event.Attach(Event.Unit.Detail.Vitality, OnUnitDetailVitality, "OnUnitDetailVitality")
Command.Event.Attach(Event.Unit.Detail.Warfront, OnUnitDetailWarfront, "OnUnitDetailWarfront")
Command.Event.Attach(Event.Unit.Detail.Mentoring, OnUnitDetailMentoring, "OnUnitDetailMentoring")
Command.Event.Attach(Event.Buff.Add, OnBuffAdd, "OnBuffAdd")
Command.Event.Attach(Event.Buff.Change, OnBuffChange, "OnBuffChange")
Command.Event.Attach(Event.Buff.Remove, OnBuffRemove, "OnBuffRemove")
Command.Event.Attach(Event.Unit.Castbar, OnUnitCastbar, "OnUnitCastbar")
Command.Event.Attach(Event.Unit.Detail.Zone, OnUnitDetailZone, "OnUnitDetailZone")
Command.Event.Attach(Event.Unit.Detail.Coord, OnUnitDetailCoord, "OnUnitDetailCoord")
--Command.Event.Attach(Event.Unit.Detail.Relation, OnUnitDetailRelation, "OnUnitDetailRelation")


local function OnChatNotify(hEvent, unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "OnChatNotify", value) end
end
counter = nil

Command.Event.Attach(Event.System.Update.Begin,	OnSystemUpdateBegin, "DB_OnSystemUpdateBegin")
Command.Event.Attach(Event.Chat.Notify,	OnChatNotify, "OnChatNotify")


Command.Event.Attach(Library.LibUnitChange.Register("player.target"), OnPlayerTargetChange, "OnPlayerTargetChange")
Command.Event.Attach(Library.LibUnitChange.Register("castName"), OnCastbarChange, "OnCastbarChange")