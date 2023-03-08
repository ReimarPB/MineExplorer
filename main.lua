_G["dir"] = fs.getDir(shell.getRunningProgram())

os.loadAPI(fs.combine(dir, "files.lua"))
os.loadAPI(fs.combine(dir, "renderer.lua"))

term.clear()

files.loadAllFiles()
files.files[1].selected = true

renderer.showFiles(files.files)

while true do
	local event, p1, p2, p3 = os.pullEvent()

	if event == "key" then
		local key = p1

		if key == keys.down then
			local selection = files.getSelectedIndex() 

			if (selection <= #files.files - 1) then
				files.setSelection(selection + 1)
				renderer.updateSelection(selection, selection + 1)
			end

		elseif key == keys.up then
			local selection = files.getSelectedIndex()

			if (selection > 1) then
				files.setSelection(selection - 1)
				renderer.updateSelection(selection, selection - 1)
			end

		elseif key == keys.home then
			local oldSelection = files.getSelectedIndex()

			files.setSelection(1)
			renderer.updateSelection(oldSelection, 1)

		elseif key == keys["end"] then
			local oldSelection = files.getSelectedIndex()

			files.setSelection(#files.files)
			renderer.updateSelection(oldSelection, #files.files)

		elseif key == keys.right then
			files.expand()
			renderer.showFiles()
		elseif key == keys.left then
			files.collapse()
			renderer.showFiles()
		end
	elseif event == "term_resize" then
		renderer.showFiles()
	end
end

