-- File:
-- * name: string
-- * path: string
-- * isDir: bool
-- * selected: bool
files = {}

function loadFiles(path)
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

