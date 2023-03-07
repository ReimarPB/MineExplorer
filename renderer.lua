function showFiles(files)
	for i, file in ipairs(files) do
		showFile(files, i)
	end
end

function showFile(files, index)
	local file = files[index]

	term.setBackgroundColor(colors.white)
	term.setCursorPos(1, index)

	-- Icon
	local color
	if file.isDir then
		color = colors.yellow
	else
		color = colors.lightGray
	end

	term.setTextColor(colors.white)
	term.setBackgroundColor(color)
	term.write("\151")
	term.setTextColor(color)
	term.setBackgroundColor(colors.white)
	term.write("\148")

	-- Name
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	term.write(file.name)

	-- Whitespace
	local x, _  = term.getCursorPos()
	local width, _ = term.getSize()
	term.write(string.rep(" ", width - x))
end

