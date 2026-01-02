--!strict

-- Services
local RunService        = game:GetService("RunService") :: RunService
local TweenService      = game:GetService("TweenService") :: TweenService



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Anim3D = {}


function Anim3D.TweenModelScale(
	model          : Model,
	targetSize     : number,
	duration       : number,
	easingStyle    : Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	onComplete     : () -> ()?
)
	targetSize      = targetSize   or  0
	duration        = duration     or  1
	easingStyle     = easingStyle  or  Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.InOut

	local elapsedTime = 0
	local connect
	local startSize = model:GetScale()
	local diffSize = targetSize - startSize
	connect = RunService.PreRender:Connect(function(dt: number)

		elapsedTime += dt
		local t     = elapsedTime / duration
		local scale = TweenService:GetValue(t, easingStyle, easingDirection)
		local newSize = math.max(startSize + (diffSize * scale), 0.001)
		model:ScaleTo(newSize)
		if t >= 1 then
			if onComplete then
				onComplete()
			end
			connect:Disconnect()
		end
	end)
end

-- Return
return Anim3D

