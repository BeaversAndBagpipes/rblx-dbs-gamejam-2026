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

function GetMapFromPlace(mapName, placeId)
	-- get place file and deserialize
	local content   = DownloadPlace(placeId)
	local game      = roblox.deserializePlace(content)
	local workspace = game:GetService("Workspace")

	--extract maps
	local mapsFolder = workspace:FindFirstChild("Maps")
	if not mapsFolder then
		print("! > No 'Maps' folder found in Workspace of map " .. mapName)
		return
	end

	local map = mapsFolder:FindFirstChild(mapName)
	if not map then
		print("! > Could not find map named " .. mapName .. " in 'Maps' folder of place " .. placeId)
		return
	end

	print("  > Found folder for map " .. mapName)
	return map
end

return GetMapFromPlace