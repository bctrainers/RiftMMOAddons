--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-09-14T11:35:04Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier

--[[

This processor will take a unit frame template's elements table, and attempt to alter 
the attachments in each one to be relative to the unit frame itself.

This is to allow resizable unit frames without the template author needing to worry
about relative positioning for every template element.

--]]

local pointNames =
{
	["TOPLEFT"] 	= {0.0, 0.0},
	["TOPCENTER"] 	= {0.5, 0.0},
	["TOPRIGHT"] 	= {1.0, 0.0},
	["CENTERLEFT"] 	= {0.0, 0.5},
	["CENTER"] 		= {0.5, 0.5},
	["CENTERRIGHT"]	= {1.0, 0.5},
	["BOTTOMLEFT"] 	= {0.0, 1.0},
	["BOTTOMCENTER"]= {0.5, 1.0},
	["BOTTOMRIGHT"] = {1.0, 1.0},
	["CENTERX"] 	= {0.5, nil},
	["CENTERY"] 	= {nil, 0.5},
	["TOP"] 		= {nil, 0.0},
	["LEFT"] 		= {0.0, nil},
	["BOTTOM"] 		= {nil, 1.0},
	["RIGHT"]		= {1.0, nil},
}

local function translatePoint(pt)
	if type(pt) == "table" then
		return pt
	end
	if pointNames[pt] then
		return pointNames[pt]
	end
	error("Invalid point: " .. tostring(pt))
end


function RefreshPosition(frame)

	local h1, h2, v1, v2
	local x1, x2, y1, y2

	if frame.hpoint1 then h1 = frame.hpoints[frame.hpoint1] end
	if frame.hpoint2 then h2 = frame.hpoints[frame.hpoint2] end
	if frame.vpoint1 then v1 = frame.vpoints[frame.vpoint1] end
	if frame.vpoint2 then v2 = frame.vpoints[frame.vpoint2] end

    if (h1) then
        x1 = h1.attachTo.left + (h1.attachTo.width * h1.toX) + h1.offsetX
        if (h2) then
            -- Screen coords of the two points
            x2 = h2.attachTo.left + (h2.attachTo.width * h2.toX) + h2.offsetX
            local deltaLength = h2.fromX - h1.fromX
            local screenLength = x2 - x1
            local width = screenLength / deltaLength
            frame.width = math.max(width, 0)
        end
        local deltaX = (frame.width or 0) * h1.fromX
        frame.left = x1 - deltaX
    end

    if (v1) then
        y1 = v1.attachTo.top + (v1.attachTo.height * v1.toY) + v1.offsetY
        if (v2) then
            -- Screen coords of the two points
            y2 = v2.attachTo.top + (v2.attachTo.height * v2.toY) + v2.offsetY
            local deltaLength = v2.fromY - v1.fromY
            local screenLength = y2 - y1
            local height = screenLength / deltaLength
            frame.height = math.max(height, 0)
        end
        local deltaY = (frame.height or 0) * v1.fromY
        frame.top = y1 - deltaY
    end
end


-- This is the actual implementation after names have been expanded
local function _SetPoint(self, fromX, fromY, attachTo, toX, toY, offsetX, offsetY)

	if not self.hpoints then self.hpoints = {} end
	if not self.vpoints then self.vpoints = {} end

	if fromX then
		-- Horizontal point defined
		local ptName = "PTX" .. math.ceil(fromX * 100)
		self.hpoints[ptName] = self.hpoints[ptName] or {}
		self.hpoints[ptName].attachTo = attachTo
		self.hpoints[ptName].fromX = fromX
		self.hpoints[ptName].toX = toX
		self.hpoints[ptName].offsetX = offsetX or 0
		if #self.hpoints > 2 then error("Too many horizontal points defined") end
		if #self.hpoints == 2 and self.width then error("Width and 2 horizontal points defined") end
		self.hpoint1 = nil
		self.hpoint2 = nil
		for k in pairs(self.hpoints) do
			if not self.hpoint1 then
				self.hpoint1 = k
			else
				if k > self.hpoint1 then
					self.hpoint2 = k
				else
					self.hpoint2 = self.hpoint1
					self.hpoint1 = k
				end
			end
		end
	end
	if fromY then
		local ptName = "PTY" .. math.ceil(fromY * 100)
		-- Vertical point defined
		self.vpoints[ptName] = self.vpoints[ptName] or {}
		self.vpoints[ptName].attachTo = attachTo
		self.vpoints[ptName].fromY = fromY
		self.vpoints[ptName].toY = toY
		self.vpoints[ptName].offsetY = offsetY or 0
		if #self.vpoints > 2 then error("Too many vertical points defined") end
		if #self.vpoints == 2 and self.height then error("Height and 2 vertical points defined") end
		self.vpoint1 = nil
		self.vpoint2 = nil
		for k in pairs(self.vpoints) do
			if not self.vpoint1 then
				self.vpoint1 = k
			else
				if k > self.vpoint1 then
					self.vpoint2 = k
				else
					self.vpoint2 = self.vpoint1
					self.vpoint1 = k
				end
			end
		end
	end
	RefreshPosition(self)
end


function WT.UnitFrame.EnableResizableTemplate(rootFrame, frameWidth, frameHeight, elList)
	
	rootFrame:EventAttach(Event.UI.Layout.Size, function(self, h)
		local newWidth = rootFrame:GetWidth()
		local newHeight = rootFrame:GetHeight()
	
		local fracWidth = newWidth / frameWidth
		local fracHeight = newHeight / frameHeight
		local fracMin = math.min(fracWidth, fracHeight)
		local fracMax = math.max(fracWidth, fracHeight)

		for idx, el in ipairs(elList) do
			if el.type == "Label" then
				local origFontSize = el.fontSize or 10
				local newFontSize = math.ceil(origFontSize * fracMin)
				if el.id and rootFrame.Elements[el.id] then
					rootFrame.Elements[el.id]:SetFontSize(newFontSize)
				end
			end
		end
	end, "Event.UI.Layout.Size")

	local els = {}
	els["frame"] = { id="frame", left = 0, top = 0, width = frameWidth, height = frameHeight }

	for idx, el in ipairs(elList) do
	
		local curr = {}
		curr.id = el.id
		curr.width = el.width or 0
		curr.height = el.height or 0
		curr.left = 0
		curr.top = 0
		els[el.id] = curr

		if not el.attach then
			error("Template element has no attachments: " .. element.id)
		end
		
		for attIdx, att in ipairs(el.attach) do
			local ptFrom = translatePoint(att.point)
			local ptTo = translatePoint(att.targetPoint)
			local ptElement = att.element or "frame"
			local offX = att.offsetX or 0
			local offY = att.offsetY or 0
			_SetPoint(curr, ptFrom[1], ptFrom[2], els[ptElement], ptTo[1], ptTo[2], offX, offY)
		end
		
		if curr.width > 0 and curr.height > 0 then
			-- write a new attach element, replacing the old one
			el.attach = {}
			el.attach[1] = { point={0,0}, element="frame", targetPoint={ curr.left / els.frame.width, curr.top / els.frame.height } }
			el.attach[2] = { point={1,1}, element="frame", targetPoint={ (curr.left + curr.width) / els.frame.width, (curr.top + curr.height) / els.frame.height } }
			
			el.width = nil
			el.height = nil
		end
		
	end

end
