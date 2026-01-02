--!strict

-- Services
local HapticService     = game:GetService("HapticService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

-- Types
local T_HapticHandler   = require(ReplicatedStorage.ClientStorage.Types.HapticHandler)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)

-- Modules
--local Settings          = require(ReplicatedStorage.Shared.Settings)
--local Util              = require(ReplicatedStorage.Shared.Lib.Util)

-- Local vars
local LocalPlayer       = Players.LocalPlayer :: Player



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

--[[
	Haptic Handler

	Controls haptic/vibration feedback.

	This script was written just before the introduction of the new Haptic system, so it works
	by tweening the motor strengths of valid controller motors.

	It uses the new Enum.HapticEffectType for describing vibration patterns, and attempts to
	implement them using the current motor controls. It works, mostly.

	Example use:
		local _HapticHandler = require(StarterScripts.Shared.Modules.EventManager)
		_HapticHandler:TriggerHaptic(Enum.HapticEffectType.GameplayCollision)

]]
local HapticHandler = {}



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

type InitConfig = {
	BE_TriggerHaptic: BindableEvent,
	RE_TriggerHaptic: RemoteEvent,
}

function HapticHandler:Init(config: InitConfig)

	-- Store last input device
	self.InputDevice = Enum.UserInputType.Keyboard
	UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
		self.InputDevice = lastInputType
	end)

	-- Watch for haptic muting
	LocalPlayer:GetAttributeChangedSignal(D_Attributes.PlayerPrefs.Haptics):Connect(function()
		self.hapticMuted = not LocalPlayer:GetAttribute(D_Attributes.PlayerPrefs.Haptics)
	end)

	-- Bind to BindableEvent
	assert(config.BE_TriggerHaptic, "BE_TriggerHaptic not provided")
	config.BE_TriggerHaptic.Event:Connect(function(hapticType: Enum.HapticEffectType)
		self:TriggerHaptic(hapticType)
	end)

	-- Bind to RemoteEvent
	assert(config.RE_TriggerHaptic, "RE_TriggerHaptic not provided")
	config.RE_TriggerHaptic.OnClientEvent:Connect(function(hapticType: Enum.HapticEffectType)
		self:TriggerHaptic(hapticType)
	end)
end



-- ████████╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗     ██╗  ██╗ █████╗ ██████╗ ████████╗██╗ ██████╗
-- ╚══██╔══╝██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗    ██║  ██║██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝
--    ██║   ██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝    ███████║███████║██████╔╝   ██║   ██║██║
--    ██║   ██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗    ██╔══██║██╔══██║██╔═══╝    ██║   ██║██║
--    ██║   ██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║    ██║  ██║██║  ██║██║        ██║   ██║╚██████╗
--    ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ╚═╝ ╚═════╝
--

function HapticHandler:TriggerHaptic(hapticType: Enum.HapticEffectType)
	print("HapticHandler:TriggerHaptic(hapticType)", hapticType)

	if self.hapticMuted then
		print("HapticHandler:TriggerHaptic(): hapticMuted = true, aborting")
		return
	end

	hapticType = hapticType or Enum.HapticEffectType.UINotification

	-- Check haptic feedback is supported by current input device
	if not HapticService:IsVibrationSupported(self.InputDevice) then
		warn("HapticHandler:TriggerHaptic(): IsVibrationSupported = false, aborting", self.InputDevice)
		return
	end

	-- New HapticEffect class, not yet implemented
	-- When this releases, enable this code, and then disable the code below
	--[[
	local haptic  = LocalPlayer:FindFirstChildOfClass("HapticEffect") or Instance.new("HapticEffect", LocalPlayer)
	haptic.Looped = false
	--haptic.Parent = LocalPlayer
	haptic.Type   = hapticType

	haptic:Play()
	--task.wait(1)
	--haptic:Destroy()
	]]


	-- Current way of handling vibrations, using manual control of the motor
	-- We've manaully programemd in some patterns to represent the haptic Enums
	-- They're mostly reliable, except for the UIClick and UINotification, which attempt to do a single blip but sometimes can't be felt
	local motor   : Enum.VibrationMotor,
		  strength: number,
		  duration: number

	if hapticType == Enum.HapticEffectType.UIHover then
		motor    = Enum.VibrationMotor.Small
		duration = 0.75
		strength = 0.3
		self:PulseMotor(motor, duration, strength)
		return

	end

	if hapticType == Enum.HapticEffectType.UIClick then
		motor    = Enum.VibrationMotor.Small
		duration = 0.1
		strength = 0.5
		self:PulseMotor(motor, duration, strength)
		return
	end

	if hapticType == Enum.HapticEffectType.UINotification then
		motor    = Enum.VibrationMotor.Small
		duration = 0.1
		strength = 0.5
		self:PulseMotor(motor, duration, strength)
		task.wait(0.2)
		self:PulseMotor(motor, duration, strength)

	end

	if hapticType == Enum.HapticEffectType.GameplayCollision then
		motor    = Enum.VibrationMotor.Large
		duration = 0.3
		strength = 2
		self:TweenMotor(motor, duration, strength)
		return
	end

	if hapticType == Enum.HapticEffectType.GameplayExplosion then
		motor    = Enum.VibrationMotor.Large
		duration = 0.6
		strength = 4
		self:TweenMotor(motor, duration, strength)
		return
	end

end



-- ██████╗ ██╗   ██╗██╗     ███████╗███████╗    ███╗   ███╗ ██████╗ ████████╗ ██████╗ ██████╗ 
-- ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝    ████╗ ████║██╔═══██╗╚══██╔══╝██╔═══██╗██╔══██╗
-- ██████╔╝██║   ██║██║     ███████╗█████╗      ██╔████╔██║██║   ██║   ██║   ██║   ██║██████╔╝
-- ██╔═══╝ ██║   ██║██║     ╚════██║██╔══╝      ██║╚██╔╝██║██║   ██║   ██║   ██║   ██║██╔══██╗
-- ██║     ╚██████╔╝███████╗███████║███████╗    ██║ ╚═╝ ██║╚██████╔╝   ██║   ╚██████╔╝██║  ██║
-- ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝    ╚═╝     ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝
--

function HapticHandler:PulseMotor(
	motor   : Enum.VibrationMotor,
	duration: number,
	strength: number
): nil
	motor    = motor or Enum.VibrationMotor.Large
	duration = duration or 0.5
	strength = strength or 1

	if HapticService:IsMotorSupported(self.InputDevice, motor) then
		HapticService:SetMotor(self.InputDevice, motor, strength)
		task.wait(duration)
		HapticService:SetMotor(self.InputDevice, motor, 0)
	end
end



-- ████████╗██╗    ██╗███████╗███████╗███╗   ██╗    ███╗   ███╗ ██████╗ ████████╗ ██████╗ ██████╗ 
-- ╚══██╔══╝██║    ██║██╔════╝██╔════╝████╗  ██║    ████╗ ████║██╔═══██╗╚══██╔══╝██╔═══██╗██╔══██╗
--    ██║   ██║ █╗ ██║█████╗  █████╗  ██╔██╗ ██║    ██╔████╔██║██║   ██║   ██║   ██║   ██║██████╔╝
--    ██║   ██║███╗██║██╔══╝  ██╔══╝  ██║╚██╗██║    ██║╚██╔╝██║██║   ██║   ██║   ██║   ██║██╔══██╗
--    ██║   ╚███╔███╔╝███████╗███████╗██║ ╚████║    ██║ ╚═╝ ██║╚██████╔╝   ██║   ╚██████╔╝██║  ██║
--    ╚═╝    ╚══╝╚══╝ ╚══════╝╚══════╝╚═╝  ╚═══╝    ╚═╝     ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝
--

function HapticHandler:TweenMotor(
	motor          : Enum.VibrationMotor,
	duration       : number,
	strength       : number,
	easingStyle    : Enum.EasingStyle,
	easingDirection: Enum.EasingDirection
): nil

	motor           = motor or Enum.VibrationMotor.Large
	duration        = duration or 0.5
	strength        = strength or 1
	easingStyle     = easingStyle or Enum.EasingStyle.Circular
	easingDirection = easingDirection or Enum.EasingDirection.Out

	if HapticService:IsMotorSupported(self.InputDevice, motor) then
		local runConnect
		local elapsedTime = 0
		runConnect = RunService.RenderStepped:Connect(function(dt)

			local progress      = elapsedTime / duration
			local progressEased = TweenService:GetValue(progress, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
			local scale         = 1 - math.abs(progressEased * 2 - 1) -- 0 => 1 => 0

			--warn("HapticHandler:TriggerHaptic(): SetMotor():", self.InputDevice, motor, strength)
			HapticService:SetMotor(self.InputDevice, motor, strength * scale)

			elapsedTime += dt
			if elapsedTime > duration then
				runConnect:Disconnect()
				HapticService:SetMotor(self.InputDevice, motor, 0)
				return
			end
		end)
	else
		warn("HapticHandler:TriggerHaptic(): Motor type not supported by current inputDevice", motor, self.InputDevice)
	end
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return HapticHandler :: T_HapticHandler.HapticHandler
