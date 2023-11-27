local Info, private = ...
local AddonId = "fragRecycle" --toc.identifier
recycle_table = {}

local function split(str, delimiter)
	local split = {}
	for i in string.gmatch(str, delimiter) do
		table.insert(split, i)
	end
	return split
end

function saveLoc()
	fragRecycleFrameX = fragframe.FrameX
	fragRecycleFrameY = fragframe.FrameY
	btnRecycleFrameX = btnframe.FrameX
	btnRecycleFrameY = btnframe.FrameY
end

function setVariables()
	if fragmentAffinity == nil then
		fragmentAffinity = {}
		for x = 1, 7 do
			fragmentAffinity[x] = true
		end
	end
	if fragmentTier == nil then
		fragmentTier = 1
	end
	if fragmentRarity == nil then
		fragmentRarity = 1
	end
	if infusionLevel == nil then
		infusionLevel = 0
	end
	if primeStats == nil then
		primeStats = {}
		for x = 1, 15 do
			primeStats[x] = false
		end
	end
	if secondStats == nil then
		secondStats = {}
		for x = 1, 15 do
			secondStats[x] = false
		end
	end
	if useinv == nil then
		useinv = true
	end
	if usebags == nil then
		usebags = false
	end
	if pri_andorMode  == nil then
		pri_andorMode = true
	end
	if sec_andorMode  == nil then
		sec_andorMode = true
	end
	if btniconsize  == nil then
		btniconsize = 40
	end
	if btniconlock  == nil then
		btniconlock = false
	end
	if btniconbackground == nil then
		btniconbackground = true
	end
	showtooltips = false
end

function resetVariables()
	fragmentAffinity = nil
	fragmentTier = nil
	fragmentRarity = nil
	infusionLevel = nil
	primeStats = nil
	secondStats = nil
	useinv = nil
	usebags = nil
	pri_andorMode  = nil
	sec_andorMode  = nil
	btniconsize  = nil
	btniconlock  = nil
	btniconbackground = nil
	
	setVariables()
	varToForm()
	
	fragframe.FrameX = (UIParent:GetWidth() / 2) - (fragframe.Width / 2)
	fragframe.FrameY = (UIParent:GetHeight() / 2) - (fragframe.Height / 2)
	btnframe.FrameX = (UIParent:GetWidth() / 2) - (btnframe.Width / 2)
	btnframe.FrameY = (UIParent:GetHeight() / 2) - (btnframe.Height / 2)
	
	saveLoc()
	
	fragframe:SetPoint(0,0,UIParent,0,0,fragframe.FrameX,fragframe.FrameY)

	btnframe.framelock = btniconlock
	btnframe.Width = btniconsize
	btnframe.Height = btniconsize
	btnframe:SetWidth(btnframe.Width)
	btnframe:SetHeight(btnframe.Height)
	btnframe.icon:SetWidth(btnframe.Width)
	btnframe.icon:SetHeight(btnframe.Height)	
	btnframe:SetPoint(0,0,UIParent,0,0,btnframe.FrameX,btnframe.FrameY)
	if (btniconbackground) then
		btnframe:SetBackgroundColor(1,1,1,0.5)
	else
		btnframe:SetBackgroundColor(0,0,0,0)
	end	
end

function varToForm()
	for i = 1,7 do
		if fragmentAffinity[i] ~= nil then
			fragframe.cb[i]:SetChecked(fragmentAffinity[i])
		else
			fragframe.cb[i]:SetChecked(true)
		end
	end
	for i = 8,22 do
		k = i - 7
		if primeStats[k] ~= nil then
			fragframe.cb[i]:SetChecked(primeStats[k])
		else
			fragframe.cb[i]:SetChecked(false)
		end
	end
	for i = 23,37 do
		k = i - 22
		if secondStats[k] ~= nil then
			fragframe.cb[i]:SetChecked(secondStats[k])
		else
			fragframe.cb[i]:SetChecked(false)
		end
	end
	if fragmentRarity ~= nil then
		fragframe.sl[1]:SetPosition(fragmentRarity)
	else
		fragframe.sl[1]:SetPosition(1)
	end
	if infusionLevel ~= nil then
		local min, max = fragframe.sl[2]:GetRange()
		if (infusionLevel > max) then infusionLevel = max end
		fragframe.sl[2]:SetPosition(infusionLevel)
	else
		fragframe.sl[2]:SetPosition(0)
	end
	if fragmentTier ~= nil then
		fragframe.sl[3]:SetPosition(fragmentTier)
	else
		fragframe.sl[3]:SetPosition(1)
	end
	if useinv ~= nil then
		fragframe.cb[38]:SetChecked(useinv)
	else
		fragframe.cb[38]:SetChecked(true)
	end
	if usebags ~= nil then
		fragframe.cb[39]:SetChecked(usebags)
	else
		fragframe.cb[39]:SetChecked(false)
	end
	if pri_andorMode ~= nil then
		fragframe.cb[41]:SetChecked(pri_andorMode)
	else
		fragframe.cb[41]:SetChecked(true)
	end
	if sec_andorMode ~= nil then
		fragframe.cb[43]:SetChecked(sec_andorMode)
	else
		fragframe.cb[43]:SetChecked(true)
	end
end	

function FormTovar()
	for i = 1,7 do
		fragmentAffinity[i] = fragframe.cb[i]:GetChecked()
	end
	for i = 8,22 do
		k = i - 7
		primeStats[k] = fragframe.cb[i]:GetChecked()
	end
	for i = 23,37 do
		k = i - 22
		secondStats[k] = fragframe.cb[i]:GetChecked()
	end
	fragmentRarity = fragframe.sl[1]:GetPosition()
	infusionLevel = fragframe.sl[2]:GetPosition()
	fragmentTier = fragframe.sl[3]:GetPosition()
	useinv = fragframe.cb[38]:GetChecked()
	usebags = fragframe.cb[39]:GetChecked()
	pri_andorMode = fragframe.cb[41]:GetChecked()
	sec_andorMode = fragframe.cb[43]:GetChecked()	
end	

function inifragles(a)
	if a~= "fragRecycle" then
		return
	end	
	setVariables()
	createUI()
	varToForm()
--	print("fragRecycle int.")
end

function returnRarity(rarity)
	if rarity == 1 then return "common" end
	if rarity == 2 then return "uncommon" end
	if rarity == 3 then return "rare" end
	if rarity == 4 then return "epic" end
	if rarity == 5 then return "relic" end
	if rarity == 6 then return "transcendent" end
	if rarity == 7 then return "ascended" end
	return "gray"
end

function returnRarityCol(rarity)
	if rarity == 1 then return 0.98,	0.98,	0.98	end
	if rarity == 2 then return 0.0,		0.797,	0.0		end
	if rarity == 3 then return 0.148,   0.496,	0.977	end
	if rarity == 4 then return 0.676,   0.281,	0.98	end
	if rarity == 5 then return 1.0,     0.5,	0.0		end
	if rarity == 6 then return 1.0,     0.0,    0.0		end
	if rarity == 7 then return 0.93,    0.51,   0.93	end
	return 0.34375, 0.34375, 0.34375
end

function returnAffinity(affinity)
	if affinity == 1 then return "Earth" end
	if affinity == 2 then return "Air" end
	if affinity == 3 then return "Fire" end
	if affinity == 4 then return "unknown" end
	if affinity == 5 then return "Water" end
	if affinity == 6 then return "Life" end
	if affinity == 7 then return "Death" end
	return "unknown"
end

function returnStat(stat)
	if stat == 1 then return "intelligence" end
	if stat == 2 then return "wisdom" end
	if stat == 3 then return "strength" end
	if stat == 4 then return "dexterity" end
	if stat == 5 then return "endurance" end
	if stat == 6 then return "maxHealth" end
	if stat == 7 then return "powerAttack" end
	if stat == 8 then return "critAttack" end
	if stat == 9 then return "powerSpell" end
	if stat == 10 then return "critSpell" end
	if stat == 11 then return "critPower" end
	if stat == 12 then return "guard" end
	if stat == 13 then return "block" end
	if stat == 14 then return "dodge" end
	return "unknown"
end

function returnStatName(stat)
	if stat == 1 then return "Enlightened" end -- intelligence
	if stat == 2 then return "Sagacious" end -- wisdom
	if stat == 3 then return "Mighty" end -- strength
	if stat == 4 then return "Nimble" end -- dexterity
	if stat == 5 then return "Stalwart" end -- endurance
	if stat == 6 then return "Vital" end -- maxHealth
	if stat == 7 then return "Aggressive" end -- powerAttack
	if stat == 8 then return "Unerring" end -- critAttack
	if stat == 9 then return "Calculating" end -- powerSpell
	if stat == 10 then return "Precise" end -- critSpell
	if stat == 11 then return "Punishing" end -- critPower
	if stat == 12 then return "Impenetrable" end -- guard
	if stat == 13 then return "Unassailable" end -- block
	if stat == 14 then return "Elusive" end -- dodge
	return "unknown"
end

function createUI()
	local k = 0
	local frame_context = UI.CreateContext("FRAME")
--	frame_context:SetSecureMode("restricted")
	fragframe = UI.CreateFrame("Frame", "fragframe", frame_context)
	fragframe.mouseDown	= false
	fragframe.mouseOffsetX = 0
	fragframe.mouseOffsetY = 0
	fragframe.framelock = false
	fragframe.Width = 400
	fragframe.Height = 210/0.7
	if fragRecycleFrameX then fragframe.FrameX = fragRecycleFrameX else fragframe.FrameX = (UIParent:GetWidth() / 2) - (fragframe.Width / 2) end
	if fragRecycleFrameY then fragframe.FrameY = fragRecycleFrameY else fragframe.FrameY = (UIParent:GetHeight() / 2) - (fragframe.Height / 2) end
	
	fragframe:SetLayer(1)
	fragframe:SetBackgroundColor(1,1,1,0)
	fragframe:SetWidth(fragframe.Width)
	fragframe:SetHeight(fragframe.Height)
	fragframe:SetPoint(0,0,UIParent,0,0,fragframe.FrameX,fragframe.FrameY)
	
	fragframe.Text = UI.CreateFrame("Text", "f.Text", fragframe)
	fragframe.Text:SetLayer(11)
	fragframe.Text:SetFontSize(16)
	fragframe.Text:SetText(AddonId .. "	" .. Info.toc.Version)
	fragframe.Text:SetPoint("TOPCENTER", fragframe, "TOPCENTER", 0,3)
	fragframe.Text:SetVisible(true)	
	
	
	fragframe.icon = UI.CreateFrame("Texture", "f.icon", fragframe)
	fragframe.icon:SetLayer(1)
	fragframe.icon:SetVisible(true)
	fragframe.icon:SetPoint("TOPLEFT", fragframe, "TOPLEFT", 0,0)	
	fragframe.icon:SetTexture("Rift", "bg_item_package_purple.png.dds")
	fragframe.icon:SetWidth(fragframe.Width)
	fragframe.icon:SetHeight(fragframe.Height)

	main_fragframe = UI.CreateFrame("Frame", "main_fragframe", fragframe)
	main_fragframe:SetLayer(2)
	main_fragframe:SetPoint("TOPLEFT", fragframe, "TOPLEFT", 20,27)	
	main_fragframe:SetWidth((fragframe.Width) - 40)
	main_fragframe:SetHeight(55)
	main_fragframe:SetBackgroundColor(1,1,1,.25)
	main_fragframe:SetVisible(true)
	
	pri_fragframe = UI.CreateFrame("Frame", "pri_fragframe", fragframe)
	pri_fragframe:SetLayer(2)
	pri_fragframe:SetPoint("TOPLEFT", fragframe, "TOPLEFT", 20,94)	
	pri_fragframe:SetWidth((fragframe.Width/2) - 25)
	pri_fragframe:SetHeight(140)
	pri_fragframe:SetBackgroundColor(1,1,1,.25)
	pri_fragframe:SetVisible(true)

	sec_fragframe = UI.CreateFrame("Frame", "sec_fragframe", fragframe)
	sec_fragframe:SetLayer(2)
	sec_fragframe:SetPoint("TOPRIGHT", fragframe, "TOPRIGHT", -20,94)	
	sec_fragframe:SetWidth((fragframe.Width/2) - 25)
	sec_fragframe:SetHeight(140)
	sec_fragframe:SetBackgroundColor(1,1,1,.25)
	sec_fragframe:SetVisible(true)
	
	tooltipframe = UI.CreateFrame("Frame", "tooltipframe", fragframe)
	tooltipframe:SetLayer(20)
	tooltipframe:SetBackgroundColor(0,0,0,1)
	tooltipframe:SetPoint("BOTTOMLEFT",fragframe,"TOPRIGHT",40,-40)
	tooltipframe.text = UI.CreateFrame("Text", "tooltipframe", tooltipframe)
	tooltipframe.text:SetPoint("CENTER", tooltipframe, "CENTER", 0, 0)
	tooltipframe.text:SetFontSize(16)
	
	function tooltipframe.text.Event:Size()
		tooltipframe:SetWidth(tooltipframe.text:GetWidth()+8)
		tooltipframe:SetHeight(tooltipframe.text:GetHeight()+8)
	end
	tooltipframe:SetVisible(false)

	fragframe.btn = {}
	for i = 1,5 do
		local btn = UI.CreateFrame("RiftButton", "f.btn", fragframe)
		table.insert(fragframe.btn,btn)
		fragframe.btn[i]:SetWidth(120)
		fragframe.btn[i]:SetLayer(10+i)
		k = i - 1
		fragframe.btn[i]:SetPoint("TOPLEFT", fragframe, "TOPLEFT", 20 + 120 * (k % 3),258)
		fragframe.btn[i]:SetText("text")
		tooltip(fragframe.btn[i])
		fragframe.btn[i]:SetVisible(true)
	end

	fragframe.btn[1].tooltip = "move any fragments in the bag inventory\n"..
								"to any free slots in the fragmnet inventory"
	fragframe.btn[2].tooltip = "move any fragments in the fragmnet inventory\n"..
								"to any free slots in the bag inventory"
	fragframe.btn[3].tooltip = "recycle the fragments"
	fragframe.btn[4].tooltip = "close this frame"
	fragframe.btn[5].tooltip = "enable/disable tooltips"

	fragframe.btn[1]:SetText("frag inv <- all")
	fragframe.btn[2]:SetText("all -> bag inv")
	fragframe.btn[3]:SetText("recycle")

	fragframe.btn[4]:ClearAll()
	fragframe.btn[4]:SetSkin("close")
	fragframe.btn[4]:SetPoint("TOPRIGHT", fragframe, "TOPRIGHT", -5,0)
	
	fragframe.btn[5]:SetWidth(fragframe.btn[4]:GetWidth())
	fragframe.btn[5]:SetHeight(fragframe.btn[4]:GetHeight())
	fragframe.btn[5]:SetPoint("TOPLEFT", fragframe, "TOPLEFT", 5,0)
	fragframe.btn[5]:SetBackgroundColor(1,1,1,0)
	
	fragframe.btn[5].icon = UI.CreateFrame("Texture", "f.btn.Text", fragframe.btn[5])
	fragframe.btn[5].icon:SetPoint("TOPLEFT", fragframe.btn[5], "TOPLEFT")
	fragframe.btn[5].icon:SetWidth(38)
	fragframe.btn[5].icon:SetHeight(38)
	fragframe.btn[5].icon:SetTexture("Rift", "AATree_I38.dds")
	fragframe.btn[5].icon:SetWidth(fragframe.btn[5]:GetWidth())
	fragframe.btn[5].icon:SetHeight(fragframe.btn[5]:GetHeight())		
	fragframe.btn[5]:SetWidth(0)
	fragframe.btn[5]:SetHeight(0)
	fragframe.btn[5].icon:SetVisible(true)
	
	local btn1 = fragframe.btn[1]
	function btn1.Event:LeftPress()
		fags_to_inv()
	end
	local btn2 = fragframe.btn[2]
	function btn2.Event:LeftPress()
		fags_to_bags()
	end
	local btn3 = fragframe.btn[3]
	function btn3.Event:LeftPress()
		FormTovar()
		recycle()
	end
	local btn4 = fragframe.btn[4]
	function btn4.Event:LeftPress()
		FormTovar()
		fragframe:SetVisible(false)
	end

	local ico1 = fragframe.btn[5].icon
--	function ico1.Event:MouseIn()
--		ico1:SetTexture("Rift", "AATree_I3A.dds")
--	end
--	function ico1.Event:MouseOut()
--		ico1:SetTexture("Rift", "AATree_I38.dds")
--	end
	showtooltips = false
	function ico1.Event:LeftClick()
		if showtooltips == true then
			showtooltips = false
			ico1:SetTexture("Rift", "AATree_I38.dds")
			print("not showing tooltips")
		else
			showtooltips = true
			ico1:SetTexture("Rift", "AATree_I3A.dds")
			print("showing tooltips")
		end
	end

	
	fragframe.cb = {}
	for i = 1,7 do
		local cb = UI.CreateFrame("RiftCheckbox", "f.cb1", main_fragframe)
		table.insert(fragframe.cb,cb)
		fragframe.cb[i]:SetLayer(11)
		fragframe.cb[i]:SetChecked(true)
		fragframe.cb[i].Text = UI.CreateFrame("Text", "f.cb.Text", main_fragframe)
		fragframe.cb[i].Text:SetLayer(11)
		fragframe.cb[i].Text:SetText(returnAffinity(i))
		tooltip(fragframe.cb[i])
		fragframe.cb[i].tooltip = "match if type " .. returnAffinity(i)
		k = i - 1
		if i >= 4 then
			k = i - 2
		end
		fragframe.cb[i]:SetPoint("TOPLEFT", main_fragframe, "TOPLEFT", 190 + 60 * (k % 3),7 + math.floor(k /3) * 18)
		fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPLEFT",15,-3)
		if (i ~= 4) then
			fragframe.cb[i]:SetVisible(true)
			fragframe.cb[i].Text:SetVisible(true)
		else
			fragframe.cb[i]:SetVisible(false)
			fragframe.cb[i].Text:SetVisible(false)
		end
	end
	for i = 8,22 do
		local cb = UI.CreateFrame("RiftCheckbox", "f.cb2", pri_fragframe)
		table.insert(fragframe.cb,cb)
		fragframe.cb[i]:SetLayer(11)
		fragframe.cb[i]:SetChecked(true)
		fragframe.cb[i].Text = UI.CreateFrame("Text", "f.cb.Text", pri_fragframe)
		fragframe.cb[i].Text:SetLayer(11)
		k = i - 9
		if k >= 0 then
			fragframe.cb[i].Text:SetText(returnStatName(i - 8))
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "match if named " .. returnStatName(i - 8)
			if (k % 2) == 0 then
				fragframe.cb[i]:SetPoint("TOPLEFT", pri_fragframe, "TOPLEFT", 3,10 + math.floor(k / 2) * 18)
				fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPRIGHT",5,-3)
				fragframe.cb[i].Text:SetFontColor(1,1,1)
			else
				fragframe.cb[i]:SetPoint("TOPRIGHT",  pri_fragframe, "TOPRIGHT", -3,10 + math.floor(k / 2) * 18)
				fragframe.cb[i].Text:SetPoint("TOPRIGHT", fragframe.cb[i], "TOPLEFT",-5,-3)
				fragframe.cb[i].Text:SetFontColor(1,1,1)
			end
		else
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "When enabled use the settings in this box as well.\n"..
										"if set to AND then and fragments found will be \n"..
										"recycled if they match the main search AND this search.\n"..
										"if set to OR then the addon will also search for fragments\n"..
										"found from this search setting.\n"..
										"Looks for any fragment with a name from the list."
			fragframe.cb[i].Text:SetText("prime stat")
			fragframe.cb[i]:SetPoint("TOPLEFT", pri_fragframe, "TOPLEFT", 3,-8)
			fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPRIGHT",5,-3)
			fragframe.cb[i].Text:SetFontColor(1,1,1,1)
		end
		fragframe.cb[i]:SetVisible(true)
		fragframe.cb[i].Text:SetVisible(true)
	end
	for i = 23,37 do
		local cb = UI.CreateFrame("RiftCheckbox", "f.cb2", sec_fragframe)
		table.insert(fragframe.cb,cb)
		fragframe.cb[i]:SetLayer(11)
		fragframe.cb[i]:SetChecked(true)
		fragframe.cb[i].Text = UI.CreateFrame("Text", "f.cb.Text", sec_fragframe)
		fragframe.cb[i].Text:SetLayer(11)
		k = i - 24
		if k >= 0 then
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "match if stat includes " .. returnStat(i - 23)		
			fragframe.cb[i].Text:SetText(returnStat(i - 23))
			if (k % 2) == 0 then
				fragframe.cb[i]:SetPoint("TOPLEFT", sec_fragframe, "TOPLEFT", 3,10 + math.floor(k / 2) * 18)
				fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPRIGHT",5,-3)
			else
				fragframe.cb[i]:SetPoint("TOPRIGHT",  sec_fragframe, "TOPRIGHT", -3,10 + math.floor(k / 2) * 18)
				fragframe.cb[i].Text:SetPoint("TOPRIGHT", fragframe.cb[i], "TOPLEFT",-5,-3)
			end
		else
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "When enabled use the settings in this box as well.\n"..
										"if set to AND then and fragments found will be \n"..
										"recycled if they match the main search AND this search.\n"..
										"if set to OR then the addon will also search for fragments\n"..
										"found from this search setting.\n"..
										"Looks for any fragment with any stat from the list."
			fragframe.cb[i].Text:SetText("any stat")
			fragframe.cb[i]:SetPoint("TOPLEFT", sec_fragframe, "TOPLEFT", 3,-8)
			fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPRIGHT",5,-3)
		end
		fragframe.cb[i]:SetVisible(true)
		fragframe.cb[i].Text:SetVisible(true)
	end
	for i = 38,39 do
		local cb = UI.CreateFrame("RiftCheckbox", "f.cb3", fragframe)
		table.insert(fragframe.cb,cb)
		fragframe.cb[i]:SetLayer(11)
		fragframe.cb[i]:SetChecked(true)
		fragframe.cb[i].Text = UI.CreateFrame("Text", "f.cb.Text", fragframe)
		fragframe.cb[i].Text:SetLayer(11)
		k = i - 38
		if (k % 2) == 0 then
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "include fragmnets found in the fragment inventory"		
			fragframe.cb[i].Text:SetText("recycle fragment inv")
			fragframe.cb[i]:SetPoint("TOPLEFT", fragframe, "TOPLEFT", 23,239)
			fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPRIGHT",5,-3)
		else
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "include fragmnets found in the bag inventory"		
			fragframe.cb[i].Text:SetText("recycle bag inv")
			fragframe.cb[i]:SetPoint("TOPLEFT",  fragframe, "TOPLEFT", 208,239)
			fragframe.cb[i].Text:SetPoint("TOPLEFT", fragframe.cb[i], "TOPRIGHT",-5,-3)
		end
		fragframe.cb[i]:SetVisible(true)
		fragframe.cb[i].Text:SetVisible(true)
	end


		for i = 40,41 do
		local cb = UI.CreateFrame("RiftCheckbox", "f.cb4",pri_fragframe)
		table.insert(fragframe.cb,cb)
		fragframe.cb[i]:SetLayer(11)
		fragframe.cb[i]:SetChecked(false)
		fragframe.cb[i].Text = UI.CreateFrame("Text", "f.cb.Text", fragframe)
		fragframe.cb[i].Text:SetLayer(11)
		if i  == 40 then
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "if they match the main search AND this search."
			fragframe.cb[i].Text:SetText("AND")
			fragframe.cb[i].Text:SetPoint("TOPRIGHT", pri_fragframe, "TOPRIGHT",-3,-11)
			fragframe.cb[i]:SetPoint("TOPRIGHT",  fragframe.cb[i].Text, "TOPLEFT", 0,3)
		else
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "if they match the main search OR this search."
			fragframe.cb[i].Text:SetText("OR")
			fragframe.cb[i].Text:SetPoint("TOPRIGHT", fragframe.cb[i-1], "TOPLEFT",-3,-3)
			fragframe.cb[i]:SetPoint("TOPRIGHT",  fragframe.cb[i].Text, "TOPLEFT", 0,3)
			fragframe.cb[i]:SetChecked(true)
		end
		fragframe.cb[i]:SetVisible(true)
		fragframe.cb[i].Text:SetVisible(true)
	end

	for i = 42,43 do
		local cb = UI.CreateFrame("RiftCheckbox", "f.cb4",sec_fragframe)
		table.insert(fragframe.cb,cb)
		fragframe.cb[i]:SetLayer(11)
		fragframe.cb[i]:SetChecked(false)
		fragframe.cb[i].Text = UI.CreateFrame("Text", "f.cb.Text", fragframe)
		fragframe.cb[i].Text:SetLayer(11)
		if i  == 42 then
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "if they match the main search AND this search."		
			fragframe.cb[i].Text:SetText("AND")
			fragframe.cb[i].Text:SetPoint("TOPRIGHT", sec_fragframe, "TOPRIGHT",-3,-11)
			fragframe.cb[i]:SetPoint("TOPRIGHT",  fragframe.cb[i].Text, "TOPLEFT", 0,3)
		else
			tooltip(fragframe.cb[i])
			fragframe.cb[i].tooltip = "if they match the main search OR this search."
			fragframe.cb[i].Text:SetText("OR")
			fragframe.cb[i].Text:SetPoint("TOPRIGHT", fragframe.cb[i-1], "TOPLEFT",-3,-3)
			fragframe.cb[i]:SetPoint("TOPRIGHT",  fragframe.cb[i].Text, "TOPLEFT", 0,3)
			fragframe.cb[i]:SetChecked(true)
		end
		fragframe.cb[i]:SetVisible(true)
		fragframe.cb[i].Text:SetVisible(true)
	end	
	
	local cb8 = fragframe.cb[8]
	function cb8.Event:CheckboxChange()
		if (fragframe.cb[8]:GetChecked()) then
			for i = 9,22 do
				fragframe.cb[i]:SetEnabled(true)
				fragframe.cb[i].Text:SetFontColor(1,1,1)
			end
			for i = 40,41 do
				fragframe.cb[i]:SetEnabled(true)
				fragframe.cb[i].Text:SetFontColor(1,1,1)
			end			
		else
			for i = 9,22 do
				fragframe.cb[i]:SetEnabled(false)
				fragframe.cb[i].Text:SetFontColor(0.8,0.8,0.8)
			end
			for i = 40,41 do
				fragframe.cb[i]:SetEnabled(false)
				fragframe.cb[i].Text:SetFontColor(0.8,0.8,0.8)
			end
		end
	end
	local cb23 = fragframe.cb[23]
	function cb23.Event:CheckboxChange()
		if (fragframe.cb[23]:GetChecked()) then
			for i = 24,37 do
				fragframe.cb[i]:SetEnabled(true)
				fragframe.cb[i].Text:SetFontColor(1,1,1)				
			end
			for i = 42,43 do
				fragframe.cb[i]:SetEnabled(true)
				fragframe.cb[i].Text:SetFontColor(1,1,1)
			end			
		else
			for i = 24,37 do
				fragframe.cb[i]:SetEnabled(false)
				fragframe.cb[i].Text:SetFontColor(0.8,0.8,0.8)
			end
			for i = 42,43 do
				fragframe.cb[i]:SetEnabled(false)
				fragframe.cb[i].Text:SetFontColor(0.8,0.8,0.8)
			end
		end
	end

	local cb40 = fragframe.cb[40]
	function cb40.Event:CheckboxChange()
		if (fragframe.cb[40]:GetChecked()) then	
			if (fragframe.cb[41]:GetChecked() == true) then
				fragframe.cb[41]:SetChecked(false)
			end
		else
			if (fragframe.cb[41]:GetChecked() == false) then
				fragframe.cb[41]:SetChecked(true)
			end
		end
	end
	local cb41 = fragframe.cb[41]
	function cb41.Event:CheckboxChange()
		if (fragframe.cb[41]:GetChecked()) then	
			if (fragframe.cb[40]:GetChecked() == true) then
				fragframe.cb[40]:SetChecked(false)
			end
		else
			if (fragframe.cb[40]:GetChecked() == false) then
				fragframe.cb[40]:SetChecked(true)
			end
		end
	end
	local cb42 = fragframe.cb[42]
	function cb42.Event:CheckboxChange()
		if (fragframe.cb[42]:GetChecked()) then	
			if (fragframe.cb[43]:GetChecked() == true) then
				fragframe.cb[43]:SetChecked(false)
			end
		else
			if (fragframe.cb[43]:GetChecked() == false) then
				fragframe.cb[43]:SetChecked(true)
			end
		end
	end
	local cb43 = fragframe.cb[43]
	function cb43.Event:CheckboxChange()
		if (fragframe.cb[43]:GetChecked()) then	
			if (fragframe.cb[42]:GetChecked() == true) then
				fragframe.cb[42]:SetChecked(false)
			end
		else
			if (fragframe.cb[42]:GetChecked() == false) then
				fragframe.cb[42]:SetChecked(true)
			end
		end
	end
	
	
	fragframe.sl = {}
	for i = 1,3 do
		local sl = UI.CreateFrame("RiftSlider", "f.sl", main_fragframe)
		table.insert(fragframe.sl,sl)
		fragframe.sl[i]:SetLayer(11)
		fragframe.sl[i]:SetWidth(100)
		fragframe.sl[i]:SetPoint("TOPLEFT", main_fragframe, "TOPLEFT", 10,-13 +i * 18)
		fragframe.sl[i]:SetVisible(true)
		-- fragframe.sl[i].Text1 = UI.CreateFrame("Text", "f.sl.Text", fragframe)
		-- fragframe.sl[i].Text1:SetLayer(11)
		-- fragframe.sl[i].Text1:SetPoint("TOPLEFT", fragframe.sl[i], "TOPLEFT",-5,-20)
		-- fragframe.sl[i].Text1:SetText(tostring(i))
		-- fragframe.sl[i].Text1:SetVisible(true)
		-- fragframe.sl[i].Text2 = UI.CreateFrame("Text", "f.sl.Text", fragframe)
		-- fragframe.sl[i].Text2:SetLayer(11)
		-- fragframe.sl[i].Text2:SetPoint("TOPRIGHT", fragframe.sl[i], "TOPRIGHT",5,-20)
		-- fragframe.sl[i].Text2:SetText(tostring(i))
		-- fragframe.sl[i].Text2:SetVisible(true)
		fragframe.sl[i].Label = UI.CreateFrame("Text", "f.sl.Text", fragframe)
		fragframe.sl[i].Label:SetLayer(11)
		fragframe.sl[i].Label:SetPoint("CENTERLEFT", fragframe.sl[i], "CENTERRIGHT",10,-10)
		fragframe.sl[i].Label:SetText("Label")
		tooltip(fragframe.sl[i])
		fragframe.sl[i].Label:SetVisible(true)
	end

	fragframe.sl[1].tooltip = "search for fragmnets of this level or worse"
	fragframe.sl[2].tooltip = "search for this level or worse"
	fragframe.sl[3].tooltip = "search for this tier or higher"
	
	local slider1 = fragframe.sl[1]
	slider1:SetRange(1,6)
	function slider1.Event:SliderChange()
		fragframe.sl[1].Label:SetText(returnRarity(fragframe.sl[1]:GetPosition()))
		fragframe.sl[1].Label:SetFontColor(returnRarityCol(fragframe.sl[1]:GetPosition()))
	end
	slider1.Event:SliderChange()

	local slider2 = fragframe.sl[2]
	slider2:SetRange(0,15)
	slider2:SetPosition(0)
	function slider2.Event:SliderChange()
		fragframe.sl[2].Label:SetText("Level " .. tostring(fragframe.sl[2]:GetPosition()))
	end
	slider2.Event:SliderChange()
	
	local slider3 = fragframe.sl[3]
	slider3:SetRange(1,6)
	function slider3.Event:SliderChange ()
		fragframe.sl[3].Label:SetText("Tier " .. tostring(7 - fragframe.sl[3]:GetPosition()))
	end
	slider3.Event:SliderChange()

	fragframe:SetVisible(false)
	moveFrame(fragframe)
	
	
	btnframe = UI.CreateFrame("Frame", "btnframe", frame_context)
	btnframe.mouseDown	= false
	btnframe.mouseOffsetX = 0
	btnframe.mouseOffsetY = 0
	btnframe.framelock = btniconlock
	btnframe.Width = btniconsize
	btnframe.Height = btniconsize
	if btnRecycleFrameX then btnframe.FrameX = btnRecycleFrameX else btnframe.FrameX = (UIParent:GetWidth() / 2) - (btnframe.Width / 2) end
	if btnRecycleFrameY then btnframe.FrameY = btnRecycleFrameY else btnframe.FrameY = (UIParent:GetHeight() / 2) - (btnframe.Height / 2)	 end

	btnframe:SetLayer(21)
	if (btniconbackground) then
		btnframe:SetBackgroundColor(1,1,1,0.5)
	else
		btnframe:SetBackgroundColor(0,0,0,0)
	end
	btnframe:SetWidth(btnframe.Width)
	btnframe:SetHeight(btnframe.Height)
	btnframe:SetPoint(0,0,UIParent,0,0,btnframe.FrameX,btnframe.FrameY)
	
	btnframe.icon = UI.CreateFrame("Texture", "f.icon", btnframe)
	btnframe.icon:SetLayer(2)
	btnframe.icon:SetVisible(true)
	btnframe.icon:SetPoint("TOPLEFT", btnframe, "TOPLEFT", 0, 0)	
--	btnframe.icon:SetTexture("fragRecycle", "textures/buttonicon.png")
	btnframe.icon:SetTexture("fragRecycle", "textures/buttonicon_128x128.png")
	btnframe.icon:SetWidth(btnframe.Width)
	btnframe.icon:SetHeight(btnframe.Height)	
	btnframe:SetVisible(true)
	moveFrame(btnframe)

	function btnframe.Event:LeftDown()
		if fragframe:GetVisible() then
			fragframe:SetVisible(false)
		else
			fragframe:SetVisible(true)
		end
	end
	
--	okframe = UI.CreateFrame("RiftWindow", "okframe", frame_context)
	okframe = UI.CreateFrame("Frame", "okframe", frame_context)
	okframe.mouseDown	= false
	okframe.mouseOffsetX = 0
	okframe.mouseOffsetY = 0
	okframe.Width = 320
	okframe.Height = 100
	okframe.FrameX = (UIParent:GetWidth() / 2) - (okframe.Width / 2)
	okframe.FrameY = (UIParent:GetHeight() / 2) - (okframe.Height / 2)


	okframe:SetLayer(21)
	okframe:SetBackgroundColor(1,1,1,0.5)

	okframe:SetWidth(okframe.Width)
	okframe:SetHeight(okframe.Height)
	okframe:SetPoint(0,0,UIParent,0,0,okframe.FrameX,okframe.FrameY)

	okframe.icon = UI.CreateFrame("Texture", "f.icon", okframe)
	okframe.icon:SetLayer(2)
	okframe.icon:SetVisible(true)
	okframe.icon:SetPoint("TOPLEFT", okframe, "TOPLEFT", 0, 0)	
	okframe.icon:SetTexture("Rift", "bg_item_package_purple.png.dds")
	okframe.icon:SetWidth(okframe.Width)
	okframe.icon:SetHeight(okframe.Height)	

	okframe.Text = UI.CreateFrame("Text", "f.cb.Text", okframe)
	okframe.Text:SetLayer(11)
	okframe.Text:SetFontSize(16)
	okframe.Text:SetText(tostring(okframe.Text:GetFontSize()))
	okframe.Text:SetPoint("CENTER", okframe, "CENTER", 0,-20)
	okframe.Text:SetVisible(true)
	
	okframe.btn = {}
	for i = 1,2 do
		local btn = UI.CreateFrame("RiftButton", "f.btn", okframe)
		table.insert(okframe.btn,btn)
		okframe.btn[i]:SetWidth(120)
		okframe.btn[i]:SetLayer(11)
		if i == 1 then
			okframe.btn[i]:SetPoint("BOTTOMLEFT", okframe, "BOTTOMLEFT", 20,-10)
		else
			okframe.btn[i]:SetPoint("BOTTOMRIGHT", okframe, "BOTTOMRIGHT", -20,-10)
		end
		okframe.btn[i]:SetText("text")
		okframe.btn[i]:SetVisible(true)
	end
	okframe.btn[1]:SetText("OK")
	okframe.btn[2]:SetText("Cancel")
	
	local btn1 = okframe.btn[1]
	function btn1.Event:LeftPress()
		okframe:SetVisible(false)	
		okframe.mouseDown	= false
		okframe.mouseOffsetX = 0
		okframe.mouseOffsetY = 0
		okframe.FrameX = (UIParent:GetWidth() / 2) - (okframe.Width / 2)
		okframe.FrameY = (UIParent:GetHeight() / 2) - (okframe.Height / 2)
		okframe:SetPoint(0,0,UIParent,0,0,okframe.FrameX,okframe.FrameY)
		Command.Fragment.Recycle(recycle_table)
	end
	local btn2 = okframe.btn[2]
	function btn2.Event:LeftPress()
		okframe:SetVisible(false)
		okframe.mouseDown	= false
		okframe.mouseOffsetX = 0
		okframe.mouseOffsetY = 0
		okframe.FrameX = (UIParent:GetWidth() / 2) - (okframe.Width / 2)
		okframe.FrameY = (UIParent:GetHeight() / 2) - (okframe.Height / 2)
		okframe:SetPoint(0,0,UIParent,0,0,okframe.FrameX,okframe.FrameY)
	end

	moveFrame(okframe)		
	okframe:SetVisible(false)	
end

function tooltip(frame)
	function frame.Event:MouseIn()
		if showtooltips then
			if frame.tooltip ~= nil then
				tooltipframe:SetPoint("BOTTOMLEFT",frame,"TOPRIGHT",40,-40)
				tooltipframe.text:SetText(tostring(frame.tooltip))
				tooltipframe:SetVisible(true)
			end
		end
	end
	function frame.Event:MouseOut()
		tooltipframe:SetVisible(false)
	end
end

function moveFrame(frame)
--	local frame = target--:GetParent()
	function frame.Event:RightDown()
		if (frame.framelock == false) then
			frame.mouseDown = true
			--print(mouseDown)
			SHmouse = Inspect.Mouse()
			frame.mouseOffsetX = frame.FrameX - SHmouse.x
			frame.mouseOffsetY = frame.FrameY - SHmouse.y
		end
	end
	function frame.Event:RightUp()
		frame.mouseDown = false
		saveLoc()
		--print(mouseDown)
	end
	function frame.Event:RightUpoutside()
		frame.mouseDown = false
		saveLoc()
		--print(mouseDown)
	end
	function frame.Event:MouseMove()
		if frame.mouseDown then
			SHmouse = Inspect.Mouse()
			SHnewX = SHmouse.x + frame.mouseOffsetX
			SHnewY = SHmouse.y + frame.mouseOffsetY

			frame:ClearAll()
			frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", tonumber(SHnewX), tonumber(SHnewY))
			frame:SetWidth(frame.Width)
			frame:SetHeight(frame.Height)
			frame.FrameX = SHnewX
			frame.FrameY = SHnewY					
		end
	end
end


function recycle()
-- generate table containing all frags from inv and bag that we are using
	if not useinv then
		if not usebags then 
			print("nothing to do")
			return
		end
	end
	local frag_table = {}
	recycle_table = {}
	if useinv then
		local items = Inspect.Item.Detail( Utility.Item.Slot.Fragments())
		for k,v in pairs(items) do
			table.insert(frag_table,k)
		end
	end
	if usebags then
		local items = Inspect.Item.Detail(Utility.Item.Slot.Inventory())
		for k,v in pairs(items) do
			local item_details = Inspect.Item.Detail(k)
			if item_details.fragmentAffinity ~= nil then
				table.insert(frag_table,k)
			end
		end
	end
	
	if table.getn(frag_table) == 0 then
		print("no fragments found")
		return
	end	

	
	local Rarity_tbl = {}
	for x = 1, fragmentRarity do
		table.insert(Rarity_tbl, returnRarity(x))
	end
	local _fragmentTier = (7 - fragmentTier)
	local primary_tbl = {}
	for i = 9,22 do
		k = i - 8
		if primeStats[k + 1] == true then
			table.insert(primary_tbl, returnStatName(k))
		end
	end
	local secondary_tbl = {}
	for i = 24,37 do
		k = i - 23
		if secondStats[k + 1] == true then
			table.insert(secondary_tbl, returnStat(k))
		end
	end
	
	for k,id in pairs(frag_table) do
		local fragmentAffinity_found = false
		local fragmentRarity_found = false
		local infusionLevel_found = false
		local fragmentTier_found = false
		local primeStats_found = false
		local secondStats_found = false
		
		local item_details = Inspect.Item.Detail(id)
		if item_details.rarity == nil then item_details.rarity = "common" end

		if fragmentAffinity[item_details.fragmentAffinity] then fragmentAffinity_found = true end
		for key, rare in pairs(Rarity_tbl) do
			if item_details.rarity == rare then fragmentRarity_found = true end
		end
		if tonumber(item_details.infusionLevel) <= infusionLevel then infusionLevel_found = true end
		if tonumber(item_details.fragmentTier) >= _fragmentTier then fragmentTier_found = true end
		--print(item_details.fragmentTier,_fragmentTier,fragmentTier,fragmentTier_found)
		if (primeStats[1]) then
			local nSplit = split(item_details.name,"%S+")
			for key, val in pairs(primary_tbl) do
				if nSplit[1] == val then primeStats_found = true end
			end
		end
		if (secondStats[1]) then
			for stat_key, stat_val in pairs(item_details.stats) do			
				for key, val in pairs(secondary_tbl) do
					if stat_key == val then secondStats_found = true end
				end
			end
		end
				
		-- print(fragmentAffinity_found)
		-- print(fragmentRarity_found)
		-- print(infusionLevel_found)
		-- print(fragmentTier_found)
		-- print(primeStats_found)
		-- print(secondStats_found)
		local found_flag = false
		if (fragmentAffinity_found and
			fragmentRarity_found and
			infusionLevel_found and
			fragmentTier_found) then
			if (primeStats[1] == false) and (secondStats[1] == false) then found_flag = true end
			if (primeStats[1]) then
				if (pri_andorMode == true) then -- or mode
					if (primeStats_found) then found_flag = true end
					primeStats_found  = true
				end
			else primeStats_found = true end
			if (secondStats[1]) then
				print(sec_andorMode)
				if (sec_andorMode == true) then -- or mode
					if (secondstats_found) then found_flag = true end
					secondStats_found = true
				end
			else secondStats_found = true end
			if (primeStats_found and secondStats_found) then found_flag = true end
		else	-- failed check first check so see if we have any secondry OR checks that pass
			if (primeStats[1]) then
				if (pri_andorMode == true) then -- or mode
					if (primeStats_found) then found_flag = true end
				end
			end
			--print(secondStats[1],sec_andorMode,secondstats_found)
			if (secondStats[1]) then
				if (sec_andorMode == true) then -- or mode
					if (secondStats_found == true) then
						found_flag = true
					end
				end
			end
		end
		if (found_flag) then
			table.insert(recycle_table,item_details.id)
--			print(item_details.id)
		end
	end
	if table.getn(recycle_table) > 0 then
		local outtext = "You are about to recycle "
		if table.getn(recycle_table) == 1 then
			outtext = outtext .. "1 fragment"
		else
			outtext = outtext .. tostring(table.getn(recycle_table)) .. " fragmnets"
		end	
		okframe.Text:SetText(outtext)
		okframe:SetVisible(true)
	else
		print("no fragments found to recycle")
	end
end

function find_empty_bag_slot(bagnumber, slotnumber)
	MAXBAGS = 8
	if(not(slotnumber))then
		slotnumber = 1
	end
	if(not(bagnumber))then
		bagnumber = 1
	end
	for bag = bagnumber, MAXBAGS do
		local item_details = Inspect.Item.Detail(Utility.Item.Slot.Inventory("bag",bag))
		if item_details ~= nil then
			bagsize = item_details.slots
			for slot = slotnumber, bagsize do
				item = Inspect.Item.Detail(Utility.Item.Slot.Inventory(bag,slot))
				if item == nil then
					return bag, slot
				end
			end
		end
		slotnumber = 1
	end
	return nil
end

function find_empty_frag_slot(fragnumber)
	MAXFRAGS = 200
	if(not(fragnumber))then
		fragnumber = 1
	end
	for frag = fragnumber, MAXFRAGS do
		item = Inspect.Item.Detail(Utility.Item.Slot.Fragments(frag))
		if item == nil then
			return frag
		end
	end
	return nil
end

function fags_to_bags()
	local bag = 1
	local slot = 1
	
	for frag_inv_no = 1, 200 do
		local frag = Inspect.Item.Detail(Utility.Item.Slot.Fragments(frag_inv_no))
		if frag ~= nil then
			bag, slot = find_empty_bag_slot(bag, slot)
			if bag == nil then return end
--			print(tostring(bag) .. "	" .. tostring(slot))
			local inv_loc = Utility.Item.Slot.Inventory(bag,slot)
			local frag_loc = Utility.Item.Slot.Fragments(frag_inv_no)
			Command.Item.Move(frag_loc, inv_loc)
			slot = slot + 1
		end
	end
end		

function fags_to_inv()
	local items = Inspect.Item.Detail( Utility.Item.Slot.Inventory())

	local frag_inv_no = 1
	for inv_loc,v in pairs(items) do
		local item_details = Inspect.Item.Detail(inv_loc)
		if item_details.fragmentAffinity then
--			print(frag_inv_no)
			frag_inv_no = find_empty_frag_slot(frag_inv_no)
			if frag_inv_no == nil then return end
			local frag_loc = Utility.Item.Slot.Fragments(frag_inv_no)
			Command.Item.Move(inv_loc, frag_loc)
			frag_inv_no = frag_inv_no + 1
		end
	end
end	
local function help_msg()
	print(AddonId .. "	" .. Info.toc.Version .. "\n" ..
			"Type:-\n" ..
			"/fragrecycle lock \t\t to lock the button frame so it can't be dragged by the mouse.\n" ..
			"/fragrecycle unlock \t\t to unlock the button frame.\n" ..
			"/fragrecycle background \t turns on the button frame background.\n" ..
			"/fragrecycle nobackground \t turns off the button frame background.\n" ..
			"/fragrecycle btnsize XX \t to set the size of the button frame where XX is a number \n" ..
			"\t\t\t\t\t\t between 10-60, 40 is about 80% height of a bar icon (default), \n" ..
			"\t\t\t\t\t\t 60 is LARGE, and 30 is about size of a buff icon.\n" ..
			"/fragrecycle reset \t\t to reset addon to default values.\n" ..
			"/fragrecycle help \t\t to display the help message (this)."
		)
end


local function fragrecycle(params)		
	if (params) then
		local pSplit = split(params,"%S+")
		local param_found = false
		for x = 1,table.getn(pSplit) do
			if pSplit[x] == "btnsize" then
				if (pSplit[x+1] ~= nil) then
					if tonumber(pSplit[x+1]) ~= nil then
						local pnum = tonumber(pSplit[x+1])
						if (pnum >= 10) and (pnum <= 60) then
							print("button frame size set to " .. tostring(pnum))
							btniconsize = pnum
							btnframe.Width = btniconsize
							btnframe.Height = btniconsize
							btnframe:SetWidth(btnframe.Width)
							btnframe:SetHeight(btnframe.Height)
							btnframe.icon:SetWidth(btnframe.Width)
							btnframe.icon:SetHeight(btnframe.Height)
							param_found = true
						end
					end
				end
			end
			if pSplit[x] == "lock" then
				print("button frame locked")
				btniconlock = true
				btnframe.framelock = btniconlock
				param_found = true
			end
			if pSplit[x] == "unlock" then
				print("button frame unlocked")
				btniconlock = false
				btnframe.framelock = btniconlock
				param_found = true
			end
			if pSplit[x] == "background" then
				print("button frame background on")
				btniconbackground = true
				btnframe:SetBackgroundColor(1,1,1,0.5)
				param_found = true
			end
			if pSplit[x] == "nobackground" then
				print("button frame background off")
				btniconbackground = false
				btnframe:SetBackgroundColor(0,0,0,0)
				param_found = true
			end
			if pSplit[x] == "reset" then
				print("everything reset")
				resetVariables()
				param_found = true
			end
			if pSplit[x] == "help" then
				help_msg()
				param_found = true
			end
		end
		if param_found == false then
			help_msg()
		end
	else
		help_msg()
	end
end
		
table.insert(Event.Addon.SavedVariables.Load.End, {inifragles, AddonId, "Addon Load"})
table.insert(Command.Slash.Register("fragrecycle"), {fragrecycle, AddonId, "fragrecycle"})
