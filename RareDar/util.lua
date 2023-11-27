local AddonData, private = ...

--------------------------------------------------------------------------------
-- Utility and debugging related functions.
--------------------------------------------------------------------------------

local lastTimeSeen = {}

function RareDar.get_rares(units)
    local rares = {}
    local lang = Inspect.System.Language()
    local player = Inspect.Unit.Detail("player");
    if (player.zone) then
        local zone=Inspect.Zone.Detail(player.zone)
        local zonename = zone.name
	for k,v in pairs(units) do
	    if k ~= nil and type(k) == "string" then
	        local detail = Inspect.Unit.Detail(k)
	        if (detail["guaranteedLoot"]) then
	            local now=Inspect.Time.Server()
	            if lastTimeSeen[detail.name] == nil
	            or lastTimeSeen[detail.name] < now - 5*60 then
			RareDarGlobal.mobList = RareDarGlobal.mobList or {}
			table.insert(RareDarGlobal.mobList,
				""  .. lang .. 
				";" .. zonename ..
				";" .. detail.name ..
				";" .. detail.coordX ..
				";" .. detail.coordZ .. 
				";" .. detail.coordY ..
				";" .. now
			);
		    end
		    lastTimeSeen[detail.name] = now
		    table.insert(rares, detail.name )
	        end
	    end
	end
    end
    return rares
end
