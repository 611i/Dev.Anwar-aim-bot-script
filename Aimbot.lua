local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local PredictAmount = 15
local IsAiming = false
local AimStrength = 1 -- قوة التثبيت
local AimZoneRadius = 50 -- 🔥 حجم منطقة الكروس للتثبيت

-- يجيب أقرب لاعب لـ منتصف الشاشة
local function GetClosestToCrosshair()
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

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AimbotGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 160, 0, 100)
Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "made by Anwar"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "Aim OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18

local PredictButton = Instance.new("TextButton", Frame)
PredictButton.Size = UDim2.new(0.9, 0, 0, 30)
PredictButton.Position = UDim2.new(0.05, 0, 0.65, 0)
PredictButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PredictButton.Text = "Predict: "..PredictAmount
PredictButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictButton.Font = Enum.Font.SourceSansBold
PredictButton.TextSize = 16

ToggleButton.MouseButton1Click:Connect(function()
    IsAiming = not IsAiming
    ToggleButton.Text = IsAiming and "Aim ON" or "Aim OFF"
end)

PredictButton.MouseButton1Click:Connect(function()
    PredictAmount = PredictAmount + 1
    if PredictAmount > 30 then PredictAmount = 1 end
    PredictButton.Text = "Predict: "..PredictAmount
end)

RunService.RenderStepped:Connect(function()
    if IsAiming then
        local target = GetClosestToCrosshair()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = target.Character.HumanoidRootPart
            local predicted = HRP.Position + (HRP.Velocity * (PredictAmount / 100))
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predicted)
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, AimStrength)
        end
    end
end)
