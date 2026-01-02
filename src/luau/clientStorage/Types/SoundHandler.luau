--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Types
local T_SharedTypes     = require(ReplicatedStorage.Shared.Types.SharedTypes)

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
		params: T_SharedTypes.SoundParams
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
