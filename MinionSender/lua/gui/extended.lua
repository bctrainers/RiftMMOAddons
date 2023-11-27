MinionSender.GUI.Extended = {
	Canvas = {
		path = { rectangle = { { xProportional = 0, yProportional = 0 }, { xProportional = 1, yProportional = 0 }, { xProportional = 1, yProportional = 1 }, { xProportional = 0, yProportional = 1 }, { xProportional = 0, yProportional = 0 } },
		       circle = { { xProportional = 0.5, yProportional = 0 }, { xProportional = 1, yProportional = 0.5, xControlProportional = 61/64, yControlProportional = 3/64 }, { xProportional = 0.5, yProportional = 1, xControlProportional = 61/64, yControlProportional = 61/64 }, { xProportional = 0, yProportional = 0.5, xControlProportional = 3/64, yControlProportional = 61/64 }, { xProportional = 0.5, yProportional = 0, xControlProportional = 3/64, yControlProportional = 3/64 } } },
		stroke = { border = { r = 0.6, g = 0.6, b = 0.47843, a = 1, thickness = 1 } },
		matrix = { sat = Utility.Matrix.Create(2.56, 1, 0, 0, 0) },
		fill = { hue = { type = "gradientLinear", transform = Utility.Matrix.Create(2.56, 1, math.pi / 2, 0, 0), color = { { r = 1, g = 0, b = 0, position = 0 }, { r = 1, g = 0, b = 1, position = 1 }, { r = 0, g = 0, b = 1, position = 2 }, { r = 0, g = 1, b = 1, position = 3 }, { r = 0, g = 1, b = 0, position = 4 }, { r = 1, g = 1, b = 0, position = 5 }, { r = 1, g = 0, b = 0, position = 6 } } },
			chart = { type = "texture", wrap = "repeat", source = MinionSenderAddon.identifier, texture = "img/chart.png" } }
	},
	Controls = {
		empty = { height = 10 },
		separator = { height = 14, create = function(container)
			MinionSender.GUI.Basic.CreateTexture(container.parent, { { container.item.x or -8, container.item.y or 4 } }, 1, "tooltip-separator.png")
		end },
		label = { create = function(container)
			return MinionSender.GUI.Basic.CreateText(container.parent, { { container.item.x or 0, container.item.y or 0, container.item.align or "TOPLEFT", "TOPLEFT" } }, 1, { text = container.item.text, isLocalized = true, fontSize = container.item.size or 12, fontColor = container.item.color })
		end },
		riftbutton = { create = function(container)
			return MinionSender.GUI.Basic.CreateRiftButton(container.parent, { { container.item.x or 0, container.item.y or 0, container.item.align } }, 1, { text = container.item.text, isLocalized = true }, { param = container.info, LeftClick = container.onClick })
		end },
		chart = { create = function(container)
			return MinionSender.GUI.Extended.CreateChart(container.parent, "TOPLEFT", container.item.x, container.item.y, container.item.prop, container.item.param)
		end },
		colorPicker = { height = 258, create = function(container)
			return MinionSender.GUI.Extended.CreateColorPicker(container.parent, container.onChange, container.info, container.getValue(container.item.param))
		end },
	}
}

function MinionSender.GUI.Extended.AttachDragFrame (parent, fTitle, variable, fLeft, fLock, callbackDrag)
	local bindedFrame = parent
	if fTitle then
		bindedFrame = parent:GetBorder()
	end

	local frame = UI.CreateFrame("Frame", "", bindedFrame)
	parent.DragFrame = frame
	frame:SetPoint("TOPLEFT", bindedFrame, "TOPLEFT", 0, 0)
	if fTitle then
		frame:SetPoint("BOTTOMRIGHT", bindedFrame, "TOPRIGHT", 0, parent:GetTop() - bindedFrame:GetTop())
	else
		frame:SetPoint("BOTTOMRIGHT", bindedFrame, "BOTTOMRIGHT", 0, 0)
	end

	frame:SetLayer(100)
	frame.parent = parent
	frame.MouseDown = false

	function frame.MouseButtonDown (fButton)
		if fButton == fLeft and (not fLock or not MinionSenderConfig.lockWindow) then
			frame.MouseDown = true
			local mouseData = Inspect.Mouse()
			frame.xDiff = frame.parent:GetLeft() - mouseData.x
			frame.yDiff = frame.parent:GetTop() - mouseData.y
		end
	end

	function frame.MouseButtonUp (fButton)
		if frame.Drag and fButton == fLeft and (not fLock or not MinionSenderConfig.lockWindow) then
			frame.Drag = false
			if callbackDrag then callbackDrag(false) end
		end
	end

	function frame.Event:LeftDown ()
		self.MouseButtonDown(true)
		if self.parent.Event.LeftDown then self.parent.Event.LeftDown() end
	end

	function frame.Event:RightDown ()
		self.MouseButtonDown(false)
		if self.parent.Event.RightDown then self.parent.Event.RightDown() end
	end
	
	function frame.Event:MouseMove (mouseX, mouseY)
		if self.MouseDown and (not fLock or not MinionSenderConfig.lockWindow) then
			self.Drag = true
			self.parent:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouseX + self.xDiff, mouseY + self.yDiff)
			MinionSenderUISettings[variable].x = mouseX + self.xDiff
			MinionSenderUISettings[variable].y = mouseY + self.yDiff

			if callbackDrag then callbackDrag(true) end
		end
		if self.parent.Event.MouseMove then self.parent.Event.MouseMove() end
	end
	
	function frame.Event:LeftUp ()
		self.MouseDown = false
		if self.parent.Event.LeftUp then self.parent.Event.LeftUp() end
		if (not self.Drag or not fLeft) and self.parent.Event.LeftClick then self.parent.Event.LeftClick() end
		self.MouseButtonUp(true)
	end

	function frame.Event:LeftUpoutside ()
		self.MouseDown = false
		if self.parent.Event.LeftUp then self.parent.Event.LeftUp() end
		self.MouseButtonUp(true)
	end

	function frame.Event:RightUp ()
		self.MouseDown = false
		if self.parent.Event.RightUp then self.parent.Event.RightUp() end
		if (not self.Drag or fLeft) and self.parent.Event.RightClick then self.parent.Event.RightClick() end
		self.MouseButtonUp(false)
	end

	function frame.Event:RightUpoutside ()
		self.MouseDown = false
		if self.parent.Event.RightUp then self.parent.Event.RightUp() end
		self.MouseButtonUp(false)
	end

	function frame.Event:MouseIn ()
		if self.parent.Event.MouseIn then self.parent.Event.MouseIn() end
	end

	function frame.Event:MouseOut ()
		if self.parent.Event.MouseOut then self.parent.Event.MouseOut() end
	end

	return frame
end

function MinionSender.GUI.Extended.AttachResizableFrame (parent, variable, minWidth, minHeight)
	local frame = UI.CreateFrame("Frame", "", parent)

	frame:SetPoint("CENTER", parent, "BOTTOMRIGHT", 0, 0)
	frame:SetWidth(20)
	frame:SetHeight(20)

	frame.parent = parent
	frame.MouseDown = false

	function frame.Event:LeftDown ()
		frame.MouseDown = true
		frame.mouseData = Inspect.Mouse()
		frame.width = frame.parent:GetWidth()
		frame.height = frame.parent:GetHeight()
	end

	function frame.Event:MouseMove (mouseX, mouseY)
		if self.MouseDown then
			local width, height = frame.width - self.mouseData.x + mouseX, frame.height - self.mouseData.y + mouseY
			self.parent:SetWidth(iif(width < minWidth, minWidth, width))
			self.parent:SetHeight(iif(height < minHeight, minHeight, height))
			MinionSenderUISettings[variable].width = self.parent:GetWidth()
			MinionSenderUISettings[variable].height = self.parent:GetHeight()
		end
	end

	function frame.Event:LeftUp ()
		self.MouseDown = false
	end

	function frame.Event:LeftUpoutside ()
		self.MouseDown = false
	end

	return frame
end

function MinionSender.GUI.Extended.CreateMenu (parent, description, callback, align)
	local container = { dependencies = {}, controls = {}, align = align }

	function container.AddDependency (param, ctrl)
		if param and ctrl then
			local p = getPath(param)
			if container.dependencies[p] == nil then container.dependencies[p] = {} end
			table.insert(container.dependencies[p], ctrl)
		end
		if ctrl then
			table.insert(container.controls, ctrl)
		end
	end

	function container.UpdateText ()
		for k, v in pairs(container.controls) do
			if v.UpdateText then
				v.UpdateText()
			end
		end
	end

	function container.UpdateValue (param, value)
		if callback.SetValue then callback.SetValue(param, value) end
	end

	function container.UpdateDependencies (param)
		local f = function (p)
			if container.dependencies[p] then
				for k, v in pairs(container.dependencies[p]) do
					if v.UpdateValue then
						v.UpdateValue(callback.GetValue(p), p)
					end
					if v.SetParameters then
						v.SetParameters(callback.GetValue(p))
					end
				end
			end
		end

		f(getPath(param))
		f(getPath(param, 1))
	end

	function container.OnChange (handler, param)
		local value = param.value or not callback.GetValue(param.param)
		container.UpdateValue(param.param, value)
	end

	container.OnClick = callback.OnClick
	container.OnEdit = callback.OnEdit
	container.GetValue = callback.GetValue 
	container.GetCustom = callback.GetCustom
	container.ctrl = MinionSender.GUI.Extended.CreateSubMenu (parent, description, container)

	return container
end

function MinionSender.GUI.Extended.CreateSubMenu (parent, description, container)
	local window = MinionSender.GUI.Basic.CreateTooltip(parent, { description.properties.width }, 100, description.properties.transparent, "tooltip", 26)
	window.selectedItem = { frame = nil, submenu = nil }
	window.properties = description.properties
	window.parent = parent
	window.owner = parent
	window.owner.direction = window.owner.direction or 1

	function window.LinkChild (index)
		if index > 0 and index + 1 <= #window.childs then
			window.childs[index + 1]:ClearPoint("TOPLEFT")
			window.childs[index + 1]:ClearPoint("TOPRIGHT")
			window.childs[index + 1]:SetParent(window.childs[index])
			window.childs[index + 1]:SetPoint("TOPLEFT", window.childs[index], iif((window.childs[index + 1].info or {}).collapse, "TOPLEFT", "BOTTOMLEFT"), 0, 0)
			window.childs[index + 1]:SetPoint("TOPRIGHT", window.childs[index], iif((window.childs[index + 1].info or {}).collapse, "TOPRIGHT", "BOTTOMRIGHT"), 0, 0)
		end

		for i = 1, #window.childs, 1 do
			window.childs[i].index = i
		end

		window:SetHeight(description.properties.height or (window.childs[#window.childs]:GetBottom() - window:GetTop()))
	end

	function window.AppendChild (height, index, info)
		index = index or #window.childs
		local frame = MinionSender.GUI.Basic.CreateFrame(window.childs[index - 1], { nil, height, { 0, 0, "TOPLEFT", iif((info or {}).collapse, "TOPLEFT", "BOTTOMLEFT") }, { 0, 0, "TOPRIGHT", iif((info or {}).collapse, "TOPRIGHT", "BOTTOMRIGHT") } }, 1)
		frame.info = info
		table.insert(window.childs, index, frame)

		window.LinkChild(index)

		return frame
	end

	function window.DeleteChild (item)
		table.remove(window.childs, item.index):SetVisible(false)
		window.LinkChild(item.index - 1)
	end

	window.childs = { MinionSender.GUI.Basic.CreateFrame(window, { nil, 26, { 13, 0 }, { -13, 0, "TOPRIGHT", "TOPRIGHT" } }, 1) }
	window.AppendChild(26, 2)

	function window.SetVis (flag)
		if flag == nil then flag = not window:GetVisible() end
		window:SetVisible(flag)
		window.OnHover(nil, {}, true)
		window:ClearPoint(nil, nil)

		if flag then
			local p = {
				ww = window:GetWidth(), wh = window:GetHeight(), wcx = (window:GetWidth() % 2) / 2, wcy = (window:GetHeight() % 2) / 2,
				pw = window.parent:GetWidth(), ph = window.parent:GetHeight(), pcx = (window.parent:GetWidth() % 2) / 2, pcy = (window.parent:GetHeight() % 2) / 2,
				px = window.parent:GetLeft() + window.parent:GetWidth() / 2, py = window.parent:GetTop() + window.parent:GetHeight() / 2, 
				uw = UIParent:GetWidth(), uh = UIParent:GetHeight(), ucx = (UIParent:GetWidth() % 2) / 2, ucy = (UIParent:GetHeight() % 2) / 2
			}

			if container.align == "HORIZONTAL" then
				local o = {
					x = p.pw / 2 + p.ww / 2 + (window.properties.offsetX or 0),
					y = { p.pcy + p.wh / 2 + (window.properties.offsetY or 0),
					      -(p.pcy + p.wh / 2 + (window.properties.offsetY or 0)),
					      p.pcy + p.wcy,
					      p.uh / 2 - p.py
					}
				}

				window.direction = iif(p.px + window.owner.direction * (p.ww / 2 + o.x) < (window.owner.direction + 1) / 2 * p.uw, 1, -1)

				for k, v in ipairs(o.y) do
					if p.py + v + p.wh / 2 < p.uh and p.py + v - p.wh / 2 > 0 then
						window:SetPoint("CENTER", window.parent, "CENTER", window.direction * o.x, v)
						break
					end
				end
			elseif container.align == "CENTER" then
				window:SetPoint("CENTER", window.parent, "CENTER", p.uw / 2 - p.px, p.uh / 2 - p.py)
			else
				local o = {
					xo = p.pw / 2 + p.ww / 2 + (window.properties.offsetX or 0),
					yo = p.ph / 2 + p.wh / 2 + (window.properties.offsetY or 0),
					xc = p.pcx - p.wcx,
					yc = p.pcy - p.wcy
				}

				local r = {
					x = iif(p.px < p.uw / 2, 1, -1) * o.xo,
					y = iif(p.py < p.uh / 2, 1, -1) * o.yo
				}

				local cw = function (x, y) return p.px + x - p.ww / 2 > 0 and p.px + x + p.ww / 2 < p.uw and p.py + y - p.wh / 2 > 0 and p.py + y + p.wh / 2 < p.uh end

				if cw(-o.xo, o.yc) or cw(o.xo, o.yc) then r = { x = iif(p.px < p.uw / 2, 1, -1) * o.xo, y = o.yc } end
				if cw(o.xc, -o.yo) or cw(o.xc, o.yo) then r = { x = o.xc, y = iif(p.py < p.uh / 2, 1, -1) * o.yo } end

				window:SetPoint("CENTER", window.parent, "CENTER", r.x, r.y)
			end
		end

		return flag
	end

	function window.OnHover (handler, param)
		if param.submenu ~= window.selectedItem.submenu then
			if window.selectedItem.submenu then
				window.selectedItem.submenu.SetVis(false)
				window.selectedItem.frame.SetHighlight(false)
				window.selectedItem = { frame = nil, submenu = nil }
			end

			if param.submenu ~= nil then
				handler.SetHighlight(true)
				param.submenu.SetVis(true)
				window.selectedItem = { frame = handler, submenu = param.submenu }
			end
		end
	end

	function window.AddItem (item, submenu, index)
		local info = tableCopy(item)
		if item.submenu or submenu then info.submenu = MinionSender.GUI.Extended.CreateSubMenu(window, item.submenu or submenu, container) end

		local parent = window
		local height = item.height or (MinionSender.GUI.Extended.Controls[item.type] or {}).height or 20
		if item.position ~= "absolute" then parent = window.AppendChild(height, index, info) end

		parent.child = ((MinionSender.GUI.Extended.Controls[item.type] or { create = function(container) return MinionSender.GUI.Extended.CreateMenuLine(container) end }).create or function() end)
			({ item = item, info = info, parent = parent, height = height, onChange = container.OnChange, onHover = window.OnHover, onClick = container.OnClick, onEdit = container.OnEdit, getValue = container.GetValue, getCustom = container.GetCustom })
		container.AddDependency(item.param, parent.child)
		if info.display then container.AddDependency(item.display, parent.child) end
		if info.submenu then info.submenu.parent = parent.child end

		container.UpdateDependencies(item.param)
	end

	function window.AddList (list)
		for k, v in pairs(list) do
			local custom = (container.GetCustom or function() end)(v) or MinionSender.GUI.Extended.GetCustom(v) or {}
			if custom.type == "child" then
				window.AddItem(v, custom.description)
			elseif custom.type == "inner" then
				window.AddList(custom.description.list)
			else
				window.AddItem(v)
			end
		end
	end

	window.AddList(description.list)

	return window
end

function MinionSender.GUI.Extended.CreateMenuLine (container)
	local frame = MinionSender.GUI.Basic.CreateFrame(container.parent, { nil, container.height - 1, { 0, 0 }, { 0, 0, "TOPRIGHT" } })
	frame.inner = 0
	frame.controls = {}

	function frame.SetHighlight (flag)
		frame.inner = frame.inner + iif(flag, 1, -1)
		if frame.inner < 0 then frame.inner = 0 end
		frame:SetBackgroundColor(1, 1, 1, iif(frame.inner > 0, .1, 0)) 
		for k, v in pairs(frame.controls) do v:SetVisible(frame.inner > 0) end
	end

	frame.text = MinionSender.GUI.Basic.CreateText(frame, { { iif(container.info.icon == nil, 23, 45), -1 }, { iif(container.info.type == "ruleset", -55, -20), -1, "TOPRIGHT" } }, 5, { text = container.info.text, isLocalized = iif(container.info.isLocalized ~= nil, container.info.isLocalized, true) } )

	frame.UpdateCallback
	({
		LeftClick = function() if container.info.collapse then container.parent:GetParent().child.Event:LeftClick() else container.onClick(frame, container.info) end end,
		MouseIn = function() iif(container.info.collapse, container.parent:GetParent().child, frame).SetHighlight(true) if container.onHover then container.onHover(frame, container.info) end end,
		MouseOut = function() iif(container.info.collapse, container.parent:GetParent().child, frame).SetHighlight(false) end
	})

	if container.info.type == "checkbox" or container.info.type == "radio" then
		frame.checkbox = MinionSender.GUI.Basic.CreateTexture(frame, { 14, 12, { 7, 4 } })
		frame.UpdateCallback({ LeftClick = function() container.onChange(frame, container.info) end })

		function frame.UpdateValue (value, param)
			if param == getPath(container.info.param) then
				frame.checkbox:SetTexture(MinionSenderAddon.identifier, "img/" .. container.info.type .. "-" .. iif((container.info.value or true) == value, "t", "f") .. ".png")
			end
			if param == getPath(container.info.display) then
				frame.text.SetParameters(value)
			end
		end
	end

	if container.info.type == "ruleset" then
		frame.checkbox2 = MinionSender.GUI.Basic.CreateTexture(frame, { 14, 12, { 7, 4 } })
		frame.textfield = MinionSender.GUI.Basic.CreateTextField(frame, { 210, 19, { 25 , 0 } }, 10, frame.text, { TextfieldChange = container.onEdit, KeyDown = function (handler, param, code) if code == "Return" then MinionSender.GUI.Basic.HideField() end end, KeyFocusLoss = function (handler) MinionSender.GUI.Basic.HideField() end, param = { frame = frame.text, value = container.info.value } }, true)
		frame.UpdateCallback({ LeftClick = function() container.onChange(frame, { param = container.info.param, value = container.info.value }) end })
		table.insert(frame.controls, MinionSender.GUI.Basic.CreateButton(frame, { 12, 15, { -40, 2, "TOPRIGHT" } }, 10, "edit", container.onClick, { param = "editRuleset", value = container.info.value, field = frame.textfield }, false, true, true, true))
		table.insert(frame.controls, MinionSender.GUI.Basic.CreateButton(frame, { 15, 15, { -20, 2, "TOPRIGHT" } }, 10, "delete", container.onClick, { param = "deleteRuleset", value = container.info.value, parent = container.parent }, false, true, true, true))

		function frame.UpdateValue (value)
			frame.checkbox2:SetTexture(MinionSenderAddon.identifier, "img/radio-" .. iif(container.info.value == value, "t", "f") .. ".png")
		end
	end

	if container.info.type == "rule" then
		frame.text2 = MinionSender.GUI.Basic.CreateText(frame, { { 23, 19 } }, 5, { text = "%s, %s", isLocalized = true } )
		table.insert(frame.controls, MinionSender.GUI.Basic.CreateButton(frame, { 15, 15, { -20, 22, "TOPRIGHT" } }, 10, "delete", container.onClick, { param = "deleteRule", value = container.info.value, parent = container.parent }, false, true, true, true))
		frame.priority = {}
		frame.match = {}

		for k, v in pairs({ "match", "common", "uncommon", "rare", "epic", "attractor" }) do
			local x = k * 21 - iif(k == 1, 158, iif(k == 6, 143, 148))
			MinionSender.GUI.Basic.CreateTexture(frame, { 21, 16, { x, 1, "TOPRIGHT" } }, 10, iif(k == 1, "match.png", iif(k == 6, "attractor.png", "minion.png")))
			if k == 1 then
				frame.match[0] = MinionSender.GUI.Basic.CreateTexture(frame, { 21, 16, { x, 1, "TOPRIGHT" } }, 11, "minion-" .. v .. "-0.png")
				frame.match[1] = MinionSender.GUI.Basic.CreateTexture(frame, { 21, 16, { x, 1, "TOPRIGHT" } }, 11, "minion-" .. v .. "-1.png")
				frame.match[2] = MinionSender.GUI.Basic.CreateTexture(frame, { 21, 16, { x, 1, "TOPRIGHT" } }, 11, "minion-" .. v .. "-2.png")
			else
				frame.priority[v] = MinionSender.GUI.Basic.CreateTexture(frame, { 21, 16, { x, 1, "TOPRIGHT" } }, 11, "minion-" .. v .. ".png")
			end
		end

		function frame.UpdateValue (value)
			local rule = container.getCustom({ type = "custom", param = "rule", value = container.info.value })
			frame.text.SetParameters(rule.level.min, rule.level.max)
			frame.text2.SetParameters("RuleDuration" .. rule.duration, "RulePriority" .. rule.priority)
			for k, v in pairs(frame.priority) do v:SetVisible(rule["filter" .. k] or false) end
			for k, v in pairs(frame.match) do v:SetVisible(rule["match" .. tostring(k)] or false) end
		end
	end

	if container.info.type == "color" then
		MinionSender.GUI.Basic.CreateTexture(frame, { 16, 16, { 5, 2 } }, 5, "color.png")
		frame.color = MinionSender.GUI.Basic.CreateFrame(frame, { 12, 12, { 7, 4 } }, 4)

		function frame.UpdateValue (value)
			frame.color:SetBackgroundColor(value[1] / 255, value[2] / 255, value[3] / 255, 1)
		end
	end

	if container.info.type == "slider" then
		frame.slider = MinionSender.GUI.Basic.CreateSlider(frame, { 100, 17, { -15, 1, "TOPRIGHT" } }, 5, container.info.min, container.info.max, container.info.count or 1, container.info.step or 1, container.getValue(container.info.param), function(value) container.onChange(frame, { param = container.info.param, value = value }) end)

		function frame.UpdateValue (value)
			if type(value) == "table" then
				frame.text.SetParameters(value.min, value.max)
			else
				frame.text.SetParameters(value)
			end
		end
	end

	if frame.UpdateValue == nil then function frame.UpdateValue () end end

	frame.UpdateText = function()
		if frame.text then frame.text.UpdateText() end
		if frame.text2 then frame.text2.UpdateText() end
	end

	if container.info.submenu ~= nil then MinionSender.GUI.Basic.CreateTexture(frame, { 9, 15, { -5, container.height / 2 - 8, "TOPRIGHT" } }, 5, "folder.png") end
	if container.info.icon ~= nil then MinionSender.GUI.Basic.CreateTexture(frame, { 17, 17, { 24, container.info.iconOffset or 1 } }, 5, { container.info.icon, true }) end

	return frame
end

function MinionSender.GUI.Extended.CreateColorPicker (parent, callbackChange, info, value)
	local frame = {
		color = colorRGBtoHSB(value),
		satMask = MinionSender.GUI.Basic.CreateMask(parent, { 256, 256, { 14, 1 } }, 15),
		lines = {}
	}

	frame.SetHue = function (h)
		if h ~= nil then frame.color.h = math.min(math.max(h, 0), 359) end
		frame.huePointer:SetPoint("TOPLEFT", frame.hue, "TOPLEFT", -7, (359 - frame.color.h) / 359 * 255 - 3)
		for i = 1, 256, 1 do
			frame.lines[i]:SetShape(MinionSender.GUI.Extended.Canvas.path.rectangle, { type = "gradientLinear", transform = MinionSender.GUI.Extended.Canvas.matrix.sat, color = { colorRGBtoGradient(colorHSBtoRGB({ h = frame.color.h, s = 0, b = (256 - i) / 2.55 }), 0),  colorRGBtoGradient(colorHSBtoRGB({ h = frame.color.h, s = 100, b = (256 - i) / 2.55 }), 1) } }, nil)
		end
	        if callbackChange ~= nil then callbackChange(frame, { param = info.param, value = colorHSBtoRGB(frame.color) }) end
	end

	frame.SetSat = function (s, b)
		if s ~= nil then frame.color.s = math.min(math.max(s, 0), 100) end
		if b ~= nil then frame.color.b = math.min(math.max(b, 0), 100) end
		frame.satPointer:SetPoint("TOPLEFT", frame.sat, "TOPLEFT", frame.color.s * 2.55 - 5, 250 - frame.color.b * 2.55)
		frame.satPointer:SetTexture(MinionSenderAddon.identifier, "img/cpSat" .. iif(frame.color.b > 60, "B", "W") .. ".png")
	        if callbackChange ~= nil then callbackChange(frame, { param = info.param, value = colorHSBtoRGB(frame.color) }) end
	end

	frame.sat = MinionSender.GUI.Basic.CreateCanvas(parent, { 257, 257, { 13, 0 } }, 10, {
			WheelBack = function(handler) frame.SetHue(frame.color.h - 1.40625) end,
			WheelForward = function(handler) frame.SetHue(frame.color.h + 1.40625) end,
			LeftDown = function(handler) handler.downed = true frame.SetSat((Inspect.Mouse().x - handler:GetLeft()) / 2.55, (255 - Inspect.Mouse().y + handler:GetTop()) / 2.55) end,
			MouseMove = function(handler, param, x, y) if handler.downed then frame.SetSat((x - handler:GetLeft()) / 2.55, (255 - y + handler:GetTop()) / 2.55) end end,
			LeftUp = function(handler) handler.downed = false end,
			LeftUpoutside = function(handler) handler.downed = false end
		}, MinionSender.GUI.Extended.Canvas.path.rectangle, nil, MinionSender.GUI.Extended.Canvas.stroke.border)

	frame.hue = MinionSender.GUI.Basic.CreateCanvas(parent, { 21, 257, { 285, 0 } }, 10, {
			WheelBack = function(handler) frame.SetHue(frame.color.h - 1.40625) end,
			WheelForward = function(handler) frame.SetHue(frame.color.h + 1.40625) end,
			LeftDown = function(handler) handler.downed = true frame.SetHue((255 - Inspect.Mouse().y + handler:GetTop()) / 255 * 359) end,
			MouseMove = function(handler, param, x, y) if handler.downed then frame.SetHue((255 - y + handler:GetTop()) / 255 * 359) end end,
			LeftUp = function(handler) handler.downed = false end,
			LeftUpoutside = function(handler) handler.downed = false end
		}, MinionSender.GUI.Extended.Canvas.path.rectangle, MinionSender.GUI.Extended.Canvas.fill.hue, MinionSender.GUI.Extended.Canvas.stroke.border)

	frame.satPointer = MinionSender.GUI.Basic.CreateTexture(frame.satMask, { 13, 13 }, 20)
	frame.huePointer = MinionSender.GUI.Basic.CreateTexture(frame.hue, { 36, 9, { -7, 0 } }, 20, "cpHue.png")

	for i = 1, 256, 1 do
		frame.lines[i] = MinionSender.GUI.Basic.CreateCanvas(frame.sat, { 256, 1, { 1, i } }, 15)
	end

	frame.SetHue()
	frame.SetSat()

	return frame
end

function MinionSender.GUI.Extended.CreateChart (parent, align, x, y, prop, param)
	local frame = MinionSender.GUI.Basic.CreateCanvas(parent, { prop.w, prop.h, { x, y } }, 10, nil, MinionSender.GUI.Extended.Canvas.path.rectangle, MinionSender.GUI.Extended.Canvas.fill.chart, nil)
	frame.lines = {}
	frame.labels = {}
	frame.max = MinionSender.GUI.Basic.CreateText(frame, { { prop.w - 2, -7 } }, 20, { fontSize = 9, fontColor = { 153, 154, 122 } })

	local i = prop.m
	for k, v in pairs(prop.description) do
		if v.color then 
			frame.lines[k] = MinionSender.GUI.Basic.CreateFrame(frame, { v.w or prop.lw, 0, { i, -1, "BOTTOMLEFT" } }, 20)
			frame.lines[k]:SetBackgroundColor(v.color[1] / 255, v.color[2] / 255, v.color[3] / 255)
			MinionSender.GUI.Basic.CreateTexture(frame.lines[k], { { 0, 0 }, { 0, 0, "BOTTOMRIGHT" } }, 30, "gv.png")
		end
		frame.labels[k] = MinionSender.GUI.Basic.CreateText(frame, { { i + (v.w or prop.lw) / 2, prop.h - 2, "TOPCENTER", "TOPLEFT" } }, 20, { fontSize = 9, fontColor = { 153, 154, 122 } })
		if v.icon then MinionSender.GUI.Basic.CreateTexture(frame, { v.w or prop.lw, v.w or prop.lw, { i, -15 } }, 20, { v.icon, true }) end
		i = i + (v.w or prop.lw) + prop.ls
	end

	function frame.UpdateValue (value)
		local maxval = 0
		value = value or {}

		for k, v in pairs(prop.description) do
			maxval = math.max(maxval, value[v.param or k] or 0)
		end

		if not prop.legend then frame.max:SetText(iif(maxval == 0, "", tostring(maxval))) end

		if maxval ~= 0 then
			for k, v in pairs(prop.description) do
				if v.color then frame.lines[k]:SetHeight(iif((value[v.param or k] or 0) == 0, 0, math.floor(math.max((value[v.param or k] or 0) / maxval * (prop.h - 1) + .5, 1)))) end
				if prop.legend then frame.labels[k]:SetText(tostring(value[v.param or k] or "")) end
			end
		end
	end

	return frame
end

function MinionSender.GUI.Extended.GetCustom (info)
	if info.type == "color" then
		return { type = "child", description = {
			properties = { width = 346, offsetX = -15, offsetY = -36 },
			list = {
				{ type = "empty" },
				{ type = "colorPicker", param = info.param },
				{ type = "empty" }
			}
		} }
	end
end
