--!strict

print("init.server.luau: Starting")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

-- Singletons
local _EventManager  = require(ReplicatedStorage.Shared.Modules.EventManager)
local _PlayerManager = require(ServerStorage.Modules.PlayerManager)

-- Init
_EventManager:Init()
_PlayerManager:Init()

-- Return
print("init.server.luau: Complete")
