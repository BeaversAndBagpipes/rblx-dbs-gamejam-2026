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

function SaveLightingFromPlace(placeId, filePath)
	print("SaveLightingFromPlace: " .. placeId .. " to ".. filePath)

	local content  = DownloadPlace(placeId)
	local game     = roblox.deserializePlace(content)
	local lighting = game:GetService("Lighting")

	local file = roblox.serializeModel({lighting})
	fs.writeFile(filePath, file)
end

return SaveLightingFromPlace