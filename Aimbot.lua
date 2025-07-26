local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local PredictAmount = 15
local TargetPlayer = nil
local IsAiming = false

local function GetTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < closestDistance and dist < 300 then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 160, 0, 100)
Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "made by Anwar"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "Aim OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = Frame

local PredictButton = Instance.new("TextButton")
PredictButton.Size = UDim2.new(0.9, 0, 0, 30)
PredictButton.Position = UDim2.new(0.05, 0, 0.65, 0)
PredictButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PredictButton.Text = "Predict: "..PredictAmount
PredictButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictButton.Font = Enum.Font.SourceSansBold
PredictButton.TextSize = 16
PredictButton.Parent = Frame

ToggleButton.MouseButton1Click:Connect(function()
    IsAiming = not IsAiming
    if IsAiming then
        ToggleButton.Text = "Aim ON"
        TargetPlayer = GetTarget()
    else
        ToggleButton.Text = "Aim OFF"
        TargetPlayer = nil
    end
end)

PredictButton.MouseButton1Click:Connect(function()
    PredictAmount = PredictAmount + 1
    if PredictAmount > 30 then
        PredictAmount = 1
    end
    PredictButton.Text = "Predict: "..PredictAmount
end)

RunService.RenderStepped:Connect(function()
    if IsAiming then
        -- تحقّق إن الهدف مات أو اختفى
        if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("Humanoid") or TargetPlayer.Character.Humanoid.Health <= 0 then
            TargetPlayer = GetTarget()
        end

        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = TargetPlayer.Character.HumanoidRootPart
            local PredictedPosition = HRP.Position + (HRP.Velocity * (PredictAmount / 100))
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, PredictedPosition) -- بدون سموذ، مباشر وثابت
        end
    end
end)
