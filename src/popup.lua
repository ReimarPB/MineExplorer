-- Popup
-- * type
-- * lines
-- * onsubmit
local currentPopup = nil
local focusedButton = nil
local buttonAmount = nil

local POPUP_PADDING_X = 4
local POPUP_PADDING_Y = 2

function create(popup)
	currentPopup = popup
	focusedButton = 1

	buttonAmount = 0
	for _, line in ipairs(popup.lines) do
		if line.type == "button" then
			buttonAmount = buttonAmount + 1
			if line.focus then focusedButton = buttonAmount end
		end
	end

	events.setFocus(events.Focus.POPUP)
	renderer.showFiles()
	drawPopup(currentPopup)
end

local function submit(popup, button)
	local btnIdx = 0
	for _, line in ipairs(popup.lines) do
		if line.type == "button" then btnIdx = btnIdx + 1 end
		if btnIdx == button then
			popup.onsubmit(line.text)
			break
		end
	end

	currentPopup = nil
	events.setFocus(events.Focus.FILES)
	renderer.showEverything()
end

local function getLineLength(line)
	if line.type == "text" or line.type == "button" then return #line.text end
	if line.type == "spacer" then return 0 end
end

local function getLineX(line)
	local width, _ = term.getSize()
	return math.floor(width / 2 - getLineLength(line) / 2)
end

local function getPopupWidth(popup)
	local popupWidth = 0
	for _, line in ipairs(popup.lines) do
		local len = getLineLength(line)
		if len > popupWidth then popupWidth = len end
	end
	return popupWidth + POPUP_PADDING_X
end

local function getPopupHeight(popup)
	return #popup.lines + POPUP_PADDING_Y
end

local function getPopupOffsetX(popupWidth)
	local width, _ = term.getSize()
	return math.floor(width / 2 - popupWidth / 2)
end

local function getPopupOffsetY(popupHeight)
	local _, height = term.getSize()
	return math.floor(height / 2 - popupHeight / 2)
end

local function getButtonIndexFromLine(popup, line)
	local i = 0
	for _, l in ipairs(popup.lines) do
		if l.type == "button" then i = i + 1 end
		if l == line then return i end
	end
	return nil
end

local function getButtonFromCoords(popup, x, y)
	local popupWidth = getPopupWidth(popup)
	local popupHeight = getPopupHeight(popup)

	local lineIdx = y - getPopupOffsetY(popupHeight)
	local line = popup.lines[lineIdx]

	if not line or line.type ~= "button" then return nil end

	local lineX = getLineX(line)
	if x < lineX - 1 or x > lineX + getLineLength(line) then return nil end

	return getButtonIndexFromLine(popup, line)
end

function drawPopup(popup)
	local width, height = term.getSize()
	local color = popup.type == "danger" and colors.red or colors.blue

	local popupWidth = getPopupWidth(popup)
	local popupHeight = getPopupHeight(popup)

	local x = getPopupOffsetX(popupWidth)
	local y = getPopupOffsetY(popupHeight)

	term.setCursorPos(x, y)
	term.setTextColor(color)
	term.setBackgroundColor(colors.white)
	term.write("\151" .. string.rep("\131", popupWidth - 2))
	term.setTextColor(colors.white)
	term.setBackgroundColor(color)
	term.write("\148")

	local btnIdx = 0
	for i, line in ipairs(popup.lines) do
		term.setCursorPos(x, y + i)

		term.setTextColor(color)
		term.setBackgroundColor(colors.white)
		term.write("\149" .. string.rep(" ", popupWidth - 2))
		term.setTextColor(colors.white)
		term.setBackgroundColor(color)
		term.write("\149")
		term.setTextColor(colors.gray)
		term.setBackgroundColor(colors.white)
		term.write("\127")

		local lineX = getLineX(line)
		if line.type == "text" then
			term.setCursorPos(lineX, y + i)
			term.setTextColor(colors.black)
			term.write(line.text)
		elseif line.type == "button" then
			btnIdx = btnIdx + 1
			local focusColor = line.buttonType == "danger" and colors.pink or colors.lightBlue

			term.setCursorPos(lineX - 1, y + i)
			if btnIdx == focusedButton then
				term.setTextColor(colors.black)
				term.setBackgroundColor(focusColor)
			else
				term.setTextColor(colors.gray)
			end
			term.write(" " .. line.text .. " ")
		end
	end

	term.setCursorPos(x, y + popupHeight - 1)
	term.setTextColor(colors.white)
	term.setBackgroundColor(color)
	term.write("\138" .. string.rep("\143", popupWidth - 2) .. "\133")
	term.setTextColor(colors.gray)
	term.setBackgroundColor(colors.white)
	term.write("\127")

	term.setCursorPos(x + 1, y + popupHeight)
	term.setTextColor(colors.gray)
	term.setBackgroundColor(colors.white)
	term.write(string.rep("\127", popupWidth))
end

events.addListener("key", events.Focus.POPUP, function(key)
	if key == keys.down or key == keys.j then
		if not focusedButton then focusedButton = 1
		else focusedButton = focusedButton + 1 end

		if focusedButton > buttonAmount then focusedButton = 1 end

		drawPopup(currentPopup)

	elseif key == keys.up or key == keys.k then
		if not focusedButton then focusedButton = buttonAmount
		else focusedButton = focusedButton - 1 end

		if focusedButton == 0 then focusedButton = buttonAmount end

		drawPopup(currentPopup)

	elseif key == keys.enter or key == keys.space then
		submit(currentPopup, focusedButton)
	end
end)

events.addListener("mouse_click", events.Focus.POPUP, function(btn, x, y)
	if btn ~= 1 then return end

	focusedButton = getButtonFromCoords(currentPopup, x, y)

	drawPopup(currentPopup)
end)

events.addListener("mouse_up", events.Focus.POPUP, function(btn, x, y)
	if btn ~= 1 then return end
	
	local btnIdx = getButtonFromCoords(currentPopup, x, y)
	if btnIdx and btnIdx == focusedButton then submit(currentPopup, focusedButton) end
end)

