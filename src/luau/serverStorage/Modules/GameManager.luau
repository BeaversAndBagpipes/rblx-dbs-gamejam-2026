--!strict

-- Services
local DataStoreService      = game:GetService("DataStoreService")
local Players               = game:GetService("Players")
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local ServerScriptService   = game:GetService("ServerScriptService")
local ServerStorage         = game:GetService("ServerStorage")
local Workspace             = game:GetService("Workspace")

-- Types
local T_GameManager       = require(ServerStorage.Types.GameManager)

-- Data
local D_Attributes          = require(ReplicatedStorage.Shared.Data.Attributes)

-- Enums
--local E_PLAYERSTATE         = require(ReplicatedStorage.Shared.Enums.PlayerState)

-- Modules
local Settings              = require(ReplicatedStorage.Shared.Settings)
local Util                  = require(ReplicatedStorage.Shared.Lib.Util)
local Util_Player           = require(ReplicatedStorage.Shared.Lib["Util.Player"])

-- DataStores
local DS_PlayerData: DataStore | nil
pcall(function()
	DS_PlayerData = DataStoreService:GetDataStore("PlayerData")
end)



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local GameManager = {}


-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function GameManager:Init()

end