--!strict
local SharedTypes = require(game.ReplicatedStorage.Shared.Types.SharedTypes)



local ServerRaceManager = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
    RequestInputProcessing : RemoteEvent,
    NotifyRacePhaseChange : RemoteEvent,
    GarageManager : table
}

function ServerRaceManager:Init(config : InitConfig)
    self.ActiveRaces = {} :: {[Player]: SharedTypes.RaceInfo}

    local metaparts = workspace:WaitForChild("Game"):WaitForChild("MetaParts")
    self.VehicleSpawn = metaparts:WaitForChild("VehicleSpawn")
    
    config.RequestRaceStart.OnServerEvent:Connect(function(player : Player)
        print(player, "started a race!")
        self.ActiveRaces[player] = {velocity = 0, totalDistance = 0}

        local playerVehicle = config.GarageManager:GetPlayerVehicle(player)
        playerVehicle = playerVehicle:Clone()
        playerVehicle.Parent = workspace
        playerVehicle:PivotTo(self.VehicleSpawn.CFrame)
        config.NotifyRaceStarting:FireClient(player, playerVehicle)

        local part = playerVehicle.PrimaryPart

        

        --this just moves the player until the end of the race, need to calc total time somehow
        local RunService = game:GetService("RunService")
        local moveConnection
        moveConnection = RunService.Heartbeat:Connect(function(dt)
            local delta = Vector3.new(0,0,-self.ActiveRaces[player].velocity * dt)
            part.CFrame += delta
            self.ActiveRaces[player].totalDistance += delta.Magnitude
        end)
        task.spawn(function()
            config.NotifyRacePhaseChange:FireClient(player, "Warmup")
            task.wait(4)
            config.NotifyRacePhaseChange:FireClient(player, "Something")
        end)
        

    end)
end

return ServerRaceManager