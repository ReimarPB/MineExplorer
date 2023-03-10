import("events")
import("files")
import("renderer")

events.addListener("key", function(key)

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

end)

events.addListener("mouse_click", function(btn, x, y)
	if btn ~= 1 then return end

	local oldSelection = files.getSelectedIndex()

	local fileIndex = renderer.getFileIndexFromY(y)
	if files.files[fileIndex] then
		files.setSelection(fileIndex)
		renderer.updateSelection(oldSelection, fileIndex)
	end
end)
