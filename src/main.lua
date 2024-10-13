_G["dir"] = fs.getDir(shell.getRunningProgram())
_G["shell"] = shell
_G["import"] = function(name)
	os.loadAPI(fs.combine(dir, name .. ".lua"))
	if _G[name .. ".lua"] then _G[name] = _G[name .. ".lua"] end
end
_G["clearScreen"] = function()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.setCursorPos(1, 1)
	term.clear()
end

import("files")
import("events")
import("renderer")
import("navigation")
import("input")
import("status")

-- Set default settings
if settings and not settings.get("minex.default_program") then
	settings.set("minex.default_program", "edit")
	settings.set("minex.programs.nfp",    "paint")
	settings.save()
end

files.loadAllFiles()

local path = ...
if path == nil then
	files.files[1].selected = true
elseif fs.exists(shell.resolve(path)) then
	files.selectFromPath(shell.resolve(path))
else
	term.setTextColor(colors.red)
	print("Invalid path: " .. path)
	return
end

term.clear()

events.setFocus(events.Focus.FILES)

renderer.showEverything()

events.listen()

