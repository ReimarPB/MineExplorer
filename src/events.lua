local listeners = {}
local currentFocus = nil;

Focus = {
	FILES = 0,
	INPUT = 1,
}

function addListener(event, focus, callback)
	if not listeners[event] then listeners[event] = {} end
	table.insert(listeners[event], {
		focus = focus,
		callback = callback,
	})
end

function listen()
	while true do
		local event, p1, p2, p3 = os.pullEvent()

		if listeners[event] then
			for _, listener in ipairs(listeners[event]) do
				if listener.focus == currentFocus then
					if listener.callback(p1, p2, p3) then return end -- Exit when callback returns true
					if currentFocus ~= listener.focus then break end -- Break out if focus changed
				end
			end
		end
	end
end

function setFocus(focus)
	currentFocus = focus
end

function isFocused(focus)
	return currentFocus == focus
end

