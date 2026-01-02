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
function GetGuiFromPlace(placeId)
	print("GetGuiFromPlace: " .. placeId)

	local content = DownloadPlace(placeId)
	local game    = roblox.deserializePlace(content)
	local Gui     = game:GetService("StarterGui")
	if Gui then
		return Gui:GetChildren()
	else
		print("! Error: Could not get Gui from placeID: " .. placeId)
	end
end

return GetGuiFromPlace