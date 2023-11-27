--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2014-06-23T17:36:15Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- UTILITY FUNCTIONS
-------------------------------------------------------------------------------

-- Namespace for Utility methods
WT.Utility = {}

-- Measure the square of the distance between 2 points (avoids the sqrt operation required to calculate actual distance)
function WT.Utility.MeasureDistanceSquared(x1, y1, z1, x2, y2, z2)
	-- Calculate the delta for each coordinate
	local dx = x1 - x2
	local dy = y1 - y2
	local dz = z1 - z2

	-- Return the distance^2 in meters between the 2 units
	return dx*dx+dy*dy+dz*dz
end

-- Measure the distance between 2 points
function WT.Utility.MeasureDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(WT.Utility.MeasureDistanceSquared(x1, y1, z1, x2, y2, z2))
end

function WT.Utility.TextConvertXofY(x, y)
	if x and y then
		return x .. " / " .. y
	else
		return nil
	end
end

function WT.Utility.TextConvertPercent(x, y)
	if (x and y) and (y ~= 0) then
		return string.format("%d", math.ceil((x / y) * 100)) .. "%"
	else
		return nil
	end
end

function WT.Utility.NumberDesc(x)
	if x < 10000 then return x .. "" end
	if x < 1000000 then return string.format("%.1fK", x / 1000) end
	return string.format("%.1fM", x / 1000000)
end

function WT.Utility.NumberComma(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function WT.Utility.ToBoolean(value)
	if value then
		return true
	else
		return false
	end
end

-- Alters a frame to have fixed width and height, and a single TOPLEFT anchor point
function WT.Utility.DeAnchor(frame)
	local left = frame:GetLeft()
	local top = frame:GetTop()
	local width = frame:GetWidth()
	local height = frame:GetHeight()
	
	frame:ClearAll()
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
	frame:SetWidth(width)
	frame:SetHeight(height)
end

function WT.Utility.ClearKeyFocus(frame)

	if frame:GetType() == "RiftTextfield" and frame:GetKeyFocus() then
		frame:SetKeyFocus(false)
		return
	end
	for child in pairs(frame:GetChildren()) do WT.Utility.ClearKeyFocus(child) end

end


function string.wtSplit(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function string.wtTrim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local pendingVisibility = {}
local pendingFunctions = {}

function WT.ShowSecureFrame(frame)

	if not frame:GetSecureMode() then
		frame:SetVisible(true)
		return
	end

	if not Inspect.System.Secure() then
		frame:SetVisible(true)
		pendingVisibility[frame] = nil
	else
		pendingVisibility[frame] = true
	end
end


function WT.HideSecureFrame(frame)

	if not frame:GetSecureMode() then
		frame:SetVisible(false)
		return
	end

	if not Inspect.System.Secure() then
		frame:SetVisible(false)
		pendingVisibility[frame] = nil
	else
		pendingVisibility[frame] = false
	end
end


function WT.SecureFunction(fn)
    
    if not Inspect.System.Secure() then
        fn()
    else
        table.insert(pendingFunctions, fn)
    end
    
end


local function OnSecureEnter(hEvent)
end

local function OnSecureLeave(hEvent)
	for frame, show in pairs(pendingVisibility) do
		if show == true then
			frame:SetVisible(true)
		end
		if show == false then
			frame:SetVisible(false)
		end
		pendingVisibility[frame] = nil
	end
	
	for _, fn in ipairs(pendingFunctions) do
	    fn()
	end
	pendingFunctions = {}
end 

Command.Event.Attach(Event.System.Secure.Enter, OnSecureEnter, "OnSecureEnter")
Command.Event.Attach(Event.System.Secure.Leave, OnSecureLeave, "OnSecureLeave")
