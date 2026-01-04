--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Types
local SharedTypes       = require(game.ReplicatedStorage.Shared.Types.SharedTypes)

-- Data
local D_Attributes      = require(ReplicatedStorage.Shared.Data.Attributes)
local D_Levels          = require(ReplicatedStorage.Shared.Data.Levels)



-- ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ████╗ ████║██╔══██╗██║████╗  ██║
-- ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
--

local UpgradeManager = {}

type InitConfig = {
    RE_RequestUpgrade : RemoteEvent
}



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function UpgradeManager:Init(config : InitConfig)
	assert(config.RE_RequestUpgrade, "RE_RequestUpgrade not provided")
    config.RE_RequestUpgrade.OnServerEvent:Connect(function(
		player : Player,
		upgrade: SharedTypes.UpgradeDescription
	)
		self:OnRequestUpgrade(player, upgrade)
    end)
end


--  ██████╗ ███╗   ██╗██████╗ ███████╗ ██████╗ ██╗   ██╗███████╗███████╗████████╗██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ ██████╗ ███████╗
-- ██╔═══██╗████╗  ██║██╔══██╗██╔════╝██╔═══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝
-- ██║   ██║██╔██╗ ██║██████╔╝█████╗  ██║   ██║██║   ██║█████╗  ███████╗   ██║   ██║   ██║██████╔╝██║  ███╗██████╔╝███████║██║  ██║█████╗  
-- ██║   ██║██║╚██╗██║██╔══██╗██╔══╝  ██║▄▄ ██║██║   ██║██╔══╝  ╚════██║   ██║   ██║   ██║██╔═══╝ ██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝  
-- ╚██████╔╝██║ ╚████║██║  ██║███████╗╚██████╔╝╚██████╔╝███████╗███████║   ██║   ╚██████╔╝██║     ╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗
--  ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
--

function UpgradeManager:OnRequestUpgrade(
	player : Player,
	upgrade: SharedTypes.UpgradeDescription
)
	--todo: access player attributes to validate if player has enough
	--money to buy the upgrade then buy it

	local currentCoins = player:GetAttribute(D_Attributes.PlayerData.Coins) or 0
	local currentLevel = player:GetAttribute(D_Attributes.PlayerData["Level_"..upgrade.name]) or 1

	-- Ensure the requested level is higher
	if currentLevel >= upgrade.level then
		-- Player already has this level
		warn("Player already has this level item", player.Name, upgrade.name, upgrade.level)
		return
	end

	-- Ensure the requested level is not higher than the max level
	if upgrade.level > #D_Levels[upgrade.name] then
		warn("Requested level is higher than the max level", player.Name, upgrade.name, upgrade.level)
		return
	end

	-- Ensure they have enough coins to buy the upgrade
	-- We do protect against this in the client, but cheaters gonna cheat
	if currentCoins < D_Levels[upgrade.name][upgrade.level].cost then
		warn("Player does not have enough coins to buy the upgrade", player.Name, upgrade.name, upgrade.level)
		return
	end

	-- Purchase the upgrade
	player:SetAttribute(D_Attributes.PlayerData.Coins, currentCoins - D_Levels[upgrade.name][upgrade.level].cost)
	player:SetAttribute(D_Attributes.PlayerData["Level_"..upgrade.name], upgrade.level)

	-- Attribute changes propagate to the player, and client script watch for attribute changes and react

end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--
return UpgradeManager