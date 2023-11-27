--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-09-14T11:00:28Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local dockerIntegration = false

local btnGadget = UI.CreateFrame("Texture", AddonId .. "_btnGadget", WT.Context)
btnGadget:SetTexture(AddonId, "img/btnGadgetMenu.png")

local btnDragging = false
local btnStartX = 0
local btnStartY = 0
local btnMouseStartX = 0
local btnMouseStartY = 0
local btnDragged = false

local function btnDragStart()
	if dockerIntegration then return end
	WT.Utility.DeAnchor(btnGadget)
	local mouse = Inspect.Mouse()
	btnDragging = true
	btnStartX = btnGadget:GetLeft()
	btnStartY = btnGadget:GetTop()
	btnMouseStartX = mouse.x
	btnMouseStartY = mouse.y
	btnDragged = false	
end

local draggedEnough = false
local function btnDragMove()
	if btnDragging then
		local mouse = Inspect.Mouse()

		if not draggedEnough then
			local deltaX = math.abs(mouse.x - btnMouseStartX)
			local deltaY = math.abs(mouse.y - btnMouseStartY)
			if deltaX > 8 or deltaY > 8 then
				draggedEnough = true
			end
		end

		if not draggedEnough then return end

		local x = mouse.x - btnMouseStartX + btnStartX
		local y = mouse.y - btnMouseStartY + btnStartY
		btnGadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
		wtxOptions.btnGadgetX = x
		wtxOptions.btnGadgetY = y
		btnDragged = true	
	end
end

local function btnDragStop()
	btnDragging = false
	draggedEnough = false
	-- try to detect a left click instead of a drag
	if not btnDragged then
		if WT.Gadget.Locked() then
			WT.Gadget.UnlockAll()
		else
			WT.Gadget.LockAll()
		end
	end
end

local menuItems = {}
local menuItemsAdd = 1
local menuItemsToggleLock = 2
local menuItemsSettings = 3
local menuItemsImport = 4
menuItems[menuItemsAdd] = {text=TXT.AddGadget, value=function() WT.Gadget.ShowCreationUI() end } 
menuItems[menuItemsToggleLock] = {text=TXT.UnlockGadgets, value=function() WT.Gadget.ToggleAll() end }
menuItems[menuItemsSettings] = {text=TXT.Settings, value=function() WT.Gadget.ShowSettings() end }
menuItems[menuItemsImport] = {text="Import Layout", value=function() WT.Gadget.ShowImportDialog() end }

local btnMenu = WT.Control.Menu.Create(btnGadget, menuItems)
btnMenu:SetPoint("TOPRIGHT", btnGadget, "CENTER")

-- 2012/10/05 - Start Adelea's change to improve Menu popup location

local btnMenu_Anchor = "TOPRIGHT"

local function btnShowMenu()
	local md = Inspect.Mouse()
	local sx = UIParent:GetWidth()/2
	local sy = UIParent:GetHeight()/2
	local anchor
	
	if md.y > sy then
		anchor = "BOTTOM"
	else
		anchor = "TOP"
	end
	
	if md.x <= sx then
		anchor = anchor.."LEFT"
	else
		anchor = anchor.."RIGHT"
	end
	
	if anchor ~= btnMenu_anchor then
		btnMenu:ClearPoint(btnMenu_Anchor)
		btnMenu_Anchor = anchor
		btnMenu:SetPoint(anchor, btnGadget, "CENTER")
	end
	btnMenu:Toggle()
end

-- 2012/10/05 - End Adelea's change to improve Menu popup location



function btnMenu:OnOpen()
	if dockerIntegration then
		MINIMAPDOCKER.AUTOHIDE_DOCKED = false
	end
end

function btnMenu:OnClose()
	if dockerIntegration then
		MINIMAPDOCKER.AUTOHIDE_DOCKED = true
	end
end


btnGadget:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self, h)
	btnDragStart()
end, "Event.UI.Input.Mouse.Left.Down")
btnGadget:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self, h)
	btnDragMove()
end, "Event.UI.Input.Mouse.Cursor.Move")
btnGadget:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self, h)
	btnDragStop()
end, "Event.UI.Input.Mouse.Left.Up")
btnGadget:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function(self, h)
	btnDragStop()
end, "Event.UI.Input.Mouse.Left.Upoutside")
btnGadget:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
	btnShowMenu()
end, "Event.UI.Input.Mouse.Right.Click")


-- API METHODS

function WT.Gadget.ResetButton()
	WT.Utility.DeAnchor(btnGadget)
	btnGadget:ClearPoint("LEFT")
	btnGadget:ClearPoint("TOP")
	btnGadget:SetPoint("CENTER", UIParent, "CENTER")
	wtxOptions.btnGadgetX = btnGadget:GetLeft()
	wtxOptions.btnGadgetY = btnGadget:GetTop()
end



local function Initialize()

	-- Docker integration
	if MINIMAPDOCKER then
		dockerIntegration = true
		MINIMAPDOCKER.Register("Gadgets", btnGadget)
	else
		dockerIntegration = false
		if (wtxOptions.btnGadgetX and wtxOptions.btnGadgetY) then
			btnGadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", wtxOptions.btnGadgetX, wtxOptions.btnGadgetY)
		else
			btnGadget:SetPoint("CENTER", UIParent, "CENTER")
		end
	end
end


-- Register an initializer to handle loading of gadgets
table.insert(WT.Initializers, Initialize)

Command.Event.Attach(WT.Event.GadgetsLocked, 
	function()
		menuItems[menuItemsToggleLock].text = TXT.UnlockGadgets
		btnMenu:SetItems(menuItems)
	end, 
	AddonId .. "_GadgetsLocked"
)

Command.Event.Attach(WT.Event.GadgetsUnlocked, 
	function()
		menuItems[menuItemsToggleLock].text = TXT.LockGadgets
		btnMenu:SetItems(menuItems)
	end, 
	AddonId .. "_GadgetsUnlocked"
)
