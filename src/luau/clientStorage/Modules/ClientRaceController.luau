local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ClientRaceController = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
}

function ClientRaceController:Init(config : InitConfig)
    --connect player input
    
    config.NotifyRaceStarting.OnClientEvent:Connect(function(playerVehicle : Model)
        local camera = workspace.CurrentCamera
        local cameraAngle = playerVehicle:WaitForChild("cameraAngle") :: BasePart
        
        camera.CameraType = Enum.CameraType.Scriptable
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(camera, tweenInfo, {
            CFrame = cameraAngle.CFrame
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            RunService:BindToRenderStep("RaceCamera", Enum.RenderPriority.Camera.Value, function()
                camera.CFrame = cameraAngle.CFrame
            end)
        end)
    end)
end

return ClientRaceController