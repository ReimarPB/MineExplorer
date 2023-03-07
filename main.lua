local dir = fs.getDir(shell.getRunningProgram())

os.loadAPI(fs.combine(dir, "files.lua"))
os.loadAPI(fs.combine(dir, "renderer.lua"))

term.clear()

files.loadAllFiles()

renderer.showFiles(files.files)

