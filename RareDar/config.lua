--------------------------------------------------------------------------------
-- Configuration variables which define notification position and appearance.
-- Warning: The RareDarConfig variables won't get set if a save file exists!
--------------------------------------------------------------------------------
RareDar = RareDar or {}
RareDarGlobal = RareDarGlobal or {}
RareDarConfig = RareDarConfig or {}

RareDarConfig.show = RareDarConfig.show or true

RareDarConfig.xpos = RareDarConfig.xpos or 100
RareDarConfig.ypos = RareDarConfig.ypos or 100

-- Positioning
RareDarConfig.horizontal_padding = RareDarConfig.horizontal_padding or 60
RareDarConfig.horizontal_offset = RareDarConfig.horizontal_offset or 60

-- Color
RareDarConfig.red = RareDarConfig.red or 0.2
RareDarConfig.green = RareDarConfig.green or 0.2
RareDarConfig.blue = RareDarConfig.blue or 0.2
RareDarConfig.alpha = RareDarConfig.alpha or 0.5

-- Fading constants
RareDarConfig.display_time = RareDarConfig.display_time or 10.0
RareDarConfig.fade_time = RareDarConfig.fade_time or 3.5

-- Lock window position
RareDarConfig.locked = RareDarConfig.locked or false

-- Share information with others
RareDarConfig.informFriends = true
RareDarConfig.informGuild   = true
RareDarConfig.informWorld   = false
RareDarConfig.showNeeded    = true
RareDarConfig.showKilled    = false

RareDarConfig.shownOnce     = false

-- Make sure our experiments won't bother players
RareDar.queryIndex=nil
RareDar.querysource=nil
RareDar.nextMobSend=0
