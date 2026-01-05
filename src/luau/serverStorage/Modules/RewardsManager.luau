--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace             = game:GetService("Workspace")

-- Types
local SharedTypes       = require(game.ReplicatedStorage.Shared.Types.SharedTypes)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Levels          = require(ReplicatedStorage.Shared.Data.Levels)

-- Modules
local Util              = require(ReplicatedStorage.Shared.Lib.Util)



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local RewardsManager = {}

type InitConfig = {
	RE_NotifyRaceEnded: RemoteEvent
}



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function RewardsManager:Init(config : InitConfig)
	assert(config.RE_NotifyRaceEnded, "RE_NotifyRaceEnded  not provided")
	config.RE_NotifyRaceEnded .OnServerEvent:Connect(function(player: Player, maxSpeed: number)
		self:OnRaceEnded(player, maxSpeed)
	end)
end


function RewardsManager:OnRaceEnded(player: Player, maxSpeed: number)
	local vehicleLevel = player:GetAttribute(D_Attributes.PlayerData.Level_Vehicle) or 1
	local currentCoins = player:GetAttribute(D_Attributes.PlayerData.Coins) or 0
	local newCoins = currentCoins + maxSpeed * D_Levels.Vehicle[vehicleLevel].statValue
	newCoins = math.floor(newCoins)

	player:SetAttribute(D_Attributes.PlayerData.Coins, newCoins)
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return RewardsManager
