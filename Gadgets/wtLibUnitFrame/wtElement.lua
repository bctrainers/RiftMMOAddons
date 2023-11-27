--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Element
	
		Provides a basic implementation for Elements. All Element classes should be subclasses of
		this.

--]]


WT.Element = {}
WT.Element.Count = 0

function WT.Element.MetaIndex(table, name)
	if table._baseFrame[name] then return table._baseFrame[name] end 
	if table._class[name] then return table._class[name] end
	return nil 
end
WT.Element_mt = { __index = WT.Element.MetaIndex }

function WT.Element:Subclass(elementTypeName, baseFrameType)
	local obj = {}
	obj.ElementType = elementTypeName
	obj.BaseFrameType = baseFrameType or "Frame"
	setmetatable(obj, { __index = self })
	WT.ElementFactories[elementTypeName] = obj
	WT.Log.Debug("Registered element factory: " .. elementTypeName) 
	return obj
end


local function stringToPoints(str)
	if str == "TOPLEFT" then return 0,0 end 
	if str == "TOP" then return nil,0 end 
	if str == "TOPRIGHT" then return 1,0 end 
	if str == "BOTTOMLEFT" then return 0,1 end 
	if str == "BOTTOM" then return nil,1 end 
	if str == "BOTTOMRIGHT" then return 1,1 end 
	if str == "CENTERLEFT" then return 0,0.5 end 
	if str == "CENTER" then return 0.5,0.5 end 
	if str == "CENTERRIGHT" then return 1,0.5 end 
	if str == "CENTERX" then return 0.5,nil end 
	if str == "CENTERY" then return nil,0.5 end
	if str == "LEFT" then return 0,nil end 
	if str == "RIGHT" then return 1,nil end
	if str == "TOPCENTER" then return 0.5,0 end 
	if str == "BOTTOMCENTER" then return 0.5,1 end 
	return "ERROR:" .. str
end


function WT.Element:Create(unitFrame, configuration, overrideParent)

	local element = UI.CreateFrame(self.BaseFrameType, WT.UniqueName("WT_ELEM", configuration.id), overrideParent or unitFrame)
	element._class = self
	element._baseFrame = getmetatable(element).__index 
	element.UnitFrame = unitFrame
	element.Configuration = configuration
	setmetatable(element, WT.Element_mt)
	
	-- Validate configuration
	local valid = true
	if self.ConfigDefinition then
		for k,v in pairs(self.ConfigDefinition.required) do
			if (v == "required") and (not config[k]) then
				WT.Log.Error(self.ElementType .. " missing required configuration item: " .. tostring(k))
				valid = false
			end
		end
	end
	
	if not valid then return nil end
	
	if configuration.layer then
		element:SetLayer(configuration.layer)
	end

	if configuration.alpha then
		element:SetAlpha(configuration.alpha)
	end
	
	if configuration.visibilityBinding then
		unitFrame:CreateBinding(configuration.visibilityBinding, element, element.SetVisible, false, WT.Utility.ToBoolean)
	end
	
	-- string valued parents need to be handled at unit frame level where the parent can actually be found
	if configuration.parent and (type(configuration.parent) == "string") then
		local parentElement = unitFrame.Elements[configuration.parent]
		if parentElement then
			element:SetParent(parentElement)
		end
	end
		
	-- allow for direct allocation of the parent frame, rather than by name
	if configuration.parent and (type(configuration.parent) == "table") then
		element:SetParent(configuration.parent)
	end
	
	-- wrap this in a pcall, as it's easy to get this wrong in a template
	if not pcall(
		function() 
			if configuration.attach then
				for idx, attachTo in ipairs(configuration.attach) do
					local attachToElement = attachTo.element
					if type(attachToElement) == "string" then
						attachToElement = unitFrame.Elements[attachToElement]
					end
					
					if attachToElement then
						local attachPoint = attachTo.point or "TOPLEFT"
						local attachTargetPoint = attachTo.targetPoint or "TOPLEFT"
						local attachOffsetX = attachTo.offsetX
						local attachOffsetY = attachTo.offsetY
						
						local apX, apY, tpX, tpY = 0, 0, 0, 0
						
						if type(attachPoint) == "string" then 
							apX, apY = stringToPoints(attachPoint)
						else
							apX, apY = attachPoint[1], attachPoint[2]   
						end
						
						if type(attachTargetPoint) == "string" then 
							tpX, tpY = stringToPoints(attachTargetPoint) 
						else
							tpX, tpY = attachTargetPoint[1], attachTargetPoint[2]   
						end
						
						if attachOffsetX and attachOffsetY then
							element:SetPoint(apX, apY, attachToElement, tpX, tpY, attachOffsetX, attachOffsetY)
						elseif attachOffsetX and not attachOffsetY then
							element:SetPoint(apX, apY, attachToElement, tpX, tpY, attachOffsetX, nil)
						elseif not attachOffsetX and attachOffsetY then
							element:SetPoint(apX, apY, attachToElement, tpX, tpY, nil, attachOffsetY)
						else
							element:SetPoint(apX, apY, attachToElement, tpX, tpY)
						end
					else
						WT.Log.Error("Could not find attachTo element: " .. tostring(attachTo.element))
					end
				end	
			end
		end
	) 
	then 
		WT.Log.Warning("Incorrect attachment options in element " .. configuration.id) 
	end
	
	-- All standard configuration has been handled, now call the construct method for the specific instance
	element:Construct()
	return element
	
end
