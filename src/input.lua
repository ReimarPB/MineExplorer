import("renderer")

-- Input
-- * text
-- * x
-- * y
-- * cursorPos
-- * color
-- * backgroundColor
-- * highlightColor
-- * cancelKey
-- * autocomplete
-- * callback
local currentInput = nil
local cursorPos = nil

function create(input)
	currentInput = input
	cursorPos = math.min(input.cursorPos or math.huge, #currentInput.text + 1)
	events.setFocus(events.Focus.INPUT)
	renderer.drawInput(currentInput, cursorPos)
end

local function endInput(result)
	currentInput.callback(result)

	currentInput = nil
	events.setFocus(events.Focus.FILES)
	renderer.showFiles()
end

events.addListener("char", events.Focus.INPUT, function(char)
	currentInput.text = string.sub(currentInput.text, 1, cursorPos - 1) .. char .. string.sub(currentInput.text, cursorPos)
	cursorPos = cursorPos + 1
	renderer.drawInput(currentInput, cursorPos)
end)

events.addListener("key", events.Focus.INPUT, function(key)

	if key == keys.right then
		cursorPos = math.min(cursorPos + 1, #currentInput.text + 1)
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys.left then
		cursorPos = math.max(cursorPos - 1, 1)
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys.home then
		cursorPos = 1
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys["end"] then
		cursorPos = #currentInput.text + 1
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys.backspace then
		if cursorPos == 1 then return end
		currentInput.text = string.sub(currentInput.text, 1, cursorPos - 2) .. string.sub(currentInput.text, cursorPos)
		cursorPos = cursorPos - 1
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys.tab and currentInput.autocomplete and fs.complete then
		local completions = fs.complete(currentInput.text, "/")
		if #completions > 0 then
			currentInput.text = currentInput.text .. completions[1]
			cursorPos = #currentInput.text + 1
			renderer.drawInput(currentInput, cursorPos)
		end

	elseif key == keys.delete then
		if cursorPos == #currentInput.text + 1 then return end
		currentInput.text = string.sub(currentInput.text, 1, cursorPos - 1) .. string.sub(currentInput.text, cursorPos + 1)
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys.enter then
		endInput(currentInput.text)

	elseif key == currentInput.cancelKey then
		endInput("")
	end
end)

events.addListener("mouse_click", events.Focus.INPUT, function(btn, x, y)
	if btn ~= 1 then return end

	if y ~= currentInput.y then
		endInput("")
		return
	end

	local newCursorPos = math.min(x - currentInput.x + 1, #currentInput.text + 1)

	if newCursorPos < 1 then
		endInput("")
		return
	end

	cursorPos = newCursorPos
	renderer.drawInput(currentInput, cursorPos)
end)
