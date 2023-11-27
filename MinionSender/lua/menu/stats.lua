MinionSender.Menu.Stats = {
	description = {
		properties = { width = 234, height = 280, offsetX = -10, offsetY = -21, transparent = true },
		list = {
			{ type = "label", text = "StatsByLevel", position = "absolute", x = 20, y = 26 },
			{ type = "label", text = "StatsByRarity", position = "absolute", x = 134, y = 26 },
			{ type = "label", text = "StatsByStats", position = "absolute", x = 20, y = 90 },
			{ type = "label", text = "StatsLevel1", param = "Level1", position = "absolute", x = 20, y = 180 },
			{ type = "label", text = "StatsLevel25", param = "Level25", position = "absolute", x = 20, y = 200 },
			{ type = "label", text = "StatsLevelCount", param = "Level1Count", position = "absolute", x = 115, y = 180, align = "TOPCENTER", color = { 216, 203, 153 } },
			{ type = "label", text = "StatsLevelCount", param = "Level25Count", position = "absolute", x = 115, y = 200, align = "TOPCENTER", color = { 216, 203, 153 } },
			{ type = "label", text = "StatsStaminaValue", param = "Stamina1", position = "absolute", x = 214, y = 180, align = "TOPRIGHT", color = { 216, 203, 153 } },
			{ type = "label", text = "StatsStaminaValue", param = "Stamina25", position = "absolute", x = 214, y = 200, align = "TOPRIGHT", color = { 216, 203, 153 } },
			{ type = "chart", param = "byLevel", position = "absolute", x = 20, y = 46, prop = { w = 80, h = 30, lw = 2, ls = 1, m = 3, legend = false, description = {
				{ color = { 255, 0, 0 } }, 
				{ color = { 255, 21, 0 } },
				{ color = { 255, 42, 0 } },
				{ color = { 255, 63, 0 } },
				{ color = { 255, 84, 0 } },
				{ color = { 255, 105, 0 } },
				{ color = { 255, 126, 0 } },
				{ color = { 255, 147, 0 } },
				{ color = { 255, 168, 0 } },
				{ color = { 255, 189, 0 } },
				{ color = { 255, 210, 0 } },
				{ color = { 255, 231, 0 } },
				{ color = { 255, 255, 0 } },
				{ color = { 231, 255, 0 } },
				{ color = { 210, 255, 0 } },
				{ color = { 189, 255, 0 } },
				{ color = { 168, 255, 0 } },
				{ color = { 147, 255, 0 } },
				{ color = { 126, 255, 0 } },
				{ color = { 105, 255, 0 } },
				{ color = { 84, 255, 0 } },
				{ color = { 63, 255, 0 } },
				{ color = { 42, 255, 0 } },
				{ color = { 21, 255, 0 } },
				{ color = { 0, 255, 0 } }
			} } },
			{ type = "chart", param = "byRarity", position = "absolute", x = 134, y = 46, prop = { w = 80, h = 30, lw = 14, ls = 6, m = 3, legend = true, description = {
				{ color = MinionSender.AE.RarityColor.common }, 
				{ color = MinionSender.AE.RarityColor.uncommon },
				{ color = MinionSender.AE.RarityColor.rare },
				{ color = MinionSender.AE.RarityColor.epic }
			} } },
			{ type = "chart", param = "byStats", position = "absolute", x = 20, y = 130, prop = { w = 194, h = 30, lw = 12, ls = 2, m = 3, legend = true, description = {
				{ color = { 255, 255, 200 }, icon = "Minion_I3C.dds", param = "Artifact" },
				{ color = { 255, 255, 200 }, icon = "Minion_I3E.dds", param = "Assassination" },
				{ color = { 255, 255, 200 }, icon = "Minion_I3A.dds", param = "Dimension" },
				{ color = { 255, 255, 200 }, icon = "Minion_I36.dds", param = "Diplomacy" },
				{ color = { 255, 255, 200 }, icon = "Minion_I38.dds", param = "Harvest" },
				{ color = { 255, 255, 200 }, icon = "Minion_I34.dds", param = "Hunting" },
				{ w = 2 },
				{ color = { 200, 200, 200 }, icon = "Minion_I35.dds", param = "Air" },
				{ color = { 230, 160, 80 }, icon = "Minion_I33.dds", param = "Earth" },
				{ color = { 35, 120, 255 }, icon = "Minion_I39.dds", param = "Water" },
				{ color = { 205, 45, 0 }, icon = "Minion_I37.dds", param = "Fire" },
				{ color = { 165, 70, 240 }, icon = "Minion_I31.dds", param = "Death" },
				{ color = { 110, 195, 20 }, icon = "Minion_I30.dds", param = "Life" },
				{ w = 2 },
				{ color = { 180, 0, 0 }, icon = "minion_magnet.png.dds", param = "Attractor" },
			} } },
		}
	},
	Slots = { }
}

function MinionSender.Menu.Stats.Init (parent)
	MinionSender.Menu.Stats.window = MinionSender.GUI.Extended.CreateMenu(parent, MinionSender.Menu.Stats.description, {
		GetValue = MinionSender.Menu.Stats.GetValue
	})
end

function MinionSender.Menu.Stats.SetVisible (flag)
	if MinionSenderConfig.showTooltip then
		local val = MinionSender.Menu.Stats.window.ctrl.SetVis(flag)
		MinionSender.AE.UpdateInfo()
		return val
	end
end

function MinionSender.Menu.Stats.GetVisible ()
	return MinionSender.Menu.Stats.window.ctrl:GetVisible()
end

function MinionSender.Menu.Stats.UpdateText ()
	if MinionSender.Menu.Stats.window then MinionSender.Menu.Stats.window.UpdateText() end
end

function MinionSender.Menu.Stats.Update ()
	if MinionSender.Menu.Stats.GetVisible() then
		MinionSender.Menu.Stats.window.UpdateDependencies("byLevel")
		MinionSender.Menu.Stats.window.UpdateDependencies("byRarity")
		MinionSender.Menu.Stats.window.UpdateDependencies("byStats")
		MinionSender.Menu.Stats.window.UpdateDependencies("Level1Count")
		MinionSender.Menu.Stats.window.UpdateDependencies("Level25Count")
		MinionSender.Menu.Stats.window.UpdateDependencies("Stamina1")
		MinionSender.Menu.Stats.window.UpdateDependencies("Stamina25")
	end
end

function MinionSender.Menu.Stats.GetValue (param)
	if param == "#byLevel" then return ((MinionSender.AE.Data.info or {}).minions or {}).level end
	if param == "#byRarity" then return ((MinionSender.AE.Data.info or {}).minions or {}).rarity end
	if param == "#byStats" then return ((MinionSender.AE.Data.info or {}).minions or {}).stats end
	if param == "#Level1Count" then return ((MinionSender.AE.Data.info or {}).minions or {}).level1 end
	if param == "#Level25Count" then return ((MinionSender.AE.Data.info or {}).minions or {}).level25 end
	if param == "#Stamina1" then return { (((MinionSender.AE.Data.info or {}).minions or {}).stamina1 or {}).cur or 0, (((MinionSender.AE.Data.info or {}).minions or {}).stamina1 or {}).max or 0 } end
	if param == "#Stamina25" then return { (((MinionSender.AE.Data.info or {}).minions or {}).stamina25 or {}).cur or 0, (((MinionSender.AE.Data.info or {}).minions or {}).stamina25 or {}).max or 0 } end
end

function MinionSender.Menu.Stats.UpdateTimer ()
	if MinionSender.AE.Data.info then
		local count = MinionSender.AE.Data.info.slots + MinionSender.AE.Data.info.working + MinionSender.AE.Data.info.finished

		if #MinionSender.Menu.Stats.Slots < count then
			local parent = MinionSender.Menu.Stats.window.ctrl

			while #MinionSender.Menu.Stats.Slots < count do
				local frame = MinionSender.GUI.Basic.CreateFrame(parent, { 10, 10 }, 5)
				frame:SetBackgroundColor(0, 0, 0, .5)
				MinionSender.GUI.Basic.CreateCanvas(frame, { { 0, 0 }, { 0, 0, "BOTTOMRIGHT" } }, 10, { }, MinionSender.GUI.Extended.Canvas.path.rectangle, nil, MinionSender.GUI.Extended.Canvas.stroke.border)
				MinionSender.GUI.Basic.CreateTexture(frame, { { 2, 2 }, { -1, -1, "BOTTOMRIGHT" } }, 10, "gh.png")
				frame.working = MinionSender.GUI.Basic.CreateFrame(frame, { { 2, 2 }, { 2, -1, "BOTTOMLEFT" } }, 9)
				frame.complete = MinionSender.GUI.Basic.CreateFrame(frame, { { 2, 2 }, { -1, -1, "BOTTOMRIGHT" } }, 9)
				frame.text = MinionSender.GUI.Basic.CreateText(frame, { { 0, -1, "TOPCENTER", "BOTTOMCENTER" } }, 10, { fontSize = 9, fontColor = { 153, 154, 122 } })
				table.insert(MinionSender.Menu.Stats.Slots, frame)
			end

			local w = math.floor(200 / #MinionSender.Menu.Stats.Slots - 6)
			local o = (240 - (w + 6) * #MinionSender.Menu.Stats.Slots) / 2

			for k, v in pairs(MinionSender.Menu.Stats.Slots) do
				v:SetPoint("TOPLEFT", parent, "TOPLEFT", o + (k - 1) * (w + 6), 230)
				v:SetWidth(w - 1)
			end

			MinionSender.Menu.Stats.UpdateColor()
		end

		for k, v in pairs(MinionSender.Menu.Stats.Slots) do
			if MinionSender.AE.Data.info.workingList[k] then
				if MinionSender.AE.Data.info.workingList[k].completion then
					local w = v:GetWidth() - 2
					v.working:SetWidth(math.min(w, math.max(1, w - (MinionSender.AE.Data.info.workingList[k].completion - Inspect.Time.Server()) / MinionSender.AE.Data.info.workingList[k].duration * w)))
				end
				v.working:SetVisible(MinionSender.AE.Data.info.workingList[k].completion ~= nil)
				v.complete:SetVisible(MinionSender.AE.Data.info.workingList[k].completion == nil)
				v.text.UpdateText({ text = TimeToString(MinionSender.AE.Data.info.workingList[k].duration) })
			else
				v.working:SetVisible(false)
				v.complete:SetVisible(false)
				v.text.UpdateText({ text = "" })
			end
		end
	end
end

function MinionSender.Menu.Stats.UpdateColor ()
	for k, v in pairs(MinionSender.Menu.Stats.Slots) do
		v.working:SetBackgroundColor(MinionSenderConfig.colorWorking[1] / 255, MinionSenderConfig.colorWorking[2] / 255, MinionSenderConfig.colorWorking[3] / 255)
		v.complete:SetBackgroundColor(MinionSenderConfig.colorFinished[1] / 255, MinionSenderConfig.colorFinished[2] / 255, MinionSenderConfig.colorFinished[3] / 255)
	end
end