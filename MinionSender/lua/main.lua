function MinionSender.AE.EventSystemUpdateEnd (handle)
	if Inspect.System.Watchdog() < 0.1 then return end

	if Inspect.Time.Real() - MinionSender.AE.InitTime >= 1 then 
		MinionSender.AE.InitTime = Inspect.Time.Real()

		if MinionSender.AE.InitCounter < 5 then
			MinionSender.AE.InitCounter = MinionSender.AE.InitCounter + 1
			MinionSender.AE.UpdateInfo()
		end

		MinionSender.AE.UpdateTimer()
	end
end

function MinionSender.AE.Init (handle)
	MinionSender.AE.InitTime = Inspect.Time.Real()
	MinionSender.AE.InitCounter = 0
	MinionSender.AE.Language = Inspect.System.Language()
	MinionSender.AE.UI.Context = UI.CreateContext(MinionSenderAddon.identifier)

	MinionSender.AE.InitSettings()
	MinionSender.AE.CreateButton()
	MinionSender.AE.CreateWindow()
	MinionSender.AE.SetLanguage()

	MinionSender.Minion.Init()
	MinionSender.Menu.Options.Simple.Init(MinionSender.AE.UI.Window)
	MinionSender.Menu.Options.Advanced.Init(MinionSender.AE.UI.Window)
	MinionSender.Menu.Stats.Init(MinionSender.AE.UI.Window)

	Command.Console.Display("general", true, "<font color=\"#" .. colorRGBtoHEX(MinionSenderConfig.colorAnnouncement) .. "\">" .. MinionSenderAddon.name .. " ver." .. MinionSenderAddon.toc.Version .. MinionSender.Data.Language.Current.Load1 .. MinionSender.AE.Command .. MinionSender.Data.Language.Current.Load2 .. MinionSender.AE.Command .. MinionSender.Data.Language.Current.Load3 .. "</font>", true)
	MinionSender.CreateEvents()
end

function MinionSender.AE.CreateButton ()
	MinionSender.AE.UI.Button = MinionSender.GUI.Basic.CreateButton(MinionSender.AE.UI.Context, { 32, 32, iif(MINIMAPDOCKER, nil, { MinionSenderUISettings.button.x, MinionSenderUISettings.button.y }) }, 0, "button", MinionSender.AE.ToggleWindow)
	if MINIMAPDOCKER then
		MINIMAPDOCKER.Register(MinionSenderAddon.toc.Name, MinionSender.AE.UI.Button, MinionSender.AE.ToggleWindow)
	else
		MinionSender.GUI.Extended.AttachDragFrame(MinionSender.AE.UI.Button, false, "button", false, false)
	end
end

function MinionSender.AE.CreateWindow ()
	MinionSender.AE.UI.Window = MinionSender.GUI.Basic.CreateFrame(MinionSender.AE.UI.Context, { 75, 75, { MinionSenderUISettings.window.x, MinionSenderUISettings.window.y } }, 100, {
		LeftClick = function() if MinionSenderConfig.actionLeft then MinionSender.AE.Action() end end,
		MiddleClick = function() if MinionSenderConfig.actionMiddle then MinionSender.AE.Action() end end,
		RightClick = function() if MinionSenderConfig.actionRight then MinionSender.AE.Action() end end,
		Mouse4Click = function() if MinionSenderConfig.actionMouse4 then MinionSender.AE.Action() end end,
		Mouse5Click = function() if MinionSenderConfig.actionMouse5 then MinionSender.AE.Action() end end,
		WheelBack = function() if MinionSenderConfig.actionWheel then MinionSender.AE.Action() end end,
		WheelForward = function() if MinionSenderConfig.actionWheel then MinionSender.AE.Action() end end,
		RightDown = function() MinionSender.Menu.Stats.SetVisible(not MinionSender.Menu.Options[MinionSenderConfig.options].SetVisible(iif(MinionSenderConfig.actionRight == false, nil, false))) end,
		LeftDown = function() MinionSender.Menu.Stats.SetVisible(not MinionSender.Menu.Options[MinionSenderConfig.options].SetVisible(iif(MinionSenderConfig.actionLeft == false, nil, false))) end,
		MouseIn = function(handler) if not MinionSender.Menu.Options[MinionSenderConfig.options].GetVisible() and not handler.DragFrame.Drag then MinionSender.Menu.Stats.SetVisible(true) end end,
		MouseOut = function() MinionSender.Menu.Stats.SetVisible(false) end
	})

	MinionSender.AE.UI.Window:SetVisible(MinionSenderUISettings.window.visible)
	MinionSender.GUI.Extended.AttachDragFrame(MinionSender.AE.UI.Window, false, "window", true, true, function(flag) MinionSender.Menu.Stats.SetVisible(not flag) end)
	MinionSender.AE.UI.Window.background = MinionSender.GUI.Basic.CreateTexture(MinionSender.AE.UI.Window, { { 0, 0 }, { 0, 0, "BOTTOMRIGHT" } }, 1, "window.png")

	MinionSender.AE.UI.Indicators = {
		Available = MinionSender.GUI.Basic.CreateText(MinionSender.AE.UI.Window, { { -13, -8, "CENTER" } }, 2, { fontSize = 13, fontColor = MinionSenderConfig.colorAvailable }),
		Working = MinionSender.GUI.Basic.CreateText(MinionSender.AE.UI.Window, { { 1, -8, "CENTER" } }, 2, { fontSize = 13, fontColor = MinionSenderConfig.colorWorking }),
		Finished = MinionSender.GUI.Basic.CreateText(MinionSender.AE.UI.Window, { { 14, -8, "CENTER" } }, 2, { fontSize = 13, fontColor = MinionSenderConfig.colorFinished }),
		Timer = MinionSender.GUI.Basic.CreateText(MinionSender.AE.UI.Window, { { 0, 9, "CENTER" } }, 2, { fontSize = 13, fontColor = MinionSenderConfig.colorTimer })
	}

	MinionSender.AE.SetScale()
	MinionSender.AE.ShowBackground()
end

function MinionSender.AE.ToggleWindow (handler, val)
	if val == "reset" then
		MinionSender.AE.FixSettings()
	else
		MinionSenderUISettings.window.visible = not MinionSenderUISettings.window.visible
		MinionSender.AE.UI.Window:SetVisible(MinionSenderUISettings.window.visible)
	end
end

function MinionSender.AE.SetLanguage ()
	MinionSender.Data.Language.Current = iif(MinionSenderConfig.language == "Auto", MinionSender.Data.Language[MinionSender.AE.Language], MinionSender.Data.Language[MinionSenderConfig.language])
	MinionSender.Menu.Options.Simple.UpdateText()
	MinionSender.Menu.Options.Advanced.UpdateText()
	MinionSender.Menu.Stats.UpdateText()
end

function MinionSender.AE.SetScale ()
	MinionSenderUISettings.window.scale = MinionSenderConfig.scale
	MinionSender.AE.UI.Window:SetWidth(.75 * MinionSenderConfig.scale)
	MinionSender.AE.UI.Window:SetHeight(.75 * MinionSenderConfig.scale)

	for k, v in pairs(MinionSender.AE.UI.Indicators) do
		v.SetScale(MinionSenderConfig.scale / 100)
	end
end

function MinionSender.AE.ShowBackground ()
	MinionSenderUISettings.window.hideBackground = MinionSenderConfig.hideBackground
	MinionSender.AE.UI.Window.background:SetVisible(not MinionSenderConfig.hideBackground)
end

function MinionSender.AE.InitSettings ()
	if MinionSenderUISettings == nil then MinionSenderUISettings = {} end
	if MinionSenderConfig == nil then MinionSenderConfig = {} end

	if MinionSenderUISettings.button == nil or MinionSenderUISettings.window == nil then 
		MinionSenderUISettings.button = { }
		MinionSenderUISettings.window = { }
		MinionSender.AE.FixSettings()
	end
	
	MinionSender.AE.UpgradeVersion()

	for k, v in pairs(MinionSender.DefaultFlags) do
		if MinionSenderConfig[k] == nil then MinionSenderConfig[k] = v end
	end	

	MinionSenderConfig.scale = MinionSenderUISettings.window.scale
	MinionSenderConfig.hideBackground = MinionSenderUISettings.window.hideBackground
end

function MinionSender.AE.UpgradeVersion ()
	if MinionSenderUISettings.flags ~= nil then MinionSenderUISettings.flags = nil end
	if MinionSenderUISettings.window.scale == nil then MinionSenderUISettings.window.scale = 100 end
	if MinionSenderUISettings.window.hideBackground == nil then MinionSenderUISettings.window.hideBackground = false end

	for k, v in pairs(MinionSenderConfig.ruleset or {}) do
		for rk, rv in pairs(v.rules or {}) do
			if rv.match == nil then rv.match = 1 end
		end
	end
end

function MinionSender.AE.FixSettings ()
	MinionSenderUISettings.button.x = math.floor(UIParent:GetWidth() / 2)
	MinionSenderUISettings.button.y = math.floor(UIParent:GetHeight() / 2)
	MinionSenderUISettings.window.x = math.floor(UIParent:GetWidth() / 4)
	MinionSenderUISettings.window.y = math.floor(UIParent:GetHeight() / 4)
	MinionSenderUISettings.window.visible = true
	MinionSenderUISettings.window.scale = 100
	MinionSenderUISettings.window.hideBackground = false

	if not MINIMAPDOCKER then
		if MinionSender.AE.UI.Button then MinionSender.AE.UI.Button:SetPoint("TOPLEFT", UIParent, "TOPLEFT", MinionSenderUISettings.button.x, MinionSenderUISettings.button.y) end
	end
	if MinionSender.AE.UI.Window then MinionSender.AE.UI.Window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", MinionSenderUISettings.window.x, MinionSenderUISettings.window.y) end
end

function MinionSender.AE.UpdateColor (param)
	if MinionSender.AE.UI.Indicators[string.sub(param, 6)] then
		MinionSender.AE.UI.Indicators[string.sub(param, 6)].UpdateColor(MinionSenderConfig[param])
	end
	MinionSender.Menu.Stats.UpdateColor()
end

function MinionSender.AE.UpdateInfo ()
	MinionSender.AE.Data.info = MinionSender.Minion.GetInfo()
	MinionSender.Menu.Stats.Update()

	MinionSender.AE.UI.Indicators.Available:SetText(iif(MinionSender.AE.Data.info.slots == 0, "-", tostring(MinionSender.AE.Data.info.slots)))
	MinionSender.AE.UI.Indicators.Working:SetText(iif(MinionSender.AE.Data.info.working == 0, "-", tostring(MinionSender.AE.Data.info.working)))
	MinionSender.AE.UI.Indicators.Finished:SetText(iif(MinionSender.AE.Data.info.finished == 0, "-", tostring(MinionSender.AE.Data.info.finished)))
end

function MinionSender.AE.UpdateTimer ()
	MinionSender.Menu.Stats.UpdateTimer()
	MinionSender.AE.UI.Indicators.Timer.UpdateText({ text = TimeToString(MinionSender.AE.Data.info.completion - Inspect.Time.Server()) })
end

function MinionSender.AE.Action (handle)
	local info = MinionSender.Minion.GetInfo()

	if MinionSender.Minion.ActionClaim(info) then return end
	if MinionSender.Minion.ActionSend(info) then return end
	if MinionSenderConfig.operateDimension and MinionSender.Inventory.ActionOperateDimension() then return end
	if MinionSenderConfig.dropUnstableBox and MinionSender.Inventory.ActionDropUnstable() then return end
end
