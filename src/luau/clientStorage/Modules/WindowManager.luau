--!strict

-- Services
local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Types
local T_HapticHandler   = require(ReplicatedStorage.ClientStorage.Types.HapticHandler)
local T_ParticleManager = require(ReplicatedStorage.ClientStorage.Types.ParticleManager)
local T_SoundHandler    = require(ReplicatedStorage.ClientStorage.Types.SoundHandler)
local T_WindowManager   = require(ReplicatedStorage.ClientStorage.Types.WindowManager)

-- Singletons
--local _EventManager     = require(ReplicatedStorage.Shared.Modules.EventManager)

-- Singletons: Specific GUI Controllers
local _UI_Loading       = require(ReplicatedStorage.ClientStorage.Modules.GUI_Controllers.Loading)
local _UI_Message       = require(ReplicatedStorage.ClientStorage.Modules.GUI_Controllers.Message)
local _UI_PlayerPrefs   = require(ReplicatedStorage.ClientStorage.Modules.GUI_Controllers.PlayerPrefs)

-- Modules
local Anim              = require(ReplicatedStorage.Shared.Lib["Anim.GUI"])



--[[
	WindowManager

	This is a service for showing/hiding windows in a stack, so they won't overlap each other.

	You can call it as a singleton directly and trigger the methods on it:

		_WindowManager:AddToQueue(guiObject: guiObject, forceToFront: boolean)
		_WindowManager:RemoveFromQueue(guiObject: guiObject)

	Or, call it via a BindableEvent:

		local BE_ShowWindow = _EventManager.Instances.BindableEvent.ShowWindow
		BE_ShowWindow:Fire(guiObject: guiObject, forceToFront: boolean)

		local BE_HideWindow = _EventManager.Instances.BindableEvent.HideWindow
		BE_HideWindow:Fire(guiObject: guiObject)
]]


-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local WindowManager = {}



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

type InitConfig = {
	BE_HideWindow    : BindableEvent,
	BE_OnClientLoad  : BindableEvent,
	BE_ShowWindow    : BindableEvent,
	BE_TriggerMessage: BindableEvent,
	RE_TriggerMessage: RemoteEvent,
	HapticHandler    : T_HapticHandler.HapticHandler,
	ParticleManager  : T_ParticleManager.ParticleManager,
	SoundHandler     : T_SoundHandler.SoundHandler
}

function WindowManager:Init(config: InitConfig)

	self.Active = nil
	self.Queue = {}

	self.ShowDuration = 0.35
	self.HideDuration = 0.2

	self.AnimationInProgress = false

	if config.BE_ShowWindow then
		config.BE_ShowWindow.Event:Connect(function(guiObject: GuiObject, forceToFront: boolean)
			self:AddToQueue(guiObject, forceToFront)
		end)
	end

	if config.BE_HideWindow then 
		config.BE_HideWindow.Event:Connect(function(guiObject: GuiObject)
			self:RemoveFromQueue(guiObject)
		end)
	end

	-- Init the specific GUI controllers

	-- UI_Loading
	assert(config.BE_OnClientLoad, "BE_OnClientLoad not provided")
	_UI_Loading:Init(config.BE_OnClientLoad)

	-- UI_Message
	assert(config.BE_TriggerMessage, "BE_TriggerMessage not provided")
	assert(config.RE_TriggerMessage, "RE_TriggerMessage not provided")
	_UI_Message:Init(config.BE_TriggerMessage, config.RE_TriggerMessage)

	-- UI_PlayerPrefs
	assert(config.HapticHandler, "HapticHandler not provided")
	assert(config.SoundHandler, "SoundHandler not provided")
	assert(config.ParticleManager, "ParticleManager not provided")

	_UI_PlayerPrefs:Init(self, config.HapticHandler, config.SoundHandler, config.ParticleManager)

end



-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ██╗██╗  ██╗██╗██████╗ ███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║   ██╔╝██║  ██║██║██╔══██╗██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║  ██╔╝ ███████║██║██║  ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║ ██╔╝  ██╔══██║██║██║  ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝██╔╝   ██║  ██║██║██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝    ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
--

function WindowManager:Show(frame: Frame)
	-- Wait for any existing animations to finish
	while self.AnimationInProgress do
		task.wait(0.05)
	end
	self.AnimationInProgress = true

	-- Ensure we've got a valid frame
	if not frame or not frame:IsA("GuiObject") then
		warn("WindowManager:Show():", frame, "frame was nil or invalid guiObject")
		return
	end

	print("WindowManager:Show()", frame.Name, frame)

	-- Get the ScreenGui and ensure it's active
	local rootGui = self:GetRootScreenGui(frame):: ScreenGui
	if not rootGui then
		warn("WindowManager:Show():", frame, "Couldn't find root ScreenGui for frame")
		return
	end

	rootGui.Enabled = true
	Anim.ScaleIn(frame, self.ShowDuration)

	-- Reset animation flag on finish
	task.wait(self.ShowDuration)
	self.AnimationInProgress = false
end


function WindowManager:Hide(frame: Frame)
	print("WindowManager:Hide()", frame.Name, frame)

	if not frame then
		warn("WindowManager:Hide():", frame, "No frame provided")
		return
	end

	Anim.ScaleOut(frame, self.HideDuration)
end



--  █████╗ ██████╗ ██████╗     ████████╗ ██████╗      ██████╗ ██╗   ██╗███████╗██╗   ██╗███████╗
-- ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██╔═══██╗    ██╔═══██╗██║   ██║██╔════╝██║   ██║██╔════╝
-- ███████║██║  ██║██║  ██║       ██║   ██║   ██║    ██║   ██║██║   ██║█████╗  ██║   ██║█████╗  
-- ██╔══██║██║  ██║██║  ██║       ██║   ██║   ██║    ██║▄▄ ██║██║   ██║██╔══╝  ██║   ██║██╔══╝  
-- ██║  ██║██████╔╝██████╔╝       ██║   ╚██████╔╝    ╚██████╔╝╚██████╔╝███████╗╚██████╔╝███████╗
-- ╚═╝  ╚═╝╚═════╝ ╚═════╝        ╚═╝    ╚═════╝      ╚══▀▀═╝  ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝
--

function WindowManager:AddToQueue(guiObject: GuiObject, forceToFront: boolean)

	print("WindowManager:AddToQueue(): guiObject, override, self.Queue:", guiObject, forceToFront, self.Queue)


	-- Do we need to jump to the front of the queue?
	if forceToFront then
		if self.Active then
			print("WindowManager:AddToQueue(): overriding Active window")
			table.insert(self.Queue, 1, self.Active)
			self:Hide(self.Active)
			self.Active = nil
		end

		table.insert(self.Queue, 1, guiObject)
	else
		-- ignore if it already exists
		for _, v in pairs(self.Queue) do
			if v == guiObject then
				print("WindowManager:AddToQueue(): already in queue, ignoring")
				return
			end
		end

		print("WindowManager:AddToQueue(): adding to queue at position", #self.Queue + 1)
		table.insert(self.Queue, guiObject)
	end

	if not self.Active then
		if self.Queue[1] then
			print("WindowManager:AddToQueue(): no window currently active, triggering ShowNextInQueue")
			self:ShowNextInQueue()
		end
	end
end



-- ███████╗██╗  ██╗ ██████╗ ██╗    ██╗    ███╗   ██╗███████╗██╗  ██╗████████╗    ██╗███╗   ██╗     ██████╗ ██╗   ██╗███████╗██╗   ██╗███████╗
-- ██╔════╝██║  ██║██╔═══██╗██║    ██║    ████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝    ██║████╗  ██║    ██╔═══██╗██║   ██║██╔════╝██║   ██║██╔════╝
-- ███████╗███████║██║   ██║██║ █╗ ██║    ██╔██╗ ██║█████╗   ╚███╔╝    ██║       ██║██╔██╗ ██║    ██║   ██║██║   ██║█████╗  ██║   ██║█████╗  
-- ╚════██║██╔══██║██║   ██║██║███╗██║    ██║╚██╗██║██╔══╝   ██╔██╗    ██║       ██║██║╚██╗██║    ██║▄▄ ██║██║   ██║██╔══╝  ██║   ██║██╔══╝  
-- ███████║██║  ██║╚██████╔╝╚███╔███╔╝    ██║ ╚████║███████╗██╔╝ ██╗   ██║       ██║██║ ╚████║    ╚██████╔╝╚██████╔╝███████╗╚██████╔╝███████╗
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝     ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝╚═╝  ╚═══╝     ╚══▀▀═╝  ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝
--

function WindowManager:ShowNextInQueue()
	print("WindowManager:ShowNextInQueue()")

	-- Remove the active window, if there is one
	if self.Active then
		self:Hide(self.Active)
		self.Active = nil
		print("WindowManager:ShowNextInQueue(): removing self.Active")
	end

	-- Check for the next window to show
	if not self.Queue[1] then
		print("WindowManager:ShowNextInQueue(): self.Queue is empty, ignoring")
		return
	end

	-- Assign next window as active
	self.Active = table.remove(self.Queue, 1)
	self:Show(self.Active)
end



-- ██████╗ ███████╗███╗   ███╗ ██████╗ ██╗   ██╗███████╗    ███████╗██████╗  ██████╗ ███╗   ███╗     ██████╗ ██╗   ██╗███████╗██╗   ██╗███████╗
-- ██╔══██╗██╔════╝████╗ ████║██╔═══██╗██║   ██║██╔════╝    ██╔════╝██╔══██╗██╔═══██╗████╗ ████║    ██╔═══██╗██║   ██║██╔════╝██║   ██║██╔════╝
-- ██████╔╝█████╗  ██╔████╔██║██║   ██║██║   ██║█████╗      █████╗  ██████╔╝██║   ██║██╔████╔██║    ██║   ██║██║   ██║█████╗  ██║   ██║█████╗  
-- ██╔══██╗██╔══╝  ██║╚██╔╝██║██║   ██║╚██╗ ██╔╝██╔══╝      ██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║    ██║▄▄ ██║██║   ██║██╔══╝  ██║   ██║██╔══╝  
-- ██║  ██║███████╗██║ ╚═╝ ██║╚██████╔╝ ╚████╔╝ ███████╗    ██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║    ╚██████╔╝╚██████╔╝███████╗╚██████╔╝███████╗
-- ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝     ╚══▀▀═╝  ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝
--

function WindowManager:RemoveFromQueue(guiObject: GuiObject)

	print("WindowManager:RemoveFromQueue()", guiObject)

	-- Remove all instances from the queue (there might be multiple?)
	for k, v in pairs(self.Queue) do
		if v == guiObject then
			print("WindowManager:RemoveFromQueue(): removed from Queue position", k)
			table.remove(self.Queue, k)
		end
	end

	-- If it was the active object, tidy up and move to the next one
	if self.Active == guiObject then
		self:Hide(guiObject)
		print("WindowManager:RemoveFromQueue(): is Active, removing")
		self.Active = nil
		self:ShowNextInQueue()

	-- If it isn't active, but is visible, then just hide it
	else
		if guiObject.Visible then
			guiObject.Visible = false
		end
	end

end



-- ██╗   ██╗████████╗██╗██╗
-- ██║   ██║╚══██╔══╝██║██║
-- ██║   ██║   ██║   ██║██║
-- ██║   ██║   ██║   ██║██║
-- ╚██████╔╝   ██║   ██║███████╗
--  ╚═════╝    ╚═╝   ╚═╝╚══════╝
--

function WindowManager:GetRootScreenGui(guiObject: GuiObject): ScreenGui?
	if not guiObject or not guiObject.Parent then
		return nil
	end

	if guiObject.Parent:IsA("ScreenGui") then
		return guiObject.Parent
	else
		return self:GetRootScreenGui(guiObject.Parent)
	end
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

-- Create and return Singleton
return WindowManager :: T_WindowManager.WindowManager
