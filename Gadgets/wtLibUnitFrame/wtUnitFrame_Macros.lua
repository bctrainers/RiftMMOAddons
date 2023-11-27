--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.4.8
      Project Date (UTC)  : 2013-07-04T23:34:42Z
      File Modified (UTC) : 2013-05-20T07:13:55Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function WT.UnitFrame.MACRO_LINE(unitSpec, ln)
	return ln:gsub("@unit", "@" .. unitSpec) .. "\n"
end

local function buildMacro(frame, macroText)	
	-- First, split the macro into individual lines
	local lines = {}
	(macroText .. "\n"):gsub('\r', '\n'):gsub("(.-)\r?\n", function(ln) if ln ~= "" then table.insert(lines, ln) end end)
	
	-- If the macro is empty, return nil
	if #lines == 0 then 
		return nil 
	end

	if lines[1]:gsub('\n','') == "menu" then
		return "menu"
	end

	-- Now build up the macro function
	local macroFunction = "local role = WT.Player.Role or Inspect.TEMPORARY.Role()\n"
	macroFunction = macroFunction .. "local unit = '" .. frame.UnitSpec .. "'\n"
	macroFunction = macroFunction .. "local MACRO = ''\n"
	macroFunction = macroFunction .. "local MACRO_LINE = WT.UnitFrame.MACRO_LINE\n"

	for _, line in ipairs(lines) do
		if line:sub(1,1) == ":" then
			macroFunction = macroFunction .. line:sub(2) .. "\n"
		else
			macroFunction = macroFunction .. "MACRO = MACRO .. MACRO_LINE(unit, \"" .. trim(line) .. "\")\n"
		end	
	end
	
	macroFunction = macroFunction .. "return MACRO\n"
	return loadstring(macroFunction)
end

function WT.UnitFrame:RebuildMacros()
	if self._MACRO then
		for eventName, fn in pairs(self._MACRO) do
			if type(fn) == "function" then
				self.Event[eventName] = fn()
			elseif fn == nil then
				self.Event[eventName] = nil
			end
		end
	end
end

function WT.UnitFrame:SetLeftMacro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN LEFT BUTTON MACRO DEFINITION", false)
	end
	self._MACRO.LeftDown = fn
	if fn == "menu" then 
		self.Event.LeftDown = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.LeftDown = fn() 
	else 
		self.Event.LeftDown = nil 
	end
end

function WT.UnitFrame:SetRightMacro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN RIGHT BUTTON MACRO DEFINITION", false)
	end
	self._MACRO.RightDown = fn
	if fn == "menu" then
		self.Event.RightDown = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.RightDown = fn() 
	else 
		self.Event.RightDown = nil 
	end
end

function WT.UnitFrame:SetMiddleMacro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN MIDDLE BUTTON MACRO DEFINITION", false)
	end
	self._MACRO.MiddleDown = fn
	if fn == "menu" then 
		self.Event.MiddleDown = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.MiddleDown = fn() 
	else 
		self.Event.MiddleDown = nil 
	end
end

function WT.UnitFrame:SetMouse4Macro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN BUTTON 4 MACRO DEFINITION", false)
	end
	self._MACRO.Mouse4Down = fn
	if fn == "menu" then 
		self.Event.Mouse4Down = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.Mouse4Down = fn() 
	else 
		self.Event.Mouse4Down = nil 
	end
end

function WT.UnitFrame:SetMouse5Macro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN BUTTON 5 MACRO DEFINITION", false)
	end
	self._MACRO.Mouse5Down = fn
	if fn == "menu" then 
		self.Event.Mouse5Down = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.Mouse5Down = fn() 
	else 
		self.Event.Mouse5Down = nil 
	end
end

function WT.UnitFrame:SetWheelForwardMacro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN WHEEL FORWARD MACRO DEFINITION", false)
	end
	self._MACRO.WheelForward = fn
	if fn == "menu" then 
		self.Event.WheelForward = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.WheelForward = fn() 
	else 
		self.Event.WheelForward = nil 
	end
end

function WT.UnitFrame:SetWheelBackMacro(macroText)
	if not self._MACRO then self._MACRO = {} end
	local fn, errMsg = buildMacro(self, macroText)
	if not fn and errMsg then
		Command.Console.Display("general", true, "ERROR IN WHEEL BACK MACRO DEFINITION", false)
	end
	self._MACRO.WheelBack = fn
	if fn == "menu" then 
		self.Event.WheelBack = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	elseif fn then 
		self.Event.WheelBack = fn() 
	else 
		self.Event.WheelBack = nil 
	end
end

function WT.UnitFrame:SetMacros(macros)
	if macros.Left then self:SetLeftMacro(macros.Left) end
	if macros.Middle then self:SetMiddleMacro(macros.Middle) end
	if macros.Right then self:SetRightMacro(macros.Right) end
	if macros.Mouse4 then self:SetMouse4Macro(macros.Mouse4) end
	if macros.Mouse5 then self:SetMouse5Macro(macros.Mouse5) end
	if macros.WheelForward then self:SetWheelForwardMacro(macros.WheelForward) end
	if macros.WheelBack then self:SetWheelBackMacro(macros.WheelBack) end
end

local function UpdateAllMacros()
	if Inspect.System.Secure() then return end
	for idx, frame in ipairs(WT.UnitFrames) do frame:RebuildMacros() end
end

local function OnRoleChange(hEvent, role)
	WT.Player.Role = role
	UpdateAllMacros()
end

Command.Event.Attach(Event.TEMPORARY.Role, OnRoleChange, "WT_UnitFrame_RoleChange")
