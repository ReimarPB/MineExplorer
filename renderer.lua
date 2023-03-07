function showFiles(files)
	for i, file in ipairs(files) do
		showFile(files, i)
	end
end

function showFile(files, index)
	local file = files[index]

	local bgcolor
	if file.selected then
		bgcolor = colors.lightBlue
	else
		bgcolor = colors.white
	end

	term.setBackgroundColor(bgcolor)
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
	term.setTextColor(colors.black)
	term.write(file.name)

	-- Whitespace
	local x, _  = term.getCursorPos()
	local width, _ = term.getSize()
	term.write(string.rep(" ", width - x))
end

