-------------------------------------------------------------------------------
---- Author: Vince@Brutwacht                                               ----
-------------------------------------------------------------------------------

local Info, RM = ...

RM.UI = {}

local L = RM.l
local NumberFormat = RM.numberFormat
local FormatSeconds = RM.formatSeconds
local Tooltip = RM.Tooltip
local Dialog = RM.Dialog
local ListBox = RM.ListBox

local UI = UI

local VU = Library.VinceUtils

local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local tsort = table.sort
local tremove = table.remove
local setmetatable = setmetatable
local abs = math.abs
local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil
local unpack = unpack

local Context = UI.CreateContext(Info.identifier)
local RelativeTo = 0
local Dummy = function() end
local Windows = {}
RM.Windows = Windows
local Modes = {}
local Sortmodes = {}


local WindowAddTrigger, WindowAddEvent = Utility.Event.Create(Info.identifier, "Window.Add")
local WindowRemoveTrigger, WindowRemoveAddEvent = Utility.Event.Create(Info.identifier, "Window.Remove")
local WindowTitleChangeTrigger, WindowTitleChangeAddEvent = Utility.Event.Create(Info.identifier, "Window.TitleChange")



local Mode = {}
Mode.__index = Mode
function Mode:new(name)
	local self = {}
	self.name = name
	self.scrollOffset = 0
	self.index = 0
	return setmetatable(self, Mode)
end
function Mode:rightClick() end
function Mode:mouse4Click() end
function Mode:mouse5Click() end
function Mode:init() end
function Mode:update() end
function Mode:onSortmodeChange(window, newSortmode) return true end
function Mode:getReportText() end


local Sortmode = {}
Sortmode.__index = Sortmode
function Sortmode:new(key, name)
	local self = {}

	self.key = key
	self.name = name

	return setmetatable(self, Sortmode)
end
function Sortmode:getData(window, mode) return {} end
function Sortmode:getSortModeSelectionData(window, mode) return "" end
function Sortmode:getReportText(window, mode) return end
function Sortmode:isCompatibleWith(mode) return false end




local DeathLog = {}
RM.DeathLog = DeathLog
DeathLog.showDamage = true
DeathLog.showHeals = true
DeathLog.showMisc = true
function DeathLog:init()
	if self.window then
		return
	end

	self.window = RM.createWindow("RM_DeathLog", Context, self.hide)
	self.window:SetVisible(false)
	self.window:SetWidth(850)
	self.window:SetHeight(500)
	self.window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (UIParent:GetWidth() - self.window:GetWidth()) / 2, (UIParent:GetHeight() - self.window:GetHeight()) / 2)

	self.deathsList = ListBox:new("RM_DeathLog_DeathsList", self.window, false)
	self.deathsList:SetPoint("TOPLEFT", self.window, "TOPLEFT", 10, 10)
	self.deathsList:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMLEFT", 180, -10)

	local damageCheckbox, damageLabel = RM.createCheckboxWithLabel("RM_DeathLog_Damage", self.window, "BOTTOMLEFT", self.deathsList, "BOTTOMRIGHT", 10, 0, self.showDamage, L["DL_Damage"], function()
		self.showDamage = not self.showDamage
		self.selectionChange()
	end)
	local healsCheckbox, healsLabel = RM.createCheckboxWithLabel("RM_DeathLog_Heals", self.window, "TOP", damageCheckbox, "TOP", nil, 0, self.showHeals, L["DL_Heals"], function()
		self.showHeals = not self.showHeals
		self.selectionChange()
	end)
	healsCheckbox:SetPoint("LEFT", damageLabel, "RIGHT", 10, nil)
	local miscCheckbox, miscLabel = RM.createCheckboxWithLabel("RM_DeathLog_Misc", self.window, "TOP", healsCheckbox, "TOP", nil, 0, self.showMisc, L["DL_Misc"], function()
		self.showMisc = not self.showMisc
		self.selectionChange()
	end)
	miscCheckbox:SetPoint("LEFT", healsLabel, "RIGHT", 10, nil)

	self.mask = UI.CreateFrame("Mask", "RM_DeathLog_Mask", self.window)
	self.logScrollbar = UI.CreateFrame("RiftScrollbar", "RM_DeathLog_LogScrollbar", self.window)
--	self.logScrollbarHorizontal = UI.CreateFrame("RiftScrollbar", "RM_DeathLog_LogScrollbarHorizontal", self.window)

	self.logScrollbar:SetOrientation("vertical")
	self.logScrollbar:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", -10, 10)
	self.logScrollbar:SetPoint("BOTTOM", damageLabel, "TOP", nil, -5)
	self.logScrollbar:EventAttach(Event.UI.Scrollbar.Change, function()
		self.log:SetPoint("TOPLEFT", self.mask, "TOPLEFT", 5 , VU.round(self.logScrollbar:GetPosition() / self.logCount * self.log:GetHeight()) * -1)
	end, "Event.UI.Scrollbar.Change")

	self.mask:SetPoint("TOPLEFT", self.deathsList, "TOPRIGHT", 10, 0)
	self.mask:SetPoint("BOTTOMRIGHT", self.logScrollbar, "BOTTOMLEFT", -10, 0)
	self.mask:SetBackgroundColor(0, 0, 0, .7)
	self.mask:EventAttach(Event.UI.Input.Mouse.Wheel.Back, function()
		self.logScrollbar:NudgeDown()
	end, "Event.UI.Input.Mouse.Wheel.Back")
	self.mask:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function()
		self.logScrollbar:NudgeUp()
	end, "Event.UI.Input.Mouse.Wheel.Forward")

--	self.logScrollbarHorizontal:SetOrientation("horizontal")
--	self.logScrollbarHorizontal:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", -10, -10)
--	self.logScrollbarHorizontal:SetPoint("LEFT", self.mask, "LEFT")
--	self.logScrollbarHorizontal.Event.ScrollbarChange = function()
--		self.log:SetPoint("TOPLEFT", self.mask, "TOPLEFT", 5 - round(self.log:GetWidth() / self.mask:GetWidth() * self.logScrollbarHorizontal:GetPosition()), round(self.logScrollbar:GetPosition() / self.logCount * self.log:GetHeight()) * -1)
--	end

	self.log = RM.createTextFrame("RM_DeathLog_Log", self.mask)
	self.log:SetPoint("RIGHT", self.mask, "RIGHT", -5, nil)
	self.log:SetFontSize(14)
	self.log:SetText("", true)
end
function DeathLog.selectionChange()
	local text = {}
	local playerName = DeathLog.player.detail.name
	local log = DeathLog.player.deathLog[DeathLog.deathsList:getSelectedIndex()]
	local deathTime = log.ingameTime

	for i = log.rangeStart, log.rangeEnd do
		local entry = log.data[i]

		local line
		local type = entry.abilityType or "physical"
		local statType = entry.statType
		if statType ~= "damage" and statType ~= "heal" and DeathLog.showMisc then
			local left
			local middle
			local right
			local caster = ("%s's <font color=\"#%s\">%s (%s)</font>"):format(entry.caster.name, RM.decToHex(RiftMeter_abilityColors[type]), entry.ability.name, type:sub(1, 1):upper() .. type:sub(2))

			if statType == "dodges" then
				left = playerName
				middle = L["DL_dodges"]
				right = caster
			elseif statType == "immunes" then
				left = playerName
				middle = L["DL_immunes"]
				right = caster
			elseif statType == "misses" then
				left = caster
				middle = L["DL_misses"]
				right = playerName
			elseif statType == "parries" then
				left = playerName
				middle = L["DL_parries"]
				right = caster
			elseif statType == "resists" then
				left = playerName
				middle = L["DL_resists"]
				right = caster
			end

			line = ("%s %s %s."):format(left, middle, right)
		elseif (statType == "damage" and DeathLog.showDamage) or (statType == "heal" and DeathLog.showHeals) then
			local extra = {}
			if entry.overheal then
				tinsert(extra, entry.overheal .. " " .. L["DL_Overheal"])
			else
				if entry.damageAbsorbed then
					tinsert(extra, entry.damageAbsorbed .. " " .. L["absorbed"])
				end
				if entry.damageBlocked then
					tinsert(extra, entry.damageBlocked .. " " .. L["blocked"])
				end
				if entry.damageDeflected then
					tinsert(extra, entry.damageDeflected .. " " .. L["deflected"])
				end
				if entry.damageIntercepted then
					tinsert(extra, entry.damageIntercepted .. " " .. L["intercepted"])
				end
-- who cares?
--				if entry.damageModified then
--					tinsert(extra, entry.damageModified .. " " .. L["modified"])
--				end
				if entry.overkill then
					tinsert(extra, entry.overkill .. " " .. L["DL_Overkill"])
				end
			end

			local extraText = ""
			if #extra > 0 then
				extraText = " (" .. table.concat(extra, ", ") .. ")"
			end

			line = ("%s's <font color=\"#%s\">%s%s</font> %s %s %s %+d%s."):format(
				entry.caster.name,
				RM.decToHex(RiftMeter_abilityColors[type:lower()] or {1, 1, 1}),
				entry.ability.name,
				statType == "damage" and (" (" .. type:sub(1, 1):upper() .. type:sub(2) .. ")") or "",
				entry.crit and L["DL_crits"] or (statType == "damage" and L["DL_hits"] or L["DL_heals"]),
				playerName,
				L["DL_for"],
				entry.amount,
				extraText
			)
		end

		if line then
			tinsert(text, ("<font color=\"#%s\">%+.2f\t%s</font>"):format(
				statType == "heal" and "21A621" or (statType == "damage" and "A72121" or "FFD100"),
				entry.time - deathTime,
				line
			))
		end
	end

	tinsert(text, ("+0.00\t%s %s. Game Over."):format(playerName, L["DL_dies"]))

	DeathLog.logCount = #text
	DeathLog.log:SetText(table.concat(text, "\n"), true)

	local maxRange = max(#text - (DeathLog.mask:GetHeight() / (DeathLog.log:GetHeight() / #text)), 0)
	DeathLog.logScrollbar:SetRange(0, maxRange)
	DeathLog.logScrollbar:SetPosition(maxRange)

--	DeathLog.logScrollbarHorizontal:SetRange(0, max(1 - (DeathLog.mask:GetWidth() / DeathLog.log:GetWidth() * (DeathLog.log:GetWidth() - DeathLog.mask:GetWidth())), 0))
--	DeathLog.logScrollbarHorizontal:SetPosition(0)
end
function DeathLog:show(player)
	if not self.window then
		self:init()
	end

	self.player = player
	self.window:SetTitle(L["Death Log"] .. " - " .. player.detail.name)
	self.deathsList.selectionChange = nil

	while self.deathsList:getItemCount() > 0 do
		self.deathsList:removeItem(1)
	end
	for i, deathLogEntry in ipairs(player.deathLog) do
		self.deathsList:addItem(os.date("%X", deathLogEntry.timeOfDeath) .. "    " .. deathLogEntry.killedBy.name)
	end

	self.deathsList.selectionChange = self.selectionChange

	self.deathsList:setSelectedIndex(self.deathsList:getItemCount())

	self.window:SetVisible(true)
end
function DeathLog:hide()
	DeathLog.window:SetVisible(false)
end
function DeathLog:toggle(player)
	if not self.window or not self.window:GetVisible() or self.player ~= player then
		self:show(player)
	else
		self:hide()
	end
end





function RM.UI.NewSortmode(key, name)
	local sortmode = Sortmode:new(key, name)
	tinsert(Sortmodes, sortmode)
	return sortmode
end

local function GetClassColor(unit)
	local calling
	if not unit.calling and unit.owner then
		calling = unit.owner.calling -- pet has no calling -> get pet owner's calling
	else
		calling = unit.calling
	end

	return RiftMeter_classColors[calling or "none"]
end

local function BuildFormat(absolute, perSecond, percent)
	local args = {}
	local format = ""
	if RiftMeter_showAbsolute then
		tinsert(args, absolute)
		format = format .. "%s (%s"
	else
		format = format .. "%s"
	end

	tinsert(args, perSecond)

	if RiftMeter_showPercent then
		tinsert(args, percent)
		format = format .. (RiftMeter_showAbsolute and ", " or " ") .. (RiftMeter_showAbsolute and "" or "(") .. "%.1f%%)"
	elseif RiftMeter_showAbsolute and not RiftMeter_showPercent then
		format = format .. ")"
	end

	return format:format(unpack(args))
end

local function RegisterDefaultSortmodes()
	local modes = {
		combats = {},
		combat = {},
		abilities = {},
		ability = {},
		interactions = {},
		interactionAbilities = {},
		interactionAbility = {}
	}
	function modes.combats:getData(window, sortKey)
		local maximum = RM.GetMaxValueCombat(sortKey, window.settings.showEnemies)
		local rows = {}
		local limit = min(#RM.combats, window.settings.rows - 1)

		-- Total Bar
		tinsert(rows, {
			leftLabel = L["Total"],
			value = maximum,
			leftClick = function()
				window:setMode("combat", RM.overall)
			end
		})

		for i = 1, limit do
			local row = {}
			local index = i + window.scrollOffset
			local combat = RM.combats[index]
			local stat = combat:getPreparedPlayerData(sortKey, window.settings.showEnemies).total / max(combat.duration, 1)
			local hostile = combat:getHostile()

			row.leftLabel = FormatSeconds(combat.duration) .. " " .. hostile
			row.rightLabel = NumberFormat(stat)
			row.value = stat
			row.leftClick = function()
				window:setMode("combat", combat)
			end

			tinsert(rows, row)
		end

		window:setGlobalLabel(window.selectedCombat:getPreparedPlayerData(sortKey, window.settings.showEnemies).total / max(window.selectedCombat.duration, 1))

		return rows, #RM.combats + 1, maximum
	end
	function modes.combats:getSortModeSelectionData()
		return
	end

	function modes.combat:getData(window, sortKey)
		local data = window.selectedCombat:getPreparedPlayerData(sortKey, window.settings.showEnemies)

		local rows = {}
		local selfFound = false
		local limit = min(data.count, window.settings.rows)
		local duration = max(window.selectedCombat.duration, 1)
		for i = 1, limit do
			local row = {}
			local player = data.players[i + window.scrollOffset]

			if player.ref.detail.self then
				row.isSelf = true
				selfFound = true
			end

			if RiftMeter_alwaysShowPlayer and not selfFound and i == limit and not row.isSelf then
				for j = i + window.scrollOffset, data.count do
					if data.players[j].ref.detail.self then
						player = data.players[j]
						i = j - window.scrollOffset
						row.isSelf = true
						break
					end
				end
			end

			row.leftLabel = (RiftMeter_showRankNumber and i + window.scrollOffset .. ". " or "") .. player.name

			if RelativeTo > 0 then
				row.rightLabel = BuildFormat(NumberFormat(player.value), NumberFormat(player.value / duration), player.value / max(data.players[RelativeTo].value, 1) * 100)
			else
				row.rightLabel = BuildFormat(NumberFormat(player.value), NumberFormat(player.value / duration), player.value / max(data.total, 1) * 100)
			end

			row.color = GetClassColor(player.ref.detail)
			row.value = player.value
			if player.ref.interactions and player.ref.interactions[sortKey] then
				row.middleClick = function()
					window:setMode("interactions", player.ref)
				end
				row.leftClick = function()
					window:setMode("abilities", player.ref)
				end
			end
			if RiftMeter_showTooltips then
				row.tooltip = function()
					return player.ref:getTooltip(sortKey)
				end
			end

			tinsert(rows, row)
		end

		window:setGlobalLabel(data.total / duration)

		return rows, data.count, data.max
	end
	function modes.combat:getSortModeSelectionData(window, sortKey)
		if not window.selectedCombat then
			return
		end
		return window.selectedCombat:getPreparedPlayerData(sortKey, window.settings.showEnemies).total / max(window.selectedCombat.duration, 1)
	end
	function modes.combat:getReportText(window, sortKey)
		local data = window.selectedCombat:getPreparedPlayerData(sortKey, window.settings.showEnemies)
		local duration = max(window.selectedCombat.duration, 1)
		local text = {("%s %s: %d%s "):format(FormatSeconds(window.selectedCombat.duration), window.selectedCombat:getHostile():sub(0, 16), data.total / duration, L[window.settings.sort .. "PerSecond"])}
		for i = 1, data.count do
			local player = data.players[i]
			if not player.ref.detail.isPet then
				tinsert(text, ("| %s %d "):format(player.ref.detail.name:sub(0, 5), player.value / duration))
			end
		end

		return table.concat(text)
	end

	function modes.abilities:getData(window, sortKey)
		local data = window.selectedPlayer:getPreparedAbilityData(sortKey)
		local duration = max(window.selectedCombat.duration, 1)
		local rows = {}
		local limit = min(data.count, window.settings.rows)

		-- Total Bar
		if window.scrollOffset == 0 then
			tinsert(rows, {
				leftLabel = L["Total"],
				rightLabel = NumberFormat(data.total),
				value = data.max,
				leftClick = function()
					window:setMode("ability", window.selectedPlayer:createFakeAbility())
				end
			})
		end

		for i = 1, limit do
			local row = {}
			local index = window.scrollOffset > 0 and i + window.scrollOffset - 1 or i
			local ability = data.abilities[index]
			local value = ability:getTotal(sortKey)

			row.icon = ability.detail.icon
			row.leftLabel = ability.detail.name

			if RelativeTo > 1 then
				-- RelativeTo - 1 because of the total bar
				row.rightLabel = BuildFormat(NumberFormat(value), NumberFormat(value / duration), value / max(data.abilities[RelativeTo - 1].value, 1) * 100)
			else
				row.rightLabel = BuildFormat(NumberFormat(value), NumberFormat(value / duration), value / max(window.selectedPlayer:getStat(sortKey), 1) * 100)
			end

			row.color = RiftMeter_abilityColors[ability.detail.type]
			row.value = value
			row.leftClick = function()
				window:setMode("ability", ability)
			end
			if RiftMeter_showTooltips then
				row.iconTooltipId = ability.detail.id
			end

			tinsert(rows, row)
		end

		window:setGlobalLabel(data.total / duration)

		return rows, data.count + 1, data.max
	end
	function modes.abilities:getSortModeSelectionData(window, sortKey)
		return window.selectedPlayer and window.selectedPlayer:getPreparedAbilityData(sortKey).total / max(window.selectedCombat.duration, 1)
	end

	function modes.ability:getData(window, sortKey)
		local playerTotal = window.selectedPlayer:getPreparedAbilityData(sortKey).total
		local ability = window.selectedPlayer:getAbility(window.selectedAbility, sortKey)
		local total
		local data
		if ability then
			data = ability:getPreparedAbilityStatData()
			total = ability.total
		else -- if user clicked on total
			data = window.selectedAbility:getPreparedAbilityStatData(sortKey)
			total = window.selectedPlayer:getStat(sortKey)
		end

		local rows = {}
		local limit = min(#data, window.settings.rows)
		for i = 1, limit do
			local row = {}
			local stat = data[i + window.scrollOffset]

			row.leftLabel = stat.name
			row.rightLabel = NumberFormat(stat.value)
			row.color = RiftMeter_abilityColors[window.selectedAbility.detail.type]

			-- :/
			local maxHitRatio = playerTotal / data[2].value -- data[2] = max hit
			if i + window.scrollOffset == 1 then
				row.value = stat.value
				row.color = nil
			elseif i + window.scrollOffset > 1 and i + window.scrollOffset <= 5 then
				row.value = maxHitRatio * stat.value
			elseif i + window.scrollOffset == 6 then -- crit rate
				row.rightLabel = ("%.2f%%"):format(stat.value)
				row.value = playerTotal / 100 * stat.value
				row.color = {1, 1, 1}
			end

			rows[i] = row
		end

		window:setGlobalLabel(total / max(window.selectedCombat.duration, 1))

		return rows, #data, playerTotal
	end
	function modes.ability:getSortModeSelectionData(window, sortKey)
		return
	end

	function modes.interactions:getData(window, sortKey)
		local data = window.selectedPlayer:getInteractions(sortKey)
		local duration = max(window.selectedCombat.duration, 1)
		local rows = {}
		local limit = min(#data.interactions, window.settings.rows)
		for i = 1, limit do
			local row = {}
			local interaction = data.interactions[i + window.scrollOffset]

			row.leftLabel = (RiftMeter_showRankNumber and i + window.scrollOffset .. ". " or "") .. interaction.name
			row.rightLabel = BuildFormat(NumberFormat(interaction.value), NumberFormat(interaction.value / duration), interaction.value / data.total * 100)
			row.color = GetClassColor(interaction.detail)
			row.value = interaction.value
			row.leftClick = function()
				window:setMode("interactionAbilities", interaction.detail)
			end
			if RiftMeter_showTooltips then
				row.tooltip = function()
					return window.selectedPlayer:getInteractionTooltip(sortKey, interaction.detail)
				end
			end

			tinsert(rows, row)
		end

		window:setGlobalLabel(data.total / duration)

		return rows, #data.interactions, data.max
	end
	function modes.interactions:getSortModeSelectionData(window, sortKey)
		return window.selectedPlayer and window.selectedPlayer:getInteractions(sortKey).total / max(window.selectedCombat.duration, 1)
	end

	function modes.interactionAbilities:getData(window, sortKey)
		local data = window.selectedPlayer:getInteractionAbilityData(sortKey, window.selectedInteractionDetail)
		local duration = max(window.selectedCombat.duration, 1)
		local rows = {}
		local limit = min(data.count, window.settings.rows)
		for i = 1, limit do

			-- Total Bar
			if i == 1 and window.scrollOffset == 0 then
				tinsert(rows, {
					leftLabel = L["Total"],
					rightLabel = NumberFormat(data.total),
					value = data.max,
					leftClick = function()
						window:setMode("interactionAbility", window.selectedPlayer:createFakeInteractionAbility(window.selectedInteractionDetail))
					end
				})
			end

			local row = {}
			local index = window.scrollOffset > 0 and i + window.scrollOffset - 1 or i + window.scrollOffset
			local ability = data.abilities[index]

			row.icon = ability.ref.detail.icon
			row.leftLabel = ability.name

			if RelativeTo > 1 then
				-- RelativeTo - 1 because of the total bar
				row.rightLabel = BuildFormat(NumberFormat(ability.value), NumberFormat(ability.value / duration), ability.value / max(data.abilities[RelativeTo - 1].value, 1) * 100)
			else
				row.rightLabel = BuildFormat(NumberFormat(ability.value), NumberFormat(ability.value / duration), ability.value / max(window.selectedPlayer:getStat(sortKey), 1) * 100)
			end

			row.color = RiftMeter_abilityColors[ability.ref.detail.type]
			row.value = ability.value
			row.leftClick = function()
				window:setMode("interactionAbility", ability.ref)
			end
			if RiftMeter_showTooltips then
				row.iconTooltipId = ability.ref.detail.id
			end

			tinsert(rows, row)
		end

		window:setGlobalLabel(data.total / duration)

		return rows, data.count + 1, data.max
	end
	function modes.interactionAbilities:getSortModeSelectionData(window, sortKey)
		return -- todo
--		return window.selectedPlayer and window.selectedPlayer:getInteractionAbilityData().total / max(window.selectedCombat.duration, 1)
	end

	function modes.interactionAbility:getData(window, sortKey)
		local interactionTotal = window.selectedPlayer:getInteractionAbilityData(sortKey, window.selectedInteractionDetail).total
		local ability = window.selectedPlayer:getInteractionAbility(window.selectedAbility, sortKey, window.selectedInteractionDetail)
		local total
		local data
		if ability then
			data = ability:getPreparedAbilityStatData()
			total = ability.total
		else -- if user clicked on total
			data = window.selectedAbility:getPreparedAbilityStatData(sortKey)
			total = window.selectedPlayer:getInteractionStat(sortKey, window.selectedInteractionDetail)
		end


		local data = window.selectedAbility:getPreparedAbilityStatData(sortKey)

		local rows = {}
		local limit = min(#data, window.settings.rows)
		for i = 1, limit do
			local row = {}
			local stat = data[i + window.scrollOffset]

			row.leftLabel = stat.name
			row.rightLabel = NumberFormat(stat.value)
			row.color = RiftMeter_abilityColors[window.selectedAbility.detail.type]

			-- :/
			local maxHitRatio = interactionTotal / data[2].value -- data[2] = max hit
			if i + window.scrollOffset == 1 then
				row.value = stat.value
				row.color = nil
			elseif i + window.scrollOffset > 1 and i + window.scrollOffset <= 5 then
				row.value = maxHitRatio * stat.value
			elseif i + window.scrollOffset == 6 then -- crit rate
				row.rightLabel = ("%.2f%%"):format(stat.value)
				row.value = interactionTotal / 100 * stat.value
				row.color = {1, 1, 1}
			end

			rows[i] = row
		end

		window:setGlobalLabel(total / max(window.selectedCombat.duration, 1))

		return rows, #data, interactionTotal
	end
	function modes.interactionAbility:getSortModeSelectionData(window, sortKey)
		return -- todo
--		return window.selectedPlayer and window.selectedPlayer:getStat(sortKey) / max(window.selectedCombat.duration, 1)
	end



	local function getData(self, window, mode)
		if modes[mode] then
			return modes[mode]:getData(window, self.key)
		end
		return {}
	end

	local function getSortModeSelectionData(self, window, mode)
		if modes[mode] then
			return modes[mode]:getSortModeSelectionData(window, self.key)
		end
		return
	end

	local function getReportText(self, window, mode)
		if modes[mode] and modes[mode].getReportText then
			return modes[mode]:getReportText(window, self.key)
		end
		return ""
	end

	local function isCompatibleWith(self, mode)
		return true
	end

	local sortmodes = {
		"damage",
		"heal",
		"damageTaken",
		"damageAbsorbed",
		"healTaken",
		"overheal",
		"overkill"
	}

	for i, sortKey in ipairs(sortmodes) do
		local sortmode = RM.UI.NewSortmode(sortKey, L[sortKey])
		sortmode.getData = getData
		sortmode.getSortModeSelectionData = getSortModeSelectionData
		sortmode.getReportText = getReportText
		sortmode.isCompatibleWith = isCompatibleWith
	end


	-- deaths sort mode
	local function getTotalDeaths(window)
		if not window.selectedCombat then
			return
		end

		local totalDeaths = 0
		for _, player in pairs(window.selectedCombat.players) do
			if (window.settings.showEnemies and not player.detail.player)
				or (not window.settings.showEnemies and player.detail.player) then
				totalDeaths = totalDeaths + player.deaths
			end
		end
		return totalDeaths
	end

	local deaths = RM.UI.NewSortmode("deaths", L["deaths"])
	function deaths:getData(window, mode)
		if mode == "combat" then
			local data = window.selectedCombat:getDeathData(window.settings.showEnemies)

			local rows = {}
			local limit = min(data.count, window.settings.rows)
			local duration = max(window.selectedCombat.duration, 1)
			for i = 1, limit do
				local row = {}
				local player = data.players[i + window.scrollOffset]

				if player.ref.detail.self then
					row.isSelf = true
				end

				if RiftMeter_alwaysShowPlayer and i == limit and not row.isSelf then
					for j = i + window.scrollOffset, data.count do
						if data.players[j].ref.detail.self then
							player = data.players[j]
							i = j - window.scrollOffset
							row.isSelf = true
							break
						end
					end
				end

				row.leftLabel = (RiftMeter_showRankNumber and i + window.scrollOffset .. ". " or "") .. player.name
				row.rightLabel = NumberFormat(player.value)
				row.color = GetClassColor(player.ref.detail)
				row.value = player.value
				row.leftClick = function()
					DeathLog:toggle(player.ref)
				end

				tinsert(rows, row)
			end

			window:setGlobalLabel(data.total)

			return rows, data.count, data.max
		elseif mode == "combats" then
			local rows = {}
			local maxValue = 0
			local limit = min(#RM.combats, window.settings.rows - 1)

			-- Total Bar
			tinsert(rows, {
				leftLabel = L["Total"],
				value = 0,
				leftClick = function()
					window:setMode("combat", RM.overall)
				end
			})

			for i = 1, limit do
				local row = {}
				local combat = RM.combats[i + window.scrollOffset]
				local total = combat:getDeathData(window.settings.showEnemies).total
				local hostile = combat:getHostile()

				maxValue = max(maxValue, total)

				row.leftLabel = FormatSeconds(combat.duration) .. " " .. hostile
				row.rightLabel = NumberFormat(total)
				row.value = total
				row.leftClick = function()
					window:setMode("combat", RM.combats[i + window.scrollOffset])
				end

				rows[i] = row
			end

			rows[1].value = maxValue

			window:setGlobalLabel(window.selectedCombat:getDeathData(window.settings.showEnemies).total)

			return rows, #RM.combats, maxValue
		end
	end
	function deaths:getSortModeSelectionData(window, mode)
		if mode == "combat" then
			return getTotalDeaths(window)
		end
		return
	end
	function deaths:isCompatibleWith(mode)
		return mode == "combat" or mode == "combats"
	end
end

RegisterDefaultSortmodes()









local Report = {}
RM.Report = Report
Report.Channels = {
	{
		name = L["Say"],
		key = "s",
		color = {1, 1, 1}
	},
	{
		name = L["Whisper Target"],
		key = "whisperTarget",
		color = {1, .5, 1}
	},
	{
		name = L["Yell"],
		key = "y",
		color = {1, .247, .247}
	},
	{
		name = L["Party"],
		key = "p",
		color = {.667, .659, 1}
	},
	{
		name = L["Raid"],
		key = "raid",
		color = {1, .5, 0}
	},
	{
		name = L["Guild"],
		key = "g",
		color = {.255, 1, .255}
	},
	{
		name = L["Guild Officer"],
		key = "o",
		color = {.208, .74, .208}
	},
	{
		name = L["Guild Wall"],
		key = "guildWall",
		color = {.255, 1, .255}
	},
}
function Report:init()
	if self.window or Inspect.System.Secure() then
		return
	end

	self.context = UI.CreateContext("RM_ReportContext")
	self.window = RM.createWindow("RM_Report", self.context, self.hide)
	self.reportButton = UI.CreateFrame("RiftButton", "RM_Report_ReportButton", self.window)
	local reportToLabel = RM.createTextFrame("RM_Report_ReportToLabel", self.window)
	local channelList = ListBox:new("RM_Report_ChannelList", self.window, true)
	local channelLabel = RM.createTextFrame("RM_Report_ChannelLabel", self.window)
	local whisperLabel = RM.createTextFrame("RM_Report_WhisperLabel", self.window)
	local copyLabel = RM.createTextFrame("RM_Report_CopyLabel", self.window)
	self.channelTextfield = UI.CreateFrame("RiftTextfield", "RM_Report_ChannelTextfield", self.window)
	self.whisperTextfield = UI.CreateFrame("RiftTextfield", "RM_Report_WhisperTextfield", self.window)
	self.copyTextfield = UI.CreateFrame("RiftTextfield", "RM_Report_CopyTextfield", self.window)

	self.context:SetStrata("topmost")
	self.context:SetSecureMode("restricted")

	self.window:SetVisible(false)
	self.window:SetSecureMode("restricted")
	self.window:SetWidth(250)
	self.window:SetHeight(305)
	self.window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (UIParent:GetWidth() - self.window:GetWidth()) / 2, (UIParent:GetHeight() - self.window:GetHeight()) / 2)
	self.window:SetTitle(L["Report Data"])

	reportToLabel:SetPoint("TOPLEFT", self.window, "TOPLEFT", 10, 5)
	reportToLabel:SetFontColor(1, .82, 0)
	reportToLabel:SetFontSize(13)
	reportToLabel:SetText(L["Report To"])

	channelList:SetPoint("TOPLEFT", reportToLabel, "BOTTOMLEFT", 0, 3)
	channelList:SetPoint("RIGHT", self.window, "RIGHT", -10, nil)

	for i, channel in ipairs(self.Channels) do
		channelList:addItem(channel.name)
		channelList:setFontColor(i, unpack(channel.color))
	end

	channelLabel:SetPoint("TOPLEFT", channelList, "BOTTOMLEFT", 0, 5)
	channelLabel:SetFontColor(1, .82, 0)
	channelLabel:SetFontSize(13)
	channelLabel:SetText(L["Channel number:"])

	self.channelTextfield:SetPoint("TOP", channelLabel, "TOP")
	self.channelTextfield:SetPoint("LEFT", self.copyTextfield, "LEFT")
	self.channelTextfield:SetPoint("RIGHT", self.window, "RIGHT", -10, nil)
	self.channelTextfield:SetBackgroundColor(0, 0, 0, .5)

	whisperLabel:SetPoint("TOPLEFT", channelLabel, "BOTTOMLEFT", 0, 5)
	whisperLabel:SetFontColor(1, .82, 0)
	whisperLabel:SetFontSize(13)
	whisperLabel:SetText(L["Whisper:"])

	self.whisperTextfield:SetPoint("TOP", whisperLabel, "TOP")
	self.whisperTextfield:SetPoint("LEFT", self.copyTextfield, "LEFT")
	self.whisperTextfield:SetPoint("RIGHT", self.window, "RIGHT", -10, nil)
	self.whisperTextfield:SetBackgroundColor(0, 0, 0, .5)

	copyLabel:SetPoint("TOPLEFT", whisperLabel, "BOTTOMLEFT", 0, 5)
	copyLabel:SetFontColor(1, .82, 0)
	copyLabel:SetFontSize(13)
	copyLabel:SetText(L["Or copy (CTRL+C):"])

	self.copyTextfield:SetPoint("TOPLEFT", copyLabel, "TOPRIGHT", 5, 0)
	self.copyTextfield:SetPoint("RIGHT", self.window, "RIGHT", -10, nil)
	self.copyTextfield:SetBackgroundColor(0, 0, 0, .5)
	self.copyTextfield:EventAttach(Event.UI.Input.Mouse.Left.Click, function()
		local len = self.copyTextfield:GetText():len()
		if len > 0 then
			self.copyTextfield:SetSelection(0, len)
		end
	end, "Event.UI.Input.Mouse.Left.Click")


	self.reportButton:SetPoint("TOP", copyLabel, "BOTTOM", nil, 5)
	self.reportButton:SetPoint("CENTERX", self.window, "CENTERX")
	self.reportButton:SetSecureMode("restricted")
	self.reportButton:SetText(L["Report"])
	self.reportButton:EventAttach(Event.UI.Input.Mouse.Left.Down, function()

		if self.channelTextfield:GetText() ~= "" then
			self.reportButton:EventMacroSet(Event.UI.Input.Mouse.Left.Up, self.channelTextfield:GetText() .. " " .. self.text)
		elseif self.whisperTextfield:GetText() ~= "" then
			self.reportButton:EventMacroSet(Event.UI.Input.Mouse.Left.Up, "w " .. self.whisperTextfield:GetText() .. " " .. self.text)
		else
			local key = self.Channels[channelList:getSelectedIndex()].key
			if key == "whisperTarget" then
				local target = Inspect.Unit.Detail("player.target")
				if target then
					self.reportButton:EventMacroSet(Event.UI.Input.Mouse.Left.Up, "w " .. target.name .. " " .. self.text)
				else
					self.reportButton:EventMacroSet(Event.UI.Input.Mouse.Left.Up, "")
				end
			elseif key == "guildWall" then
				self.reportButton:EventMacroSet(Event.UI.Input.Mouse.Left.Up, "")
				Command.Guild.Wall.Post(self.text)
			else
				self.reportButton:EventMacroSet(Event.UI.Input.Mouse.Left.Up, key .. " " .. self.text)
			end
		end

	end, "Event.UI.Input.Mouse.Left.Down")
	self.reportButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function()
		self:hide()
	end, "Event.UI.Input.Mouse.Left.Click")

	Command.Event.Attach(Event.System.Secure.Enter, self.hide, "Secure mode")
end
function Report:show(text)
	if not text or Inspect.System.Secure() then
		return
	end
	if not self.window then
		self:init()
	end

	self.text = tostring(text)

	self.copyTextfield:SetText(self.text)
	self.copyTextfield:SetKeyFocus(true)
	self.copyTextfield:SetSelection(0, self.text:len())

	self.window:SetVisible(true)
end
function Report:hide()
	if Report.window then
		Report.channelTextfield:SetKeyFocus(false)
		Report.whisperTextfield:SetKeyFocus(false)
		Report.copyTextfield:SetKeyFocus(false)

		Report.window:SetVisible(false)
	end
end
function Report:toggle(text)
	if not self.window or not self.window:GetVisible() then
		self:show(text)
	else
		self:hide()
	end
end





local Window = {}
Window.__index = Window
function Window:new(settings)
	local self = {}

	self.settings = settings
	self.frames = {}
	self.lastData = {}
	self.history = {}
	self.maxValue = 0
	self.rowCount = 0
	self.scrollOffset = 0
	self.showNpcs = false
	self.isScrollbarPresent = false
	self.activeRowTooltip = nil
	self.selectedMode = Modes.combat
	self.selectedSortmode = nil
	self.selectedCombat = nil
	self.selectedPlayer = nil
	self.selectedPlayerDetail = nil
	self.selectedAbility = nil
	self.selectedAbilityDetail = nil

	setmetatable(self, Window)

	self:setSortMode(self.settings.sort)
	self:init()

	return self
end
function Window:init()
	local window = self
	local frames = self.frames

	frames.base = UI.CreateFrame("Frame", "RM_base", Context)
	frames.base:SetLayer(1)

	frames.header = UI.CreateFrame("Texture", "RM_header", frames.base)
	frames.header:SetPoint("TOPLEFT", frames.base, "TOPLEFT")
	frames.header:SetPoint("TOPRIGHT", frames.base, "TOPRIGHT")
	frames.header:SetHeight(self.settings.titlebarHeight)
	frames.header:SetLayer(0)
	frames.header:SetTexture(Info.identifier, self.settings.titlebarTexture)
	frames.header:SetAlpha(window.settings.titlebarColor[4])
	frames.header:EventAttach(Event.UI.Input.Mouse.Right.Click, function()
		window:setMode("modes")
	end, "Event.UI.Input.Mouse.Right.Click")
	frames.header:EventAttach(Event.UI.Input.Mouse.Middle.Click, function()
		window:setMode("combat", RM.combats[#RM.combats])
	end, "Event.UI.Input.Mouse.Middle.Click")
	frames.header:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		if not RiftMeter_lock then
			local mouse = Inspect.Mouse()
			frames.header.pressed = true
			frames.header.mouseStartX = mouse.x
			frames.header.mouseStartY = mouse.y
			frames.header.attrStartX = frames.base:GetLeft()
			frames.header.attrStartY = frames.base:GetTop()
		end
	end, "Event.UI.Input.Mouse.Left.Down")
	frames.header:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if frames.header.pressed then
			local mouse = Inspect.Mouse()
			window.settings.x = mouse.x - frames.header.mouseStartX + frames.header.attrStartX
			window.settings.y = mouse.y - frames.header.mouseStartY + frames.header.attrStartY
			frames.base:SetPoint("TOPLEFT", UIParent, "TOPLEFT", window.settings.x, window.settings.y)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	frames.header:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		frames.header.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	frames.header:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		frames.header.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")


	local function showTooltip()
		return RiftMeter_showTooltips
	end

	frames.headerLabel = RM.createTextFrame("RM_header_title", frames.base)
	frames.headerLabel:SetPoint("CENTERLEFT", frames.header, "CENTERLEFT", 7, 0)
	frames.headerLabel:SetFontSize(self.settings.titlebarFontSize)
	frames.headerLabel:SetFontColor(unpack(self.settings.titlebarFontColor))
	frames.headerLabel:SetLayer(1)
	frames.headerLabel:SetMouseMasking("limited")
	frames.headerLabel:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		window.frames.headerLabel:SetFontColor(0.8, 0.8, 0.8)
	end, "Event.UI.Input.Mouse.Cursor.In")
	frames.headerLabel:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		window.frames.headerLabel:SetFontColor(unpack(self.settings.titlebarFontColor))
	end, "Event.UI.Input.Mouse.Cursor.Out")
	Tooltip.createForFrame(frames.headerLabel, L["Right-Click to set\nsort mode\nMiddle-Click to jump\nto current combat"], frames.headerLabel, true, showTooltip)


	frames.buttons = {}

	frames.buttons.close = RM.createIconButton(
		"RM_buttons_close", frames.base, [[textures\icons-shadowless\cross.png]],
		"CENTERRIGHT", frames.header, "CENTERRIGHT", -4, 0, L["Close"], showTooltip, function()
			if not RiftMeter_lock then
				RM.UI.CloseWindow(window)
				Tooltip:hide()
			else
				RM.notify(L["Frames are locked."])
			end
	end)

	frames.buttons.report = RM.createIconButton(
		"RM_buttons_copy", frames.base, [[textures\icons-shadowless\megaphone.png]],
		"TOPRIGHT", frames.buttons.close, "TOPLEFT", -4, 0, L["Report"], showTooltip, function()
			window:report()
	end)

	frames.buttons.clearData = RM.createIconButton(
		"RM_buttons_clear", frames.base, [[textures\icons-shadowless\broom.png]],
		"TOPRIGHT", frames.buttons.report, "TOPLEFT", -4, 0, L["Clear data"], showTooltip, function()
			Dialog:show(L["Clear data?"], L["Yes"], L["No"], RM.Reset, function() end)
	end)

	frames.buttons.configuration = RM.createIconButton(
		"RM_buttons_config", frames.base, [[textures\icons-shadowless\gear.png]],
		"TOPRIGHT", frames.buttons.clearData, "TOPLEFT", -4, 0, L["Configuration"], showTooltip, function()
			RM.Config:toggle()
	end)

	frames.buttons.showEnemies = RM.createIconButton(
		"RM_buttons_showEnemies", frames.base, [[textures\icons-shadowless\animal-monkey.png]],
		"TOPRIGHT", frames.buttons.configuration, "TOPLEFT", -4, 0, L["Show enemies"], showTooltip, function()
			frames.buttons.showPlayers:SetVisible(true)
			frames.buttons.showEnemies:SetVisible(false)
			RM.triggerFrameEvent(frames.buttons.showPlayers, Event.UI.Input.Mouse.Cursor.In)
			window.scrollOffset = 0
			window.settings.showEnemies = true
			window:update()
	end)

	frames.buttons.showPlayers = RM.createIconButton(
		"RM_buttons_showPlayers", frames.base, [[textures\icons-shadowless\user.png]],
		"TOPLEFT", frames.buttons.showEnemies, "TOPLEFT", 0, 0, L["Show players"], showTooltip, function()
			frames.buttons.showPlayers:SetVisible(false)
			frames.buttons.showEnemies:SetVisible(true)
			RM.triggerFrameEvent(frames.buttons.showEnemies, Event.UI.Input.Mouse.Cursor.In)
			window.scrollOffset = 0
			window.settings.showEnemies = false
			window:update()
	end)

	frames.buttons.combatStart = RM.createIconButton(
		"RM_buttons_combatStart", frames.base, [[textures\icons-shadowless\control.png]],
		"TOPRIGHT", frames.buttons.showEnemies, "TOPLEFT", -4, 0, L["Force combat start"], showTooltip, function()
			RM.NewCombat(true)
	end)

	frames.buttons.combatEnd = RM.createIconButton(
		"RM_buttons_combatEnd", frames.base, [[textures\icons-shadowless\control-stop-square.png]],
		"TOPLEFT", frames.buttons.combatStart, "TOPLEFT", 0, 0, L["Force combat end"], showTooltip, function()
			RM.EndCombat(true)
	end)

	self:updateButtons()

	if window.settings.showEnemies then
		frames.buttons.showEnemies:SetVisible(false)
	else
		frames.buttons.showPlayers:SetVisible(false)
	end

	frames.buttons.combatEnd:SetVisible(false)


	frames.background = UI.CreateFrame("Frame", "RM_background", frames.base)
	frames.background:SetPoint("TOPLEFT", frames.header, "BOTTOMLEFT")
	frames.background:SetPoint("RIGHT", frames.header, "RIGHT")
	frames.background:SetLayer(1)
	frames.background:SetBackgroundColor(unpack(window.settings.backgroundColor))
	frames.background:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function()
		local val = max(window.scrollOffset - 1, 0)
		if val ~= window.scrollOffset then
			window.scrollOffset = val
			window:update()

			if window.isScrollbarPresent then
				frames.scrollbar:SetPosition(window.scrollOffset)
			end
		end
	end, "Event.UI.Input.Mouse.Wheel.Forward")
	frames.background:EventAttach(Event.UI.Input.Mouse.Wheel.Back, function()
		local val = min(window.scrollOffset + 1, window.rowCount - window.settings.rows)
		if val ~= window.scrollOffset and val > 0 then
			window.scrollOffset = val
			window:update()

			if window.isScrollbarPresent then
				frames.scrollbar:SetPosition(window.scrollOffset)
			end
		end
	end, "Event.UI.Input.Mouse.Wheel.Back")
	frames.background:EventAttach(Event.UI.Input.Mouse.Right.Click, function()
		window.selectedMode:rightClick(window)
	end, "Event.UI.Input.Mouse.Right.Click")
	frames.background:EventAttach(Event.UI.Input.Mouse.Mouse4.Click, function()
		window.selectedMode:mouse4Click(window)
	end, "Event.UI.Input.Mouse.Mouse4.Click")
	frames.background:EventAttach(Event.UI.Input.Mouse.Mouse5.Click, function()
		window.selectedMode:mouse5Click(window)
	end, "Event.UI.Input.Mouse.Mouse5.Click")

	--	function frames.background.Event:MouseOut()
	--		RelativeTo = 0
	--		Update()
	--	end

	frames.footer = UI.CreateFrame("Frame", "RM_footer", frames.base)
	frames.footer:SetPoint("TOPLEFT", frames.background, "BOTTOMLEFT")
	frames.footer:SetPoint("RIGHT", frames.background, "RIGHT")
	frames.footer:SetHeight(20)
	frames.footer:SetLayer(0)
	frames.footer:SetBackgroundColor(unpack(window.settings.footerBackgroundColor))

	frames.copyField = UI.CreateFrame("RiftTextfield", "RM_copyField", frames.base)
	frames.copyField:SetPoint("TOPLEFT", frames.header, "BOTTOMLEFT")
	frames.copyField:SetPoint("BOTTOMRIGHT", frames.footer, "TOPRIGHT")
	frames.copyField:SetLayer(10)
	frames.copyField:SetBackgroundColor(0, 0, 0, 0.75)
	frames.copyField:SetVisible(false)
	frames.copyField:EventAttach(Event.UI.Input.Key.Focus.Loss, function()
		frames.copyField:SetVisible(false)
	end, "Event.UI.Input.Key.Focus.Loss")

	frames.resizerLeft = UI.CreateFrame("Texture", "RM_footer_resizerLeft", frames.base)
	frames.resizerLeft:SetPoint("BOTTOMLEFT", frames.footer, "BOTTOMLEFT")
	frames.resizerLeft:SetWidth(16)
	frames.resizerLeft:SetHeight(16)
	frames.resizerLeft:SetLayer(1)
	frames.resizerLeft:SetTexture("RiftMeter", [[textures\resizerLeft.png]])
	frames.resizerLeft:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		if not RiftMeter_lock then
			local mouse = Inspect.Mouse()
			frames.resizerLeft.pressed = true
			frames.resizerLeft.mouseStartX = mouse.x
			frames.resizerLeft.mouseStartY = mouse.y
			frames.resizerLeft.attrStartX = frames.base:GetLeft()
			frames.resizerLeft.backupWidth = window.settings.width
		end
	end, "Event.UI.Input.Mouse.Left.Down")
	frames.resizerLeft:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if frames.resizerLeft.pressed then
			local mouse = Inspect.Mouse()
			local diffX = mouse.x - frames.resizerLeft.mouseStartX
			window.settings.width = max(diffX * -1 + frames.resizerLeft.backupWidth, 200)
			window.settings.x = min(diffX + frames.resizerLeft.attrStartX, frames.resizerLeft.attrStartX + frames.resizerLeft.backupWidth - 200)
			frames.base:SetPoint("TOPLEFT", UIParent, "TOPLEFT", window.settings.x, window.settings.y)

			local diffY = mouse.y - frames.resizerLeft.mouseStartY
			local steps = 0
			if diffY < 0 then
				steps = ceil(diffY / window.settings.rowHeight)
			else
				steps = floor(diffY / window.settings.rowHeight)
			end
			if steps > 0 or steps < 0 then
				local rows = window.settings.rows
				window:setRows(rows + steps)
				frames.resizerLeft.mouseStartY = frames.resizerLeft.mouseStartY + window.settings.rowHeight * (window.settings.rows - rows)
			end
			window:setWidth(window.settings.width)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	frames.resizerLeft:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		frames.resizerLeft.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	frames.resizerLeft:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		frames.resizerLeft.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")


	frames.resizerRight = UI.CreateFrame("Texture", "RM_footer_resizerRight", frames.base)
	frames.resizerRight:SetPoint("BOTTOMRIGHT", frames.footer, "BOTTOMRIGHT")
	frames.resizerRight:SetWidth(16)
	frames.resizerRight:SetHeight(16)
	frames.resizerRight:SetLayer(1)
	frames.resizerRight:SetTexture("RiftMeter", [[textures\resizerRight.png]])
	frames.resizerRight:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		if not RiftMeter_lock then
			local mouse = Inspect.Mouse()
			frames.resizerRight.pressed = true
			frames.resizerRight.mouseStartX = mouse.x
			frames.resizerRight.mouseStartY = mouse.y
			frames.resizerRight.backupWidth = window.settings.width
		end
	end, "Event.UI.Input.Mouse.Left.Down")
	frames.resizerRight:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if frames.resizerRight.pressed then
			local mouse = Inspect.Mouse()
			window.settings.width = max(mouse.x - frames.resizerRight.mouseStartX + frames.resizerRight.backupWidth, 200)

			local diffY = mouse.y - frames.resizerRight.mouseStartY
			local steps = 0
			if diffY < 0 then
				steps = ceil(diffY / window.settings.rowHeight)
			else
				steps = floor(diffY / window.settings.rowHeight)
			end
			if steps > 0 or steps < 0 then
				local rows = window.settings.rows
				window:setRows(rows + steps)
				frames.resizerRight.mouseStartY = frames.resizerRight.mouseStartY + window.settings.rowHeight * (window.settings.rows - rows)
			end
			window:setWidth(window.settings.width)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	frames.resizerRight:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		frames.resizerRight.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	frames.resizerRight:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		frames.resizerRight.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")


	frames.timerLabel = RM.createTextFrame("RM_footer_timerLabel", frames.base)
	frames.timerLabel:SetPoint("TOPLEFT", frames.resizerLeft, "TOPRIGHT", 10, -3)
	frames.timerLabel:SetLayer(1)

	frames.globalStatLabel = RM.createTextFrame("RM_footer_globalStatLabel", frames.base)
	frames.globalStatLabel:SetPoint("TOPLEFT", frames.timerLabel, "TOPRIGHT")
	frames.globalStatLabel:SetLayer(1)

	self.selectedMode:init(self)
	self:resize()
	self:showResizer(not RiftMeter_lock)

	if RiftMeter_showScrollbar then
		self:showScrollbar(true)
	end
end
function Window:clearRows(count) -- from count to rowCount will be hidden
	self.scrollOffset = 0
	self.activeRowTooltip = nil
	Tooltip:hide()
	Command.Tooltip(nil)

	local rows = self.frames.rows
	if not rows or count == #rows then return end
	if not count then
		count = 1
	end

	for i = count, #rows do
		local row = rows[i]
		row.background:SetWidth(0)
		row.icon:SetVisible(false)
		row.leftLabel:SetText("")
		row.rightLabel:SetText("")
		row.base:SetVisible(false)
	end
end
function Window:update(useOldData)
	if not useOldData then
		self.lastData, self.rowCount, self.maxValue = self.selectedMode:update(self)
	end

	self.lastData = self.lastData or {}
	self.rowCount = self.rowCount or 0
	self.maxValue = max(self.maxValue or 1, 1)

	if self.isScrollbarPresent then
		local scrollbar = self.frames.scrollbar
		local val = max(self.rowCount - self.settings.rows, 0)
		if val == 0 then
			scrollbar:SetEnabled(false)
		else
			scrollbar:SetEnabled(false)
			scrollbar:SetRange(0, val)
			scrollbar:SetPosition(self.scrollOffset) -- e.g. combats mode overrides scrollOffset
			scrollbar:SetEnabled(true)
		end
	end

	local maxRowWidth = self.frames.rows[1].base:GetWidth()

	for i = 1, self.settings.rows do
		local row = self.frames.rows[i]
		local data = self.lastData[i]
		if data then
			-- Default values
			if not data.value then
				data.value = 0
			end
			if not data.color then
				data.color = RiftMeter_totalbarColor
			end
			if not data.leftLabel then
				data.leftLabel = ""
			end
			if not data.rightLabel then
				data.rightLabel = ""
			end
			if data.icon and data.icon ~= "" then
				row.icon:SetTexture("Rift", data.icon)
				row.icon:SetVisible(true)
				row.leftLabel:SetPoint("LEFT", row.icon, "RIGHT", 2, nil)
			else
				row.icon:SetVisible(false)
				row.leftLabel:SetPoint("LEFT", row.base, "LEFT")
			end

			if self.settings.swapTextAndBarColor then
				row.background:SetBackgroundColor(unpack(self.settings.rowFontColor))
				row.leftLabel:SetFontColor(data.color[1], data.color[2], data.color[3])
				row.rightLabel:SetFontColor(data.color[1], data.color[2], data.color[3])
			else
				row.background:SetBackgroundColor(data.color[1], data.color[2], data.color[3])
				row.leftLabel:SetFontColor(unpack(self.settings.rowFontColor))
				row.rightLabel:SetFontColor(unpack(self.settings.rowFontColor))
			end
			if RiftMeter_customHighlightFontColor and data.isSelf then
				row.leftLabel:SetFontColor(unpack(RiftMeter_customHighlightFontColorValue))
				row.rightLabel:SetFontColor(unpack(RiftMeter_customHighlightFontColorValue))
			end
			if RiftMeter_customHighlightBackgroundColor and data.isSelf then
				row.background:SetBackgroundColor(unpack(RiftMeter_customHighlightBackgroundColorValue))
			end


			-- Events were called in Window:SetRows() by the default click handlers due some recursion issues
			if not data.rightClick then
				-- if no custom callback defined, pass through right clicks
				data.rightClick = function() RM.triggerFrameEvent(self.frames.background, Event.UI.Input.Mouse.Right.Click) end
			end
			row.base.leftClick = data.leftClick
			row.base.middleClick = data.middleClick
			row.base.rightClick = data.rightClick


			-- Assign
			row.icon.tooltipId = data.iconTooltipId
			row.leftLabel:ClearWidth()
			row.leftLabel:SetText(tostring(data.leftLabel))
			row.rightLabel:SetText(tostring(data.rightLabel))
			row.background:SetWidth(max(min(maxRowWidth * data.value / self.maxValue, maxRowWidth), 0))
			row.base.tooltip = data.tooltip
			row.base:SetVisible(true)
		else
			row.base:SetVisible(false)
		end
	end

	if self.activeRowTooltip then
		Tooltip:show(self.activeRowTooltip())
	end
end
function Window:report()
	local text = self.selectedMode:getReportText(self)

	if not text then return end

	if Inspect.System.Secure() then
		local field = self.frames.copyField
		field:SetText(text)
		field:SetKeyFocus(true)
		field:SetSelection(0, text:len())
		field:SetVisible(true)

		RM.notify(L["Report window does only work when out of fight."])
	else
		Report:toggle(text)
	end
end
function Window:setRows(count)
	local forCount = count
	local rowCount = 0
	if self.frames.rows then
		rowCount = #self.frames.rows
	end

	if rowCount == count then
		return
	end

	count = max(count, 1)
	self.settings.rows = count

	if self.frames.rows then
		local diff = count - rowCount
		if diff < 0 then -- remove row(s)
			self:clearRows(count)
			for i = count + 1, rowCount do
				tremove(self.frames.rows)
			end
		elseif diff > 0 then -- add row(s)
			self.scrollOffset = max(min(self.scrollOffset, self.rowCount - self.settings.rows), 0)
		elseif diff == 0 then
			forCount = 0
		end
	else
		self.frames.rows = {}
	end

	for i = rowCount + 1, forCount do
		local row = {}
		self.frames.rows[i] = row

		row.base = UI.CreateFrame("Texture", "RM_rows_" .. i .. "_base", self.frames.base)
		row.background = UI.CreateFrame("Texture", "RM_rows_" .. i .. "_background", row.base)
		row.icon = UI.CreateFrame("Texture", "RM_rows_" .. i .. "_icon", row.base)
		row.rightLabel = RM.createTextFrame("RM_rows_" .. i .. "_rightLabel", row.base)
		row.leftLabel = RM.createTextFrame("RM_rows_" .. i .. "_leftLabel", row.base)


		if i == 1 then
			row.base:SetPoint("TOPLEFT", self.frames.header, "BOTTOMLEFT", 1, self.settings.rowPadding)
			row.base:SetPoint("RIGHT", self.frames.background, "RIGHT", -1, nil)
		else
			row.base:SetPoint("TOPLEFT", self.frames.rows[i - 1].base, "BOTTOMLEFT", 0, self.settings.rowPadding)
			row.base:SetPoint("RIGHT", self.frames.rows[i - 1].base, "RIGHT")
		end
		row.base:SetHeight(self.settings.rowHeight)
		row.base:SetMouseMasking("limited")
		row.base:SetLayer(2)
		row.base:SetVisible(false)


		-- Click Handlers
		row.base:EventAttach(Event.UI.Input.Mouse.Left.Click, function()
			if row.base.leftClick then
				row.base.leftClick()
			end
		end, "Default Left Click")
		row.base:EventAttach(Event.UI.Input.Mouse.Middle.Click, function()
			if row.base.middleClick then
				row.base.middleClick()
			end
		end, "Default Middle Click")
		row.base:EventAttach(Event.UI.Input.Mouse.Right.Click, function()
			if row.base.rightClick then
				row.base.rightClick()
			end
		end, "Default Right Click")


		-- Hover
		row.base:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
			row.base.asyncHelper = i

			row.background:SetAlpha(0.6)

			if row.base.tooltip then
				-- event trace: frame1:MouseIn(), frame2:MouseIn(), frame1:MouseOut() WTF?
				Tooltip:show(row.base.tooltip())
				self.activeRowTooltip = row.base.tooltip
			end

			--			RelativeTo = i + RM.selectedMode.scrollOffset
			--			self.relativeTo = RelativeTo
			--			Update()
		end, "Event.UI.Input.Mouse.Cursor.In")
		row.base:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
			row.background:SetAlpha(0.45)

			if row.base.asyncHelper == i then
				row.base.asyncHelper = 0
				self.activeRowTooltip = nil
				Tooltip:hide()
			end


			-- async events
			--			if RelativeTo == self.relativeTo then
			--				RelativeTo = 0
			--				Update()
			--			end
		end, "Event.UI.Input.Mouse.Cursor.Out")


		-- Icon Hover
		row.icon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
			row.icon.asyncHelper = i
			if row.icon.tooltipId then
				Command.Tooltip(row.icon.tooltipId)
			end
		end, "Event.UI.Input.Mouse.Cursor.In")
		row.icon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
			if row.icon.asyncHelper == i then
				row.icon.asyncHelper = 0
				Command.Tooltip(nil)
			end
		end, "Event.UI.Input.Mouse.Cursor.Out")


		row.background:SetPoint("TOPLEFT", row.base, "TOPLEFT")
		row.background:SetPoint("BOTTOM", row.base, "BOTTOM")
		row.background:SetWidth(0)
		row.background:SetAlpha(0.45)
		row.background:SetTexture(Info.identifier, self.settings.rowTexture)

		row.icon:SetPoint("TOPLEFT", row.base, "TOPLEFT", 1, 1)
		row.icon:SetPoint("BOTTOM", row.base, "BOTTOM", nil, -1)
		row.icon:SetWidth(row.icon:GetHeight())
		row.icon:SetLayer(3)
		row.icon:SetMouseMasking("limited")

		row.rightLabel:SetPoint("CENTERRIGHT", row.base, "CENTERRIGHT")
--		row.rightLabel:SetFont(Info.identifier, self.settings.rowFont)
		row.rightLabel:SetFontSize(self.settings.rowFontSize)
		row.rightLabel:SetLayer(3)

		row.leftLabel:SetPoint("CENTERY", row.base, "CENTERY")
		row.leftLabel:SetPoint("LEFT", row.base, "LEFT") -- need two separate points to shift leftLabel when an icon is set
		row.leftLabel:SetPoint("RIGHT", row.rightLabel, "LEFT", -2, nil)
--		row.leftLabel:SetFont(Info.identifier, self.settings.rowFont)
		row.leftLabel:SetFontSize(self.settings.rowFontSize)
		row.leftLabel:SetLayer(3)
	end
	self.frames.background:SetPoint("BOTTOM", self.frames.rows[count].base, "BOTTOM", nil, self.settings.rowPadding)

	self:update()
end
function Window:timerUpdate(duration)
	self.frames.timerLabel:SetText(FormatSeconds(duration))
end
function Window:setSortMode(sortName)
	for i, sortMode in ipairs(Sortmodes) do
		if sortMode.key == sortName then
			self.settings.sort = sortName
			self.sortMode = Sortmodes[i]
			return
		end
	end
end
function Window:setMode(mode, ...)
	--	RelativeTo = 0

	local newMode = {}
	if type(mode) == "string" then
		newMode = Modes[mode]
	else
		newMode = mode
	end

	if newMode ~= self.selectedMode then -- prevent endless loop
		tinsert(self.history, self.selectedMode)
		self.selectedMode = newMode
	end

	self:clearRows()
	self.selectedMode:init(self, ...)
	self:update()

--	if self.isScrollbarPresent and self.frames.scrollbar:GetEnabled() then
--		print(self.scrollOffset)
--		self.frames.scrollbar:SetPosition(self.scrollOffset)
--	end
end
function Window:getLastMode()
	-- sortmode selection is skipped (Modes.modes)
	-- two same modes can't be behind one another

	local index = #self.history
	if self.history[index] == Modes.modes then
		index = index - 1
	end
	if self.history[index] == self.selectedMode then
		index = index - 1
	end

	return self.history[max(index, 1)]
end
function Window:setTitle(title)
	title = tostring(title)
	self.frames.headerLabel:SetText(title)
	WindowTitleChangeTrigger(self, title)
end
function Window:getTitle()
	return self.frames.headerLabel:GetText()
end
function Window:setBackgroundColor(...)
	self.frames.background:SetBackgroundColor(...)
end
function Window:setFooterBackgroundColor(...)
	self.frames.footer:SetBackgroundColor(...)
end
--function Window:showTitlebar(state)
--	self.frames.header:SetVisible(state)
--end
function Window:setTitlebarAlpha(alpha)
	self.frames.header:SetAlpha(alpha)
end
function Window:setTitlebarTexture(texture)
	self.frames.header:SetTexture(Info.identifier, self.settings.titlebarTexture)
end
function Window:setTitlebarHeight(height)
	self.frames.header:SetHeight(height)
end
function Window:setTitlebarFontSize(size)
	self.frames.headerLabel:SetFontSize(size)
end
function Window:setTitlebarFontColor(r, g, b)
	self.frames.headerLabel:SetFontColor(r, g, b)
end
function Window:updateButtons()
	local buttons = {"close", "report", "clearData", "configuration", "showEnemies", "combatStart"}

	-- normalize
	self.frames.buttons[buttons[1]]:SetVisible(false)
	self.frames.buttons[buttons[1]]:SetPoint("CENTERRIGHT", self.frames.header, "CENTERRIGHT", -4, 0)
	for i = 2, #buttons do
		self.frames.buttons[buttons[i]]:SetVisible(false)
		self.frames.buttons[buttons[i]]:SetPoint("TOPRIGHT", self.frames.buttons[buttons[i - 1]], "TOPLEFT", -4, 0)
	end
	self.frames.buttons.showPlayers:SetVisible(false)
	self.frames.buttons.combatEnd:SetVisible(false)


	-- now reposition
	local visibleButtons = {}
	for i, key in ipairs(buttons) do
		if not self.settings.hideButtons[key] then
			tinsert(visibleButtons, key)
		end
	end

	if #visibleButtons > 0 then
		self.frames.buttons[visibleButtons[1]]:SetVisible(true)
		self.frames.buttons[visibleButtons[1]]:SetPoint("CENTERRIGHT", self.frames.header, "CENTERRIGHT", -4, 0)
		for i = 2, #visibleButtons do
			self.frames.buttons[visibleButtons[i]]:SetPoint("TOPRIGHT", self.frames.buttons[visibleButtons[i - 1]], "TOPLEFT", -4, 0)

			if visibleButtons[i] == "combatStart" then
				self:showCombatStartButton(true) -- todo
			elseif visibleButtons[i] == "showEnemies" then
				if self.settings.showEnemies then
					self.frames.buttons.showEnemies:SetVisible(false)
					self.frames.buttons.showPlayers:SetVisible(true)
				else
					self.frames.buttons.showEnemies:SetVisible(true)
					self.frames.buttons.showPlayers:SetVisible(false)
				end
			else
				self.frames.buttons[visibleButtons[i]]:SetVisible(true)
			end
		end
	end
end
function Window:showCombatStartButton(state)
	if not self.settings.hideButtons.combatStart then
		self.frames.buttons.combatStart:SetVisible(state)
		self.frames.buttons.combatEnd:SetVisible(not state)
	end
end
function Window:setRowHeight(height)
	for i, row in ipairs(self.frames.rows) do
		row.base:SetHeight(height)
		row.icon:SetWidth(row.icon:GetHeight())
	end
end
function Window:setRowPadding(padding)
	for i = 1, #self.frames.rows do
		if i == 1 then
			self.frames.rows[i].base:SetPoint("TOPLEFT", self.frames.header, "BOTTOMLEFT", 1, padding)
		else
			self.frames.rows[i].base:SetPoint("TOPLEFT", self.frames.rows[i - 1].base, "BOTTOMLEFT", 0, padding)
		end
	end
end
function Window:setRowFontSize(size)
	for i, row in ipairs(self.frames.rows) do
		row.leftLabel:SetFontSize(size)
		row.rightLabel:SetFontSize(size)
	end
end
function Window:setGlobalLabel(text)
	self.frames.globalStatLabel:SetText(NumberFormat(text))
end
function Window:setWidth(width)
	self.frames.base:SetWidth(width)
	self:update(true)
end
function Window:resize()
	self.frames.base:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self.settings.x, self.settings.y)
	self.frames.base:SetWidth(self.settings.width)

	self:setRows(self.settings.rows)
end
function Window:showResizer(state)
	self.frames.resizerLeft:SetVisible(state)
	self.frames.resizerRight:SetVisible(state)
end
function Window:showScrollbar(state)
	local window = self
	if not self.frames.scrollbar then
		if state then
			self.frames.scrollbar = UI.CreateFrame("RiftScrollbar", "RM_scrollbar", self.frames.base)
			self.frames.scrollbar:SetPoint("TOPRIGHT", self.frames.header, "BOTTOMRIGHT")
			self.frames.scrollbar:SetPoint("BOTTOM", self.frames.footer, "TOP")
			self.frames.scrollbar:SetOrientation("vertical")
			self.frames.scrollbar:SetLayer(2)
			self.frames.scrollbar:SetThickness(4)
			self.frames.scrollbar:SetEnabled(false)

			self.frames.scrollbar:EventAttach(Event.UI.Scrollbar.Change, function ()
				if not self.frames.scrollbar:GetEnabled() then
					return
				end

				local val = VU.round(window.frames.scrollbar:GetPosition())
				if val ~= window.scrollOffset then
					window.scrollOffset = val
					window:update()
				end
			end, "Event.UI.Scrollbar.Change")
		else
			return
		end
	end

	if state then
		local val = self.rowCount - self.settings.rows
		if val > 0 then
			self.frames.scrollbar:SetVisible(true)
			self.frames.scrollbar:SetEnabled(true)
			self.frames.scrollbar:SetRange(0, val)
			self.frames.scrollbar:SetPosition(self.scrollOffset)
		end
	else
		self.frames.scrollbar:SetVisible(false)
	end

	if RiftMeter_showScrollbar then
		self.frames.rows[1].base:SetPoint("RIGHT", self.frames.scrollbar, "LEFT")
	else
		self.frames.rows[1].base:SetPoint("RIGHT", self.frames.background, "RIGHT", -1, nil)
	end

	self.isScrollbarPresent = state

	self:update(true)
end
function Window:updateLayout()
	self:setBackgroundColor(unpack(self.settings.backgroundColor))
	self:setFooterBackgroundColor(unpack(self.settings.footerBackgroundColor))

	self:setTitlebarAlpha(self.settings.titlebarColor[4])
	self:setTitlebarTexture(self.settings.titlebarTexture)
	self:setTitlebarHeight(self.settings.titlebarHeight)
	self:setTitlebarFontSize(self.settings.titlebarFontSize)
	self:setTitlebarFontColor(unpack(self.settings.titlebarFontColor))

	self:updateButtons()

	self:setRowHeight(self.settings.rowHeight)
	self:setRowPadding(self.settings.rowPadding)
	self:setRowFontSize(self.settings.rowFontSize)

	self:resize()
	self:showResizer(not RiftMeter_lock)
	self:showScrollbar(RiftMeter_showScrollbar)
end











Modes.modes = Mode:new("modes")
function Modes.modes:init(window)
	window:setTitle("RiftMeter: " .. L["Sort Modes"])
end
function Modes.modes:update(window)
	local rows = {}
	local lastMode = window:getLastMode()
	local limit = min(#Sortmodes, window.settings.rows)
	for i = 1, limit do
		local sortMode = Sortmodes[i + window.scrollOffset]

		if sortMode:isCompatibleWith(lastMode.name) then
			local row = {}
			local val = sortMode:getSortModeSelectionData(window, lastMode.name)
			if val then
				val = NumberFormat(val)
			end

			row.leftLabel = sortMode.name
			row.rightLabel = val
			row.value = window.settings.width - 2
			row.leftClick = function()
				local oldSortmode = window.settings.sort
				window:setSortMode(sortMode.key)

				if lastMode:onSortmodeChange(window, oldSortmode) then
					window:setMode(lastMode)
				end
			end

			rows[i] = row
		end
	end

	local total = 0
	for i, sortMode in ipairs(Sortmodes) do
		if sortMode:isCompatibleWith(lastMode.name) then
			total = total + 1
		end
	end


	return rows, total, window.settings.width - 2
end


Modes.combat = Mode:new("combat")
function Modes.combat:init(window, combat)
    if combat then
		window.selectedCombat = combat
    end

    if not window.selectedCombat then
		if #RM.combats > 0 then
			window.selectedCombat = RM.combats[#RM.combats]
		end
    end

    if window.selectedCombat then
		window:timerUpdate(window.selectedCombat.duration)
	end
	window:setTitle(window.sortMode.name)
end
function Modes.combat:update(window)
	if not window.selectedCombat then return end -- Update() is called on init

	return window.sortMode:getData(window, self.name)
end
function Modes.combat:rightClick(window)
	if #RM.combats > 0 and window.sortMode:isCompatibleWith("combats") then
		window:setMode("combats")
	end
end
function Modes.combat:getReportText(window)
	if not window.selectedCombat then return end

	return window.sortMode:getReportText(window, self.name)
end
function Modes.combat:mouse4Click(window)
	for i, combat in ipairs(RM.combats) do
		if combat == window.selectedCombat and i > 1 then
			window:setMode("combat", RM.combats[i - 1])
			return
		end
	end
end
function Modes.combat:mouse5Click(window)
	for i, combat in ipairs(RM.combats) do
		if combat == window.selectedCombat and i < #RM.combats then
			window:setMode("combat", RM.combats[i + 1])
			return
		end
	end
end


Modes.interactions = Mode:new("interactions")
function Modes.interactions:init(window, player)
	if player then
		window.selectedPlayer = player
	end
	if window.selectedPlayer then
		window:setTitle(L["%s: Interactions: %s"]:format(window.selectedPlayer.detail.name, window.sortMode.name))
	end
end
function Modes.interactions:update(window)
	if not window.selectedPlayer then
		if window.selectedPlayerDetail then
			self:findOwner(window)
		end
		if not window.selectedPlayer then
			return
		end
	end

	return window.sortMode:getData(window, self.name)
end
function Modes.interactions:rightClick(window)
	window:setMode("combat")
end
function Modes.interactions:findOwner(window)
	local player = window.selectedCombat.players[window.selectedPlayerDetail]
	if player then
		window.selectedPlayer = player
		window:setTitle(L["%s's Interactions: %s"]:format(player.detail.name, window.sortMode.name))
	end
end


Modes.interactionAbilities = Mode:new("interactionAbilities")
function Modes.interactionAbilities:init(window, interactionDetail)
	if window.selectedPlayer then
		if interactionDetail then
			window.selectedInteractionDetail = interactionDetail
		end
		window:setTitle(("%s: %s: %s"):format(window.selectedInteractionDetail.name:sub(0, 6), window.selectedPlayer.detail.name:sub(0, 6), window.sortMode.name))
	end
end
function Modes.interactionAbilities:update(window)
	if not window.selectedPlayer then
		if window.selectedPlayerDetail then
			--self:findOwner(window)
		end
		if not window.selectedPlayer then
			window:setMode("combat")
			return
		end
	end

	return window.sortMode:getData(window, self.name)
end
function Modes.interactionAbilities:rightClick(window)
	window:setMode("interactions", window.selectedPlayer)
end
--function Modes.interactionAbilities:findOwner(window)
--	local player = window.selectedCombat.players[window.selectedPlayerDetail]
--	if player then
--		window.selectedPlayer = player
--		window:setTitle(("%s: %s"):format(player.detail.name, window.sortMode.name))
--	end
--end
function Modes.interactionAbilities:onSortmodeChange(window, oldSortmode)
	if window.settings.sort ~= oldSortmode then
		window:setMode("interactions", window.selectedPlayer)
		return false
	end
	return true
end



Modes.interactionAbility = Mode:new("interactionAbility")
function Modes.interactionAbility:init(window, ability)
	if ability then
		window.selectedAbility = ability
	end
	if window.selectedAbility then
		window:setTitle(("%s: %s"):format(window.selectedInteractionDetail.name, window.selectedAbility.detail.name))
	end
end
function Modes.interactionAbility:update(window)
	if not window.selectedAbility or not window.selectedPlayer then
		self:findOwner(window)
		if not window.selectedAbility then
			return
		end
	end

	return window.sortMode:getData(window, self.name)
end
function Modes.interactionAbility:rightClick(window)
	window:setMode("interactionAbilities")
end
function Modes.interactionAbility:findOwner(window)
	if not window.selectedPlayer then
		Modes.abilities:findOwner(window)
	end
	if window.selectedPlayer then
		window:setMode("abilities", window.selectedPlayer)
	end
end
function Modes.interactionAbility:onSortmodeChange(window, oldSortmode)
	if window.settings.sort ~= oldSortmode then
		window:setMode("interactions", window.selectedPlayer)
		return false
	end
	return true
end



Modes.combats = Mode:new("combats")
function Modes.combats:init(window)
	window.rowCount = #RM.combats
	window.scrollOffset = max(window.rowCount - window.settings.rows + 1, 0)
	window:setTitle(L["Combats"] .. ": " .. window.sortMode.name)
end
function Modes.combats:update(window)
	if not window.selectedCombat then return end

	return window.sortMode:getData(window, self.name)
end


Modes.abilities = Mode:new("abilities")
function Modes.abilities:init(window, player)
	if player then
		window.selectedPlayer = player
	end
	if window.selectedPlayer then
		window:setTitle(("%s: %s"):format(window.selectedPlayer.detail.name, window.sortMode.name))
	end
end
function Modes.abilities:update(window)
	if not window.selectedPlayer then
		if window.selectedPlayerDetail then
			self:findOwner(window)
		end
		if not window.selectedPlayer then
			return
		end
	end

	return window.sortMode:getData(window, self.name)
end
function Modes.abilities:rightClick(window)
	window:setMode("combat")
end
function Modes.abilities:findOwner(window)
	local player = window.selectedCombat.players[window.selectedPlayerDetail]
	if player then
		window.selectedPlayer = player
		window:setTitle(("%s: %s"):format(player.detail.name, window.sortMode.name))
	end
end


Modes.ability = Mode:new("ability")
function Modes.ability:init(window, ability)
	if ability then
		window.selectedAbility = ability
	end
	if window.selectedAbility then
		window:setTitle(("%s: %s"):format(window.selectedPlayer.detail.name, window.selectedAbility.detail.name))
	end
end
function Modes.ability:update(window)
	if not window.selectedAbility or not window.selectedPlayer then
		self:findOwner(window)
		if not window.selectedAbility then
			return
		end
	end

	return window.sortMode:getData(window, self.name)
end
function Modes.ability:rightClick(window)
	window:setMode("abilities", window.selectedPlayer)
end
function Modes.ability:findOwner(window)
	if not window.selectedPlayer then
		Modes.abilities:findOwner(window)
	end
	if window.selectedPlayer then
		window:setMode("abilities")
	end
end
function Modes.ability:onSortmodeChange(window, oldSortmode)
	if window.settings.sort ~= oldSortmode then
		window:setMode("abilities", window.selectedPlayer)
		return false
	end
	return true
end







function RM.UI.Update(useOldData)
	for i, window in ipairs(Windows) do
		window:update(useOldData)
	end
end

function RM.UI.TimerUpdate(duration)
	local combat = RM.combats[#RM.combats]
	for i, window in ipairs(Windows) do
		if window.selectedCombat == combat then
			window:timerUpdate(duration)
		end
	end
end

function RM.UI.NewCombat()
	for i, window in ipairs(Windows) do
		-- update to current combat if last combat was selected
		if window.selectedCombat == RM.combats[#RM.combats - 1] then
			window.selectedCombat = RM.combats[#RM.combats]

			if window.selectedPlayer then
				window.selectedPlayerDetail = window.selectedPlayer.detail
				window.selectedPlayer = nil
			end
			if window.selectedAbility then
				window.selectedAbilityDetail = window.selectedAbility.detail
				window.selectedAbility = nil
			end

			window:clearRows()
			window.selectedMode:init(window)
		end

		window:showCombatStartButton(false)
	end
end
function RM.UI.EndCombat()
	for i, window in ipairs(Windows) do
		window:showCombatStartButton(true)

		if window.selectedCombat == RM.combats[#RM.combats] then
			window:timerUpdate(window.selectedCombat.duration)
		end
	end
end


function RM.UI.Default()
	-- update window first that RM.Config.windowList triggers on CloseWindow() and refreshes the config window
	local window = Windows[1]
	window.settings = RiftMeter_windows[1]
	window:updateLayout()
	window:setMode("combat")
	window:setSortMode("damage")

	while #Windows > 1 do
		RM.UI.CloseWindow(Windows[#Windows])
	end
end

function RM.UI.Reset()
	for i, window in ipairs(Windows) do
		window.selectedCombat = nil
		window:setMode("combat")
		window.frames.timerLabel:SetText("")
		window.frames.globalStatLabel:SetText("")
		window:showCombatStartButton(true)
		window:clearRows()
	end
end

function RM.UI.Init()
	for i = 1, #RiftMeter_windows do
		RiftMeter_windows[i] = VU.extend(VU.deepcopy(RM.windowSettings), RiftMeter_windows[i])
		tinsert(Windows, Window:new(RiftMeter_windows[i]))
	end
end

function RM.UI.NewWindow(settings)
	if #Windows >= 8 then
		return
	end

	if not settings then
		settings = VU.deepcopy(RM.windowSettings)
	end

	tinsert(RiftMeter_windows, settings)

	local window = Window:new(settings)
	tinsert(Windows, window)

	WindowAddTrigger(window)
end

function RM.UI.CloseWindow(window)
	if #Windows == 1 then
		RM.notify((L["Type /rm show to reactivate %s."]):format(Info.toc.Name))
		RM.Off()
		return
	end

	for i = 1, #Windows do
		if window == Windows[i] then
			WindowRemoveTrigger(window)

			window.frames.base:SetVisible(false)
			tremove(Windows, i)
			tremove(RiftMeter_windows, i)
			return
		end
	end
end

function RM.UI.Visible(visible)
	for i, window in ipairs(Windows) do
		window.frames.base:SetVisible(visible)
	end
end
function RM.UI.ShowResizer(state)
	for i, window in ipairs(Windows) do
		window:showResizer(state)
	end
end
function RM.UI.ShowScrollbar(state)
	for i, window in ipairs(Windows) do
		window:showScrollbar(state)
	end
end
