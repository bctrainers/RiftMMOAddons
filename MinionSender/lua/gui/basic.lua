MinionSender.GUI.Basic = {}

-- align = { w, h, { x, y, [align1, [align2]] }, ... }
-- text = { text = text, isLocalized = isLocalized, fontSize = fontSize, fontColor = fontColor }
-- callback = { param = .., LeftClick = .., LeftDown = .., LeftUp = .., LeftUpoutside = .., RightClick = .., RightDown = .., RightUp = .., RightUpoutside = .., WheelBack = .., WheelForward = .., MouseIn = .., MouseMove = .., MouseOut = .. }
-- texture = texture || { texture, isInner }

function MinionSender.GUI.Basic.Create (frameType, parent, align, layer, text, callback)
	local frame = UI.CreateFrame(frameType, "", parent)
	frame.scale = 1
	frame.parent = parent

	function frame.SetAlign()
		for k, v in pairs(align) do
			if k == 1 and type(v) == "number" then frame:SetWidth(v * frame.scale) end
			if k == 2 and type(v) == "number" then frame:SetHeight(v * frame.scale) end
			if type(v) == "table" then frame:SetPoint(v[3] or "TOPLEFT", parent, v[4] or v[3] or "TOPLEFT", v[1] * frame.scale, v[2] * frame.scale) end
		end
	end
	frame.SetAlign()

	function frame.SetScale(scale)
		frame.scale = scale or frame.scale
		frame.SetAlign()
		if frame.text and frame.SetFontSize then frame:SetFontSize(frame.text.fontSize * frame.scale) end
	end

	if layer then frame:SetLayer(layer) end

	if frameType == "RiftButton" or frameType == "Text" then
		text = text or {}
		frame.text = { text = text.text, isLocalized = text.isLocalized or false, fontSize = text.fontSize or 14, fontColor = text.fontColor or { 255, 255, 255 }, params = {} }

		function frame.SetParameters (...)
			frame.text.params = {...}
			if #frame.text.params > 0 and type(frame.text.params[1]) == "table" then frame.text.params = frame.text.params[1] end
			frame.UpdateText()
		end

		function frame.UpdateText (value)
			if value then
				if value.text then frame.text.text = value.text end
				if value.isLocalized ~= nil then frame.text.isLocalized = value.isLocalized end
				if value.fontSize then frame.text.fontSize = value.fontSize end
				if value.fontColor then frame.text.fontColor = value.fontColor end
			end

			if frame.text.text then
				local str
				local p = {}
				if frame.text.isLocalized then
					str = (MinionSender.Data.Language.Current or {})[frame.text.text] or frame.text.text
					for k, v in pairs(frame.text.params) do
						p[k] = (MinionSender.Data.Language.Current or {})[v] or v
					end
				else
					str = frame.text.text
					p = frame.text.params
				end
				if str then
					if #p > 0 then
						frame:SetText(str:format(unpack(p)))
					else
						frame:SetText(str)
					end
				end
			end

			frame.SetScale()
		end

		function frame.UpdateColor (value)
			if value then frame.text.fontColor = value end

			if frame.SetFontColor then
				if frame.text.fontColor[4] == nil then 
					frame:SetFontColor(frame.text.fontColor[1] / 255, frame.text.fontColor[2] / 255, frame.text.fontColor[3] / 255)
				else
					frame:SetFontColor(frame.text.fontColor[1] / 255, frame.text.fontColor[2] / 255, frame.text.fontColor[3] / 255, frame.text.fontColor[4])
				end
			end
		end

		frame.UpdateText()
		frame.UpdateColor()
	end

	function frame.UpdateCallback (callback)
		callback = callback or {}
		if callback.LeftClick or callback.LeftDown or callback.LeftUp or callback.LeftUpoutside or callback.RightClick or callback.RightDown or callback.RightUp or callback.RightUpoutside then 
			function frame.Event:LeftDown () MinionSender.GUI.Basic.HideField() end
			function frame.Event:RightDown () MinionSender.GUI.Basic.HideField() end
		end

		if callback.LeftClick then function frame.Event:LeftClick () callback.LeftClick(frame, callback.param) end end
		if callback.LeftDown then function frame.Event:LeftDown () MinionSender.GUI.Basic.HideField() callback.LeftDown(frame, callback.param) end end
		if callback.LeftUp then function frame.Event:LeftUp () callback.LeftUp(frame, callback.param) end end
		if callback.LeftUpoutside then function frame.Event:LeftUpoutside () callback.LeftUpoutside(frame, callback.param) end end

		if callback.RightClick then function frame.Event:RightClick () callback.RightClick(frame, callback.param) end end
		if callback.RightDown then function frame.Event:RightDown () MinionSender.GUI.Basic.HideField() callback.RightDown(frame, callback.param) end end
		if callback.RightUp then function frame.Event:RightUp () callback.RightUp(frame, callback.param) end end
		if callback.RightUpoutside then function frame.Event:RightUpoutside () callback.RightUpoutside(frame, callback.param) end end

		if callback.MiddleClick then function frame.Event:MiddleClick () callback.MiddleClick(frame, callback.param) end end
		if callback.Mouse4Click then function frame.Event:Mouse4Click () callback.Mouse4Click(frame, callback.param) end end
		if callback.Mouse5Click then function frame.Event:Mouse5Click () callback.Mouse5Click(frame, callback.param) end end

		if callback.WheelBack then function frame.Event:WheelBack () callback.WheelBack(frame, callback.param) end end
		if callback.WheelForward then function frame.Event:WheelForward () callback.WheelForward(frame, callback.param) end end

		if callback.MouseIn then function frame.Event:MouseIn () callback.MouseIn(frame, callback.param) end end
		if callback.MouseMove then function frame.Event:MouseMove (x, y) callback.MouseMove(frame, callback.param, x, y) end end
		if callback.MouseOut then function frame.Event:MouseOut () callback.MouseOut(frame, callback.param) end end

		if callback.TextfieldChange then function frame.Event:TextfieldChange () callback.TextfieldChange(frame, callback.param) end end
		if callback.KeyDown then function frame.Event:KeyDown(code) callback.KeyDown(frame, callback.param, code) end end
		if callback.KeyFocusLoss then function frame.Event:KeyFocusLoss() callback.KeyFocusLoss(frame, callback.param) end end
	end

	frame.UpdateCallback(callback)

	return frame
end

function MinionSender.GUI.Basic.CreateFrame (parent, align, layer, callback)
	return MinionSender.GUI.Basic.Create("Frame", parent, align, layer, nil, callback)
end

function MinionSender.GUI.Basic.CreateRiftButton (parent, align, layer, text, callback)
	return MinionSender.GUI.Basic.Create("RiftButton", parent, align, layer, text, callback)
end

function MinionSender.GUI.Basic.CreateText (parent, align, layer, text, callback)
	return MinionSender.GUI.Basic.Create("Text", parent, align, layer, text, callback)
end

function MinionSender.GUI.Basic.CreateCanvas (parent, align, layer, callback, path, fill, stroke)
	local frame = MinionSender.GUI.Basic.Create("Canvas", parent, align, layer, nil, callback)
	frame:SetShape(path, fill, stroke)
	return frame
end

function MinionSender.GUI.Basic.CreateMask (parent, align, layer)
	return MinionSender.GUI.Basic.Create("Mask", parent, align, layer)
end

function MinionSender.GUI.Basic.CreateTexture (parent, align, layer, texture, callback)
	local frame = MinionSender.GUI.Basic.Create("Texture", parent, align, layer, nil, callback)

	function frame.UpdateTexture (value)
		if type(value) == "table" then
			frame:SetTexture(iif(value[2], "Rift", MinionSenderAddon.identifier), iif(value[2], value[1], "img/" .. value[1]))
		elseif value then
			frame:SetTexture(MinionSenderAddon.identifier, "img/" .. value)
		end
	end

	frame.UpdateTexture(texture)

	return frame
end

function MinionSender.GUI.Basic.CreateButton (parent, align, layer, textureName, callback, param, isSwitch, isSimple, isDelegate, isHidden)
	local frame = MinionSender.GUI.Basic.CreateTexture(parent, align, layer, textureName .. "-normal.png",
	{
		LeftDown = function (handler) if not isSimple then handler.UpdateTexture(textureName .. "-down.png") end end,
		MouseIn = function (handler) if isDelegate then parent.Event.MouseIn() end handler.UpdateTexture(textureName .. "-" .. iif(isSwitch and handler.state and not isSimple, "down", "") .. "hover.png") end,
		MouseMove = function (handler) handler.UpdateTexture(textureName .. "-" .. iif(isSwitch and handler.state and not isSimple, "down", "") .. "hover.png") end,
		MouseOut = function (handler) if isDelegate then parent.Event.MouseOut() end handler.UpdateTexture(textureName .. "-" .. iif(isSwitch and handler.state and not isSimple, "down", "normal") .. ".png") end,
		LeftClick = function (handler) if callback then callback(handler, param) end end
	})

	function frame.UpdateState (flag)
		frame.state = flag
		frame.UpdateTexture(textureName .. "-" .. iif(isSwitch and frame.state and not isSimple, "down", "normal") .. ".png")
	end

	if isHidden then frame:SetVisible(false) end

	return frame
end

function MinionSender.GUI.Basic.CreateTextField (parent, align, layer, textCtrl, callback, isDelegate)
	local frame = MinionSender.GUI.Basic.CreateTooltip (parent, align, layer, true, "field", 2)
	frame.field = MinionSender.GUI.Basic.Create("RiftTextfield", frame, { { 0, 0 }, { 0, 0, "BOTTOMRIGHT" } }, layer, nil,
	{
		MouseIn = function (handler) if isDelegate then parent.Event.MouseIn() end end,
		MouseOut = function (handler) if isDelegate then parent.Event.MouseOut() end end,
		KeyFocusLoss = function (handler) if isDelegate then parent.Event.MouseOut() end if callback.KeyFocusLoss then callback.KeyFocusLoss(handler) end end,
		TextfieldChange = callback.TextfieldChange,
		KeyDown = callback.KeyDown,
		param = callback.param
	})

	function frame.Show (text)
		MinionSender.GUI.Basic.HideField()
		frame.field:SetText(text)
		frame.field:SetCursor(text:len())
		frame.field:SetSelection(0, text:len())
		frame.field:SetKeyFocus(true)
		frame:SetVisible(true)
		textCtrl:SetVisible(false)
		MinionSender.GUI.Basic.ActiveField = frame
	end

	function frame.Hide ()
		frame.field:SetKeyFocus(false)
		frame:SetVisible(false)
		textCtrl:SetVisible(true)
		MinionSender.GUI.Basic.ActiveField = nil
	end

	frame.Hide();
	return frame
end

function MinionSender.GUI.Basic.CreateTooltip (parent, align, layer, isTransparent, name, size)
	local callback = iif(isTransparent, {}, { LeftDown = function() end })
	local frame = MinionSender.GUI.Basic.CreateFrame(parent, align, layer)
	frame:SetVisible(false)

	MinionSender.GUI.Basic.CreateTexture(frame, { size, size, { 0, 0, "TOPLEFT" } }, -1, name .. "-tl.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { nil, size, { size, 0, "TOPLEFT" }, { -size, 0, "TOPRIGHT" } }, -1, name .. "-tc.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { size, size, { 0, 0, "TOPRIGHT" } }, -1, name .. "-tr.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { size, nil, { 0, size, "TOPLEFT" }, { 0, -size, "BOTTOMLEFT" } }, -1, name .. "-ml.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { nil, nil, { size, size, "TOPLEFT" }, { -size, -size, "BOTTOMRIGHT" } }, -1, name .. "-mc.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { size, nil, { 0, size, "TOPRIGHT" }, { 0, -size, "BOTTOMRIGHT" } }, -1, name .. "-mr.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { size, size, { 0, 0, "BOTTOMLEFT" } }, -1, name .. "-bl.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { nil, size, { size, 0, "BOTTOMLEFT" }, { -size, 0, "BOTTOMRIGHT" } }, -1, name .. "-bc.png", callback)
	MinionSender.GUI.Basic.CreateTexture(frame, { size, size, { 0, 0, "BOTTOMRIGHT" } }, -1, name .. "-br.png", callback)

	return frame
end

function MinionSender.GUI.Basic.CreateSlider (parent, align, layer, min, max, count, step, value, callbackChange)
	local calcPosition = function(handler, x) return math.floor(math.max(math.min((x - handler:GetLeft() - 2) / handler:GetWidth() * (max - min), max - min), 0) / (step or 1) + .5) * (step or 1) + min end

	local updatePosition = function(handler, position)
		if (handler.downed or 0) > 0 then
			if count == 2 then position = { min = iif(handler.downed == 1, position, math.min(position, handler.value.min)), max = iif(handler.downed == 2, position, math.max(position, handler.value.max)) } end
			handler.UpdateValue(position)
			if callbackChange then callbackChange(position) end
		end 
	end

	local frame = MinionSender.GUI.Basic.CreateFrame(parent, align, layer,
	{
		LeftDown = function(handler)
			local position = calcPosition(handler, Inspect.Mouse().x)
			handler.downed = iif(count == 1 or handler.value.max + handler.value.min < position * 2, 2, 1)
			updatePosition(handler, position)
		end,
		MouseIn = function() if parent.Event.MouseIn then parent.Event.MouseIn() end end,
		MouseOut = function() if parent.Event.MouseOut then parent.Event.MouseOut() end end,
		MouseMove = function(handler, param, x, y) updatePosition(handler, calcPosition(handler, x)) end,
		LeftUp = function(handler) handler.downed = 0 end,
		LeftUpoutside = function(handler) handler.downed = 0 end
	})
	frame.value = value

	frame.UpdateValue = function (value)
		frame.value = value
		local cmin, cmax
		if type(value) == "table" then
			cmin = value.min - min
			cmax = value.max - min
		else
			cmin = 0
			cmax = (value or 0) - min
		end
		cmin = cmin / (max - min) * frame:GetWidth()
		cmax = cmax / (max - min) * frame:GetWidth()

		frame.slider.back:SetPoint("TOPLEFT", frame, "TOPLEFT", cmin - iif(count == 1, 3, 0), 6)
		frame.slider.back:SetWidth(cmax - cmin + iif(count == 1, 3, 0))
		if count == 2 then frame.slider.left:SetPoint("TOPLEFT", frame, "TOPLEFT", cmin - 9, 0) end
		frame.slider.right:SetPoint("TOPLEFT", frame, "TOPLEFT", cmax - 9, 0)
	end

	MinionSender.GUI.Basic.CreateTexture(frame, { 10, 9, { -4, 5 } }, 5, "slider-l.png")
	MinionSender.GUI.Basic.CreateTexture(frame, { nil, 9, { 6, 5 }, { -4, 5, "TOPRIGHT" } }, 5, "slider-m.png")
	MinionSender.GUI.Basic.CreateTexture(frame, { 10, 9, { 6, 5, "TOPRIGHT" } }, 5, "slider-r.png")

	frame.slider = { back = MinionSender.GUI.Basic.CreateFrame(frame, { 25, 5 }, 4),
			 right = MinionSender.GUI.Basic.CreateTexture(frame, { 18, 17 }, 6, "sliderMark-" .. iif(count == 2, "r", "m") .. ".png") }
	if count == 2 then frame.slider.left = MinionSender.GUI.Basic.CreateTexture(frame, { 18, 17 }, 6, "sliderMark-l.png") end
	frame.slider.back:SetBackgroundColor(0.847, 0, 1, 1)
	frame.UpdateValue(value)

	return frame
end

function MinionSender.GUI.Basic.HideField ()
	if MinionSender.GUI.Basic.ActiveField then MinionSender.GUI.Basic.ActiveField.Hide() end
end
