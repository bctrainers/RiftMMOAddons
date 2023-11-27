--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2015-07-13T11:42:28Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- Checks a buff against a standard filter configuration table
-- The gadget must be a UnitFrame instance, with a .config property containing the gadget configuration
function data.CheckBuffFilter(gadget, buff)

	local config = gadget.config

	local casterId = buff.caster
	local playerCast = casterId == WT.Player.id
	local unitCast = casterId == gadget.UnitId
	local otherCast = not (playerCast or unitCast)
	
	local passFilter = false
	
	if not buff.debuff then
		if not config.showPermanentBuffs and not buff.duration then return false end
		if config.showMyBuffs and playerCast then passFilter = true end
		if config.showUnitBuffs and unitCast then passFilter = true end
		if config.showOtherBuffs and otherCast then passFilter = true end
	end
	if buff.debuff then
		if config.showMyDebuffs and playerCast then passFilter = true end
		if config.showUnitDebuffs and unitCast then passFilter = true end
		if config.showOtherDebuffs and otherCast then passFilter = true end
	end

	if not passFilter then return false end	
	
	local bName = buff.name:lower()
	if config.filterType == "exclude" then 
		if config.filters[bName] then 
			return false
		else
			for wildcard in pairs(gadget.wildcards) do
				if bName:match(wildcard) then
					return false
				end
			end
		end
	elseif config.filterType == "include" then
	 	if config.filters[bName] then
			return true
		end
		for wildcard in pairs(gadget.wildcards) do
			if bName:match(wildcard) then
				return true
			end
		end
		return false
	end
	
	return true

end