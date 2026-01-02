--!strict
print("ReplicatedFirst: Init")

-- Services
local Players           = game:GetService("Players")
local ReplicatedFirst   = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

-- Data
local VERSION           = require(ReplicatedFirst.Shared.VERSION)

-- Local vars
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Gui               = PlayerGui:WaitForChild("GUI")
Gui.Enabled             = true



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

-- UI: Version
task.spawn(function()
	local UI_Version = Gui:WaitForChild("Version", 5) :: ScreenGui
	if not UI_Version then
		warn("ReplicatedFirst: Couldn't find UI_Version")
		return
	else
		UI_Version.Enabled = true
	end

	local Txt_Version = UI_Version:WaitForChild("Txt_Version", 5)
	if not Txt_Version then
		warn("ReplicatedFirst: Couldn't find Txt_Version")
		return
	else
		Txt_Version.Text = VERSION
	end
end)

-- UI: Loading Spinner
task.spawn(function()
	local UI_Loading      = Gui:WaitForChild("Loading") :: ScreenGui
	if not UI_Loading then
		warn("ReplicatedFirst: Couldn't find UI_Loading")
		return
	else
		UI_Loading.Enabled = true
	end

	local Img_Loading     = UI_Loading:FindFirstChild("Img_Spinner", true) :: ImageLabel
	if not Img_Loading then
		warn("ReplicatedFirst: Couldn't find Img_Loading")
		return
	else
		-- Spin the loading icon
		RunService:BindToRenderStep("LoadingSpinner", 1, function(dt)
			Img_Loading.Rotation += dt * 180 -- Adjust spin speed here, degrees per second
		end)
	end
end)

-- No return, not a singleton
-- What next? See src/luau/client/init.client.luau