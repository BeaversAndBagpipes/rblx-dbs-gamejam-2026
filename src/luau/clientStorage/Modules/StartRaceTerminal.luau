local StartRaceTerminal = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent
}

function StartRaceTerminal:Init(config : InitConfig)
    local startPrompt = workspace.Game.World.Garage:WaitForChild("StartRace")
                                                   :WaitForChild("StartRacePrompt")
    
    startPrompt.Triggered:Connect(function()
        config.RequestRaceStart:FireServer()
    end)

end

return StartRaceTerminal