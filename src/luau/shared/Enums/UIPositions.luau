--!strict

-- Enum: E_POSITION
local E_POSITION = {
	-- List of element position scale values
	ABOVE_LEFT   = Vector2.new(0  , 0  ),
	ABOVE_CENTER = Vector2.new(0.5, 0  ),
	ABOVE_RIGHT  = Vector2.new(1  , 0  ),
	LEFT         = Vector2.new(0  , 0.5),
	RIGHT        = Vector2.new(1  , 0.5),
	BELOW_LEFT   = Vector2.new(0  , 1  ),
	BELOW_CENTER = Vector2.new(0.5, 1  ),
	BELOW_RIGHT  = Vector2.new(1  , 1  )
} :: { [string]: Vector2 }

return E_POSITION