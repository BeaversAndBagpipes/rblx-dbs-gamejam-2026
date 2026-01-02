-- Lune libs
local fs     = require("@lune/fs")
local net    = require("@lune/net")
local roblox = require("@lune/roblox")

-- Custom libs
local dotenv = require("./dotenv.luau")
local GetMapFromPlace = require("./GetMapFromPlace")

-- Load dotenv to get ROBLOSECURITY cookie
local env = dotenv()


--Main

function GetMapsFromPlaces(maps)
	print("Downloading Maps")

	local data = {}

	-- Download, save, and read each of the places
	for mapName, placeId in pairs(maps) do
		print("> Download map "..mapName..": "..placeId)
		local map = GetMapFromPlace(mapName, placeId)
		table.insert(data, map)
	end

	return data
end

return GetMapsFromPlaces