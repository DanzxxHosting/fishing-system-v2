-- Premium UI (Black x Red Neon) untuk Auto Fishing System
-- Dibuat clean, smooth, premium, dan modular.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "PremiumFishingUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Blur (background premium style)
local blur = Instance.new("Frame")
blur.Size = UDim2.new(1,0,1,0)
blur.BackgroundTransparency = 1
blur.Parent = gui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 390, 0, 230)
main.Position = UDim2.new(0.5, -195, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.BackgroundTransparency = 0.05
main.ClipsDescendants = true
main.Parent = gui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = main

-- Glow Outline
local glow = Instance.new("UIStroke")
glow.Thickness = 2
glow.Color = Color3.fromRGB(255, 0, 60)
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
glow.Parent = main

-- Top Bar
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 46)
topbar.Position = UDim2.new(0, 0, 0, 0)
topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
topbar.BorderSizePixel = 0
topbar.Parent = main

local topcorner = Instance.new("UICorner")
topcorner.CornerRadius = UDim.new(0, 18)
topcorner.Parent = topbar

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO FISHING SYSTEM"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 30, 50)
title.Parent = topbar

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 40, 0, 40)
minBtn.Position = UDim2.new(1, -45, 0, 3)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 40, 60)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 32
minBtn.Parent = topbar

-- Body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -46)
body.Position = UDim2.new(0, 0, 0, 46)
body.BackgroundTransparency = 1
body.Parent = main

-- ON/OFF Toggle
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 330, 0, 60)
toggle.Position = UDim2.new(0.5, -165, 0, 20)
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.Text = "AUTO FISHING: OFF"
toggle.TextColor3 = Color3.fromRGB(255, 50, 50)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20
toggle.Parent = body

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 14)
tc.Parent = toggle

local ts = Instance.new("UIStroke")
ts.Color = Color3.fromRGB(255, 0, 50)
ts.Thickness = 2
ts.Parent = toggle

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 40)
statusLabel.Position = UDim2.new(0, 0, 1, -50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.TextColor3 = Color3.fromRGB(255, 50, 60)
statusLabel.Parent = body

-- ANIMATION: SHOW UI
main.Position = UDim2.new(0.5, -195, 1.2, 0)
TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
	Position = UDim2.new(0.5, -195, 0.5, -115)
}):Play()

-- TOGGLE LOGIC (UI ONLY)
local enabled = false
toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		toggle.Text = "AUTO FISHING: ON"
		toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
		statusLabel.Text = "Status: Running..."
		TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 0, 0)}):Play()
	else
		toggle.Text = "AUTO FISHING: OFF"
		toggle.TextColor3 = Color3.fromRGB(255, 80, 80)
		statusLabel.Text = "Status: Idle"
		TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
	end
end)

-- Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, 390, 0, 46)
		}):Play()
	else
		TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, 390, 0, 230)
		}):Play()
	end
end)

-- Dragging
local dragging = false
local dragStart, startPos

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

topbar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
