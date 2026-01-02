--!strict

-- Services
local DataStoreService      = game:GetService("DataStoreService")
local Players               = game:GetService("Players")
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local ServerScriptService   = game:GetService("ServerScriptService")
local ServerStorage         = game:GetService("ServerStorage")
local Workspace             = game:GetService("Workspace")

-- Types
local T_PlayerManager       = require(ServerStorage.Types.PlayerManager)

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

local PlayerManager = {}


-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function PlayerManager:Init()

	-- Set the respawn time:
	Players.RespawnTime = Settings.Player.CharacterRespawnTime

	-- Remember the SpawnLocation
	self.lobbySpawnPart = Workspace:FindFirstChild("SpawnLocation", true)

	-- Store a prefix to use for player data attributes
	self.PlayerDataAttributePrefix = D_Attributes.PlayerData.Prefix

	-- Handle players connecting
	Players.PlayerAdded:Connect(function(player: Player)
		self:OnPlayerConnect(player)
	end)

	-- Handle players disconnecting
	Players.PlayerRemoving:Connect(function(player: Player)
		self:OnPlayerDisconnect(player)
	end)

	-- Add any players already in the game (useful for testing or single-player mode), as sometimes this script kicks in after the debug player has loaded
	for _, player in Players:GetPlayers() do
		self:OnPlayerConnect(player)
	end
end



--  ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗
-- ██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
-- ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║
-- ██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝
--

function PlayerManager:OnPlayerConnect(player: Player)
	print("PlayerManager: OnPlayerConnect: " .. player.Name)

	-- Handle CharacterAdded for additional setup if needed (optional)
	if player.Character then
		print("PlayerManager: CharacterExists: " .. player.Name)
		self:ConfigurePlayerCharacter(player, player.Character)
	end

	-- Handle late-loading characters - Not sure when this happens, but it's good practice to handle it?
	player.CharacterAdded:Connect(function(character: Model)
		print("PlayerManager: CharacterAdded: " .. player.Name)
		self:ConfigurePlayerCharacter(player, character)
	end)

	-- Watch players chat messages
	player.Chatted:Connect(function(msg)
		self:OnPlayerChat(player, msg)
	end)

	-- Update various player stats, such as when they last played, how many days in a row they've been palying for, etc
	self:UpdatePlayerStats(player)
end



-- ██████╗ ██╗███████╗ ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗
-- ██╔══██╗██║██╔════╝██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
-- ██║  ██║██║███████╗██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║   
-- ██║  ██║██║╚════██║██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║   
-- ██████╔╝██║███████║╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║   
-- ╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝   
--

function PlayerManager:OnPlayerDisconnect(player: Player)
	-- Save their player stats
	self:SavePlayerStats(player)
end



-- ██████╗ ██╗      █████╗ ██╗   ██╗███████╗██████╗     ███████╗████████╗ █████╗ ████████╗███████╗
-- ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗    ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
-- ██████╔╝██║     ███████║ ╚████╔╝ █████╗  ██████╔╝    ███████╗   ██║   ███████║   ██║   ███████╗
-- ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗    ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
-- ██║     ███████╗██║  ██║   ██║   ███████╗██║  ██║    ███████║   ██║   ██║  ██║   ██║   ███████║
-- ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝
--

function PlayerManager:UpdatePlayerStats(player)
	-- Reads various attributes to get PlayerData and update playtime stats
	-- Updates DaysPlayed, DaysPlayedInARow, DateLastPlayed
	local today     = os.date("%Y%m%d")
	local yesterday = os.date("%Y%m%d", os.time() - 86400)

	-- DaysPlayedInARow: check if consecutive: increment if yes, reset if no
	local dateLastPlayed       = player:GetAttribute(D_Attributes.PlayerData.DateLastPlayed) or 0
	local daysPlayedInARow     = player:GetAttribute(D_Attributes.PlayerData.DaysPlayedInARow) or 0
	local mostDaysPlayedInARow = player:GetAttribute(D_Attributes.PlayerData.MostDaysPlayedInARow) or 0

	if dateLastPlayed == yesterday then
		daysPlayedInARow += 1
		player:SetAttribute(D_Attributes.PlayerData.DaysPlayedInARow, daysPlayedInARow)
	elseif dateLastPlayed ~= today then
		player:SetAttribute(D_Attributes.PlayerData.DaysPlayedInARow, 0)
	end

	-- MostDaysPlayedInARow: check if new record
	if daysPlayedInARow > mostDaysPlayedInARow then
		mostDaysPlayedInARow = daysPlayedInARow
		player:SetAttribute(D_Attributes.PlayerData.MostDaysPlayedInARow, mostDaysPlayedInARow)
	end

	-- DaysPlayed: increment if dateLastPlayed is not today
	if dateLastPlayed ~= today then
		local daysPlayed = player:GetAttribute(D_Attributes.PlayerData.DaysPlayed) or 0
		player:SetAttribute(D_Attributes.PlayerData.DaysPlayed, daysPlayed + 1)
	end

	-- DateLastPlayed
	player:SetAttribute(D_Attributes.PlayerData.DateLastPlayed, today)

	-- DateFirstPlayed: set if not set
	if not player:GetAttribute(D_Attributes.PlayerData.DateFirstPlayed) then
		player:SetAttribute(D_Attributes.PlayerData.DateFirstPlayed, today)
	end

	-- Times played
	local totalLogins = player:GetAttribute(D_Attributes.PlayerData.TotalLogins) or 0
	player:SetAttribute(D_Attributes.PlayerData.TotalLogins, totalLogins + 1)

end



--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ ██╗   ██╗██████╗ ███████╗     ██████╗██╗  ██╗ █████╗ ██████╗  █████╗  ██████╗████████╗███████╗██████╗ 
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ ██║   ██║██╔══██╗██╔════╝    ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗██║   ██║██████╔╝█████╗      ██║     ███████║███████║██████╔╝███████║██║        ██║   █████╗  ██████╔╝
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║██║   ██║██╔══██╗██╔══╝      ██║     ██╔══██║██╔══██║██╔══██╗██╔══██║██║        ██║   ██╔══╝  ██╔══██╗
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝╚██████╔╝██║  ██║███████╗    ╚██████╗██║  ██║██║  ██║██║  ██║██║  ██║╚██████╗   ██║   ███████╗██║  ██║
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
--

function PlayerManager:ConfigurePlayerCharacter(player: Player, character: Model)
	print("PlayerManager:ConfigurePlayerCharacter", player, character)

	-- Move them to the correct spawnLocation
	if character.PrimaryPart then
		character.PrimaryPart.CFrame = self.lobbySpawnPart.CFrame
	end

	-- Set their Humaoid properties
	if character.Humanoid then
		character.Humanoid.JumpHeight   = Settings.Player.CharacterJumpHeight
		character.Humanoid.JumpPower    = Settings.Player.CharacterJumpPower
		character.Humanoid.UseJumpPower = Settings.Player.CharacterUseJumpPower
		character.Humanoid.WalkSpeed    = Settings.Player.CharacterWalkSpeed
	else
		warn("PlayerManager:ConfigurePlayerCharacter: No Humanoid found for player: " .. player.Name)
	end

	-- Get the players stats/data and write them to attributes on the player
	local playerData = self:GetPlayerData(player)
	if not playerData then
		warn("PlayerManager:ConfigurePlayerCharacter: No player data found for player: " .. player.Name)
		return
	end
	self:SetPlayerDataAttributes(player, playerData)

	return
end



--  ██████╗ ███╗   ██╗     ██████╗██╗  ██╗ █████╗ ████████╗
-- ██╔═══██╗████╗  ██║    ██╔════╝██║  ██║██╔══██╗╚══██╔══╝
-- ██║   ██║██╔██╗ ██║    ██║     ███████║███████║   ██║
-- ██║   ██║██║╚██╗██║    ██║     ██╔══██║██╔══██║   ██║
-- ╚██████╔╝██║ ╚████║    ╚██████╗██║  ██║██║  ██║   ██║
--  ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝
--

function PlayerManager:OnPlayerChat(player: Player, msg: string)
	if Util.TableContainsValue(Settings.PlayerList.Admins, player.UserId) or player.UserId < 1 then

		-- kill self
		if msg == "dead" or msg == "die" then
			self:KillPlayer(player)
		end

		--kill player
		if msg:sub(1, 4) == "kill" then
			local params = msg:split(" ")
			local targetplayer = Players:FindFirstChild(params[2])
			if not targetplayer then return false end
			self:KillPlayer(targetplayer)
		end
	end
end




-- ███████╗ █████╗ ██╗   ██╗███████╗  ███████╗████████╗ █████╗ ████████╗███████╗
-- ██╔════╝██╔══██╗██║   ██║██╔════╝  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
-- ███████╗███████║██║   ██║█████╗    ███████╗   ██║   ███████║   ██║   ███████╗
-- ╚════██║██╔══██║╚██╗ ██╔╝██╔══╝    ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
-- ███████║██║  ██║ ╚████╔╝ ███████╗  ███████║   ██║   ██║  ██║   ██║   ███████║
-- ╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝
--


function PlayerManager:SavePlayerStats(player: Player)
	print("PlayerManager:SavePlayerStats:", player)

	-- Ensure the DataStore is available
	if not DS_PlayerData then
		print("PlayerManager:SavePlayerStats: DS_PlayerData is not available")
		return
	end

    local data = self:GetPlayerData(player)

	for name, value in pairs(self:GetPlayerDataAttributes(player)) do
		print("PlayerManager:SavePlayerStats: " .. name, value)
		data[name] = value
	end

	DS_PlayerData:Set(player.UserId, data)
end

function PlayerManager:SaveAllPlayerStats()
	for _, player in Players:GetPlayers() do
		self:SavePlayerStats(player)
	end
end



--  ██████╗ ███████╗████████╗    ██████╗ ██╗      █████╗ ██╗   ██╗███████╗██████╗     ██████╗  █████╗ ████████╗ █████╗
-- ██╔════╝ ██╔════╝╚══██╔══╝    ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
-- ██║  ███╗█████╗     ██║       ██████╔╝██║     ███████║ ╚████╔╝ █████╗  ██████╔╝    ██║  ██║███████║   ██║   ███████║
-- ██║   ██║██╔══╝     ██║       ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗    ██║  ██║██╔══██║   ██║   ██╔══██║
-- ╚██████╔╝███████╗   ██║       ██║     ███████╗██║  ██║   ██║   ███████╗██║  ██║    ██████╔╝██║  ██║   ██║   ██║  ██║
--  ╚═════╝ ╚══════╝   ╚═╝       ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
--
function PlayerManager:GetPlayerData(
	player: Player
)
	if not DS_PlayerData then
		warn("PlayerManager:GetPlayerData: DS_PlayerData is not available")
		return
	end

	local playerData = DS_PlayerData:GetAsync(player.UserId)

	return playerData
end




--  █████╗ ████████╗████████╗██████╗ ██╗██████╗ ██╗   ██╗████████╗███████╗███████╗
-- ██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██║██╔══██╗██║   ██║╚══██╔══╝██╔════╝██╔════╝
-- ███████║   ██║      ██║   ██████╔╝██║██████╔╝██║   ██║   ██║   █████╗  ███████╗
-- ██╔══██║   ██║      ██║   ██╔══██╗██║██╔══██╗██║   ██║   ██║   ██╔══╝  ╚════██║
-- ██║  ██║   ██║      ██║   ██║  ██║██║██████╔╝╚██████╔╝   ██║   ███████╗███████║
-- ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚══════╝
--

function PlayerManager:SetPlayerDataAttributes(player: Player, attributes: {})

	local function SetAttributes(attributes, prefix)
		--prefix = prefix or self.PlayerDataAttributePrefix
		for key, value in pairs(attributes) do
			if typeof(value) == "table" then
				--SetAttributes(value, prefix .. key .. "_") -- Disabled: we probably shouldn't recurse into tables, as we can't read them back out
				print("PlayerManager:SetPlayerDataAttributes: skipping table:", key)
			else
				player:SetAttribute((prefix or "") .. key, value)
			end
		end
	end

	if attributes then
		SetAttributes(attributes)
	end

	player:SetAttribute(D_Attributes.PlayerData.GameVersion, Settings.GameVersion)
end


function PlayerManager:GetPlayerDataAttributes(player: Player)
	local data = {}

	-- Seach player attributes for anythign starting with the prefix
	for key: string, value: any in pairs(player:GetAttributes()) do
		if
			Util.TableContainsKey(DS_PlayerData.DefaultValue, key) or
			Util.TableContainsValue(D_Attributes.PlayerData, key)
		then
			local newKey = string.gsub(key, self.PlayerDataAttributePrefix, "")
			data[newKey] = value
		end
	end

	return data
end

function PlayerManager:ClearPlayerDataAttributes(player: Player)
	for key: string, _ in pairs(player:GetAttributes()) do
		if key:sub(1, #self.PlayerDataAttributePrefix) == self.PlayerDataAttributePrefix then
			player:SetAttribute(key, nil)
		end
	end
end




-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return PlayerManager :: T_PlayerManager.PlayerManager
