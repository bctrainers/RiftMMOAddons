local RareDarAddonData, PrivateTable = ...


--------------------------------------------------------------------------------
-- Mapping of event handlers to event types.
--------------------------------------------------------------------------------

-- Notification display

local job_coroutine = nil

local function run_job()
   -- Set yield time 10 milli sec from now
   RareDar.next_yield = Inspect.Time.Real() + 0.01

   RareDar.fade_notification()
   RareDar.SetCloseMobs()
end

function RareDar.ignoreme()
end

local updating = false
local function update()

	-- prevent being called over and over in case of errors
	if updating then return end
	updating=true

	run_job()
	
-- experimental [[
	if RareDar.queryIndex ~= nil
	and RareDar.querySource ~= nil
	and RareDar.nextMobSend < Inspect.Time.Real()
	and RareDarGlobal.mobList ~= nil
	and RareDar.queryIndex <= #RareDarGlobal.mobList then
		Command.Message.Send(RareDar.querySource, "RareDar", 
			"moblist content " .. RareDar.queryIndex .. " " .. RareDarGlobal.mobList[RareDar.queryIndex], RareDar.ignoreme)
		RareDar.queryIndex=RareDar.queryIndex + 1
		RareDar.nextMobSend = Inspect.Time.Real()+0.1
	end
	if RareDar.queryIndex ~= nil
	and RareDarGlobal.mobList ~= nil
	and RareDar.queryIndex > #RareDarGlobal.mobList then
		Command.Message.Send(RareDar.querySource, "RareDar", "moblist end", RareDar.ignoreme)
		RareDar.queryIndex = nil
	end
--]]
	updating=false
end


local raremobachvs={
   "c5C766AF68015CB70",	-- old named mobs
   "c5057BAEBDEA774CE", -- ember isle 20 mob achievment
   "c128FB25EE807902B", -- storm legion
   "c7443CBB86FC99D5E",	-- Brine Buster
   "c67C744D530A8EC9B",	-- The Hidden Forest
   "c35BB4DD687461439",	-- Take Only Lives, Leave Only Corpses
   "c14A33E10DAD5EC40",	-- Foci on the Big Picture
   "c3F734803456F6934", -- A Deranged Obsession
   "c5C49C11CB05C8F3E",	-- I'll See You in Ashenfell
}

local function updateachv(achv)
    local y=Inspect.Achievement.Detail(achv)
    local lang=Inspect.System.Language()
	
	if y~=nil then
		for req,data in pairs(y.requirement) do
			local name=data.name
			for zone, info in pairs(RareDar_rares[lang]) do
				if (info[name]) then
					info[name][6]=(data.complete or false)
				end
			end
			-- end of old compatibility stuff

			for i, zone in ipairs(RareDar.data) do
				for j, mob in ipairs(zone.mobs) do
					if (mob.achv[lang] == name) then
						mob.killed=(data.complete or false)
					end
				end
			end
		end
	end
end

-- Initialization
local function init(addon)
	if (addon == "RareDar") then
		Command.System.Watchdog.Quiet()	-- dont bother during init

		print(RareDarAddonData.toc.Version .. " loaded!  We'll do our best to let you know when we find a rare mob!")
		print("Visit http://riftrares.gbl-software.de for current location data.")
		print("Type /raredar for options.")

		RareDar.createUI()
		RareDar.CreateConfigUI()

		-- Normally, we get Command.Achievement.Update events after we're initialized.
		-- However, this might not happen after a /reloadui, so we just to the same
		-- stuff again here.

		local id,achv
		for id,achv in ipairs(raremobachvs) do
			updateachv(achv)
		end

		Command.Message.Accept(nil, "RareDar")
		LibVersionCheck.register("RareDar", RareDarAddonData.toc.Version)

		if not RareDarConfig.shownOnce then
			RareDarConfig.shownOnce = true
			RareDar.ShowConfigUI()
		end
	end
end

local function gotachv(tab)
   local id, b, i, achvid

   for id,b in pairs(tab) do
      for i, achvid in ipairs(raremobachvs) do
	 if id == achvid then
	    updateachv(id)
	 end
      end
   end
end

local function enterSecure()
   RareDar.secureMode = true
end

local function leaveSecure()
   RareDar.secureMode = false
end


-- This is purely experimental and not supposed to be usable yet.

local function receive(from, type, channel, identifier, data)
	if identifier ~= "RareDar" then return end
	if (data == "query") then
		Command.Message.Send(from, identifier, "version "..RareDarAddonData.toc.Version, RareDar.ignoreme)
		RareDar.nextMobSend=Inspect.Time.Real() + 0.1
		RareDar.querySource=from
		RareDar.queryIndex=1
		Command.Message.Send(from, identifier, "moblist start", RareDar.ignoreme)
	end
	
	if data:len()>8 and data:sub(1, 8) == "mobfound" then
		local token
		local tnum=1
		local parms={}
		for token in string.gmatch(data, "[^%s]+") do
			parms[tnum]=token
			tnum=tnum+1
		end
		local mobName=data:sub(parms[1]:len()+parms[2]:len()+parms[3]:len()+4)
		RareDar.foundRare(mobName, parms[2], parms[3])
	end
end

local function help()
	print("Usage: /raredar [option]:")
	print("	show:	show the main window.")
	print("	hide:		hide the main window.")
	print("	lock:		lock the main window position.")
	print("	unlock:	unlock the main window position.")
	print("	config:	open the configuration window.")
end

local function process(param)
    if (param ~= nil) and (param ~= "") then

        if param == "help" then
            help()
        elseif param == "hide" then
            RareDar.hideMiniWindow()
	elseif param == "show" then
            RareDar.showMiniWindow()
        elseif param == "lock" then
            RareDarConfig.locked = true
	elseif param == "unlock" then
            RareDarConfig.locked = false
	elseif param == "debug" then
            dump(RareDarAddonData)
	elseif param=="config" then
	    RareDar.ShowConfigUI()
        else
            print("Unknown option [" .. param .."] type /raredar help for valid options")
        end
    else
	help()
    end
end;

table.insert(Event.System.Update.Begin, {update, "RareDar", "Fade & Close mobs"})
table.insert(Event.Achievement.Update, { gotachv, "RareDar", "gotachv" })
table.insert(Event.Addon.Load.End, {init, "RareDar", "Initialization"})
table.insert(Event.System.Secure.Enter, { enterSecure, "RareDar", "EnterSecure" })
table.insert(Event.System.Secure.Leave, { leaveSecure, "RareDar", "LeaveSecure" })
table.insert(Event.Unit.Availability.Full, { RareDar.find_rares_in_units, "RareDar", "Display Notification"})
table.insert(Command.Slash.Register("raredar"), { process, "RareDar", "Slash command"})
table.insert(Event.Message.Receive, { receive, "RareDar", "receive" })
