import("events")
import("files")
import("renderer")
import("input")

local function clearScreen()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.setCursorPos(1, 1)
	term.clear()
end

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
-- Returns whether to exit
local function doSecondaryAction(file)
	clearScreen()
	if file.type == files.FileType.FILE then
		shell.run("/" .. file.path)
		term.write("Press any key to continue")
		os.pullEvent("key")
		renderer.showEverything()
		return false
	else
		shell.setDir(file.path)
		return true
	end
end

events.addListener("key", events.Focus.FILES, function(key)
	local selection = files.getSelectedIndex()

	if key == keys.down or key == keys.j then
		if not selection then selection = 0 end

		if (selection <= #files.files - 1) then
			files.setSelection(selection + 1)
			renderer.updateSelection(selection, selection + 1)
		end

	elseif key == keys.up or key == keys.k then
		if not selection then selection = #files.files + 1 end

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
		return doSecondaryAction(file)

	-- Rename on F2
	elseif key == keys.f2 then
		if not selection then return end
		local file = files.files[selection]

		input.create({
			text = file.name,
			x = file.depth + 3,
			y = renderer.getYFromFileIndex(selection),
			color = colors.black,
			backgroundColor = colors.white,
			highlightColor = colors.lightGray,
			cancelKey = keys.f2,
			callback = function(newName)
				if #newName == 0 then return true end

				local newPath = fs.combine(fs.getDir(file.path), newName)

				if fs.exists(newPath) or fs.isReadOnly(file.path) then
					return false
				end

				fs.move(file.path, newPath)
				file.name = newName
				file.path = newPath

				renderer.showPath()

				return true
			end
		})
	end

end)

-- Quit when pressing Q
-- This is in key up to prevent typing 'q' in the terminal
events.addListener("key_up", events.Focus.FILES, function(key)
	if key == keys.q then
		clearScreen()
		return true
	end
end)

events.addListener("mouse_click", events.Focus.FILES, function(btn, x, y)
	if btn ~= 1 then return end

	local oldSelection = files.getSelectedIndex()
	local fileIndex = renderer.getFileIndexFromY(y)
	local file = files.files[fileIndex]

	-- Deselect when pressing outside
	if not file then
		files.deselect()
		renderer.showFiles()
		renderer.showPath()
		return
	end

	-- Select if not selected already
	if not file.selected then
		files.setSelection(fileIndex)
		renderer.updateSelection(oldSelection, fileIndex)
		return
	end

	doPrimaryAction(file)
end)

