--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)

-- Local vars
--local Folder_Sfx = Workspace:FindFirstChild("Sfx", true)

-- Types
type Level = { [number]: {
	cost     : number,
	icon     : string,
	statValue: number,
} } -- each "level" is a number representing the cost (in coins) to purchase the level, and the key is the level number

-- Main
-- This is a table of levels used in the game
	-- The KEYS should not be changed, as they're used all over the codebase
	-- The VALUES should be a number representing the cost (in coins) to purchase the level

local levels = {} :: { [string]: { [number]: Level } }

-- Vehicle body
levels.Vehicle = {
	[1] = {
		cost     = 0,
		name     = "Vehicle 1",
		icon     = "rbxassetid://1234567890",
		statValue = 10,
	},
	[2] = {
		cost     = 100,
		name     = "Vehicle 2",
		icon     = "rbxassetid://1234567890",
		statValue = 12,
	},
	[3] = {
		cost     = 400,
		name     = "Vehicle 3",
		icon     = "rbxassetid://1234567890",
		statValue = 14,
	},
	[4] = {
		cost     = 1000,
		name     = "Vehicle 4",
		icon     = "rbxassetid://1234567890",
		statValue = 16,
	}
}

-- Vehicle engine
levels.Engine = {
	[1]        = {
		cost      = 0,
		name      = "Engine 1",
		icon      = "rbxassetid://102217505435625",
		statValue = 2,
	},
	[2]        = {
		cost      = 100,
		name      = "Engine 2",
		icon      = "rbxassetid://111763757416474",
		statValue = 3,
	},
	[3]        = {
		cost      = 400,
		name      = "Engine 3",
		icon      = "rbxassetid://138015811833511",
		statValue = 4,
	},
	[4]        = {
		cost      = 1000,
		name      = "Engine 4",
		icon      = "rbxassetid://71748925882844",
		statValue = 6,
	}
}

-- Vehicle fuel system
levels.FuelSystem = {
	[1]        = {
		cost      = 0,
		name      = "Fuel System 1",
		icon      = "rbxassetid://108062062329824",
		statValue = 10,
	},
	[2]        = {
		cost      = 100,
		name      = "Fuel System 2",
		icon      = "rbxassetid://89025312680280",
		statValue = 12,
	},
	[3]        = {
		cost      = 400,
		name      = "Fuel System 3",
		icon      = "rbxassetid://137677197286659",
		statValue = 14,
	},
	[4]        = {
		cost      = 1000,
		name      = "Fuel System 4",
		icon      = "rbxassetid://72059993874686",
		statValue = 15,
	}
}

-- Vehicle fuel tanks
levels.FuelTank = {
	[1]        = {
		cost      = 0,
		name      = "Fuel Tank 1",
		icon      = "rbxassetid://96157761753281",
		statValue = 3,
	},
	[2]        = {
		cost      = 100,
		name      = "Fuel Tank 2",
		icon      = "rbxassetid://91740470277721",
		statValue = 4,
	},
	[3]        = {
		cost      = 400,
		name      = "Fuel Tank 3",
		icon      = "rbxassetid://131645565857718",
		statValue = 5,
	},
	[4]        = {
		cost      = 1000,
		name      = "Fuel Tank 4",
		icon      = "rbxassetid://136004226347092",
		statValue = 6,
	}
}

-- Engine nozzles
levels.Nozzle = {
	[1]        = {
		cost      = 0,
		name      = "Nozzle 1",
		icon      = "rbxassetid://77578901218759",
		statValue = 10,
	},
	[2]        = {
		cost      = 100,
		name      = "Nozzle 2",
		icon      = "rbxassetid://111221818607785",
		statValue = 12,
	},
	[3]        = {
		cost      = 400,
		name      = "Nozzle 3",
		icon      = "rbxassetid://118302719065587",
		statValue = 14,
	},
	[4]        = {
		cost      = 1000,
		name      = "Nozzle 4",
		icon      = "rbxassetid://92516573396327",
		statValue = 16,
	}
}

return levels