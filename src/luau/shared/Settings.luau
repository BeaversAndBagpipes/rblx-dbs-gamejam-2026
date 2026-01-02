--!strict

-- Services
local ReplicatedFirst   = game:GetService("ReplicatedFirst")

-- Data
local VERSION = require(ReplicatedFirst.Shared.VERSION)

-- Main
local Settings = {
	GameVersion = VERSION, -- Version number for playerData tests
}

Settings.Player = {
	CharacterWalkSpeed    = 16,
	CharacterJumpHeight   = 7.2,
	CharacterJumpPower    = 50,
	CharacterUseJumpPower = true, -- false = JumpHeight
	CharacterRespawnTime  = 5,
}

Settings.Audio = {
	MusicVolume   = 0.5,
	EffectsVolume = 0.8,
}


return Settings
