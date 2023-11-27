MinionSender.Menu.Options.Advanced = { 
	description = {
		properties = { width = 320, offsetX = -26 },
		list = {
			{ type = "label", text = "OptionsAdvanced", x = 12, y = 5, height = 30, size = 16, color = { 216, 203, 153 } },
			{ type = "separator" },
			{ type = "custom", param = "rulesetList" },
			{ type = "empty" },
			{ type = "button", text = "OptionsAddRuleset", param = "addRuleset", icon = "vfx_ui_mob_tag_heal_mini.png.dds" },
			{ type = "custom", param = "options" },
			{ type = "button", text = "OptionSwitchSimple", param = "options", value = "Simple" },
			{ type = "empty" },
			{ type = "checkbox", text = "OptionLockWindow", param = "lockWindow" },
		}
	}
}

function MinionSender.Menu.Options.Advanced.Init (parent)
	MinionSender.Menu.Options.Advanced.window = MinionSender.GUI.Extended.CreateMenu(parent, MinionSender.Menu.Options.Advanced.description,
	{
		GetValue = MinionSender.Menu.Options.GetValue, 
		SetValue = MinionSender.Menu.Options.SetValue, 
		OnClick = MinionSender.Menu.Options.Advanced.OnClick, 
		OnEdit = MinionSender.Menu.Options.Advanced.OnEdit, 
		GetCustom = MinionSender.Menu.Options.Advanced.GetCustom
	}, "HORIZONTAL")
end

function MinionSender.Menu.Options.Advanced.SetVisible (flag)
	return MinionSender.Menu.Options.Advanced.window.ctrl.SetVis(flag)
end

function MinionSender.Menu.Options.Advanced.GetVisible ()
	return MinionSender.Menu.Options.Advanced.window.ctrl:GetVisible()
end

function MinionSender.Menu.Options.Advanced.UpdateText ()
	if MinionSender.Menu.Options.Advanced.window then MinionSender.Menu.Options.Advanced.window.UpdateText() end
end

function MinionSender.Menu.Options.Advanced.OnClick (handler, param)
	MinionSender.Menu.Options.OnClick(handler, param)

	local validate = function ()
		if MinionSenderConfig.ruleset[MinionSenderConfig.rule] == nil then
			MinionSenderConfig.rule = tableFirst(MinionSenderConfig.ruleset)
			MinionSender.Menu.Options.Advanced.window.UpdateDependencies("rule")
		end
	end

	if param.param == "addRuleset" then
		local id = (tableLast(MinionSenderConfig.ruleset) or 0) + 1
		MinionSenderConfig.ruleset[id] = { name = "OptionsCustomRuleset", rules = { { level = { min = 1, max = 25 }, filtercommon = true, filteruncommon = true, filterrare = true, filterepic = true, filterattractor = true, duration = 1, staminaReserve = 0, priority = 1, match0 = false, match1 = true, match2 = true } } }
		MinionSender.Menu.Options.Advanced.window.ctrl.AddItem(MinionSender.Menu.Options.Advanced.GetRuleSet(id, MinionSenderConfig.ruleset[id]), nil, tableLength(MinionSenderConfig.ruleset) + 3)
		MinionSender.Menu.Options.Advanced.window.ctrl.SetVis(true)
		validate()
	end

	if param.param == "editRuleset" then
		local info = MinionSenderConfig.ruleset[param.value]
		param.field.Show(info.text or MinionSender.Data.Language.Current[info.name])
	end

	if param.param == "deleteRuleset" then
		MinionSenderConfig.ruleset[param.value] = nil
		MinionSender.Menu.Options.Advanced.window.ctrl.DeleteChild(param.parent)
		MinionSender.Menu.Options.Advanced.window.ctrl.SetVis(true)
		validate()
	end

	if param.param == "addRule" then
		local ctrl = MinionSender.Menu.Options.Advanced.FindRuleSet(param.value)
		local id = (tableLast(MinionSenderConfig.ruleset[param.value].rules) or 0) + 1
		MinionSenderConfig.ruleset[param.value] .rules[id] = { level = { min = 1, max = 25 }, filtercommon = true, filteruncommon = true, filterrare = true, filterepic = true, filterattractor = true, duration = 1, staminaReserve = 0, priority = 1, match0 = false, match1 = true, match2 = true }

		ctrl.info.submenu.AddItem(MinionSender.Menu.Options.Advanced.GetRule(param.value, id), nil, tableLength(MinionSenderConfig.ruleset[param.value].rules) + 1)
		ctrl.info.submenu.SetVis(true)
		validate()
	end

	if param.param == "deleteRule" then
		local ctrl = MinionSender.Menu.Options.Advanced.FindRuleSet(param.value.rulesetId)
		MinionSenderConfig.ruleset[param.value.rulesetId].rules[param.value.ruleId] = nil
		ctrl.info.submenu.DeleteChild(param.parent)
		ctrl.info.submenu.SetVis(true)
	end
end

function MinionSender.Menu.Options.Advanced.OnEdit (handler, param)
	local text = handler:GetText()
	MinionSenderConfig.ruleset[param.value].text = iif(text == "", nil, text)
	param.frame.UpdateText(MinionSender.Menu.Options.Advanced.GetRuleSet(param.value, MinionSenderConfig.ruleset[param.value]))
end

function MinionSender.Menu.Options.Advanced.GetCustom (info)
	if info.type == "custom" and info.param == "rulesetList" then
		local ret = { type = "inner", description = { list = { } } }
		for k, v in pairsByKeys(MinionSenderConfig.ruleset) do
			table.insert(ret.description.list, MinionSender.Menu.Options.Advanced.GetRuleSet(k, v))
		end
		return ret
	end

	if info.type == "custom" and info.param == "ruleset" then
		local ret = { type = "inner", description = { list = { } } }
		for k, v in pairsByKeys(MinionSenderConfig.ruleset[info.value].rules) do
			table.insert(ret.description.list, MinionSender.Menu.Options.Advanced.GetRule(info.value, k))
		end
		return ret
	end

	if info.type == "custom" and info.param == "rule" then
		return MinionSenderConfig.ruleset[info.value.rulesetId].rules[info.value.ruleId]
	end

	return MinionSender.Menu.Options.GetCustom(info)
end

function MinionSender.Menu.Options.Advanced.GetRuleSet (id, item)
	return { type = "ruleset", text = item.text or item.name, isLocalized = item.text == nil, param = "rule", value = id, submenu = {
			properties = { width = 350, offsetX = -15, offsetY = -36 },
			list = { 
				{ type = "custom", param = "ruleset", value = id },
				{ type = "empty" },
				{ type = "button", text = "OptionsAddRule", param = "addRule", value = id, icon = "vfx_ui_mob_tag_heal_mini.png.dds" }
			} } }
end

function MinionSender.Menu.Options.Advanced.GetRule (rulesetId, ruleId)
	return { type = "rule", text = "RuleLevel", isLocalized = true, height = 40, value = { rulesetId = rulesetId, ruleId = ruleId }, param = { "ruleset", rulesetId, "rules", ruleId }, submenu = {
			properties = { width = 350, offsetX = -15, offsetY = -36 },
			list = { 
				{ type = "radio", text = "OptionDurationExperience", param = { "ruleset", rulesetId, "rules", ruleId, "duration" }, value = 1 },
				{ type = "radio", text = "OptionDurationShort", param = { "ruleset", rulesetId, "rules", ruleId, "duration" }, value = 2 },
				{ type = "radio", text = "OptionDurationLong", param = { "ruleset", rulesetId, "rules", ruleId, "duration" }, value = 3 },
				{ type = "radio", text = "OptionDurationPremium", param = { "ruleset", rulesetId, "rules", ruleId, "duration" }, value = 4 },
				{ type = "empty" },
				{ type = "slider", text = "OptionLevel", param = { "ruleset", rulesetId, "rules", ruleId, "level" }, min = 1, max = 25, count = 2 },
				{ type = "slider", text = "OptionStamina", param = { "ruleset", rulesetId, "rules", ruleId, "staminaReserve" }, min = 0, max = 30 },
				{ type = "empty" },
				{ type = "radio", text = "OptionPriority1", param = { "ruleset", rulesetId, "rules", ruleId, "priority" }, value = 1 },
				{ type = "radio", text = "OptionPriority2", param = { "ruleset", rulesetId, "rules", ruleId, "priority" }, value = 2 },
				{ type = "radio", text = "OptionPriority3", param = { "ruleset", rulesetId, "rules", ruleId, "priority" }, value = 3 },
				{ type = "radio", text = "OptionPriority4", param = { "ruleset", rulesetId, "rules", ruleId, "priority" }, value = 4 },
				{ type = "empty" },
				{ type = "checkbox", text = "OptionMatch0", param = { "ruleset", rulesetId, "rules", ruleId, "match0" } },
				{ type = "checkbox", text = "OptionMatch1", param = { "ruleset", rulesetId, "rules", ruleId, "match1" } },
				{ type = "checkbox", text = "OptionMatch2", param = { "ruleset", rulesetId, "rules", ruleId, "match2" } },
				{ type = "empty" },
				{ type = "checkbox", text = "OptionFilterCommon", param = { "ruleset", rulesetId, "rules", ruleId, "filtercommon" } },
				{ type = "checkbox", text = "OptionFilterUncommon", param = { "ruleset", rulesetId, "rules", ruleId, "filteruncommon" } },
				{ type = "checkbox", text = "OptionFilterRare", param = { "ruleset", rulesetId, "rules", ruleId, "filterrare" } },
				{ type = "checkbox", text = "OptionFilterEpic", param = { "ruleset", rulesetId, "rules", ruleId, "filterepic" } },
				{ type = "checkbox", text = "OptionFilterAttractor", param = { "ruleset", rulesetId, "rules", ruleId, "filterattractor" } },
			} } }
end

function MinionSender.Menu.Options.Advanced.FindRuleSet (id)
	local ctrl
	for k, v in pairs(MinionSender.Menu.Options.Advanced.window.ctrl.childs) do
		if v.info and v.info.param == "rule" and v.info.value == id then
			ctrl = v
		end
	end
	return ctrl
end