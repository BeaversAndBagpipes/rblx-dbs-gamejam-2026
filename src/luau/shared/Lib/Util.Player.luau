--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)

--[[
	Utils: Player

	Misc functions for handling players and their characters, cameras, etc

	Contents:
	- Camera controls - toggle between 1st/3rd person
--]]

-- Main
local Util = {}



--  ██████╗ █████╗ ███╗   ███╗███████╗██████╗  █████╗      ██████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ███████╗
-- ██╔════╝██╔══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗    ██╔════╝██║  ██║██╔══██╗████╗  ██║██╔════╝ ██╔════╝
-- ██║     ███████║██╔████╔██║█████╗  ██████╔╝███████║    ██║     ███████║███████║██╔██╗ ██║██║  ███╗█████╗  
-- ██║     ██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██║    ██║     ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══╝  
-- ╚██████╗██║  ██║██║ ╚═╝ ██║███████╗██║  ██║██║  ██║    ╚██████╗██║  ██║██║  ██║██║ ╚████║╚██████╔╝███████╗
--  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
--

---
-- Switches the player to first-person camera mode while keeping the mouse cursor enabled.\
-- This is achieved by creating a modal ScreenGui with an invisible button to force the cursor to remain visible.\
-- @param player Player -- The player whose camera mode will be changed.
--
function Util:SwitchToFirstPerson(player: Player)

	-- Ensure we can get the PlayerGui
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		warn("PlayerManager:SwitchToFirstPerson(): Couldn't find PlayerGui for player 💩")
		return
	end

	-- Create a new screenGui to house the Modal Button which will force the mouse cursor to become visible
	local screenGui        = Instance.new("ScreenGui", playerGui)
	screenGui.Name         = D_Attributes.UI_FirstPersonForce
	screenGui.ResetOnSpawn = false

	local btnInvisible                  = Instance.new("TextButton", screenGui) :: TextButton
	btnInvisible.Active                 = false
	btnInvisible.Interactable           = false
	btnInvisible.Modal                  = true
	btnInvisible.Size                   = UDim2.fromOffset(1, 1)
	btnInvisible.BackgroundTransparency = 1
	btnInvisible.Text                   = ""

	-- Change viewpoint and keep cursor enabled
	player.CameraMode                 = Enum.CameraMode.LockFirstPerson
	UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
end


---
-- Switches the player to third-person camera mode and removes any first-person forcing UI.\
-- Destroys the modal ScreenGui if present and resets the camera zoom distance after a short delay.\
-- @param player Player -- The player whose camera mode will be changed.
--
function Util:SwitchToThirdPerson(player: Player)
	-- Ensure we can get the PlayerGui
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		warn("PlayerManager:SwitchToThirdPerson(): Couldn't find PlayerGui for player 💩")
		return
	end

	-- Loop through all the playerGui ScreenGUIs and destroy them if they match the FirstpersonForce screen
	for _, screenGui: GuiObject in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and screenGui.Name == D_Attributes.UI_FirstPersonForce then
			screenGui:Destroy()
		end
	end

	-- Change viewpoint
	player.CameraMode            = Enum.CameraMode.Classic -- Allow third-person again
	player.CameraMinZoomDistance = 12

	task.spawn(function()
		task.wait(1)
		player.CameraMinZoomDistance = 0.5
	end)
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Util
