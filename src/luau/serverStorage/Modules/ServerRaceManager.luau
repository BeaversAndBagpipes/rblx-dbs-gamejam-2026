--!strict
local SharedTypes = require(game.ReplicatedStorage.Shared.Types.SharedTypes)



local ServerRaceManager = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
    GarageManager : table
}

function ServerRaceManager:Init(config : InitConfig)
    self.ActiveRaces = {} :: {[Player]: SharedTypes.RaceInfo}

    local metaparts = workspace:WaitForChild("Game"):WaitForChild("MetaParts")
    self.VehicleSpawn = metaparts:WaitForChild("VehicleSpawn")
    
    config.RequestRaceStart.OnServerEvent:Connect(function(player : Player)
        print(player, "started a race!")
        self.ActiveRaces[player] = {velocity = 20, totalDistance = 0}

        local playerVehicle = config.GarageManager:GetPlayerVehicle(player)
        playerVehicle = playerVehicle:Clone();
        playerVehicle:PivotTo(self.VehicleSpawn.CFrame)
        config.NotifyRaceStarting:FireClient(player, playerVehicle)

        local part = playerVehicle.PrimaryPart

        local RunService = game:GetService("RunService")
        local moveConnection
        moveConnection = RunService.Heartbeat:Connect(function(dt)
            part.CFrame += Vector3.new(0,0,-self.ActiveRaces[player].velocity * dt)
        end)

    end)
end

return ServerRaceManager