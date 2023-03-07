function showFiles(files)
	for i, file in ipairs(files) do
		term.setCursorPos(1, i)
		term.write(file.name)
	end
end

