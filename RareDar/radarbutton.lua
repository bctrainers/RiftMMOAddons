local miniWindow
local cycle, cyclepos
local lastCoordX = 0
local lastCoordZ = 0
local lastShownMessage = nil

local function yieldcheck()
   if (Inspect.Time.Real() >= RareDar.next_yield) then
      coroutine.yield()
      
      -- Set yield time 10 milli sec from now
      RareDar.next_yield = Inspect.Time.Real() + 0.01
   end
end

local function regBackground(form)
	form:SetBackgroundColor(0.1, 0.1, 0.1, RareDarConfig.alpha)
end
local function dragBackground(form)
	form:SetBackgroundColor(0.4, 0.4, 0.4, RareDarConfig.alpha)
end
local function blueBackground(form)
	form:SetBackgroundColor(0, 0, 1, RareDarConfig.alpha)
end
-- A array for the cycle data.
-- Format of the array is:
-- [1] xccord
-- [2] ycoord
-- [3] index
-- [4] zone
-- [5] rare name
-- [6] achiev
local function updatecycleinfo(i)
	if(miniWindow.cycle.positions==nil) then miniWindow.cycle.positions={} end
	local j=0
	local lineHeight=20
	for j,position in ipairs(cycle[i][1]) do
		if(miniWindow.cycle.positions[j]==nil) then
			miniWindow.cycle.positions[j]=UI.CreateFrame("Frame", "CycleMobPositions"..j, miniWindow.cycle)
			miniWindow.cycle.positions[j]:SetWidth(120)
			miniWindow.cycle.positions[j]:SetHeight(lineHeight)
			if (j==1) then
				miniWindow.cycle.positions[j]:SetPoint("TOPLEFT", miniWindow.cycle.mobArea, "BOTTOMLEFT", 0, 0)
			else
				miniWindow.cycle.positions[j]:SetPoint("TOPLEFT", miniWindow.cycle.positions[j-1], "BOTTOMLEFT", 0, 0)
			end
			miniWindow.cycle.positions[j].xpos=UI.CreateFrame("Text", "CycleMobXPos"..j, miniWindow.cycle.positions[j])
			miniWindow.cycle.positions[j].ypos=UI.CreateFrame("Text", "CycleMobYPos"..j, miniWindow.cycle.positions[j])
			miniWindow.cycle.positions[j].xpos:SetWidth(60)
			miniWindow.cycle.positions[j].ypos:SetWidth(60)
			miniWindow.cycle.positions[j].xpos:SetHeight(lineHeight)
			miniWindow.cycle.positions[j].ypos:SetHeight(lineHeight)
			miniWindow.cycle.positions[j].xpos:SetFontSize(14)
			miniWindow.cycle.positions[j].ypos:SetFontSize(14)
			if(j%2==1) then
				miniWindow.cycle.positions[j].xpos:SetFontColor(0,1,1)
				miniWindow.cycle.positions[j].ypos:SetFontColor(0,1,1)
			else
				miniWindow.cycle.positions[j].xpos:SetFontColor(1,1,0)
				miniWindow.cycle.positions[j].ypos:SetFontColor(1,1,0)
			end
			regBackground(miniWindow.cycle.positions[j])
			miniWindow.cycle.positions[j].xpos:SetPoint("TOPLEFT", miniWindow.cycle.positions[j], "TOPLEFT", 0, 0)
			miniWindow.cycle.positions[j].ypos:SetPoint("TOPRIGHT", miniWindow.cycle.positions[j], "TOPRIGHT", 0, 0)
			miniWindow.cycle.positions[j]:SetSecureMode("restricted")
			miniWindow.cycle.positions[j].Event.LeftClick=function()
				if RareDar.secureMode then return end
				Command.Map.Waypoint.Set(tonumber(miniWindow.cycle.positions[j].xpos:GetText(),10),tonumber(miniWindow.cycle.positions[j].ypos:GetText(),10))
			end
			miniWindow.cycle.positions[j].Event.MouseIn=function()
				blueBackground(miniWindow.cycle.positions[j])
			end
			miniWindow.cycle.positions[j].Event.MouseOut=function()
				regBackground(miniWindow.cycle.positions[j])
			end
		end
		miniWindow.cycle.positions[j].xpos:SetText(tostring(position[1]))
		miniWindow.cycle.positions[j].ypos:SetText(tostring(position[2]))
		if(not miniWindow.cycle.positions[j]:GetVisible()) then
			miniWindow.cycle.positions[j]:SetVisible(true)
		end
	end
	local totalPositions=#cycle[i][1]
	local prevPositions=#miniWindow.cycle.positions
	for j=totalPositions+1,prevPositions,1 do
		miniWindow.cycle.positions[j]:SetVisible(false)
	end
	local totalHight=lineHeight*(totalPositions+2)
	miniWindow.cycle:SetHeight(totalHight)
	miniWindow.cycle.rightshift:SetHeight(totalHight)
	miniWindow.cycle.leftshift:SetHeight(totalHight)
	miniWindow.cycle.mobName:SetText(cycle[i][5])
	miniWindow.cycle.mobArea:SetText(cycle[i][4])
	miniWindow.cycle.mobName.Event.LeftDown="/target "..cycle[i][5]
	if (cycle[i][6] == true) then
		miniWindow.cycle.mobName:SetFontColor(0, 1, 0)
	elseif (cycle[i][6] == false) then
		miniWindow.cycle.mobName:SetFontColor(1, 0.5, 0.5)
	else
		miniWindow.cycle.mobName:SetFontColor(1, 1, 1)
	end
end

local function showZoneMenu()
   if RareDar.secureMode then
      return
   end
   for i, label in ipairs(miniWindow.zoneMenu) do
      label:SetVisible(true)
   end
   miniWindow.cycle:SetVisible(false)
end

local function hideZoneMenu()
   if RareDar.secureMode then
      return
   end
   for i, label in ipairs(miniWindow.zoneMenu) do
      label:SetVisible(false)
   end
end

function RareDar.showMiniWindow()
   if RareDar.secureMode then
      print("disabled during combat.")
      return
   end
   RareDarConfig.show = true
   miniWindow:SetVisible(true)
   print("showing main window.")
end

function RareDar.hideMiniWindow()
   if RareDar.secureMode then
      print("disabled during combat.")
      return
   end
   RareDarConfig.show = false
   miniWindow:SetVisible(false)
   print("hiding main window.")
end

local function zoneMenuClick(zonename)
	if RareDar.secureMode then return end
	hideZoneMenu()
	local lang=Inspect.System.Language()
	cycle={}

    for i, zone in ipairs(RareDar.data) do
		if zone.zone[lang] == zonename then
			for j, mob in ipairs(zone.mobs) do
				if mob.pos[1] then
					local tmpinfo={};
					tmpinfo[1]=mob.pos			-- xy coords
					tmpinfo[2]=0				-- old stuff
					tmpinfo[3]=0				-- old stuff
					tmpinfo[4]=zonename
					tmpinfo[5]=mob.targ[lang]
					tmpinfo[6]=mob.killed
					table.insert(cycle, tmpinfo)
				end
			end
		end
    end
   
	cyclepos=1
	updatecycleinfo(cyclepos)
	miniWindow.cycle:SetVisible(true)
end

local function cycleLeft()
   if RareDar.secureMode then return end
   if cyclepos==1 then cyclepos=#cycle else cyclepos=cyclepos-1 end
   updatecycleinfo(cyclepos)
end

local function cycleRight()
   if RareDar.secureMode then return end
   if cyclepos==#cycle then cyclepos=1 else cyclepos=cyclepos+1 end
   updatecycleinfo(cyclepos)
end

function refreshMiniWindow()
	regBackground(miniWindow)
	regBackground(miniWindow.cycle.mobName)
	regBackground(miniWindow.cycle.mobArea)
	regBackground(miniWindow.cycle.leftshift)
	regBackground(miniWindow.cycle.rightshift)
	for i,zone in ipairs(miniWindow.zoneMenu) do
		regBackground(zone)
	end
	if(miniWindow.cycle.positions~=nil) then
		for i,position in ipairs(miniWindow.cycle.positions) do
			regBackground(position)
		end
	end
end

local function buildMiniWindow()
    miniWindow=UI.CreateFrame("Frame", "RareDar", context)
    miniWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RareDarConfig.xpos, RareDarConfig.ypos)
    miniWindow:SetWidth(150)
    miniWindow:SetHeight(50)
    regBackground(miniWindow)
    miniWindow:SetVisible(RareDarConfig.show)
    miniWindow:SetSecureMode("restricted")
    miniWindow.state={}
    function miniWindow.Event:LeftDown()
        if RareDar.secureMode then return end
        miniWindow.state.mouseDown = true
        local mouse = Inspect.Mouse()
        miniWindow.state.startX = miniWindow:GetLeft()
        miniWindow.state.startY = miniWindow:GetTop()
        miniWindow.state.mouseStartX = mouse.x
        miniWindow.state.mouseStartY = mouse.y
        dragBackground(miniWindow)
    end

    function miniWindow.Event:MouseMove()
        if RareDar.secureMode then return end
        if (miniWindow.state.mouseDown and (not RareDarConfig.locked)) then
	    local mouse = Inspect.Mouse()
	    RareDarConfig.xpos = mouse.x - miniWindow.state.mouseStartX + miniWindow.state.startX
 	    RareDarConfig.ypos = mouse.y - miniWindow.state.mouseStartY + miniWindow.state.startY
            miniWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
			     RareDarConfig.xpos, RareDarConfig.ypos)
        end
     end

    function miniWindow.Event:LeftUp()
        if miniWindow.state.mouseDown then
	    miniWindow.state.mouseDown = false
	    regBackground(miniWindow)
        end
    end

    function miniWindow.Event:RightClick()
        if (miniWindow.zoneMenu[1]:GetVisible() == true) then
            hideZoneMenu()
        else
			showZoneMenu()
        end
    end

	miniWindow.title = UI.CreateFrame("Text", "title", miniWindow)
	miniWindow.title:SetText("RareDar")
	miniWindow.title:SetPoint("CENTER", miniWindow, "TOPLEFT", 100, 25)
	miniWindow.title:SetFontSize(17)
	miniWindow.title:SetWidth(100);

	miniWindow.itembtn = UI.CreateFrame("Texture", "itembtn", miniWindow)
	miniWindow.itembtn:SetPoint("TOPLEFT", miniWindow, "TOPLEFT", 0, 0)
	miniWindow.itembtn:SetWidth(50)
	miniWindow.itembtn:SetHeight(50)
	miniWindow.itembtn:SetTexture("RareDar", "radarred.png")
	miniWindow.itembtn:SetSecureMode("restricted")
	miniWindow.itembtn.Event.RightClick = miniWindow.Event.RightClick

	miniWindow.cycle=UI.CreateFrame("Frame", "Cycle", miniWindow)
	miniWindow.cycle:SetWidth(150)
	miniWindow.cycle:SetVisible(false)
	miniWindow.cycle:SetPoint("TOPLEFT", miniWindow, "BOTTOMLEFT", 0, 0)
	miniWindow.cycle:SetSecureMode("restricted")

	miniWindow.cycle.mobName=UI.CreateFrame("Text", "CycleMobName", miniWindow.cycle)
	miniWindow.cycle.mobName:SetWidth(120)
	miniWindow.cycle.mobName:SetHeight(20)
	miniWindow.cycle.mobName:SetFontSize(14)
	regBackground(miniWindow.cycle.mobName)
	miniWindow.cycle.mobName:SetPoint("TOPLEFT", miniWindow.cycle, "TOPLEFT", 15, 0)
	miniWindow.cycle.mobName:SetSecureMode("restricted")

	miniWindow.cycle.mobArea=UI.CreateFrame("Text", "CycleMobArea", miniWindow.cycle)
	miniWindow.cycle.mobArea:SetWidth(120)
	miniWindow.cycle.mobArea:SetHeight(20)
	miniWindow.cycle.mobArea:SetFontSize(14)
	regBackground(miniWindow.cycle.mobArea)
	miniWindow.cycle.mobArea:SetPoint("TOPLEFT", miniWindow.cycle.mobName, "BOTTOMLEFT", 0, 0)

	miniWindow.cycle.leftshift=UI.CreateFrame("Texture", "CycleLeft", miniWindow.cycle)
	miniWindow.cycle.leftshift:SetWidth(15)
	miniWindow.cycle.leftshift:SetTexture("RareDar", "arrowleft.png")
	regBackground(miniWindow.cycle.leftshift)
	miniWindow.cycle.leftshift:SetPoint("TOPLEFT", miniWindow.cycle, "TOPLEFT", 0, 0)
	miniWindow.cycle.leftshift.Event.LeftClick=cycleLeft

	miniWindow.cycle.rightshift=UI.CreateFrame("Texture", "CycleRight", miniWindow.cycle)
	miniWindow.cycle.rightshift:SetWidth(15)
	miniWindow.cycle.rightshift:SetTexture("RareDar", "arrowright.png")
	regBackground(miniWindow.cycle.rightshift)
	miniWindow.cycle.rightshift:SetPoint("TOPRIGHT", miniWindow.cycle, "TOPRIGHT", 0, 0)
	miniWindow.cycle.rightshift.Event.LeftClick=cycleRight

	miniWindow.zoneMenu = {}

	local lang = Inspect.System.Language()
	local zoneNames = {}
	local zoneFound = true

	for i, zone in ipairs(RareDar.data) do
		table.insert(zoneNames, zone.zone[lang])
	end

	table.sort(zoneNames);
	if (next(zoneNames) == nil) then
		table.insert(zoneNames, "Missing zone names in ")
		table.insert(zoneNames, lang.." localization")
		zoneFound = false
	end
	for i,name in ipairs(zoneNames) do
		miniWindow.zoneMenu[i]=UI.CreateFrame("Text", "menu"..i, miniWindow)
		miniWindow.zoneMenu[i]:SetText(name)
		miniWindow.zoneMenu[i]:SetFontSize(14)
		miniWindow.zoneMenu[i]:SetWidth(150)
		miniWindow.zoneMenu[i]:SetVisible(false)
		regBackground(miniWindow.zoneMenu[i])
		if (i==1) then
			miniWindow.zoneMenu[i]:SetPoint("TOPLEFT", miniWindow, "BOTTOMLEFT", 0, 0)
		else
			miniWindow.zoneMenu[i]:SetPoint("TOPLEFT", miniWindow.zoneMenu[i-1], "BOTTOMLEFT", 0, 0)
		end
		if zoneFound then
			miniWindow.zoneMenu[i].Event.LeftClick=function()
				zoneMenuClick(name)
			end
			miniWindow.zoneMenu[i].Event.MouseIn=function()
				blueBackground(miniWindow.zoneMenu[i])
			end
			miniWindow.zoneMenu[i].Event.MouseOut=function()
				regBackground(miniWindow.zoneMenu[i])
			end
		end
	end
end

function RareDar.SetTargetMacro(list)
    local str = ""
    local n=0
    for i, name in ipairs(list) do
	n=i
        str = str .. "target " .. name .. "\n"
    end

    if (str ~= "") then
        miniWindow.itembtn:SetTexture("RareDar", "radargreen.png")
        miniWindow.title:SetText("RareDar")
    else
        miniWindow.itembtn:SetTexture("RareDar", "radarred.png")
        miniWindow.title:SetText("RareDar (" .. n .. ")")
    end

    
    miniWindow.itembtn.Event.LeftDown = str
end

function RareDar.SetCloseMobs()
    if (not RareDar.secureMode) then
        local player = Inspect.Unit.Detail("player");
        if (player.zone ~= nil
        and player.coordX ~= nil 
        and player.coordY ~= nil
        and ((math.abs(player.coordX - lastCoordX) >= 20) or
	     (math.abs(player.coordZ - lastCoordZ) >= 20))) then
            local lang = Inspect.System.Language()
            local moblist = {}
            local zoneName=Inspect.Zone.Detail(player.zone).name
            local message=""
	    local explain=""
         
            for i, zone in ipairs(RareDar.data) do
		if zone.zone[lang] == zoneName then
		    for j, mob in ipairs(zone.mobs) do
			-- print ("check mob "..j..": "..mob.targ[lang])
		        -- yieldcheck()
		        local close=false
		        for k, pos in ipairs(mob.pos) do
                            local xdist = math.abs(player.coordX - pos[1])
                            local zdist = math.abs(player.coordZ - pos[2])
      	                    if (xdist <= 80 and zdist <= 80) then
                                close=true
                            end
                        end
                        -- print ("close = ".. (close and "true" or "false"))
                        if close then
			    table.insert(moblist, mob.targ[lang])
			    if message == "" then
				message="Possible nearby Mobs: "
			    else
			        message=message..", "
			    end
			    message=message..mob.targ[lang]
			    if (mob.killed) then
				message=message.."(already killed)"
			    end
			    if (mob.comment[lang] and mob.comment[lang] ~= "") then
				explain=explain..mob.targ[lang]..": "..mob.comment[lang].."\n"
			    end
			end
                    end
                end
            end
            RareDar.SetTargetMacro(moblist)
            if (message ~= "" and message ~= lastShownMessage) then
		print (message)
		if (explain ~= "") then
			print(explain)
		end
            end
            lastShownMessage=message

            lastCoordX = player.coordX;
            lastCoordZ = player.coordZ;
        end
    end
end

function RareDar.createUI()
    context = UI.CreateContext("RareDar")
    context:SetSecureMode("restricted")

    if (miniWindow == nil) then
        buildMiniWindow()
    end
end
