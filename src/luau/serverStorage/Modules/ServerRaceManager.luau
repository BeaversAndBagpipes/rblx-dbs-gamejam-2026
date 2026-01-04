--!strict
local ServerRaceManager = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    RaceEvents: { [string]: RemoteEvent }
}

function ServerRaceManager:Init(config : InitConfig)
end

return ServerRaceManager