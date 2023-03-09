_G["dir"] = fs.getDir(shell.getRunningProgram())
_G["getapi"] = function(name)
	os.loadAPI(fs.combine(dir, name .. ".lua"))
	if _G[name .. ".lua"] then _G[name] = _G[name .. ".lua"] end
end

getapi("files")
getapi("renderer")

function getProgramForExtension(extension)
	if not settigns then return "edit" end
	return settings.get("minex.programs." .. extension, settings.get("minex.default_program", "edit"))
end

-- Set default settings
if false and settings and not settings.get("minex.default_program") then
	settings.set("minex.default_program", "edit")
	settings.set("minex.programs.nfp",    "paint")
	settings.save()
end

term.clear()

files.loadAllFiles()
files.files[1].selected = true

renderer.showFiles(files.files)

while true do
	local event, p1, p2, p3 = os.pullEvent()

	if event == "key" then
		local key = p1

		if key == keys.down or key == keys.j then
			local selection = files.getSelectedIndex() 

			if (selection <= #files.files - 1) then
				files.setSelection(selection + 1)
				renderer.updateSelection(selection, selection + 1)
			end

		elseif key == keys.up or key == keys.k then
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

		elseif key == keys.right or key == keys.l then
			files.expand()
			renderer.showFiles()

		elseif key == keys.left or key == keys.h then
			files.collapse()
			renderer.showFiles()

		elseif key == keys.enter then
			local file = files.files[files.getSelectedIndex()]

			if file.type == files.FileType.FILE then
				local ext = files.getFileExtension(file.name)
				shell.run(getProgramForExtension(ext), "/" .. file.path)
				renderer.showFiles()
			else
				term.setBackgroundColor(colors.black)
				term.setCursorPos(1, 1)
				term.clear()
				shell.setDir(file.path)
				return
			end

		end
	elseif event == "mouse_click" then
		local button, x, y = p1, p2, p3
		local oldSelection = files.getSelectedIndex()

		local fileIndex = renderer.getFileIndexFromY(y)
		if files.files[fileIndex] then
			files.setSelection(fileIndex)
			renderer.updateSelection(oldSelection, fileIndex)
		end

	elseif event == "term_resize" then
		renderer.showFiles()
	end
end

