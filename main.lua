local dir = fs.getDir(shell.getRunningProgram())

os.loadAPI(fs.combine(dir, "files.lua"))
os.loadAPI(fs.combine(dir, "renderer.lua"))

term.clear()

files.loadAllFiles()
files.files[1].selected = true

renderer.showFiles(files.files)

