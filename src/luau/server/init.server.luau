--!strict

print("init.server.luau: Starting")

-- Services
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local ServerStorage      = game:GetService("ServerStorage")

-- Singletons
local _EventManager      = require(ReplicatedStorage.Shared.Modules.EventManager)
local _PlayerManager     = require(ServerStorage.Modules.PlayerManager)

-- DBS Jam singletons
local _UpgradeManager    = require(ServerStorage.Modules.UpgradeManager)
local _ServerRaceManager = require(ServerStorage.Modules.ServerRaceManager)
local _GarageManager     = require(ServerStorage.Modules.GarageManager)
local _RewardsManager    = require(ServerStorage.Modules.RewardsManager)


-- Init
_EventManager:Init()

_GarageManager:Init({

})

_UpgradeManager:Init({
    RE_RequestUpgrade = _EventManager.Instances.RemoteEvent.RequestUpgrade
})

_PlayerManager:Init()
_PlayerManager:AddListener(_GarageManager)
--_PlayerManager:AddListener(_UpgradeManager)

_RewardsManager:Init({
    RE_NotifyRaceEnded = _EventManager.Instances.RemoteEvent.NotifyRaceEnded
})

_ServerRaceManager:Init({
    RequestRaceStart = _EventManager.Instances.RemoteEvent.RequestRaceStart,
    NotifyRaceStarting = _EventManager.Instances.RemoteEvent.NotifyRaceStarting,
    RequestInputProcessing = _EventManager.Instances.RemoteEvent.RequestInputProcessing,
    NotifyRacePhaseChange = _EventManager.Instances.RemoteEvent.NotifyRacePhaseChange,
    NotifyRaceEnded = _EventManager.Instances.RemoteEvent.NotifyRaceEnded,
    GarageManager = _GarageManager
})


-- Return
print("init.server.luau: Complete")
