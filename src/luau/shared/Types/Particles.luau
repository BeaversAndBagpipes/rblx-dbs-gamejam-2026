--!strict

-- Type Definitions

export type Burst = {
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

return {}
