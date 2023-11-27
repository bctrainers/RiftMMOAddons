local Info, Addon = ...

local InspectTimeFrame = Inspect.Time.Frame

Addon.Timer = Addon.class(function(self, settings)
	self.settings = Addon.extend({}, self.settings, settings)
	self.event = function()
		local now = InspectTimeFrame()
		if now >= self.startAt then
			if self.settings.repeating then
				self.startAt = now + self.settings.interval
			else
				self:Stop(i)
			end
			self.settings.callback(unpack(self.settings.arguments))
		end
	end
end)
local Timer = Addon.Timer
Timer.settings = {
	interval = 1,
	delay = 0,
	callback = function()end,
	repeating = false,
	arguments = {},
}
Timer.running = false
Timer.startAt = 0
Timer.event = nil
function Timer:Start()
	if self:IsRunning() then
		return
	end
	self.running = true
	self.startAt = InspectTimeFrame() + self.settings.delay
	Command.Event.Attach(Event.System.Update.Begin, self.event, Info.identifier .. ": Timer")
end
function Timer:Stop(i)
	if not self:IsRunning() then
		return
	end
	self.running = false
	Command.Event.Detach(Event.System.Update.Begin, self.event)
end
function Timer:IsRunning()
	return self.running
end

