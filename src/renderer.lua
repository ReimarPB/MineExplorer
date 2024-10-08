import("files")
import("events")

local scrollY = 0
local CONTENT_OFFSET_Y = 1

function showPath()
	local path = files.getCurrentPath()

	term.setCursorPos(1, 1)
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.black)
	term.write(path)

	-- Fill remaining space
	local width, _ = term.getSize()
	term.write(string.rep(" ", width - #path + 1))
end

function showFiles()
	for i, file in ipairs(files.files) do
		showFile(i)
	end

	-- Fill remaining space
	local width, height = term.getSize()
	if #files < height then
		term.setBackgroundColor(colors.white)
		for i = #files.files + 1 + CONTENT_OFFSET_Y, height do
			term.setCursorPos(1, i)
			term.write(string.rep(" ", width))
		end
	end
end

function showFile(index)
	local width, height = term.getSize()
	local y = index - scrollY + CONTENT_OFFSET_Y

	if y < 1 + CONTENT_OFFSET_Y or y > height then return end

	local file = files.files[index]

	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.setCursorPos(1, y)

	term.write(string.rep(" ", file.depth - 1))

	-- Arrow + Icon
	local color1, color2
	if file.type ~= files.FileType.FILE then
		if file.expanded then
			term.write("\025")
		else
			term.write("\026")
		end

		if file.readonly then
			color1 = colors.orange
			color2 = colors.orange
		elseif file.type == files.FileType.DIRECTORY then
			color1 = colors.yellow
			color2 = colors.yellow
		else
			color1 = colors.gray
			color2 = colors.gray
		end
	else
		term.write(" ")
		color1 = colors.lightGray
		color2 = colors.lightGray
	end

	if file.name:match("%.lua$") then
		color2 = colors.blue
	end

	term.setTextColor(color1)
	term.write("\138")
	term.setTextColor(color2)
	term.write("\133")

	-- Name
	if file.selected and events.isFocused(events.Focus.FILES) then
		term.setBackgroundColor(colors.lightBlue)
	elseif file.selected then
		term.setBackgroundColor(colors.lightGray)
	else
		term.setBackgroundColor(colors.white)
	end

	if not file.selected and file.name:find("^%.") then
		term.setTextColor(colors.lightGray)
	else
		term.setTextColor(colors.black)
	end
	term.write(file.name)

	-- Fill remaining space
	local x, _ = term.getCursorPos()
	term.setBackgroundColor(colors.white)
	term.write(string.rep(" ", width - x + 1))
end

function showEverything()
	showPath()
	showFiles()
end

-- Returns whether it actually scrolled
local function scrollTo(index)
	local _, height = term.getSize()
	height = height - CONTENT_OFFSET_Y

	if index <= scrollY + 1 then
		scrollY = index - 1
		return true
	end

	if index > scrollY + height - 1 then
		scrollY = index - height
		return true
	end

	return false
end

-- Scrolls to new selection if necessary and draws changes
function updateSelection(oldIndex, newIndex)
	if scrollTo(newIndex) then
		showFiles()
	else
		if oldIndex and files.files[oldIndex] then showFile(oldIndex) end
		showFile(newIndex)
	end
	showPath()
end

function getFileIndexFromY(y)
	return y + scrollY - CONTENT_OFFSET_Y
end

function getYFromFileIndex(index)
	return index - scrollY + CONTENT_OFFSET_Y
end

function drawInput(input, cursorPos)
	local width, _ = term.getSize()

	term.setCursorPos(input.x, input.y)
	term.setTextColor(input.color)

	term.setBackgroundColor(input.highlightColor)
	term.write(input.text)

	local completion = ""
	if input.autocomplete and fs.complete then
		local completions = fs.complete(input.text, "/")

		if #completions > 0 then
			completion = completions[1]

			term.setTextColor(colors.gray)
			term.write(completion)
		end
	end

	term.setTextColor(input.color)
	term.setBackgroundColor(input.backgroundColor)
	term.write(string.rep(" ", width - input.x - #input.text - #completion))

	term.setCursorBlink(true)
	term.setCursorPos(input.x + cursorPos - 1, input.y)
end

events.addListener("term_resize", events.Focus.FILES, function()
	showEverything()
end)

events.addListener("mouse_scroll", events.Focus.FILES, function(direction)
	local width, height = term.getSize()
	local newScrollY = scrollY + direction

	if newScrollY < 0 or newScrollY > #files.files - height + 1 then return end

	scrollY = newScrollY

	showFiles()
end)

