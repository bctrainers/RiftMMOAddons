local toc, data = ...
local AddonId = toc.identifier


--[[
	A BuffSet is a table that must contain the following methods:
	:CanAccept(buff) - return true if there is a valid slot available for the buff
	:Add(buff) - add a new buff to the set
	:Remove(buff) - remove a buff from the set
	:Update(buff) - update a buff within the set
	:Done() - all changes applied, the set can now compress itself/sort itself, or whatever
--]]
function WT.UnitFrame:RegisterBuffSet(buffSet)

	if not self.BuffSets then self.BuffSets = {} end
	if not buffSet.CanAccept then error("Invalid BuffSet - missing CanAccept method") end
	if not buffSet.Add then error("Invalid BuffSet - missing Add method") end
	if not buffSet.Remove then error("Invalid BuffSet - missing Remove method") end
	if not buffSet.Update then error("Invalid BuffSet - missing Update method") end
	if not buffSet.Done then error("Invalid BuffSet - missing Done method") end
	table.insert(self.BuffSets, buffSet)
end



function WT.UnitFrame:BuffHandler(added, removed, updated)

	-- bail out if we are called on initialisation
	--if not WT.Player then
	--	WT.Player = {}
	--	WT.Player.id = Inspect.Unit.Lookup("player") 
	--end

	local altered = {}

	-- Removals first, to free up slots
	if removed then
		for buffId, buff in pairs(removed) do
			local allocation = self.BuffAllocations[buffId]
			if allocation then
				allocation:Remove(buff)
				altered[allocation] = true
			end 
			self.BuffAllocations[buffId] = nil
			self.BuffData[buffId] = nil
		end
	end
	
	-- Then add in any new buffs
	if added then
		for buffId, buff in pairs(added) do
		
			if ((self.Options.ownBuffs) and (not buff.debuff) and (buff.caster ~= WT.Player.id)) 
			or ((self.Options.ownDebuffs) and (buff.debuff) and (buff.caster ~= WT.Player.id))
			then
				-- exclude
			else		
				buff.priority = self:GetBuffPriority(buff)		
				self.BuffData[buffId] = buff
				self.BuffAllocations[buffId] = false -- default to unallocated
				if self.BuffSets then
					for idx, buffSet in ipairs(self.BuffSets) do
						if buffSet:CanAccept(buff) then
							buffSet:Add(buff)
							self.BuffAllocations[buffId] = buffSet
							altered[buffSet] = true
							break
						end
					end
				end
			end
		end
	end

	-- Update any changed buffs
	if updated then
		for buffId, buff in pairs(updated) do
			self.BuffData[buffId] = buff
			local allocation = self.BuffAllocations[buffId]
			if allocation then
				allocation:Update(buff)
				altered[allocation] = true
			end
		end
	end

	-- See if we can find a home for any unallocated buffs if anything has been removed
	if removed then
		for buffId, buffSet in pairs(self.BuffAllocations) do
			if not buffSet then
				local buff = self.BuffData[buffId]
				-- COPIED FROM 'ADDED' LOOP
				if self.BuffSets then
					for idx, buffSet in ipairs(self.BuffSets) do
						if buffSet:CanAccept(buff) then
							buffSet:Add(buff)
							self.BuffAllocations[buffId] = buffSet
							altered[buffSet] = true
							break
						end
					end
				end
			end
		end
	end

	-- Trigger the 'done' handler, which is where heavyweight sorting, texture loading, etc should be done
	for buffSet in pairs(altered) do
		buffSet:Done()
	end
	
end



-- This function calculates the difference between the buffs currently on the unitframe
-- and the buffs actually on the unit, and generates an OnBuffUpdates() event to apply
-- the differences
function WT.UnitFrame:ApplyBuffDelta()

-- .BuffData[buffId] = buff
-- .BuffAllocations[buffId] = buffset

	local changes = nil

	if not self.Unit and self.BuffData then
		for buffId, buff in pairs(self.BuffData) do
			if not changes then changes = {} end
			if not changes.remove then changes.remove = {} end
			changes.remove[buffId] = buff
		end 
	end 
	
	if self.Unit then
		local actualBuffs = self.Unit.Buffs
		if self.BuffData then
			for buffId, buff in pairs(self.BuffData) do
				if not actualBuffs[buffId] then
					if not changes then changes = {} end
					if not changes.remove then changes.remove = {} end
					changes.remove[buffId] = buff
				end
				if actualBuffs[buffId] then
					if not changes then changes = {} end
					if not changes.update then changes.update = {} end
					changes.update[buffId] = buff
				end
			end
		end
		for buffId, buff in pairs(actualBuffs) do
			if not self.BuffData or not self.BuffData[buffId] then
				if not changes then changes = {} end
				if not changes.add then changes.add = {} end
				changes.add[buffId] = buff			
			end
		end
	end
	
	if changes then
		self:BuffHandler(changes.add, changes.remove, changes.update)
	end

end


-- Clears all buffs from the frame, and then applies them again
function WT.UnitFrame:ReapplyBuffDelta()

	local changes = nil

	if self.BuffData then
		for buffId, buff in pairs(self.BuffData) do
			if not changes then changes = {} end
			if not changes.remove then changes.remove = {} end
			changes.remove[buffId] = buff
		end 
	end 

	if changes then
		self:BuffHandler(changes.add, changes.remove, changes.update)
	end

	self:ApplyBuffDelta()

end
