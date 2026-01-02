--!strict

-- Services
local Workspace = game:GetService("Workspace")

-- Local vars
local Folder_Sfx = Workspace:FindFirstChild("Sfx", true)

-- Types
type Sfx = Sound | { [number]: Sound } -- each entry can either be a string, or a table of strings, or a SoundEffect object, or a table of SoundEffect objects

-- Main
-- This is a table of Sound Instances used in the game
	-- The KEYS should not be changed, as they're used all over the codebase
	-- The VALUES should be valid part references
		-- VALUES can be either a single instance, or a table of Instances
		-- If using a table, a random entry will be chosen

-- Define sfx table expected structure
local sfx = {} :: { [string]: Sfx | { [number]: Sfx } }

-- Misc
sfx.Default        = { Folder_Sfx:WaitForChild("error") }     -- used when a sound effect can't be found, falls back to this
sfx.Generic_Error  = { Folder_Sfx:WaitForChild("error") }     -- used for error noise
sfx.Notify_PopUp   = { Folder_Sfx:WaitForChild("pop-up") }    -- used when a window appears

-- UI
sfx.Button_Generic = { Folder_Sfx:WaitForChild("btn-click") } -- used by non-specific UI buttons
sfx.Button_Close   = { Folder_Sfx:WaitForChild("btn-click") } -- used to close/dismiss pop-up windows

-- Music
sfx.Music_Lobby    = Folder_Sfx:WaitForChild("happy-cheerful-folk-pop-264393")

-- Return
return sfx
