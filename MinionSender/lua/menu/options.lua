MinionSender.Menu.Options = {
	common = { type = "inner", description = {
		list = {
			{ type = "separator" },
			{ type = "checkbox", text = "OptionClaimAttractors", param = "claimAttractors", submenu = { 
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionClaimArtifact", param = "claimArtifact", icon = "Minion_I3C.dds" },
					{ type = "checkbox", text = "OptionClaimAssassination", param = "claimAssassination", icon = "Minion_I3E.dds" },
					{ type = "checkbox", text = "OptionClaimDimension", param = "claimDimension", icon = "Minion_I3A.dds" },
					{ type = "checkbox", text = "OptionClaimDiplomacy", param = "claimDiplomacy", icon = "Minion_I36.dds" },
					{ type = "checkbox", text = "OptionClaimHarvesting", param = "claimHarvest", icon = "Minion_I38.dds" },
					{ type = "checkbox", text = "OptionClaimHunting", param = "claimHunting", icon = "Minion_I34.dds" },
				} } },
			{ type = "checkbox", text = "OptionShuffle", param = "shuffle", submenu = { 
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionShuffleArtifact", param = "shuffleArtifact", icon = "Minion_I3C.dds" },
					{ type = "checkbox", text = "OptionShuffleAssassination", param = "shuffleAssassination", icon = "Minion_I3E.dds" },
					{ type = "checkbox", text = "OptionShuffleDimension", param = "shuffleDimension", icon = "Minion_I3A.dds" },
					{ type = "checkbox", text = "OptionShuffleDiplomacy", param = "shuffleDiplomacy", icon = "Minion_I36.dds" },
					{ type = "checkbox", text = "OptionShuffleHarvesting", param = "shuffleHarvest", icon = "Minion_I38.dds" },
					{ type = "checkbox", text = "OptionShuffleHunting", param = "shuffleHunting", icon = "Minion_I34.dds" },
					{ type = "empty" },
					{ type = "checkbox", text = "OptionShuffleChain", param = "shuffleChain", icon = "Minion_I1BA.dds", iconOffset = 3 },
					{ type = "checkbox", text = "OptionShuffleRare", param = "shuffleRare", icon = "target_portrait_LootPinata.png.dds", iconOffset = 1, min = 1, max = 20, step = 1, display = "shuffleRareThreshold" },
				} } },
			{ type = "checkbox", text = "OptionOperateDimension", param = "operateDimension", submenu = {
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionDestroyDimensionCommon", param = "destroyDimensioncommon" },
					{ type = "checkbox", text = "OptionDestroyDimensionUncommon", param = "destroyDimensionuncommon" },
					{ type = "checkbox", text = "OptionDestroyDimensionRare", param = "destroyDimensionrare" },
					{ type = "checkbox", text = "OptionDestroyDimensionEpic", param = "destroyDimensionepic" },
					{ type = "checkbox", text = "OptionDestroyDimensionRelic", param = "destroyDimensionrelic" },
					{ type = "empty" },
					{ type = "checkbox", text = "OptionOpenDimensionContainer", param = "openDimensionContainer" },
					{ type = "checkbox", text = "OptionDestroyDimensionContainer", param = "destroyDimensionContainer" },
					{ type = "checkbox", text = "OptionDestroyDimensionKey", param = "destroyDimensionKey" },
				} } },
			{ type = "separator" },
			{ type = "text", text = "OptionSettings", submenu = {
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionActionLeft", param = "actionLeft" },
					{ type = "checkbox", text = "OptionActionRight", param = "actionRight" },
					{ type = "checkbox", text = "OptionActionMiddle", param = "actionMiddle" },
					{ type = "checkbox", text = "OptionActionMouse4", param = "actionMouse4" },
					{ type = "checkbox", text = "OptionActionMouse5", param = "actionMouse5" },
					{ type = "checkbox", text = "OptionActionWheel", param = "actionWheel" },
					{ type = "empty" },
					{ type = "checkbox", text = "OptionShowTooltip", param = "showTooltip" },
					{ type = "slider", text = "OptionScale", param = "scale", min = 50, max = 200, step = 10 },
					{ type = "checkbox", text = "OptionHideBackground", param = "hideBackground" },
					{ type = "empty" },
					{ type = "text", text = "OptionAnounceSettings", submenu = {
						properties = { width = 300, offsetX = -15, offsetY = -36 },
						list = {
							{ type = "checkbox", text = "OptionAnnounceSend", param = "announceSend" },
							{ type = "checkbox", text = "OptionAnnounceClaim", param = "announceClaim" },
							{ type = "checkbox", text = "OptionAnnounceShuffle", param = "announceShuffle" },
						} } },
					{ type = "text", text = "OptionColorSettings", submenu = {
						properties = { width = 200, offsetX = -15, offsetY = -36 },
						list = {
							{ type = "color", text = "OptionColorAvailable", param = "colorAvailable" },
							{ type = "color", text = "OptionColorWorking", param = "colorWorking" },
							{ type = "color", text = "OptionColorFinished", param = "colorFinished" },
							{ type = "color", text = "OptionColorTimer", param = "colorTimer" },
							{ type = "color", text = "OptionColorAnnouncement", param = "colorAnnouncement" },
						} } },
					{ type = "text", text = "OptionLanguage", submenu = {
						properties = { width = 250, offsetX = -15, offsetY = -36 },
						list = {
							{ type = "radio", text = "OptionLanguageAuto", param = "language", value = "Auto" },
							{ type = "empty" },
							{ type = "radio", text = "OptionLanguageEnglish", param = "language", value = "English" },
							{ type = "radio", text = "OptionLanguageGerman", param = "language", value = "German" },
							{ type = "radio", text = "OptionLanguageFrench", param = "language", value = "French" },
							{ type = "radio", text = "OptionLanguageRussian", param = "language", value = "Russian" },
						} } },
				} } },
			{ type = "text", text = "OptionMore", submenu = {
				properties = { width = 300, offsetX = -15, offsetY = -36 },
				list = {
					{ type = "checkbox", text = "OptionChainReserve", param = "chainReserve" },
					{ type = "checkbox", text = "OptionDropUnstableBox", param = "dropUnstableBox" },
				} } },
		}
	} }
}

function MinionSender.Menu.Options.GetValue (param)
	return tableGetByPath (MinionSenderConfig, param)
end

function MinionSender.Menu.Options.SetValue (param, value)
	tableSetByPath (MinionSenderConfig, param, value)

	if param == "language" then MinionSender.AE.SetLanguage() end
	if param == "scale" then MinionSender.AE.SetScale() end
	if param == "hideBackground" then MinionSender.AE.ShowBackground() end
	if type(param) == "string" and string.sub(param, 1, 5) == "color" then MinionSender.AE.UpdateColor(param) end

	if param == "destroyDimensionContainer" and value then MinionSender.Menu.Options.SetValue("openDimensionContainer", false) end
	if param == "openDimensionContainer" and value then MinionSender.Menu.Options.SetValue("destroyDimensionContainer", false) end

	if param == "actionLeft" and value then MinionSender.Menu.Options.SetValue("actionRight", false) end
	if param == "actionRight" and value then MinionSender.Menu.Options.SetValue("actionLeft", false) end

	if param == "shuffleRareThreshold" then MinionSender.Minion.Attempts = value end

	if MinionSender.Menu.Options.Simple.window then MinionSender.Menu.Options.Simple.window.UpdateDependencies(param) end
	if MinionSender.Menu.Options.Advanced.window then MinionSender.Menu.Options.Advanced.window.UpdateDependencies(param) end
end

function MinionSender.Menu.Options.OnClick (handler, param)
	if param.param == "options" then
		MinionSender.Menu.Options[MinionSenderConfig.options].SetVisible(false)
		MinionSenderConfig.options = param.value
		MinionSender.Menu.Options[MinionSenderConfig.options].SetVisible(true)
	end
end

function MinionSender.Menu.Options.GetCustom (info)
	if info.type == "custom" and info.param == "options" then return MinionSender.Menu.Options.common end
end