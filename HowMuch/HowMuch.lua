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
local addon, HowMuch = ...
HowMuch.name = "HowMuch"
HowMuch.slashName = "hm"
HowMuch.version = "v1.7"
HowMuch.lang = "English"
HowMuch.datesToKeep = 7
HowMuch.db = {}
HowMuch.derivedDb = {}
HowMuch.totalAvgVisible = true
HowMuch.totalMinVisible = false
HowMuch.totalMaxVisible = false
HowMuch.unitAvgVisible = true
HowMuch.unitMinVisible = true
HowMuch.unitMaxVisible = true
HowMuch.itemNameToIdMap = {}
HowMuch.itemNameToFullNameMap = {}
HowMuch.itemNameToRarityMap = {}
HowMuch.itemIdMap = {}
HowMuch.itemLookupQueue = {}
HowMuch.itemNameLookupHandlerRunning = false
HowMuch.lookupItems = {}
HowMuch.maxDuration = 0

local function SetPhaseDialog(phaseNumber, param1, param2)
	for i=1,6 do
		local item = "text" .. i
		if phaseNumber == i then
			HowMuch.window[item]:SetFontColor(1, 1, 1, 1)
		else
			HowMuch.window[item]:SetFontColor(132 / 255, 132 / 255, 132 / 255, 1)
		end
	end
	
	if phaseNumber == 1 then
		HowMuch.window.text1:SetText("Requesting list of all auctions from the server")
		HowMuch.window.text2:SetText("Waiting on auction list (takes a while)...")
		HowMuch.window.text3:SetText("Received auction list")
		HowMuch.window.text4:SetText("Requesting details on each auction from the server")
		HowMuch.window.text5:SetText("Received auction details")
		HowMuch.window.text6:SetText("Done")
	elseif phaseNumber == 3 then
		HowMuch.window.text3:SetText("Received list of " .. tostring(param1) .. " auctions")
	elseif phaseNumber == 5 then
		HowMuch.window.text5:SetText("Received details on " .. tostring(param1) .. " out of " .. tostring(param2) .. " auctions")
	end
end

local function GetCurrencyValues(ccyValue)
	local plat = math.floor(ccyValue / 10000)
	local remainder = ccyValue - plat * 10000
	local gold = math.floor(remainder / 100)
	local silver = remainder - gold * 100
	return plat, gold, silver
end

local function FormatCurrencyString(ccyValue)
	local plat, gold, silver = GetCurrencyValues(ccyValue)
	if plat > 0 then
		return plat .. "p " .. gold .. "g " .. silver .. "s"
	elseif gold > 0 then
		return gold .. "g " .. silver .. "s"
	else
		return silver .. "s"
	end
end

local function GetMedian(sortedArray)
	if #sortedArray == 0 then
		return 0
	end
	
	if #sortedArray == 1 then
		return sortedArray[1]
	end
	
	if math.fmod(#sortedArray,2) == 0 then
		local val1 = sortedArray[#sortedArray/2]
		local val2 = sortedArray[(#sortedArray/2)+1]
		if val1 == nil or val2 == nil then
			--print ("Len=" .. #sortedArray .. " val1=" .. tostring(val1) .. " val2=" .. tostring(val2))
			return 0
		else
			return ( sortedArray[#sortedArray/2] + sortedArray[(#sortedArray/2)+1] ) / 2
		end
	else
		return sortedArray[math.ceil(#sortedArray/2)]
	end
end

local function GetTrimmedAverage(sortedArray, dumpIt)
	if #sortedArray == 0 then
		return 0
	end
	
	if #sortedArray == 1 then
		return sortedArray[1]
	end
	
	if #sortedArray == 2 then
		return (sortedArray[1] + sortedArray[2]) / 2
	end
	
	-- Trimming outliers via quartiles.  See http://en.wikipedia.org/wiki/Quartile
	local lowerQuartileData = {}
	local upperQuartileData = {}
	local medianIndex = math.floor((#sortedArray/2.0 + 0.5) * 10) / 10
	
	for index, value in ipairs(sortedArray) do
		if index < medianIndex then
			table.insert(lowerQuartileData, value)
		elseif index > medianIndex then
			table.insert(upperQuartileData, value)
		end
	end
	
	--if math.fmod(#sortedArray,2) ~= 0 then
	--	table.insert(lowerQuartileData, sortedArray[medianIndex])
	--end
	
	--if #lowerQuartileData ~= #upperQuartileData then
		--print ("quartiles differ in size. total=" .. #sortedArray .. " lower=" .. #lowerQuartileData .. " upper=" .. #upperQuartileData)
	--end
	
	local lowerQuartileMedian = GetMedian(lowerQuartileData)
	local upperQuartileMedian = GetMedian(upperQuartileData)
	local interQuartileRange = upperQuartileMedian - lowerQuartileMedian
	local lowerBound = lowerQuartileMedian - (1.5 * interQuartileRange)
	local upperBound = upperQuartileMedian + (1.5 * interQuartileRange)
	local total = 0
	local count = 0
	for _, value in ipairs(sortedArray) do
		if value >= lowerBound and value <= upperBound then
			total = total + value
			count = count + 1
		end
	end
	
	if dumpIt == true then
		print ("lowerBound " .. lowerBound .. " upperBound " .. upperBound)
	end
	
	if count < 1 then
		return 0
	else
		return math.ceil(total / count)
	end
end

local function GetMinValueForDate(item, dateString)
	local minValue = 999999999
	local itemData = item[dateString]
	if itemData ~= nil then
		for price, data in pairs(itemData) do
			if price < minValue then
				minValue = price
			end
		end
	end
	
	return minValue
end

local function GetSortedValues(item)
	local itemValues = {}
	local minValue = 999999999
	local maxValue = 0
	for _, itemData in pairs(item) do
		for price, data in pairs(itemData) do
			if price < minValue then
				minValue = price
			end
			
			if price > maxValue then
				maxValue = price
			end
			
			for i=0,data.count do
				table.insert(itemValues, price)
			end
		end
	end
	
	table.sort(itemValues)
	return minValue, maxValue, itemValues
end

local function GetAverageValues(item, dumpIt)
	local minValue, maxValue, sortedArray = GetSortedValues(item)
	if dumpIt == true then
		dump(sortedArray)
	end
	local average = GetTrimmedAverage(sortedArray, dumpIt)
	return minValue, average, maxValue
end

local function CalculateItem(id, item)
	local minValue, averageValue, maxValue = GetAverageValues(item)
	local values = {}
	values.min = minValue
	values.avg = averageValue
	values.max = maxValue
	--print ("Item id=" .. id .. " min=" .. minValue .. " avg=" .. averageValue .. " max=" .. maxValue)
	HowMuch.derivedDb[id] = values				
end

local function GetItemValues(id)
	if HowMuch.derivedDb[id] == nil then
		CalculateItem(id, HowMuch.db[id])
	end
	
	return HowMuch.derivedDb[id]
end

local function MapItemName(itemId, itemName, rarity)
	local name = itemName:lower()
	if rarity ~= nil then
		name = name .. " (" .. rarity .. ")"
	end
	
	HowMuch.itemNameToIdMap[name] = itemId
	HowMuch.itemNameToFullNameMap[name] = itemName
	HowMuch.itemNameToRarityMap[name] = rarity
	HowMuch.itemIdMap[itemId] = name
end

local function ItemNameLookupHandler()
	if Inspect.System.Secure() ~= true then
		Command.System.Watchdog.Quiet()
		local startDog = Inspect.System.Watchdog()
		
		while(startDog > 0.025) do
			local lookupTable = {}
			local count = 0
			for itemId, _ in pairs(HowMuch.itemLookupQueue) do
				lookupTable[itemId] = 1
				count = count + 1
				if count >= 1 then
					break
				end
			end
			
			if count < 1 then
				HowMuch.itemNameLookupHandlerRunning = false
				--print ("Lookup stopped")
				return false
			else
				local resultTable = Inspect.Item.Detail(lookupTable)
				if resultTable ~= nil then
					local resultCount = 0
					for itemId, detail in pairs(resultTable) do
						MapItemName(itemId, detail.name, detail.rarity)
						resultCount = resultCount + 1
					end
					
					for itemId, _ in pairs(lookupTable) do
						HowMuch.itemLookupQueue[itemId] = nil
					end
					
					local endDog = Inspect.System.Watchdog()
					local duration = startDog - endDog
					if duration > HowMuch.maxDuration then
						HowMuch.maxDuration = duration
					end
					
					startDog = endDog
					--print ("Lookup " .. resultCount .. " max duration " .. HowMuch.maxDuration)
				end
			end
		end
	end
	
	return true
end

local function GetItemNameString(fullName, rarity)
	local name = fullName
	if rarity ~= nil then
		if rarity == "sellable" then
			name = "<font color=\"#888888\">" .. name .. "</font>"
		elseif rarity == "uncommon" then
			name = "<font color=\"#00cc00\">" .. name .. "</font>"
		elseif rarity == "rare" then
			name = "<font color=\"#2681fe\">" .. name .. "</font>"
		elseif rarity == "epic" then
			name = "<font color=\"#b049ff\">" .. name .. "</font>"
		elseif rarity == "relic" then
			name = "<font color=\"#ff9900\">" .. name .. "</font>"
		elseif rarity == "transcendant" then
			name = "<font color=\"#ff2828\">" .. name .. "</font>"
		elseif rarity == "quest" then
			name = "<font color=\"#fff600\">" .. name .. "</font>"
		end
	end
	
	return name
end

local function GetItemStrings(itemName)
	if itemName ~= nil then
		local rarities = {"", " (sellable)", " (uncommon)", " (rare)", " (epic)", " (relic)", " (transcendant)", " (quest)"}
		local results = {}
		local lowerName = itemName:lower()
		for _, suffix in ipairs(rarities) do
			local wholeName = lowerName .. suffix
			local itemId = HowMuch.itemNameToIdMap[wholeName]
			if itemId ~= nil then
				local fullName = HowMuch.itemNameToFullNameMap[wholeName]
				local rarity = HowMuch.itemNameToRarityMap[wholeName]
				local values = GetItemValues(itemId)
				local valueString = FormatCurrencyString(values.avg)
				table.insert(results, GetItemNameString(fullName, rarity) .. " = " .. valueString)
			end
		end
		
		return results
	end
end

local function LookupItems()
	for name, _ in pairs(HowMuch.lookupItems) do
		local found = false
		local results = GetItemStrings(name)
		if results ~= nil then
			for _, itemString in ipairs(results) do
				Command.Console.Display("general", false, itemString, true)
				found = true
			end
		end
		
		if found == false then
			Command.Console.Display("general", false, "Item not found: " .. tostring(name), false)
		end
	end
	
	HowMuch.lookupItems = {}
end

local function StartItemNameLookup()
	if HowMuch.itemNameLookupHandlerRunning == false then
		HowMuch.itemNameLookupHandlerRunning = true
		HowMuch.AsyncHandler.StartHandler("HowMuch.itemNameLookupHandler", ItemNameLookupHandler, nil, LookupItems)
	end
end

local function QueueItemNameMap(itemId)
	if HowMuch.itemIdMap[itemId] == nil then
		HowMuch.itemLookupQueue[itemId] = 1
	end
end

local function FindItemName(itemId)
	return HowMuch.itemIdMap[itemId]
end

local function RecalcDerivedDb()
	HowMuch.derivedDb = {}
end

local function ClearDerivedDbItem(itemId)
	HowMuch.derivedDb[itemId] = nil
end

local function GetTableForId(id)
	local ret = HowMuch.db[id]
	if ret == nil then
		ret = {}
		HowMuch.db[id] = ret
	end
	
	return ret
end

local function PurgeOldDates(idTable, latestDate)
	local lowestDate = latestDate
	local count = 0
	for dateString, _ in pairs(idTable) do
		count = count + 1
		if dateString < lowestDate then
			lowestDate = dateString
		end
	end
	
	if count > HowMuch.datesToKeep then
		idTable[lowestDate] = nil
	else
		return 0
	end
	
	return count - 1
end

local function PurgeIdTable(id, dateString)
	local idTable = HowMuch.db[id]
	if idTable ~= nil then
		local count = 0
		while(PurgeOldDates(idTable, dateString) > HowMuch.datesToKeep) do
			count = count + 1
			if count > 100 then
				break
			end
		end
		
		for thisDate, dateTable in pairs(idTable) do
			if thisDate ~= dateString then
				for price, priceTable in pairs(dateTable) do
					priceTable.ids = nil
				end
			end
		end
	end
end

local function GetDateTableForId(id, dateString)
	local idTable = GetTableForId(id)
	local ret = idTable[dateString]
	if ret == nil then
		ret = {}
		idTable[dateString] = ret
		PurgeIdTable(id, dateString)
	end
	
	return ret
end

local function GetPriceTableForId(id, dateString, price)
	local dateTable = GetDateTableForId(id, dateString)
	local ret = dateTable[price]
	if ret == nil then
		ret = {}
		ret.count = 0
		ret.ids = {}
		dateTable[price] = ret
	end
	
	return ret
end

local function RegisterPrice(dateString, auctionId, itemId, price, stacks)
	local unitPrice = math.floor(price / stacks)
	local priceTable = GetPriceTableForId(itemId, dateString, unitPrice)
	if priceTable.ids[auctionId] == nil then
		priceTable.ids[auctionId] = 1
		priceTable.count = priceTable.count + 1
	end
end

local function AuctionDetailUpdateHandler(stateTable)
	if stateTable.auctions == nil then
		return false
	else
		local auctionIds = {}
		local count = 0
		for id, _ in pairs(stateTable.auctions) do
			auctionIds[id] = 1
			count = count + 1
			if count > stateTable.batchSize then
				break
			end
		end
		
		if count == 0 then
			return false
		end
		
		for id, _ in pairs(auctionIds) do
			stateTable.auctions[id] = nil
		end
		
		if Inspect.Interaction("auction") ~= true then
			return false
		end
		
		local details = Inspect.Auction.Detail(auctionIds)
		local dateString = stateTable.dateString
		for _, detail in pairs(details) do
			local stacks = detail.itemStack
			if stacks == nil then
				stacks = 1
			end
			
			if detail.buyout ~= nil then
				RegisterPrice(dateString, detail.id, detail.itemType, detail.buyout, stacks)
				ClearDerivedDbItem(detail.itemType)
				QueueItemNameMap(detail.itemType)
			end
		end
		
		stateTable.auctionsProcessed = stateTable.auctionsProcessed + count
		SetPhaseDialog(5, stateTable.auctionsProcessed, stateTable.totalAuctions)
		
		if next(stateTable.auctions) == nil then
			StartItemNameLookup()
			return false
		end
	end
	
	return true
end

local function StopAuctionDetailHandler()
	RecalcDerivedDb()
	if HowMuch.window:GetVisible() == true then
		HowMuch.window:SetVisible(false)
	end
end

local function StartAuctionDetailHandler(auctions, totalAuctions)
	SetPhaseDialog(4)
	local stateTable = {}
	stateTable.batchSize = 100
	stateTable.auctionsProcessed = 0
	stateTable.auctions = auctions
	stateTable.totalAuctions = totalAuctions
	stateTable.dateString = os.date("%Y%m%d")
	HowMuch.AsyncHandler.StartHandler("AuctionDetailUpdateHandler", AuctionDetailUpdateHandler, stateTable, StopAuctionDetailHandler)
end

local function PurgeHandler(purgeTable)
	if Inspect.System.Secure() ~= true then
		if purgeTable == nil then
			return false
		else
			local dateString = os.date("%Y%m%d")
			for i=1,50 do
				local id = table.remove(purgeTable)
				if id == nil then
					return false
				else
					PurgeIdTable(id, dateString)
				end
			end
		end
	end
	
	return true
end

local function RefreshItemNameDb()
	if HowMuch.itemNameDbRefreshed ~= true then
		for itemId, _ in pairs(HowMuch.db) do
			QueueItemNameMap(itemId)
		end
		
		HowMuch.itemNameDbRefreshed = true
		StartItemNameLookup()
		print("Refreshing item lookup table.  please wait...")
	else
		LookupItems()
	end
end

local function StartPurgeHandler()
	local purgeTable = {}
	for id, _ in pairs(HowMuch.db) do
		table.insert(purgeTable, id)
	end
	
	HowMuch.AsyncHandler.StartHandler("PurgeHandler", PurgeHandler, purgeTable)
end

local function ScanEventReceived(h, auctionType, auctions)
	local count = 0
	for _, index in pairs(auctions) do
		count = count + 1
	end
	
	if count > 0 then
		SetPhaseDialog(3, count)
		StartAuctionDetailHandler(auctions, count)
	end
end

local function StartScan()
	if Inspect.Interaction("auction") == true then
		if Inspect.Queue.Status("auctionfullscan") ~= false then
			SetPhaseDialog(1)
			HowMuch.warningTooltip:Hide(HowMuch.button)
			HowMuch.window:SetVisible(true)
			local scanArgs = {}
			scanArgs.type = "search"
			--scanArgs.index = 1
			Command.Auction.Scan(scanArgs)
			HowMuch.dbRefreshDate = os.time()
			SetPhaseDialog(2)
		end
	end
end

local function TooltipEventReceived(h, tooltipType, itemId)
	if HowMuch.tooltip == nil then
		return
	end
	
	if UI.Native.Tooltip:GetLoaded() ~= true then
		HowMuch.tooltip:Hide()
	elseif tooltipType == nil and HowMuch.tooltipShowFrame ~= nil then
		if HowMuch.tooltipShowFrame == Inspect.Time.Frame() then
			HowMuch.tooltip:Show()
		end
	end
	
	if tooltipType == "item" then
		local details = Inspect.Item.Detail(itemId)
		if details ~= nil and details.bound ~= true and details.type ~= nil then
			if HowMuch.derivedDb ~= nil and HowMuch.db[details.type] ~= nil then
				local itemValues = GetItemValues(details.type)
				local stacks = 1
				if details.stack ~= nil then
					stacks = details.stack
				end
				
				HowMuch.tooltip:SetValues(itemValues.avg, itemValues.min, itemValues.max, stacks)
				HowMuch.tooltipShowFrame = Inspect.Time.Frame()
				HowMuch.tooltip:Show()
			end
		end
	elseif tooltipType == "itemtype" then
		if itemId ~= nil then
			if HowMuch.derivedDb ~= nil and HowMuch.db[itemId] ~= nil then
				local itemValues = GetItemValues(itemId)
				HowMuch.tooltip:SetValues(itemValues.avg, itemValues.min, itemValues.max, 1)
				HowMuch.tooltipShowFrame = Inspect.Time.Frame()
				HowMuch.tooltip:Show()
			end
		end
	end
end

local function ShowWarningTooltip()
	local oldestDate = os.time() - HowMuch.datesToKeep * 24 * 60 * 60
	if HowMuch.dbRefreshDate == nil or HowMuch.dbRefreshDate < oldestDate then
		local warningString = "HowMuch db out of date.\nPress spanner to refresh"
		if HowMuch.dbRefreshDate == nil then
			warningString = "HowMuch db not setup.\nPress spanner to scan prices"
		end
		
		HowMuch.warningTooltip:Show(HowMuch.button, warningString, "TOPRIGHT")
	else
		HowMuch.warningTooltip:Hide(HowMuch.button)
	end
end

local function SetTooltipVisibilities()
	local tooltip = HowMuch.tooltip
	tooltip:SetUnitAvgVisible(HowMuch.unitAvgVisible)
	tooltip:SetUnitMinVisible(HowMuch.unitMinVisible)
	tooltip:SetUnitMaxVisible(HowMuch.unitMaxVisible)
	tooltip:SetTotalAvgVisible(HowMuch.totalAvgVisible)
	tooltip:SetTotalMinVisible(HowMuch.totalMinVisible)
	tooltip:SetTotalMaxVisible(HowMuch.totalMaxVisible)
end

local function ShowConfigWindow()
	if HowMuch.configWindow:GetVisible() ~= true then
		HowMuch.configWindow.checkbox1:SetChecked(HowMuch.unitAvgVisible)
		HowMuch.configWindow.checkbox2:SetChecked(HowMuch.unitMinVisible)
		HowMuch.configWindow.checkbox3:SetChecked(HowMuch.unitMaxVisible)
		HowMuch.configWindow.checkbox4:SetChecked(HowMuch.totalAvgVisible)
		HowMuch.configWindow.checkbox5:SetChecked(HowMuch.totalMinVisible)
		HowMuch.configWindow.checkbox6:SetChecked(HowMuch.totalMaxVisible)
		HowMuch.configWindow:SetVisible(true)
	end
end

local function ConfigClosed()
	HowMuch.unitAvgVisible = HowMuch.configWindow.checkbox1:GetChecked()
	HowMuch.unitMinVisible = HowMuch.configWindow.checkbox2:GetChecked()
	HowMuch.unitMaxVisible = HowMuch.configWindow.checkbox3:GetChecked()
	HowMuch.totalAvgVisible = HowMuch.configWindow.checkbox4:GetChecked()
	HowMuch.totalMinVisible = HowMuch.configWindow.checkbox5:GetChecked()
	HowMuch.totalMaxVisible = HowMuch.configWindow.checkbox6:GetChecked()
	SetTooltipVisibilities()
end

local function InteractionEventReceived(h, interaction, state)
	if interaction == "auction" then
		if state == true then
			HowMuch.button:SetLayer(UI.Native.Auction:GetLayer() + 1)
			HowMuch.button:SetVisible(true)
			ShowWarningTooltip()
		else
			HowMuch.button:SetVisible(false)
			HowMuch.window:SetVisible(false)
		end
	end
end

local function SlashHandler(h, args)
	if args == "config" then
		ShowConfigWindow()
	else
		local bracketTrim = args:gsub("^%s*%[?(.-)%]?%s*$", "%1")
		if bracketTrim ~= "" then
			HowMuch.lookupItems[bracketTrim] = 1
			RefreshItemNameDb()
		end
	end
end

local function SaveVariables(h, addon)
	if addon == HowMuch.name then
		-- now copy saved group to settings so that they can be preserved on logout
		HowMuch_SavedVariables = {}
		HowMuch_SavedVariables.version = HowMuch.version
		HowMuch_SavedVariables.lang = HowMuch.lang
		HowMuch_SavedVariables.db = HowMuch.db
		HowMuch_SavedVariables.dbRefreshDate = HowMuch.dbRefreshDate
		HowMuch_SavedVariables.totalAvgVisible = HowMuch.totalAvgVisible
		HowMuch_SavedVariables.totalMinVisible = HowMuch.totalMinVisible
		HowMuch_SavedVariables.totalMaxVisible = HowMuch.totalMaxVisible
		HowMuch_SavedVariables.unitAvgVisible = HowMuch.unitAvgVisible
		HowMuch_SavedVariables.unitMinVisible = HowMuch.unitMinVisible
		HowMuch_SavedVariables.unitMaxVisible = HowMuch.unitMaxVisible
	end
end

local function RegisterPostStartupEvents()
	Command.Event.Attach(Command.Slash.Register(HowMuch.slashName), SlashHandler, "HowMuch.SlashHandler")
	Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, SaveVariables, "HowMuch.SaveVariables")
	Command.Event.Attach(Event.Auction.Scan, ScanEventReceived, "HowMuch.ScanEventReceived")
	Command.Event.Attach(Event.Tooltip, TooltipEventReceived, "HowMuch.TooltipEventReceived")
	Command.Event.Attach(Event.Interaction, InteractionEventReceived, "HowMuch.InteractionEventReceived")
end

local function Create()
	local margin = 5
	local parent = UI.CreateContext(HowMuch.name .. "Context")
	parent:SetStrata("tutorial")
	local HowMuchWindow = UI.CreateFrame("SimpleWindow", "HowMuchWindow", parent)
	HowMuchWindow:SetVisible(false)
	HowMuchWindow:SetCloseButtonVisible(true)
	HowMuchWindow:SetTitle("HowMuch")
	HowMuchWindow:SetPoint("TOPLEFT", UI.Native.Auction, "TOPLEFT", 10, 10)
	HowMuchWindow:SetWidth(300)
	HowMuchWindow:SetHeight(350)
	HowMuchWindow.text1 = UI.CreateFrame("Text", "HowMuchWindowText1", HowMuchWindow)
	HowMuchWindow.text1:SetPoint("TOPCENTER", HowMuchWindow, "TOPCENTER", 0, 50)
	HowMuchWindow.text2 = UI.CreateFrame("Text", "HowMuchWindowText2", HowMuchWindow)
	HowMuchWindow.text2:SetPoint("TOPCENTER", HowMuchWindow.text1, "TOPCENTER", 0, 20)
	HowMuchWindow.text3 = UI.CreateFrame("Text", "HowMuchWindowText3", HowMuchWindow)
	HowMuchWindow.text3:SetPoint("TOPCENTER", HowMuchWindow.text2, "TOPCENTER", 0, 20)
	HowMuchWindow.text4 = UI.CreateFrame("Text", "HowMuchWindowText4", HowMuchWindow)
	HowMuchWindow.text4:SetPoint("TOPCENTER", HowMuchWindow.text3, "TOPCENTER", 0, 20)
	HowMuchWindow.text5 = UI.CreateFrame("Text", "HowMuchWindowText5", HowMuchWindow)
	HowMuchWindow.text5:SetPoint("TOPCENTER", HowMuchWindow.text4, "TOPCENTER", 0, 20)
	HowMuchWindow.text6 = UI.CreateFrame("Text", "HowMuchWindowText6", HowMuchWindow)
	HowMuchWindow.text6:SetPoint("TOPCENTER", HowMuchWindow.text5, "TOPCENTER", 0, 20)
	HowMuch.window = HowMuchWindow
	
	local button = UI.CreateFrame("Texture", "HowMuchButton", parent)
	button:SetVisible(false)
	button:SetTexture(HowMuch.name, "SettingsButton32.png")
	button:SetPoint("TOPLEFT", UI.Native.Auction, "TOPLEFT", 18, 18)
	HowMuch.button = button
	local settingsButtonGlow = UI.CreateFrame("Texture", "HowMuchButtonGlow", button)
	settingsButtonGlow:SetTexture(HowMuch.name, "SettingsButtonGlow32.png")
	settingsButtonGlow:SetAllPoints(button)
	settingsButtonGlow:SetVisible(false)
	button:SetMouseMasking("limited")
	button.Event.MouseIn = function() settingsButtonGlow:SetVisible(true) end
	button.Event.MouseOut = function() settingsButtonGlow:SetVisible(false) end

	HowMuch.warningTooltip = UI.CreateFrame("SimpleTooltip", "HowMuchWarningToolip", button)
	
	local tooltipParent = UI.CreateContext(HowMuch.name .. "TooltipContext")
	tooltipParent:SetStrata("tooltip")
	HowMuch.tooltip = HowMuch.Tooltip.Create(HowMuch.name .. "Tooltip", tooltipParent)
	SetTooltipVisibilities()
	
	local configParent = UI.CreateContext(HowMuch.name .. "ConfigContext")
	local HowMuchConfig = UI.CreateFrame("SimpleWindow", "HowMuchConfigWindow", configParent)
	HowMuchConfig:SetVisible(false)
	HowMuchConfig:SetCloseButtonVisible(true)
	HowMuchConfig:SetTitle("HowMuch Configuration")
	HowMuchConfig:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	HowMuchConfig:SetWidth(300)
	HowMuchConfig:SetHeight(350)
	HowMuchConfig.Event.Close = ConfigClosed

	HowMuchConfig.title1 = UI.CreateFrame("Text", "HowMuchConfig.title1", HowMuchConfig)
	HowMuchConfig.title1:SetText("Name")
	HowMuchConfig.title1:SetPoint("TOPLEFT", HowMuchConfig, "TOPLEFT", 60, 70)
	HowMuchConfig.title2 = UI.CreateFrame("Text", "HowMuchConfig.title2", HowMuchConfig)
	HowMuchConfig.title2:SetText("Show?")
	HowMuchConfig.title2:SetPoint("TOPLEFT", HowMuchConfig, "TOPLEFT", 180, 70)

	local selectItems = { "1", "2", "3", "4", "5", "6" }
	HowMuchConfig.label1 = UI.CreateFrame("Text", "HowMuchConfig.label1", HowMuchConfig)
	HowMuchConfig.label1:SetText("Unit Avg")
	HowMuchConfig.label1:SetPoint("TOPLEFT", HowMuchConfig.title1, "TOPLEFT", 0, 30)
	HowMuchConfig.checkbox1 = UI.CreateFrame("SimpleCheckbox", "HowMuchConfig.checkbox1", HowMuchConfig)
	HowMuchConfig.checkbox1:SetPoint("TOPLEFT", HowMuchConfig.title2, "TOPLEFT", 15, 20)
	HowMuchConfig.label2 = UI.CreateFrame("Text", "HowMuchConfig.label2", HowMuchConfig)
	HowMuchConfig.label2:SetText("Unit Min")
	HowMuchConfig.label2:SetPoint("TOPLEFT", HowMuchConfig.label1, "TOPLEFT", 0, 30)
	HowMuchConfig.checkbox2 = UI.CreateFrame("SimpleCheckbox", "HowMuchConfig.checkbox2", HowMuchConfig)
	HowMuchConfig.checkbox2:SetPoint("TOPLEFT", HowMuchConfig.checkbox1, "TOPLEFT", 0, 30)
	HowMuchConfig.label3 = UI.CreateFrame("Text", "HowMuchConfig.label3", HowMuchConfig)
	HowMuchConfig.label3:SetText("Unit Max")
	HowMuchConfig.label3:SetPoint("TOPLEFT", HowMuchConfig.label2, "TOPLEFT", 0, 30)
	HowMuchConfig.checkbox3 = UI.CreateFrame("SimpleCheckbox", "HowMuchConfig.checkbox3", HowMuchConfig)
	HowMuchConfig.checkbox3:SetPoint("TOPLEFT", HowMuchConfig.checkbox2, "TOPLEFT", 0, 30)
	HowMuchConfig.label4 = UI.CreateFrame("Text", "HowMuchConfig.label4", HowMuchConfig)
	HowMuchConfig.label4:SetText("Total Avg")
	HowMuchConfig.label4:SetPoint("TOPLEFT", HowMuchConfig.label3, "TOPLEFT", 0, 30)
	HowMuchConfig.checkbox4 = UI.CreateFrame("SimpleCheckbox", "HowMuchConfig.checkbox4", HowMuchConfig)
	HowMuchConfig.checkbox4:SetPoint("TOPLEFT", HowMuchConfig.checkbox3, "TOPLEFT", 0, 30)
	HowMuchConfig.label5 = UI.CreateFrame("Text", "HowMuchConfig.label5", HowMuchConfig)
	HowMuchConfig.label5:SetText("Total Min")
	HowMuchConfig.label5:SetPoint("TOPLEFT", HowMuchConfig.label4, "TOPLEFT", 0, 30)
	HowMuchConfig.checkbox5 = UI.CreateFrame("SimpleCheckbox", "HowMuchConfig.checkbox5", HowMuchConfig)
	HowMuchConfig.checkbox5:SetPoint("TOPLEFT", HowMuchConfig.checkbox4, "TOPLEFT", 0, 30)
	HowMuchConfig.label6 = UI.CreateFrame("Text", "HowMuchConfig.label6", HowMuchConfig)
	HowMuchConfig.label6:SetText("Total Max")
	HowMuchConfig.label6:SetPoint("TOPLEFT", HowMuchConfig.label5, "TOPLEFT", 0, 30)
	HowMuchConfig.checkbox6 = UI.CreateFrame("SimpleCheckbox", "HowMuchConfig.checkbox5", HowMuchConfig)
	HowMuchConfig.checkbox6:SetPoint("TOPLEFT", HowMuchConfig.checkbox5, "TOPLEFT", 0, 30)
	
	HowMuch.configWindow = HowMuchConfig
end

local function Startup(stateTable)
	stateTable.startCount = stateTable.startCount + 1
	if stateTable.startCount % 50 == 0 then
		if stateTable.startup == true then
			stateTable.startup = false

			RegisterPostStartupEvents()

			RecalcDerivedDb()
			StartPurgeHandler()
			
			HowMuch.button:EventAttach(Event.UI.Input.Mouse.Left.Down, StartScan, "HowMuchButton.MouseClick")
			return false
		end
	end
	
	return true
end

local function Initialise(h, addon)
	if addon == HowMuch.name then
		HowMuch.startup = true
		Create()
		
		local startTable = {}
		startTable.startCount = 0
		startTable.startup = true
		HowMuch.AsyncHandler.StartHandler("Startup", Startup, startTable)
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
	if addon == HowMuch.name then
		-- now that variables are loaded and saved positions restored we can create frame
		if HowMuch_SavedVariables then
			HowMuch.lang = GetSavedValue(HowMuch_SavedVariables.lang, "English")
			HowMuch.totalAvgVisible = GetSavedValue(HowMuch_SavedVariables.totalAvgVisible, true)
			HowMuch.totalMinVisible = GetSavedValue(HowMuch_SavedVariables.totalMinVisible, false)
			HowMuch.totalMaxVisible = GetSavedValue(HowMuch_SavedVariables.totalMaxVisible, false)
			HowMuch.unitAvgVisible = GetSavedValue(HowMuch_SavedVariables.unitAvgVisible, true)
			HowMuch.unitMinVisible = GetSavedValue(HowMuch_SavedVariables.unitMinVisible, true)
			HowMuch.unitMaxVisible = GetSavedValue(HowMuch_SavedVariables.unitMaxVisible, true)
			HowMuch.db = GetSavedValue(HowMuch_SavedVariables.db, {})
			HowMuch.dbRefreshDate = GetSavedValue(HowMuch_SavedVariables.dbRefreshDate, nil)
		end
		
		--HowMuch.SetLocale()
	end	
end

--
-- Register events
--
Command.Event.Attach(Event.Addon.Load.End, Initialise, "HowMuch.Initialise")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, LoadVariables, "HowMuch.LoadVariables")
