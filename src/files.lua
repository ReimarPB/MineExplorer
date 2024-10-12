FileType = {
	FILE = 0,
	DIRECTORY = 1,
	DISK = 2
}

-- File:
-- * name: string
-- * path: string
-- * type: FileType
-- * readonly: bool
-- * depth: int
-- * selected: bool
-- * expanded: bool
files = {}

local function loadFiles(path, depth, index)
	-- Get new files
	local newFiles = {}
	for _, file in ipairs(fs.list(path)) do
		local filePath = fs.combine(path, file)
		local type

		if filePath == file and fs.getDrive(filePath) ~= "hdd" then type = FileType.DISK
		elseif fs.isDir(filePath) then type = FileType.DIRECTORY
		else type = FileType.FILE end

		table.insert(newFiles, {
			name = file,
			path = filePath,
			type = type,
			readonly = fs.isReadOnly(filePath),
			depth = depth + 1,
			selected = false,
			expanded = false,
		})
	end

	-- Sort by file type
	table.sort(newFiles, function(a, b)
		if a.type ~= b.type then
			return a.type > b.type
		end
		return a.name < b.name
	end)

	-- Add to files array
	for i, file in ipairs(newFiles) do
		table.insert(files, index + i, file)
	end
end

function loadAllFiles()
	-- Reset file list if there are any
	if #files > 0 then
		for i, _ in pairs(files) do
			files[i] = nil
		end
	end

	loadFiles("/", 0, 0)
end

function getSelectedIndex()
	for i, file in ipairs(files) do
		if file.selected then return i end
	end
	return nil
end

function setSelection(index)
	for i, file in ipairs(files) do
		file.selected = i == index
	end
end

function deselect()
	for _, file in ipairs(files) do
		file.selected = false
	end
end

function expand()
	local index = getSelectedIndex()
	local file = files[index]

	if not file or file.type == FileType.FILE or file.expanded then return end

	loadFiles(file.path, file.depth, index)

	file.expanded = true
end

function collapse()
	local index = getSelectedIndex()
	local file = files[index]

	if not file or file.type == FileType.FILE or not file.expanded then return end

	local i = index + 1
	while i <= #files and files[i].depth > file.depth do
		table.remove(files, i)
	end

	file.expanded = false
end

function getFileExtension(name)
	if not string.find(name, "%.") then return "" end
	return string.gsub(name, "%w*%.", "")
end

function getCurrentPath()
	local index = getSelectedIndex()
	if not index then return "/" end
	return "/" .. files[index].path
end

-- Expands folders if necessary to find and select the path, returns index of selected file
function selectFromPath(path, startIndex)
	path = string.gsub(path, "^/", "")
	if #path == 0 then return (startIndex or 2) - 1 end

	if startIndex == nil then startIndex = 1 end

	local fileName = string.match(path, "^[^/]+")
	local depth = nil

	for i, file in ipairs(files) do
		if depth == nil and i >= startIndex then depth = file.depth end

		if i >= startIndex and file.name == fileName and file.depth == depth then
			setSelection(i)

			if file.type == FileType.FILE then return i end

			expand()

			return selectFromPath(string.sub(path, #fileName + 1), i + 1)
		end
	end

	return nil
end

