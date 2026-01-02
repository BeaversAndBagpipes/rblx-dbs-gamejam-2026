--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage
local RunService        = game:GetService("RunService") :: RunService
local TweenService      = game:GetService("TweenService") :: TweenService

-- Modules
local Util              = require(ReplicatedStorage.Shared.Lib.Util)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Anim = {}



-- ████████╗███████╗██╗  ██╗████████╗
-- ╚══██╔══╝██╔════╝╚██╗██╔╝╚══██╔══╝
--    ██║   █████╗   ╚███╔╝    ██║
--    ██║   ██╔══╝   ██╔██╗    ██║
--    ██║   ███████╗██╔╝ ██╗   ██║
--    ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝
--

function Anim.TextTypedEffect(guiObject: GuiObject, textString: string, duration: number)
	-- Ensure we got a valid object
	if not guiObject or not guiObject:IsA("GuiObject") or not guiObject.Text then
		error("Anim:TextTypedEffect(): no guiObject specified, or no Text property available")
		return
	end

	duration = tonumber(duration) or 0.75
	textString = tostring(textString) or "......"

	guiObject:SetAttribute("TextTypedEffectString", textString)

	local elapsedTime = 0
	local runConnect
	runConnect = RunService.RenderStepped:Connect(function(dt)
		elapsedTime += dt

		if elapsedTime > duration then
			runConnect:Disconnect()
			guiObject.Text = textString
		else
			-- Check we're still the opne applying the text
			if guiObject:GetAttribute("TextTypedEffectString") ~= textString then
				warn("Anim:TextTypedEffect(): TextTypedEffectString has changed, aborting")
				runConnect:Disconnect()
			else
				local progress    = elapsedTime / duration
				local charsToShow = math.floor(textString:len() * progress)
				guiObject.Text    = textString:sub(1, charsToShow)
			end
		end
	end)
end



-- ███████╗ █████╗ ██████╗ ███████╗
-- ██╔════╝██╔══██╗██╔══██╗██╔════╝
-- █████╗  ███████║██║  ██║█████╗  
-- ██╔══╝  ██╔══██║██║  ██║██╔══╝  
-- ██║     ██║  ██║██████╔╝███████╗
-- ╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝
--

function Anim.Fade(
	frame           : GuiObject,
	duration        : number,
	fromTransparency: number,
	toTransparency  : number
)
	if not frame then error("Anim.Fade: no frame") return end
	duration         = duration                     or  0.5
	fromTransparency = math.clamp(fromTransparency  or  0, 0, 1)
	toTransparency   = math.clamp(toTransparency    or 1, 0, 1)

	local goal = {
		BackgroundTransparency = toTransparency
	}
	frame.BackgroundTransparency = fromTransparency

	if frame:IsA("ImageLabel") then
		goal.ImageTransparency = toTransparency
		frame.ImageTransparency = fromTransparency
	end

	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(frame, tweenInfo, goal) :: Tween

	tween:Play()
end

function Anim.FadeOut(frame: GuiObject, duration: number?)
	Anim.Fade(frame, duration, 0, 1)
end
function Anim.FadeIn(frame: GuiObject, duration: number?)
	Anim.Fade(frame, duration, 1, 0)
end



-- ███████╗██╗     ██╗██████╗ ███████╗
-- ██╔════╝██║     ██║██╔══██╗██╔════╝
-- ███████╗██║     ██║██║  ██║█████╗  
-- ╚════██║██║     ██║██║  ██║██╔══╝  
-- ███████║███████╗██║██████╔╝███████╗
-- ╚══════╝╚══════╝╚═╝╚═════╝ ╚══════╝
--

function Anim.SlideTo(frame: GuiObject, target: UDim2, duration: number, fadeOut: boolean)
	fadeOut = fadeOut ~= false
	local tweenInfo = TweenInfo.new(
		duration or 0.5,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.In
	)
	local tweenData = {
		Position = target
	}
	tweenData.BackgroundTransparency = fadeOut == true and 1 or 0

	local tween = TweenService:Create(frame, tweenInfo, tweenData) :: Tween

	tween:Play()
end



-- ██╗    ██╗██╗ ██████╗  ██████╗ ██╗     ███████╗
-- ██║    ██║██║██╔════╝ ██╔════╝ ██║     ██╔════╝
-- ██║ █╗ ██║██║██║  ███╗██║  ███╗██║     █████╗  
-- ██║███╗██║██║██║   ██║██║   ██║██║     ██╔══╝  
-- ╚███╔███╔╝██║╚██████╔╝╚██████╔╝███████╗███████╗
--  ╚══╝╚══╝ ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
--

function Anim.Wiggle(
	obj     : GuiObject,
	offset  : Vector2,
	duration: number,
	count   : number
)
	offset   = offset or Vector2.new(10, 0)
	duration = duration or 0.5
	count    = count or 4

	-- Get or store the default position
	local defaultPosition = obj:GetAttribute(D_Attributes.Default.Position)
	if not defaultPosition then
		defaultPosition = obj.Position
		obj:SetAttribute(D_Attributes.Default.Position, defaultPosition)
	end

	-- Setup tweens
	local tweenInfo = TweenInfo.new(duration / (count * 2), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

	-- Doo the wiggle, wiggle it 🐝
	for i = 1, count do
		local factor = (count - i + 1) / count -- Damping factor (reducing over time)
		local target1 = defaultPosition + UDim2.new(0, offset.X * factor, 0, offset.Y * factor)
		local target2 = defaultPosition - UDim2.new(0, offset.X * factor, 0, offset.Y * factor)

		local tween1 = TweenService:Create(obj, tweenInfo, {Position = target1})
		local tween2 = TweenService:Create(obj, tweenInfo, {Position = target2})

		tween1:Play()
		tween1.Completed:Wait()
		tween2:Play()
		tween2.Completed:Wait()
	end

	-- Reset to original position
	local resetTween = TweenService:Create(obj, tweenInfo, {Position = defaultPosition})
	resetTween:Play()
end



-- ██████╗ ██╗   ██╗██╗     ███████╗███████╗
-- ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
-- ██████╔╝██║   ██║██║     ███████╗█████╗  
-- ██╔═══╝ ██║   ██║██║     ╚════██║██╔══╝  
-- ██║     ╚██████╔╝███████╗███████║███████╗
-- ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝
--

function Anim.PulseSize(
	obj        : GuiObject,
	sizeStart  : number,
	sizeEnd    : number,
	duration   : number,
	repeatCount: number,
	reverse    : boolean,
	delayTime  : number
)
	Anim.Size(obj, sizeStart, sizeEnd, duration, repeatCount or 10, reverse or true, delayTime or 0)
end



-- ███████╗██╗███████╗███████╗
-- ██╔════╝██║╚══███╔╝██╔════╝
-- ███████╗██║  ███╔╝ █████╗
-- ╚════██║██║ ███╔╝  ██╔══╝
-- ███████║██║███████╗███████╗
-- ╚══════╝╚═╝╚══════╝╚══════╝
--

function Anim.Size(
	obj        : GuiObject,
	sizeStart  : number,
	sizeEnd    : number,
	duration   : number,
	repeatCount: number,
	reverse    : boolean,
	delayTime  : number
)

	-- Add the UIScale component if not present
	local uiScale  = obj:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Parent = obj
	uiScale.Scale  = sizeStart or 1

	local tweenInfo = TweenInfo.new(
		duration or 0.5,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		repeatCount or 99,
		reverse or true,
		delayTime or 0
	)
	local tween = TweenService:Create(uiScale, tweenInfo, {
		Scale = sizeEnd
	}) :: Tween

	tween:Play()
end



-- ███████╗ ██████╗ █████╗ ██╗     ███████╗
-- ██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
-- ███████╗██║     ███████║██║     █████╗
-- ╚════██║██║     ██╔══██║██║     ██╔══╝
-- ███████║╚██████╗██║  ██║███████╗███████╗
-- ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
--

function Anim.ScaleTween(
	obj        : GuiObject,
	duration   : number,
	targetScale: number,
	easingDir  : Enum.EasingDirection,
	onComplete : (() -> ())?
)
	duration = duration or 0.3

	print("Anim.ScaleTween", obj, duration, targetScale)

	if not obj or not obj:IsA("GuiObject") then
		warn("Anim.ScaleTween: Invalid object passed. Expected a GuiObject, got:", obj)
		return
	end

	-- Check if animation is already in progress
	if obj:GetAttribute(D_Attributes.Anim.InProgress) == true then
		while obj:GetAttribute(D_Attributes.Anim.InProgress) == true do
			task.wait(0.05)
		end
	end
	obj:SetAttribute(D_Attributes.Anim.InProgress, true)

	-- Add the UIScale component if not present
	local uiScale  = obj:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", obj)
	--uiScale.Parent = obj
	uiScale.Scale  = targetScale == 1 and 0 or 1 -- Start from the opposite scale

	-- Adjust visibility
	obj.Visible = true

	-- Configure Tween
	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Back,
		easingDir
	)
	local tween = TweenService:Create(uiScale, tweenInfo, { Scale = targetScale }) :: Tween

	tween:Play()
	tween.Completed:Connect(function()
		if targetScale == 0 then
			obj.Visible = false
		end
		uiScale:Destroy()
		obj:SetAttribute(D_Attributes.Anim.InProgress, false)

		if onComplete then
			onComplete()
		end
	end)
end


-- ScaleIn and ScaleOut simply call ScaleTween with the appropriate parameters
function Anim.ScaleIn(obj: GuiObject, duration: number, onComplete: (() -> ())?)
	Anim.ScaleTween(obj, duration, 1, Enum.EasingDirection.Out, onComplete)
end


function Anim.ScaleOut(obj: GuiObject, duration: number, onComplete: (() -> ())?)
	Anim.ScaleTween(obj, duration, 0, Enum.EasingDirection.In, onComplete)
end



-- ██████╗  ██████╗ ████████╗ █████╗ ████████╗███████╗     █████╗ ██████╗  ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
-- ██╔══██╗██╔═══██╗╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗██║   ██║████╗  ██║██╔══██╗
-- ██████╔╝██║   ██║   ██║   ███████║   ██║   █████╗      ███████║██████╔╝██║   ██║██║   ██║██╔██╗ ██║██║  ██║
-- ██╔══██╗██║   ██║   ██║   ██╔══██║   ██║   ██╔══╝      ██╔══██║██╔══██╗██║   ██║██║   ██║██║╚██╗██║██║  ██║
-- ██║  ██║╚██████╔╝   ██║   ██║  ██║   ██║   ███████╗    ██║  ██║██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
-- ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
--

function Anim.RotateAround(
	obj        : GuiObject,
	radius     : number,
	repeatCount: number,
	duration   : number,
	offset     : UDim2,
	onComplete : (() -> ())?
)
	-- Default values
	repeatCount = repeatCount or 1
	radius      = radius or 64
	duration    = duration or 1
	offset      = offset or UDim2.new(0,0,0,0)

	-- Store some vars
	local origin = Util.UDim2Add(obj.Position, offset)
	local elapsedTime  = 0

	-- Get UDim2 position
	local function GetPosition(angle)
		local x = math.sin(-angle) * radius
		local y = math.cos(angle) * radius
		local pos = UDim2.fromOffset(x, y)
		local result = Util.UDim2Add(origin, pos)
		--print("Anim.RotateAround: origin ", origin, " | pos ", pos, " | result", result)
		return result
	end

	local hasRunOnComplete = false

	-- Use Runservice to update  the position
	local runConnect
	runConnect = RunService.RenderStepped:Connect(function(dt)
		elapsedTime += dt
		if elapsedTime > duration * repeatCount then
			if onComplete and not hasRunOnComplete then
				hasRunOnComplete = true
				onComplete()
				runConnect:Disconnect()
				return
			end

			--if (elapsedTime / 2) > duration * repeatCount then
			--	runConnect:Disconnect()
			--	return
			--end
		end

		local progress = elapsedTime / duration
		local angle    = progress * math.pi * 2 --radians, remember? always radians
		obj.Position   = GetPosition(angle)

	end)



end



-- ██╗   ██╗████████╗██╗██╗
-- ██║   ██║╚══██╔══╝██║██║
-- ██║   ██║   ██║   ██║██║
-- ██║   ██║   ██║   ██║██║
-- ╚██████╔╝   ██║   ██║███████╗
--  ╚═════╝    ╚═╝   ╚═╝╚══════╝
--

function rotateVector2(vec, angle)
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    return Vector2.new(
        vec.X * cosA - vec.Y * sinA,
        vec.X * sinA + vec.Y * cosA
    )
end

function Anim.GetRandomEasingStyle()
	local easingStyles = {
		Enum.EasingStyle.Circular,
		Enum.EasingStyle.Cubic,
		Enum.EasingStyle.Quart,
		Enum.EasingStyle.Quad,
	}

	return easingStyles[math.random(#easingStyles)]
end

function Anim.GetRandomEasingDirection()
	local easingDirections = {
		Enum.EasingDirection.In,
		Enum.EasingDirection.Out,
		Enum.EasingDirection.InOut,
	}

	return easingDirections[math.random(#easingDirections)]
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Anim
