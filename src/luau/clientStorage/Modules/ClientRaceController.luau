local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ClientRaceController = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
    RequestInputProcessing : RemoteEvent,
    NotifyRacePhaseChange : RemoteEvent,
    Warmup : table
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
    
    config.NotifyRacePhaseChange.OnClientEvent:Connect(function(phase : string)
        if phase == "Warmup" then
            config.Warmup:Show()
        else
            config.Warmup:Hide()
        end
    end)
end

function ClientRaceController:PressButton()
    print("pressing the button")
end

function ClientRaceController:ReleaseButton()
    print("released the button")
end

return ClientRaceController