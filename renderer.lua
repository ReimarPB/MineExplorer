function showFiles(files)
	for i, file in ipairs(files) do
		showFile(files, i)
	end

	-- Fill remaining space
	local width, height = term.getSize()
	if #files < height then
		term.setBackgroundColor(colors.white)
		for i = #files + 1, height do
			term.setCursorPos(1, i)
			term.write(string.rep(" ", width))
		end
	end
end

function showFile(files, index)
	local file = files[index]

	local bgcolor

	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.setCursorPos(1, index)

	-- Arrow + Icon
	if file.isDir then
		term.write("\026")
		term.setTextColor(colors.yellow)
	else
		term.write(" ")
		term.setTextColor(colors.lightGray)
	end

	term.write("\138")
	term.write("\133")

	-- Name
	if file.selected then
		term.setBackgroundColor(colors.lightBlue)
	else
		term.setBackgroundColor(colors.white)
	end
	term.setTextColor(colors.black)
	term.write(file.name)

	-- Fill remaining space
	local x, _ = term.getCursorPos()
	local width, _ = term.getSize()
	term.setBackgroundColor(colors.white)
	term.write(string.rep(" ", width - x + 1))
end

