local addonInfo, private = ...

local function SetButtonTexture(frame, active)
	if active then
		frame:SetTexture("RatHunter", "textures/Button_active.png")
	else
		frame:SetTexture("RatHunter", "textures/Button_inactive.png")
	end	
end

private.InitButton = function(settings, main_window)
	-- Create button
	local button = {}
	button.context = UI.CreateContext("RH_button.context")
	button.frame = UI.CreateFrame("Texture", "RH_button.frame", button.context)
	button.frame.moving = false
	settings.ba = true
	SetButtonTexture(button.frame, settings.ba)
	
	-- Define local functions
	local function OnLeftClick(self, h)
		if not main_window.context:GetVisible() then
			main_window.context:SetVisible(true)
			main_window.ActivateTab(1)
		else
			main_window.context:SetVisible(false)
			main_window.ActivateTab(0)
		end
	end
	
	local function OnCursorMove(self, h)
		local mouseData = Inspect.Mouse()
		self:SetPoint(0, 0, UIParent, 0, 0, mouseData.x-self.ofx, mouseData.y-self.ofy)
	end
	
	local function OnLeftDown(self, h)
		self.moving = true
		
		local mouseData = Inspect.Mouse()
		self.ofx = mouseData.x-self:GetLeft()
		self.ofy = mouseData.y-self:GetTop()
		
		button.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, OnCursorMove, "RH_button_cursorMove")
	end
	
	local function OnLeftUp(self, h)
		self.moving = false
		local mouseData = Inspect.Mouse()
		settings.bx = mouseData.x-self.ofx
		settings.by = mouseData.y-self.ofy
		
		button.frame:EventDetach(Event.UI.Input.Mouse.Cursor.Move, nil, "RH_button_cursorMove")
	end
	
	local function OnRightClick(self, h)
		settings.ba = not settings.ba
		SetButtonTexture(button.frame, settings.ba)
		
		-- Detach all left mouse button events
		button.frame:EventDetach(Event.UI.Input.Mouse.Left.Click, nil, "RH_button_leftClick")
		button.frame:EventDetach(Event.UI.Input.Mouse.Left.Down, nil, "RH_button_leftDown")
		button.frame:EventDetach(Event.UI.Input.Mouse.Left.Up, nil, "RH_button_leftUp")
		button.frame:EventDetach(Event.UI.Input.Mouse.Cursor.Move, nil, "RH_button_cursorMove")
		
		-- Attach correct mouse button events
		if settings.ba then
			button.frame:EventAttach(Event.UI.Input.Mouse.Left.Click, OnLeftClick, "RH_button_leftClick")
		else
			button.frame:EventAttach(Event.UI.Input.Mouse.Left.Down, OnLeftDown, "RH_button_leftDown")
			button.frame:EventAttach(Event.UI.Input.Mouse.Left.Up, OnLeftUp, "RH_button_leftUp")
		end
	end
	
	-- Assign event functions
	button.frame:EventAttach(Event.UI.Input.Mouse.Left.Click, OnLeftClick, "RH_button_leftClick")
	button.frame:EventAttach(Event.UI.Input.Mouse.Right.Click, OnRightClick, "RH_button_rightClick")
	
	return button
end

