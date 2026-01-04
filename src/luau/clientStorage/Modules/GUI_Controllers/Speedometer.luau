--!strict

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

-- Types
local T_ParticleManager = require(ReplicatedStorage.ClientStorage.Types.ParticleManager)
local T_SoundHandler    = require(ReplicatedStorage.ClientStorage.Types.SoundHandler)
local T_WindowManager   = require(ReplicatedStorage.ClientStorage.Types.WindowManager)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Levels          = require(ReplicatedStorage.Shared.Data.Levels)
local D_Sfx             = require(ReplicatedStorage.Shared.Data.Sfx)

--Modules
local Anim              = require(ReplicatedStorage.Shared.Lib["Anim.GUI"])
local Settings          = require(ReplicatedStorage.Shared.Settings)
local Util              = require(ReplicatedStorage.Shared.Lib.Util)
local Zone              = require(ReplicatedStorage.Shared.Lib.ZonePlus)

-- Local vars
local LocalPlayer       = Players.LocalPlayer :: Player
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local Gui               = PlayerGui:WaitForChild("GUI"):WaitForChild("UI_Speed") :: ScreenGui


-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗  
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_Speedometer = {
	Init: (
		self: T_Speedometer,
		config: InitConfig
	) -> nil,
	Show: (
		self: T_Speedometer
	) -> nil,
	Hide: (
		self: T_Speedometer
	) -> nil,
	SetValue: (
		self: T_Speedometer,
		ratio: number,
		trueValue: number
	) -> nil,
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Speedometer = {} :: T_Speedometer


-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

type InitConfig = {
	BE_TriggerSound: BindableEvent,
	Btn_Func: () -> (),
}

function Speedometer:Init(config: InitConfig)

	assert(config.BE_TriggerSound, "BE_TriggerSound not provided")
	self.BE_TriggerSound = config.BE_TriggerSound

	assert(config.Btn_Func, "Btn_Func not provided")
	self.Btn_Func = config.Btn_Func

	Gui.Enabled = true

	-- Get references to GameUI elements for later user
	self.Frame_Root          = Gui:FindFirstChild("Frame_Root"):: Frame -- Root frame
	self.defaultPosition     = UDim2.fromScale(self.Frame_Root.Position.X.Scale, self.Frame_Root.Position.Y.Scale)

	self.Text_Value        = Gui:FindFirstChild("Text_Value", true):: TextLabel -- Value text

	self.Img_Needle        = Gui:FindFirstChild("Img_Needle", true):: Frame -- Grid of upgrade buttons


	task.spawn(function()
		task.wait(0.1)
		self.Frame_Root.Position = UDim2.fromScale(self.defaultPosition.X.Scale, -1)
	end)
end




-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Speedometer:Show(name: string)
	Anim.SlideTo(self.Frame_Root, self.defaultPosition, 0.5, false)
end

function Speedometer:Hide(name: string)
	local target = UDim2.fromScale(self.defaultPosition.X.Scale, -1)
	Anim.SlideTo(self.Frame_Root, target, 0.5, true)
end



-- ███████╗███████╗████████╗    ██╗   ██╗ █████╗ ██╗     ██╗   ██╗███████╗
-- ██╔════╝██╔════╝╚══██╔══╝    ██║   ██║██╔══██╗██║     ██║   ██║██╔════╝
-- ███████╗█████╗     ██║       ██║   ██║███████║██║     ██║   ██║█████╗  
-- ╚════██║██╔══╝     ██║       ╚██╗ ██╔╝██╔══██║██║     ██║   ██║██╔══╝  
-- ███████║███████╗   ██║        ╚████╔╝ ██║  ██║███████╗╚██████╔╝███████╗
-- ╚══════╝╚══════╝   ╚═╝         ╚═══╝  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝
--

function Speedometer:SetValue(ratio: number, trueValue: number)
	ratio = math.clamp(ratio or 0.5, 0, 1)

	local minRotation = 0
	local maxRotation = -205
	local rotation = minRotation + (maxRotation - minRotation) * ratio

	self.Frame_Marker.Rotation = rotation

	self.Text_Value.Text = trueValue
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Speedometer
