local SharedTypes = require(game.ReplicatedStorage.Shared.Types.SharedTypes)


local UpgradeManager = {}

type InitConfig = {
    RequestUpgrade : RemoteEvent
}

function UpgradeManager:Init(config : InitConfig)
    config.RequestUpgrade:Connect(function(player : Player, upgrade : SharedTypes.UpgradeDescription)
        --todo: access player attributes to validate if player has enough
        --money to buy the upgrade then buy it
    end)
end

return UpgradeManager