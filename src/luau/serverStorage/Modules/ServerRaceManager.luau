--!strict
local RunService = game:GetService("RunService")

local SharedTypes = require(game.ReplicatedStorage.Shared.Types.SharedTypes)



local ServerRaceManager = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
    RequestInputProcessing : RemoteEvent,
    NotifyRacePhaseChange : RemoteEvent,
    NotifyRaceEnded : RemoteEvent,
    GarageManager : table
}

function ServerRaceManager:Init(config : InitConfig)
    self.ActiveRaces = {} :: {[Player]: SharedTypes.RaceInfo}

    local metaparts = workspace:WaitForChild("Game"):WaitForChild("MetaParts")
    self.VehicleSpawn = metaparts:WaitForChild("VehicleSpawn")
    
    

    config.RequestRaceStart.OnServerEvent:Connect(function(player : Player)
        
        


        print(player, "started a race!")
        
        local playerVehicle = config.GarageManager:GetPlayerVehicle(player)
        
        self.ActiveRaces[player] = {accel = 0, velocity = 0, totalDistance = 0, vehicle = nil}


        config.RequestInputProcessing.OnServerEvent:Connect(function(player : Player, phase : string, value : number)
            self.ActiveRaces[player].accel = 75 + (100 * (0.25 - value)) 
        end)

        
        playerVehicle = playerVehicle:Clone()
        self.ActiveRaces[player].vehicle = playerVehicle
        playerVehicle.Parent = workspace
        playerVehicle:PivotTo(self.VehicleSpawn.CFrame)
        config.NotifyRaceStarting:FireClient(player, playerVehicle)

        local part = playerVehicle.PrimaryPart

        

        --this just moves the player until the end of the race, need to calc total time somehow
        
        self.moveConnection = nil
        self.moveConnection = RunService.Heartbeat:Connect(function(dt)
            self.ActiveRaces[player].velocity += self.ActiveRaces[player].accel * dt
            local delta = Vector3.new(0,0,-self.ActiveRaces[player].velocity * dt)
            part.CFrame += delta
            self.ActiveRaces[player].totalDistance += delta.Magnitude
        end)
        task.spawn(function()
            config.NotifyRacePhaseChange:FireClient(player, "Warmup")
            task.wait(5)
            config.NotifyRacePhaseChange:FireClient(player, "Race")
            task.wait(5)
            config.NotifyRacePhaseChange:FireClient(player, "End")
            --award??
            --todo activeraces velocity can be used here
            
            config.NotifyRaceEnded:FireClient(player, self.ActiveRaces[player].velocity)
            self.moveConnection:Disconnect()
            
            --todo: this happens after the camera tweens back
            --self.ActiveRaces[player].vehicle:Destroy()
            --self.ActiveRaces[player] = nil
        end)
        

    end)
end

return ServerRaceManager