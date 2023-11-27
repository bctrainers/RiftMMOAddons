local Info, Data = ...

local bit = bit
local max = math.max
local min = math.min
local floor = math.floor
local round = function(val) return math.floor(val + .5) end
local tonumber = tonumber
local tostring = tostring
local Inspect = Inspect
local UI = UI
local UIParent = UIParent

Library = Library or {}
Library.ColorPicker = {
	callback = function() end,
	hideCallback = function() end,
	newValue = {
		h = 0,
		s = 1,
		v = 1,
		a = 1
	},
	previousValue = {
		h = 0,
		s = 1,
		v = 1,
		a = 1
	},
	lastNotify = {
		r = 1,
		g = 1,
		b = 1,
		a = 1
	}
}

local ColorPicker = Library.ColorPicker

function ColorPicker:init()
	local cp = self

	local window = UI.CreateFrame("RiftWindow", "ColorPicker", UI.CreateContext("ColorPicker"))
	window:SetController("content")
	window:SetVisible(false)
	window:SetWidth(280)
	window:SetHeight(270)
	window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (UIParent:GetWidth() - window:GetWidth()) / 2, (UIParent:GetHeight() - window:GetHeight()) / 2)
	window:SetTitle("Color Picker")

	self.window = window

	window.titleBar = UI.CreateFrame("Frame", "ColorPicker_titleBar", window)
	window.titleBar:SetPoint("TOPLEFT", window:GetBorder(), "TOPLEFT")
	window.titleBar:SetWidth(window:GetWidth())
	window.titleBar:SetHeight(({window:GetTrimDimensions()})[2])

	window.titleBar.close = UI.CreateFrame("RiftButton", "ColorPicker_titleBar_close", window.titleBar)
	window.titleBar.close:SetSkin("close")
	window.titleBar.close:SetPoint("TOPRIGHT", window.titleBar, "TOPRIGHT", 21, 11)
	window.titleBar.close:EventAttach(Event.UI.Button.Left.Press, function()
		cp:hide(cp.previousValue)
	end, "Event.UI.Button.Left.Press")

	window.titleBar:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		local mouse = Inspect.Mouse()
		window.titleBar.pressed = true
		window.titleBar.mouseStartX = mouse.x
		window.titleBar.mouseStartY = mouse.y
		window.titleBar.startX = window:GetLeft()
		window.titleBar.startY = window:GetTop()
	end, "Event.UI.Input.Mouse.Left.Down")
	window.titleBar:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if window.titleBar.pressed then
			local mouse = Inspect.Mouse()
			window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouse.x - window.titleBar.mouseStartX + window.titleBar.startX, mouse.y - window.titleBar.mouseStartY + window.titleBar.startY)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	window.titleBar:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		window.titleBar.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	window.titleBar:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		window.titleBar.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")

	window:EventAttach(Event.UI.Layout.Size, function()
		window.titleBar:SetWidth(window:GetWidth())
	end, "Event.UI.Layout.Size")


	local sv = UI.CreateFrame("Texture", "ColorPicker_sv", window)
	self.sv = sv
	self.svBackground = UI.CreateFrame("Frame", "ColorPicker_svBackground", sv)
	self.svBorder = UI.CreateFrame("Frame", "ColorPicker_svBorder", sv)

	sv:SetPoint("TOPLEFT", window, "TOPLEFT", 20, 20)
	sv:SetWidth(128)
	sv:SetHeight(128)
	sv:SetLayer(2)
	sv:SetTexture(Info.identifier, [[textures\overlay.png]])
	sv:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		local mouse = Inspect.Mouse()
		sv.pressed = true
		cp:updateSVPicker(mouse.x - cp.sv:GetLeft(), mouse.y - cp.sv:GetTop())
	end, "Event.UI.Input.Mouse.Left.Down")
	sv:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if sv.pressed then
			local mouse = Inspect.Mouse()
			cp:updateSVPicker(mouse.x - cp.sv:GetLeft(), mouse.y - cp.sv:GetTop())
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	sv:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		sv.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	sv:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		sv.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")

	self.svBackground:SetPoint("TOPLEFT", self.sv, "TOPLEFT")
	self.svBackground:SetPoint("BOTTOMRIGHT", self.sv, "BOTTOMRIGHT")
	self.svBackground:SetBackgroundColor(1, 0, 0)
	self.svBackground:SetLayer(1)

	self.svBorder:SetPoint("TOPLEFT", self.sv, "TOPLEFT", -1, -1)
	self.svBorder:SetPoint("BOTTOMRIGHT", self.sv, "BOTTOMRIGHT", 1, 1)
	self.svBorder:SetBackgroundColor(0, 0, 0, 0.4)
	self.svBorder:SetLayer(0)

	self.picker = UI.CreateFrame("Texture", "ColorPicker_picker", window)
	self.picker:SetPoint("TOPLEFT", self.sv, "TOPLEFT", -7, -7)
	self.picker:SetTexture(Info.identifier, [[textures\picker.png]])
	self.picker:SetLayer(3)


	local hue = UI.CreateFrame("Texture", "ColorPicker_hue", window)
	self.hue = hue
	self.hueBorder = UI.CreateFrame("Frame", "ColorPicker_hueBorder", hue)

	hue:SetPoint("TOPLEFT", self.svBackground, "TOPRIGHT", 20, 0)
	hue:SetTexture(Info.identifier, [[textures\hue.png]])
	hue:SetWidth(20)
	hue:SetHeight(128)
	hue:SetLayer(1)
	hue:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		local mouse = Inspect.Mouse()
		hue.pressed = true
		cp:updateHPicker(mouse.y - cp.hue:GetTop())
	end, "Event.UI.Input.Mouse.Left.Down")
	hue:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if hue.pressed then
			local mouse = Inspect.Mouse()
			cp:updateHPicker(mouse.y - cp.hue:GetTop())
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	hue:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		hue.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	hue:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		hue.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")

	self.hueBorder:SetPoint("TOPLEFT", self.hue, "TOPLEFT", -1, -1)
	self.hueBorder:SetPoint("BOTTOMRIGHT", self.hue, "BOTTOMRIGHT", 1, 1)
	self.hueBorder:SetBackgroundColor(0, 0, 0, 0.4)
	self.hueBorder:SetLayer(0)

	self.hSlider = UI.CreateFrame("Texture", "ColorPicker_hSlider", window)
	self.hSlider:SetTexture(Info.identifier, [[textures\hslider.png]])
	self.hSlider:SetLayer(2)
	self.hSlider:SetPoint("TOPLEFT", self.hue, "TOPLEFT", -10, -4)


	self.newValuePreview = UI.CreateFrame("Frame", "ColorPicker_newValuePreview", window)
	self.previousValuePreview = UI.CreateFrame("Frame", "ColorPicker_previousValuePreview", window)

	self.previewBorderTop = UI.CreateFrame("Frame", "ColorPicker_previewBorderTop", window)
	self.previewBorderBottom = UI.CreateFrame("Frame", "ColorPicker_previewBorderBottom", window)
	self.previewBorderLeft = UI.CreateFrame("Frame", "ColorPicker_previewBorderLeft", window)
	self.previewBorderRight = UI.CreateFrame("Frame", "ColorPicker_previewBorderRight", window)

	self.newValuePreview:SetPoint("TOPLEFT", self.hue, "TOPRIGHT", 20, 0)
	self.newValuePreview:SetWidth(50)
	self.newValuePreview:SetHeight(26)
	self.newValuePreview:SetLayer(2)
	self.newValuePreview:SetBackgroundColor(0, 0.5, 1)

	self.previousValuePreview:SetPoint("TOPLEFT", self.newValuePreview, "BOTTOMLEFT")
	self.previousValuePreview:SetWidth(50)
	self.previousValuePreview:SetHeight(26)
	self.previousValuePreview:SetLayer(2)
	self.previousValuePreview:SetBackgroundColor(1, 0.5, 0)

	------- preview border
	self.previewBorderTop:SetPoint("TOPLEFT", self.newValuePreview, "TOPLEFT", -1, -1)
	self.previewBorderTop:SetPoint("BOTTOMRIGHT", self.newValuePreview, "TOPRIGHT", 1, 0)
	self.previewBorderTop:SetLayer(1)
	self.previewBorderTop:SetBackgroundColor(0, 0, 0, 0.4)

	self.previewBorderBottom:SetPoint("BOTTOMLEFT", self.previousValuePreview, "BOTTOMLEFT", -1, 1)
	self.previewBorderBottom:SetPoint("TOPRIGHT", self.previousValuePreview, "BOTTOMRIGHT", 1, 0)
	self.previewBorderBottom:SetLayer(1)
	self.previewBorderBottom:SetBackgroundColor(0, 0, 0, 0.4)

	self.previewBorderLeft:SetPoint("TOPLEFT", self.newValuePreview, "TOPLEFT", -1, 0)
	self.previewBorderLeft:SetPoint("BOTTOMRIGHT", self.previousValuePreview, "BOTTOMLEFT")
	self.previewBorderLeft:SetLayer(1)
	self.previewBorderLeft:SetBackgroundColor(0, 0, 0, 0.4)

	self.previewBorderRight:SetPoint("TOPRIGHT", self.newValuePreview, "TOPRIGHT", 1, 0)
	self.previewBorderRight:SetPoint("BOTTOMLEFT", self.previousValuePreview, "BOTTOMRIGHT")
	self.previewBorderRight:SetLayer(1)
	self.previewBorderRight:SetBackgroundColor(0, 0, 0, 0.4)
	-------

	self.hLabel = UI.CreateFrame("Text", "ColorPicker_hLabel", window)
	self.hLabel:SetPoint("TOPLEFT", self.previousValuePreview, "BOTTOMLEFT", -2, 10)
	self.hLabel:SetText("H:")
	self.hLabel:SetWidth(8)
	self.hTextbox = UI.CreateFrame("RiftTextfield", "ColorPicker_hTextbox", window)
	self.hTextbox:SetPoint("CENTERLEFT", self.hLabel, "CENTERRIGHT", 12, 0)
	self.hTextbox:SetWidth(32)
	self.hTextbox:SetBackgroundColor(0, 0, 0, 0.5)
	self.hTextbox:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.hTextbox:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromHsv(cp.hTextbox)
	end, "Event.UI.Textfield.Change")

	self.sLabel = UI.CreateFrame("Text", "ColorPicker_sLabel", window)
	self.sLabel:SetPoint("TOPLEFT", self.hLabel, "BOTTOMLEFT", 0, 5)
	self.sLabel:SetText("S:")
	self.sLabel:SetWidth(8)
	self.sTextbox = UI.CreateFrame("RiftTextfield", "ColorPicker_sTextbox", window)
	self.sTextbox:SetPoint("CENTERLEFT", self.sLabel, "CENTERRIGHT", 12, 0)
	self.sTextbox:SetWidth(32)
	self.sTextbox:SetBackgroundColor(0, 0, 0, 0.5)
	self.sTextbox:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.sTextbox:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromHsv(cp.sTextbox)
	end, "Event.UI.Textfield.Change")

	self.vLabel = UI.CreateFrame("Text", "ColorPicker_vLabel", window)
	self.vLabel:SetPoint("TOPLEFT", self.sLabel, "BOTTOMLEFT", 0, 5)
	self.vLabel:SetText("B:")
	self.vLabel:SetWidth(8)
	self.vTextbox = UI.CreateFrame("RiftTextfield", "ColorPicker_vTextbox", window)
	self.vTextbox:SetPoint("CENTERLEFT", self.vLabel, "CENTERRIGHT", 12, 0)
	self.vTextbox:SetWidth(32)
	self.vTextbox:SetBackgroundColor(0, 0, 0, 0.5)
	self.vTextbox:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.vTextbox:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromHsv(cp.vTextbox)
	end, "Event.UI.Textfield.Change")


	self.alphaLabel = UI.CreateFrame("Text", "ColorPicker_alphaLabel", window)
	self.alphaLabel:SetPoint("TOPLEFT", self.sv, "BOTTOMLEFT", 0, 5)
	self.alphaLabel:SetText("Alpha:")

	self.alpha = UI.CreateFrame("RiftSlider", "ColorPicker_alpha", window)
	self.alpha:SetPoint("TOPLEFT", self.alphaLabel, "BOTTOMLEFT", 7, 4)
	self.alpha:SetRange(0, 100)
	self.alpha:SetWidth(190)
	self.alpha:SetPosition(100)
	self.alpha:EventAttach(Event.UI.Slider.Change, function()
		cp.newValue.a = cp.alpha:GetPosition() / 100
		cp:update()

		cp:notify(cp.newValue)
	end, "Event.UI.Slider.Change")

	self.alphaValue = UI.CreateFrame("Text", "ColorPicker_alphaValue", window)
	self.alphaValue:SetPoint("CENTERLEFT", self.alpha, "TOPRIGHT", 12, 4)
	self.alphaValue:SetText("1")


	self.rLabel = UI.CreateFrame("Text", "ColorPicker_rLabel", window)
	self.rLabel:SetPoint("TOPLEFT", self.alphaLabel, "BOTTOMLEFT", 0, 25)
	self.rLabel:SetText("R:")
	self.rLabel:SetWidth(8)
	self.rTextbox = UI.CreateFrame("RiftTextfield", "ColorPicker_rTextbox", window)
	self.rTextbox:SetPoint("TOPLEFT", self.rLabel, "TOPRIGHT", 10, 0)
	self.rTextbox:SetWidth(30)
	self.rTextbox:SetBackgroundColor(0, 0, 0, 0.5)
	self.rTextbox:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.rTextbox:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromRgb(cp.rTextbox)
	end, "Event.UI.Textfield.Change")

	self.gLabel = UI.CreateFrame("Text", "ColorPicker_gLabel", window)
	self.gLabel:SetPoint("TOP", self.rLabel, "TOP")
	self.gLabel:SetPoint("LEFT", self.rTextbox, "RIGHT", 10, nil)
	self.gLabel:SetText("G:")
	self.gLabel:SetWidth(8)
	self.gTextbox = UI.CreateFrame("RiftTextfield", "ColorPicker_gTextbox", window)
	self.gTextbox:SetPoint("TOPLEFT", self.gLabel, "TOPRIGHT", 10, 0)
	self.gTextbox:SetWidth(30)
	self.gTextbox:SetBackgroundColor(0, 0, 0, 0.5)
	self.gTextbox:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.gTextbox:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromRgb(cp.gTextbox)
	end, "Event.UI.Textfield.Change")

	self.bLabel = UI.CreateFrame("Text", "ColorPicker_bLabel", window)
	self.bLabel:SetPoint("TOP", self.gLabel, "TOP")
	self.bLabel:SetPoint("LEFT", self.gTextbox, "RIGHT", 10, nil)
	self.bLabel:SetText("B:")
	self.bLabel:SetWidth(8)
	self.bTextbox = UI.CreateFrame("RiftTextfield", "ColorPicker_bTextbox", window)
	self.bTextbox:SetPoint("TOPLEFT", self.bLabel, "TOPRIGHT", 10, 0)
	self.bTextbox:SetWidth(30)
	self.bTextbox:SetBackgroundColor(0, 0, 0, 0.5)
	self.bTextbox:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.bTextbox:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromRgb(cp.bTextbox)
	end, "Event.UI.Textfield.Change")


	self.rgbLabel = UI.CreateFrame("Text", "ColorPicker_rgbLabel", window)
	self.rgbLabel:SetPoint("TOP", self.bLabel, "TOP")
	self.rgbLabel:SetPoint("LEFT", self.bTextbox, "RIGHT", 20, nil)
	self.rgbLabel:SetText("#")
	self.rgb = UI.CreateFrame("RiftTextfield", "ColorPicker_rgb", window)
	self.rgb:SetPoint("TOPLEFT", self.rgbLabel, "TOPRIGHT", 2, 0)
	self.rgb:SetBackgroundColor(0, 0, 0, 0.5)
	self.rgb:SetWidth(55)
	self.rgb:EventAttach(Event.UI.Input.Key.Focus.Loss, self.textboxKeyFocusLoss, "Event.UI.Input.Key.Focus.Loss")
	self.rgb:EventAttach(Event.UI.Textfield.Change, function()
		cp:updateFromHex(cp.rgb)
	end, "Event.UI.Textfield.Change")


	self.okay = UI.CreateFrame("RiftButton", "ColorPicker_okay", window)
	self.okay:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT")
	self.okay:SetText("Okay")
	self.okay:EventAttach(Event.UI.Button.Left.Press, function()
		cp:hide(cp.newValue)
	end, "Event.UI.Button.Left.Press")
	self.cancel = UI.CreateFrame("RiftButton", "ColorPicker_cancel", window)
	self.cancel:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT")
	self.cancel:SetText("Cancel")
	self.cancel:EventAttach(Event.UI.Button.Left.Press, function()
		cp:hide(cp.previousValue)
	end, "Event.UI.Button.Left.Press")
end
function ColorPicker.textboxKeyFocusLoss()
	ColorPicker:update()
end
function ColorPicker:getVisible()
	return self.window and self.window:GetVisible()
end
function ColorPicker:show(r, g, b, a, callback)
	if not self.window then
		self:init()
	end

	local r2, g2, b2, a2 = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

	if not r2 or not g2 or not g2 or not a2 then
		error(("r, g, b have to be a number. Values given: %s, %s, %s"):format(tostring(r), tostring(g), tostring(b)))
	end
	if min(r2, g2, b2) < 0 or max(r2, g2, b2) > 1 then
		error("r, g, b must be in range from 0.0 to 1.0")
	end
	if type(callback) ~= "function" then
		error("callback has to be a function")
	end

	r, g, b, a = r2, g2, b2, a2 or 1

	self.callback = callback
	self.previousValue.h, self.previousValue.s, self.previousValue.v = self.rgb2hsv(r, g, b)
	self.previousValue.a = a

	self.newValue.h, self.newValue.s, self.newValue.v, self.newValue.a = self.previousValue.h, self.previousValue.s, self.previousValue.v, self.previousValue.a

	self.lastNotify.r = r
	self.lastNotify.g = g
	self.lastNotify.b = b
	self.lastNotify.a = a

	self.previousValuePreview:SetBackgroundColor(r, g, b, self.newValue.a)

	self:update()
	self.window:SetVisible(true)
end
function ColorPicker.rgb2hsv(r, g, b)
	local h
	local v = max(r, g, b)
	local MIN = min(r, g, b)
	local d = v - MIN
	local s = v == 0 and 0 or d / v

	if v == MIN then
		h = 0
	elseif v == r then
		h = (g - b) / d + (b > g and 6 or 0)
	elseif v == g then
		h = (b - r) / d + 2
	else
		h = (r - g) / d + 4
	end

	return h * 60, s, v
end
function ColorPicker.hsv2rgb(h, s, v)
	local h2 = floor(h / 60)
	local f = h / 60 - h2

	v = round(v * 255)
	local p = round(v * (1 - s))
	local q = round(v * (1 - s * f))
	local t = round(v * (1 - s * (1 - f)))

	if h2 % 6 == 0 then
		return v, t, p
	elseif h2 == 1 then
		return q, v, p
	elseif h2 == 2 then
		return p, v, t
	elseif h2 == 3 then
		return p, q, v
	elseif h2 == 4 then
		return t, p, v
	else
		return v, p, q
	end
end
function ColorPicker:updateSVPicker(x, y)
	x = max(min(x, 127), 0)
	y = max(min(y, 127), 0)

	self.picker:SetPoint("TOPLEFT", self.sv, "TOPLEFT", round(x) - 7, round(y) - 7)

	self.newValue.s = x / 127
	self.newValue.v = 1 - (y / 127)
	self:update()

	self:notify(self.newValue)
end
function ColorPicker:updateHPicker(y)
	y = max(min(y, 127), 0)

	self.newValue.h = (1 - (y / 127)) * 360

	self:update()

	self:notify(self.newValue)
end
function ColorPicker:update(skip)
	local color = {self.hsv2rgb(self.newValue.h, self.newValue.s, self.newValue.v)}
	local r = color[1] / 255
	local g = color[2] / 255
	local b = color[3] / 255

	local bg = {self.hsv2rgb(self.newValue.h, 1, 1)}
	self.svBackground:SetBackgroundColor(bg[1] / 255, bg[2] / 255, bg[3] / 255)

	self.picker:SetPoint("TOPLEFT", self.sv, "TOPLEFT", round(self.newValue.s * 128) - 7, round((1 - self.newValue.v) * 127) - 7)
	self.hSlider:SetPoint("TOPLEFT", self.hue, "TOPLEFT", -10, round((1 - (self.newValue.h / 360)) * 127) - 4)
	self.newValuePreview:SetBackgroundColor(r, g, b, self.newValue.a)

	if skip ~= self.hTextbox then
		self.hTextbox:SetText(tostring(round(self.newValue.h)))
	end
	if skip ~= self.sTextbox then
		self.sTextbox:SetText(tostring(round(self.newValue.s * 100)))
	end
	if skip ~= self.vTextbox then
		self.vTextbox:SetText(tostring(round(self.newValue.v * 100)))
	end

	self.alpha:SetPosition(round(self.newValue.a * 100))
	self.alphaValue:SetText(("%.2g"):format(self.newValue.a))

	if skip ~= self.rTextbox then
		self.rTextbox:SetText(tostring(color[1]))
	end
	if skip ~= self.gTextbox then
		self.gTextbox:SetText(tostring(color[2]))
	end
	if skip ~= self.bTextbox then
		self.bTextbox:SetText(tostring(color[3]))
	end

	if skip ~= self.rgb then
		self.rgb:SetText(("%02X%02X%02X"):format(color[1], color[2], color[3]))
	end
end
function ColorPicker:hide(tbl)
	local self = ColorPicker
	if not self.window or not self.window:GetVisible() then
		return
	end
	self.hTextbox:SetKeyFocus(false)
	self.sTextbox:SetKeyFocus(false)
	self.vTextbox:SetKeyFocus(false)

	self.rTextbox:SetKeyFocus(false)
	self.gTextbox:SetKeyFocus(false)
	self.bTextbox:SetKeyFocus(false)

	self.rgb:SetKeyFocus(false)

	self.window:SetVisible(false)
	self:notify(tbl or self.previousValue)
	self.hideCallback()
end
function ColorPicker:toggle(r, g, b, a, callback)
	if not self.window or not self.window:GetVisible() then
		self:show(r, g, b, a, callback)
		return true
	else
		self:hide(self.previousValue)
		return false
	end
end
function ColorPicker:notify(tbl)
	local color = {self.hsv2rgb(tbl.h, tbl.s, tbl.v)}
	color[1] = color[1] / 255
	color[2] = color[2] / 255
	color[3] = color[3] / 255
	if self.lastNotify.r ~= color[1] or self.lastNotify.g ~= color[2] or self.lastNotify.b ~= color[3] or self.lastNotify.a ~= tbl.a then
		self.lastNotify.r = color[1]
		self.lastNotify.g = color[2]
		self.lastNotify.b = color[3]
		self.lastNotify.a = tbl.a
		self.callback(color[1], color[2], color[3], tbl.a)
	end
end
function ColorPicker:updateFromHsv(skip)
	self.newValue.h = max(min(tonumber(self.hTextbox:GetText()) or 0, 360), 0)
	self.newValue.s = max(min(tonumber(self.sTextbox:GetText()) or 0, 100), 0) / 100
	self.newValue.v = max(min(tonumber(self.vTextbox:GetText()) or 0, 100), 0) / 100

	self:update(skip)

	self:notify(self.newValue)
end
function ColorPicker:updateFromRgb(skip)
	local r = max(min(tonumber(self.rTextbox:GetText()) or 0, 255), 0)
	local g = max(min(tonumber(self.gTextbox:GetText()) or 0, 255), 0)
	local b = max(min(tonumber(self.bTextbox:GetText()) or 0, 255), 0)

	self.newValue.h, self.newValue.s, self.newValue.v = self.rgb2hsv(r / 255, g / 255, b / 255)

	self:update(skip)

	self:notify(self.newValue)
end
function ColorPicker:updateFromHex(skip)
	local color = {self.extractColors(tonumber(self.rgb:GetText(), 16) or 0)}
	self.newValue.h, self.newValue.s, self.newValue.v = self.rgb2hsv(color[1] / 255, color[2] / 255, color[3] / 255)

	self:update(skip)

	self:notify(self.newValue)
end
function ColorPicker.extractColors(hex)
	return bit.rshift(hex, 16), bit.band(bit.rshift(hex, 8), 0xff), bit.band(hex, 0xff)
end