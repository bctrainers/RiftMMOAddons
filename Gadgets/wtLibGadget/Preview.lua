--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v10.0
      Project Date (UTC)  : 2015-08-24T16:47:34Z
      File Modified (UTC) : 2015-08-24T14:01:21Z (Lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate
--for k,v in pairs(WT) do print(tostring(k).."="..tostring(v)) end
-- Events -----------------------------------------------------------------------------------------------------
WT.Event.Trigger.GadgetSelected_Preview, WT.Event.GadgetSelected_Preview = Utility.Event.Create(AddonId, "GadgetSelected_Preview")
---------------------------------------------------------------------------------------------------------------
WT.Previews ={}
WT.Preview = WT.Preview or {}
WT.Themes = {}

local gadgetsLocked_Preview = WT.Preview.gadgetsLocked_Preview or true

function WT.Preview.AttachHandle_Preview(previewId, frame, createOptions)

	-- Create the default (unthemed) movement handle
	local mvHandle = UI.CreateFrame("Texture", frame:GetName() .. "_mvHandle", WT.Context)
	mvHandle:SetLayer(9999)
	--mvHandle:SetBackgroundColor(1,1,1,1)

	-- Create the overlay frame to highlight the Preview when unlocked
	local mvBox = UI.CreateFrame("Frame", frame:GetName() .. "_mvBox", mvHandle)
	mvBox:SetLayer(9998)
	mvBox:SetPoint("TOPLEFT", frame, "TOPLEFT")
	mvBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	mvBox:SetBackgroundColor(1,1,1,1)

	-- Get the current frame position
	local currX = frame:GetLeft()
	local currY = frame:GetTop()

	-- Configure the default (unthemed) movement handle
	mvHandle:SetVisible(false)
	mvHandle:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self, h)
		WT.Preview.DragMove_Preview(mvHandle)
	end, "Event.UI.Input.Mouse.Cursor.Move")
	mvHandle:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self, h)
		WT.Preview.DragStart_Preview(mvHandle)
	end, "Event.UI.Input.Mouse.Left.Down")
	mvHandle:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self, h)
		WT.Preview.DragStop_Preview(mvHandle)
	end, "Event.UI.Input.Mouse.Left.Up")
	mvHandle:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function(self, h)
		WT.Preview.DragStop_Preview(mvHandle)
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	mvHandle.frame = frame
	mvHandle.previewId = previewId
	mvHandle:SetPoint("TOPLEFT", frame, "TOPLEFT")

	frame.gadgetOverlay = {}
	frame.gadgetOverlay.box = mvBox
	frame.gadgetOverlay.handle = mvHandle

	-- Setup the resizing handle if required
	if createOptions.resizable then
		local szHandle = UI.CreateFrame("Texture", frame:GetName() .. "_szHandle", mvHandle) -- child of mvHandle, so will show/hide automatically 
		szHandle:SetLayer(9999)
		szHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		szHandle:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self, h)
			WT.Preview.SizeMove_Preview(szHandle)
		end, "Event.UI.Input.Mouse.Cursor.Move")
		szHandle:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self, h)
			WT.Preview.SizeStart_Preview(szHandle)
		end, "Event.UI.Input.Mouse.Left.Down")
		szHandle:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self, h)
			WT.Preview.SizeStop_Preview(szHandle)
		end, "Event.UI.Input.Mouse.Left.Up")
		szHandle:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function(self, h)
			WT.Preview.SizeStop_Preview(szHandle)
		end, "Event.UI.Input.Mouse.Left.Upoutside")
		szHandle.frame = frame
		szHandle.previewId = previewId
		szHandle.minX, szHandle.minY, szHandle.maxX, szHandle.maxY = unpack(createOptions.resizable)  
		frame.gadgetOverlay.resizer = szHandle
	end
	
	WT.Preview[previewId].mvHandle = mvHandle
	WT.Preview[previewId].name = frame:GetName()

	-- Apply the selected theme to the overlay here
	--local selectedTheme = "subtle_preview"
	local theme = WT.Themes["subtle_preview"]
	theme.ApplyOverlayTheme(frame, createOptions)
	
	if WT.Preview[previewId].name == "icon" then
		frame:SetPoint("TOPLEFT", WT.Preview[previewId].Parent, "TOPLEFT", WT.Preview[previewId].config.iconPositionX or 0, WT.Preview[previewId].config.iconPositionY or 0) --UIParent
	end
	if WT.Preview[previewId].name == "labelCast" then
	--[[
					if WT.Preview[previewId].config.TextRight == true then 
				frame:SetPoint("TOPRIGHT", WT.Preview[previewId].Parent, "TOPLEFT",  WT.Preview[previewId].config.namePositionX/2 or 0,  WT.Preview[previewId].config.namePositionY or 0)
				else
				frame:SetPoint("TOPLEFT", WT.Preview[previewId].Parent, "TOPLEFT",  WT.Preview[previewId].config.namePositionX or 0,  WT.Preview[previewId].config.namePositionY or 0)
				end
				]]
		frame:SetPoint("TOPLEFT", WT.Preview[previewId].Parent, "TOPLEFT", WT.Preview[previewId].config.namePositionX or 0, WT.Preview[previewId].config.namePositionY or 0) --UIParent
	end
	if WT.Preview[previewId].name == "labelTime" then
		frame:SetPoint("TOPLEFT", WT.Preview[previewId].Parent, "TOPLEFT", WT.Preview[previewId].config.timePositionX or 0, WT.Preview[previewId].config.timePositionY or 0) --UIParent
	end
	
	if not gadgetsLocked_Preview then
		mvHandle:SetVisible(true) 
	end

end

function WT.Preview:DragStart_Preview()
	if not WT.Preview.gadgetsLocked_Preview then
		self.Dragging_Preview = true	
		WT.Preview.InDragMode_Preview = true
		WT.Preview.Dragging_Preview = self
			if WT.Preview[self.previewId].name == "icon" then
			local mouse = Inspect.Mouse()
			self.start_iconPositionX = WT.Preview[self.previewId].config.iconPositionX
			self.start_iconPositionY = WT.Preview[self.previewId].config.iconPositionY
			self.mouseStart_iconPositionX = mouse.x
			self.mouseStart_iconPositionY = mouse.y	
			end
			if WT.Preview[self.previewId].name == "labelCast" then
			local mouse = Inspect.Mouse()
			self.start_namePositionX = WT.Preview[self.previewId].config.namePositionX
			self.start_namePositionY = WT.Preview[self.previewId].config.namePositionY
			self.mouseStart_namePositionX = mouse.x
			self.mouseStart_namePositionY = mouse.y
			end
			if WT.Preview[self.previewId].name == "labelTime" then
			local mouse = Inspect.Mouse()
			self.start_timePositionX = WT.Preview[self.previewId].config.timePositionX
			self.start_timePositionY = WT.Preview[self.previewId].config.timePositionY
			self.mouseStart_timePositionX = mouse.x
			self.mouseStart_timePositionY = mouse.y
			end
		WT.Event.Trigger.GadgetSelected_Preview(self.previewId)
		WT.Log.Info("Preview Selected: " .. self.previewId) 
	end
end

function WT.Preview:DragStop_Preview()
	if self.Dragging_Preview then 
		WT.Log.Debug("DragStop_Preview")
		self.Dragging_Preview = false
		WT.Preview.Dragging_Preview = nil
		WT.Preview.InDragMode_Preview = false
		WT.Preview[self.previewId] = WT.Preview[self.previewId] or {}
		if WT.Preview[self.previewId].name == "icon" then
		WT.Preview[self.previewId].config.iconPositionX = self.iconPositionX
		WT.Preview[self.previewId].config.iconPositionY = self.iconPositionY
		WT.Preview[self.previewId].xpos = self.x
		WT.Preview[self.previewId].ypos = self.y
		end
		if WT.Preview[self.previewId].name == "labelCast" then
		WT.Preview[self.previewId].config.namePositionX = self.namePositionX
		WT.Preview[self.previewId].config.namePositionY = self.namePositionY
		WT.Preview[self.previewId].xpos = self.x
		WT.Preview[self.previewId].ypos = self.y
		end
		if WT.Preview[self.previewId].name == "labelTime" then
		WT.Preview[self.previewId].config.timePositionX = self.timePositionX
		WT.Preview[self.previewId].config.timePositionY = self.timePositionY
		WT.Preview[self.previewId].xpos = self.x
		WT.Preview[self.previewId].ypos = self.y
		end	
		--UpdatePreview()
		--[[
		if WT.Preview.alignTo then
			WT.Preview.alignTo:NormalMode()
			WT.Preview.alignTo = nil
			WT.Log.Debug("Alignment Mode Disengaged")
		end
		]]
	end 
end

function WT.Preview:DragMove_Preview()
	if self.Dragging_Preview then

			if WT.Preview[self.previewId].name == "icon" then
			local mouse = Inspect.Mouse()
			self.iconPositionX = math.ceil(mouse.x - self.mouseStart_iconPositionX + self.start_iconPositionX)
			self.iconPositionY = math.ceil(mouse.y - self.mouseStart_iconPositionY + self.start_iconPositionY)
			WT.Preview[self.previewId].config.iconPositionX = self.iconPositionX
			WT.Preview[self.previewId].config.iconPositionY = self.iconPositionY
			WT.Preview[self.previewId].xpos = self.iconPositionX
			WT.Preview[self.previewId].ypos = 	self.iconPositionY
				--[[if WT.Preview[self.previewId].config.TextRight == true then 
				self.frame:SetPoint("TOPRIGHT", WT.Preview[self.previewId].Parent, "TOPLEFT", self.namePositionX, self.namePositionY)
				else
				self.frame:SetPoint("TOPLEFT", WT.Preview[self.previewId].Parent, "TOPLEFT", self.namePositionX, self.namePositionY)
				end]]
			self.frame:SetPoint("TOPLEFT", WT.Preview[self.previewId].Parent, "TOPLEFT", self.iconPositionX, self.iconPositionY)
			end
			if WT.Preview[self.previewId].name == "labelCast" then
			local mouse = Inspect.Mouse()
			self.namePositionX = math.ceil(mouse.x - self.mouseStart_namePositionX + self.start_namePositionX)
			self.namePositionY = math.ceil(mouse.y - self.mouseStart_namePositionY + self.start_namePositionY)
			WT.Preview[self.previewId].config.namePositionX = self.namePositionX
			WT.Preview[self.previewId].config.namePositionY = self.namePositionY
			WT.Preview[self.previewId].xpos = self.namePositionX
			WT.Preview[self.previewId].ypos = 	self.namePositionY
			self.frame:SetPoint("TOPLEFT", WT.Preview[self.previewId].Parent, "TOPLEFT", self.namePositionX, self.namePositionY)			
			end
			if WT.Preview[self.previewId].name == "labelTime" then
			local mouse = Inspect.Mouse()
			self.timePositionX = math.ceil(mouse.x - self.mouseStart_timePositionX + self.start_timePositionX)
			self.timePositionY = math.ceil(mouse.y - self.mouseStart_timePositionY + self.start_timePositionY)
			WT.Preview[self.previewId].config.timePositionX = self.timePositionX
			WT.Preview[self.previewId].config.timePositionY = self.timePositionY
			WT.Preview[self.previewId].xpos = self.timePositionX
			WT.Preview[self.previewId].ypos = 	self.timePositionY
			self.frame:SetPoint("TOPLEFT", WT.Preview[self.previewId].Parent, "TOPLEFT", self.timePositionX, self.timePositionY)
			end
		--else
		--[[
			local mouse = Inspect.Mouse()
			self.x = math.ceil(mouse.x - self.mouseStartX + self.startX)
			self.y = math.ceil(mouse.y - self.mouseStartY + self.startY)
			self.frame:SetPoint("TOPLEFT", WT.Preview[self.previewId].Parent, "TOPLEFT", math.ceil(mouse.x - self.mouseStartX + self.startX), math.ceil(mouse.y - self.mouseStartY + self.startY))
			]]
		--end	
		--UpdatePreview()
	end
end

function WT.Preview:MouseIn_Preview()
	if WT.Preview.InDragMode_Preview and not WT.Preview.alignTo then
		if WT.Preview.Dragging_Preview ~= self then
			-- Go into alignment mode
			--WT.Preview.alignTo = self
			--self:AlignMode()
			WT.Log.Debug("Alignment Mode Engaged")
		end
	end
end



-- RESIZING FUNCTIONALITY

local origWidth = 0
local origHeight = 0
local constrainProportions = false


function WT.Preview:SizeStart_Preview()
	if not WT.Preview.InSizeMode then
		self.sizing = true	
		WT.Preview.InSizeMode = true
		WT.Preview.Sizing = self
		--WT.Log.Debug("SizeStart_Preview " .. self.startX .. "," .. self.startY)
		
		if WT.Preview[self.previewId].name == "icon" then
				local mouse = Inspect.Mouse()
		self.startX = self.frame:GetRight()
		self.startY = self.frame:GetBottom()
		self.mouseStartX = mouse.x
		self.mouseStartY = mouse.y	
		origWidth = self.frame:GetWidth()
		origHeight = self.frame:GetHeight()
			WT.Preview[self.previewId].config.iconSize = self.frame:GetWidth()
			WT.Preview[self.previewId].config.iconSize = self.frame:GetHeight()
		end
		if WT.Preview[self.previewId].name == "castBar" then
				local mouse = Inspect.Mouse()
		self.startX = self.frame:GetRight()
		self.startY = self.frame:GetBottom()
		self.mouseStartX = mouse.x
		self.mouseStartY = mouse.y	
		origWidth = self.frame:GetWidth()
		origHeight = self.frame:GetHeight()	
			WT.Preview[self.previewId].config.Width = self.frame:GetWidth()
			WT.Preview[self.previewId].config.Height = self.frame:GetHeight()
		end
	end
end

function WT.Preview:SizeStop_Preview()
	if self.sizing then 
		WT.Log.Debug("SizeStop_Preview")
		self.sizing = false
		WT.Preview.Sizing = nil
		WT.Preview.InSizeMode = false	
		WT.Preview[self.previewId] = WT.Preview[self.previewId] or {}
		if WT.Preview[self.previewId].name == "icon" then
			WT.Preview[self.previewId].config.iconSize = self.frame:GetWidth()
			WT.Preview[self.previewId].config.iconSize = self.frame:GetHeight()
		end
		if WT.Preview[self.previewId].name == "castBar" then
			WT.Preview[self.previewId].config.Width = self.frame:GetWidth()
			WT.Preview[self.previewId].config.Height = self.frame:GetHeight()
		end
	end 
end

function WT.Preview:SizeMove_Preview()
	if self.sizing then
		--[[
		if constrainProportions then
			local deltaW = newWidth - origWidth
			local deltaH = newHeight - origHeight
			if math.abs(deltaH) > math.abs(deltaW) then
				-- moved mainly vertically
				local frac = newHeight / origHeight
				newWidth = origWidth * frac				
			else
				-- moved mainly horizontally
				local frac = newWidth / origWidth
				newHeight = origHeight * frac 			
			end 
		end
		]]
		if WT.Preview[self.previewId].name == "icon" then
					local mouse = Inspect.Mouse()
				local x = mouse.x - self.mouseStartX + self.startX
				local y = mouse.y - self.mouseStartY + self.startY	
				
				local newWidth = math.ceil(x - self.frame:GetLeft() + 1)		
				local newHeight = math.ceil(y - self.frame:GetTop() + 1)
					
				if newWidth < self.minX then newWidth = self.minX end
				if newWidth > self.maxX then newWidth = self.maxX end
				if newHeight < self.minY then newHeight = self.minY end
				if newHeight > self.maxY then newHeight = self.maxY end
				self.frame:SetWidth(newWidth)
		self.frame:SetHeight(newHeight)
		if not WT.Preview[self.previewId] == nil then
		WT.Preview[self.previewId].config.width = newWidth
		WT.Preview[self.previewId].config.height = newHeight
		end
		dump(newWidth, newHeight)
		end
		if WT.Preview[self.previewId].name == "castBar" then
					local mouse = Inspect.Mouse()
				local x = mouse.x - self.mouseStartX + self.startX
				local y = mouse.y - self.mouseStartY + self.startY	
				
				local newWidth = math.ceil(x - self.frame:GetLeft() + 1)		
				local newHeight = math.ceil(y - self.frame:GetTop() + 1)
					
				if newWidth < self.minX then newWidth = self.minX end
				if newWidth > self.maxX then newWidth = self.maxX end
				if newHeight < self.minY then newHeight = self.minY end
				if newHeight > self.maxY then newHeight = self.maxY end
				self.frame:SetWidth(newWidth)
		self.frame:SetHeight(newHeight)
		if not WT.Preview[self.previewId] == nil then
		WT.Preview[self.previewId].config.width = newWidth
		WT.Preview[self.previewId].config.height = newHeight
		end
		end
		
		if self.frame.OnResize then self.frame:OnResize(newWidth, newHeight) end
	end
end

function WT.Preview.UnlockAll()

	for idx, gadget in pairs(WT.Previews) do
		gadget.mvHandle:SetVisible(true)
	end

	gadgetsLocked_Preview = false

	if GRAB_KEYBOARD_ON_UNLOCK then
		if not keyFocusFrame then
			keyFocusFrame = UI.CreateFrame("Frame", "Gadgets_KeyHandler", WT.Context)
			keyFocusFrame:SetAllPoints(UIParent)
			keyFocusFrame:SetLayer(9900)
			keyFocusFrame:EventAttach(Event.UI.Input.Key.Down, GadgetKeyDown, "GdtKeyDown")
			keyFocusFrame:EventAttach(Event.UI.Input.Key.Up, GadgetKeyUp, "GdtKeyUp")
		end
		keyFocusFrame:SetVisible(true)
		keyFocusFrame:SetKeyFocus(true)	
		escMessageShown = false
	end
end


function WT.Preview.LockAll()
	
	for idx, gadget in pairs(WT.Previews) do
		gadget.mvHandle:SetVisible(false)
	end
	gadgetsLocked_Preview = true
	if keyFocusFrame then
		keyFocusFrame:SetVisible(false)
		keyFocusFrame:SetKeyFocus(false)
	end
	UpdatePreview()

end


function WT.Preview.ToggleAll()
	if gadgetsLocked_Preview then
		WT.Preview.UnlockAll()
	else
		WT.Preview.LockAll()
	end
end

function WT.Preview.Locked()
	return gadgetsLocked_Preview
end

