local GarageManager = {}

type InitConfig = {
    
}

function GarageManager:Init(config : InitConfig)
    self.ConnectedPlayers = {} :: {[Player]: {spawnLocation: BasePart, vehicle: Model}}
    self.AvailableSpawnLocations = {} :: {BasePart}
    self.VehicleTemplate = nil :: Model?
    
    local metaparts = workspace:WaitForChild("Game"):WaitForChild("MetaParts")
    local vehicles = workspace:WaitForChild("Game"):WaitForChild("Vehicles")
    
    self.VehicleTemplate = vehicles:WaitForChild("vehicle1")
    
    for i = 1, 6 do
        local spawnName = "GarageVehicleSpawn" .. i
        local spawnPart = metaparts:WaitForChild(spawnName)
        
        table.insert(self.AvailableSpawnLocations, spawnPart)
    end
end

function GarageManager:OnPlayerConnect(player : Player)
    -- Claim a spawn location from the available pool
    local spawnLocation = table.remove(self.AvailableSpawnLocations, 1)
    
    -- Clone and position the vehicle
    local vehicle = self.VehicleTemplate:Clone()
    vehicle.Name = "Vehicle_" .. player.Name
    vehicle:PivotTo(spawnLocation.CFrame)
    vehicle.Parent = workspace
    
    -- Track player data
    self.ConnectedPlayers[player] = {
        spawnLocation = spawnLocation,
        vehicle = vehicle
    }
end

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

return GarageManager