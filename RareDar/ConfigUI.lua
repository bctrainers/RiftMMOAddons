local configWindow

local function L(x) return x end

function RareDar.CreateConfigUI()
	local context=UI.CreateContext("RareDarConfig")		-- cant reuse the other one because that one's in secure mode
	
	configWindow=UI.CreateFrame("RiftWindow", "RareDarConfigFrame", context)
	configWindow:SetTitle(L("RareDar Config"))
	configWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	
	configWindow:SetWidth(500)
	
	local tx1=UI.CreateFrame("Text", "TSN", configWindow);
	tx1:SetFontSize(24);
	tx1:SetText(L("Tell me when others find mobs"))
	tx1:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 70)

-- 	
	local cbShowNeeded=UI.CreateFrame("RiftCheckbox", "CBSN", configWindow)
	cbShowNeeded:SetChecked(RareDarConfig.showNeeded and true or false)
	cbShowNeeded:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 120)
	cbShowNeeded:EventAttach(Event.UI.Checkbox.Change, 
		function(h) RareDarConfig.showNeeded=cbShowNeeded:GetChecked() end
	, "cbShowNeeded")
	
	tx1=UI.CreateFrame("Text", "TSN", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("Tell me when someone finds a mob that i don't have yet"))
	tx1:SetPoint("TOPLEFT", cbShowNeeded, "TOPLEFT", 20, 0)
	
--
	local cbShowKilled=UI.CreateFrame("RiftCheckbox", "CBSK", configWindow)
	cbShowKilled:SetChecked(RareDarConfig.showKilled and true or false)
	cbShowKilled:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 150)
	cbShowKilled:EventAttach(Event.UI.Checkbox.Change, 
		function(h) RareDarConfig.showKilled=cbShowKilled:GetChecked() end
		, "cbShowKilled")

	tx1=UI.CreateFrame("Text", "TSK", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("Tell me when someone finds a mob that i have killed"))
	tx1:SetPoint("TOPLEFT", cbShowKilled, "TOPLEFT", 20, 0)

--

	local tx1=UI.CreateFrame("Text", "TSN", configWindow);
	tx1:SetFontSize(24);
	tx1:SetText(L("Tell others when i find a mob"))
	tx1:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 200)


--
	local cbInformFriends=UI.CreateFrame("RiftCheckbox", "CBIF", configWindow)
	cbInformFriends:SetChecked(RareDarConfig.informFriends and true or false)
	cbInformFriends:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 250)
	cbInformFriends:EventAttach(Event.UI.Checkbox.Change, 
		function(h) RareDarConfig.informFriends=cbInformFriends:GetChecked() end
	, "cbInformFriends")

	tx1=UI.CreateFrame("Text", "TSIF", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("Tell my friends when i find a rare mob"))
	tx1:SetPoint("TOPLEFT", cbInformFriends, "TOPLEFT", 20, 0)
	
--
	local cbInformGuild=UI.CreateFrame("RiftCheckbox", "CBSK", configWindow)
	cbInformGuild:SetChecked(RareDarConfig.informGuild and true or false)
	cbInformGuild:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 280)
	cbInformGuild:EventAttach(Event.UI.Checkbox.Change, 
		function(h) RareDarConfig.informGuild=cbInformGuild:GetChecked() end
	, "cbInformGuild")

	tx1=UI.CreateFrame("Text", "TSIG", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("Tell my guild mates when i find a rare mob"))
	tx1:SetPoint("TOPLEFT", cbInformGuild, "TOPLEFT", 20, 0)
	
--
	local cbInformWorld=UI.CreateFrame("RiftCheckbox", "CBSK", configWindow)
	cbInformWorld:SetChecked(RareDarConfig.informWorld and true or false)
	cbInformWorld:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 310)
	cbInformWorld:EventAttach(Event.UI.Checkbox.Change, 
		function(h) RareDarConfig.informWorld=cbInformWorld:GetChecked() end
	, "cbInformWorld")

	tx1=UI.CreateFrame("Text", "TSIW", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("Tell the world when i find a rare mob"))
	tx1:SetPoint("TOPLEFT", cbInformWorld, "TOPLEFT", 20, 0)

	tx1=UI.CreateFrame("Text", "TSIW2", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("(This needs you to join the RareDar Channel,"))
	tx1:SetPoint("TOPLEFT", cbInformWorld, "TOPLEFT", 20, 20)

	tx1=UI.CreateFrame("Text", "TSIW2", configWindow);
	tx1:SetFontSize(14);
	tx1:SetText(L("type /join RareDar)"))
	tx1:SetPoint("TOPLEFT", cbInformWorld, "TOPLEFT", 20, 40)

	txTrTitle=UI.CreateFrame("Text", "TSTRTITLE", configWindow);
	txTrTitle:SetFontSize(14);
	txTrTitle:SetText("Transparency")
	txTrTitle:SetPoint("TOPLEFT", configWindow, "TOPLEFT", 30, 390)

	local slTransparecy=UI.CreateFrame("RiftSlider", "SLTRANS", configWindow)
	slTransparecy:SetWidth(300)
	slTransparecy:SetRange(0,99)
	local transparency=tonumber(tostring((1-RareDarConfig.alpha)*100),10)
	slTransparecy:SetPosition(transparency)
	slTransparecy:SetPoint("TOPLEFT", txTrTitle, "TOPRIGHT", 14, 6)
	slTransparecy:EventAttach(Event.UI.Slider.Change,
		function(h)
			transparency=slTransparecy:GetPosition()
			txmax:SetText(tostring(transparency))
			RareDarConfig.alpha=(100-transparency)/100
			refreshMiniWindow()
		end
		, "slTransparecy")

	txmax=UI.CreateFrame("Text", "TSMIN", configWindow);
	txmax:SetFontSize(14);
	txmax:SetText(tostring(transparency))
	txmax:SetPoint("TOPLEFT", slTransparecy, "TOPRIGHT", 14, -6)

	local btClose=UI.CreateFrame("RiftButton", "CBCLOSE", configWindow)
	btClose:SetText("Close")
	btClose:SetPoint("BOTTOMCENTER", configWindow, "BOTTOMCENTER", 0, -30)
	btClose:EventAttach(Event.UI.Button.Left.Press,
		function(h) configWindow:SetVisible(false) end
	, "cbClose")
	
	configWindow:SetVisible(false)
end

function RareDar.ShowConfigUI()
	configWindow:SetVisible(true)
end
