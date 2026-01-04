local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ClientRaceController = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
}

function ClientRaceController:GetCameraAngle(playerVehicle : Model)
    local playerVehiclePrimaryPart = playerVehicle.PrimaryPart
        
    local offset = CFrame.new(0, 10, 25)
        local lookAtCFrame = playerVehiclePrimaryPart.CFrame * offset
        local ret = CFrame.lookAt(
            lookAtCFrame.Position,
            lookAtCFrame.Position + -playerVehiclePrimaryPart.CFrame.ZVector,
            playerVehiclePrimaryPart.CFrame.YVector
        )
        return ret
end

function ClientRaceController:Init(config : InitConfig)
    --connect player input
    
    config.NotifyRaceStarting.OnClientEvent:Connect(function(playerVehicle : Model)
        
        local camera = workspace.CurrentCamera
        local camCFrame = self:GetCameraAngle(playerVehicle)

        camera.CameraType = Enum.CameraType.Scriptable
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(camera, tweenInfo, {
            CFrame = camCFrame
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            RunService:BindToRenderStep("RaceCamera", Enum.RenderPriority.Camera.Value, function()
                camera.CFrame = self:GetCameraAngle(playerVehicle)
            end)
        end)
    end)
end

return ClientRaceController