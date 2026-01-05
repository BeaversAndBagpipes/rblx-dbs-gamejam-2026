local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ClientRaceController = {}

type InitConfig = {
    RequestRaceStart : RemoteEvent,
    NotifyRaceStarting : RemoteEvent,
    RequestInputProcessing : RemoteEvent,
    NotifyRacePhaseChange : RemoteEvent,
    NotifyRaceEnded : RemoteEvent,
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
    self.buttonPressed = false
    self.phase = "None"
    self.warmupPerSecond = 0.7
    self.totalWarmup = 0
    config.Warmup:SetValue(0)

    --connect player input
    
    config.NotifyRaceStarting.OnClientEvent:Connect(function(playerVehicle : Model)
        
        RunService.Heartbeat:Connect(function(dt)
            if self.phase == "Warmup" then
                if self.buttonPressed then
                    self.totalWarmup += dt * self.warmupPerSecond
                    if self.totalWarmup > 1 then self.totalWarmup = 1 end
                else
                    self.totalWarmup -= dt * self.warmupPerSecond
                    if self.totalWarmup < 0 then self.totalWarmup = 0 end
                end
                config.Warmup:SetValue(self.totalWarmup)
            end
        end)

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
            self.phase = "Warmup"
            config.Warmup:Show()
        else
            config.Warmup:Hide()
        end
        if phase == "Race" then
            local delta = math.abs(math.clamp(self.totalWarmup - 0.69, -0.25, 0.25))
            config.RequestInputProcessing:FireServer("Warmup", delta)
        end
    end)

    config.NotifyRaceEnded.OnClientEvent:Connect(function()
    
    end)
end

function ClientRaceController:PressButton()
    self.buttonPressed = true
end

function ClientRaceController:ReleaseButton()
    self.buttonPressed = false
end

return ClientRaceController