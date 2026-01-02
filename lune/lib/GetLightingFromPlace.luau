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
function GetLightingFromPlace(placeId)
	print("GetLightingFromPlace: " .. placeId)

	local content  = DownloadPlace(placeId)
	local game     = roblox.deserializePlace(content)
	local Lighting = game:GetService("Lighting")
	if Lighting then
		return Lighting
	else
		print("! Error: Could not get Lighting from placeID: " .. placeId)
	end
end

return GetLightingFromPlace