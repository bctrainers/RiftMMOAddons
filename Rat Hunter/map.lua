local addonInfo, private = ...

-- Window top left corner matches coordinates (961, 546)
-- The whole window is a 500 unit square

--[[
	{1110, 674 - 20}, -- Start
	{1110, 674}, -- Checkpoint 1
	{1156, 698}, -- Checkpoint 2
	{1312, 650}, -- Checkpoint 3
	{1296, 690}, -- Checkpoint 4
	{1360, 658}, -- Checkpoint 5
	{1328, 706}, -- Checkpoint 6
	{1348, 728}, -- Checkpoint 7
	{1407, 769}, -- Checkpoint 8
	{1328, 866}, -- Checkpoint 9
	{1344, 946}, -- Checkpoint 10
	{1424, 882}, -- Checkpoint 11
	{1312, 850}, -- Checkpoint 12
	{1264, 859}, -- Checkpoint 13
	{1097, 858}, -- Checkpoint 14
	{1024, 858}, -- Checkpoint 15
	{ 992, 852}, -- Checkpoint 16
	{1071, 793}, -- Checkpoint 17
	{1103, 729}, -- Checkpoint 18
	{1160, 674}, -- Checkpoint 19
	{1101, 674}, -- Finish
]]--


local dungeon_run_coords = {
	{label = "S",  coords = {1157, 674}, y = nil}, -- Start
	{label = "1",  coords = {1148, 674}, y = nil}, -- Checkpoint 1
	{label = "2",  coords = {1110, 674}, y = nil}, -- Checkpoint 2
	{label = "3",  coords = {1156, 698}, y = nil}, -- Checkpoint 3
	{label = "4",  coords = {1311, 650}, y = nil}, -- Checkpoint 4
	{label = "5",  coords = {1296, 690}, y = nil}, -- Checkpoint 5
	{label = "6",  coords = {1360, 658}, y = nil}, -- Checkpoint 6
	{label = "7",  coords = {1328, 706}, y = nil}, -- Checkpoint 7
	{label = "8",  coords = {1348, 728}, y = nil}, -- Checkpoint 8
	{label = "9",  coords = {1407, 769}, y = nil}, -- Checkpoint 9
	{label = "10", coords = {1328, 866}, y = nil}, -- Checkpoint 10
	{label = "11", coords = {1344, 947}, y = nil}, -- Checkpoint 11
	{label = "12", coords = {1424, 882}, y = nil}, -- Checkpoint 12
	{label = "13", coords = {1312, 850}, y = nil}, -- Checkpoint 13
	{label = "14", coords = {1264, 859}, y = nil}, -- Checkpoint 14
	{label = "15", coords = {1097, 858}, y = nil}, -- Checkpoint 15
	{label = "16", coords = {1024, 858}, y = nil}, -- Checkpoint 16
	{label = "17", coords = { 992, 852}, y = 800}, -- Checkpoint 17
	{label = "18", coords = {1071, 793}, y = nil}, -- Checkpoint 18
	{label = "19", coords = {1103, 731}, y = nil}, -- Checkpoint 19
	{label = "F",  coords = {1157, 674}, y = nil}, -- Finish
}


private.InitMapTab = function(settings, main_window)
	local map_tab = {}
	
	-- Create frames
	map_tab.frame = UI.CreateFrame("Texture", "RH_map.frame", main_window.frame)
	map_tab.frame:SetTexture("RatHunter", "textures/Rat_map.png")
	map_tab.frame:SetPoint("TOPLEFT", main_window.frame, "TOPLEFT")
	map_tab.frame:SetPoint("BOTTOMRIGHT", main_window.frame, "BOTTOMRIGHT")
	
	map_tab.run_toggle = UI.CreateFrame("Texture", "RH_munch.run_toggle", map_tab.frame)
	map_tab.run_toggle:SetTexture("RatHunter", "textures/map_run_toggle.png")
	map_tab.run_toggle:SetPoint(0, 0, map_tab.frame, 1/25, 22/25)
	map_tab.run_toggle:SetPoint(1, 1, map_tab.frame, 3/25, 24/25)
	
	map_tab.player = UI.CreateFrame("Texture", "RH_map.player", map_tab.frame)
	map_tab.player:SetTexture("RatHunter", "textures/indicator_self.png")
	map_tab.player:SetLayer(100)
	
	map_tab.target = UI.CreateFrame("Texture", "RH_map.target", map_tab.frame)
	map_tab.target:SetTexture("RatHunter", "textures/indicator_target.png")
	map_tab.player:SetLayer(100)
	
	-- Create dungeon run frames
	map_tab.run_index = nil
	map_tab.tiles = {}
	for index, info in ipairs(dungeon_run_coords) do
		map_tab.tiles[index] = UI.CreateFrame("Texture", "RH_runTiles[" .. tostring(index) .. "]", map_tab.frame)
		map_tab.tiles[index]:SetTexture("RatHunter", "textures/dungeon_run/Path_" .. info.label .. ".png")
		map_tab.tiles[index]:SetPoint("TOPLEFT", map_tab.frame, "TOPLEFT")
		map_tab.tiles[index]:SetPoint("BOTTOMRIGHT", map_tab.frame, "BOTTOMRIGHT")
	end
	
	-- Define local functions
	local function SetTileOpacity(index)
		-- Finish condition - passed Checkpoint 19 and current index is at finish line
		if map_tab.run_index ~= nil and dungeon_run_coords[index].label == "F" and map_tab.run_index > 19 then
			map_tab.run_index = nil
		end
		
		-- Show/hide all tiles
		for index, info in ipairs(dungeon_run_coords) do
			map_tab.tiles[index]:SetVisible(map_tab.run_index ~= nil)
		end
		
		-- Exit condition - tiles hidden, no more work
		if map_tab.run_index == nil then return end
		
		-- If progressing checkpoint, set new opacity. Ignore finish line
		if index > map_tab.run_index and dungeon_run_coords[index].label ~= "F" then
			map_tab.run_index = index
			for i, info in ipairs(dungeon_run_coords) do
				if i == index then
					map_tab.tiles[i]:SetAlpha(1)
				elseif i == index + 1 then
					map_tab.tiles[i]:SetAlpha(0.9)
				elseif i == index + 2 then
					map_tab.tiles[i]:SetAlpha(0.4)
				else
					map_tab.tiles[i]:SetAlpha(0)
				end
			end
		end
	end
	
	local function OnUnitMove()
		local player = Inspect.Unit.Detail("player")
		local target = Inspect.Unit.Detail("player.target")
		if target == nil then 
			target={}
			map_tab.target:SetVisible(false) 
		else
			map_tab.target:SetVisible(true) 
		end
		
		if player.coordX then
			-- Clamp coordinates to window
			player.coordX = math.min(math.max(961, player.coordX), 1461)
			player.coordZ = math.min(math.max(546, player.coordZ), 1046)
			
			-- Move player indicator
			map_tab.player:SetPoint(0, 0, map_tab.frame, (player.coordX - 961 - 10) / 500, (player.coordZ - 546 - 10) / 500)
			map_tab.player:SetPoint(1, 1, map_tab.frame, (player.coordX - 961 + 10) / 500, (player.coordZ - 546 + 10) / 500)
			
			-- Tile toggling for dungeon run
			if map_tab.run_index ~= nil then
				for index, info in ipairs(dungeon_run_coords) do
					if info.coords[1] + 4 > player.coordX and info.coords[1] - 4 < player.coordX and 
					info.coords[2] + 4 > player.coordZ and info.coords[2] - 4 < player.coordZ then
						-- If no coordY is specified, or the coords match, trigger index.
						if info.y == nil or (info.y + 4 > player.coordY and info.y - 4 < player.coordY) then
							SetTileOpacity(index)
						end
					end
				end
			end
		end
		
		if target.coordX then
			-- Clamp coordinates to window
			target.coordX = math.min(math.max(961, target.coordX), 1461)
			target.coordZ = math.min(math.max(546, target.coordZ), 1046)
		
			-- Move target indicator
			map_tab.target:SetPoint(0, 0, map_tab.frame, (target.coordX - 961 - 10) / 500, (target.coordZ - 546 - 10) / 500)
			map_tab.target:SetPoint(1, 1, map_tab.frame, (target.coordX - 961 + 10) / 500, (target.coordZ - 546 + 10) / 500)
		end
	end
	
	local function ToggleDungeonRun(active)
		-- Handle oppacity and tile tracking
		if active then
			map_tab.run_index = 0
		else
			map_tab.run_index = nil
		end
		
		SetTileOpacity(1)
	end
	
	local function OnRunToggleLeftClick(h, self)
		ToggleDungeonRun(map_tab.run_index == nil)
	end
	
	local function SetActive(active)
		map_tab.frame:SetVisible(active)
		ToggleDungeonRun(false)
		
		if active then
			OnUnitMove()
			
			Command.Event.Attach(Event.Unit.Add, OnUnitMove, "RH_map_OnUnitAdd")
			Command.Event.Attach(Event.Unit.Detail.Coord, OnUnitMove, "RH_map_OnUnitCoord")
		else
			Command.Event.Detach(Event.Unit.Add, nil, "RH_map_OnUnitAdd")
			Command.Event.Detach(Event.Unit.Detail.Coord, nil, "RH_map_OnUnitCoord")
		end
	end
	
	-- Assign local functions
	map_tab.run_toggle:EventAttach(Event.UI.Input.Mouse.Left.Click, OnRunToggleLeftClick, "RH_munch_onRunToggleLeftClick")
	
	map_tab.SetActive = SetActive
	map_tab.color = {28/255, 26/255, 20/255}
	
	SetActive(false)
	return map_tab
end

