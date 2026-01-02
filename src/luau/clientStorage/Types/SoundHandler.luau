--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Types
local T_SoundParams     = require(ReplicatedStorage.Shared.Types.SoundParams)

-- Main
export type SoundHandler = {
	Init         : (
		self           : SoundHandler,
		BE_TriggerSound: BindableEvent,
		RE_TriggerSound: RemoteEvent
	) -> nil,

	TriggerSound : (
		self  : SoundHandler,
		sound : Sound | { Sound },
		params: T_SoundParams.SoundParams
	) -> nil,

	TriggerMusic: (
		self : SoundHandler,
		sound: Sound
	) -> nil,

	StartMusic   : (
		self: SoundHandler
	) -> nil,

	StopMusic    : (
		self: SoundHandler
	) -> nil
}

-- Return
return {}
