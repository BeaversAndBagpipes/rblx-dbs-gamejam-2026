--!strict

-- Services
local Players                  = game:GetService("Players")
local ReplicatedStorage        = game:GetService("ReplicatedStorage")
local TweenService             = game:GetService("TweenService")
local Workspace                = game:GetService("Workspace")
local StarterPlayer            = game:GetService("StarterPlayer")

-- Types
local T_HapticHandler          = require(ReplicatedStorage.ClientStorage.Types.HapticHandler)
local T_ParticleManager        = require(ReplicatedStorage.ClientStorage.Types.ParticleManager)
local T_SoundHandler           = require(ReplicatedStorage.ClientStorage.Types.SoundHandler)
local T_WindowManager          = require(ReplicatedStorage.ClientStorage.Types.WindowManager)

-- Data
local D_Attributes             = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Sfx                    = require(ReplicatedStorage.Shared.Data.Sfx)

-- Enums
--local E_PLAYERSTATE            = require(ReplicatedStorage.Shared.Enums.PlayerState)

--Modules
local Settings                 = require(ReplicatedStorage.Shared.Settings)
local Util                     = require(ReplicatedStorage.Shared.Lib.Util)

-- Local vars
local LocalPlayer              = Players.LocalPlayer :: Player
local PlayerGui                = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local Gui                      = PlayerGui:WaitForChild("GUI"):WaitForChild("Settings") :: ScreenGui

-- Singletons
local _WindowManager  : T_WindowManager.WindowManager
local _HapticHandler  : T_HapticHandler.HapticHandler
local _SoundHandler   : T_SoundHandler.SoundHandler
local _ParticleManager: T_ParticleManager.ParticleManager



-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_PlayerPrefs = {
	Init:   (
		self           : T_PlayerPrefs,
		WindowManager  : T_WindowManager.WindowManager,
		HapticHandler  : T_HapticHandler.HapticHandler,
		SoundHandler   : T_SoundHandler.SoundHandler,
		ParticleManager: T_ParticleManager.ParticleManager
		) -> nil,
	Toggle: (self: T_PlayerPrefs) -> nil,
	Show  : (self: T_PlayerPrefs) -> nil,
	Hide  : (self: T_PlayerPrefs) -> nil
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local PlayerPrefs = {} :: T_PlayerPrefs



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--
function PlayerPrefs:Init(
	WindowManager  : T_WindowManager.WindowManager,
	HapticHandler  : T_HapticHandler.HapticHandler,
	SoundHandler   : T_SoundHandler.SoundHandler,
	ParticleManager: T_ParticleManager.ParticleManager
)

	_HapticHandler   = HapticHandler
	_ParticleManager = ParticleManager
	_SoundHandler    = SoundHandler
	_WindowManager   = WindowManager

	-- Enable
	Gui.Enabled = true

	-- Get references to the various GUI elements
	self.Frame_Root   = Gui:WaitForChild("Frame_Root") :: Frame
	self.Frame_Button = Gui:WaitForChild("Frame_Button") :: Frame
	self.Frame_Root.Visible = false

	-- Toggle Button
	self.Btn_Toggle = self.Frame_Button:FindFirstChild("Btn_Toggle", true) :: GuiButton
	self.Btn_Toggle.MouseButton1Click:Connect(function()
		if self.Frame_Root.Visible then
			_SoundHandler:TriggerSound(D_Sfx.Button_Close)
		else
			_SoundHandler:TriggerSound(D_Sfx.Button_Generic)
		end
		_HapticHandler:TriggerHaptic(Enum.HapticEffectType.UIClick)
		self:Toggle()
	end)

	-- Close Button
	self.Btn_Close  = self.Frame_Root:FindFirstChild("Btn_Close", true) :: GuiButton
	self.Btn_Close.MouseButton1Click:Connect(function()
		self:Hide(self.Frame_Root)
		_SoundHandler:TriggerSound(D_Sfx.Button_Close)
		_HapticHandler:TriggerHaptic(Enum.HapticEffectType.UIClick)
	end)

	-- Setup the player pref toggle inputs
	self:SetupToggles()

	-- Add hover animations for dev tags
	self.Txt_stom = self.Frame_Root:FindFirstChild("10.name.stom", true) :: TextLabel
	self.Txt_stom.MouseEnter:Connect(function()
		_ParticleManager:CBBurst(self.Txt_stom)
	end)
end

function PlayerPrefs:SetupToggles()
	for _, child in ipairs(Gui:GetDescendants()) do
		if child:GetAttribute(D_Attributes.PlayerPrefs.ToggleBtnPref) ~= nil then
			-- Found a button

			-- Bind it to the Toggle function
			child.MouseButton1Click:Connect(function()
				self:OnToggleClick(child)
			end)

			-- Set it's initial state
			local attr  = child:GetAttribute(D_Attributes.PlayerPrefs.ToggleBtnPref)
			local state = LocalPlayer:GetAttribute(attr) or true
			self:SetToggleState(child, state)
		end
	end
end




--  ██████╗ ███╗   ██╗    ████████╗ ██████╗  ██████╗  ██████╗ ██╗     ███████╗
-- ██╔═══██╗████╗  ██║    ╚══██╔══╝██╔═══██╗██╔════╝ ██╔════╝ ██║     ██╔════╝
-- ██║   ██║██╔██╗ ██║       ██║   ██║   ██║██║  ███╗██║  ███╗██║     █████╗  
-- ██║   ██║██║╚██╗██║       ██║   ██║   ██║██║   ██║██║   ██║██║     ██╔══╝  
-- ╚██████╔╝██║ ╚████║       ██║   ╚██████╔╝╚██████╔╝╚██████╔╝███████╗███████╗
--  ╚═════╝ ╚═╝  ╚═══╝       ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
--

function PlayerPrefs:OnToggleClick(btn: GuiButton)
	local prefAttributeName = btn:GetAttribute(D_Attributes.PlayerPrefs.ToggleBtnPref) --read the name of the preference we're toggling

	if not prefAttributeName then
		warn("PlayerPrefs:onToggleClick(): Couldn't find attribute on btn:", D_Attributes.PlayerPrefs.ToggleBtnPref, btn)
		return
	end

	-- Toggle the saved state
	local currentState = LocalPlayer:GetAttribute(prefAttributeName)
	if currentState == nil then currentState = true end

	local newState = not currentState
	LocalPlayer:SetAttribute(prefAttributeName, newState)

	self:SetToggleState(btn, newState)

	-- Buzz
	_HapticHandler:TriggerHaptic(Enum.HapticEffectType.UIClick)
end


function PlayerPrefs:SetToggleState(btn: GuiButton, state: boolean)

	task.spawn(function()

		local icon               = btn.Parent:FindFirstChild("ToggleIconEnabled", true)
		local value              = state and 1 or 0
		local disabledBackground = btn.Parent:FindFirstChild("BackgroundDisabled", true)
		local disabledIcon       = btn.Parent:FindFirstChild("ToggleIconDisabled", true)

		local tweeninfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenIcon = TweenService:Create(icon, tweeninfo, {
			AnchorPoint    = Vector2.new(value, 0.5),
			Position       = UDim2.fromScale(value, 0.5)
		})
		tweenIcon:Play()

		local tweenDisabledIcon = TweenService:Create(disabledIcon, tweeninfo, { ImageTransparency = value})
		tweenDisabledIcon:Play()

		local tweenDisabledBackground = TweenService:Create(disabledBackground, tweeninfo, { ImageTransparency = value})
		tweenDisabledBackground:Play()

	end)
end



-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function PlayerPrefs:Toggle()
	print("PlayerPrefs:Toggle()")

	if self.Frame_Root.Visible then
		self:Hide()
	else
		self:Show()
	end
end

function PlayerPrefs:Show()
	print("PlayerPrefs:Show()")
	_WindowManager:AddToQueue(self.Frame_Root, true)
end

function PlayerPrefs:Hide()
	print("PlayerPrefs:Hide()")
	_WindowManager:RemoveFromQueue(self.Frame_Root)
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return PlayerPrefs :: T_PlayerPrefs
