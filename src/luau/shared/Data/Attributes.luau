--!strict

--[[
	Attributes:
	A table of every attribute name used throughout the codebase
	VALUES can be changed, if needed. EG, to help inspecting values in Studio
	KEYS must NOT be changed as they are what's referenced throughout the code
]]

local D_Attributes = {

	-- Player prefs
	PlayerPrefs        = {
		Haptics           = "Pref_Haptics",      -- HapticHandler: used to store preference - also matches elements attribute PrefToToggle value
		Music             = "Pref_Music",		 -- SoundHandler: used to store preference - also matches elements attribute PrefToToggle value
		Sfx               = "Pref_Sfx",          -- SoundHandler: used to store preference - also matches elements attribute PrefToToggle value
		Tooltips          = "Pref_Tooltips",     -- Used to toggle on-hover GUI tooltips - also matches elements attribute PrefToToggle value
		ToggleBtnPref     = "PrefToToggle",      -- Matches the preferences toggle button's attribute name; used by PlayerPrefs and UI to identify preferences
	},

	-- Player data
	PlayerData         = {
		Prefix               = "PlayerData_",          -- Prefix for player data attributes, all attribute names will be prefixed with this

		DateFirstPlayed      = "DateFirstPlayed",      -- Stat: date player was first seen
		DateLastPlayed       = "DateLastPlayed",       -- Stat: date player was most recently seen
		DaysPlayed           = "DaysPlayed",           -- Stat: total cumulative days player has logged in
		DaysPlayedInARow     = "DaysPlayedInARow",     -- Stat: current streak of days the user has logged in for
		MostDaysPlayedInARow = "MostDaysPlayedInARow", -- Stat: most consecutive days the player has
		TotalLogins          = "TotalLogins",          -- Stat: total times the player has logged in
		GameVersion          = "GameVersion",          -- Stat: version of the game the player data was last touched by

		GamesPlayed          = "GamesPlayed",          -- Stat: total number of games player
		MaxSpeed             = "MaxSpeed",             -- Stat: max speed the player has achieved

		Coins                = "Coins",              -- Stat  : total number of coins the player has
		Level_Vehicle        = "Level_Vehicle",      -- Stat  : level of the vehicle the player has - note when this is upgrades the other vehicle stats are reset
		Level_Engine         = "Level_Engine",       -- Stat  : level of the engine the player has
		Level_FuelSystem     = "Level_FuelSystem",   -- Stat  : level of the fuel system the player has
		Level_FuelTank       = "Level_FuelTank",    -- Stat  : level of the fuel tanks the player has
		Level_Nozzle         = "Level_Nozzle",      -- Stat  : level of the engine bells the player has
	},

	-- General default attributes, used for animations mostly
	Default            = {
		Brightness = "DefaultBrightness", -- used by Lighting Manager (Gaffer)
		CFrame     = "DefaultCFrame",     -- Used when animating/moving objects
		Color      = "DefaultColor",      -- used by Lighting Manager (Gaffer)
		Position   = "DefaultPosition",   -- Used when animating UI  or  Workspace objects
		Size       = "DefaultSize",       -- Used when animating elements
		Value      = "DefaultValue",      -- Used by Admin panel to remember default value
	},

	UI = {
		Closed = "UI_Closed",
	},

	-- Misc
	Anim = {
		InProgress = "AnimInProgress" -- used by the anim lib to check if an instance is currently being animated
	},

	VehicleParts = {
		Vehicle     = "Vehicle",
		Engine      = "Engine",
		FuelSystem  = "FuelSystem",
		FuelTank    = "FuelTank",
		Nozzle      = "Nozzle",
	}

}

table.freeze(D_Attributes)
return D_Attributes
