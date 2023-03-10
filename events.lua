local listeners = {}

function addListener(event, callback)
	if not listeners[event] then listeners[event] = {} end
	table.insert(listeners[event], callback)
end

function listen()
	while true do
		local event, p1, p2, p3 = os.pullEvent()

		if listeners[event] then
			for _, callback in ipairs(listeners[event]) do
				callback(p1, p2, p3)
			end
		end
	end
end
