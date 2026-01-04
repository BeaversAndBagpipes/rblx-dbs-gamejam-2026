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
local Gui               = PlayerGui:WaitForChild("GUI"):WaitForChild("UI_Fuel") :: ScreenGui


-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗  
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_Fuel = {
	Init: (
		self: T_Fuel,
		config: InitConfig
	) -> nil,
	Show: (
		self: T_Fuel
	) -> nil,
	Hide: (
		self: T_Fuel
	) -> nil,
	SetValue: (
		self: T_Fuel
	) -> nil,
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Fuel = {} :: T_Fuel


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

function Fuel:Init(config: InitConfig)

	assert(config.BE_TriggerSound, "BE_TriggerSound not provided")
	self.BE_TriggerSound = config.BE_TriggerSound

	assert(config.Btn_Func, "Btn_Func not provided")
	self.Btn_Func = config.Btn_Func

	Gui.Enabled = true

	-- Get references to GameUI elements for later user
	self.Frame_Root          = Gui:FindFirstChild("Frame_Root"):: Frame -- Root frame
	self.defaultPosition     = UDim2.fromScale(self.Frame_Root.Position.X.Scale, self.Frame_Root.Position.Y.Scale)

	self.Frame_Body_Tanks   = Gui:FindFirstChild("Frame_Body_Tanks", true):: Frame -- Body tanks frame
	self.Frame_Tank_Default = Gui:FindFirstChild("Tank_Default", true):: Frame -- Default tank frame
	self.Frame_System_Level = Gui:FindFirstChild("System_Level", true):: Frame -- System level frame

	-- State stuff
	self.currentTank = 0
	self.currentTankMax = 4


	task.spawn(function()
		task.wait(0.1)
		self.Frame_Root.Position = UDim2.fromScale(self.defaultPosition.X.Scale, 2)
	end)
end




-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Fuel:Show(name: string)
	Anim.SlideTo(self.Frame_Root, self.defaultPosition, 0.5, false)
end

function Fuel:Hide(name: string)
	local target = UDim2.fromScale(self.defaultPosition.X.Scale, 2)
	Anim.SlideTo(self.Frame_Root, target, 0.5, true)
end



-- ███████╗███████╗████████╗    ████████╗ █████╗ ███╗   ██╗██╗  ██╗    ███╗   ██╗██╗   ██╗███╗   ███╗██████╗ ███████╗██████╗
-- ██╔════╝██╔════╝╚══██╔══╝    ╚══██╔══╝██╔══██╗████╗  ██║██║ ██╔╝    ████╗  ██║██║   ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗
-- ███████╗█████╗     ██║          ██║   ███████║██╔██╗ ██║█████╔╝     ██╔██╗ ██║██║   ██║██╔████╔██║██████╔╝█████╗  ██████╔╝
-- ╚════██║██╔══╝     ██║          ██║   ██╔══██║██║╚██╗██║██╔═██╗     ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══██╗██╔══╝  ██╔══██╗
-- ███████║███████╗   ██║          ██║   ██║  ██║██║ ╚████║██║  ██╗    ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗██║  ██║
-- ╚══════╝╚══════╝   ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝
--

function Fuel:SetTankNumber(number: number)
	-- Remove all the extra tanks
	for _, child in self.Frame_Body_Tanks:GetChildren() do
		if child:IsA("Frame") and child ~= self.Frame_Tank_Default then
			child:Destroy()
		end
	end

	-- Clone the default tank as many times as we need
	for i = 1, number do
		local tank       = self.Frame_Tank_Default: Clone()
		tank.Name        = "Tank_" .. i
		tank.LayoutOrder = i

		-- Ensure the tank level is max
		local Frame_TankLevel = tank:FindFirstChild("Level", true):: Frame
		Frame_TankLevel.Size = UDim2.fromScale(1, 1)
	end

	self.currentTank = number
	self.currentTankMax = number
end


function Fuel:UseNextTank()
	-- use next tank down
	if self.currentTank >= 1 then
		self.currentTank = self.currentTank - 1
	end

	-- mark the previous tank as used
	if self.currentTank < self.currentTankMax then
		local Frame_LastTank = self.Frame_Body_Tanks:FindFirstChild("Tank_" .. self.currentTank + 1, true):: Frame
		Frame_LastTank.Visible = false -- TODO: make this nicer. greyscal eit? add some background element to show it's gone?
	end
end



-- ███████╗███████╗████████╗    ████████╗ █████╗ ███╗   ██╗██╗  ██╗    ██╗     ███████╗██╗   ██╗███████╗██╗
-- ██╔════╝██╔════╝╚══██╔══╝    ╚══██╔══╝██╔══██╗████╗  ██║██║ ██╔╝    ██║     ██╔════╝██║   ██║██╔════╝██║
-- ███████╗█████╗     ██║          ██║   ███████║██╔██╗ ██║█████╔╝     ██║     █████╗  ██║   ██║█████╗  ██║
-- ╚════██║██╔══╝     ██║          ██║   ██╔══██║██║╚██╗██║██╔═██╗     ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║
-- ███████║███████╗   ██║          ██║   ██║  ██║██║ ╚████║██║  ██╗    ███████╗███████╗ ╚████╔╝ ███████╗███████╗
-- ╚══════╝╚══════╝   ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝
--

function Fuel:SetTankLevel(level: number)
	level = math.clamp(level or 1, 0, 1)

	local Frame_TankLevel = self.Frame_Body_Tanks:FindFirstChild("Tank_" .. self.currentTank, true):: Frame
	Frame_TankLevel.Size = UDim2.fromScale(1, level)
end



-- ███████╗███████╗████████╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗    ██╗     ███████╗██╗   ██╗███████╗██╗     
-- ██╔════╝██╔════╝╚══██╔══╝    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║    ██║     ██╔════╝██║   ██║██╔════╝██║     
-- ███████╗█████╗     ██║       ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║    ██║     █████╗  ██║   ██║█████╗  ██║     
-- ╚════██║██╔══╝     ██║       ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║    ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     
-- ███████║███████╗   ██║       ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║    ███████╗███████╗ ╚████╔╝ ███████╗███████╗
-- ╚══════╝╚══════╝   ╚═╝       ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝    ╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝
--

function Fuel:SetSystemLevel(level: number)
	self.Frame_System_Level.Size = UDim2.fromScale(level, 1)

	-- todo: add some logic here to colour the bar depending on the fuel level?

end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Fuel
