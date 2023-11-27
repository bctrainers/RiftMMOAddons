local addon, shared = ...
local id = addon.identifier
_GCDDisplay = {}
local GCD = _GCDDisplay
local GCD_ACTIVE = false
local prev_width = 0
local cur_vis = true
local GCDStart = nil
local GCDTime = 1
local GCDAbility = nil
local default_settings = {
	show=true, x=0, y=0, w=300, h=3, bg=true, cast=true, locked=false, numeric=false, red = 1, green = 0, blue = 0
}

local function MergeTable(o,n)
	for k,v in pairs(n) do
		if type(v) == "table" then
			if o[k] == nil then
				o[k] = {}
			end
	 	 	if type(o[k]) == 'table' then
	 			MergeTable(o[k], n[k])
	 	 	end
		else
			if o[k] == nil then
				o[k] = v
			end
		end
	end
end

function GCD.BuildUI()

	GCD.context = UI.CreateContext(id)
	GCD.frame = UI.CreateFrame("Frame", "GCD.frame", GCD.context)
	GCD.frame:SetWidth(default_settings.w+1)
	GCD.frame:SetHeight(default_settings.h+2)
	GCD.frame:SetLayer(0)
	GCD.frame:SetBackgroundColor(0,0,0,0)
	GCD.frame:SetPoint("CENTER", UIParent, "CENTER", 0,0)
	local x = GCD.frame:GetLeft()
	local y = GCD.frame:GetTop()
	GCD.spark = UI.CreateFrame("Frame", "GCD.spark", GCD.frame)
	GCD.spark:SetWidth(0)
	GCD.spark:SetHeight(default_settings.h)
	GCD.spark:SetLayer(1)
	GCD.spark:SetBackgroundColor(default_settings.red,default_settings.green,default_settings.blue,1)
	GCD.spark:SetPoint("TOPLEFT", GCD.frame, "TOPLEFT", 1,1)

	GCD.number = UI.CreateFrame("Text", "GCD.number", GCD.spark)
	GCD.number:SetFont(id,"font\\ArmWrestler.ttf")
	GCD.number:SetFontSize(10)
	GCD.number:SetPoint("CENTERRIGHT", GCD.frame, "CENTERLEFT", 0,0)
	GCD.number:SetLayer(1)
	GCD.number:SetFontColor(1,1,1,1)
	GCD.frame:ClearPoint("CENTER")
	GCD.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x,y)

	GCD.frame:EventAttach(Event.UI.Input.Mouse.Right.Down, function(self, h)
		if GCD_Settings.locked == false then
			self.MouseDown = true
			local md = Inspect.Mouse()
			self.sx = md.x - GCD.frame:GetLeft()
			self.sy = md.y - GCD.frame:GetTop()
		end
	end, "Event.UI.Input.Mouse.Right.Down")

	GCD.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self, h)
		if self.MouseDown then
			local nx, ny
			local md = Inspect.Mouse()
			ny = md.y - self.sy
			nx = md.x - self.sx
			GCD.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nx,ny)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")

	GCD.frame:EventAttach(Event.UI.Input.Mouse.Right.Up, function(self, h)
		self.MouseDown = false
		GCD_Settings.x = GCD.frame:GetLeft()
		GCD_Settings.y = GCD.frame:GetTop()
	end, "Event.UI.Input.Mouse.Right.Up")
end
function GCD.RemoveVisibility() 
	GCD_ACTIVE = false
	prev_width = 0
	GCD.spark:SetWidth(prev_width)
	GCD.frame:SetVisible(GCD_Settings.show)
	if GCD_Settings.numeric then
		GCD.number:SetVisible(false)
		GCD.number:SetText("")
	end
end
function GCD.Event_System_Update_Begin(h)
	if GCD_ACTIVE then
		local candisplay = true
		local show = true
		if GCD_Settings.cast == false then
			local cb= Inspect.Unit.Castbar("player")
			if cb ~= nil then
				candisplay = false
				GCD.RemoveVisibility()
			end
		end
		if candisplay then 
			local w = 0
			local RemainingTime = (Inspect.Time.Frame() - GCDStart);
			local GCDRemaining = 0
			if RemainingTime < GCDTime then
				GCDRemaining = (GCDTime-RemainingTime)
				w = math.floor(GCD_Settings.w*(GCDRemaining/GCDTime))
			end
			if w == 0 then
				show = GCD_Settings.show
				GCD.frame:SetVisible(show)
				if GCD_Settings.numeric then
					GCD.number:SetVisible(false)
					GCD.number:SetText("")
				end
				GCD.spark:SetWidth(w)
				GCD_ACTIVE = false
			else		
				GCD.frame:SetVisible(show)
				if prev_width ~= w then
					prev_width = w
					GCD.spark:SetWidth(w)
				end
				if GCD_Settings.numeric then
					GCD.number:SetVisible(true)
					--GCD.number:SetText(string.format("%.2fs", GCDRemaining))
					GCD.number:SetText(string.sub(GCDRemaining,0,3).."s")
				end
			end
			if cur_vis ~= show then
				cur_vis = show
				GCD.frame:SetVisible(show)
				if show == false then
					GCD.spark:SetWidth(0)
				end
				if GCD_Settings.numeric then
					GCD.number:SetVisible(show)
				end
			end
		end
	end
end

function GCD.ShowUsage()
	print("Usage:")
	print("/gcd lock - toggles whether the bar can be moved or is fixed in place")
	print("/gcd show - toggles between always visible, or only visible when active")
	print("/gcd info - shows summary of current settings")
	print("/gcd cdreset - resets the current GCD monitor")
	print("/gcd bg - toggles display of the black background bar")
	print("/gcd cast - toggles visibility when casting")
	print("/gcd number - toggles display of numeric timer")
	print("/gcd w XXX - sets width to XXX (>=50 and < screen width)")
	print("/gcd h XXX - sets height to XXX (>=1 and < 100)")
	print("/gcd color R G B - changes the spark bar color)")
end

function GCD.Command_Slash_Register(h,args)
	local r = {}
	local numargs = 0
	for token in string.gmatch(args, "[^%s]+") do
		numargs=numargs+1
		r[numargs] = token
	end
	local showusage = true
	if numargs>0 then
		if r[1] == "show" then
			GCD_Settings.show = not GCD_Settings.show
			if GCD_Settings.show then
				print("VISIBLE: Always")
			else
				print("VISIBLE: When Active")
			end
			GCD.frame:SetVisible(GCD_Settings.show)
			showusage = false
		elseif r[1] == "cast" then
			GCD_Settings.cast = not GCD_Settings.cast
			if GCD_Settings.cast then
				print("VISIBLE: When casting")
			else
				print("VISIBLE: When not casting")
			end
			showusage = false
		elseif r[1] == "bg" then
			GCD_Settings.bg = not GCD_Settings.bg
			if GCD_Settings.bg then
				print("BACKGROUND BAR: Visible")
				GCD.frame:SetBackgroundColor(0,0,0,0.75)
			else
				print("BACKGROUND BAR: Hidden")
				GCD.frame:SetBackgroundColor(0,0,0,0)
			end
			showusage = false
		elseif r[1] == "w" then
			if numargs > 1 then
				local w = tonumber(r[2])
				if w == nil or w < 50 or w > UIParent:GetWidth() then
					print(string.format("'%s' is not a valid width value", r[2]))
				else
					w = math.floor(w)
					GCD_Settings.w = w
					GCD.frame:SetWidth(w+1)
					showusage = false
				end
			end
		elseif r[1] == "h" then
			if numargs > 1 then
				local h = tonumber(r[2])
				if h == nil or h < 1 or h>100 then
					print(string.format("'%s' is not a valid width value", r[2]))
				else
					h = math.floor(h)
					GCD_Settings.h = h
					GCD.frame:SetHeight(h+2)
					GCD.spark:SetHeight(h)
					showusage = false
				end
			end
		elseif r[1] == "lock" then
			GCD_Settings.locked = not GCD_Settings.locked
			print(string.format("LOCKED: %s", tostring(GCD_Settings.locked)))
			showusage = false
		elseif r[1] == "color" then
			showusage = false
			if numargs > 1 and numargs < 5 then
				showusage = false
				local red = tonumber(r[2])
				local green = tonumber(r[3])
				local blue = tonumber(r[4])
				if red == nil or red < 0 or red > 255 then
					print(string.format("'%s' is not a valid color value", red))
					return
				end
				if green == nil or green < 0 or green > 255 then
					print(string.format("'%s' is not a valid color value", green))
					return
				end
				if blue == nil or blue < 0 or blue > 255 then
					print(string.format("'%s' is not a valid color value", blue))
					return
				end
				GCD_Settings.red = red/255
				GCD_Settings.green = green/255
				GCD_Settings.blue = blue/255
				GCD.spark:SetBackgroundColor(GCD_Settings.red,GCD_Settings.green,GCD_Settings.blue,1)
				print("GCD Spark color changed!")
				return
			end
		elseif r[1] == "info" then
			print("CURRENT SETTINGS:")
			if GCD_Settings.show then
				print("VISIBLE: Always")
			else
				print("VISIBLE: When Active")
			end
			if GCD_Settings.cast then
				print("VISIBLE: When casting")
			else
				print("VISIBLE: When not casting")
			end
			if GCD_Settings.bg then
				print("BACKGROUND BAR: Visible")
			else
				print("BACKGROUND BAR: Hidden")
			end
			print(string.format("SHOW TIMER: %s", tostring(GCD_Settings.numeric)))
			print(string.format("LOCKED: %s", tostring(GCD_Settings.locked)))
			print(string.format("SCREEN POSITION: %d, %d", GCD_Settings.x, GCD_Settings.y))
			print(string.format("BAR SIZE: %d x %d", GCD_Settings.w, GCD_Settings.h))
			showusage = false
		elseif r[1] == "number" then
			GCD_Settings.numeric = not GCD_Settings.numeric
			print(string.format("SHOW TIMER: %s", tostring(GCD_Settings.numeric)))
			--GCD.number:SetVisible(GCD_Settings.numeric)
			showusage = false
		end
	end
	if showusage then
		GCD.ShowUsage()
	end
end

function GCD.Event_Addon_SavedVariables_Load_End(h,a)
	if a == addon.identifier then
		if GCD_Settings == nil then
			GCD_Settings = {}
			GCD_Settings.x = GCD.frame:GetLeft()
			GCD_Settings.y = GCD.frame:GetTop()
		end
		MergeTable(GCD_Settings, default_settings)
		GCD.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", GCD_Settings.x, GCD_Settings.y)
		if GCD_Settings.bg then
			GCD.frame:SetBackgroundColor(0,0,0,0.75)
		else
			GCD.frame:SetBackgroundColor(0,0,0,0)
		end
		GCD.frame:SetVisible(GCD_Settings.show)
		GCD.frame:SetHeight(GCD_Settings.h+2)
		GCD.spark:SetHeight(GCD_Settings.h)
		GCD.frame:SetWidth(GCD_Settings.w+1)
		GCD.spark:SetBackgroundColor(GCD_Settings.red,GCD_Settings.green,GCD_Settings.blue,1)
	end
end

function GCD.Event_Ability_New_Cooldown_Begin(h,t)
	for k,v in pairs(t) do
		if v > 0.9 and v < 1.51 then
			GCD_ACTIVE = true
			GCDStart = Inspect.Time.Frame();
			GCDTime = v
			GCDAbility = k
			break;
		end
	end
end
function GCD.Event_Ability_New_Cooldown_End(h,t)
	if GCD_ACTIVE then
		for k,v in pairs(t) do
			if k == GCDAbility then
				GCD.RemoveVisibility()
				break;
			end
		end
	end
end
GCD.BuildUI()
Command.Event.Attach(Event.System.Update.Begin, GCD.Event_System_Update_Begin, "Event.System.Update.Begin")
Command.Event.Attach(Command.Slash.Register("gcd"), GCD.Command_Slash_Register, "Command.Slash.Register")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, GCD.Event_Addon_SavedVariables_Load_End, "Event.Addon.SavedVariables.Load.End")
Command.Event.Attach(Event.Ability.New.Cooldown.Begin, GCD.Event_Ability_New_Cooldown_Begin, "Event.Ability.New.Cooldown.Begin")
Command.Event.Attach(Event.Ability.New.Cooldown.End, GCD.Event_Ability_New_Cooldown_End, "Event.Ability.New.Cooldown.End")
print(string.format("v%s loaded.", addon.toc.Version))