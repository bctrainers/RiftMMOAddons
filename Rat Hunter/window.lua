local addonInfo, private = ...


local function InitTabs(settings, main_window)
	main_window.tabs = {}
	main_window.tab_frames = {}
	
	main_window.ActivateTab = function(index)
		for i, t in ipairs(main_window.tabs) do
			t.SetActive(false)
		end
		if 0 < index and index <= #main_window.tabs then
			main_window.tabs[index].SetActive(true)
		end
	end
	
	main_window.AddTab = function(tab)
		local index = #main_window.tabs + 1
		
		table.insert(main_window.tabs, index, tab)
		local frame = UI.CreateFrame("Frame", "RH_tabs.tab_" .. tostring(index), main_window.context)
		frame:SetBackgroundColor(tab.color[1], tab.color[2], tab.color[3])
		
		frame:SetPoint(0, 0, main_window.frame, (80 / 500) * (index - 1), -(20 / 500))
		frame:SetPoint(1, 1, main_window.frame, (80 / 500) * (index), 0)
		
		local function OnLeftClick(self, h)
			main_window.ActivateTab(index)
		end
		
		frame:EventAttach(Event.UI.Input.Mouse.Left.Click, OnLeftClick, "RH_tabs.tab_" .. tostring(index) .. "_leftClick")
	end
end


private.InitWindow = function(settings)
	local window = {}
	
	window.context = UI.CreateContext("RH_window.context")
	window.context:SetVisible(false)
	
	window.frame = UI.CreateFrame("Frame", "RH_window.frame", window.context)
	
	-- Define local functions
	local function OnCursorMove(self, h)
		local mouseData = Inspect.Mouse()
		self:SetPoint(0, 0, UIParent, 0, 0, mouseData.x-self.ofx, mouseData.y-self.ofy)
	end
	
	local function OnLeftDown(self, h)
		self.moving = true
		
		local mouseData = Inspect.Mouse()
		self.ofx = mouseData.x-self:GetLeft()
		self.ofy = mouseData.y-self:GetTop()
		
		window.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, OnCursorMove, "RH_window_cursorMove")
	end
	
	local function OnLeftUp(self, h)
		self.moving = false
		local mouseData = Inspect.Mouse()
		settings.wx = mouseData.x-self.ofx
		settings.wy = mouseData.y-self.ofy
		
		window.frame:EventDetach(Event.UI.Input.Mouse.Cursor.Move, nil, "RH_window_cursorMove")
	end
	
	-- Assign local functions
	window.frame:EventAttach(Event.UI.Input.Mouse.Left.Down, OnLeftDown, "RH_window_leftDown")
	window.frame:EventAttach(Event.UI.Input.Mouse.Left.Up, OnLeftUp, "RH_window_leftUp")
	
	InitTabs(settings, window)
	return window
end




