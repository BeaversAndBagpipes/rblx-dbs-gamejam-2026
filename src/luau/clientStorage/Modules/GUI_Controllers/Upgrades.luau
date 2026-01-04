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
local Gui               = PlayerGui:WaitForChild("GUI"):WaitForChild("UI_Upgrade") :: ScreenGui

local MetaParts         = Workspace:FindFirstChild("MetaParts", true) :: Folder



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Upgrades = {}


-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

type InitConfig = {
	WindowManager  : T_WindowManager.WindowManager,
	BE_TriggerSound: BindableEvent
}

function Upgrades:Init(config: InitConfig)

	assert(config.BE_TriggerSound, "BE_TriggerSound not provided")
	self.BE_TriggerSound = config.BE_TriggerSound

	assert(config.RE_RequestUpgrade, "RE_RequestUpgrade not provided")
	self.RE_RequestUpgrade = config.RE_RequestUpgrade

	assert(config.WindowManager, "WindowManager not provided")
	self.WindowManager = config.WindowManager

	Gui.Enabled = true

	self.triggerDistance = 10

	-- Get references to GameUI elements for later user
	self.Frame_Root      = Gui:FindFirstChild("Frame_Root"):: Frame -- Root frame
	self.Frame_Root.Visible = false

	self.Text_Title            = Gui:FindFirstChild("Text_Title", true):: Frame -- Main window title
	self.Frame_Grid            = Gui:FindFirstChild("Frame_Grid", true):: Frame -- Grid of upgrade buttons
	self.Frame_Default         = self.Frame_Grid:FindFirstChild("Frame_Default", true):: Frame -- Default frame
	self.Frame_Default.Visible = false

	self.currentView = ""

	-- Create the zones
	self.Zones = {}
	for _, name in pairs(D_Attributes.VehicleParts) do
		local folder = MetaParts:FindFirstChild("Upgrade_" .. name, true) :: Folder
		print("Creating zone:", name, folder)
		self.Zones[name] = Zone.new(folder)
		for _, child in folder:GetChildren() do
			if child:IsA("BasePart") then
				child.Transparency = 1
			end
		end
	end
	-- Connect the zones to the player entered event
	for name, zone in pairs(self.Zones) do
		zone.playerEntered:Connect(function(player)
			print("Zone entered:", name)
			self:Show(name)
		end)
		zone.playerExited:Connect(function(player)
			print("Zone exited:", name)
			self:Hide(name)
		end)
	end

	-- Watch players level attributes for changes
	for name, _ in pairs(self.Zones) do
		LocalPlayer:GetAttributeChangedSignal(D_Attributes.PlayerData["Level_"..name]):Connect(function()
			self:UpdateView()
		end)
	end
end




-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Upgrades:Show(name: string)
	print("Upgrades:Show()")
	if self.currentView ~= "" then
		-- another window is visible, hide it
		self:Hide(self.currentView)
		task.wait(0.1)
	end

	self:UpdateView(name)
	self.currentView = name
	self.WindowManager:AddToQueue(self.Frame_Root)
end

function Upgrades:Hide(name: string)
	print("Upgrades:Hide()")
	if self.currentView ~= name then
		return
	end
	self.WindowManager:RemoveFromQueue(self.Frame_Root)
	self.currentView = ""
end


-- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗██╗   ██╗██╗███████╗██╗    ██╗
-- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║   ██║██║██╔════╝██║    ██║
-- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗  ██║   ██║██║█████╗  ██║ █╗ ██║
-- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝  ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║
-- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗ ╚████╔╝ ██║███████╗╚███╔███╔╝
--  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝  ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝
--

function Upgrades:UpdateView(name: string)
	if not name then name = self.currentView end
	if name == "" then return end

	self.Text_Title.Text = "Upgrade " .. name

	-- Clear the current frames in the grid
	for _, child in self.Frame_Grid:GetChildren() do
		if child:IsA("Frame") and child ~= self.Frame_Default then
			child:Destroy()
		end
	end

	-- Get the players current level of the upgrade
	local currentLevel = LocalPlayer:GetAttribute(D_Attributes.PlayerData["Level_"..name]) or 1
	print("Current level of", name, "is", currentLevel)

	-- Create the new frames
	for index, level in ipairs(D_Levels[name]) do
		local frame = self.Frame_Default:Clone()
		frame.Name = "Frame_" .. level.name
		frame.Parent = self.Frame_Grid
		frame.Visible = true


		local isOwned = currentLevel >= index
		print("Is", name, "level", index, "owned?", isOwned)

		local img_icon = frame:FindFirstChild("Img_Preview", true):: ImageLabel
		img_icon.Image = level.icon

		local Text_Name = frame:FindFirstChild("Text_Name", true):: TextLabel
		Text_Name.Text = level.name

		local Text_Price = frame:FindFirstChild("Text_Price", true):: TextLabel
		Text_Price.Text = level.cost
		if isOwned then
			Text_Price.Text = "Owned!"
		end

		local Img_Background = frame:FindFirstChild("BG_Hover", true):: ImageLabel
		Img_Background.Visible = false

		frame.MouseEnter:Connect(function()
			Img_Background.Visible = true
			Anim.FadeIn(Img_Background)
		end)
		frame.MouseLeave:Connect(function()
			Anim.FadeOut(Img_Background)
		end)

		local Btn_Purchase = frame:FindFirstChild("Btn_Purchase", true):: TextButton
		Btn_Purchase.MouseButton1Click:Connect(function()
			self:Purchase(name, index)
		end)
	end
end


-- ██████╗ ██╗   ██╗██████╗  ██████╗██╗  ██╗ █████╗ ███████╗███████╗
-- ██╔══██╗██║   ██║██╔══██╗██╔════╝██║  ██║██╔══██╗██╔════╝██╔════╝
-- ██████╔╝██║   ██║██████╔╝██║     ███████║███████║███████╗█████╗  
-- ██╔═══╝ ██║   ██║██╔══██╗██║     ██╔══██║██╔══██║╚════██║██╔══╝  
-- ██║     ╚██████╔╝██║  ██║╚██████╗██║  ██║██║  ██║███████║███████╗
-- ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝
--

function Upgrades:Purchase(name: string, index: number)

	local currentLevel = LocalPlayer:GetAttribute(D_Attributes.PlayerData["Level_"..name]) or 1
	local isOwned      = currentLevel >= index
	local level        = D_Levels[name][index]

	if isOwned or LocalPlayer:GetAttribute(D_Attributes.PlayerData.Coins) < level.cost then
		-- Player can't purchase this
		self.BE_TriggerSound:Fire(D_Sfx.Generic_Error)
		return
	else
		self.BE_TriggerSound:Fire(D_Sfx.Upgrade)
		self.RE_RequestUpgrade:FireServer({name = name, level = index})
		return
	end
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Upgrades
