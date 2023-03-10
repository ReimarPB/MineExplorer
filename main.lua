_G["dir"] = fs.getDir(shell.getRunningProgram())
_G["import"] = function(name)
	os.loadAPI(fs.combine(dir, name .. ".lua"))
	if _G[name .. ".lua"] then _G[name] = _G[name .. ".lua"] end
end

import("files")
import("renderer")
import("events")
import("navigation")

function getProgramForExtension(extension)
	if not settigns then return "edit" end
	return settings.get("minex.programs." .. extension, settings.get("minex.default_program", "edit"))
end

-- Set default settings
if false and settings and not settings.get("minex.default_program") then
	settings.set("minex.default_program", "edit")
	settings.set("minex.programs.nfp",    "paint")
	settings.save()
end

term.clear()

files.loadAllFiles()
files.files[1].selected = true

renderer.showFiles(files.files)

events.listen()

