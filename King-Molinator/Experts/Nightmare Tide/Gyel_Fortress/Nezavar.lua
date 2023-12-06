-- Admiral Nezavar Boss Mod for King Boss Mods
-- Written by Maatang
-- July 2015
--

KBMNTGFNEZ_Settings = nil
chKBMNTGFNEZ_Settings = nil

-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data

if not KBM.BossMod then
	return
end

local Instance = KBM.BossMod["Gyel_Fortress"]

local MOD = {
	Directory = Instance.Directory,
	File = "Nezavar.lua",
	Enabled = true,
	Instance = Instance.Name,
	InstanceObj = Instance,
	HasPhases = true,
	Lang = {},
	ID = "GF_Nezavar",
	Object = "MOD",
	--Enrage = 5*60,
}

-- Main Unit Dictionary
MOD.Lang.Unit = {}
MOD.Lang.Unit.Nezavar = KBM.Language:Add("Admiral Nezavar")
MOD.Lang.Unit.Nezavar:SetFrench("Amiral Nezavar")
-- Ability Dictionary
MOD.Lang.Ability = {}

-- Verbose Dictionary
MOD.Lang.Verbose = {}
MOD.Lang.Verbose.Chase = KBM.Language:Add("Run Away!")
MOD.Lang.Verbose.Chase:SetFrench("Courez!!!")

-- Buff Dictionary
MOD.Lang.Buff = {}

-- Debuff Dictionary
MOD.Lang.Debuff = {}

-- Notify Dictionary
MOD.Lang.Notify = {}
MOD.Lang.Notify.Chase = KBM.Language:Add("Admiral Nezavar chases after (%a*)!")
MOD.Lang.Notify.Chase:SetFrench("Amiral Nezavar poursuit(%a*)!")

-- Description Dictionary
MOD.Lang.Main = {}
MOD.Descript = MOD.Lang.Unit.Nezavar[KBM.Lang]


MOD.Nezavar = {
	Mod = MOD,
	Level = "??",
	Active = false,
	Name = MOD.Lang.Unit.Nezavar[KBM.Lang],
	NameShort = "Nezavar",
	Menu = {},
	AlertsRef = {},
	Castbar = nil,
	Dead = false,
	Available = false,
	UnitID = nil,
	UTID = "U719192E66CD2E0CA",
	TimeOut = 5,
	Triggers = {},
	Settings = {
		CastBar = KBM.Defaults.Castbar(),
		AlertsRef = {
		  Enabled = true,
		  Chase = KBM.Defaults.AlertObj.Create("red"),
		 },
	},
}

KBM.RegisterMod(MOD.ID, MOD)

function MOD:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Nezavar.Name] = self.Nezavar,
	}
end

function MOD:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Nezavar.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		PhaseMon = KBM.Defaults.PhaseMon(),
		-- MechTimer = KBM.Defaults.MechTimer(),
		Alerts = KBM.Defaults.Alerts(),
		-- TimersRef = self.Baird.Settings.TimersRef,
		AlertsRef = self.Nezavar.Settings.AlertsRef,
	}
	KBMNTGFNEZ_Settings = self.Settings
	chKBMNTGFNEZ_Settings = self.Settings
	
end

function MOD:SwapSettings(bool)

	if bool then
		KBMNTGFNEZ_Settings = self.Settings
		self.Settings = chKBMNTGFNEZ_Settings
	else
		chKBMNTGFNEZ_Settings = self.Settings
		self.Settings = KBMNTGFNEZ_Settings
	end

end

function MOD:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMNTGFNEZ_Settings, self.Settings)
	else
		KBM.LoadTable(KBMNTGFNEZ_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMNTGFNEZ_Settings = self.Settings
	else
		KBMNTGFNEZ_Settings = self.Settings
	end	
end

function MOD:SaveVars()	
	if KBM.Options.Character then
		chKBMNTGFNEZ_Settings = self.Settings
	else
		KBMNTGFNEZ_Settings = self.Settings
	end	
end

function MOD:Castbar(units)
end

function MOD:RemoveUnits(UnitID)
	if self.Nezavar.UnitID == UnitID then
		self.Nezavar.Available = false
		return true
	end
	return false
end

function MOD:Death(UnitID)
	if self.Nezavar.UnitID == UnitID then
		self.Nezavar.Dead = true
		return true
	end
	return false
end

function MOD:UnitHPCheck(uDetails, unitID)	
	if uDetails and unitID then
		if uDetails.type == self.Nezavar.UTID then
			if not self.EncounterRunning then
				self.EncounterRunning = true
				self.StartTime = Inspect.Time.Real()
				self.HeldTime = self.StartTime
				self.TimeElapsed = 0
				self.Nezavar.Dead = false
				self.Nezavar.Casting = false
				self.Nezavar.CastBar:Create(unitID)
				self.PhaseObj:Start(self.StartTime)
				self.PhaseObj:SetPhase(KBM.Language.Options.Single[KBM.Lang])
				self.PhaseObj.Objectives:AddPercent(self.Nezavar.Name, 0, 100)
				self.Phase = 1
			end
			self.Nezavar.UnitID = unitID
			self.Nezavar.Available = true
			return self.Nezavar
		end
	end
end

function MOD:Reset()
	self.EncounterRunning = false
	self.Nezavar.Available = false
	self.Nezavar.UnitID = nil
	self.Nezavar.CastBar:Remove()
		
	self.PhaseObj:End(Inspect.Time.Real())
end

function MOD:Timer()	
end




function MOD:Start()
	-- Create Timers
	--KBM.Defaults.TimerObj.Assign(self.Baird)
	
	-- Create Alerts
	self.Nezavar.AlertsRef.Chase = KBM.Alert:Create(self.Lang.Verbose.Chase[KBM.Lang], nil, true, true, "red")
	KBM.Defaults.AlertObj.Assign(self.Nezavar)
	
	-- Assign Alerts and Timers to Triggers
	self.Nezavar.Triggers.Chase = KBM.Trigger:Create(self.Lang.Notify.Chase[KBM.Lang], "notify", self.Nezavar)
  self.Nezavar.Triggers.Chase:AddAlert(self.Nezavar.AlertsRef.Chase, true)
	
	self.Nezavar.CastBar = KBM.Castbar:Add(self, self.Nezavar)
	self.PhaseObj = KBM.PhaseMonitor.Phase:Create(1)
	
end