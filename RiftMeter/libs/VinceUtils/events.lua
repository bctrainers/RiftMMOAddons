local Info, Addon = ...

local GCDBeginTrigger = Utility.Event.Create(Info.identifier, "GlobalCooldown.Begin")
local GCDEndTrigger = Utility.Event.Create(Info.identifier, "GlobalCooldown.End")

local GCDAbility

Command.Event.Attach(Event.Ability.New.Cooldown.Begin, function(handle, cooldowns)
	for ability, cooldown in next, cooldowns do
		if cooldown > 0.9 and cooldown < 1.6 then
			GCDAbility = ability
			GCDBeginTrigger(cooldown)
			return
		end
	end
end, Info.identifier .. ": Event.Ability.New.Cooldown.Begin")

Command.Event.Attach(Event.Ability.New.Cooldown.End, function(handle, cooldowns)
	for ability, cooldown in next, cooldowns do
		if ability == GCDAbility then
			GCDAbility = nil
			GCDEndTrigger()
		end
	end
end, Info.identifier .. ": Event.Ability.New.Cooldown.End")
