-- Public Functions

local toc, data = ...
local AddonId = toc.identifier

local function SetBorder(self, width, r, g, b, a)
  Library.LibSimpleWidgetsLifeEdition.SetBorder(self, width, r, g, b, a)
end

local function GetChecked(self)
  return self.check:GetChecked()
end

local function SetChecked(self, checked)
  assert(type(checked) == "boolean", "param 1 must be a boolean!")

  self.check:SetChecked(checked)
end

local function GetEnabled(self)
  return self.check:GetEnabled()
end

local function SetEnabled(self, enabled)
  assert(type(enabled) == "boolean", "param 1 must be a boolean!")

  self.check:SetEnabled(enabled)
  if enabled then
    self.label:SetFontColor(1, 1, 1, 1)
  else
    self.label:SetFontColor(0.5, 0.5, 0.5, 1)
  end
end

local function GetText(self)
  return self.label:GetText()
end

local function SetText(self, text)
  assert(type(text) == "string", "param 1 must be a string!")

  self.label:SetText(text)
  self:ResizeToFit()
end

local function SetLabelPos(self, pos)
  assert(type(pos) == "string", "param 1 must be a string!")
  assert(pos == "left" or pos == "right", "param 1 must be one of: left, right")

  if pos == "right" then
    self.check:ClearAll()
    self.label:ClearAll()
    self.label:SetPoint("TOPLEFT", self, "TOPLEFT", self.check:GetWidth(), 0)
    self.label:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    self.check:SetPoint("CENTERRIGHT", self.label, "CENTERLEFT")
  elseif pos == "left" then
    self.check:ClearAll()
    self.label:ClearAll()
    self.label:SetPoint("TOPRIGHT", self, "TOPRIGHT", -self.check:GetWidth(), 0)
    self.label:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
    self.check:SetPoint("CENTERLEFT", self.label, "CENTERRIGHT")
  end
  self.labelPos = pos
end

local function GetFontSize(self)
  return self.label:GetFontSize()
end

local function SetFontSize(self, size)
  assert(type(size) == "number", "param 1 must be a number!")

  self.label:SetFontSize(size)
  self:ResizeToFit()
end

local function GetFontColor(self)
  return self.label:GetFontColor()
end

local function SetFontColor(self, r, g, b, a)
  self.label:SetFontColor(r, g, b, a)
end

local function GetFont(self)
  return self.label:GetFont()
end

local function SetFont(self, source, font)
  self.label:SetFont(source, font)
end
	
local function GetEffectGlow(self)
  return self.label:GetEffectGlow()
end

local function SetEffectGlow(self, effect)
  self.label:SetEffectGlow(effect)
end

local function ResizeToFit(self)
  self.label:ClearAll()

  self:SetHeight(self.label:GetHeight())
  self:SetWidth(self.check:GetWidth() + self.label:GetWidth())

  self:SetLabelPos(self.labelPos)
end


-- Constructor Function

function Library.LibSimpleWidgetsLifeEdition.Checkbox(name, parent)
  local widget = UI.CreateFrame("Frame", name, parent)
  widget.check = UI.CreateFrame("RiftCheckbox", name.."Check", widget)
  widget.label = UI.CreateFrame("Text", name.."Label", widget)
  widget.label:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
  widget.label:SetFontColor(1,0.97,0.84,1)
  --widget.label:SetFont(AddonId, "blank-Bold")
  widget.label:SetFontSize(12)

  widget:SetHeight(widget.label:GetHeight())
  widget:SetWidth(widget.check:GetWidth() + widget.label:GetWidth())

  SetLabelPos(widget, "right")

  local function MouseIn(self)
    if widget.Event.MouseIn and not (widget.label.mousein or widget.label.mousein) then
      self.mousein = true
      widget.Event.MouseIn(widget)
    end
  end
  local function MouseOut(self)
    self.mousein = false
    if widget.Event.MouseOut and not (widget.label.mousein or widget.label.mousein) then
      widget.Event.MouseOut(widget)
    end
  end
  local function MouseMove(self)
    if widget.Event.MouseMove then
      widget.Event.MouseMove(widget)
    end
  end

  widget.label.Event.MouseIn = MouseIn
  widget.label.Event.MouseOut = MouseOut
  widget.label.Event.MouseMove = MouseMove
  function widget.label.Event:LeftClick()
    widget.check:SetChecked(not widget.check:GetChecked())
  end

  widget.check.Event.MouseIn = MouseIn
  widget.check.Event.MouseOut = MouseOut
  widget.check.Event.MouseMove = MouseMove
  function widget.check.Event:CheckboxChange()
    if widget.Event.CheckboxChange then
      widget.Event.CheckboxChange(widget)
    end
  end

  widget.SetBorder = SetBorder
  widget.GetFontSize = GetFontSize
  widget.SetFontSize = SetFontSize
  widget.GetFont = GetFont
  widget.SetFont = SetFont  
  widget.GetFontColor = GetFontColor
  widget.SetFontColor = SetFontColor
  widget.GetEffectGlow = GetEffectGlow
  widget.SetEffectGlow = SetEffectGlow
  widget.GetChecked = GetChecked
  widget.SetChecked = SetChecked
  widget.GetEnabled = GetEnabled
  widget.SetEnabled = SetEnabled
  widget.GetText = GetText
  widget.SetText = SetText
  widget.SetLabelPos = SetLabelPos
  widget.ResizeToFit = ResizeToFit

  Library.LibSimpleWidgetsLifeEdition.EventProxy(widget, {"CheckboxChange", "MouseIn", "MouseOut", "MouseMove"})

  return widget
end
