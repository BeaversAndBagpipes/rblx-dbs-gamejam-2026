--!strict
local ServerRaceManager = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
    GarageManager : table
}

function ServerRaceManager:Init(config : InitConfig)
    local metaparts = workspace:WaitForChild("Game"):WaitForChild("MetaParts")
    self.VehicleSpawn = metaparts:WaitForChild("VehicleSpawn")
    
    config.RequestRaceStart.OnServerEvent:Connect(function(player : Player)
        print(player, "started a race!")
        local playerVehicle = config.GarageManager:GetPlayerVehicle(player)
        playerVehicle:PivotTo(self.VehicleSpawn.CFrame)
        config.NotifyRaceStarting:FireClient(player, playerVehicle)
    end)
end

return ServerRaceManager