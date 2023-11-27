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
local fpsGadgets = {}
local cpuGadgets = {}
local MoneyGadgets = {}
local shardName=nil
local lastQueried=0

local function Create(configuration)	

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtDataText"), WT.Context)
	wrapper:SetWidth(570)
	wrapper:SetHeight(30)
	wrapper:SetSecureMode("restricted")
	wrapper:SetLayer(1000)
	
	wrapper.font = Library.Media.GetFont(configuration.font)
	wrapper.textFontSize = configuration.fontSize
	local fontEntry = wrapper.font or Library.Media.GetFont("#Default")
	
	if configuration.showBackground == nil then
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		wrapper:SetBackgroundColor(0.07,0.07,0.07,0.85)		
	elseif configuration.showBackground == true then
			Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		if configuration.BackgroundColor == nil then
			configuration.BackgroundColor = {0.07,0.07,0.07,0.85}
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		else 
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		end
	else 	
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", wrapper, 1, 0, 0, 0, 0)
		wrapper:SetBackgroundColor(0,0,0,0)
	end
------------------------FPS---------------------------------------------------------------
	local fpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	fpsFrame:SetText("")
	fpsFrame:SetFontSize(configuration.fontSize or 14)
	fpsFrame:SetFont(fontEntry.addonId, fontEntry.filename)
	fpsFrame:SetFontColor(1,0.97,0.84,1)
	fpsFrame:SetPoint("CENTERLEFT", wrapper, "CENTERLEFT", 10, 0)
	
	if 	configuration.outlineTextBlack == true then
		fpsFrame:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		fpsFrame:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end
	
	if configuration.showFPS == false then
		fpsFrame:SetVisible(false)	
		fpsFrame:SetWidth(-10)
	end
----------------------CPU------------------------------------------------------------------
	local cpuFrame = UI.CreateFrame("Text", WT.UniqueName("wtCPU"), wrapper)
	cpuFrame:SetText("")
	cpuFrame:SetFontSize(configuration.fontSize or 14)
	cpuFrame:SetFont(fontEntry.addonId, fontEntry.filename)
	cpuFrame.currText = ""
	cpuFrame:SetFontColor(1,0.97,0.84,1)
	cpuFrame:SetEffectGlow({ strength = 3 })
	cpuFrame:SetPoint("CENTERLEFT", fpsFrame, "CENTERRIGHT", 10, 0)
	
	if 	configuration.outlineTextBlack == true then
		cpuFrame:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		cpuFrame:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end	
	
	if configuration.showCPU == false then
		cpuFrame:SetVisible(false)	
		cpuFrame:SetWidth(-10)
	end
----------------------PlanarCharge----------------------------------------------------------
	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetLayer(1001)
	chargeMeter:SetPoint("CENTERLEFT", cpuFrame, "CENTERRIGHT", 10, 0)
	chargeMeter:CreateElement(
	{
		id="imgCharge", type="Image", parent="frame", layer=10, alpha=1,
		attach = {
			{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT" },
		},
		texAddon="Rift", texFile="chargedstone_on.png.dds",
		backgroundColor={r=1, g=1, b=1, a=1},
		width = 22, height = 22,
	});
	chargeMeter:CreateElement(
	{
		id="chargeLabel", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTERLEFT", element="imgCharge", targetPoint="CENTERLEFT", offsetX=20, offsetY=0}},
		outline=true,
		text="{planar}/{planarMax}", fontSize=configuration.fontSize or 14, color={r=1, g=0.97, b=0.84, a=1},
		font = configuration.font or "#Default",
	});

	if configuration.showCharge == false then
		chargeMeter.Elements.imgCharge:SetWidth(0)
		chargeMeter.Elements.chargeLabel:SetWidth(-30)
		chargeMeter:SetWidth(-10)
		chargeMeter:SetVisible(false)
	end
	
	if 	configuration.outlineTextBlack == true then
		chargeMeter.Elements.chargeLabel:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		chargeMeter.Elements.chargeLabel:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end
----------------------SoulVitality----------------------------------------------------------
	local vitalityMeter = WT.UnitFrame:Create("player")
	vitalityMeter:SetLayer(1001)
	vitalityMeter:SetPoint("CENTERLEFT", chargeMeter.Elements.chargeLabel, "CENTERRIGHT", 10, 0)
	
	vitalityMeter:CreateElement(
	{
		id="imgVitality", type="Image", parent="frame", layer=10, alpha=1,
		attach = {
			{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=0, offsetY=7},
		},
		texAddon="Rift", texFile="death_icon_(grey).png.dds",
		backgroundColor={r=1, g=1, b=1, a=1},
		width = 40, height = 40,
	});
	vitalityMeter:CreateElement(
	{
		id="imgZVitality", type="Image", parent="frame", layer=15, alpha=1,
		attach = {
			{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=0, offsetY=7 },
		},
		texAddon="Rift", texFile="death_icon_(red).png.dds",
		visibilityBinding="zVitality",
		backgroundColor={r=1, g=1, b=1, a=0},
		width = 40, height = 40,
	});
	vitalityMeter:CreateElement(
	{
		id="txtVitality", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTERLEFT", element="imgVitality", targetPoint="CENTERLEFT", offsetX=30, offsetY=-8 }},
		text="{vitality}%", fontSize=configuration.fontSize or 14, outline=true, color={r=1, g=0.97, b=0.84, a=1},
		font = configuration.font or "#Default",
	});
	
	if 	configuration.outlineTextBlack == true then
		vitalityMeter.Elements.txtVitality:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		vitalityMeter.Elements.txtVitality:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end
	
	if configuration.showVitality == false then
		vitalityMeter.Elements.imgVitality:SetWidth(0)
		vitalityMeter.Elements.imgZVitality:SetWidth(0)
		vitalityMeter.Elements.txtVitality:SetWidth(-40)
		vitalityMeter.Elements.txtVitality:SetText("")
		vitalityMeter:SetWidth(-10)
		vitalityMeter:SetVisible(false)
	end
------------------------------ShardName-------------------------------------------------------------------

	local shardNameText = UI.CreateFrame("Text", WT.UniqueName("wtshardName"), wrapper)
	shardNameText:SetText("")
	shardNameText:SetFontSize(configuration.fontSize or 14)
	shardNameText:SetFont(fontEntry.addonId, fontEntry.filename)
	shardNameText:SetFontColor(1,0.97,0.84,1)
	shardNameText:SetPoint("CENTERLEFT", vitalityMeter.Elements.txtVitality, "CENTERRIGHT", 10, 0)		
		
	if 	configuration.outlineTextBlack == true then
		shardNameText:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		shardNameText:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end	
	
	if configuration.showShard == false then
		shardNameText:SetVisible(false)
		shardNameText:SetWidth(-10)	
	end

local function systemUpdate(handle, systemUpdate)
    local now=Inspect.Time.Server()
    if (shardName==nil or now > lastQueried+5) and Inspect.System.Watchdog() > 0.1 then
        lastQueried=now

        local ZoneID = Inspect.Unit.Detail("player")
        if not ZoneID.zone then return end
        local ZoneInfo = Inspect.Zone.Detail(ZoneID.zone)
        local foundzone = 0
        local consoles=Inspect.Console.List()
        local newShardName = Inspect.Shard().name
            for cid, flag in pairs(consoles) do
                local console=Inspect.Console.Detail(cid)
                if console.channel then
                    for cname, flag in pairs(console.channel) do
                        if ( (cname:sub(1, ZoneInfo.name:len()+1) == ZoneInfo.name.."@") and foundzone == 0) then
                            -- we are in a "zone@server" channel
                            newShardName=cname:sub(ZoneInfo.name:len()+2)
                            foundzone = 1
                        end
                    end
                end
            end
            if newShardName and newShardName ~= shardName then
                shardNameText:SetText(newShardName)
                shardname=newShardName
            end
        
            
    end
end
if newShardName == nil then 
	local shardTemp=Inspect.Shard()
	shardNameText:SetText(shardTemp.name)
end
----------------------Bag_slot----------------------------------------------------------	
	BagSlotText = UI.CreateFrame("Text", WT.UniqueName("wtBagSlotText"), wrapper)
	BagSlotText:SetText("")
	BagSlotText:SetFontSize(configuration.fontSize or 14)
	BagSlotText:SetFont(fontEntry.addonId, fontEntry.filename)
	BagSlotText:SetFontColor(1,0.97,0.84,1)
	BagSlotText:SetPoint("CENTERLEFT", shardNameText, "CENTERRIGHT", 10, 0)		
		
	if 	configuration.outlineTextBlack == true then
		BagSlotText:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		BagSlotText:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end	

	--[[local BagSlotsAll = 0
	local bagsizes={}
	for i=1,7 do
		if Inspect.Item.Detail(Utility.Item.Slot.Inventory("bag",i)) then
			BagSlotsAll= BagSlotsAll + Inspect.Item.Detail(Utility.Item.Slot.Inventory("bag",i))["slots"]			
		end

	end

	BagSlots_empty = 0
	
	BagSlotText_String = string.format("B: %d/%d", BagSlots_empty, BagSlotsAll)
	BagSlotText:SetText(BagSlotText_String)]]
	


	if configuration.showBagSlot == false then
		BagSlotText:SetVisible(false)
		BagSlotText:SetWidth(-10)	
	end
	--table.insert(Event.Item.Slot, { BagSlotsList, AddonId, "BagSlotsList" })
----------------------Money----------------------------------------------------------	
	
	local MoneyPlatIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneyPlatIcon "), wrapper)
	MoneyPlatIcon:SetTexture("Rift", "coins_platinum.png.dds")
	MoneyPlatIcon:SetPoint("CENTERLEFT", BagSlotText, "CENTERRIGHT", 10, 0)
	MoneyPlatIcon:SetWidth(15)
	MoneyPlatIcon:SetHeight(15)	
	
	local MoneyPlatFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneyPlat"), wrapper)
	MoneyPlatFrame:SetText("")
	MoneyPlatFrame:SetFontSize(configuration.fontSize or 14)
	MoneyPlatFrame:SetFont(fontEntry.addonId, fontEntry.filename)
	MoneyPlatFrame:SetFontColor(1,0.97,0.84,1)
	MoneyPlatFrame:SetPoint("CENTERLEFT", MoneyPlatIcon, "CENTERRIGHT", 0, 0)
	
	local MoneyGoldIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneyGoldIcon "), wrapper)
	MoneyGoldIcon:SetTexture("Rift", "coins_gold.png.dds")
	MoneyGoldIcon:SetPoint("CENTERLEFT", MoneyPlatFrame, "CENTERRIGHT", 0, 0)
	MoneyGoldIcon:SetWidth(15)
	MoneyGoldIcon:SetHeight(15)

	local MoneyGoldFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneyGold"), wrapper)
	MoneyGoldFrame:SetText("")
	MoneyGoldFrame:SetFontSize(configuration.fontSize or 14)
	MoneyGoldFrame:SetFont(fontEntry.addonId, fontEntry.filename)
	MoneyGoldFrame:SetFontColor(1,0.97,0.84,1)
	MoneyGoldFrame:SetPoint("CENTERLEFT", MoneyGoldIcon, "CENTERRIGHT", 0, 0)	
	
	local MoneySilverIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneySilverIcon "), wrapper)
	MoneySilverIcon:SetTexture("Rift", "coins_Silver.png.dds")
	MoneySilverIcon:SetPoint("CENTERLEFT", MoneyGoldFrame, "CENTERRIGHT", 0, 0)
	MoneySilverIcon:SetWidth(15)
	MoneySilverIcon:SetHeight(15)
	
	local MoneySilverFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneySilver"), wrapper)
	MoneySilverFrame:SetText("")
	MoneySilverFrame:SetFontSize(configuration.fontSize or 14)
	MoneySilverFrame:SetFont(fontEntry.addonId, fontEntry.filename)
	MoneySilverFrame:SetFontColor(1,0.97,0.84,1)
	MoneySilverFrame:SetPoint("CENTERLEFT", MoneySilverIcon, "CENTERRIGHT", 0, 0)
	
	if 	configuration.outlineTextBlack == true then
		MoneyPlatFrame:SetEffectGlow({ strength = 3 })
		MoneyGoldFrame:SetEffectGlow({ strength = 3 })
		MoneySilverFrame:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		MoneyPlatFrame:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
		MoneyGoldFrame:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
		MoneySilverFrame:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end		
	
	if configuration.showMoney == false then
		MoneyPlatIcon:SetWidth(-25)
			MoneyPlatIcon:SetVisible(false)
		MoneyGoldIcon:SetWidth(0)
			MoneyGoldIcon:SetVisible(false)
		MoneySilverIcon:SetWidth(0)	
			MoneySilverIcon:SetVisible(false)
		MoneyPlatFrame:SetFontSize(0)
			MoneyPlatFrame:SetVisible(false)
		MoneyGoldFrame:SetFontSize(0)
			MoneyGoldFrame:SetVisible(false)
		MoneySilverFrame:SetFontSize(0)		
			MoneySilverFrame:SetVisible(false)
	end
	
	currencyTemp = Inspect.Currency.Detail("coin")
	if currencyTemp.stack ~= nil then	
	len = string.len(currencyTemp.stack)	
		if len > 0 then
			MoneySilverFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-1, len))	
			if len > 2 then
				MoneyGoldFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-3, len-2))
				if len > 4 then
					MoneyPlatFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, 1, len-4))
				else
					MoneyPlatFrame:SetText("0")
				end
			else
				MoneyGoldFrame:SetText("0")
				MoneyPlatFrame:SetText("0")
			end
		else
			MoneySilverFrame:SetText("0")
			MoneyGoldFrame:SetText("0")
			MoneyPlatFrame:SetText("0")
		end
	end	
function currency (handle, currency)
	len = string.len(Inspect.Currency.Detail("coin").stack)	
			
		if len > 0 then
			MoneySilverFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-1, len))	
			if len > 2 then
				MoneyGoldFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-3, len-2))
				if len > 4 then
					MoneyPlatFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, 1, len-4))
				else
					MoneyPlatFrame:SetText("0")
				end
			else
				MoneyGoldFrame:SetText("0")
				MoneyPlatFrame:SetText("0")
			end
		else
			MoneySilverFrame:SetText("0")
			MoneyGoldFrame:SetText("0")
			MoneyPlatFrame:SetText("0")
		end
end
------------------------------ReloadUI-------------------------------------------------------------------

	local btnReloadUI = UI.CreateFrame("Frame", WT.UniqueName("wtReloadUI"), wrapper)
	btnReloadUI:SetWidth(90)
	btnReloadUI:SetHeight(20)
	btnReloadUI:SetBackgroundColor(0,0,0,0)
	
	if configuration.showBackground == nil then
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", btnReloadUI, 1, 0, 0, 0, 1)	
	elseif configuration.showBackground == true then
			Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", btnReloadUI, 1, 0, 0, 0, 1)
	else 	
		Library.LibSimpleWidgetsLifeEdition.SetBorder("plain", btnReloadUI, 1, 0, 0, 0, 0)
	end

	btnReloadUI:SetPoint("CENTERLEFT", MoneySilverFrame, "CENTERRIGHT", 10, 0)	
	if configuration.showBackground == true or configuration.showBackground == nil then
	btnReloadUI:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
		btnReloadUI:SetBackgroundColor(0.5,0.4,0.7, 0.85)
	end, "Event.UI.Input.Mouse.Cursor.In")
	btnReloadUI:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
		btnReloadUI:SetBackgroundColor(0,0,0,0)
	end, "Event.UI.Input.Mouse.Cursor.Out")
	end
	btnReloadUI:SetSecureMode("restricted")
	btnReloadUI:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "reloadui")
	
	local txtReloadUI = UI.CreateFrame("Text", WT.UniqueName("wttxtReloadUI"), btnReloadUI)
	txtReloadUI:SetText("Reload UI")
	txtReloadUI:SetFontSize(configuration.fontSize or 14)
	txtReloadUI:SetFont(fontEntry.addonId, fontEntry.filename)
	txtReloadUI.currText = ""
	txtReloadUI:SetFontColor(1,0.97,0.84,1)
	txtReloadUI:SetPoint("CENTERLEFT", btnReloadUI, "CENTERLEFT", 15, 0)
	txtReloadUI:SetLayer(100)
	
	if 	configuration.outlineTextBlack == true then
		txtReloadUI:SetEffectGlow({ strength = 3 })
	elseif configuration.outlineTextLight == true then
		txtReloadUI:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	end	
	
	if configuration.showReloadUI == false then
		btnReloadUI:SetVisible(false)
		btnReloadUI:SetWidth(-10)	
	end	
-----------------------------------------------------------------------------------------------------------	
	
	table.insert(fpsGadgets, fpsFrame)
	table.insert(cpuGadgets, cpuFrame)
	table.insert(MoneyGadgets, MoneyPlatFrame)
	table.insert(MoneyGadgets, MoneyGoldFrame)
	table.insert(MoneyGadgets, MoneySilverFrame)
	table.insert(Event.Currency,{ currency, AddonId, "_currency" })
	table.insert(Event.System.Update.Begin,{ systemUpdate, AddonId, "_systemUpdate" })

	return wrapper, { resizable={70, 30, 3000, 30} }
	
end
	
local dialog = false

local function ConfigDialog(container)	
	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	
	dialog = WT.Dialog(container)
		:Label("This gadget displays DataText bar with FRS, CPU, Planar charge, Soul vitality, Money and button 'ReloadUI' ")
		:Checkbox("showFPS", "Show FPS", true)
		:Checkbox("showCPU", "Show CPU", true)
		:Checkbox("showCharge", "Show Planar Charge", true)		
		:Checkbox("showVitality", "Show Soul Vitality", true)
		:Checkbox("showShard", "Show Shard Name", true)	
		:Checkbox("showBagSlot", "Show Bag Slot", false)			
		:Checkbox("showMoney", "Show Money", true)			
		:Checkbox("showReloadUI", "Show ReloadUI", true)
		:TitleY("Gadgets Options")					
		:Checkbox("showBackground", "Show Background frame", true)
		:ColorPicker("BackgroundColor", "Background Color", 0.07,0.07,0.07,0.85)
		:Checkbox("outlineTextBlack", "Show outline(black) text", true)	
		:Checkbox("outlineTextLight", "Show outline(light) text", false)
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 14, true)		
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

local delta = 0
	
local function OnTick(hEvent, frameDeltaTime, frameIndex)
	local fpsText = "FPS:" .. " " .. tostring(math.ceil(WT.FPS))
	for idx, gadget in ipairs(fpsGadgets) do
		if gadget.currText ~=fpsText then
			gadget:SetText(fpsText)
			gadget.currText = fpsText
		end
	end
	
		delta = delta + frameDeltaTime
	if (delta >= 1) then
		delta = 0
		local addons = {}
		local grandTotal = 0
		local renderTotal = 0
		for addonId, cpuData in pairs(Inspect.Addon.Cpu()) do
			if cpuData then
				local total = 0
				for k,v in pairs(cpuData) do
					total = total + v
					if string.find(k, "render time") then renderTotal = renderTotal + v end
					if string.find(k, "update time") then renderTotal = renderTotal + v end
				end
				grandTotal = grandTotal + total
				addons[addonId] = total
			end
		end

		local cpuText = "CPU:" .. " " .. string.format("%.02f%%", grandTotal * 100)

		for idx, gadget in ipairs(cpuGadgets) do
			gadget:SetText(cpuText)
		end
	end
end


Command.Event.Attach(WT.Event.Tick, OnTick, AddonId .. "_OnTick")

WT.Unit.CreateVirtualProperty("zVitality", {"vitality" },
	function(unit)
		if unit.vitality and unit.vitality > 11 then
			return false
		else
			return true
		end
end)

WT.Gadget.RegisterFactory("DataTextBar",
	{
		name=TXT.gadgetDataTextBar_name,
		description=TXT.gadgetDataTextBar_desc,
		author="Lifeismystery",
		version="1.0.0",
		iconTexAddon="Rift",
		iconTexFile="tumblr.png.dds",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})