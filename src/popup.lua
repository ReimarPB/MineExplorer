import("events")

-- Popup
-- * type
-- * lines
-- * onclick
local currentPopup = nil
local focusedButton = nil
local buttonAmount = nil

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

function getLineLength(line)
	if line.type == "text" or line.type == "button" then return #line.text end
	if line.type == "spacer" then return 0 end
end

function drawPopup(popup)
	local width, height = term.getSize()
	local color = popup.type == "danger" and colors.red or colors.blue

	local popupHeight = #popup.lines + 2
	local popupWidth = 0
	for _, line in ipairs(popup.lines) do
		local len = getLineLength(line)
		if len > popupWidth then popupWidth = len end
	end
	popupWidth = popupWidth + 4

	local x = math.floor(width / 2 - popupWidth / 2)
	local y = math.floor(height / 2 - popupHeight / 2)

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

		local lineX = math.floor(width / 2 - getLineLength(line) / 2)
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
		focusedButton = focusedButton + 1 % buttonAmount
		drawPopup(currentPopup)
	elseif key == keys.up or key == keys.k then
		focusedButton = focusedButton - 1
		if focusedButton == 0 then focusedButton = buttonAmount end
		drawPopup(currentPopup)
	end
end)

