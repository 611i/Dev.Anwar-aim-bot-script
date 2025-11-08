local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace:FindFirstChildOfClass("Camera")

local IsAiming = false
local AimZoneRadius = 50
local CurrentTarget = nil

local function GetClosestToCrosshair()
    if not Camera then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if distance < closestDistance and distance <= AimZoneRadius then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

local function valid(target)
    return target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AnwarAim"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 140, 0, 60)
Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 18)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = " made by Anwar tik @hf4_l حقوق"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.9, 0, 0, 32)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 22)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "Aim OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16

ToggleButton.MouseButton1Click:Connect(function()
    IsAiming = not IsAiming
    ToggleButton.Text = IsAiming and "Aim ON" or "Aim OFF"
    if not IsAiming then
        CurrentTarget = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not IsAiming or not Camera then return end

    if not valid(CurrentTarget) then
        CurrentTarget = GetClosestToCrosshair()
    end

    if valid(CurrentTarget) then
        local HRP = CurrentTarget.Character.HumanoidRootPart
        local velocity = HRP.Velocity
        local speed = velocity.Magnitude

        local predictFactor = math.clamp(speed * 0.5, 22, 25)
        local verticalPredict = 0

        if velocity.Y > 1 then
            verticalPredict = -3
        elseif velocity.Y < -1 then
            verticalPredict = 3
        end

        local predicted = HRP.Position + (velocity * (predictFactor / 100)) + Vector3.new(0, verticalPredict, 0)
        local targetDirection = (predicted - Camera.CFrame.Position).Unit
        local dot = Camera.CFrame.LookVector:Dot(targetDirection)
        local angle = math.acos(math.clamp(dot, -1, 1))

        if angle > 0.0001 then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predicted)
        end
    end
end)
