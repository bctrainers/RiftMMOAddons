function MinionSender.Inventory.ActionOperateDimension()
	local items = Inspect.Item.Detail(Utility.Item.Slot.Inventory())
	local container

	if items ~= nil then
		for k, v in pairs(items) do
			local category = " " .. (v.category or "") .. " "

			if string.find(category, " dimension ") ~= nil then
				local isContainer = MinionSender.Data.Inventory.DimensionContainer[v.type] or false
				local isKey = string.find(category, " key ") ~= nil

				if MinionSenderConfig["destroyDimension" .. (v.rarity or "common")] and Inspect.Queue.Status("global") and
				   (not isKey or MinionSenderConfig.destroyDimensionKey) and 
				   (not isContainer or MinionSenderConfig.destroyDimensionContainer) then
					pcall(Command.Item.Destroy, v.id)
					return true
				end

				if isContainer and MinionSenderConfig.openDimensionContainer then
					container = v.id
				end
			end
		end
	end

	if container then
		pcall(Command.Item.Standard.Right, container)
		return true
	end
end

function MinionSender.Inventory.ActionDropUnstable()
	local items = Inspect.Item.Detail(Utility.Item.Slot.Inventory())
	local container

	if items ~= nil then
		for k, v in pairs(items) do
			if MinionSender.Data.Inventory.UnstableContainer[v.type] then
				pcall(Command.Item.Destroy, v.id)
				return true
			end
		end
	end
end