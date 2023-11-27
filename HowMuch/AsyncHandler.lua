-- There is no copyright on this code

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
-- associated documentation files (the "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is furnished to do so.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
-- NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--
-- Global variables
--
local addon, HowMuch = ...
HowMuch.AsyncHandler = {}
HowMuch.AsyncHandler.handlers = {}
HowMuch.AsyncHandler.handlerCount = 0

function HowMuch.AsyncHandler.StopHandler(handler)
	if handler ~= nil then
		Command.Event.Detach(Event.System.Update.Begin, handler.wrapperFn, "HowMuch." .. handler.name)
		HowMuch.AsyncHandler.handlers[handler.name] = nil
		if handler.stopFn ~= nil then
			HowMuch.AsyncHandler.OneOffCallback(function() handler.stopFn(handler.stateTable) end)
		end
	end
end

local function AsyncHandlerFunction(handler)
	if handler.handlerFn(handler.stateTable) ~= true then
		HowMuch.AsyncHandler.StopHandler(handler)
	end
end

function HowMuch.AsyncHandler.StartHandler(name, handlerFn, stateTable, stopFn)
	HowMuch.AsyncHandler.handlerCount = HowMuch.AsyncHandler.handlerCount + 1
	
	local handler = {}
	handler.stateTable = stateTable
	handler.name = name .. HowMuch.AsyncHandler.handlerCount
	handler.handlerFn = handlerFn
	handler.stopFn = stopFn
	handler.wrapperFn = function() AsyncHandlerFunction(handler) end
	HowMuch.AsyncHandler.handlers[handler.name] = handler
	Command.Event.Attach(Event.System.Update.Begin, handler.wrapperFn, "HowMuch." .. handler.name)
	return handler
end

local function OneOffHandler()
	local handler = HowMuch.AsyncHandler.oneOffHandler
	if handler ~= nil then
		local handlerFn = table.remove(handler, 1)
		if handlerFn ~= nil then
			handlerFn()
		else
			handler = nil
		end
	end
		
	if handler == nil then
		Command.Event.Detach(Event.System.Update.Begin, OneOffHandler, "HowMuch_OneOffHandler")
		HowMuch.AsyncHandler.oneOffHandler = nil
	end
end

function HowMuch.AsyncHandler.OneOffCallback(handlerFn)
	local handler = HowMuch.AsyncHandler.oneOffHandler
	if handler == nil then
		handler = {}
		HowMuch.AsyncHandler.oneOffHandler = handler
		Command.Event.Attach(Event.System.Update.Begin, OneOffHandler, "HowMuch_OneOffHandler")
	end
	
	table.insert(handler, handlerFn)
end


