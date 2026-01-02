-- Lune libs
local fs     = require("@lune/fs")
local net    = require("@lune/net")
local roblox = require("@lune/roblox")

-- Custom libs
local dotenv = require("./dotenv.luau")
local DownloadPlace = require("./DownloadPlace")

-- Load dotenv to get ROBLOSECURITY cookie
local env = dotenv()


--Main
function GetFolderFromPlace(folderName, placeId)
	--[[
		This function allows you to load in the contents of a named folder from 
		a place ID. 
	]]

	print("> Loading folder '" .. folderName .. "' from placeId: " .. placeId)

	-- get place file and deserialize
	local content   = DownloadPlace(placeId)
	local game      = roblox.deserializePlace(content)
	local workspace = game:GetService("Workspace")
	local folder    = workspace[folderName]

	if folder and folder:IsA("Folder") then
		return folder
	else 
		return false
	end

end

return GetFolderFromPlace