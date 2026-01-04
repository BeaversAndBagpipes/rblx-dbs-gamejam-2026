--!strict

print("init.server.luau: Starting")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

-- Singletons
local _EventManager  = require(ReplicatedStorage.Shared.Modules.EventManager)
local _PlayerManager = require(ServerStorage.Modules.PlayerManager)

-- DBS Jam singletons
local _UpgradeManager     = require(ServerStorage.Modules.UpgradeManager)
local _ServerRaceManager = require(ServerStorage.Modules.ServerRaceManager)


-- Init
_EventManager:Init()
_PlayerManager:Init()
_UpgradeManager:Init({
    RequestUpgrade = _EventManager.Instances.RemoteEvent.RequestUpgrade
})

_ServerRaceManager:Init({
    RequestRaceStart = _EventManager.Instances.RemoteEvent.RequestRaceStart,
	
})


-- Return
print("init.server.luau: Complete")
