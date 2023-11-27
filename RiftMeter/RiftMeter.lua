-------------------------------------------------------------------------------
----                               Rift Meter                              ----
----                                                                       ----
---- http://www.curse.com/addons/rift/rift-meter                           ----
---- Author: Vince@Brutwacht                                               ----
-------------------------------------------------------------------------------

local Info, RM = ...
RiftMeter = RM

local L = RM.l

local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local abs = math.abs
local max = math.max
local min = math.min
local floor = math.floor
local setmetatable = setmetatable

local Event = Event
local InspectUnitDetail = Inspect.Unit.Detail
local InspectUnitLookup = Inspect.Unit.Lookup
local InspectAbilityNewDetail = Inspect.Ability.New.Detail
local InspectTimeFrame = Inspect.Time.Frame
local CommandEventAttach = Command.Event.Attach
local CommandEventDetach = Command.Event.Detach

local VU = Library.VinceUtils
local VURaidManagerUnitExists = VU.RaidManager.UnitExists

local RegisterEventIfNotExists = RM.registerEventIfNotExists
local NumberFormat = RM.numberFormat
local RMUITimerUpdate = RM.UI.TimerUpdate
local RMUIUpdate = RM.UI.Update


local Events = {}
local Units = {}
local Abilities = {}

local SlashCommand = "rm"
local Enabled = false
local StopTracking = false -- used by EndCombatAfterKill
local PlayerID = ""
local LastDamageAction = 0
local LastUpdate = 0
local LastTimerUpdate = 0
local InCombat = false
local NeedsUpdate = false
local Permanent = false -- manual combat start
local UnitAvailabilityQueue = {}
local CurrentCombat = {}
local FilteredAbilities = {
	[L["Ricocheted Obliteration Beam"]] = true,		-- Garau
	[L["Shocking Cipher"]] = true,					-- Plutonus
	[L["Sourcestone Annihilation"]] = true,			-- Alsbeth
	[L["Deathly Flames"]] = true,					-- Greenscale
	[L["Crystalline Distortion"]] = true,			-- Maklamos
	[L["Crystal Laser"]] = true,					-- Maklamos hard mode
	[L["Rusila's Fist"]] = true,					-- Rusila
	--[L["Break Free"]] = true,						-- Rusila
	--[L["Static Discharge"]] = true,				-- General Typhiria
	[L["Outbreak"]] = true,							-- Volan
    [L["Chain Gang"]] = true,                		-- Warden Thrax
}
local EndCombatAfterKill = {
	"U2548A17D2D0E9F2F",	-- Ituziel
	"U7DB5A8C428F42F6F",	-- Sicaron
	"U7F19EEA52A744F51",	-- Murdantix
	"U00BF999D1AD12EF7",	-- Warboss Drak
	"U6D6AA149570398D0",	-- Maklamos The Scryer
	"U175A020043177B26",	-- Rusila Dreadblade
	"U7C80B6005E92811F",	-- Laethys p2
	"U35BDBE1C0B7EB642",	-- Maelforge Dragon Eggs
	"U22D6DD797E7A5F87",	-- Maelforge p1
	"U35BDBE1D14577953",	-- Maelforge p2
	"UFD8602DF11B09969",    -- Goloch
}
local NewCombatAfterKill = {
	"U6AA84B235AEB7988",	-- Heart of the Dread Fortune - Rusila
}



RM.combats = {}
RM.overall = nil -- sum of all combats

RM.settings = {
	windows = {},
	classColors = {
		warrior = {1, .15686, .15686},
		cleric = {.46667, .93725, 0},
		mage = {.78431, .36863, 1},
		rogue = {1, .85882, 0},
		primalist = {.231, .842, 1},
		none = {1, 1, 1}
	},
	abilityColors = {
		life = {0, 1, 0},
		fire = {1, 0, 0},
		earth = {1, 1, 0},
		water = {0, .5, 1},
		death = {.81, .31, 1},
		air = {1, 1, 1},
		physical = {.6, .6, .6}
	},
	totalbarColor = {0, 0.5, 1},
	lock = false,
	alwaysShowPlayer = true,
	showScrollbar = false,
	showRankNumber = true,
	showPercent = true,
	showAbsolute = true,
	mergeAbilitiesByName = true,
	showTooltips = true,
	absorbAsDamage = true,
	mergePets = true,
	customHighlightFontColor = false,
	customHighlightFontColorValue = {1, 1, 0},
	customHighlightBackgroundColor = false,
	customHighlightBackgroundColorValue = {0, 0, 0},
	abbreviateNumbers = true,
}

RM.windowSettings = {
	sort = "damage",
	rows = 8,
	width = 280,
	rowHeight = 18,
	rowPadding = 1,
	rowTexture = [[textures\BantoBar.dds]],
	--	rowFont = "",
	rowFontSize = 12,
	rowFontColor = {1, 1, 1},
	swapTextAndBarColor = false,
	showEnemies = false,
	hideButtons = {},
	backgroundColor = {0, 0, 0, .5},
	footerBackgroundColor = {0, 0, 0, .7},
	titlebarColor = {0, 0, 0, 1},
	titlebarTexture = [[textures\header.png]],
	titlebarHeight = 24,
	titlebarFontSize = 12,
	titlebarFontColor = {1, 1, 1},
}
RM.windowSettings.x = VU.round((UIParent:GetWidth() - RM.windowSettings.width) / 2)
RM.windowSettings.y = VU.round(UIParent:GetHeight() / 2)

local function Default(startUp)
	for key, value in pairs(RM.settings) do
		_G["RiftMeter_" .. key] = VU.deepcopy(value)
	end

	tinsert(RiftMeter_windows, VU.deepcopy(RM.windowSettings))

	if not startUp then
		RM.UI.Default()
		RM.Config:update()
	end
end

Default(true)



local function IsInGroup(id)
	return VURaidManagerUnitExists(id) or PlayerID == id or PlayerID == InspectUnitLookup(id .. ".owner")
end

local function AddToUnitAvailabilityQueue(id)
	tinsert(UnitAvailabilityQueue, id)

	RegisterEventIfNotExists(Event.Unit.Availability.Full, Events.UnitAvailabilityFull, "Gather full information for unavailable units")
end


local Ability = {}
Ability.__index = Ability
function Ability:new(info, damageAction)
	local self = {}
	self.detail = Abilities[info.abilityNew or info.abilityName]
	self.total = 0
	self.totalCrit = 0
	self.max = 0
	self.min = 0
	self.hits = 0
	self.crits = 0
	self.swings = 0
	self.filtered = 0
	self.absorbed = 0

	if damageAction then
		self.dodges = 0
		self.immunes = 0
		self.misses = 0
		self.parries = 0
		self.resists = 0
		self.blocked = 0
		self.deflected = 0
		self.intercepted = 0
		self.modified = 0
	end

	return setmetatable(self, Ability)
end
function Ability:clone()
	local clone = {
		detail = self.detail,
		total = self.total,
		totalCrit = self.totalCrit,
		max = self.max,
		min = self.min,
		hits = self.hits,
		crits = self.crits,
		swings = self.swings,
		filtered = self.filtered,
		absorbed = self.absorbed
	}


	if self.dodges then -- damageAction
		clone.dodges = self.dodges
		clone.immunes = self.immunes
		clone.misses = self.misses
		clone.parries = self.parries
		clone.resists = self.resists
		clone.blocked = self.blocked
		clone.deflected = self.deflected
		clone.intercepted = self.intercepted
		clone.modified = self.modified
	end

	return setmetatable(clone, Ability)
end
function Ability:merge(otherAbility)
	self.total = self.total + otherAbility.total
	self.totalCrit = self.totalCrit + otherAbility.totalCrit
	self.max = max(self.max, otherAbility.max)
	if self.min == 0 then
		self.min = otherAbility.min
	else
		if otherAbility.min > 0 then
			self.min = min(self.min, otherAbility.min)
		end
	end
	self.hits = self.hits + otherAbility.hits
	self.crits = self.crits + otherAbility.crits
	self.swings = self.swings + otherAbility.swings
	self.filtered = self.filtered + otherAbility.filtered

	if otherAbility.dodges then
		self.dodges = self.dodges + otherAbility.dodges
		self.immunes = self.immunes + otherAbility.immunes
		self.misses = self.misses + otherAbility.misses
		self.parries = self.parries + otherAbility.parries
		self.resists = self.resists + otherAbility.resists
		self.absorbed = self.absorbed + otherAbility.absorbed
		self.blocked = self.blocked + otherAbility.blocked
		self.deflected = self.deflected + otherAbility.deflected
		self.intercepted = self.intercepted + otherAbility.intercepted
		self.modified = self.modified + otherAbility.modified
	end
end
function Ability:add(combatEventData)
	local amount = combatEventData.amount
	local dmgType = combatEventData.dmgType

	if self.detail.filter then
		self.filtered = self.filtered + amount
	else
		self.total = self.total + amount
	end

	if combatEventData.info.crit then
		self.crits = self.crits + 1
		self.totalCrit = self.totalCrit + amount
	elseif dmgType == "dodges" or dmgType == "immunes" or dmgType == "misses" or dmgType == "parries" or dmgType == "resists" then
		self[dmgType] = self[dmgType] + 1
	else
		self.hits = self.hits + 1
	end

	self.swings = self.swings + 1

	if amount > self.max then
		self.max = amount
	end

	if amount < self.min or self.min == 0 then
		self.min = amount
	end

	if combatEventData.damageAction then
		self.absorbed = self.absorbed + abs(combatEventData.info.damageAbsorbed or 0)
		self.blocked = self.blocked + abs(combatEventData.info.damageBlocked or 0)
		self.deflected = self.deflected + abs(combatEventData.info.damageDeflected or 0)
		self.intercepted = self.intercepted + abs(combatEventData.info.damageIntercepted or 0)
		self.modified = self.modified + abs(combatEventData.info.damageModified or 0)
	end
end
function Ability:getTotal(sort)
	-- wow this function is fugly
	if RiftMeter_absorbAsDamage and not self.detail.filter then
		return sort == "damageAbsorbed" and self.total or self.total + self.absorbed
	else
		return self.total
	end
end
function Ability:getPreparedAbilityStatData()
	local stats = {
		{ name = L["total"], value = self.total },
		{ name = L["max"], value = self.max },
		{ name = L["average"], value = VU.round(self.total / self.swings) },
		{ name = L["average crit"], value = VU.round(self.totalCrit / max(self.crits, 1)) },
		{ name = L["min"], value = self.min },
		{ name = L["crit rate"], value = self.crits / self.swings * 100 },
		{ name = L["swings"], value = self.swings },
		{ name = L["hits"], value = self.hits },
		{ name = L["crits"], value = self.crits },
		{ name = L["filtered"], value = self.filtered }
	}

	if self.dodges then
		tinsert(stats, { name = L["dodges"], value = self.dodges })
		tinsert(stats, { name = L["immunes"], value = self.immunes })
		tinsert(stats, { name = L["misses"], value = self.misses })
		tinsert(stats, { name = L["parries"], value = self.parries })
		tinsert(stats, { name = L["resists"], value = self.resists })
		tinsert(stats, { name = L["absorbed"], value = self.absorbed })
		tinsert(stats, { name = L["blocked"], value = self.blocked })
		tinsert(stats, { name = L["deflected"], value = self.deflected })
		tinsert(stats, { name = L["intercepted"], value = self.intercepted })
		tinsert(stats, { name = L["modified"], value = self.modified })
	end

	return stats
end


-- struct
local CombatEventData = VU.class(function(self, interactedWith, statType, amount, info, damageAction, dmgType)
	self.interactedWith = interactedWith
	self.statType = statType
	self.amount = amount
	self.info = info
	self.damageAction = damageAction
	self.dmgType = dmgType
end)
function CombatEventData:Clone()
	return CombatEventData(self.interactedWith, self.statType, self.amount, self.info, self.damageAction, self.dmgType)
end


local AbilityDetail = {}
function AbilityDetail:new(info)
	local self = {}
	self.id = info.abilityNew
	self.name = info.abilityName
	self.icon = ""
	self.type = info.type or "physical"
	self.filter = false

	if info.abilityNew then
		local detail = InspectAbilityNewDetail(info.abilityNew)
		if detail then
			self.icon = detail.icon
		end
	end

	if FilteredAbilities[self.name] and not info.abilityNew then
		self.filter = true
	end

	return self
end

local Unit = {}
function Unit:new(detail, id)
	local self = {}
	self.name = detail.name
	self.player = detail.player
	self.id = detail.id
	self.inGroup = IsInGroup(detail.id)
	self.self = false
	self.isPet = false
	self.owner = nil

	if detail.availability == "full" then
		self.calling = detail.calling
		self.relation = detail.relation
		self.alliance = detail.alliance
	else
		AddToUnitAvailabilityQueue(id)
	end

	return self
end

local Player = {}
Player.__index = Player
function Player:new(id, reduced)
	local self = {}
	self.detail = Units[id]
	self.reduced = reduced
	self.damage = 0
	self.damageTaken = 0
	self.damageAbsorbed = 0
	self.damageDoneAbsorbed = 0
	self.overkill = 0
	self.heal = 0
	self.healTaken = 0
	self.overheal = 0

	if reduced then
		self.abilities = {}
		self.linkedToOwner = false
		self.pets = false
		self.interactions = false
		self.deathLog = false
	else
		self.deaths = 0
		self.deathLogRangeStart = 1
		self.deathLogRangeEnd = 0
		self.deathLogTemp = {}
		self.deathLog = {}

		self.pets = {}
		self.linkedToOwner = false

		self.interactions = {
			damage = {},
			damageTaken = {},
			damageAbsorbed = {},
			overkill = {},
			heal = {},
			healTaken = {},
			overheal = {}
		}
	end

	return setmetatable(self, Player)
end
function Player:addStat(combatEventData)
	local ability = self:addAbility(combatEventData)

	if not ability.filter then
		self[combatEventData.statType] = self[combatEventData.statType] + combatEventData.amount
		if combatEventData.statType == "damage" and combatEventData.info.damageAbsorbed then
			self.damageDoneAbsorbed = self.damageDoneAbsorbed + abs(combatEventData.info.damageAbsorbed)
		end
	end

	if not self.reduced then
		if combatEventData.statType == "damageTaken" then
			if combatEventData.info.damageAbsorbed then
				local absorbed = combatEventData.info.damageAbsorbed * -1
				self.damageAbsorbed = self.damageAbsorbed + absorbed
				local ced = combatEventData:Clone()
				ced.statType = "damageAbsorbed"
				ced.amount = absorbed
				self:addAbility(ced)
			end
		end

		if self.detail.player and (combatEventData.statType == "damageTaken" or combatEventData.statType == "healTaken") then
			self:addToDeathLog(combatEventData)
		end
	end
end
function Player:addAbility(combatEventData)
	local abilityDetail = Abilities[combatEventData.info.abilityNew or combatEventData.info.abilityName]

	if self.reduced then
		local ability = self.abilities[abilityDetail]
		if not ability then
			ability = Ability:new(combatEventData.info, combatEventData.damageAction)
			self.abilities[abilityDetail] = ability
		end
		ability:add(combatEventData)
	end

	if not self.reduced and self.interactions then
		local key = combatEventData.interactedWith and combatEventData.interactedWith or L["Unknown"]
		local player = self.interactions[combatEventData.statType][key]
		if not player then
			player = self:new(combatEventData.interactedWith and combatEventData.interactedWith.id, true)
			if not player.detail then
				player.detail = { name = key }
			end
			self.interactions[combatEventData.statType][key] = player
		end

		player:addStat(combatEventData)
	end

	return abilityDetail
end
function Player:addToDeathLog(combatEventData)
	local now = InspectTimeFrame()

	-- only keep data up to 10 seconds ago
	for i = self.deathLogRangeStart, self.deathLogRangeEnd do
		if now - self.deathLogTemp[i].time > 10 then
			self.deathLogTemp[i] = nil
			self.deathLogRangeStart = i + 1
		else
			break
		end
	end

	local entry = {
		time = now,
		caster = combatEventData.interactedWith,
		ability = Abilities[combatEventData.info.abilityNew or combatEventData.info.abilityName],
		statType = combatEventData.dmgType
	}
	if combatEventData.dmgType == "damage" or combatEventData.dmgType == "heal" then
		entry.amount = combatEventData.damageAction and combatEventData.amount * -1 or combatEventData.amount
		entry.crit = combatEventData.info.crit
	end

	if combatEventData.damageAction then
		entry.overkill = combatEventData.info.overkill
		entry.abilityType = combatEventData.info.type
		entry.damageAbsorbed = combatEventData.info.damageAbsorbed and combatEventData.info.damageAbsorbed * -1
		entry.damageBlocked = combatEventData.info.damageBlocked
		entry.damageDeflected = combatEventData.info.damageDeflected
		entry.damageIntercepted = combatEventData.info.damageIntercepted
		entry.damageModified = combatEventData.info.damageModified
	else
		entry.overheal = combatEventData.info.overheal
	end

	self.deathLogRangeEnd = self.deathLogRangeEnd + 1
	self.deathLogTemp[self.deathLogRangeEnd] = entry


	if combatEventData.info.overkill and combatEventData.amount > 0 then
		self.deaths = self.deaths + 1

		tinsert(self.deathLog, {
			timeOfDeath = os.time(),
			ingameTime = InspectTimeFrame(),
			killedBy = combatEventData.interactedWith,
			rangeStart = self.deathLogRangeStart,
			rangeEnd = self.deathLogRangeEnd,
			data = self.deathLogTemp
		})

		self.deathLogTemp = {}
		self.deathLogRangeStart = 1
		self.deathLogRangeEnd = 0
	end
end
function Player:getStat(sort)
	if RiftMeter_mergePets then
		return self:getStatPlusPets(sort)
	else
		return self:getRawStat(sort)
	end
end
function Player:getRawStat(sort)
	local stat = self[sort]
	if RiftMeter_absorbAsDamage and sort == "damage" then
		stat = stat + self.damageDoneAbsorbed
	end
	return stat
end
function Player:getInteractionStat(sort, interactionDetail)
	if RiftMeter_mergePets then
		local value = 0
		local units = self:getUnitTable()
		for _, unit in ipairs(units) do
			for _, interaction in pairs(unit.interactions[sort]) do
				if interaction.detail == interactionDetail then
					value = value + interaction:getRawStat(sort)
					break
				end
			end
		end
		return value
	else
		for _, interaction in pairs(self.interactions[sort]) do
			if interaction.detail == interactionDetail then
				return interaction:getRawStat(sort)
			end
		end
	end
end
function Player:getStatPlusPets(sort)
	local stat = self:getRawStat(sort)
	for i, pet in ipairs(self.pets) do
		stat = stat + pet:getRawStat(sort)
	end
	return stat
end
function Player:getUnitTable()
	local units = {self}
	if RiftMeter_mergePets then
		for i, pet in ipairs(self.pets) do
			tinsert(units, pet)
		end
	end
	return units
end
function Player:getInteractions(sort)
	local data = {
		interactions = nil,
		max = 0,
		total = 0
	}

	local interactions = {}
	local units = self:getUnitTable()
	for _, unit in ipairs(units) do
		for _, interaction in pairs(unit.interactions[sort]) do
			local value = interaction:getRawStat(sort)

			-- merge same interactions
			local found = false
			for _, insertedInteraction in ipairs(interactions) do
				if insertedInteraction.detail == interaction.detail then
					found = true
					insertedInteraction.value = insertedInteraction.value + value
					break
				end
			end
			--
			if not found then
				tinsert(interactions, {
					detail = interaction.detail,
					name = interaction.detail.name,
					value = value
				})
			end

			data.total = data.total + value
		end
	end

	tsort(interactions, function (a, b)
		return a.value > b.value
	end)

	if #interactions > 0 then
		data.max = max(interactions[1].value, 1)
	end

	data.interactions = interactions

	return data
end
function Player:getAbility(ability, sort)
	local returnAbility
	local units = self:getUnitTable()
	for _, unit in ipairs(units) do
		for _, interaction in pairs(unit.interactions[sort]) do
			for _, ability2 in pairs(interaction.abilities) do
				if (RiftMeter_mergeAbilitiesByName and (ability.detail.name == ability2.detail.name))
					or (not RiftMeter_mergeAbilitiesByName and (ability.detail == ability2.detail)) then
					if not returnAbility then
						returnAbility = ability2:clone()
					else
						returnAbility:merge(ability2)
					end
				end
			end
		end
	end
	return returnAbility
end
function Player:getInteractionAbility(ability, sort, interactionDetail)
	local returnAbility
	local units = self:getUnitTable()
	for _, unit in ipairs(units) do
		for _, interaction in pairs(unit.interactions[sort]) do
			if interaction.detail == interactionDetail then
				for _, ability2 in pairs(interaction.abilities) do
					if (RiftMeter_mergeAbilitiesByName and (ability.detail.name == ability2.detail.name))
						or (not RiftMeter_mergeAbilitiesByName and (ability.detail == ability2.detail)) then
						if not returnAbility then
							returnAbility = ability2:clone()
						else
							returnAbility:merge(ability2)
						end
					end
				end
				break
			end
		end
	end
	return returnAbility
end
function Player.sortAbilities(abilities, sort)
	tsort(abilities, function (a, b)
		if a:getTotal(sort) == b:getTotal(sort) then
			return a.detail.name:upper() < b.detail.name:upper()
		else
			return a:getTotal(sort) > b:getTotal(sort)
		end
	end)

	return abilities
end
function Player:getAbilities(sort)
	local abilities = {}
	local units = self:getUnitTable()
	for _, unit in ipairs(units) do
		for _, interaction in pairs(unit.interactions[sort]) do
			for _, ability in pairs(interaction.abilities) do
				local found = false
				for i, insertedAbility in ipairs(abilities) do
					if (RiftMeter_mergeAbilitiesByName and (insertedAbility.detail.name == ability.detail.name))
						or (not RiftMeter_mergeAbilitiesByName and (insertedAbility.detail == ability.detail)) then
						found = true
						insertedAbility:merge(ability)
					end
				end
				if not found then
					tinsert(abilities, ability:clone())
				end
			end
		end
	end
	return self.sortAbilities(abilities, sort)
end
function Player:getInteractionAbilities(sort, interactionDetail)
	local abilities = {}
	local units = self:getUnitTable()
	for _, unit in ipairs(units) do
		for _, interaction in pairs(unit.interactions[sort]) do
			if interaction.detail == interactionDetail then
				for _, ability in pairs(interaction.abilities) do
					local found = false
					for i, insertedAbility in ipairs(abilities) do
						if (RiftMeter_mergeAbilitiesByName and (insertedAbility.detail.name == ability.detail.name))
							or (not RiftMeter_mergeAbilitiesByName and (insertedAbility.detail == ability.detail)) then
							found = true
							insertedAbility:merge(ability)
						end
					end
					if not found then
						tinsert(abilities, ability:clone())
					end
				end
				break
			end
		end
	end
	return self.sortAbilities(abilities, sort)
end
function Player:getPreparedAbilityData(sort)
	local data = {
		count = 0,
		max = 0,
		total = 0
	}

	data.abilities = self:getAbilities(sort)
	for i, ability in ipairs(data.abilities) do
		data.total = data.total + ability:getTotal(sort)
		data.count = data.count + 1
	end

	if data.count > 0 then
		data.max = max(data.abilities[1]:getTotal(sort), 0)
	end

	return data
end
function Player:getInteractionAbilityData(sort, interactionDetail)
	local data = {
		abilities = {},
		count = 0,
		max = 0,
		total = 0
	}

	local abilities = self:getInteractionAbilities(sort, interactionDetail)

	for i, ability in ipairs(abilities) do
		local value = ability:getTotal(sort)
		local name = ability.detail.name

		tinsert(data.abilities, {
			name = name,
			value = value,
			ref = ability
		})

		data.total = data.total + value
		data.count = data.count + 1
	end

	if data.count > 0 then
		data.max = max(data.abilities[1].value, 0)
	end

	return data
end
function Player:createFakeAbility() -- total ability
	local fakeAbility = Ability:new({ability = ""}, true)
	local backup = fakeAbility.getPreparedAbilityStatData
	local player = self
	fakeAbility.detail = AbilityDetail:new({abilityName = L["Total"]})

	function fakeAbility:getPreparedAbilityStatData(sort)
		-- force update on retrieve

		self.total = 0
		self.totalCrit = 0
		self.max = 0
		self.min = 0
		self.hits = 0
		self.crits = 0
		self.swings = 0
		self.filtered = 0

		self.dodges = 0
		self.immunes = 0
		self.misses = 0
		self.parries = 0
		self.resists = 0
		self.absorbed = 0
		self.blocked = 0
		self.deflected = 0
		self.intercepted = 0
		self.modified = 0

		local units = player:getUnitTable()
		for _, unit in ipairs(units) do
			for _, interaction in pairs(unit.interactions[sort]) do
				for _, ability in pairs(interaction.abilities) do
					self:merge(ability)
				end
			end
		end

		return backup(self)
	end

	return fakeAbility
end
function Player:createFakeInteractionAbility(interactionDetail) -- total ability
	local fakeAbility = Ability:new({ability = ""}, true)
	local backup = fakeAbility.getPreparedAbilityStatData
	local player = self
	fakeAbility.detail = AbilityDetail:new({abilityName = L["Total"]})

	function fakeAbility:getPreparedAbilityStatData(sort)
		-- force update on retrieve

		self.total = 0
		self.totalCrit = 0
		self.max = 0
		self.min = 0
		self.hits = 0
		self.crits = 0
		self.swings = 0
		self.filtered = 0

		self.dodges = 0
		self.immunes = 0
		self.misses = 0
		self.parries = 0
		self.resists = 0
		self.absorbed = 0
		self.blocked = 0
		self.deflected = 0
		self.intercepted = 0
		self.modified = 0

		local units = player:getUnitTable()
		for _, unit in ipairs(units) do
			for _, interaction in pairs(unit.interactions[sort]) do
				if interaction.detail == interactionDetail then
					for _, ability in pairs(interaction.abilities) do
						self:merge(ability)
					end
					break
				end
			end
		end

		return backup(self)
	end

	return fakeAbility
end
function Player:getTooltip(sort)
	if not self.interactions or not self.interactions[sort] then
		return
	end

	local result = {"<font color=\"#FFD100\">" .. L["Top 3 Abilities:"] .. "</font>"}

	local interactions = self:getInteractions(sort)
	local abilities = self:getAbilities(sort)

	local formatInt = "   (%.f%%) %s"
	local formatFloat = "   (%.1f%%) %s"

	for i = 1, 3 do
		if abilities[i] then
			local val = abilities[i]:getTotal(sort) / self:getStat(sort) * 100
			if val == floor(val) then
				tinsert(result, formatInt:format(val, abilities[i].detail.name:sub(0, 16)))
			else
				tinsert(result, formatFloat:format(val, abilities[i].detail.name:sub(0, 16)))
			end
		else
			break
		end
	end

	tinsert(result, "<font color=\"#FFD100\">" .. L["Top 3 Interactions:"] .. "</font>")

	for i = 1, 3 do
		if interactions.interactions[i] then
			local val = interactions.interactions[i].value / self:getStat(sort) * 100
			if val == floor(val) then
				tinsert(result, formatInt:format(val, interactions.interactions[i].detail.name:sub(0, 16)))
			else
				tinsert(result, formatFloat:format(val, interactions.interactions[i].detail.name:sub(0, 16)))
			end
		else
			break
		end
	end

	tinsert(result, "<font color=\"#33FF33\">&lt;" .. L["Middle-Click for interactions"] .. "&gt;</font>")

	return table.concat(result, "\n")
end
function Player:getInteractionTooltip(sort, interactionDetail)
	local result = {"<font color=\"#FFD100\">" .. L["Top 6 Abilities:"] .. "</font>" }
	local abilities = self:getInteractionAbilities(sort, interactionDetail)
	for i = 1, 6 do
		if abilities[i] then
			tinsert(result, ("   (%.1f%%) %s"):format(abilities[i].total / self:getStat(sort) * 100, abilities[i].detail.name:sub(0, 16)))
		else
			break
		end
	end
	return table.concat(result, "\n")
end


local Combat = {}
Combat.__index = Combat
function Combat:new()
	local self = {}
	self.startTime = InspectTimeFrame()
	self.duration = 0
	self.players = {}
	self.hostiles = {}
	return setmetatable(self, Combat)
end
function Combat:endCombat(durationIsCallTime)
	local now = InspectTimeFrame()
	if durationIsCallTime then
		self.duration = now - self.startTime
	else
		self.duration = now - self.startTime - (now - LastDamageAction)
	end
end
function Combat:getDeathData(showEnemies)
	local data = {
		players = {},
		count = 0,
		max = 0,
		total = 0
	}

	local players = {}
	for _, player in pairs(self.players) do
		if (showEnemies and not player.detail.player)
			or (not showEnemies and player.detail.player) then
			tinsert(players, player)
		end
	end

	tsort(players, function (a, b)
		if a.deaths == b.deaths then
			return a.detail.name:upper() < b.detail.name:upper()
		else
			return a.deaths > b.deaths
		end
	end)

	for i, player in ipairs(players) do
		local value = player.deaths
		if value > 0 then
			local name
			if player.linkedToOwner then
				name = ("%s (%s)"):format(player.detail.name, player.detail.owner.name)
			else
				name = player.detail.name
			end

			tinsert(data.players, {
				name = name,
				value = value,
				ref = player
			})

			data.total = data.total + value
			data.count = data.count + 1
		end
	end

	if data.count > 0 then
		data.max = data.players[1].value
	end

	return data
end
function Combat:getPreparedPlayerData(sort, showEnemies)
	local players = {}
	local data = {
		players = {},
		count = 0,
		max = 0,
		total = 0
	}


	if RiftMeter_mergePets then
		for _, player in pairs(self.players) do
			if (showEnemies and not player.detail.player and not player.detail.isPet) -- npc pets?
				or (not showEnemies and player.detail.player) then
				tinsert(players, player)
			end
		end

		tsort(players, function (a, b)
			if a:getStatPlusPets(sort) == b:getStatPlusPets(sort) then
				return a.detail.name:upper() < b.detail.name:upper()
			else
				return a:getStatPlusPets(sort) > b:getStatPlusPets(sort)
			end
		end)

		for i, player in ipairs(players) do
			local valuePlusPets = player:getStatPlusPets(sort)
			if valuePlusPets > 0 then
				tinsert(data.players, {
					name = player.detail.name,
					value = valuePlusPets,
					ref = player
				})

				data.total = data.total + valuePlusPets
				data.count = data.count + 1
			end
		end
	else
		for _, player in pairs(self.players) do
			if (showEnemies and not player.detail.player and not player.detail.isPet)
				or (not showEnemies and (player.detail.player or player.detail.isPet)) then
				tinsert(players, player)
			end
		end

		tsort(players, function (a, b)
			if a:getRawStat(sort) == b:getRawStat(sort) then
				return a.detail.name:upper() < b.detail.name:upper()
			else
				return a:getRawStat(sort) > b:getRawStat(sort)
			end
		end)

		for i, player in ipairs(players) do
			local value = player:getStat(sort)
			if value > 0 then
				local name
				if player.linkedToOwner then
					name = ("%s (%s)"):format(player.detail.name, player.detail.owner.name)
				else
					name = player.detail.name
				end

				tinsert(data.players, {
					name = name,
					value = value,
					ref = player
				})

				data.total = data.total + value
				data.count = data.count + 1
			end
		end
	end


	if data.count > 0 then
		data.max = data.players[1].value
	end

	return data
end
function Combat:getHostile()
	local players = {}
	for _, player in pairs(self.players) do
		tinsert(players, player)
	end

	-- other units > Players and pets + sort by damage taken desc
	tsort(players, function (a, b)
		local aCond = not (a.detail.player or a.detail.isPet)
		local bCond = not (b.detail.player or b.detail.isPet)
		if aCond and bCond then
			return a.damageTaken > b.damageTaken
		end
		return aCond and not bCond
	end)

	if #players > 0 then
		return players[1].detail.name
	end

	return ""
end
function Combat:addPlayer(id)
	local unit = Units[id]
	local player = self.players[unit]
	if not player then
		player = Player:new(id, false)
		self.players[unit] = player
	end
	if player.detail.isPet and not player.linkedToOwner and player.detail.owner then
		self:linkPetToOwner(player)
	end

	return player
end
function Combat:linkPetToOwner(pet)
	local owner = self.players[pet.detail.owner]
	if not owner then
		owner = self:addPlayer(pet.detail.owner.id)
	end

	if owner then
		pet.linkedToOwner = true
		tinsert(owner.pets, pet)
	end
end





local function AddGlobalAbility(info)
	local key = info.abilityNew or info.abilityName
	local ability = Abilities[key]
	if not ability then
		ability = AbilityDetail:new(info)
		Abilities[key] = ability
	end
	return ability
end

local function AddGlobalUnit(id)
	local unit = Units[id]
	if not unit then
		local detail = InspectUnitDetail(id)
		if not detail then
			return
		end

		unit = Unit:new(detail, id)

		local ownerID = InspectUnitLookup(id .. ".owner")
		if ownerID then
			unit.isPet = true
			unit.owner = AddGlobalUnit(ownerID)
		end

		if PlayerID == id then
			unit.self = true
		end

		Units[id] = unit
		return unit
	end

	if unit.isPet and not unit.owner then
		local detail = InspectUnitDetail(id)
		if not detail then
			return
		end

		local ownerID = InspectUnitLookup(id .. ".owner")
		if ownerID then
			unit.isPet = true
			unit.owner = AddGlobalUnit(ownerID)
		end
	end
	return unit
end

local function GetMaxValueCombat(sort, showEnemies)
	local maxvalue = 1
	for i, combat in ipairs(RM.combats) do
		local value = combat:getPreparedPlayerData(sort, showEnemies).total / max(combat.duration, 1)
		if value > maxvalue then
			maxvalue = value
		end
	end
	return maxvalue
end

local function NewCombat(permanent)
	if InCombat then
		return
	end

	CurrentCombat = Combat:new()
	InCombat = true
	Permanent = not not permanent
	tinsert(RM.combats, CurrentCombat)

	if not RM.overall then
		RM.overall = Combat:new()
		RM.overall.durationBefore = 0
	end

	RM.UI.NewCombat()
end

local function EndCombat(durationIsCallTime)
    if not InCombat then
        return
	end

	CurrentCombat:endCombat(durationIsCallTime)
	StopTracking = false
	InCombat = false
	Permanent = false

	-- clear deathlogs
	for _, player in pairs(CurrentCombat.players) do
		player.deathLogTemp = nil
	end

    -- add to overall
    RM.overall.duration = RM.overall.durationBefore + CurrentCombat.duration
    RM.overall.durationBefore = RM.overall.duration

	RM.UI.Update()
	RM.UI.EndCombat()
end

local function AddPlayer(id)
	local overall = RM.overall:addPlayer(id)
	overall.interactions = nil
	return CurrentCombat:addPlayer(id), overall
end

local function AddStat(player, overall, ability, combatEventData)
	player:addStat(combatEventData)

	-- add to overall
	if not ability.filter then
		overall[combatEventData.statType] = overall[combatEventData.statType] + combatEventData.amount
		if combatEventData.info.damageAbsorbed then
			if combatEventData.statType == "damage" then
				overall.damageDoneAbsorbed = overall.damageDoneAbsorbed + abs(combatEventData.info.damageAbsorbed)
			elseif combatEventData.statType == "damageTaken" then
				overall.damageAbsorbed = overall.damageAbsorbed + (combatEventData.info.damageAbsorbed * -1)
			end
		end
	end
end

local function CombatEventsHandler(info, statType, damageAction)
	if StopTracking and not Permanent then -- force a combat end on several bosses with incoming damage after kill extending the duration
		return
	end

	local target = AddGlobalUnit(info.target)
	local caster = AddGlobalUnit(info.caster)
	if not caster then return end -- if details cant be found by Inspect.Unit.Detail(info.caster) cuz of out of range or other. However Event.Damage still triggers

	local ability = AddGlobalAbility(info)

	local selfAction = info.caster == info.target
	local selfDamageAction = false
	if not selfAction then
		if statType == "damage" then
			if not InCombat and caster.inGroup then
				NewCombat()
			end
		end
	else
		-- self damage action, e.g. fall damage, sacrifice mana, ...
		if statType == "damage" then
			selfDamageAction = true
		end
	end

	if InCombat then
		if statType == "damage" and caster.inGroup then
			LastDamageAction = InspectTimeFrame()
		end
		NeedsUpdate = true
	else
		return
	end

	local amount = info[statType] or 0


	local casterInCombat, casterInOverall = AddPlayer(info.caster)

	-- Add stat to caster
	local stat
	if damageAction and not selfDamageAction then
		stat = "damage"
	elseif not damageAction then
		stat = "heal"
	end

	if stat then
		AddStat(casterInCombat, casterInOverall, ability, CombatEventData(target, stat, amount, info, damageAction, statType))
	end

	-- Add Overheal/Overkill
	local key
	if info.overkill then
		key = "overkill"
	elseif info.overheal then
		key = "overheal"
	end

	if key then
		AddStat(casterInCombat, casterInOverall, ability, CombatEventData(target, key, info[key], info, damageAction))
	end

	-- Add targets equivalent damage/heal taken
	if target then
		local targetInCombat, targetInOverall = AddPlayer(info.target)

		local taken
		if damageAction then
			taken = "damageTaken"
		elseif statType == "heal" then
			taken = "healTaken"
		end

		if taken then
			AddStat(targetInCombat, targetInOverall, ability, CombatEventData(caster, taken, amount, info, damageAction, statType))
		end
	end
end


--function Events.Combat(Units)
--	local unitId = ""
--	local inGroup = false
--	for id, combatStart in pairs(Units) do
--		if IsInGroup(id) then
--			unitId = id
--			inGroup = true
--			break
--		end
--	end
--
--	if not inGroup then
--		return
--	end
--
--	local startCombat = false
--	if LibSRMGrouped() then
--		for i = 1, 20 do
--			local specifier, unitId = LibSRMGroupInspect(i)
--			if unitId then
--				local InCombat = InspectUnitDetail(unitId).combat
--				if InCombat then
--					startCombat = true
--					break
--				end
--			end
--		end
--	else
--		if Units[unitId] then
--			startCombat = true
--		end
--	end
--	if startCombat then
--		NewCombat()
--	else
--		EndCombat()
--	end
--end
--local eventsCombat = Events.Combat

function Events:Update()
    local now = InspectTimeFrame()

    if InCombat then
        if now - LastDamageAction >= 6 and not Permanent then
            EndCombat()
		end

		if now - LastTimerUpdate > 1 then
			LastTimerUpdate = now
			RMUITimerUpdate(now - CurrentCombat.startTime) -- dont use combat's.duration
		end
	end

	if not NeedsUpdate and not Permanent then return end

	if now - LastUpdate > .3 then
		CurrentCombat.duration = now - CurrentCombat.startTime
		RM.overall.duration = now - RM.overall.startTime
		LastUpdate = now
		NeedsUpdate = false

		RMUIUpdate()
	end
end

function Events:Damage(info)
	CombatEventsHandler(info, "damage", true)
end
function Events:Dodge(info)
	CombatEventsHandler(info, "dodges", true)
end
function Events:Immune(info)
	CombatEventsHandler(info, "immunes", true)
end
function Events:Miss(info)
	CombatEventsHandler(info, "misses", true)
end
function Events:Parry(info)
	CombatEventsHandler(info, "parries", true)
end
function Events:Resist(info)
	CombatEventsHandler(info, "resists", true)
end
function Events:Heal(info)
	CombatEventsHandler(info, "heal", false)
end
function Events:Death(info)
	if not InCombat or StopTracking or not info.target then
		return
	end

	local detail = InspectUnitDetail(info.target)
	if not detail or not detail.type then
		return
	end
	for i, type in ipairs(EndCombatAfterKill) do
		if type == detail.type then
			EndCombat()
			StopTracking = true
			InCombat = true
			return
		end
	end
	for i, type in ipairs(NewCombatAfterKill) do
		if type == detail.type then
			EndCombat()
			return
		end
	end
end

function Events:GroupChange(id, oldState, newState)
	if Units[id] then
		Units[id].inGroup = IsInGroup(id)
	end
end

--function Events.UIResize()
--	RM.frames.base:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", RiftMeter_x, RiftMeter_y)
--end



function Events:UnitAvailabilityFull(units)
	for id, specifier in pairs(units) do
		for i, unavailableUnitId in ipairs(UnitAvailabilityQueue) do
			if unavailableUnitId == id then
				local unit = Units[id]
				if unit then
					local detail = InspectUnitDetail(id)
					unit.calling = detail.calling
					unit.relation = detail.relation
					unit.alliance = detail.alliance
					tremove(UnitAvailabilityQueue, i)
					break
				end
			end
		end
	end

	if #UnitAvailabilityQueue == 0 then
		CommandEventDetach(Event.Unit.Availability.Full, Events.UnitAvailabilityFull)
	end
end

local function On()
	if Enabled then
		return
	end

	Enabled = true
	RM.UI.Visible(true)

	CommandEventAttach(Event.Combat.Death,          Events.Death,   "Handle Deaths")
	CommandEventAttach(Event.Combat.Damage,         Events.Damage,  "Handle Damage")
	CommandEventAttach(Event.Combat.Dodge,          Events.Dodge,   "Handle Dodges")
	CommandEventAttach(Event.Combat.Immune,         Events.Immune,  "Handle Immunes")
	CommandEventAttach(Event.Combat.Miss,           Events.Miss,    "Handle Misses")
	CommandEventAttach(Event.Combat.Parry,          Events.Parry,   "Handle Parries")
	CommandEventAttach(Event.Combat.Resist,         Events.Resist,  "Handle Resists")
	CommandEventAttach(Event.Combat.Heal,           Events.Heal,    "Handle Heal")
	CommandEventAttach(Event.System.Update.Begin,   Events.Update,  "Update")

	-- permanent
	RegisterEventIfNotExists(Event.VinceUtils.Group.Change,	Events.GroupChange, "Track Group")
	RegisterEventIfNotExists(Event.VinceUtils.Group.Join,	Events.GroupChange, "Track Group")
	RegisterEventIfNotExists(Event.VinceUtils.Group.Leave,	Events.GroupChange, "Track Group")

	--	RegisterEvent(Event.Unit.Detail.Combat, 			{EventsCombat,  Info.identifier, "Handle Combats"})
	--	RegisterEvent(Event.SafesRaidManager.Group.Combat.End, 	{EndCombat,  Info.identifier, "Raid Combat End"})
end

local function Off()
	if not Enabled then
		return
	end

	Enabled = false
	RM.UI.Visible(false)

	CommandEventDetach(Event.Combat.Death, 	        Events.Death)
	CommandEventDetach(Event.Combat.Damage, 	   	Events.Damage)
	CommandEventDetach(Event.Combat.Dodge, 		    Events.Dodge)
	CommandEventDetach(Event.Combat.Immune, 		Events.Immune)
	CommandEventDetach(Event.Combat.Miss, 			Events.Miss)
	CommandEventDetach(Event.Combat.Parry, 		    Events.Parry)
	CommandEventDetach(Event.Combat.Resist, 		Events.Resist)
	CommandEventDetach(Event.Combat.Heal, 			Events.Heal)
	CommandEventDetach(Event.System.Update.Begin, 	Events.Update)
end

local function Toggle()
	if Enabled then
		Off()
	else
		On()
	end
end

local function Reset()
    Units = {}
    Abilities = {}
	CurrentCombat = {}

	InCombat = false
	NeedsUpdate = false
	Permanent = false

	RM.combats = {}
	RM.overall = nil

	RM.UI.Reset()

--	Thanks to WatchDog
--	collectgarbage("collect")
end

local SlashCommands = setmetatable({
	show = function()
		On()
	end,
	hide = function()
		Off()
	end,
	default = function()
		RM.Dialog:show(L["Set to default?"], L["Yes"], L["No"], Default, function() end)
	end,
	config = function()
		RM.Config:toggle()
	end,
	toggle = function()
		if Enabled then
			Off()
		else
			On()
		end
	end,
	version = function()
		RM.notify(Info.name .. " v" .. Info.toc.Version)
	end
},
{
	__index = function(t, key)
		return function()
			RM.notify(L["Available commands:"])
			for cmd, func in pairs(t) do
				RM.notify("/" .. SlashCommand .. " <a lua=\"RiftMeter.SlashCommands['" .. cmd .. "']()\"><font color=\"#AAAAAA\"><u>" .. cmd .. "</u></font></a>")
			end
		end
	end
})

function Events:SlashHandler(params)
	local list = {}
	for param in params:gmatch("[^%s]+") do
		tinsert(list, param)
	end
	SlashCommands[list[1]](unpack(list, 2, #list))
end

function RM.notify(text)
	Command.Console.Display("general", true, "<font color=\"#FFD100\">" .. text .. "</font>", true)
end

function Events:SavedVariablesLoadEnd(identifier)
	if identifier ~= Info.identifier then
		return
	end

	for key, value in pairs(RM.settings) do
		if type(value) == "table" then
			_G["RiftMeter_" .. key] = VU.extend(VU.deepcopy(value), _G["RiftMeter_" .. key])
		end
	end

	-- migration to v1.0
	if not RiftMeter_classColors.none then
		RiftMeter_classColors.none = VU.deepcopy(RM.settings.classColors.none)
	end
end
function Events:LoadEnd(identifier)
	if identifier ~= Info.identifier then
		return
	end

	PlayerID = InspectUnitLookup("player")

	RM.UI.Init()
	On()

	Command.Console.Display("general", true, RM.colorize(L["%s v%s loaded. /rm for"]:format(Info.toc.Name, Info.toc.Version), 0x00D0FF, 0x0065FF) .. " <a lua=\"RiftMeter.SlashCommands[0]()\"><font color=\"#AAAAAA\"><u>" .. L["commands"] .. "</u></font></a>", true)
end

CommandEventAttach(Event.Addon.Load.End,                    Events.LoadEnd,                 Info.identifier .. " Init")
CommandEventAttach(Event.Addon.SavedVariables.Load.End,     Events.SavedVariablesLoadEnd,   "Variables loaded")
CommandEventAttach(Command.Slash.Register(SlashCommand),    Events.SlashHandler,            "Slash Handler")


-- Make public
RM.Reset = Reset
RM.Off = Off
RM.Default = Default
RM.NewCombat = NewCombat
RM.EndCombat = EndCombat
RM.GetMaxValueCombat = GetMaxValueCombat
RM.SlashCommands = SlashCommands
