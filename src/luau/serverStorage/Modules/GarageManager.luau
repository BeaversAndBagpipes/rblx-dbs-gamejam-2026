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

local GarageManager = {}

type InitConfig = {
    
}



-- ██╗███╗   ██╗██╗████████╗
-- ██║████╗  ██║██║╚══██╔══╝
-- ██║██╔██╗ ██║██║   ██║
-- ██║██║╚██╗██║██║   ██║
-- ██║██║ ╚████║██║   ██║
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝
--

function GarageManager:Init(config : InitConfig)
    self.ConnectedPlayers        = {} :: {[Player]: {spawnLocation: BasePart, vehicle: Model}}
    self.AvailableSpawnLocations = {} :: {BasePart}

    self.vehicles       = Workspace:WaitForChild("Game"):WaitForChild("Vehicles")
    local metaparts     = Workspace:WaitForChild("Game"):WaitForChild("MetaParts")

    for i = 1, 6 do
        local spawnName = "GarageVehicleSpawn" .. i
        local spawnPart = metaparts:WaitForChild(spawnName)
        table.insert(self.AvailableSpawnLocations, spawnPart)
    end
end



--  ██████╗ ███╗   ██╗ ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗
-- ██╔═══██╗████╗  ██║██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
-- ██║   ██║██╔██╗ ██║██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║
-- ██║   ██║██║╚██╗██║██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║
-- ╚██████╔╝██║ ╚████║╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║
--  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝
--

function GarageManager:OnPlayerConnect(player : Player)
    -- Claim a spawn location from the available pool
    local spawnLocation = table.remove(self.AvailableSpawnLocations, 1)

    -- Clone and position the vehicle
	local vehicle = self:SpawnVehicle(player, spawnLocation.CFrame)

    -- Track player data
    self.ConnectedPlayers[player] = {
        spawnLocation = spawnLocation,
        vehicle = vehicle
    }

	-- Watch the carious player attributes for any changes, and resawpn the vehicle if needed
	for _, partName in pairs(D_Attributes.VehicleParts) do
		local attrName = "Level_" .. partName	
		player:GetAttributeChangedSignal(attrName):Connect(function()
			print("GarageManager:OnPlayerConnect():", player.Name, "attribute", attrName, "changed, updating vehicle")
			self:UpdatePlayerVehicle(player)
		end)
	end
end



--  ██████╗ ███╗   ██╗██████╗ ██╗███████╗ ██████╗ ██████╗ ███╗   ██╗███╗   ██╗███████╗ ██████╗████████╗
-- ██╔═══██╗████╗  ██║██╔══██╗██║██╔════╝██╔════╝██╔═══██╗████╗  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
-- ██║   ██║██╔██╗ ██║██║  ██║██║███████╗██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║        ██║
-- ██║   ██║██║╚██╗██║██║  ██║██║╚════██║██║     ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║        ██║
-- ╚██████╔╝██║ ╚████║██████╔╝██║███████║╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║███████╗╚██████╗   ██║
--  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝
--

function GarageManager:OnPlayerDisconnect(player : Player)
    local playerData = self.ConnectedPlayers[player]

    if not playerData then
        return
    end

    -- Destroy the player's vehicle
    if playerData.vehicle then
        playerData.vehicle:Destroy()
    end

    -- Return spawn location to the available pool
    table.insert(self.AvailableSpawnLocations, playerData.spawnLocation)

    -- Clean up player data
    self.ConnectedPlayers[player] = nil
end

function GarageManager:GetPlayerVehicle(player : Player) : Model?
    local playerData = self.ConnectedPlayers[player]

    return playerData.vehicle
end



-- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗██████╗ ██╗      █████╗ ██╗   ██╗███████╗██████╗ ██╗   ██╗███████╗██╗  ██╗██╗ ██████╗██╗     ███████╗
-- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗██║   ██║██╔════╝██║  ██║██║██╔════╝██║     ██╔════╝
-- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗  ██████╔╝██║     ███████║ ╚████╔╝ █████╗  ██████╔╝██║   ██║█████╗  ███████║██║██║     ██║     █████╗  
-- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝  ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██║██║██║     ██║     ██╔══╝  
-- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗██║     ███████╗██║  ██║   ██║   ███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║██║╚██████╗███████╗███████╗
--  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝╚══════╝
--
function GarageManager:UpdatePlayerVehicle(player : Player)
    if not self.ConnectedPlayers[player] then
		warn("GarageManager:UpdatePlayerVehicle: Player data doesn't exist connected", player.Name)
        return
    end

	-- Remove the current vehicle
	if self.ConnectedPlayers[player].vehicle then
		self.ConnectedPlayers[player].vehicle:Destroy()
	else
		warn("GarageManager:UpdatePlayerVehicle: Vehicle doesn't exist", player.Name)
        return
	end

	-- Spawn the new vehicle
	self.ConnectedPlayers[player].vehicle = self:SpawnVehicle(player, self.ConnectedPlayers[player].spawnLocation.CFrame)
end


-- ███████╗██████╗  █████╗ ██╗    ██╗███╗   ██╗██╗   ██╗███████╗██╗  ██╗██╗ ██████╗██╗     ███████╗
-- ██╔════╝██╔══██╗██╔══██╗██║    ██║████╗  ██║██║   ██║██╔════╝██║  ██║██║██╔════╝██║     ██╔════╝
-- ███████╗██████╔╝███████║██║ █╗ ██║██╔██╗ ██║██║   ██║█████╗  ███████║██║██║     ██║     █████╗
-- ╚════██║██╔═══╝ ██╔══██║██║███╗██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██╔══██║██║██║     ██║     ██╔══╝
-- ███████║██║     ██║  ██║╚███╔███╔╝██║ ╚████║ ╚████╔╝ ███████╗██║  ██║██║╚██████╗███████╗███████╗
-- ╚══════╝╚═╝     ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝╚══════╝
--

function GarageManager:SpawnVehicle(player : Player, spawnLocation : CFrame)
	print("GarageManager:SpawnVehicle:", player.Name, spawnLocation)

	local playerLevels = {
		Vehicle    = player:GetAttribute(D_Attributes.PlayerData.Level_Vehicle) or 1,
		Engine     = player:GetAttribute(D_Attributes.PlayerData.Level_Engine) or 1,
		FuelSystem = player:GetAttribute(D_Attributes.PlayerData.Level_FuelSystem) or 1,
		FuelTank   = player:GetAttribute(D_Attributes.PlayerData.Level_FuelTank) or 1,
		Nozzle     = player:GetAttribute(D_Attributes.PlayerData.Level_Nozzle) or 1,
	}

    local vehicle = self.vehicles:WaitForChild("vehicle" .. playerLevels.Vehicle, 5):Clone() :: Model

	-- Now we loop though each of the parts and disable any models that don't match the players current level
	for folderName, level in pairs(playerLevels) do
		if folderName == "Vehicle" then continue end -- we don't look for a folder called "Vehicle"

		print("GarageManager:SpawnVehicle: Checking vehicle:", vehicle, "for folder:", folderName)
		for _, child in vehicle:WaitForChild(folderName):GetChildren() do
			if child:IsA("Model") then
				if child.Name ~= "Level"..level then
					Util.HideDescendants(child)
				else
					Util.ShowDescendants(child)
				end
			end
		end
	end

    vehicle.Name = "Vehicle_" .. player.Name
    vehicle:PivotTo(spawnLocation)
    vehicle.Parent = workspace

	return vehicle
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return GarageManager
