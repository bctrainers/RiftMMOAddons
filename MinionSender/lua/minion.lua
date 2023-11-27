function MinionSender.Minion.Init ()
	MinionSender.Minion.Reserve = {}
	MinionSender.Minion.Chains = {}
	MinionSender.Minion.Dependence = {}

	local fillReserve
	fillReserve = function (item, dependence)
		for ck, cv in pairs(item) do
			if cv.group then
				fillReserve(cv.list, cv.dependence)
			else
				local minion = (cv.required or {}).minion
				local stamina = (cv.required or {}).stamina or 1
				if type(minion) ~= "table" then minion = { minion } end
				MinionSender.Minion.Chains[cv.id] = tableCopy(cv)
				if MinionSender.Minion.Chains[cv.id].required == nil then MinionSender.Minion.Chains[cv.id].required = {} end
				MinionSender.Minion.Chains[cv.id].required.minion = {}
				if dependence ~= nil and dependence ~= cv.id then MinionSender.Minion.Dependence[cv.id] = dependence end

				for mk, mv in pairs(minion) do
					MinionSender.Minion.Reserve[mv] = math.max(MinionSender.Minion.Reserve[mv] or 0, stamina)
					MinionSender.Minion.Chains[cv.id].required.minion[mv] = true
				end
				if tableLength(MinionSender.Minion.Chains[cv.id].required.minion) == 0 then MinionSender.Minion.Chains[cv.id].required.minion = nil end
			end
		end
	end

	for k, v in pairs(MinionSender.Data.Chain) do
		fillReserve(v.list)
	end
end

function MinionSender.Minion.ActionClaim (info)
	for k, v in pairs(info.finishedList) do
		if ((MinionSenderConfig.claimAttractors and MinionSenderConfig["claim" .. ((MinionSender.Data.Minion[v.minionId] or {}).attractorType or "")]) or not (MinionSender.Data.Minion[v.minionId] or {}).hasAttractor) and 
		  (MinionSenderConfig.shuffleChain or MinionSender.Minion.Dependence[k] == nil or info.adventureList[MinionSender.Minion.Dependence[k]]) then
			pcall(Command.Minion.Claim, k)

			if MinionSenderConfig.announceClaim then
				Command.Console.Display("general", true, MinionSender.Data.Language.Current.AnnounceClaim:format(colorRGBtoHEX(MinionSenderConfig.colorAnnouncement), colorRGBtoHEX(MinionSender.AE.RarityColor[v.minionRarity]), v.minionName, MinionSender.Data.Language.Current.AnnounceClaimDuration[v.duration], TimeToString(v.time)), true)
			end
			return true
		end
	end
end

function MinionSender.Minion.ActionSend (info)
	if info.slots == 0 then return false end
	local tasks = MinionSender.Minion.GetTasks()

	for k, v in pairs(tasks) do
		if MinionSender.Minion.ExecuteTask(info, v) then return true end
	end
end

function MinionSender.Minion.ExecuteTask (info, task)
	local adventure = info.availableList[task.duration]
	if adventure ~= nil then
		if MinionSenderConfig.shuffle and task.duration > 1 then
			local stats = MinionSender.Minion.GetStats(adventure, true)
			local shuffle = false
			for k, v in pairs(stats) do
				if MinionSenderConfig["shuffle" .. k] then shuffle = true end
			end
			if MinionSender.Minion.Chains[adventure.id] ~= nil and MinionSenderConfig.shuffleChain then shuffle = true end

			if shuffle then
				MinionSender.Minion.CallShuffle(task, adventure, "aventurine")
				return true
			end

			if MinionSender.Minion.LastAdventure == adventure.id and MinionSenderConfig.shuffleRare then
				MinionSender.Minion.CallShuffle(task, adventure, "none")
				return true
			end
		end

		local minion = MinionSender.Minion.GetMinion(task, adventure, info.minionList)
		if minion.id ~= nil then
			MinionSender.Minion.LastAdventure = adventure.id
			MinionSender.Minion.CallSend(task, adventure, minion)
			return true
		end
	end
end

function MinionSender.Minion.CallShuffle (task, adventure, currency)
	pcall(Command.Minion.Shuffle, adventure.id, currency)

	if MinionSenderConfig.announceShuffle then
		Command.Console.Display("general", true, MinionSender.Data.Language.Current.AnnounceShuffle:format(colorRGBtoHEX(MinionSenderConfig.colorAnnouncement), colorRGBtoHEX(MinionSender.AE.RarityColor[({ "common", "uncommon", "rare", "epic" })[task.duration]]), adventure.name, TimeToString(adventure.duration)), true)
	end
end

function MinionSender.Minion.CallSend (task, adventure, minion)
	pcall(Command.Minion.Send, minion.id, adventure.id, iif((adventure.costAventurine or 0) > 0, "aventurine", "none"))

	if MinionSenderConfig.announceSend then
		Command.Console.Display("general", true, MinionSender.Data.Language.Current.AnnounceSend:format(colorRGBtoHEX(MinionSenderConfig.colorAnnouncement), colorRGBtoHEX(MinionSender.AE.RarityColor[minion.rarity]), minion.name, MinionSender.Data.Language.Current.AnnounceSendDuration[task.duration], TimeToString(adventure.duration)), true)
	end
end

function MinionSender.Minion.GetTasks ()
	if MinionSenderConfig.options == "Simple" then
		return { MinionSenderConfig }
	else
		return (MinionSenderConfig.ruleset[MinionSenderConfig.rule] or {}).rules or {}
	end
end

function MinionSender.Minion.GetStats (item, flag)
	local stats = {}

	for k in pairs(item) do
		if string.sub(k, 1, 4) == "stat" then
			stats[iif(flag, string.sub(k, 5), k)] = true
		end
	end

	return stats
end

function MinionSender.Minion.ValidateStats (item, required)
	local res = { req = 0, mth = 0 }
	for k in pairs(required) do
		if string.sub(k, 1, 4) == "stat" then
			res.req = res.req + 1
			if item[k] ~= nil then res.mth = res.mth + 1 end
		end
	end

	return res
end

function MinionSender.Minion.CalculateWeight (priority, minion, stats)
	local weight = 0
	local statsSum = 0
	for k, v in pairs(stats) do
		statsSum = statsSum + (minion[k] or 0)
	end

	if priority == 2 or priority == 3 then weight = weight * 100 + iif(priority == 2, 100 - minion.level, minion.level) end
	if priority < 4 then weight = weight * 100 + statsSum end
	weight = weight * 100 + 100 + minion.stamina - minion.staminaMax
	if priority == 4 then weight = weight * 100 + statsSum end

	return weight
end

function MinionSender.Minion.GetMinion (task, adventure, ignoreList)
	local list = Inspect.Minion.Minion.List()
	local minion = { value = -1 }
	local stats = MinionSender.Minion.GetStats(adventure)

	if list ~= nil then
		local minions = Inspect.Minion.Minion.Detail(list)
		local required = (MinionSender.Minion.Chains[adventure.id] or {}).required or {}

		if minions ~= nil then
			for k, v in pairs(minions) do
				local validate = MinionSender.Minion.ValidateStats(v, required)

				if v.stamina - adventure.costStamina >= iif((required.minion or {})[k], 0, math.max(task.staminaReserve, iif(MinionSenderConfig.shuffleChain, 0, iif(MinionSenderConfig.chainReserve, MinionSender.Minion.Reserve[k] or 0, 0)))) and 
				   ignoreList[k] == nil and ((required.minion or {})[k] or (required.minion == nil and 
				   v.level >= task.level.min and v.level <= task.level.max and v.level >= (required.levelMin or 1) and v.level <= (required.levelMax or 25) and
				   task["filter" .. v.rarity] and (task.filterattractor or not (MinionSender.Data.Minion[k] or {}).hasAttractor) and
				   validate.req <= validate.mth and task["match" .. tostring(MinionSender.Minion.ValidateStats(v, stats).mth)])) then
					local value = MinionSender.Minion.CalculateWeight(task.priority, v, stats)

					if minion.value < value then
						minion.id = k
						minion.value = value
						minion.name = v.name
						minion.rarity = v.rarity
					end
				end
			end
		end
	end

	return minion
end

function MinionSender.Minion.GetInfo ()
	local info = { slots = Inspect.Minion.Slot() or 0, working = 0, finished = 0, adventureList = {}, availableList = {}, finishedList = {}, minionList = {}, completion = 0, workingList = {}, minions = { level = {}, rarity = {}, stats = {}, level1 = 0, level25 = 0, stamina1 = { cur = 0, max = 0 }, stamina25 = { cur = 0, max = 0 } } }

	local addWorking = function (data)
		for k, v in pairs(info.workingList) do
			if (v.completion or 0) > (data.completion or 0) then
				table.insert(info.workingList, k, data)
				return
			end
		end
		table.insert(info.workingList, data)
	end

	local adventureList = Inspect.Minion.Adventure.List()
	local minionList = Inspect.Minion.Minion.List()

	if adventureList ~= nil and minionList ~= nil then
		local adventures = Inspect.Minion.Adventure.Detail(adventureList)
		local minions = Inspect.Minion.Minion.Detail(minionList)

		if adventures ~= nil and minions ~= nil then
			for k, v in pairs(adventures) do
				local duration = (MinionSender.Data.Adventure[k] or {}).duration or MinionSender.Data.Duration[v.duration] or 2

				if v.mode == "available" then
					info.availableList[duration] = v
					info.adventureList[k] = true
				elseif v.mode == "finished" or (v.mode == "working" and Inspect.Time.Server() - v.completion > 10) then
					info.finished = info.finished + 1
					info.finishedList[k] = { name = v.name, duration = duration, time = v.duration, minionId = v.minion, minionName = (minions[v.minion] or {}).name or "", minionRarity = (minions[v.minion] or {}).rarity or "common" }
					info.adventureList[k] = true
					addWorking({ duration = v.duration })
					if v.minion ~= nil then info.minionList[v.minion] = true end
				elseif v.mode == "working" then
					info.working = info.working + 1
					info.completion = iif(info.completion == 0, v.completion or 0, iif(v.completion == nil, info.completion, math.min(info.completion, v.completion or 0)))
					info.adventureList[k] = true
					addWorking({ duration = v.duration, completion = v.completion or 0 })
					if v.minion ~= nil then info.minionList[v.minion] = true end
				end
			end

			for k, v in pairs(minions) do
				local rarity = iif(v.rarity == "epic", 4, iif(v.rarity == "rare", 3, iif(v.rarity == "uncommon", 2, 1)))
				local stats = MinionSender.Minion.GetStats(v, true)

				info.minions.rarity[rarity] = (info.minions.rarity[rarity] or 0) + 1
				info.minions.level[v.level] = (info.minions.level[v.level] or 0) + 1
				for sk, sv in pairs(stats) do info.minions.stats[sk] = (info.minions.stats[sk] or 0) + 1 end
				info.minions.stats.Attractor = (info.minions.stats.Attractor or 0) + iif((MinionSender.Data.Minion[k] or {}).hasAttractor, 1, 0)

				info.minions[iif(v.level < 25, "stamina1", "stamina25")].cur = info.minions[iif(v.level < 25, "stamina1", "stamina25")].cur + math.floor(v.stamina)
				info.minions[iif(v.level < 25, "stamina1", "stamina25")].max = info.minions[iif(v.level < 25, "stamina1", "stamina25")].max + v.staminaMax
				info.minions[iif(v.level < 25, "level1", "level25")] = info.minions[iif(v.level < 25, "level1", "level25")] + 1
			end

			info.slots = info.slots - info.working - info.finished
		end
	end

	return info
end
