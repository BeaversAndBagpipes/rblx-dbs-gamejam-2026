--!strict

-- Type Definitions

-- MARK: SoundParams
export type SoundParams = {
	parent        : BasePart?, -- (optional) default LocalPlayer - parent the sound to a sepcific object
	pitchIncrement: number?,   -- (optional) default 0 - increase pitch every repeat
	pitchOffset   : number?,   -- (optional) default 0 - standard pitch adjust
	pitchRandom   : number?,   -- (optional) default 0 - max random amount to vary pitch, every repeat
	repeatCount   : number?,   -- (optional) default 1
	repeatDelay   : number?,   -- (optional) default 1 - time between triggering each sound (ignores sfx duration)
	repeatRandom  : number?,   -- (optional) default 0 - max random amount to vary repeat delay, every repeat
}


-- MARK: Particles: Burst
export type ParticleBurst = {
	guiObject   : GuiObject,
	count       : number?,
	repeatCount : number?,
	emitDuration: number?,
	maxAge      : number?,
	interval    : number?,
	velocity    : number?,
	particles   : { ImageLabel }?,
	spawnPos    : () -> Vector2?
}

export type UpgradeDescription = {
	tier	: string,
	level 	: number
}

return {}
