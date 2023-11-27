--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            Lifeismystery@yandex.ru
                           Lifeismystery: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.4.92
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local gadgetIndex = 0

MoneyGadgets = {
	Currencies = {},
	curIcon = {},
	curText = {},
	curName = {},
	isRendered = false,
	wrapper = nil,
	addonConfiguration = nil
}

function MoneyGadgets.pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then
				return nil
			else
				return a[i], t[a[i]]
			end
		end
	return iter
end

function MoneyGadgets.ScanCurrencies()
	for k,v in pairs(Inspect.Currency.Detail(Inspect.Currency.List())) do
    	local category = Inspect.Currency.Category.Detail(v.category).name
    	if MoneyGadgets.Currencies[category] == nil then MoneyGadgets.Currencies[category] = {} end
    	MoneyGadgets.Currencies[category][v.name] = {value=v.stack, icon=v.icon}
	end	
end

local function Create(configuration)
	MoneyGadgets.wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtCurrencies"), WT.Context)
	MoneyGadgets.wrapper:SetHeight(30)
	MoneyGadgets.wrapper:SetWidth(700)
	MoneyGadgets.wrapper:SetSecureMode("restricted")
	
	if configuration.showBackground == nil then
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", MoneyGadgets.wrapper, 1, 0, 0, 0, 1)
		MoneyGadgets.wrapper:SetBackgroundColor(0.07,0.07,0.07,0.85)		
	elseif configuration.showBackground == true then
			Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", MoneyGadgets.wrapper, 1, 0, 0, 0, 1)
		if configuration.BackgroundColor == nil then
			configuration.BackgroundColor = {0.07,0.07,0.07,0.85}
			MoneyGadgets.wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		else 
			MoneyGadgets.wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		end
	else 	
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", MoneyGadgets.wrapper, 1, 0, 0, 0, 0)
		MoneyGadgets.wrapper:SetBackgroundColor(0,0,0,0)
	end

	MoneyGadgets.addonConfiguration = configuration
	return MoneyGadgets.wrapper, { resizable={50, 30, 2560, 30} }
end

function MoneyGadgets.CurrencyAll (handle, currencyAll)
	if MoneyGadgets.isRendered then
		local len = string.len(Inspect.Currency.Detail("coin").stack)	
		if len > 0 then
			MoneyGadgets.MoneySilverFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-1, len))	
			if len > 2 then
				MoneyGadgets.MoneyGoldFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-3, len-2))
				if len > 4 then
					MoneyGadgets.MoneyPlatFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, 1, len-4))
				else
					MoneyGadgets.MoneyPlatFrame:SetText("0")
				end
			else
				MoneyGadgets.MoneyGoldFrame:SetText("0")
				MoneyGadgets.MoneyPlatFrame:SetText("0")
			end
		else
			MoneyGadgets.MoneySilverFrame:SetText("0")
			MoneyGadgets.MoneyGoldFrame:SetText("0")
			MoneyGadgets.MoneyPlatFrame:SetText("0")
		end

		MoneyGadgets.ScanCurrencies()
		for k, v in pairs(MoneyGadgets.Currencies) do
			for ik, iv in pairs(v) do
				if k ~= "Coin" or ik == "Credits" then
					if MoneyGadgets.curText[ik] then
					MoneyGadgets.curText[ik]:SetText(iv.value.."")
					end
				end
			end
		end
	end
end
	
local function ConfigDialog(container)	
	MoneyGadgets.ScanCurrencies()		

	local tabs = UI.CreateFrame("SimpleLifeTabView", "tabs", container)
	tabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	tabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	local frmCurrencies = UI.CreateFrame("Frame", "frmCurrencies", tabs.tabContent)
	frmCurrencies:SetPoint("TOPLEFT", container, "TOPLEFT")
	frmCurrencies:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	local frmEvents = UI.CreateFrame("Frame", "frmEvents", tabs.tabContent)
	frmEvents:SetPoint("TOPLEFT", container, "TOPLEFT")
	frmEvents:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	local frmOptions = UI.CreateFrame("Frame", "frmOptions", tabs.tabContent)
	frmOptions:SetPoint("TOPLEFT", container, "TOPLEFT")
	frmOptions:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -20)
	
	tabs:SetTabPosition("top")
	tabs:AddTab("Currencies", frmCurrencies)
	tabs:AddTab("Events", frmEvents)
	tabs:AddTab("Options", frmOptions)
	
	local CoinText = UI.CreateFrame("Text", "CoinText", frmCurrencies)
	CoinText:SetText("Coin")
	CoinText:SetEffectGlow({ strength = 3 })
	CoinText:SetFontColor(0.2,0.4,0.7)
	CoinText:SetFontSize(18)
	--CoinText:SetFont(AddonId, "blank-Bold")
	CoinText:SetPoint("TOPLEFT", frmCurrencies, "TOPLEFT", 10, 4)
	
	lastName = CoinText
	if MoneyGadgets.Currencies.Coin then
	for i,v in pairs(MoneyGadgets.Currencies.Coin) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Coin", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(true)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	SourcestoneText = UI.CreateFrame("Text", "SourcestoneText", frmCurrencies)
	SourcestoneText:SetText("Sourcestone")
	SourcestoneText:SetEffectGlow({ strength = 3 })
	SourcestoneText:SetFontColor(0.2,0.4,0.7)
	SourcestoneText:SetFontSize(18)
	--SourcestoneText:SetFont(AddonId, "blank-Bold")
	SourcestoneText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)

	lastName = SourcestoneText
	if MoneyGadgets.Currencies.Sourcestone then
	for i,v in pairs(MoneyGadgets.Currencies.Sourcestone) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Sourcestone", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(true)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	PvPText = UI.CreateFrame("Text", "PvPText", frmCurrencies)
	PvPText:SetText("PvP")
	PvPText:SetFontColor(0.2,0.4,0.7)
	PvPText:SetEffectGlow({ strength = 3 })
	PvPText:SetFontSize(18)
	--PvPText:SetFont(AddonId, "blank-Bold")
	PvPText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)
	
	lastName = PvPText
	if MoneyGadgets.Currencies.PvP then
	for i,v in pairs(MoneyGadgets.Currencies.PvP) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "PvP", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(false)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	DungeonsText = UI.CreateFrame("Text", "DungeonsText", frmCurrencies)
	DungeonsText:SetText("Dungeons")
	DungeonsText:SetFontColor(0.2,0.4,0.7)
	DungeonsText:SetEffectGlow({ strength = 3 })
	DungeonsText:SetFontSize(18)
	--DungeonsText:SetFont(AddonId, "blank-Bold")
	DungeonsText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)

	lastName = DungeonsText
	if MoneyGadgets.Currencies.Dungeons then
	for i,v in pairs(MoneyGadgets.Currencies.Dungeons) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Dungeons", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(false)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	StoreText = UI.CreateFrame("Text", "Rift Store", frmCurrencies)
	StoreText:SetText("Rift Store")
	StoreText:SetFontColor(0.2,0.4,0.7)
	StoreText:SetEffectGlow({ strength = 3 })
	StoreText:SetFontSize(18)
	--StoreText:SetFont(AddonId, "blank-Bold")
	StoreText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)

	lastName = StoreText
	if MoneyGadgets.Currencies.Store then
	for i,v in pairs(MoneyGadgets.Currencies.Store) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Rift Store", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(false)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	
	RaidsText = UI.CreateFrame("Text", "RaidsText", frmCurrencies)
	RaidsText:SetText("Raids")
	RaidsText:SetFontColor(0.2,0.4,0.7)
	RaidsText:SetEffectGlow({ strength = 3 })
	RaidsText:SetFontSize(18)
	--RaidsText:SetFont(AddonId, "blank-Bold")
	RaidsText:SetPoint("CENTERLEFT", CoinText, "CENTERRIGHT", 200, 0)
	
	lastName = RaidsText	
	if MoneyGadgets.Currencies.Raids then
	for i,v in pairs(MoneyGadgets.Currencies.Raids) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Raids", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(false)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	CraftingText = UI.CreateFrame("Text", "CraftingText", frmCurrencies)
	CraftingText:SetText("Crafting")
	CraftingText:SetFontColor(0.2,0.4,0.7)
	CraftingText:SetEffectGlow({ strength = 3 })
	CraftingText:SetFontSize(18)
	--CraftingText:SetFont(AddonId, "blank-Bold")
	CraftingText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)
	
	lastName = CraftingText
	if MoneyGadgets.Currencies.Crafting then
	for i,v in pairs(MoneyGadgets.Currencies.Crafting) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Crafting", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(false)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	ArtifactsText = UI.CreateFrame("Text", "ArtifactsText", frmCurrencies)
	ArtifactsText:SetText("Artifacts")
	ArtifactsText:SetFontColor(0.2,0.4,0.7)
	ArtifactsText:SetEffectGlow({ strength = 3 })
	ArtifactsText:SetFontSize(18)
	--ArtifactsText:SetFont(AddonId, "blank-Bold")
	ArtifactsText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)

	lastName = ArtifactsText	
	if MoneyGadgets.Currencies.Artifacts then
	for i,v in pairs(MoneyGadgets.Currencies.Artifacts) do
		MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Artifacts", frmCurrencies)
		MoneyGadgets.curName[i]:SetText(i.."")
		MoneyGadgets.curName[i]:SetChecked(false)
		MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
		lastName = MoneyGadgets.curName[i]
	end
	end
	
	PromotionsText = UI.CreateFrame("Text", "TPromotionsText", frmCurrencies)
	PromotionsText:SetText("Promotions")
	PromotionsText:SetFontColor(0.2,0.4,0.7)
	PromotionsText:SetEffectGlow({ strength = 3 })
	PromotionsText:SetFontSize(18)
	--PromotionsText:SetFont(AddonId, "blank-Bold")
	PromotionsText:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 4)	

	lastName = PromotionsText	
	if MoneyGadgets.Currencies.Promotions then
		for i,v in pairs(MoneyGadgets.Currencies.Promotions) do
			MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Promotions", frmCurrencies)
			MoneyGadgets.curName[i]:SetText(i.."")
			MoneyGadgets.curName[i]:SetChecked(false)
			MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
			lastName = MoneyGadgets.curName[i]
		end
	end
	
	EventsText = UI.CreateFrame("Text", "TEventsext", frmEvents)
	EventsText:SetText("Events")
	EventsText:SetFontColor(0.2,0.4,0.7)
	EventsText:SetEffectGlow({ strength = 3 })
	EventsText:SetFontSize(18)
	--EventsText:SetFont(AddonId, "blank-Bold")
	EventsText:SetPoint("TOPLEFT", frmEvents, "TOPLEFT", 10, 4)	

	lastName = EventsText	
	if MoneyGadgets.Currencies.Events then
		for i,v in pairs(MoneyGadgets.Currencies.Events) do
			MoneyGadgets.curName[i] = UI.CreateFrame("SimpleLifeCheckbox", "Events", frmEvents)
			MoneyGadgets.curName[i]:SetText(i.."")
			MoneyGadgets.curName[i]:SetChecked(false)
			MoneyGadgets.curName[i]:SetPoint("TOPLEFT", lastName, "BOTTOMLEFT", 0, 3)
			lastName = MoneyGadgets.curName[i]
		end
	end
	
--------------------------------------------------------------------------------------------

	local GadgetsOptions = UI.CreateFrame("Text", "GadgetsOptions", frmOptions)
	GadgetsOptions:SetText("Gadgets Options")
	GadgetsOptions:SetFontColor(0.2,0.4,0.7)
	GadgetsOptions:SetEffectGlow({ strength = 3 })
	GadgetsOptions:SetFontSize(18)
	--GadgetsOptions:SetFont(AddonId, "blank-Bold")
	GadgetsOptions:SetPoint("TOPLEFT", frmOptions, "TOPLEFT", 10, 4)
	
	showBackground = UI.CreateFrame("SimpleLifeCheckbox", "showBackground", frmOptions)
	showBackground:SetText("Show Background frame")
	showBackground:SetChecked(true)
	showBackground:SetPoint("TOPLEFT", CoinText, "BOTTOMLEFT", 0, 4)

	--BackgroundColor = WT.CreateColourPicker(frmOptions,  0.07,0.07,0.07,0.85)
	BackgroundColor = WT.Control.ColorPicker.Create(frmOptions, "Label", 0.07,0.07,0.07,0.85)

	BackgroundColor:SetPoint("CENTERLEFT", showBackground, "CENTERRIGHT", 0, 0)

end

local function GetConfiguration()
	local config = {
	showBackground = showBackground:GetChecked(),
	BackgroundColor = {BackgroundColor:GetColor()}
	}
	
	for k, v in pairs(MoneyGadgets.Currencies) do
		for ik, iv in pairs(v) do
			config[ik] = MoneyGadgets.curName[ik]:GetChecked()
		end
	end
	return config
end

local function SetConfiguration(config)
	showBackground:SetChecked(WT.Utility.ToBoolean(config.showBackground)) 
	BackgroundColor:SetColor(unpack(config.BackgroundColor))

	for k, v in pairs(MoneyGadgets.Currencies) do
		for ik, iv in pairs(v) do
			MoneyGadgets.curName[ik]:SetChecked(WT.Utility.ToBoolean(config[ik]))
		end
	end
end

function MoneyGadgets.AsyncCreate()
	if Inspect.System.Watchdog() < 0.1 then
		return
	end

	if MoneyGadgets.wrapper ~= nil and MoneyGadgets.addonConfiguration ~= nil then
		if next(Inspect.Currency.List()) ~= nil then
			MoneyGadgets.ScanCurrencies()
	
------------------------------Money-------------------------------------------------------------------
			local MoneyPlatIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneyPlatIcon "), MoneyGadgets.wrapper)
			MoneyPlatIcon:SetTexture("Rift", "coins_platinum.png.dds")
			MoneyPlatIcon:SetPoint("CENTERLEFT", MoneyGadgets.wrapper, "CENTERLEFT", 10, 0)
			MoneyPlatIcon:SetWidth(15)
			MoneyPlatIcon:SetHeight(15)	
	
			MoneyGadgets.MoneyPlatFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneyPlat"), MoneyGadgets.wrapper)
			MoneyGadgets.MoneyPlatFrame:SetText("")
			MoneyGadgets.MoneyPlatFrame:SetFontSize(14)
			MoneyGadgets.MoneyPlatFrame:SetFontColor(1,0.97,0.84,1)
			MoneyGadgets.MoneyPlatFrame:SetPoint("CENTERLEFT", MoneyPlatIcon, "CENTERRIGHT", 0, 0)
	
			local MoneyGoldIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneyGoldIcon "), MoneyGadgets.wrapper)
			MoneyGoldIcon:SetTexture("Rift", "coins_gold.png.dds")
			MoneyGoldIcon:SetPoint("CENTERLEFT", MoneyGadgets.MoneyPlatFrame, "CENTERRIGHT", 0, 0)
			MoneyGoldIcon:SetWidth(15)
			MoneyGoldIcon:SetHeight(15)

			MoneyGadgets.MoneyGoldFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneyGold"), MoneyGadgets.wrapper)
			MoneyGadgets.MoneyGoldFrame:SetText("")
			MoneyGadgets.MoneyGoldFrame:SetFontSize(14)
			MoneyGadgets.MoneyGoldFrame:SetFontColor(1,0.97,0.84,1)
			MoneyGadgets.MoneyGoldFrame:SetPoint("CENTERLEFT", MoneyGoldIcon, "CENTERRIGHT", 0, 0)	
	
			local MoneySilverIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneySilverIcon "), MoneyGadgets.wrapper)
			MoneySilverIcon:SetTexture("Rift", "coins_Silver.png.dds")
			MoneySilverIcon:SetPoint("CENTERLEFT", MoneyGadgets.MoneyGoldFrame, "CENTERRIGHT", 0, 0)
			MoneySilverIcon:SetWidth(15)
			MoneySilverIcon:SetHeight(15)
	
			MoneyGadgets.MoneySilverFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneySilver"), MoneyGadgets.wrapper)
			MoneyGadgets.MoneySilverFrame:SetText("")
			MoneyGadgets.MoneySilverFrame:SetFontSize(14)
			MoneyGadgets.MoneySilverFrame:SetFontColor(1,0.97,0.84,1)
			MoneyGadgets.MoneySilverFrame:SetPoint("CENTERLEFT", MoneySilverIcon, "CENTERRIGHT", 0, 0)
	
			MoneyGadgets.MoneyPlatFrame:SetEffectGlow({ strength = 3 })
			MoneyGadgets.MoneyGoldFrame:SetEffectGlow({ strength = 3 })
			MoneyGadgets.MoneySilverFrame:SetEffectGlow({ strength = 3 })
	
			if MoneyGadgets.addonConfiguration["Platinum, Gold, Silver"] == false then
				MoneyPlatIcon:SetWidth(-25)
				MoneyPlatIcon:SetVisible(false)
				MoneyGoldIcon:SetWidth(0)
				MoneyGoldIcon:SetVisible(false)
				MoneySilverIcon:SetWidth(0)	
				MoneySilverIcon:SetVisible(false)
				MoneyGadgets.MoneyPlatFrame:SetFontSize(0)
				MoneyGadgets.MoneyPlatFrame:SetVisible(false)
				MoneyGadgets.MoneyGoldFrame:SetFontSize(0)
				MoneyGadgets.MoneyGoldFrame:SetVisible(false)
				MoneyGadgets.MoneySilverFrame:SetFontSize(0)		
				MoneyGadgets.MoneySilverFrame:SetVisible(false)
			end
	
			local currencyTemp = Inspect.Currency.Detail("coin").stack
			if currencyTemp ~= nil then	
			local len = string.len(currencyTemp)	
				if len > 0 then
					MoneyGadgets.MoneySilverFrame:SetText(string.sub(currencyTemp, len-1, len))	
					if len > 2 then
						MoneyGadgets.MoneyGoldFrame:SetText(string.sub(currencyTemp, len-3, len-2))
						if len > 4 then
							MoneyGadgets.MoneyPlatFrame:SetText(string.sub(currencyTemp, 1, len-4))
						else
							MoneyGadgets.MoneyPlatFrame:SetText("0")
						end
					else
						MoneyGadgets.MoneyGoldFrame:SetText("0")
						MoneyGadgets.MoneyPlatFrame:SetText("0")
					end
				else
					MoneyGadgets.MoneySilverFrame:SetText("0")
					MoneyGadgets.MoneyGoldFrame:SetText("0")
					MoneyGadgets.MoneyPlatFrame:SetText("0")
				end
			end
	
			local lastElement = MoneyGadgets.MoneySilverFrame
			for k, v in MoneyGadgets.pairsByKeys(MoneyGadgets.Currencies) do
				for ik, iv in MoneyGadgets.pairsByKeys(v) do
					if k ~= "Coin" or ik == "Credits" then
						MoneyGadgets.curIcon[ik] = UI.CreateFrame("Texture", "icon", MoneyGadgets.wrapper) 
						MoneyGadgets.curIcon[ik]:SetWidth(20)
						MoneyGadgets.curIcon[ik]:SetHeight(20)
						MoneyGadgets.curIcon[ik]:SetPoint("CENTERLEFT", lastElement, "CENTERRIGHT", 10, 0)
						if ik == "Credits" then
							MoneyGadgets.curIcon[ik]:SetTexture(AddonId, "img/credits_icon.png")
						else
							MoneyGadgets.curIcon[ik]:SetTexture("Rift", iv.icon)	
						end
						MoneyGadgets.curText[ik] = UI.CreateFrame("Text", "value", MoneyGadgets.wrapper)
						MoneyGadgets.curText[ik]:SetPoint("CENTERLEFT", MoneyGadgets.curIcon[ik], "CENTERRIGHT", 0, 0) 
						MoneyGadgets.curText[ik]:SetText(iv.value .. "")
						MoneyGadgets.curText[ik]:SetFontSize(14)
						MoneyGadgets.curText[ik]:SetFontColor(1, 0.97, 0.84, 1)
						MoneyGadgets.curText[ik]:SetEffectGlow({ strength = 3 })
						lastElement = MoneyGadgets.curText[ik]
						if MoneyGadgets.addonConfiguration[ik] == false then
							MoneyGadgets.curIcon[ik]:SetWidth(-10)
							MoneyGadgets.curIcon[ik]:SetVisible(false)
							MoneyGadgets.curText[ik]:SetFontSize(0)
							MoneyGadgets.curText[ik]:SetWidth(0)
							MoneyGadgets.curText[ik]:SetVisible(false)
						end
					end
				end
			end

			Command.Event.Detach(Event.System.Update.End, MoneyGadgets.AsyncCreate, "Event.System.Update.End - MoneyGadgets.AsyncCreate")
			MoneyGadgets.isRendered = true
		end
	end
end


WT.Gadget.RegisterFactory("CurrenciesTextBar",
	{
		name=TXT.gadgetCurrenciesTextBar_name,
		description=TXT.gadgetCurrenciesTextBar_desc,
		author="Lifeismystery",
		version="1.0.0",
		iconTexAddon="Rift",
		iconTexFile="tumblr.png.dds",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

Command.Event.Attach(Event.System.Update.End, MoneyGadgets.AsyncCreate, "Event.System.Update.End - MoneyGadgets.AsyncCreate")
Command.Event.Attach(Event.Currency, MoneyGadgets.CurrencyAll, "Event.Currency - MoneyGadgets.CurrencyAll")
