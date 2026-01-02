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

		-- More stats can be added here, eg:
		--[[
		GamesPlayed          = "GamesPlayed",          -- Stat: total number of games player
		GamesWon             = "GamesWon",             -- Stat: total number of games won
		GamesWonInARow       = "GamesWonInARow",       -- Stat: total number of games won in a row
		]]
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

	-- Misc
	Anim = {
		InProgress = "AnimInProgress" -- used by the anim lib to check if an instance is currently being animated
	}

}

table.freeze(D_Attributes)
return D_Attributes
