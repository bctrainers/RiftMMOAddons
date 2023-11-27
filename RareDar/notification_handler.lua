--------------------------------------------------------------------------------
-- A single state variable and functions for controlling notification display.
--------------------------------------------------------------------------------

local bar = nil
local lastShownRare = nil

--- Displays a notification if a rare is found in a list of units.
--
-- @param list The units "the client can see"
function RareDar.find_rares_in_units(units)
   rares = RareDar.get_rares(units)
   if table.getn(rares) > 0 then
      local rareName=rares[1]
      local lang=Inspect.System.Language()
      local player=Inspect.Unit.Detail("player")
      RareDar.informOthers(rareName, player.name, lang)
      RareDar.foundRare(rareName, nil, lang)
   end
end

function RareDar.informOthers(rareName, player, lang)
	local message="mobfound "..player.." "..lang.." "..rareName

	if RareDarConfig.informGuild then
		Command.Message.Broadcast("guild", nil, "RareDar", message)
	end

	if RareDarConfig.informWorld then
		Command.Message.Broadcast("channel", "RareDar", "RareDar", message)
	end

	if RareDarConfig.informFriends then
		local friends=Inspect.Social.Friend.List()
		for k, v in pairs(friends) do
			if v and v=="online" then
				Command.Message.Send(k, "RareDar", message, RareDar.ignoreme)
			end
		end
	end
end

function RareDar.foundRare(rareName, playerName, lang)
	local killed=nil
	for i, zone in ipairs(RareDar.data) do
		for j, mob in ipairs(zone.mobs) do
			-- print ("name="..rareName..", mobname="..mob.targ[lang])
			if rareName == mob.targ[lang] then
				killed=mob.killed
			end
		end
	end

	-- suppress "found" messages from other players
	if playerName then
		if not killed and not RareDarConfig.showNeeded
		or     killed and not RareDarConfig.showKilled
		then
			return
		end
	end

	if (rareName ~= lastShownRare) then
		lastShownRare=rareName
		local message = rareName .. " found"
		if playerName then
			message=message.." by "..playerName
		end
		if (killed) then
			message=message.." (already killed)"
		end
		print(message)
		RareDar.show_notification(message, killed, playerName)
	end
end

function RareDar.show_notification(message, killflag, playerName)
   -- Hide the currently displayed notification.
   if bar ~= nil then
      bar:SetVisible(false)
   end

   local red=0.5
   local green=0.5
   local blue=0.5
   
   if killflag==true then
	red=0.2
	green=0.8
	blue=0.2
   end
   
   if killflag==false then
       red=0.8
       green=0.2
       blue=0.2
   end
   
   if playerName then blue=blue+0.4 end

   -- Display the new notification.
   bar = RareDar.display_notification(message,
			      RareDarConfig.horizontal_padding, RareDarConfig.horizontal_offset,
			      red, green, blue, RareDarConfig.alpha)
end

--- Fades a notification out.
--
-- Closes on display_time and fade_time defined in config.lua.
--
-- @param display_time The total duration in seconds to display the notification.
-- @param fade_time The time spent to fade out the notification.
--
-- Examples
--
--   fade_notification with display_time = 10.0 and fade_time = 3.0
--   => When the notification is displayed it will be displayed for a total of 10 total seconds beginning fading out after 7 seconds and completely faded out after 10 seconds.
function RareDar.fade_notification()
   if bar ~= nil then
      dt = Inspect.Time.Real() - bar.time
      if dt > RareDarConfig.display_time then
         bar:SetVisible(false)
	 lastShownRare=nil
      elseif RareDarConfig.display_time-dt < RareDarConfig.fade_time then
	 local normalized_dt
	 local new_alpha
         normalized_dt = RareDarConfig.fade_time - (RareDarConfig.display_time - dt)
         new_alpha = RareDarConfig.alpha-((normalized_dt/RareDarConfig.fade_time)*RareDarConfig.alpha)
         bar:SetAlpha(new_alpha)
      end
   end
end
