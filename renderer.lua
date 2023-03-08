os.loadAPI(fs.combine(dir, "files.lua"))

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
	if file.type ~= files.FileType.FILE then
		if file.expanded then
			term.write("\025")
		else
			term.write("\026")
		end

		if file.type == files.FileType.DIRECTORY then
			term.setTextColor(colors.yellow)
		else
			term.setTextColor(colors.gray)
		end
	else
		term.write(" ")
		term.setTextColor(colors.lightGray)
	end
	term.write("\138\133")

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

function scrollTo(index)
	local width, height = term.getSize()

	if index <= 0 - scrollY then
		scrollY = -index + 1
		showFiles()
	elseif index > height - scrollY then
		scrollY = height - index
		showFiles()
	end

end

