--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-03-11T20:37:35Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier

--[[

--]]


local animatedFrames = {}
local runningAnimations = {}

local function fnAnimate(frame, animation, value)
	if value and (not animation.running) then
		animation.running = true
		animation.startTime = Inspect.Time.Frame()
		animation.iteration = 1
		animation.onStart(frame.Elements)
		runningAnimations[animation] = true
	end
	if (not value) and animation.running then
		animation.onFinish(frame.Elements)
		animation.running = false
		runningAnimations[animation] = nil
	end
end


function WT.UnitFrame.EnableAnimation(rootFrame, animList)
	
	for idx, anim in ipairs(animList) do
	
		local animation = {}
		animation.frame = rootFrame
		animation.trigger = tostring(anim.trigger)
		animation.duration = tonumber(anim.duration)
		animation.loopCount = tonumber(anim.loopCount)
		animation.onStart = anim.onStart
		animation.onTick = anim.onTick
		animation.onFinish = anim.onFinish

		if not animation.trigger then error("Missing trigger on animation") end
		if not animation.duration then error("Missing duration on animation") end
		if not animation.loopCount then error("Missing loopCount on animation") end
		if not animation.onStart then error("Missing onStart on animation") end
		if not animation.onTick then error("Missing onTick on animation") end
		if not animation.onFinish then error("Missing onFinish on animation") end
		if type(animation.onStart) ~= "function" then error("onStart is not a function on animation") end
		if type(animation.onTick) ~= "function" then error("onTick is not a function on animation") end
		if type(animation.onFinish) ~= "function" then error("onFinish is not a function on animation") end
		
		table.insert(rootFrame.Animations, animation)	
			
		rootFrame:CreateBinding(animation.trigger, rootFrame, function(frm, val) fnAnimate(frm, animation, val) end, nil, nil) 
		
	end

	table.insert(animatedFrames, rootFrame) 

end

local function OnTick(hEvent)
	for animation, _ in pairs(runningAnimations) do
		local elapsed = Inspect.Time.Frame() - animation.startTime
		while elapsed > animation.duration do
			elapsed = elapsed - animation.duration
			animation.startTime = animation.startTime + animation.duration
			animation.iteration = animation.iteration + 1
			if animation.loopCount > 0 and animation.iteration > animation.loopCount then
				fnAnimate(animation.frame, animation, nil)
			end
		end
		local progress = elapsed / animation.duration
		animation.onTick(animation.frame.Elements, elapsed, elapsed / animation.duration) 
	end 
end

Command.Event.Attach(Event.System.Update.Begin, OnTick, "AnimationTick")
