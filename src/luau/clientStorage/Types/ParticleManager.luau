--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Types
local T_SharedTypes     = require(ReplicatedStorage.Shared.Types.SharedTypes)

-- Main
export type ParticleManager = {
	Burst             : (
		self     : ParticleManager,
		guiObject: GuiObject,
		props    : T_SharedTypes.ParticleBurst?
	) -> nil,
	OutlineBurst      : (
		self     : ParticleManager,
		guiObject: GuiObject,
		props    : T_SharedTypes.ParticleBurst?
	) -> nil,
	OutlineBurstCircle: (
		self     : ParticleManager,
		guiObject: GuiObject,
		props    : T_SharedTypes.ParticleBurst?
	) -> nil,
}

-- Return
return {}
