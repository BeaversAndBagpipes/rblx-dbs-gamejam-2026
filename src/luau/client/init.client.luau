--!strict

print("init.client.lua: Starting")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Singletons
-- Event system comes first
local _EventManager     = require(ReplicatedStorage.Shared.Modules.EventManager)

-- Singletons: Non-Gui
local _HapticHandler    = require(ReplicatedStorage.ClientStorage.Modules.HapticHandler)
local _SoundHandler     = require(ReplicatedStorage.ClientStorage.Modules.SoundHandler)

-- Singletons: GUI Generic
local _ParticleManager  = require(ReplicatedStorage.ClientStorage.Modules.ParticleManager)
local _WindowManager    = require(ReplicatedStorage.ClientStorage.Modules.WindowManager)


-- Wait until everything have finished loading before firing events
task.spawn(function()


	-- Wait until IsLoaded
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	print("init.client.luau: game:IsLoaded()")

	-- Wait for _EventManager to finish loading
	_EventManager:Init()
	while not _EventManager.IsLoaded do
		task.wait(0.1)
		print("ReplicatedFirst: Waiting for _EventManager to load")
	end
	print("init.client.luau: _EventManager.IsLoaded")


	-- Call Init on our various singletons
	_HapticHandler:Init({
		BE_TriggerHaptic = _EventManager.Instances.BindableEvent.TriggerHaptic,
		RE_TriggerHaptic = _EventManager.Instances.RemoteEvent.TriggerHaptic
	})

	_ParticleManager:Init()

	_SoundHandler:Init({
		BE_TriggerSound = _EventManager.Instances.BindableEvent.TriggerSound,
		RE_TriggerSound = _EventManager.Instances.RemoteEvent.TriggerSound
	})

	_WindowManager:Init({
		BE_HideWindow     = _EventManager.Instances.BindableEvent.HideWindow,
		BE_OnClientLoad   = _EventManager.Instances.BindableEvent.OnClientLoad,
		BE_ShowWindow     = _EventManager.Instances.BindableEvent.ShowWindow,
		BE_TriggerMessage = _EventManager.Instances.BindableEvent.TriggerMessage,
		RE_TriggerMessage = _EventManager.Instances.RemoteEvent.TriggerMessage,
		HapticHandler     = _HapticHandler,
		ParticleManager   = _ParticleManager,
		SoundHandler      = _SoundHandler
	})

	-- Fire Event
	_EventManager.Instances.BindableEvent.OnClientLoad:Fire()

	-- Finish
	print("init.client.lua: Complete")
end)
