-- File:
-- * name: string
-- * path: string
-- * isDir: bool
-- * selected: bool
files = {}

local function loadFiles(path)
	for _, file in ipairs(fs.list(path)) do
		local filePath = fs.combine(path, file)
		table.insert(files, {
			name = file,
			path = filePath,
			isDir = fs.isDir(filePath),
			selected = false,
		})
	end
end

function loadAllFiles()
	loadFiles("/")
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

