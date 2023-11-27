local RH_button = {}
local RH_window = {}
local RH_tiles = {}
local RH_settings = {
	bx=UIParent:GetWidth()/2,
	by=UIParent:GetHeight()/2,
	ba=true,
	wx=UIParent:GetWidth()/2,
	wy=UIParent:GetHeight()/2,
	wstate="rat",
	size=1,
}
local RH_info = {
	munch_tiles = {
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
	},
	
}
--activation button
function RH_ButtonInit()
	RH_button.context = UI.CreateContext("RH_button.context")
	RH_button.frame = UI.CreateFrame("Texture","RH_button.frame",RH_button.context)
	RH_button.frame.moving = false
	
	if RH_settings.ba then
		RH_button.frame:SetTexture("RatHunter","Button_active.png")
	else
		RH_button.frame:SetTexture("RatHunter","Button_inactive.png")
	end	

	RH_button.frame:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self,h)
		self.moving = true
		local mouseData = Inspect.Mouse()
		self.ofx = mouseData.x-self:GetLeft()
		self.ofy = mouseData.y-self:GetTop()
		
		RH_button.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self,h)
			if self.moving == true and RH_settings.ba == false then
			local mouseData = Inspect.Mouse()
			self:SetPoint(0,0,UIParent,0,0,mouseData.x-self.ofx,mouseData.y-self.ofy) end
		end, "Button move")
	
	end, "Button move left down")
	RH_button.frame:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self,h)
		if self.moving == true then
			self.moving = false
			local mouseData = Inspect.Mouse()
			RH_settings.bx=mouseData.x-self.ofx
			RH_settings.by=mouseData.y-self.ofy
		end
	
		RH_button.frame:EventDetach(Event.UI.Input.Mouse.Cursor.Move, function(self,h)
			if self.moving == true and RH_settings.ba == false then
			local mouseData = Inspect.Mouse()
			self:SetPoint(0,0,UIParent,0,0,mouseData.x-self.ofx,mouseData.y-self.ofy) end
		end, "Button move")
	
	end, "Button move left up")


	RH_button.frame:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self,h)
		if 	RH_settings.ba then
			if RH_window.context:GetVisible() then RH_window.context:SetVisible(false)
			else RH_window.context:SetVisible(true) end
		end
	end,"Button left click")
	RH_button.frame:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self,h)
		if RH_settings.ba then 
			RH_settings.ba = false
			RH_button.frame:SetTexture("RatHunter","Button_inactive.png")
		else
			RH_settings.ba = true
			RH_button.frame:SetTexture("RatHunter","Button_active.png")
		end
	end,"Button right click")

end

--main map window, tabs
function RH_WindowInit()
	RH_window.context = UI.CreateContext("RH_window.context")
	RH_window.context:SetVisible(false)

	RH_window.frame = UI.CreateFrame("Frame","RH_window.frame",RH_window.context)
	--RH_window.frame:SetTexture("RatHunter","Rat_map.png") 
	
	RH_window.frame:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self,h)
		self.moving = true
		local mouseData = Inspect.Mouse()
		self.ofx = mouseData.x-self:GetLeft()
		self.ofy = mouseData.y-self:GetTop()
	
		RH_window.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self,h)
			if self.moving then
			local mouseData = Inspect.Mouse()
			self:SetPoint(0,0,UIParent,0,0,mouseData.x-self.ofx,mouseData.y-self.ofy) end
		end, "Button move")
	end, "Button move left down")
	RH_window.frame:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self,h)
		if self.moving then
			self.moving = false
			local mouseData = Inspect.Mouse()
			RH_settings.wx=mouseData.x-self.ofx
			RH_settings.wy=mouseData.y-self.ofy
		end
	
		RH_window.frame:EventDetach(Event.UI.Input.Mouse.Cursor.Move, function(self,h)
			if self.moving then
			local mouseData = Inspect.Mouse()
			self:SetPoint(0,0,UIParent,0,0,mouseData.x-self.ofx,mouseData.y-self.ofy) end
		end, "Button move")
	end, "Button move left up")
	
end

function RH_RatInit()
	RH_window.rat = UI.CreateFrame("Texture","RH_window.rat",RH_window.context)
	RH_window.rat:SetTexture("RatHunter","Rat_map.png")

	RH_window.target = UI.CreateFrame("Texture","RH_window.target",RH_window.rat)
	RH_window.target:SetTexture("RatHunter","indicator_target.png")

	RH_window.self = UI.CreateFrame("Texture","RH_window.self",RH_window.rat)
	RH_window.self:SetTexture("RatHunter","indicator_self.png")
	
	
end

function RH_MunchInit()
	RH_window.munch = UI.CreateFrame("Texture","RH_window.munch",RH_window.frame)
	RH_window.munch:SetTexture("RatHunter","munchmaze.png")
	
	RH_window.self_m = UI.CreateFrame("Texture","RH_window.self_m",RH_window.munch)
	RH_window.self_m:SetTexture("RatHunter","indicator_self.png")
	
	RH_window.reset = UI.CreateFrame("Frame","RH_window.self_m",RH_window.munch)
	RH_window.reset:SetPoint(0,0,RH_window.munch,22/25,22/25)
	--RH_window.reset:SetBackgroundColor(1,0,0,0.5)
	
	RH_window.reset:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self,h)
		--print("munch reset")
		for i,v in pairs(RH_info.munch_tiles) do
			RH_tiles[i]:SetVisible(true)
		end
	end,"Button left click")
	
end

function RH_MunchTilesInit()
	for i,v in pairs(RH_info.munch_tiles) do
		RH_tiles[i]=UI.CreateFrame("Frame","RH_tiles[i]"..i,RH_window.munch)
		RH_tiles[i]:SetBackgroundColor(0,210/225,1)
		RH_tiles[i]:SetPoint(0.5,0.5,RH_window.munch, (v[1]-1021)/70 , (v[2]-823)/70 )
		RH_tiles[i].done = false
	end
	
end

function RH_TabInit()
	RH_window.tab_rat = UI.CreateFrame("Frame","RH_window.tab_rat",RH_window.context)
	RH_window.tab_rat:SetBackgroundColor(28/255,26/255,20/255)
	RH_window.tab_rat:SetPoint(0,1,RH_window.frame,0,0)
	
	RH_window.tab_rat:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self,h)
		RH_window.rat:SetVisible(true)
		RH_window.munch:SetVisible(false)
		RH_settings.wstate = "rat"
		RH_UnitUpdate(); RH_Place()
	end, "Rat tab left click")
	
	
	RH_window.tab_munch = UI.CreateFrame("Frame","RH_window.tab_munch",RH_window.context)
	RH_window.tab_munch:SetBackgroundColor(172/255,147/255,157/255)
	RH_window.tab_munch:SetPoint(0,0,RH_window.tab_rat,1,0)
	
	RH_window.tab_munch:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self,h)
		RH_window.rat:SetVisible(false)
		RH_window.munch:SetVisible(true)
		RH_settings.wstate = "munch"
		RH_UnitUpdate(); RH_Place()
	end, "Munch tab left click")
end

RH_ButtonInit()
RH_WindowInit()
RH_RatInit()
RH_MunchInit()
RH_MunchTilesInit()
RH_TabInit()

--global functions 

function RH_Place()
	--button
	RH_button.frame:SetPoint(0,0,UIParent,0,0,RH_settings.bx,RH_settings.by)
	
	--window
	RH_window.frame:SetPoint(0,0,UIParent,0,0,RH_settings.wx,RH_settings.wy)
	RH_window.frame:SetWidth(RH_settings.size*500)
	RH_window.frame:SetHeight(RH_settings.size*500)
	
	--window rat
	RH_window.rat:SetWidth(RH_settings.size*500)
	RH_window.rat:SetHeight(RH_settings.size*500)
	RH_window.rat:SetPoint(0,0,RH_window.frame,0,0)
	
	RH_window.target:SetWidth(RH_settings.size*20)
	RH_window.target:SetHeight(RH_settings.size*20)
	
	RH_window.self:SetWidth(RH_settings.size*20)
	RH_window.self:SetHeight(RH_settings.size*20)
	
	--window munch
	RH_window.munch:SetWidth(RH_settings.size*500)
	RH_window.munch:SetHeight(RH_settings.size*500)
	RH_window.munch:SetPoint(0,0,RH_window.frame,0,0)
	
	RH_window.self_m:SetWidth(RH_settings.size*30)
	RH_window.self_m:SetHeight(RH_settings.size*30)
	
	RH_window.reset:SetWidth(RH_settings.size*40)
	RH_window.reset:SetHeight(RH_settings.size*40)
	
	for i,v in pairs(RH_info.munch_tiles) do
		RH_tiles[i]:SetWidth(RH_settings.size*12)
		RH_tiles[i]:SetHeight(RH_settings.size*12)
	end
	
	--tabs
	RH_window.tab_rat:SetWidth(RH_settings.size*80)
	RH_window.tab_rat:SetHeight(RH_settings.size*20)
	RH_window.tab_munch:SetWidth(RH_settings.size*80)
	RH_window.tab_munch:SetHeight(RH_settings.size*20)
	
	if RH_settings.wstate == "rat" then
		RH_window.rat:SetVisible(true)
		RH_window.munch:SetVisible(false)
	elseif RH_settings.wstate == "munch" then
		RH_window.rat:SetVisible(false)
		RH_window.munch:SetVisible(true)
	end
end

function RH_TableMerge(a,b) 
	for k,v in pairs(b) do
		a[k]=v
	end
end

function RH_UnitUpdate()
	local player = Inspect.Unit.Detail("player")
	local target = Inspect.Unit.Detail("player.target")
	if target == nil then target={}; RH_window.target:SetVisible(false) end
	if RH_settings.wstate == "rat" then
		if player.coordX then
			RH_window.self:SetPoint(.5,.5,RH_window.frame,0,0,(player.coordX-961)*RH_settings.size,(player.coordZ-546)*RH_settings.size)
			--print(player.coordX.." - "..player.coordZ) 
		end
	
		if target.coordX then
			RH_window.target:SetPoint(.5,.5,RH_window.frame,0,0,(target.coordX-961)*RH_settings.size,(target.coordZ-546)*RH_settings.size)
			RH_window.target:SetVisible(true)
		end	
	elseif RH_settings.wstate == "munch" then
		if player.coordX then
			RH_window.self_m:SetPoint(.5,.5,RH_window.frame,0,0,(player.coordX-1021)*RH_settings.size*50/7,(player.coordZ-823)*RH_settings.size*50/7)
			--print(player.coordX.." - "..player.coordZ) 
		end
		
		if player.coordX and RH_window.frame:GetVisible() and RH_settings.wstate == "munch" then
			for i,v in pairs(RH_info.munch_tiles) do
				if v[1]+2>player.coordX and v[1]-2<player.coordX and v[2]+2>player.coordZ and v[2]-2<player.coordZ then
				RH_tiles[i]:SetVisible(false)
				break
				end
			end
		end
	
	end
end

--global events


Command.Event.Attach(Command.Slash.Register("rathunter"), function (h, arg) 
	if arg==nil then 
		print("/rathunter scale - changes the size of main window")
		print("/rathunter munch - reset the munch maze pellets")
	elseif tonumber(arg) then RH_settings.size=tonumber(arg) 
	elseif arg=="munch" then
		for i,v in pairs(RH_info.munch_tiles) do
			RH_tiles[i]:SetVisible(true)
		end
	else print("Uncexpected input") 
	end
	
	
	if RH_settings.size>2 then RH_settings.size=2 end
	if RH_settings.size<0.2 then RH_settings.size=0.2 end
	RH_Place()
	RH_UnitUpdate()
end, "RH_SlashCommand" )

Command.Event.Attach(Event.Unit.Add,RH_UnitUpdate,"Locator update on unit add/remove")
Command.Event.Attach(Event.Unit.Detail.Coord,RH_UnitUpdate,"Locator update on unit coord change")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin,function(h,idef)
	if idef == "RatHunter" then
		RH_TableMerge(RHSettings,RH_settings) 
	end
end,"Saving global settings.")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,function(h,idef)
	if idef == "RatHunter" then
		if RHSettings==nil then RHSettings = RH_settings else RH_TableMerge(RH_settings,RHSettings) end
		RH_Place()
	end
end,"Saved variable import, then window placement.")
print("Rat Hunter successifully loaded.")
print("Use '/rathunter scale' to change the size of the window.")