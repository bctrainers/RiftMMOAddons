--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.6
      Project Date (UTC)  : 2013-11-03T06:56:55Z
      File Modified (UTC) : 2013-06-11T07:10:52Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- This allows for fluent building of a dialog, consisting of a vertical stack of controls

local CDialog = {}
local CDialog_mt = { __index = CDialog }

function CDialog:add(id, label, control, labelFontSize, stretch, iconFile, labelFontOutline, labelFontColor, labelFontColorY)

	local lbl = false		
	local frm = UI.CreateFrame("Frame", "DialogFormRow", self.container)
	
	if label then

		lbl = UI.CreateFrame("Text", "DialogFieldLbl", frm)
	
		if iconFile then
			local icon = UI.CreateFrame("Texture", "DialogIcon", frm)
			icon:SetTexture(AddonId, iconFile)
			icon:SetPoint("TOPLEFT", frm, "TOPLEFT")
			lbl:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, -3)
		else
			lbl:SetPoint("TOPLEFT", frm, "TOPLEFT")
		end
	
		if (not control) then
			lbl:SetPoint("RIGHT", frm, "RIGHT")
		else
			lbl:SetPoint("RIGHT", frm, "LEFT", self.labelWidth - 16, nil)
		end
		lbl:SetWordwrap(true)
		if labelFontSize then
			lbl:SetFontSize(labelFontSize)
		else
			lbl:SetFontSize(16)
		end
		lbl:SetText(label)
		--lbl:SetFont(AddonId, "blank-Bold")
		lbl:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		lbl:SetFontColor(1,0.97,0.84,1)
		if labelFontOutline then
			lbl:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		end
		if labelFontColor then
			lbl:SetFontColor(1,0.97,0.84,1)
		end
		if labelFontColorY then
			lbl:SetFontColor(0.2,0.4,0.7)
			lbl:SetEffectGlow({ strength = 3, })
		end
	end
	
	frm.control = control
	frm.id = id

	if #self.fields == 0 then
		frm:SetPoint("TOPLEFT", self.container, "TOPLEFT")
	elseif #self.fields == 20 then
		frm:SetPoint("TOPLEFT", self.fields[1], "BOTTOMRIGHT", -245 , 8)
	elseif #self.fields > 20 then
		frm:SetPoint("TOPLEFT", self.fields[#self.fields], "BOTTOMLEFT", 0, 8)
	else
		frm:SetPoint("TOPLEFT", self.fields[#self.fields], "BOTTOMLEFT", 0, 8)
	end

	
	frm:SetPoint("RIGHT", self.container, "RIGHT")

	if control then
		control:SetParent(frm)
		control:SetPoint("TOPLEFT", frm, "TOPLEFT", self.labelWidth, 0)
		if stretch then
			control:SetPoint("RIGHT", frm, "RIGHT")
		end
		frm:SetPoint("BOTTOM", control, "BOTTOM")
	else
		if lbl then
			frm:SetPoint("BOTTOM", lbl, "BOTTOM")
		else
			frm:SetHeight(8)
		end
	end

	table.insert(self.fields, frm)
	
	return frm
end

function CDialog:GetControl(id)
	for idx, control in ipairs(self.fields) do
		if control.id == id then return control end
	end
	return nil
end

function CDialog:Label(label)
	self:add(nil, label, nil, 14, false, false, true, true)
	return self
end

function CDialog:Title(label)
	self:add(nil, label, nil, 18, false, false, true, true)
	return self
end

function CDialog:TitleY(label)
	self:add(nil, label, nil, 18, false, false, false, false, true)
	return self
end

function CDialog:Heading(label)
	self:add(nil, label, nil, 18)
	return self
end

function CDialog:FieldNote(note)
	-- Double span notes... (note - setting stretch to true with no control will make the label span the full width)
	self:add(nil, note, nil, 14, true, "img/wtInfo12.png")	
	return self
end

function CDialog:Textfield(id, label, text)
	local control = UI.CreateFrame("RiftTextfield", "DialogField", self.container)
	control:SetBackgroundColor(0.2,0.2,0.2,0.9)
	control:SetText(text)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:Checkbox(id, label, checked)
	local control = UI.CreateFrame("RiftCheckbox", "DialogField", self.container)
	control:SetChecked(checked)
	local frm = self:add(id, label, control, 16)
	frm.getValue = control.GetChecked
	frm.setValue = control.SetChecked
	return self
end

function CDialog:Combobox(id, label, default, listItems, sort, onchange)
	local control = WT.Control.ComboBox.Create(self.container, nil, default, listItems, sort, onchange)
	control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:Select(id, label, default, listItems, sort, onchange)
	local control = WT.Control.Select.Create(self.container, nil, default, listItems, sort, onchange)
	control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:Slider(id, label, default)
	
	local control = WT.Control.Slider.Create(self.container, id, label, default, onchange)
	--control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetPosition
	frm.setValue = control.SetPosition
	return self
	
end

function CDialog:SliderRange(id, label, minRange, maxRange, default)
	
	local control = WT.Control.SliderRange.Create(self.container, id, label, minRange, maxRange, default, onchange)
	--control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetPosition
	frm.setValue = control.SetPosition
	return self
	
end

function CDialog:MacroSet(id, label)
	local control = WT.Control.MacroSet.Create(self.container, label)
	local frm = self:add(id, "Mouse Macros", control)
	frm.getValue = control.GetMacros
	frm.setValue = control.SetMacros
	return self
end

function CDialog:Spacer(height)
	-- Double span notes... (note - setting stretch to true with no control will make the label span the full width)
	local gap = UI.CreateFrame("Frame", "spacer", self.container)
	gap:SetPoint("TOPLEFT", self.fields[#self.fields], "BOTTOMLEFT")
	gap:SetHeight(height)
	self.fields[#self.fields+1] = gap
	return self
end

function CDialog:TexSelect(id, label, default, mediaTag, onchange)
	local control = WT.Control.TexSelect.Create(self.container, nil, default, mediaTag, onchange)
	control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:ImgSelect(id, label, default, mediaTag, onchange)
	local control = WT.Control.ImgSelect.Create(self.container, nil, default, mediaTag, onchange)
	control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:ColorPicker(id, label, r, g, b, a)
	local control = WT.Control.ColorPicker.Create(self.container, nil, r, g, b, a)
	control:SetColor(r,g,b,a)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetValue
	frm.setValue = control.SetValue
	return self
end

function CDialog:FontSize(value)
	local item = self.fields[#self.fields].control
	item:SetFontSize(value)
	return self
end

function CDialog:Width(value)
	local item = self.fields[#self.fields].control
	item:SetWidth(value)
	return self
end

function CDialog:Height(value)
	local item = self.fields[#self.fields].control
	item:SetHeight(value)
	return self
end

function CDialog:GetValue(id)
	for idx,field in ipairs(self.fields) do
		if field.id == id then
			local ctrl = field.control
			if field.getValue then
				return field.getValue(ctrl)
			else
				return nil
			end
		end
	end
end

function CDialog:GetValues()
	local vals = {}
	for idx,field in ipairs(self.fields) do
		if field.id then
			if field.getValue then
				vals[field.id] = field.getValue(field.control)
			end
		end
	end
	return vals
end


function CDialog:SetValues(tbl)
	for idx,field in ipairs(self.fields) do
		if field.id then
			local ctrl = field.control
			if field.setValue and tbl[field.id] ~= nil then
				field.setValue(ctrl, tbl[field.id])
			end
		end
	end
end


function WT.Dialog(container, labelWidth)
	local obj = {}
	obj.labelWidth = labelWidth or 220
	obj.container = container
	obj.fields = {}
	obj.isWTDialog = true
	setmetatable(obj, CDialog_mt)
	return obj
end
