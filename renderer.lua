import("files")
import("events")

local scrollY = 0

function showFiles()
	for i, file in ipairs(files.files) do
		showFile(i)
	end

	-- Fill remaining space
	local width, height = term.getSize()
	if #files < height then
		term.setBackgroundColor(colors.white)
		for i = #files.files + 1, height do
			term.setCursorPos(1, i)
			term.write(string.rep(" ", width))
		end
	end
end

function showFile(index)
	local width, height = term.getSize()
	local y = index + scrollY

	if y < 1 or y > height then return end

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
	if file.selected then
		term.setBackgroundColor(colors.lightBlue)
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

-- Returns whether it actually scrolled
local function scrollTo(index)
	local width, height = term.getSize()

	if index <= 0 - scrollY then
		scrollY = -index + 1
		return true
	end

	if index > height - scrollY then
		scrollY = height - index
		return true
	end

	return false
end

-- Scrolls to new selection if necessary and draws changes
function updateSelection(oldIndex, newIndex)
	if scrollTo(newIndex) then
		showFiles()
	else
		showFile(oldIndex)
		showFile(newIndex)
	end
end

function getFileIndexFromY(y)
	return y - scrollY
end

events.addListener("term_resize", function()
	showAllFiles()
end)

