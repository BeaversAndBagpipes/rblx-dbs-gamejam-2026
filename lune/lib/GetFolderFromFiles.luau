-- Lune libs
local fs     = require("@lune/fs")
local net    = require("@lune/net")
local roblox = require("@lune/roblox")

-- Custom libs
local dotenv = require("./dotenv.luau")

-- Load dotenv to get ROBLOSECURITY cookie
local env = dotenv()


--Main
function GetFolderFromFiles(folderName, files)
	--[[
		This function allows you to load in the contents of a named folder from 
		multiple files. This is because we often have mobs in their own files, and sometimes in the same
		file. This way we can split them up into as many or few files as we want and then
		combine them into a single folder.
	]]

	print("> Loading folder '" .. folderName .. "' from " .. #files .. " files")

	local data = {}

	for _, filename in ipairs(files) do
		local file      = fs.readFile(filename)
		local game      = roblox.deserializePlace(file)
		local workspace = game:GetService("Workspace")

		if string.lower(folderName) == "workspace" then
			return workspace
		end

		local folder = workspace[folderName]

		if folder and folder:IsA("Folder") then
			return folder
		end
	end

	return data
end

return GetFolderFromFiles