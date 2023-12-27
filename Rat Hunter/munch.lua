local addonInfo, private = ...

local munch_tiles = {
	{1036,840},           {1044,840},{1048,840},                                 {1064,840},{1068,840},           {1076,840},
	{1036,844},           {1044,844},{1048,844},                                 {1064,844},{1068,844},{1072,844},{1076,844},
	{1036,848},{1040,848},{1044,848},{1048,848},{1052,848},{1056,848},{1060,848},{1064,848},{1068,848},{1072,848},{1076,848},
	{1036,852},           {1044,852},{1048,852},                                 {1064,852},{1068,852},{1072,852},{1076,852},
	{1036,856},{1040,856},{1044,856},{1048,856},                                 {1064,856},{1068,856},{1072,856},{1076,856},
	{1036,860},{1040,860},{1044,860},{1048,860},                                 {1064,860},{1068,860},{1072,860},{1076,860},
	{1036,864},           {1044,864},{1048,864},                                 {1064,864},{1068,864},{1072,864},{1076,864},
	{1036,868},{1040,868},{1044,868},{1048,868},{1052,868},{1056,868},{1060,868},{1064,868},{1068,868},{1072,868},{1076,868},
	{1036,872},           {1044,872},{1048,872},                                 {1064,872},{1068,872},{1072,872},{1076,872},
	{1036,876},           {1044,876},{1048,876},                                 {1064,876},{1068,876},           {1076,876},
}

-- Window top left corner matches coordinates (1021, 823)
-- The whole window is a 70 unit square


private.InitMunchTab = function(settings, main_window)
	local munch_tab = {}
	
	-- Create frames
	munch_tab.frame = UI.CreateFrame("Texture", "RH_munch.frame", main_window.frame)
	munch_tab.frame:SetTexture("RatHunter", "textures/munchmaze_background.png")
	munch_tab.frame:SetPoint("TOPLEFT", main_window.frame, "TOPLEFT")
	munch_tab.frame:SetPoint("BOTTOMRIGHT", main_window.frame, "BOTTOMRIGHT")
	
	munch_tab.reset = UI.CreateFrame("Texture", "RH_munch.reset", munch_tab.frame)
	munch_tab.reset:SetTexture("RatHunter", "textures/munchmaze_reset.png")
	munch_tab.reset:SetPoint(0, 0, munch_tab.frame, 22/25, 22/25)
	munch_tab.reset:SetPoint(1, 1, munch_tab.frame, 24/25, 24/25)
	
	munch_tab.player = UI.CreateFrame("Texture", "RH_munch.player", munch_tab.frame)
	munch_tab.player:SetTexture("RatHunter", "textures/indicator_self.png")
	
	munch_tab.tiles = {}
	local ts = 0.7  -- tile size
	for index, coords in ipairs(munch_tiles) do
		munch_tab.tiles[index] = UI.CreateFrame("Frame", "RH_tiles[i]" .. tostring(index), munch_tab.frame)
		munch_tab.tiles[index]:SetBackgroundColor(0, 210/225, 1)
		munch_tab.tiles[index]:SetPoint(0, 0, munch_tab.frame, (coords[1] - 1021 - ts) / 70, (coords[2] - 823 - ts) / 70)
		munch_tab.tiles[index]:SetPoint(1, 1, munch_tab.frame, (coords[1] - 1021 + ts) / 70, (coords[2] - 823 + ts) / 70)
	end
	
	-- Define local functions
	local function OnResetLeftClick(self, h)
		for index, frame in ipairs(munch_tab.tiles) do
			frame:SetVisible(true)
		end
	end
	
	local function OnUnitMove()
		local player = Inspect.Unit.Detail("player")
		
		if player.coordX then
			-- Clamp coordinates to window
			player.coordX = math.min(math.max(1021, player.coordX), 1091)
			player.coordZ = math.min(math.max(823, player.coordZ), 893)
			
			-- Move player indicator
			munch_tab.player:SetPoint(0, 0, munch_tab.frame, (player.coordX - 1021 - 2) / 70, (player.coordZ - 823 - 2) / 70)
			munch_tab.player:SetPoint(1, 1, munch_tab.frame, (player.coordX - 1021 + 2) / 70, (player.coordZ - 823 + 2) / 70)
			
			-- Hide tiles
			for index, coords in ipairs(munch_tiles) do
				if coords[1] + 2 > player.coordX and coords[1] - 2 < player.coordX and 
				coords[2] + 2 > player.coordZ and coords[2] - 2 < player.coordZ and 
				munch_tab.tiles[index]:GetVisible() then
					munch_tab.tiles[index]:SetVisible(false)
				end
			end
		end
	end
	
	local function SetActive(active)
		munch_tab.frame:SetVisible(active)
		
		if active then
			OnResetLeftClick(nil, nil)
			OnUnitMove()
			
			Command.Event.Attach(Event.Unit.Add, OnUnitMove, "RH_munch_OnUnitAdd")
			Command.Event.Attach(Event.Unit.Detail.Coord, OnUnitMove, "RH_munch_OnUnitCoord")
		else
			Command.Event.Detach(Event.Unit.Add, nil, "RH_munch_OnUnitAdd")
			Command.Event.Detach(Event.Unit.Detail.Coord, nil, "RH_munch_OnUnitCoord")
		end
	end
	
	-- Assign local functions
	munch_tab.reset:EventAttach(Event.UI.Input.Mouse.Left.Click, OnResetLeftClick, "RH_munch_onResetLeftClick")
	munch_tab.SetActive = SetActive
	munch_tab.ResetTiles = OnResetLeftClick
	munch_tab.color = {172/255, 147/255, 157/255}
	
	SetActive(false)
	return munch_tab
end

