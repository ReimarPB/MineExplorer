-- File:
-- * name: string
-- * isDir: bool
files = {}

function loadFiles(path)
	for _, file in ipairs(fs.list(path)) do
		table.insert(files, {
			name = file,
			isDir = fs.isDir(fs.combine(path, file)),
		})
	end
end

function loadAllFiles()
	loadFiles("/")
end

