-- This recreates the "old" Raredar_rares array so other addons,
-- like TomTom, which rely on it can still use it. We save a little
-- time by only recreating the current language version.

local i, zone, zoneName, j, mobName
local lang=Inspect.System.Language()

Command.System.Watchdog.Quiet()			-- we do this only once at the start, so dont bother

RareDar_rares={}
RareDar_rares[lang]={}
for i, zone in ipairs(RareDar.data) do 
    zoneName=zone.zone[lang]
    --print ("converting zone ".. zoneName)
    RareDar_rares[lang][zoneName]={}

    for j, mob in ipairs(zone.mobs) do
	-- print ("j="..j)
	if mob.pos[1] ~= nil and mob.achv[lang] ~= nil then			-- dont remember them if we dont know the position
	    mobName = mob.achv[lang]
	    --print ("mob="..mobName)
	    RareDar_rares[lang][zoneName][mobName]=mob.pos[1]
	end
    end
end
