-- File:
-- * name: string
-- * path: string
-- * isDir: bool
-- * depth: int
-- * selected: bool
-- * expanded: bool
files = {}

local function loadFiles(path, depth, index)
	for i, file in ipairs(fs.list(path)) do
		local filePath = fs.combine(path, file)
		table.insert(files, index + i, {
			name = file,
			path = filePath,
			isDir = fs.isDir(filePath),
			depth = depth + 1,
			selected = false,
			expanded = false,
		})
	end
end

function loadAllFiles()
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

function expand()
	local index = getSelectedIndex()
	local file = files[index]

	if not file.isDir or file.expanded then return end

	loadFiles(file.path, file.depth, index)

	file.expanded = true
end

function collapse()
	local index = getSelectedIndex()
	local file = files[index]

	if not file.isDir or not file.expanded then return end

	local i = index + 1
	while i <= #files and files[i].depth > file.depth do
		table.remove(files, i)
	end

	file.expanded = false
end

