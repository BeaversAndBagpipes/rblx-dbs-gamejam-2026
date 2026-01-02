--!strict

-- Main
export type HapticHandler = {
	TriggerHaptic: (
		self      : HapticHandler,
		hapticType: Enum.HapticEffectType
	) -> nil,
	PulseMotor: (
		self    : HapticHandler,
		motor   : Enum.VibrationMotor?,
		duration: number?,
		strength: number?
	) -> nil
}

-- Return
return {}
