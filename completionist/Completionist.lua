-- There is no copyright on this code

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
-- associated documentation files (the "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is furnished to do so.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
-- NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--
-- Global variables
--
local addon, Completionist = ...
Completionist.name = "Completionist"
Completionist.slashName = "cmpl"
Completionist.version = "v2.9.8"
Completionist.x = 500
Completionist.y = 500
Completionist.buttonX = 200
Completionist.buttonY = 200
Completionist.lang = "English"
Completionist.isButtonShown = true
Completionist.isButtonLocked = false
Completionist.hideEmptyZones = true
Completionist.saveUnknownQuests = false
Completionist.ignoredQuests = {}
Completionist.completedRepeatQuests = {}
Completionist.questCoords = {}
Completionist.unknownQuestCoords = {}
Completionist.unknownQuestDetails = {}
Completionist.extraQuestCoords = {}
Completionist.startCount = 0
Completionist.faction = "None"
Completionist.player = "None"
Completionist.IgnoreZone = "Ignored"

local REWARD_FILTER_TYPE = 1
local NOTORIETY_FILTER_TYPE = 2
local SCOPE_FILTER_TYPE = 3

--
-- Main functions
--
local function BroadcastMessage(message)
	Command.Message.Broadcast("guild", nil, "Completionist", message, function(failure, message) end)
	Command.Message.Broadcast("yell", nil, "Completionist", message, function(failure, message) end)
end

local function GetQuestLocationString(questId, x, z)
	return "|" .. questId .. "|" .. x .. "|" .. z
end

local function BroadcastQuests(locationString)
	BroadcastMessage("QuestLocations" .. locationString)
end

local function BroadcastSavedQuests()
	local block = 50
	local count = 1
	local locations = ""
	for questId, coordStr in pairs(Completionist.questCoords) do
		if count >= block then
			Completionist.AsyncHandler:OneOffCallback(function() BroadcastQuests(locations) end)
			count = 1
			locations = ""
		end

		local coords = XenUtils.Utils.Split(coordStr, ",")
		locations = locations .. GetQuestLocationString(questId, coords[1], coords[2])
		count = count + 1
	end
	
	if locations ~= "" then
		Completionist.AsyncHandler:OneOffCallback(function() BroadcastQuests(locations) end)
	end

	Completionist.lastSharedCoords = os.time()
end

local function InternalGetZoneName(zoneName, lang)
	if zoneName ~= nil then
		local internalZoneName = zoneName:gsub('%s%(%d+%)', '')
		
		if lang == "Francais" then
			if Completionist.French2EnglishZoneMap[internalZoneName] ~= nil then
				return internalZoneName
			elseif Completionist.FrenchZoneMap[internalZoneName] ~= nil then
				return Completionist.FrenchZoneMap[internalZoneName]
			end
		elseif lang == "Deutsch" then
			if Completionist.German2EnglishZoneMap[internalZoneName] ~= nil then
				return internalZoneName
			elseif Completionist.GermanZoneMap[internalZoneName] ~= nil then
				return Completionist.GermanZoneMap[internalZoneName]
			end
		else
			if Completionist.FrenchZoneMap[internalZoneName] ~= nil then
				return internalZoneName
			elseif Completionist.German2EnglishZoneMap[internalZoneName] ~= nil then
				return Completionist.German2EnglishZoneMap[internalZoneName]
			elseif Completionist.French2EnglishZoneMap[internalZoneName] ~= nil then
				return Completionist.French2EnglishZoneMap[internalZoneName]
			end
		end
		
		return internalZoneName
	end
	
	return ""
end

local function GetZoneName(zoneName)
	return InternalGetZoneName(zoneName, Completionist.lang)
end

local function GetEnglishZoneName(zoneName)
	return InternalGetZoneName(zoneName, "English")
end

local function GetQuestCoords(giver, questId)
	local coords = Completionist.KnownQuestCoords[questId]
	if coords ~= nil then
		return coords
	end
	
	coords = Completionist.questCoords[questId]
	if coords ~= nil then
		return coords
	end
	
	if giver ~= nil and giver.OriginalID ~= "0" and giver.Coords ~= nil then
		return giver.Coords
	end
	
	return ""
end

local function GetNPCText(questId, giverId)
	local giver = Completionist.Givers[giverId]
	if giver == nil or giver.OriginalID == "0" then
		local coords = GetQuestCoords(giver, questId)
		if coords ~= nil and coords ~= "" then
			return " [" .. coords .. "]"
		else
			return ""
		end
	else
		local ret
		if Completionist.lang == "Francais" then
			ret = "Début: " .. giver.French
		elseif Completionist.lang == "Deutsch" then
			ret = "Start: " .. giver.German
		else
			ret = "Start: " .. giver.English
		end
		
		return ret .. " - " .. GetZoneName(giver.Zone) .. " [" .. GetQuestCoords(giver, questId) .. "]"
	end
end

local function GetQuestName(id)
	if Completionist.lang == "Francais" then
		return Completionist.Quests[id].French
	elseif Completionist.lang == "Deutsch" then
		return Completionist.Quests[id].German
	end
	
	return Completionist.Quests[id].English
end

local function GetQuestText(id)
	local npc = GetNPCText(id, Completionist.Quests[id].NPC)
	local ret = ""
	if Completionist.Quests[id].Repeatable ~= "Never" then
		ret = Completionist.Quests[id].Repeatable .. " quest " .. npc .. "\n"
	elseif npc ~= "" then
		ret = npc .. "\n"
	end

	local desc
	if Completionist.lang == "Francais" then
		desc = Completionist.Quests[id].FrenchDescription
	elseif Completionist.lang == "Deutsch" then
		desc = Completionist.Quests[id].GermanDescription
	else
		desc = Completionist.Quests[id].EnglishDescription
	end
	if desc == nil then
		desc = ""
	end
	
	if ret ~= "" or desc ~= "" then
		return ret .. desc
	else
		return "Empty"
	end
end

local function HideQuestPopup()
	if Inspect.System.Secure() ~= true then
		Completionist.parentFrame.questPopupMenu:Hide()
	end
end

local function SetQuestText()
	local item = Completionist.parentFrame.list:GetSelectedValue()
	if item == nil then
		Completionist.parentFrame.quest:SetText(Completionist.GetLocaleValue("Select quest to see description"))
	else
		Completionist.parentFrame.quest:SetText(GetQuestText(item))
	end

	HideQuestPopup()	
	Completionist.parentFrame.ignoredPopupMenu:Hide()
end

local function IsWeeklyQuest(quest)
	if quest ~= nil and quest.Repeatable == "Weekly" then
		return true
	end
	
	return false
end

local function IsDailyQuest(quest)
	if quest ~= nil and quest.Repeatable == "Daily" then
		return true
	end
	
	return false
end

local function IsQuestRepeatable(quest)
	if IsWeeklyQuest(quest) or IsDailyQuest(quest) then
		return true
	end
	
	return false
end

local function IsQuestCompleted(quest)
	if quest.completed == true then
		local lastCompleted = Completionist.completedRepeatQuests[quest.ID]
		if lastCompleted == nil then
			return true
		else
			if IsDailyQuest(quest) then
				if lastCompleted > Completionist.resetDailyTime then
					return true
				end
			elseif IsWeeklyQuest(quest) then
				if lastCompleted > Completionist.resetWeeklyTime then
					return true
				end				
			else
				return true
			end
		end
	end
	
	return false
end

local function IsQuestInFilter(quest, filterType, filterString, faction)
	if faction ~= "None" and faction ~= Completionist.faction then
		return false
	end
	
	if filterString == "None" then
		return true
	end

	if filterString == "Unrepeatable" then
		return quest.Repeatable == "Never"
	end
	
	if filterType == REWARD_FILTER_TYPE then
		return quest.Rewards[filterString] == 1 or quest.RepeatRewards[filterString] == 1
	elseif filterType == NOTORIETY_FILTER_TYPE then
		return quest.Notoriety[filterString] == 1 or quest.RepeatNotoriety[filterString] == 1
	else
		return quest.Scope[filterString] == 1
	end
end

local function GetFilterType(englishFilter)
	local filterType = NOTORIETY_FILTER_TYPE
	if Completionist.Scopes[englishFilter] ~= nil then
		filterType = SCOPE_FILTER_TYPE
	elseif Completionist.Rewards[englishFilter] ~= nil then
		filterType = REWARD_FILTER_TYPE
	end
	
	return filterType
end

local function RedrawList()
	Completionist.parentFrame.list:SetItems({})
	local zoneName = GetEnglishZoneName(Completionist.parentFrame.select:GetSelectedItem())
	if zoneName ~= nil and Completionist.ZoneQuestMap[zoneName] ~= nil then
		local englishFilter = Completionist.GetEnglishValue(Completionist.parentFrame.filter:GetSelectedItem())
		
		local filterType = GetFilterType(englishFilter)
		local questNames = {}
		local items = {}
		local values = {}
		for _, id in ipairs(Completionist.ZoneQuestMap[zoneName]) do
			local quest = Completionist.Quests[id]
			if quest ~= nil then
				if IsQuestCompleted(quest) == false and IsQuestInFilter(quest, filterType, englishFilter, quest.Faction) == true then
					local name = GetQuestName(id)
					if questNames[name] == nil then
						questNames[name] = 1
						table.insert(items, name)
						values[name] = id
					end
				end
			end
		end
		
		table.sort(items)
		
		local questIds = {}
		for _, name in ipairs(items) do
			table.insert(questIds, values[name])
		end

		Completionist.parentFrame.list:SetItems(items, questIds)
		if #items == 1 then
			Completionist.parentFrame.list:SetSelectedItem(items[1])
		else
			SetQuestText()
		end
	else
		SetQuestText()
	end
end

local function CountCompletedZoneQuests(questIds)
	local count = 0
	local totalCount = 0
	if questIds ~= nil then
		local englishFilter = Completionist.GetEnglishValue(Completionist.parentFrame.filter:GetSelectedItem())
		local filterType = GetFilterType(englishFilter)
		for _, questId in ipairs(questIds) do
			if questId ~= nil and Completionist.Quests[questId] ~= nil then
				local faction = Completionist.Quests[questId].Faction
				if IsQuestInFilter(Completionist.Quests[questId], filterType, englishFilter, faction) == true then
					if IsQuestCompleted(Completionist.Quests[questId]) == false then
						count = count + 1
					end
				
					totalCount = totalCount + 1
				end
			end			
		end
	end
	
	return count, totalCount
end

local function RedrawZoneNames()
	local selectedZone = GetEnglishZoneName(Completionist.parentFrame.select:GetSelectedItem())

	local items = {}
	for name, questIds in pairs(Completionist.ZoneQuestMap) do
		local count = CountCompletedZoneQuests(questIds)
		local zoneName = GetZoneName(name)
		if (zoneName ~= "") then
			if Completionist.hideEmptyZones ~= true or count > 0 then
				local zoneName = zoneName .. " (" .. count .. ")"
				if name == selectedZone then
					selectedZone = zoneName
				end
				
				table.insert(items, zoneName)
			end
		end
	end
	
	table.sort(items)
	Completionist.parentFrame.select:SetItems(items)
	Completionist.parentFrame.select:SetSelectedItem(selectedZone)
end

local function GetZoneTooltip()
	local tip = ""
	
	local playerDetails = Inspect.Unit.Detail("player")
	if playerDetails ~= nil and playerDetails.zone ~= nil then
		local zoneDetails = Inspect.Zone.Detail(playerDetails.zone)
		if zoneDetails ~= nil and zoneDetails.name ~= nil then
			local zoneName = GetEnglishZoneName(zoneDetails.name)
			local questIds = Completionist.ZoneQuestMap[zoneName]
			if questIds ~= nil then
				local count, totalCount = CountCompletedZoneQuests(questIds)
				tip = zoneDetails.name .. " " .. count .. " out of " .. totalCount
			end
		end
	end
	
	return tip
end

local function SelectCurrentZone()
	local playerDetails = Inspect.Unit.Detail("player")
	if playerDetails ~= nil and playerDetails.zone ~= nil then
		local zone = Inspect.Zone.Detail(playerDetails.zone)
		if zone ~= nil and zone.name ~= nil then
			local currentZoneName = GetZoneName(zone.name)
			local items = Completionist.parentFrame.select:GetItems()
			for _, zoneName in ipairs(items) do
				if GetZoneName(zoneName) == currentZoneName then
					Completionist.parentFrame.select:SetSelectedItem(zoneName)
				end
			end
		end
	end
end

local function RedrawLabels()
	Completionist.parentFrame.label:SetText(Completionist.GetLocaleValue("Zone"))
	Completionist.parentFrame.filterLabel:SetText(Completionist.GetLocaleValue("Filter"))
	Completionist.parentFrame.langLabel:SetText(Completionist.GetLocaleValue("Language"))
	Completionist.parentFrame.quest:SetText(Completionist.GetLocaleValue("Select quest to see description"))
	Completionist.parentFrame.showButtonCheck:SetText(Completionist.GetLocaleValue("Show icon button"))
	Completionist.parentFrame.lockButtonCheck:SetText(Completionist.GetLocaleValue("Lock icon button"))
	Completionist.parentFrame.hideZoneCheck:SetText(Completionist.GetLocaleValue("Hide zones with no quests"))
	Completionist.parentFrame.coordLabel:SetText(Completionist.GetLocaleValue("Quest Start Locations"))
end

local function ZoneSelected()
	RedrawList()
end

local function BuildFilterList()
	local defaultValue = Completionist.GetLocaleValue("Unrepeatable")
	local filters = {}
	table.insert(filters, defaultValue)
	table.insert(filters, Completionist.GetLocaleValue("None"))
	table.insert(filters, Completionist.GetLocaleValue("Void Stone"))
	table.insert(filters, Completionist.GetLocaleValue("Infinity Stone"))
	table.insert(filters, Completionist.GetLocaleValue("Sourcestone"))
	table.insert(filters, Completionist.GetLocaleValue("Eternal Crystallized Insight"))
	table.insert(filters, Completionist.GetLocaleValue("Spirit Infusion"))
	table.insert(filters, Completionist.GetLocaleValue("Minion Card"))
	table.insert(filters, Completionist.GetLocaleValue("Grandmaster Craftsman's Mark"))
	table.insert(filters, Completionist.GetLocaleValue("Master Craftsman's Mark"))
	table.insert(filters, Completionist.GetLocaleValue("Artisan's Mark"))
	table.insert(filters, Completionist.GetLocaleValue("Story"))
	table.insert(filters, Completionist.GetLocaleValue("Saga"))
	
	if Completionist.Scopes == nil then
		local scopeMap = {}
		scopeMap[Completionist.GetEnglishValue("Story")] = 1
		scopeMap[Completionist.GetEnglishValue("Saga")] = 1
		
		Completionist.Scopes = scopeMap
	end
	
	if Completionist.Rewards == nil then
		local rewardMap = {}
		local count = 0
		for _, name in ipairs(filters) do
			if count > 1 then
				local key = Completionist.GetEnglishValue(name)
				if Completionist.Scopes[key] == nil then
					rewardMap[key] = 1
				end
			end
			
			count = count + 1
		end
		
		Completionist.Rewards = rewardMap
	end
	
	if Completionist.Factions == nil then
		local factions = {}
		for _, entry in pairs(Completionist.Quests) do
			if entry.Notoriety ~= nil then
				for notoriety, _ in pairs(entry.Notoriety) do
					factions[notoriety] = 1
				end
			end
			
			if entry.RepeatNotoriety ~= nil then
				for notoriety, _ in pairs(entry.RepeatNotoriety) do
					factions[notoriety] = 1
				end
			end
		end
		
		Completionist.Factions = factions
	end
	
	local factions = {}
	for faction, _ in pairs(Completionist.Factions) do
		table.insert(factions, Completionist.GetLocaleValue(faction))
	end
	
	table.sort(factions)
	for _, faction in ipairs(factions) do
		table.insert(filters, faction)
	end
	
	Completionist.parentFrame.filter:SetItems(filters)
	Completionist.parentFrame.filter:SetSelectedItem(defaultValue)
end

local function FilterSelected()
	RedrawZoneNames()
	RedrawList()
	SetQuestText()
end

local function EnsureFrameOnScreen(frame, x, y)
	local screenWidth = UIParent:GetWidth()
	local screenHeight = UIParent:GetHeight()
	
	local newX = x
	local newY = y

	if newX + frame:GetWidth() > screenWidth then
		newX = screenWidth - frame:GetWidth()
	end
	
	if newY + frame:GetHeight() > screenHeight then
		newY = screenHeight - frame:GetHeight()
	end
	
	if newX < 0 then
		newX = 0
	end
	
	if newY < 0 then
		newY = 0
	end
	
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", newX, newY)
	return newX, newY
end

local function SetButtonCoords(x, y)
	local newX, newY = EnsureFrameOnScreen(Completionist.button, x, y)
	Completionist.buttonX = newX
	Completionist.buttonY = newY
	Completionist.button:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Completionist.buttonX, Completionist.buttonY)
end

local function EnsureOnScreen()
	EnsureFrameOnScreen(Completionist.button, Completionist.button:GetLeft(), Completionist.button:GetTop())
	EnsureFrameOnScreen(Completionist.parentFrame, Completionist.parentFrame:GetLeft(), Completionist.parentFrame:GetTop())
end

local function GetQuestIDString(originalID)
	return string.sub(originalID, 1, 9)
end

local function UpdatedCompletedRepeatable(quests)
	local changed = false
	if quests ~= nil then
		for id, _ in pairs(quests) do
			local questId = GetQuestIDString(id)
			local quest = Completionist.Quests[questId]
			if quest ~= nil then
				if IsQuestCompleted(quest) ~= true then
					changed = true
					
					if IsQuestRepeatable(quest) == true then
						Completionist.completedRepeatQuests[questId] = Inspect.Time.Server()
						quest.completed = true
					end
				end
				
			end
		end
	end
end

local function UpdatedCompleted(quests)
	local changed = false
	if quests ~= nil then
		for id, _ in pairs(quests) do
			local questId = GetQuestIDString(id)
			local quest = Completionist.Quests[questId]
			if quest ~= nil then
				if IsQuestCompleted(quest) ~= true then
					changed = true
					
					if IsQuestRepeatable(quest) ~= true then
						quest.completed = true
					end
				end
				
			end
		end
	end

	RedrawZoneNames()
end

local function RefreshCompleted()
	local quests = Inspect.Quest.Complete()
	UpdatedCompleted(quests)
end

local function SetResetTimes()
	local st = Inspect.Time.Server()
	local serverTable = os.date("*t", st)
	serverTable.hour = 4
	serverTable.min = 0
	serverTable.sec = 0
	Completionist.resetDailyTime = os.time(serverTable)
	
	if serverTable.wday >= 4 then
		local offset = (serverTable.wday - 4) * 24 * 60 * 60
		Completionist.resetWeeklyTime = Completionist.resetDailyTime - offset
	else
		local offset = (3 + serverTable.wday) * 24 * 60 * 60
		Completionist.resetWeeklyTime = Completionist.resetDailyTime - offset
	end
end

local function GetPlayerCoords()
	local playerDetail = Inspect.Unit.Detail("player")
	if playerDetail ~= nil then
		return math.floor(playerDetail.coordX), math.floor(playerDetail.coordZ)
	end
	
	return nil, nil
end

local function SaveQuestCoords(questId, x, z)
	if questId ~= nil and x ~= nil and z ~= nil and Completionist.KnownQuestCoords[questId] == nil and Completionist.questCoords[questId] == nil then
		Completionist.questCoords[questId] = x .. "," .. z
		return true
	end
	
	return false
end

local function SaveUnknownQuestCoords(questId, id, x, z)
	if questId ~= nil and x ~= nil and z ~= nil and Completionist.unknownQuestCoords[questId] == nil then
		Completionist.unknownQuestCoords[questId] = id .. "|" .. x .. "|" .. z
		return true
	end
	
	return false
end

local function CleanQuestCoords()
	local cleanUpTable = {}
	
	if Completionist.extraQuestCoords ~= nil then
		for questId, coords in pairs(Completionist.extraQuestCoords) do
			if Completionist.KnownQuestCoords[questId] == nil and Completionist.questCoords[questId] == nil then
				Completionist.questCoords[questId] = coords
			end
		end		
	end
	
	local unknownCleanupTable = {}
	if Completionist.unknownQuestCoords ~= nil then
		for questId, unknownCoords in pairs(Completionist.unknownQuestCoords) do
			if Completionist.KnownQuestCoords[questId] ~= nil then
				table.insert(unknownCleanupTable, questId)
			elseif Completionist.Quests[questId] ~= nil and Completionist.questCoords ~= nil then
				local dataParts = XenUtils.Utils.Split(unknownCoords, "|")
				if dataParts ~= nil then
					Completionist.questCoords[questId] = dataParts[2] .. "," .. dataParts[3]
					table.insert(unknownCleanupTable, questId)
				end
			end
		end
	end
	
	for _, questId in ipairs(unknownCleanupTable) do
		Completionist.unknownQuestCoords[questId] = nil
	end
	
	if Completionist.questCoords ~= nil then
		for questId, _ in pairs(Completionist.questCoords) do
			if Completionist.KnownQuestCoords[questId] ~= nil then
				table.insert(cleanUpTable, questId)
			end
		end
	end
	
	for _, questId in ipairs(cleanUpTable) do
		Completionist.questCoords[questId] = nil
	end
	
	Completionist.extraQuestCoords = {}
	
	local unknownQuestCleanupTable = {}
	if Completionist.unknownQuestDetails ~= nil then
		for questId, _ in pairs(Completionist.unknownQuestDetails) do
			if Completionist.Quests[questId] ~= nil then
				table.insert(unknownQuestCleanupTable, questId)
			end
		end
	end
	
	for _, questId in ipairs(unknownQuestCleanupTable) do
		Completionist.unknownQuestDetails[questId] = nil
	end
end

local function StoreUnknownQuestDetails(questId, originalID)
	if Completionist.unknownQuestDetails ~= nil and Completionist.unknownQuestDetails[questId] == nil then
		local args = {}
		args[originalID] = true
		local questDetails = Inspect.Quest.Detail(args)
		if questDetails ~= nil and questDetails[originalID] ~= nil then
			local questTab = {
				ID = questId,
				OriginalID = originalID,
				Repeatable = "Never",
				Faction = "None",
				Notoriety = { },
				RepeatNotoriety = { },
				LevelRange = "65-70",
				Rewards = { },
				RepeatRewards = { },
				NPC = "n00000000",
				Scope = { },
				completed = false
			}
			
			local dets = questDetails[originalID]
			questTab.English = dets.name
			questTab.French = dets.name
			questTab.German = dets.name
			questTab.Zone = dets.categoryName
			questTab.EnglishDescription = dets.summary
			questTab.FrenchDescription = dets.summary
			questTab.GermanDescription = dets.summary
			
			Completionist.unknownQuestDetails[questId] = questTab
		end
	end
end

local function QuestAccepted(h, quests)
	if quests ~= nil then
		for id, _ in pairs(quests) do
			local questId = GetQuestIDString(id)
			local quest = Completionist.Quests[questId]
			if quest ~= nil then
				local x, z = GetPlayerCoords()
				local saved = SaveQuestCoords(questId, x, z)
				if saved == true then
					local locationString = GetQuestLocationString(questId, x, z)
					BroadcastQuests(locationString)
				end
			elseif Completionist.saveUnknownQuests == true then
				local x, z = GetPlayerCoords()
				local saved = SaveUnknownQuestCoords(questId, id, x, z)
				StoreUnknownQuestDetails(questId, id)
			end
		end
	end
end

local function QuestComplete(h, questTable)
	SetResetTimes()
	UpdatedCompletedRepeatable(questTable)
	RefreshCompleted()
	if Completionist.parentFrame:GetVisible() == true then
		RedrawList()
	end
end

local function SaveVariables(h, addon)
	if addon == Completionist.name then
		-- now copy saved group to settings so that they can be preserved on logout
		Completionist_SavedVariables = {}
		Completionist_SavedVariables.version = Completionist.version
		Completionist_SavedVariables.x = Completionist.parentFrame:GetLeft()
		Completionist_SavedVariables.y = Completionist.parentFrame:GetTop()
		Completionist_SavedVariables.buttonX = Completionist.buttonX
		Completionist_SavedVariables.buttonY = Completionist.buttonY
		Completionist_SavedVariables.lang = Completionist.lang
		Completionist_SavedVariables.isButtonShown = Completionist.isButtonShown
		Completionist_SavedVariables.isButtonLocked = Completionist.isButtonLocked
		Completionist_SavedVariables.hideEmptyZones = Completionist.hideEmptyZones
		Completionist_SavedVariables.saveUnknownQuests = Completionist.saveUnknownQuests
		
		CleanQuestCoords()
		Completionist_SavedVariables.questCoords = Completionist.questCoords
		Completionist_SavedVariables.extraQuestCoords = {}
		Completionist_SavedVariables.lastSharedCoords = Completionist.lastSharedCoords
		if Completionist.saveUnknownQuests ~= true then
			Completionist_SavedVariables.unknownQuestCoords = {}
			Completionist_SavedVariables.unknownQuestDetails = {}
		else
			Completionist_SavedVariables.unknownQuestCoords = Completionist.unknownQuestCoords
			Completionist_SavedVariables.unknownQuestDetails = Completionist.unknownQuestDetails
		end
		
		Completionist_SavedVariables.unknownZoneMap = nil
		
		Completionist_SavedCharacterVariables = {}
		Completionist_SavedCharacterVariables.ignoredQuests = Completionist.ignoredQuests
		Completionist_SavedCharacterVariables.completedRepeatQuests = Completionist.completedRepeatQuests
	end
end

local function ToggleVisibility()
	if Completionist.parentFrame:GetVisible() == true then
		Completionist.parentFrame:SetVisible(false)
	else
		EnsureOnScreen()
		SelectCurrentZone()
		RedrawList()
		Completionist.parentFrame:SetVisible(true)
	end
end

local function SlashHandler(h, args)
	if args == "share" then
		BroadcastSavedQuests()
		BroadcastMessage("ShareQuestLocations")
	elseif args == "soundoff" then
		Completionist.printVersions = true
		BroadcastMessage("SoundOff")
	else
		ToggleVisibility()
	end
end

local function IgnoreQuest(id)
	if id ~= nil and Completionist.ignoredQuests[id] == nil then
		local zone = InternalIgnoreQuest(id)
		if zone ~= nil then
			Completionist.ignoredQuests[id] = zone
			RedrawZoneNames()
			RedrawList()
		end
	end
end

local function InternalIgnoreQuest(id)
	if id ~= nil then
		local quest = Completionist.Quests[id]
		if quest ~= nil then
			local zoneMap = Completionist.ZoneQuestMap[quest.Zone]
			if zoneMap ~= nil then
				local found = nil
				for indx, questId in ipairs(zoneMap) do
					if questId == id then
						found = indx
						break
					end
				end
				
				if found ~= nil then
					table.remove(zoneMap, found)
					table.insert(Completionist.ZoneQuestMap[Completionist.IgnoreZone], id)
					return quest.Zone
				end
			end
		end
	end
end

local function IgnoreQuest(id)
	if id ~= nil and Completionist.ignoredQuests[id] == nil then
		local zone = InternalIgnoreQuest(id)
		if zone ~= nil then
			Completionist.ignoredQuests[id] = zone
			RedrawZoneNames()
			RedrawList()
		end
	end
end

local function IgnoreQuests()
	for id, _ in pairs(Completionist.ignoredQuests) do
		InternalIgnoreQuest(id)
	end
end

local function RestoreQuest(id)
	if id ~= nil then
		local zone = Completionist.ignoredQuests[id]
		if zone ~= nil then
			local zoneMap = Completionist.ZoneQuestMap[zone]
			if zoneMap ~= nil then
				table.insert(zoneMap, id)
			end
			
			local zoneMap = Completionist.ZoneQuestMap[Completionist.IgnoreZone]
			if zoneMap ~= nil then
				local found = nil
				for indx, questId in ipairs(zoneMap) do
					if questId == id then
						found = indx
						break
					end
				end
				
				if found ~= nil then
					table.remove(zoneMap, found)
				end
			end
		end
		
		Completionist.ignoredQuests[id] = nil
		RedrawZoneNames()
		RedrawList()
	end
end

local function MessageHandler(h, from, messageType, channel, identifier, data)
	if identifier ~= "Completionist" or from == Completionist.player then
		return
	end
	
	local dataParts = XenUtils.Utils.Split(data, "|")
	if dataParts ~= nil then
		if dataParts[1] == "QuestLocations" then
		--print("Receiving")
			local indx = 2
			while indx < (#dataParts - 1) do
				questId = dataParts[indx]
				x = tonumber(dataParts[indx+1])
				z = tonumber(dataParts[indx+2])

				local quest = Completionist.Quests[questId]
				if quest ~= nil then
					SaveQuestCoords(questId, x, z)
				end
				
				indx = indx + 3
			end
		elseif dataParts[1] == "ShareQuestLocations" then
		--print("Sharing")
			BroadcastSavedQuests()
		elseif dataParts[1] == "SoundOff" then
			BroadcastMessage("Version|" .. Completionist.version .. "|" .. Completionist.player)
		elseif dataParts[1] == "Version" then
			if Completionist.printVersions == true then
				print(data)
			end
		end
	end
end

local function RegisterPostStartupEvents()
	Command.Event.Attach(Command.Slash.Register(Completionist.slashName), SlashHandler, "Completionist.SlashHandler")
	Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, SaveVariables, "Completionist.SaveVariables")
	Command.Event.Attach(Event.Quest.Complete, QuestComplete, "Completionist.QuestComplete")
	Command.Event.Attach(Event.Quest.Accept, QuestAccepted, "Completionist.QuestAccepted")
	Command.Event.Attach(Event.Message.Receive, MessageHandler, "Completionist.MessageHandler")
	Command.Message.Accept(nil, "Completionist")
end

local function MergeExtraQuests()
	if Completionist.extraQuestDetails ~= nil then
		for id, detail in pairs(Completionist.extraQuestDetails) do
			if Completionist.Quests[id] == nil then
				Completionist.Quests[id] = detail
				
				if Completionist.ZoneQuestMap[detail.Zone] == nil then
					Completionist.ZoneQuestMap[detail.Zone] = {}
				end
				
				table.insert(Completionist.ZoneQuestMap[detail.Zone], id)
				
				print("Merged quest " .. id .. " from zone " .. detail.Zone)
			end
		end
	end
end

local function BuildZoneMaps()
	Completionist.French2EnglishZoneMap = {}
	for english, french in pairs(Completionist.FrenchZoneMap) do
		Completionist.French2EnglishZoneMap[french] = english
	end
	
	Completionist.German2EnglishZoneMap = {}
	for english, german in pairs(Completionist.GermanZoneMap) do
		Completionist.German2EnglishZoneMap[german] = english
	end
end

local function HideSettings()
	Completionist.parentFrame.settingsFrame:SetVisible(false)
	
	Completionist.isButtonShown = Completionist.parentFrame.showButtonCheck:GetChecked()
	Completionist.isButtonLocked = Completionist.parentFrame.lockButtonCheck:GetChecked()
	Completionist.hideEmptyZones = Completionist.parentFrame.hideZoneCheck:GetChecked()
	Completionist.lang = Completionist.parentFrame.langSelect:GetSelectedItem()
	Completionist.parentFrame.coordText:SetKeyFocus(false)

	
	Completionist.button:SetVisible(Completionist.isButtonShown)
	Completionist.DragFrame.SetEnabled(Completionist.dragFrame, not Completionist.isButtonLocked)
	
	Completionist.SetLocale()
	RedrawLabels()
	BuildFilterList()
	RedrawZoneNames()
	RedrawList()
	SetQuestText()
	
	Completionist.parentFrame.mainFrame:SetVisible(true)
end

local function Startup()
	if Completionist.startup == true then
		local quests = Inspect.Quest.Complete()
		if quests == nil then
			return true
		end
		
		local playerDetails = Inspect.Unit.Detail("player")
		if playerDetails == nil or playerDetails.alliance == nil or playerDetails.name == nil then
			return true
		end
		
		Completionist.player = playerDetails.name
		
		if playerDetails.alliance == "guardian" or playerDetails.alliance == "Guardian" then
			Completionist.faction = "Guardian"
		else
			Completionist.faction = "Defiant"
		end
		
		SetButtonCoords(Completionist.buttonX, Completionist.buttonY)
		
		SetResetTimes()
		
		IgnoreQuests()
		
		MergeExtraQuests()
		CleanQuestCoords()
		
		BuildZoneMaps()
		
		BuildFilterList()
		
		UpdatedCompleted(quests)
		
		Completionist.startup = false

		HideSettings()
		
		RegisterPostStartupEvents()
		
		local currentTime = os.time()
		if Completionist.lastSharedCoords == nil or Completionist.lastSharedCoords + (60 * 60 * 24 * 7) < currentTime then
			BroadcastSavedQuests()
		end
	end
	
	return false
end

local function GetQuestCoordList()
	local coordList = ""
	for id, coords in pairs(Completionist.questCoords) do
		coordList = coordList .. id .. " = " .. coords .. "\n"
	end
	
	return coordList
end

local function ShowSettings()
	Completionist.parentFrame.mainFrame:SetVisible(false)
	
	Completionist.parentFrame.showButtonCheck:SetChecked(Completionist.isButtonShown)
	Completionist.parentFrame.lockButtonCheck:SetChecked(Completionist.isButtonLocked)
	Completionist.parentFrame.hideZoneCheck:SetChecked(Completionist.hideEmptyZones)
	Completionist.parentFrame.langSelect:SetSelectedItem(Completionist.lang)
	Completionist.parentFrame.coordText:SetText(GetQuestCoordList())
	
	Completionist.parentFrame.settingsFrame:SetVisible(true)
end

local function ToggleSettings()
	if Completionist.parentFrame.mainFrame:GetVisible() == true then
		ShowSettings()
	else
		HideSettings()
	end
end

local function LangSelected(item)
	Completionist.lang = item
	Completionist.SetLocale()
	RedrawLabels()
end

local function ShowQuestPopup(Completionist, CompletionistWindow)
	if Inspect.System.Secure() ~= true then
		local id = CompletionistWindow.list:GetSelectedValue()
		if id ~= nil then
			local quest = Completionist.Quests[id]
			if quest ~= nil then
				local englishZoneName = GetEnglishZoneName(CompletionistWindow.select:GetSelectedItem())
				if englishZoneName == Completionist.IgnoreZone then
					CompletionistWindow.ignoredPopupMenu:Show()
				else
					local giver = Completionist.Givers[quest.NPC]
					local questCoords = GetQuestCoords(giver, id)
					local questWorld = Completionist.ZoneWorldMap[englishZoneName]
					local thisWorld = ""
					if questWorld ~= nil and questCoords ~= "" then
						local playerDetail = Inspect.Unit.Detail("player")
						if playerDetail ~= nil and playerDetail.zone ~= nil then
							local zoneDetail = Inspect.Zone.Detail(playerDetail.zone)
							if zoneDetail ~= nil then
								local thisZone = GetEnglishZoneName(zoneDetail.name)
								if thisZone ~= nil then
									thisWorld = Completionist.ZoneWorldMap[thisZone]
								end
							end
						end
					end
					
					if questWorld ~= nil and questWorld == thisWorld then
						local coords = XenUtils.Utils.Split(questCoords, ",")
						
						if coords ~= nil and #coords == 2 then 
							CompletionistWindow.questPopupMenu:SetItemCallback(CompletionistWindow.questPopupMenu.markItem, "setwaypoint " .. coords[1] .. " " .. coords[2])
							CompletionistWindow.questPopupMenu:EnableItem(CompletionistWindow.questPopupMenu.markItem, true)
						else
							CompletionistWindow.questPopupMenu:EnableItem(CompletionistWindow.questPopupMenu.markItem, false)
						end
					else
						CompletionistWindow.questPopupMenu:EnableItem(CompletionistWindow.questPopupMenu.markItem, false)
					end
					
					CompletionistWindow.questPopupMenu:Show()
				end
			end
		end
	end
 end

local function Create()
	local margin = 5
	local parent = UI.CreateContext(Completionist.name .. "Context")
	local CompletionistWindow = UI.CreateFrame("SimpleWindow", "CompletionistWindow", parent)
	CompletionistWindow:SetVisible(false)
	CompletionistWindow:SetCloseButtonVisible(true)
	CompletionistWindow:SetTitle("Completionist")
	CompletionistWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Completionist.x, Completionist.y)
	CompletionistWindow:SetWidth(450)
	CompletionistWindow.settingsButton = UI.CreateFrame("Texture", "CompletionistSettingsButton", CompletionistWindow)
	CompletionistWindow.settingsButton:SetTexture(Completionist.name, "SettingsButton32.png")
	CompletionistWindow.settingsButton:SetPoint("TOPLEFT", CompletionistWindow, "TOPLEFT", 10, 18)
	local settingsButtonGlow = UI.CreateFrame("Texture", "CompletionistSettingsButton", CompletionistWindow.settingsButton)
	settingsButtonGlow:SetTexture(Completionist.name, "SettingsButtonGlow32.png")
	settingsButtonGlow:SetAllPoints(CompletionistWindow.settingsButton)
	settingsButtonGlow:SetVisible(false)
	CompletionistWindow.settingsButton:SetMouseMasking("limited")
	CompletionistWindow.settingsButton.Event.LeftClick = function() ToggleSettings() end
	CompletionistWindow.settingsButton.Event.MouseIn = function() settingsButtonGlow:SetVisible(true) end
	CompletionistWindow.settingsButton.Event.MouseOut = function() settingsButtonGlow:SetVisible(false) end
	
	CompletionistWindow.mainFrame = UI.CreateFrame("Frame", "CompletionistMainFrame", CompletionistWindow:GetContent())
	CompletionistWindow.mainFrame:SetAllPoints()
	
	CompletionistWindow.label = UI.CreateFrame("Text", "CompletionistLabel", CompletionistWindow.mainFrame)
	CompletionistWindow.label:SetPoint("TOPLEFT", CompletionistWindow.mainFrame, "TOPLEFT", margin, margin)
	CompletionistWindow.select = UI.CreateFrame("SimpleSelect", "CompletionistSelect", CompletionistWindow.mainFrame)
	CompletionistWindow.select:SetPoint("TOPLEFT", CompletionistWindow.label, "BOTTOMLEFT", 0, margin)
	CompletionistWindow.select:SetWidth(200)
	CompletionistWindow.select:SetHeight(19)
	CompletionistWindow.select:SetItems({})
	CompletionistWindow.select.Event.ItemSelect = function(view, item) ZoneSelected(item) end
	
	CompletionistWindow.filterLabel = UI.CreateFrame("Text", "CompletionistFilterLabel", CompletionistWindow.mainFrame)
	CompletionistWindow.filterLabel:SetPoint("TOPRIGHT", CompletionistWindow.mainFrame, "TOPRIGHT", -margin, margin)
	CompletionistWindow.filter = UI.CreateFrame("SimpleSelect", "CompletionistFilter", CompletionistWindow.mainFrame)
	CompletionistWindow.filter:SetPoint("TOPRIGHT", CompletionistWindow.filterLabel, "BOTTOMRIGHT", 0, margin)
	CompletionistWindow.filter:SetWidth(200)
	CompletionistWindow.filter:SetHeight(19)
	CompletionistWindow.filter:SetItems({})
	CompletionistWindow.filter.Event.ItemSelect = function(view, item) FilterSelected(item) end
	
	CompletionistWindow.questScrollView = UI.CreateFrame("SimpleScrollView", "CompletionistScrollView", CompletionistWindow.mainFrame)
	CompletionistWindow.questScrollView:SetPoint("TOPLEFT", CompletionistWindow.mainFrame, "BOTTOMLEFT", margin, -margin-122)
	CompletionistWindow.questScrollView:SetPoint("BOTTOMRIGHT", CompletionistWindow.mainFrame, "BOTTOMRIGHT", -margin, -margin)
	CompletionistWindow.questScrollView:SetBorder(1, 1, 1, 1, 1)
	CompletionistWindow.quest = UI.CreateFrame("Text", "CompletionistQuest", CompletionistWindow.mainFrame)
	CompletionistWindow.quest:SetWordwrap(true)
	CompletionistWindow.quest:SetHeight(200)
	CompletionistWindow.questScrollView:SetContent(CompletionistWindow.quest)

	CompletionistWindow.listScrollView = UI.CreateFrame("SimpleScrollView", "CompletionistScrollView", CompletionistWindow.mainFrame)
	CompletionistWindow.listScrollView:SetPoint("TOPLEFT", CompletionistWindow.select, "BOTTOMLEFT", 0, margin)
	CompletionistWindow.listScrollView:SetPoint("BOTTOMRIGHT", CompletionistWindow.questScrollView, "TOPRIGHT", 0, -margin)
	CompletionistWindow.listScrollView:SetBorder(1, 1, 1, 1, 1)
	CompletionistWindow.list = UI.CreateFrame("SimpleList", "CompletionistList", CompletionistWindow.listScrollView)
	CompletionistWindow.list:SetItems({})
	CompletionistWindow.list.Event.ItemSelect = function(view, item, quest) SetQuestText() end
	CompletionistWindow.listScrollView:SetContent(CompletionistWindow.list)
	
	local restrictedParent = UI.CreateContext(Completionist.name .. "RestrictedContext")
	restrictedParent:SetSecureMode("restricted")
	restrictedParent:SetStrata("topmost")
	CompletionistWindow.questPopupMenu = XenUtils.CreatePopupMenu("QuestPopup", restrictedParent, 130)
	CompletionistWindow.questPopupMenu.markItem = CompletionistWindow.questPopupMenu:AddItem(Completionist.GetLocaleValue("Mark quest start"), "setwaypoint 3000 4000")
	CompletionistWindow.questPopupMenu:AddItem(Completionist.GetLocaleValue("Ignore quest"), function() IgnoreQuest(CompletionistWindow.list:GetSelectedValue()) end)
	
	local unrestrictedParent = UI.CreateContext(Completionist.name .. "UnrestrictedContext")
	unrestrictedParent:SetStrata("topmost")
	CompletionistWindow.ignoredPopupMenu = XenUtils.CreatePopupMenu("IgnoredPopup", unrestrictedParent, 100)
	CompletionistWindow.ignoredPopupMenu:AddItem(Completionist.GetLocaleValue("Restore quest"), function() RestoreQuest(CompletionistWindow.list:GetSelectedValue()) end)
	
	CompletionistWindow.quest:SetMouseMasking("limited")
	CompletionistWindow.quest.Event.RightClick = function() ShowQuestPopup(Completionist, CompletionistWindow) end
	CompletionistWindow.quest.Event.LeftDown = function() HideQuestPopup() CompletionistWindow.ignoredPopupMenu:Hide() end
	
	CompletionistWindow.settingsFrame = UI.CreateFrame("Frame", "CompletionistSettingsFrame", CompletionistWindow:GetContent())
	CompletionistWindow.settingsFrame:SetAllPoints()
	CompletionistWindow.settingsFrame:SetVisible(false)
	
	CompletionistWindow.langLabel = UI.CreateFrame("Text", "CompletionistLabel", CompletionistWindow.settingsFrame)
	CompletionistWindow.langLabel:SetPoint("TOPLEFT", CompletionistWindow.settingsFrame, "TOPLEFT", margin * 4, margin * 4)
	CompletionistWindow.langSelect = UI.CreateFrame("SimpleSelect", "CompletionistLangSelect", CompletionistWindow.settingsFrame)
	CompletionistWindow.langSelect:SetPoint("TOPLEFT", CompletionistWindow.langLabel, "TOPRIGHT", margin, 0)
	CompletionistWindow.langSelect:SetWidth(70)
	CompletionistWindow.langSelect:SetHeight(19)
	local items = {}
	table.insert(items, "English")
	table.insert(items, "Deutsch")
	table.insert(items, "Francais")
	table.sort(items)
	CompletionistWindow.langSelect:SetItems(items)
	CompletionistWindow.langSelect:SetSelectedItem(Completionist.lang)
	CompletionistWindow.langSelect.Event.ItemSelect = function(view, item) LangSelected(item) end
	
	CompletionistWindow.showButtonCheck = UI.CreateFrame("SimpleCheckbox", "CompletionistHideButton", CompletionistWindow.settingsFrame)
	CompletionistWindow.showButtonCheck:SetPoint("TOPLEFT", CompletionistWindow.langLabel, "BOTTOMLEFT", 0, margin * 2)

	CompletionistWindow.lockButtonCheck = UI.CreateFrame("SimpleCheckbox", "CompletionistHideButton", CompletionistWindow.settingsFrame)
	CompletionistWindow.lockButtonCheck:SetPoint("TOPLEFT", CompletionistWindow.showButtonCheck, "BOTTOMLEFT", 0, margin * 2)

	CompletionistWindow.hideZoneCheck = UI.CreateFrame("SimpleCheckbox", "CompletionistHideZone", CompletionistWindow.settingsFrame)
	CompletionistWindow.hideZoneCheck:SetPoint("TOPLEFT", CompletionistWindow.lockButtonCheck, "BOTTOMLEFT", 0, margin * 2)
	
	CompletionistWindow.settingsOK = UI.CreateFrame("RiftButton", "CompletionistSettingsOK", CompletionistWindow.settingsFrame)
	CompletionistWindow.settingsOK:SetPoint("BOTTOMCENTER", CompletionistWindow.settingsFrame, "BOTTOMCENTER", 0, - (margin * 2))
	CompletionistWindow.settingsOK:SetText("OK")
	CompletionistWindow.settingsOK.Event.LeftClick = function() HideSettings() end

	CompletionistWindow.coordLabel = UI.CreateFrame("Text", "CompletionistCoordLabel", CompletionistWindow.settingsFrame)
	CompletionistWindow.coordLabel:SetPoint("TOPLEFT", CompletionistWindow.hideZoneCheck, "BOTTOMLEFT", 0, margin * 2)
	CompletionistWindow.coordText = UI.CreateFrame("SimpleTextArea", "CompletionistCoordText", CompletionistWindow.settingsFrame)
	CompletionistWindow.coordText:SetPoint("TOPLEFT", CompletionistWindow.coordLabel, "BOTTOMLEFT", 0, margin)
	CompletionistWindow.coordText:SetPoint("BOTTOMRIGHT", CompletionistWindow.settingsOK, "TOPCENTER", 0, -margin * 4)
	CompletionistWindow.coordText:SetBorder(1, 1, 1, 1, 1)

	CompletionistWindow.thxLabel = UI.CreateFrame("Text", "CompletionistThxLabel", CompletionistWindow.settingsFrame)
	CompletionistWindow.thxLabel:SetPoint("TOPLEFT", CompletionistWindow.coordText, "TOPRIGHT", margin * 2, 0)
	CompletionistWindow.thxLabel:SetText("Quest coords provided by:")
	CompletionistWindow.thxText = UI.CreateFrame("Text", "CompletionistThxText", CompletionistWindow.settingsFrame)
	CompletionistWindow.thxText:SetPoint("TOPLEFT", CompletionistWindow.thxLabel, "BOTTOMLEFT", 0, margin)
	CompletionistWindow.thxText:SetPoint("BOTTOMLEFT", CompletionistWindow.coordText, "BOTTOMRIGHT", margin * 3, 0)
	CompletionistWindow.thxText:SetWordwrap(true)
	CompletionistWindow.thxText:SetWidth(150)
	CompletionistWindow.thxText:SetText("Sulra@zaviel, Isthsiike@zaviel, Jhogo@zaviel, Cnaaa@curse")

	local button = UI.CreateFrame("Texture", "CompletionistButton", parent)
	button:SetTexture(Completionist.name, "icon.png")
	button.Event.LeftClick = function() ToggleVisibility() end
	Completionist.button = button
	Completionist.dragFrame = Completionist.DragFrame.Create(button, button:GetWidth(), button:GetHeight(), function(dragFrame) SetButtonCoords(dragFrame.x, dragFrame.y) end)
	CompletionistWindow.tooltip = UI.CreateFrame("SimpleTooltip", "CompletionistTooltip", parent)
	CompletionistWindow.tooltip:InjectEvents(Completionist.dragFrame.frame, GetZoneTooltip)
	button:SetVisible(false)
	
	Completionist.parent = parent
	Completionist.parentFrame = CompletionistWindow

	EnsureOnScreen()
	RedrawLabels()
	ShowSettings()
end


--
-- Event Handlers
--
local function TryStartup()
	Completionist.startCount = Completionist.startCount + 1
	if Completionist.startCount % 50 == 0 then
		return Startup()
	end
	
	return true
end

local function Initialise(h, addon)
	if addon == Completionist.name then
		Completionist.startup = true
		Create()
		Completionist.AsyncHandler = XenUtils.CreateAsyncHandler("Completionist")
		Completionist.AsyncHandler:StartHandler("Startup", TryStartup)
	end
end

local function GetSavedValue(value, default)
	if value ~= nil then
		return value
	else
		return default
	end
end

local function LoadVariables(h, addon)
	if addon == Completionist.name then
		-- now that variables are loaded and saved positions restored we can create frame
		if Completionist_SavedVariables then
			Completionist.x = GetSavedValue(Completionist_SavedVariables.x, 100)
			Completionist.y = GetSavedValue(Completionist_SavedVariables.y, 20)
			Completionist.buttonX = GetSavedValue(Completionist_SavedVariables.buttonX, 50)
			Completionist.buttonY = GetSavedValue(Completionist_SavedVariables.buttonY, 20)
			Completionist.lang = GetSavedValue(Completionist_SavedVariables.lang, "English")
			Completionist.isButtonShown = GetSavedValue(Completionist_SavedVariables.isButtonShown, true)
			Completionist.isButtonLocked = GetSavedValue(Completionist_SavedVariables.isButtonLocked, false)
			Completionist.hideEmptyZones = GetSavedValue(Completionist_SavedVariables.hideEmptyZones, true)
			Completionist.saveUnknownQuests = GetSavedValue(Completionist_SavedVariables.saveUnknownQuests, false)
			Completionist.lastSharedCoords = Completionist_SavedVariables.lastSharedCoords
			Completionist.questCoords = GetSavedValue(Completionist_SavedVariables.questCoords, {})
			Completionist.extraQuestCoords = GetSavedValue(Completionist_SavedVariables.extraQuestCoords, {})
			Completionist.unknownQuestCoords = GetSavedValue(Completionist_SavedVariables.unknownQuestCoords, {})
			Completionist.unknownQuestDetails = GetSavedValue(Completionist_SavedVariables.unknownQuestDetails, {})

			CleanQuestCoords()
		end
		
		if Completionist_SavedCharacterVariables then
			Completionist.ignoredQuests = GetSavedValue(Completionist_SavedCharacterVariables.ignoredQuests, {})
			Completionist.completedRepeatQuests = GetSavedValue(Completionist_SavedCharacterVariables.completedRepeatQuests, {})
		end
		
		Completionist.SetLocale()
	end	
end

--
-- Register events
--
Command.Event.Attach(Event.Addon.Load.End, Initialise, "Completionist.Initialise")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, LoadVariables, "Completionist.LoadVariables")
