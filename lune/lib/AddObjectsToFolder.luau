-- Lune libs
local roblox = require("@lune/roblox")

--Main
local function AddObjectsToFolder(data, folderName, parent)

	print("> Adding " .. folderName .. " to "..parent.Name)

	local folder = roblox.Instance.new("Folder")
	folder.Name = folderName
	folder.Parent = parent

	for name, child in pairs(data) do
		print(">  Adding " .. name .. " - " .. child.Name)
		data.Parent = folder
	end
end

return AddObjectsToFolder