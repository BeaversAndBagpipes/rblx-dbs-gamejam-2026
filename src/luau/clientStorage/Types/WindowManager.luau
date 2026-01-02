--!strict

-- Main
export type WindowManager = {
	AddToQueue     : (
		self        : WindowManager,
		guiObject   : GuiObject,
		forceToFront: boolean
	) -> nil,

	RemoveFromQueue: (
		self     : WindowManager,
		guiObject: GuiObject
	) -> nil,
}

-- Return
return {}
