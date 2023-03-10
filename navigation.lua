import("events")
import("files")
import("renderer")

local function getProgramForExtension(extension)
	if not settigns then return "edit" end
	return settings.get("minex.programs." .. extension, settings.get("minex.default_program", "edit"))
end

-- Edit files, expand/collapse folders
local function doPrimaryAction(file)
	if file.type == files.FileType.FILE then
		local ext = files.getFileExtension(file.name)
		shell.run(getProgramForExtension(ext), "/" .. file.path)
		renderer.showEverything()
	else
		if file.expanded then files.collapse()
		else files.expand() end
		renderer.showFiles()
	end
end

-- Execute files, switch to folders and quit
local function doSecondaryAction(file)
	if file.type == files.FileType.FILE then
		shell.run("/" .. file.path)
	else
		term.setBackgroundColor(colors.black)
		term.setCursorPos(1, 1)
		term.clear()
		shell.setDir(file.path)
	end
end

events.addListener("key", function(key)
	local selection = files.getSelectedIndex()

	if key == keys.down or key == keys.j then
		if (selection <= #files.files - 1) then
			files.setSelection(selection + 1)
			renderer.updateSelection(selection, selection + 1)
		end

	elseif key == keys.up or key == keys.k then
		if (selection > 1) then
			files.setSelection(selection - 1)
			renderer.updateSelection(selection, selection - 1)
		end

	elseif key == keys.home then
		files.setSelection(1)
		renderer.updateSelection(selection, 1)

	elseif key == keys["end"] then
		files.setSelection(#files.files)
		renderer.updateSelection(selection, #files.files)

	elseif key == keys.right or key == keys.l then
		files.expand()
		renderer.showFiles()

	elseif key == keys.left or key == keys.h then
		files.collapse()
		renderer.showFiles()

	elseif key == keys.space then
		if not selection then return end

		local file = files.files[selection]
		doPrimaryAction(file)

	elseif key == keys.enter then
		if not selection then return end

		local file = files.files[selection]
		doSecondaryAction(file)

		return true
	end

end)

events.addListener("mouse_click", function(btn, x, y)
	if btn ~= 1 then return end

	local oldSelection = files.getSelectedIndex()
	local fileIndex = renderer.getFileIndexFromY(y)
	local file = files.files[fileIndex]

	if not file then
		files.deselect()
		renderer.showFiles()
		renderer.showPath()
		return
	end

	if not file.selected then
		files.setSelection(fileIndex)
		renderer.updateSelection(oldSelection, fileIndex)
		return
	end

	doPrimaryAction(file)
end)

