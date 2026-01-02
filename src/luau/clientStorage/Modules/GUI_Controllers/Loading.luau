--!strict

-- Services
local Players              = game:GetService("Players")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local RunService           = game:GetService("RunService")

--Modules
local Anim                 = require(ReplicatedStorage.Shared.Lib["Anim.GUI"])

-- Local vars
local LocalPlayer          = Players.LocalPlayer :: Player
local PlayerGui            = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local Gui                  = PlayerGui:WaitForChild("GUI"):WaitForChild("Loading") :: ScreenGui



-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_Loading = {
	Init: (
		self: T_Loading,
		BE_OnClientLoad: BindableEvent
	) -> nil,

	Show: (
		self: T_Loading
	) -> nil,

	Hide: (
		self: T_Loading
	) -> nil,
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Loading = {} :: T_Loading


-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function Loading:Init(
	BE_OnClientLoad: BindableEvent
)
	print("Loading.luau: Init()")

	-- Get references to GameUI elements for later use:
	self.Frame_Background = Gui:WaitForChild("Background") :: Frame
	self.Frame_Content    = Gui:FindFirstChild("Content")  :: Frame
	self.Img_Spinner      = self.Frame_Content:FindFirstChild("Img_Spinner", true) :: ImageLabel

	-- BE_OnClientLoad: Triggered by the init.client.luau when loading has finished
	BE_OnClientLoad.Event:Connect(function()
		print("Loading: BE_OnClientLoad")
		self:Hide()
	end)
end



--  █████╗ ███╗   ██╗██╗███╗   ███╗ █████╗ ████████╗███████╗    ███████╗██╗     ███████╗███╗   ███╗███████╗███╗   ██╗████████╗███████╗
-- ██╔══██╗████╗  ██║██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝    ██╔════╝██║     ██╔════╝████╗ ████║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
-- ███████║██╔██╗ ██║██║██╔████╔██║███████║   ██║   █████╗      █████╗  ██║     █████╗  ██╔████╔██║█████╗  ██╔██╗ ██║   ██║   ███████╗
-- ██╔══██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝      ██╔══╝  ██║     ██╔══╝  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   ╚════██║
-- ██║  ██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗    ███████╗███████╗███████╗██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   ███████║
-- ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
--

function Loading:AnimateElements()
	print("Loading:AnimateElements()")

	RunService:UnbindFromRenderStep("RS_Loading")
	RunService:BindToRenderStep("RS_Loading", Enum.RenderPriority.Last.Value, function(dt: number)
		-- Pulse the Logo
		-- local pulseFreq     = 2
		-- local scale         = 0.95
		-- local progress      = math.abs((tick() % pulseFreq) / pulseFreq * 2 - 1) -- 1 -> 0 -> 1
		-- local easedProgress = TweenService:GetValue(progress, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)
		-- self.Img_Logo_Scale.Scale = 1 - (easedProgress * (1 - scale))

		-- Spin the spinner
		self.Img_Spinner.Rotation += dt * 180
	end)
end



-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Loading:Show()
	print("Loading:Show")

	-- Ensure ScreenGUI is enabled
	Gui.Enabled = true

	-- Setup the ReenderStepped animations
	self:AnimateElements()

	-- Show the carious UI elements
	Anim.FadeIn(self.Frame_Background, 0.3)
	Anim.SlideTo(self.Frame_Content, UDim2.fromScale(0.5, 0.5), 0.5, false)
end

function Loading:Hide()
	print("Loading:Hide")

	-- Hide the various UI elements
	Anim.SlideTo(self.Frame_Content, UDim2.fromScale(0.5, 4), 0.5)
	Anim.FadeOut(self.Frame_Background)

	-- Disable GUI once animations are complete
	task.wait(1)
	Gui.Enabled = false

	-- Disable animations
	RunService:UnbindFromRenderStep("RS_Loading")
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--


return Loading :: T_Loading
