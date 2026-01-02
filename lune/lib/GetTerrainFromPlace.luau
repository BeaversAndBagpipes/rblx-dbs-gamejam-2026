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
function GetTerrainFromPlace(mapID)
	local content = DownloadPlace(mapID)
	local game = roblox.deserializePlace(content)
	local terrain = game.Workspace.Terrain
	if terrain then
		print("> Found terrain")
		return terrain
	end
end

return GetTerrainFromPlace