Type = {
	DEFAULT = 0,
	ERROR = 1,
}

-- Button:
-- * text: string
-- * callback: function

-- Status:
-- * text: string
-- * type: Type
-- * buttons: Button[]
local status = nil
local statusTimer = nil
local activeButton = nil

local leftButtons = {
	{ text = "+",   callback = navigation.createFile },
	{ text = "\16", callback = navigation.executeCurrentFile, condition = (function() return files.getSelectedIndex() ~= nil end) },
}

local rightButtons = {
	{ text = "?",    callback = (function() end) },
	{ text = "\215", callback = (function() clearScreen() return true end) },
}

function set(s)
	status = s
	draw()
end

function clearAfter(sec)
	statusTimer = os.startTimer(sec)
end

function error(text)
	status = {
		text = text,
		type = Type.ERROR,
	}

	clearAfter(2)

	draw()
end

local function drawButton(btn, i)
	if activeButton == i then
		term.setBackgroundColor(colors.gray)
	else
		term.setBackgroundColor(colors.lightGray)
	end

	if btn.condition and not btn.condition() then
		term.setTextColor(colors.gray)
	else
		term.setTextColor(colors.black)
	end

	term.write(btn.text)
end

function draw()
	if not status or status.type == Type.DEFAULT then
		term.setTextColor(colors.black)
		term.setBackgroundColor(colors.lightGray)
	elseif status.type == Type.ERROR then
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.red)
	end

	local width, height = term.getSize()
	term.setCursorPos(1, height)

	-- Show default buttons
	if not status then
		term.write(string.rep(" ", width))

		for i, btn in ipairs(leftButtons) do
			term.setCursorPos(i + i - 1, height)

			drawButton(btn, i)
		end

		for i, btn in ipairs(rightButtons) do
			term.setCursorPos(width - (#rightButtons + #rightButtons - 1) + i + i - 1, height)

			drawButton(btn, #leftButtons + i)
		end

		return
	end

	term.write(status.text)
	term.write(string.rep(" ", math.max(0, width - #status.text)))
end

local function getButtonIndexFromX(x)
	local width, _ = term.getSize()

	if not status then
		local leftIndex = (1 + x) / 2
		if leftButtons[leftIndex] then
			return leftIndex
		end

		local rightIndex = (#rightButtons + 1) - (2 + width - x) / 2
		if rightButtons[rightIndex] then
			return #leftButtons + rightIndex
		end
	end
end

local function getButtons()
	if not status then
		local buttons = {}

		for i, btn in ipairs(leftButtons)  do table.insert(buttons, btn) end
		for i, btn in ipairs(rightButtons) do table.insert(buttons, btn) end

		return buttons
	end
end

local function activeButtonCanBeClicked()
	if not activeButton then return false end

	local btn = getButtons()[activeButton]

	return not btn.condition or btn.condition()
end

events.addListener("timer", nil, function(timer)
	if timer == statusTimer then
		status = nil
		draw()
	end
end)

events.addListener("mouse_click", events.Focus.FILES, function(btn, x, y)
	local _, height = term.getSize()

	if btn ~= 1 or y ~= height then return end

	activeButton = getButtonIndexFromX(x)
	if not activeButtonCanBeClicked() then
		activeButton = nil
		return
	end

	if activeButton then
		draw()
	else
		files.deselect()
		renderer.showPath()
		renderer.showFiles()
	end
end)

events.addListener("mouse_up", events.Focus.FILES, function(btn, x, y)
	local width, height = term.getSize()

	if btn ~= 1 then return end

	if y ~= height then
		local oldActive = activeButton
		activeButton = nil
		if oldActive ~= nil then draw() end

		return
	end

	local btnIndex = getButtonIndexFromX(x)

	if btnIndex ~= nil and btnIndex == activeButton and activeButtonCanBeClicked() then
		activeButton = nil
		draw()

		return getButtons()[btnIndex].callback()
	end
end)

