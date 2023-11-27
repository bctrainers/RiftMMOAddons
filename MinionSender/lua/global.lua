MinionSenderAddon = Inspect.Addon.Detail(Inspect.Addon.Current())
MinionSender = {
	AE = {
		Command = "minsnd",
		UI = {},
		Data = {},
		Visible = false,
		RarityColor = { common = { 255, 255, 255 }, uncommon = { 0, 194, 0 }, rare = { 36, 122, 240 }, epic = { 165, 70, 240 } }
	},
	Data = { Language = {} },
	Menu = {},
	GUI = {},
	Events = {},
	Minion = {},
	Inventory = {},
	DefaultFlags = {
		duration = 1,
		level = { min = 1, max = 25 },
		staminaReserve = 0,

		priority = 1,
		match0 = false,
		match1 = true,
		match2 = true,
		filtercommon = true,
		filteruncommon = true,
		filterrare = true,
		filterepic = true,
		filterattractor = true,

		shuffle = false,
		shuffleArtifact = false,
		shuffleAssassination = false,
		shuffleDimension = false,
		shuffleDiplomacy = false,
		shuffleHarvest = false,
		shuffleHunting = false,
		shuffleChain = false,
		shuffleRare = true,
		shuffleRareValue = 10,

		operateDimension = false,
		destroyDimensioncommon = true,
		destroyDimensionuncommon = true,
		destroyDimensionrare = true,
		destroyDimensionepic = true,
		destroyDimensionrelic = true,
		destroyDimensionKey = false,
		destroyDimensionContainer = false,
		openDimensionContainer = true,

		claimAttractors = true,
		claimArtifact = true,
		claimAssassination = true,
		claimDimension = true,
		claimDiplomacy = true,
		claimHarvest = true,
		claimHunting = true,

		actionLeft = true,
		actionRight= false,
		actionMiddle = false,
		actionMouse4 = false,
		actionMouse5 = false,
		actionWheel = false,
		showTooltip = true,
		language = "Auto",
		options = "Simple",
		lockWindow = false,

		chainReserve = true,
		dropUnstableBox = false,

		colorAvailable = { 231, 219, 165 },
		colorWorking = { 90, 204, 2 },
		colorFinished = { 218, 3, 3 },
		colorTimer = { 245, 245, 9 },
		colorAnnouncement = { 173, 72, 251 },

		rule = 1,
		ruleset = {
			{ name = "AdvancedPriority1", rules = {
				{ level = { min = 1, max = 24 }, filtercommon = true, filteruncommon = true, filterrare = true, filterepic = true, filterattractor = true, staminaReserve = 0, priority = 4, duration = 1, match0 = false, match1 = true, match2 = true },
			} },
			{ name = "AdvancedPriority2", rules = {
				{ level = { min = 25, max = 25 }, filtercommon = true, filteruncommon = true, filterrare = true, filterepic = true, filterattractor = true, staminaReserve = 0, priority = 1, duration = 2, match0 = false, match1 = true, match2 = true },
			} },
			{ name = "AdvancedPriority3", rules = {
				{ level = { min = 25, max = 25 }, filtercommon = true, filteruncommon = true, filterrare = true, filterepic = true, filterattractor = true, staminaReserve = 0, priority = 1, duration = 4, match0 = false, match1 = true, match2 = true },
			} },
		}
	}
}
