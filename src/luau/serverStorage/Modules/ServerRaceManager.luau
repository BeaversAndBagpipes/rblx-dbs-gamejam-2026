--!strict
local ServerRaceManager = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
}

function ServerRaceManager:Init(config : InitConfig)
    config.RequestRaceStart.OnServerEvent:Connect(function(player : Player)
        print(player, "started a race!")
    end)
end

return ServerRaceManager