import("renderer")

-- Input
-- * text
-- * x
-- * y
-- * color
-- * backgroundColor
-- * highlightColor
-- * cancelKey
-- * callback
local currentInput = nil
local cursorPos = nil

function create(input)
	currentInput = input
	cursorPos = #currentInput.text + 1
	events.setFocus(events.Focus.INPUT)
	renderer.drawInput(currentInput, cursorPos)
end

local function endInput()
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

	elseif key == keys.delete then
		if cursorPos == #currentInput.text + 1 then return end
		currentInput.text = string.sub(currentInput.text, 1, cursorPos - 1) .. string.sub(currentInput.text, cursorPos + 1)
		renderer.drawInput(currentInput, cursorPos)

	elseif key == keys.enter then
		currentInput.callback(currentInput.text)
		endInput()

	elseif key == currentInput.cancelKey then
		endInput()
	end
end)

