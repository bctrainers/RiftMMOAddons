--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-01-04T22:17:01Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


WT.Gadget.Command = {}

local TXT = Library.Translate

function WT.Gadget.Command.add()
	if WT.Gadget.isSecure then
		print(TXT.CannotAlterGadgetsInCombat)
		return
	end
	WT.Gadget.ShowCreationUI()
end

function WT.Gadget.Command.copy(gadgetId)
	WT.Gadget.Copy(gadgetId)
end

function WT.Gadget.Command.import(charId)
	if wtxLayouts[charId] then
		local def = Utility.Serialize.Inline(wtxLayouts[charId])
		wtxGadgets = loadstring("return " .. def)()
		print("You must type /reloadui now")
	else
		print("Layout not found: " .. charId)
	end
end

function WT.Gadget.Command.list()
	for gadgetId,config in pairs(wtxGadgets) do
		print(string.format("Gadget: %s (%s)", gadgetId, config.type)) 
	end
end

function WT.Gadget.Command.delete(gadgetId)
	WT.Gadget.Delete(gadgetId)
end


function WT.Gadget.Command.modify(gadgetId)
	WT.Gadget.Modify(gadgetId)
end


function WT.Gadget.Command.reset()
	WT.Gadget.ResetButton()
end


function WT.Gadget.Command.unlock()
	WT.Gadget.UnlockAll()
end

function WT.Gadget.Command.lock()
	WT.Gadget.LockAll()
end

function WT.Gadget.Command.toggle()
	WT.Gadget.ToggleAll()
end

function WT.Gadget.Command.grid(gridSize)
	local gs = tonumber(gridSize) or 1
	if (gs < 1) then gs = 1 end	
	WT.Gadget.GridSize = gs
	Command.Console.Display("general", true, "Gadgets grid snapping set to " .. gs .. " pixels", false)
end

function WT.Gadget.GetGridSize()
	if WT.Gadget.GridSize and WT.Gadget.GridSize >= 1 then
		return WT.Gadget.GridSize
	else
		return 1
	end
end

function WT.Gadget.Command.setproperty(gadgetId, propertyId, value)
	local gadget = WT.Gadgets[gadgetId]
	if not gadget then
		Command.Console.Display("general", true, "Unknown gadget: " .. gadgetId, false)
	end
	local err, errMsg = pcall(
		function()
			WT.Gadget.SetProperty(gadgetId, propertyId, value)
		end)
	if not err then
		Command.Console.Display("general", true, "SetProperty failed: " .. errMsg, false)
	end
end

function WT.Gadget.OnSlashCommand(cmd)
	local words = {}
	for word in string.gmatch(cmd, "[^%s]+") do table.insert(words, word) end
	local numWords = table.getn(words)
	if numWords > 0 then
		local command = string.lower(words[1])
		local args = {}
		for i = 2, numWords do table.insert(args, words[i]) end
		WT.Log.Debug("Command received: " .. command .. " with " .. table.getn(args) .. " args")
		if WT.Gadget.Command[command] then
			WT.Gadget.Command[command](unpack(args))
		end
	end
end

table.insert(Command.Slash.Register("gadget"), { WT.Gadget.OnSlashCommand, AddonId, AddonId .. "_OnSlashCommand1" })
table.insert(Command.Slash.Register("gadgets"), { WT.Gadget.OnSlashCommand, AddonId, AddonId .. "_OnSlashCommand2" })

