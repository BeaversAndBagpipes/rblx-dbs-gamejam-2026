--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)

-- Local vars
--local Folder_Sfx = Workspace:FindFirstChild("Sfx", true)

-- Types
type Level = { [number]: number } -- each "level" is a number representing the cost (in coins) to purchase the level, and the key is the level number

-- Main
-- This is a table of levels used in the game
	-- The KEYS should not be changed, as they're used all over the codebase
	-- The VALUES should be a number representing the cost (in coins) to purchase the level

local levels = {} :: { [string]: {Level} }

-- Vehicle body
levels[D_Attributes.PlayerData.Level_Vehicle] = {
	[1] = 0, -- all components start at level 1
	[2] = 200,
	[3] = 300,
	[4] = 400,
	[5] = 500,
}

-- Vehicle engine
levels[D_Attributes.PlayerData.Level_Engine] = {
	[1] = 0, -- all components start at level 1
	[2] = 200,
	[3] = 300,
	[4] = 400,
	[5] = 500,
}

-- Vehicle fuel system
levels[D_Attributes.PlayerData.Level_FuelSystem] = {
	[1] = 0, -- all components start at level 1
	[2] = 200,
	[3] = 300,
	[4] = 400,
	[5] = 500,
}

-- Vehicle fuel tanks
levels[D_Attributes.PlayerData.Level_FuelTanks] = {
	[1] = 0, -- all components start at level 1
	[2] = 200,
	[3] = 300,
	[4] = 400,
	[5] = 500,
}