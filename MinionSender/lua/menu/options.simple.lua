MinionSender.Menu.Options.Simple = { 
	description = {
		properties = { width = 320, offsetX = -26 },
		list = {
			{ type = "label", text = "OptionsSimple", x = 12, y = 5, height = 30, size = 16, color = { 216, 203, 153 } },
			{ type = "separator" },
			{ type = "radio", text = "OptionDurationExperience", param = "duration", value = 1 },
			{ type = "radio", text = "OptionDurationShort", param = "duration", value = 2 },
			{ type = "radio", text = "OptionDurationLong", param = "duration", value = 3 },
			{ type = "radio", text = "OptionDurationPremium", param = "duration", value = 4 },
			{ type = "empty" },
			{ type = "slider", text = "OptionLevel", param = "level", min = 1, max = 25, count = 2 },
			{ type = "slider", text = "OptionStamina", param = "staminaReserve", min = 0, max = 30 },
			{ type = "empty" },
			{ type = "text", text = "OptionPriority", submenu = {
				properties = { width = 350, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "radio", text = "OptionPriority1", param = "priority", value = 1 },
					{ type = "radio", text = "OptionPriority2", param = "priority", value = 2 },
					{ type = "radio", text = "OptionPriority3", param = "priority", value = 3 },
					{ type = "radio", text = "OptionPriority4", param = "priority", value = 4 },
				} } },
			{ type = "text", text = "OptionMatch", submenu = {
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionMatch0", param = "match0" },
					{ type = "checkbox", text = "OptionMatch1", param = "match1" },
					{ type = "checkbox", text = "OptionMatch2", param = "match2" },
				} } },
			{ type = "text", text = "OptionFilter", submenu = {
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionFilterCommon", param = "filtercommon" },
					{ type = "checkbox", text = "OptionFilterUncommon", param = "filteruncommon" },
					{ type = "checkbox", text = "OptionFilterRare", param = "filterrare" },
					{ type = "checkbox", text = "OptionFilterEpic", param = "filterepic" },
					{ type = "checkbox", text = "OptionFilterAttractor", param = "filterattractor" },
				} } },
			{ type = "custom", param = "options" },
			{ type = "button", text = "OptionSwitchAdvanced", param = "options", value = "Advanced" },
			{ type = "empty" },
			{ type = "checkbox", text = "OptionLockWindow", param = "lockWindow" },
		}
	}
}

function MinionSender.Menu.Options.Simple.Init (parent)
	MinionSender.Menu.Options.Simple.window = MinionSender.GUI.Extended.CreateMenu(parent, MinionSender.Menu.Options.Simple.description, 
	{
		GetValue = MinionSender.Menu.Options.GetValue, 
		SetValue = MinionSender.Menu.Options.SetValue, 
		OnClick = MinionSender.Menu.Options.OnClick,
		GetCustom = MinionSender.Menu.Options.GetCustom
	}, "HORIZONTAL")
end

function MinionSender.Menu.Options.Simple.SetVisible (flag)
	return MinionSender.Menu.Options.Simple.window.ctrl.SetVis(flag)
end

function MinionSender.Menu.Options.Simple.GetVisible ()
	return MinionSender.Menu.Options.Simple.window.ctrl:GetVisible()
end

function MinionSender.Menu.Options.Simple.UpdateText ()
	if MinionSender.Menu.Options.Simple.window then MinionSender.Menu.Options.Simple.window.UpdateText() end
end
