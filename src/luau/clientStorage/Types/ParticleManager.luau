--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Types
local T_Particles       = require(ReplicatedStorage.Shared.Types.Particles)

-- Main
export type ParticleManager = {
	Burst             : (
		self     : ParticleManager,
		guiObject: GuiObject,
		props    : T_Particles.Burst?
	) -> nil,
	OutlineBurst      : (
		self     : ParticleManager,
		guiObject: GuiObject,
		props    : T_Particles.Burst?
	) -> nil,
	OutlineBurstCircle: (
		self     : ParticleManager,
		guiObject: GuiObject,
		props    : T_Particles.Burst?
	) -> nil,
}

-- Return
return {}
