--!nocheck

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

-- Enums
--local GameState       = require(ReplicatedStorage.Shared.Enums.GameState)
--local PlayerState     = require(ReplicatedStorage.Shared.Enums.PlayerState)

--Modules
--local Settings        = require(ReplicatedStorage.Shared.Settings)
--local Util            = require(ReplicatedStorage.Shared.Lib.Util)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)

-- Singletons
--local _EventManager     = require(ReplicatedStorage.Shared.Modules.EventManager)

-- Local vars
local LocalPlayer       = Players.LocalPlayer :: Player
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
local Gui               = PlayerGui:WaitForChild("GUI"):WaitForChild("Message") :: ScreenGui



-- ████████╗██╗   ██╗██████╗ ███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
--    ██║      ██║   ██║     ███████╗
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝
--

export type T_Message = {
	ShowMessage: (
		self    : any,
		msgUpper: string?,
		msgLower: string?,
		duration: number?
	) -> nil,

	ShowCountdown: (
		self       : any,
		message    : string,
		duration   : number,
		endMessage : string,
		endDuration: number
	) -> nil
}



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local Message = {} :: T_Message



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function Message:Init(
	BE_OnMessage: BindableEvent,
	RE_OnMessage: RemoteEvent
)

	-- Get references to GameUI elements for later user
	self.Frame_Root    = Gui:WaitForChild("Frame_Root") :: Frame
	self.Frame_Content = self.Frame_Root:WaitForChild("Content") :: Frame

	-- Store default position
	self.Frame_Root:SetAttribute(D_Attributes.Default.Position, self.Frame_Root.Position)

	-- TextLabels
	self.Txt_Message_Upper = self.Frame_Content:FindFirstChild("10.Txt_Message_Upper") :: TextLabel
	self.Txt_Message_Lower = self.Frame_Content:FindFirstChild("20.Txt_Message_Lower") :: TextLabel

	-- Config timings
	self.showDuration = 0.4
	self.hideDuration = 0.4

	-- Config offsets
	self.slideInStartPos = UDim2.fromScale(-1.5, 0)
	self.slideOutEndPos  = UDim2.fromScale(1.5, 0)

	-- Hide self
	self:Hide(true)
	Gui.Enabled = true

	-- Bind to BindableEvent
	BE_OnMessage.Event:Connect(function(msgUpper, msgLower, duration)
		self:ShowMessage(msgUpper, msgLower, duration)
	end)

	-- Bind to RemoteEvent
	RE_OnMessage.OnClientEvent:Connect(function(msgUpper, msgLower, duration)
		self:ShowMessage(msgUpper, msgLower, duration)
	end)
end



-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function Message:Show(skipAnimation: boolean?): nil

	skipAnimation = skipAnimation or false
	print("Message:Show()", skipAnimation)

	if skipAnimation == true then
		self.Frame_Root.Visible = true
		return
	end

	-- Move to start pos
	local defaultPos         = self.Frame_Root: GetAttribute(D_Attributes.Default.Position)
	self.Frame_Root.Position = defaultPos + self.slideInStartPos
	self.Frame_Root.Visible  = true

	-- Create and play the tween
	local tweenInfo = TweenInfo.new(self.showDuration, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(self.Frame_Root, tweenInfo, {Position = defaultPos})
	tween:Play()

end

function Message:Hide(skipAnimation: boolean?): nil

	skipAnimation = skipAnimation or false
	print("Message:Hide()", skipAnimation)

	if skipAnimation == true then
		self.Frame_Root.Visible = false
	else
		-- Move to start pos
		local defaultPos = self.Frame_Root:GetAttribute(D_Attributes.Default.Position)
		local endPos = defaultPos + self.slideOutEndPos

		-- Create and play the tween
		local tweenInfo = TweenInfo.new(self.hideDuration, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local tween = TweenService:Create(self.Frame_Root, tweenInfo, {Position = endPos})
		tween.Completed:Connect(function()
			self.Frame_Root.Position = defaultPos
			self.Frame_Root.Visible  = false
		end)

		tween:Play()
	end
end



-- ███╗   ███╗███████╗███████╗███████╗ █████╗  ██████╗ ███████╗
-- ████╗ ████║██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝ ██╔════╝
-- ██╔████╔██║█████╗  ███████╗███████╗███████║██║  ███╗█████╗
-- ██║╚██╔╝██║██╔══╝  ╚════██║╚════██║██╔══██║██║   ██║██╔══╝
-- ██║ ╚═╝ ██║███████╗███████║███████║██║  ██║╚██████╔╝███████╗
-- ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
--

function Message:ShowMessage(
	msgUpper: string?,
	msgLower: string?,
	duration: number?
): nil
	print("Message:ShowMessage:", msgUpper, msgLower, duration)

	duration = duration or 3
	msgUpper = msgUpper or ""
	msgLower = msgLower or ""

	-- Set the UI text labels and their visiblity
	self.Txt_Message_Upper.Text    = msgUpper
	self.Txt_Message_Upper.Visible = msgUpper ~= ""

	self.Txt_Message_Lower.Text    = msgLower
	self.Txt_Message_Lower.Visible = msgLower ~= ""

	-- Set parent element visible
	if not self.Frame_Root.Visible then
		self:Show()
		task.wait(self.showDuration)
	end

	-- Wait the duration
	task.wait(duration)

	-- Only hide the message if the current message value is the one we displayed, otherwise a new message has been displayed and we don't want to overwrite that
	if self.Txt_Message_Upper.Text == msgUpper and self.Txt_Message_Lower.Text == msgLower then
		self:Hide()
	end
end



--  ██████╗ ██████╗ ██╗   ██╗███╗   ██╗████████╗██████╗  ██████╗ ██╗    ██╗███╗   ██╗
-- ██╔════╝██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗██║    ██║████╗  ██║
-- ██║     ██║   ██║██║   ██║██╔██╗ ██║   ██║   ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║
-- ██║     ██║   ██║██║   ██║██║╚██╗██║   ██║   ██║  ██║██║   ██║██║███╗██║██║╚██╗██║
-- ╚██████╗╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║
--  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝
--

function Message:ShowCountdown(
	message    : string,
	duration   : number?,
	endMessage : string?,
	endDuration: number?
): nil

	message     = message      or  "No message"
	duration    = duration     or  3
	endMessage  = endMessage   or  nil
	endDuration = endDuration  or  3

	print("Message:ShowCountdown:", message, duration, endMessage, endDuration)

	self:Show()

	-- Set the UI text labels
	self.Txt_Message_Upper.Text = message
	self.Txt_Message_Lower.Text = duration

	-- Countdown through the sequence
	for i = duration, 1, -1 do
		--self:Show()
		self.Txt_Message_Lower.Text = i
		task.wait(1)

		-- check we're still showing the same upper message
		-- if we're not this means another message was broadcast, so we should dip out
		if self.Txt_Message_Upper.Text ~= message then
			print("Message:ShowCountdown(), Txt_Message_Upper ~= message, aborting")
			return
		end
	end

	-- Optionally show an ending message
	if endMessage and endMessage ~= "" then
		self:ShowMessage(endMessage, nil, endDuration)
	else
		-- Hide the parent
		self:Hide()
	end

end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Message :: T_Message
