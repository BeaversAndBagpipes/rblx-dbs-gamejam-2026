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
local Gui               = PlayerGui:WaitForChild("GUI"):WaitForChild("UI_Warmup") :: ScreenGui



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Warmup = {}


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

function Warmup:Init(config: InitConfig)

	assert(config.BE_TriggerSound, "BE_TriggerSound not provided")
	self.BE_TriggerSound = config.BE_TriggerSound

	assert(config.Btn_Func, "Btn_Func not provided")
	self.Btn_Func = config.Btn_Func

	Gui.Enabled = true

	-- Get references to GameUI elements for later user
	self.Frame_Root          = Gui:FindFirstChild("Frame_Root"):: Frame -- Root frame
	self.defaultPosition     = self.Frame_Root.Position
	self.Frame_Root.Position = UDim2.fromScale(self.defaultPosition.X.Scale, 1.75) -- hide it off-screen

	self.Frame_Marker        = Gui:FindFirstChild("Frame_Marker", true):: Frame -- Grid of upgrade buttons

	self.Btn_Input           = Gui:FindFirstChild("Btn_Input", true):: GuiButton -- Main window title
	self.Btn_Input.MouseButton1Click:Connect(function()
		self.Btn_Func()
	end)
end




-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Warmup:Show(name: string)
	Anim.SlideTo(self.Frame_Root, self.defaultPosition, 0.5, false)
end

function Warmup:Hide(name: string)
	local target = UDim2.fromScale(self.defaultPosition.X.Scale, 1.75)
	Anim.SlideTo(self.Frame_Root, target, 0.5, true)
end



-- ███████╗███████╗████████╗    ██╗   ██╗ █████╗ ██╗     ██╗   ██╗███████╗
-- ██╔════╝██╔════╝╚══██╔══╝    ██║   ██║██╔══██╗██║     ██║   ██║██╔════╝
-- ███████╗█████╗     ██║       ██║   ██║███████║██║     ██║   ██║█████╗  
-- ╚════██║██╔══╝     ██║       ╚██╗ ██╔╝██╔══██║██║     ██║   ██║██╔══╝  
-- ███████║███████╗   ██║        ╚████╔╝ ██║  ██║███████╗╚██████╔╝███████╗
-- ╚══════╝╚══════╝   ╚═╝         ╚═══╝  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝
--

function Warmup:SetValue(value: number)
	value = math.clamp(value or 0.5, 0, 1)

	self.Frame_Marker.Position = UDim2.fromScale(value, 0)
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Warmup
