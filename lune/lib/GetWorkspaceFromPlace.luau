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
function GetWorkspaceFromPlace(placeId)
	--[[
		This function allows you to load in the contents of a workspace from
		a place ID.
	]]

	print("> Loading workspace from placeId: " .. placeId)

	-- get place file and deserialize
	local content   = DownloadPlace(placeId)
	local game      = roblox.deserializePlace(content)
	local workspace = game:GetService("Workspace")

	return workspace
end

return GetWorkspaceFromPlace