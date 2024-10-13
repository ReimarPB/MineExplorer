local function getProgramForExtension(extension)
	if not settings then return "edit" end
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

function executeCurrentFile()
	local index = files.getSelectedIndex()
	if index == nil then return end

	local file = files.files[index]
	return doSecondaryAction(file)
end

local function editFileName(index, file, cancelKey, finishCallback, cancelCallback)
	input.create({
		text = file.name,
		x = file.depth + 3,
		y = renderer.getYFromFileIndex(index),
		color = colors.black,
		backgroundColor = colors.white,
		highlightColor = colors.lightGray,
		cancelKey = cancelKey,
		callback = function(newName)
			if #newName == 0 then
				cancelCallback()
				return
			end

			local newPath = fs.combine(fs.getDir(file.path), newName)

			if fs.exists(newPath) then
				status.error("File name is already in use")
				cancelCallback()
				return
			end

			finishCallback(newName)

			renderer.showPath()

			return
		end
	})
end

function createFile()
	local index = files.getCurrentFolderIndex()
	local newIndex, newDepth, newPath

	if index ~= nil and index > 0 and fs.isReadOnly(files.files[index].path) then
		status.error("Can't create files in read-only folder")
		return
	end

	if index == nil or index == 0 then
		newIndex = #files.files + 1
		newDepth = 1
		newPath = "/"
	else
		newIndex = index + files.getAmountOfFilesInFolder(index)
		newDepth = files.files[index].depth + 1
		newPath = files.files[index].path
	end

	local file = {
		name = "",
		path = newPath,
		type = files.FileType.FILE,
		readonly = false,
		depth = newDepth,
		selected = true,
		expanded = false,
	}
	table.insert(files.files, newIndex, file)

	files.setSelection(newIndex)
	renderer.scrollTo(newIndex)
	renderer.showFiles()

	editFileName(newIndex, file, keys.insert,
		function(newName)
			local path = fs.combine(newPath, newName)

			fs.open(path, "w").close()

			files.files[newIndex].name = newName
			files.files[newIndex].path = path
		end,
		function()
			table.remove(files.files, newIndex)

			files.setSelection(index)
			renderer.showFiles()
		end
	)
end

local function editPath(pos)
	events.setFocus(events.Focus.INPUT)

	local index = files.getSelectedIndex()
	if index then renderer.showFile(files.getSelectedIndex()) end

	input.create({
		text = files.getCurrentPath(),
		x = 1,
		y = 1,
		cursorPos = pos,
		color = colors.black,
		backgroundColor = colors.lightGray,
		highlightColor = colors.lightGray,
		cancelKey = keys.f6,
		autocomplete = true,
		callback = function(newPath)
			if #newPath == 0 then
				renderer.showPath()
				return
			end

			if not fs.exists(newPath) then
				renderer.showPath()
				status.error("Path doesn't exist")
				return false
			end

			local index = files.selectFromPath(newPath)
			if index == nil then
				renderer.showPath()
				return false
			end

			files.setSelection(index)
			renderer.updateSelection(selection, index)

			renderer.showFiles()
			renderer.showPath()

			return true
		end
	})
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

	elseif key == keys.pageUp then
		if not selection then selection = #files.files + 1 end

		local _, height = term.getSize()
		local newSelection = math.max(1, selection - height + 2)

		files.setSelection(newSelection)
		renderer.updateSelection(selection, newSelection)

	elseif key == keys.pageDown then
		if not selection then selection = 0 end

		local _, height = term.getSize()
		local newSelection = math.min(#files.files, selection + height - 2)

		files.setSelection(newSelection)
		renderer.updateSelection(selection, newSelection)

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

	elseif key == keys.f6 then
		editPath(nil)

	-- Refresh current folder
	elseif key == keys.f5 then
		local index = files.getCurrentFolderIndex()

		if not index then
			files.loadAllFiles()
			renderer.showFiles()

			return
		end

		if not files.files[index].expanded then return end

		files.collapse()
		files.expand()

		renderer.showFiles()

	-- Rename on F2
	elseif key == keys.f2 then
		if not selection then return end
		local file = files.files[selection]

		if fs.isReadOnly(files.getCurrentPath()) then
			status.error("File is read-only")
			return
		end

		editFileName(selection, file, keys.f2,
			function(newName)
				local newPath = fs.combine(fs.getDir(file.path), newName)

				fs.move(file.path, newPath)
				file.name = newName
				file.path = newPath
			end,
			function() end
		)

	elseif key == keys.insert then
		createFile()
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

	if y == 1 then
		editPath(x)
		return
	end

	local _, height = term.getSize()
	if y == height then return end

	local oldSelection = files.getSelectedIndex()
	local fileIndex = renderer.getFileIndexFromY(y)
	local file = files.files[fileIndex]

	-- Deselect when pressing outside
	if not file then
		files.deselect()
		renderer.showEverything()
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

