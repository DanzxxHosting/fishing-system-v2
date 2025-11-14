-- Fishing Assistant UI (Legal & Helpful)
-- Fitur: Timer, Stats Tracker, Quest Helper, Efficiency Calculator

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "FishingAssistantUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.BackgroundTransparency = 0.05
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = main

-- Glow Outline
local glow = Instance.new("UIStroke")
glow.Thickness = 2
glow.Color = Color3.fromRGB(0, 255, 170)
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
title.Text = "FISHING ASSISTANT"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(0, 255, 170)
title.Parent = topbar

-- Body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -46)
body.Position = UDim2.new(0, 0, 0, 46)
body.BackgroundTransparency = 1
body.Parent = main

-- Fishing Timer Section
local timerSection = Instance.new("Frame")
timerSection.Size = UDim2.new(1, -40, 0, 80)
timerSection.Position = UDim2.new(0, 20, 0, 20)
timerSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
timerSection.Parent = body

local timerCorner = Instance.new("UICorner")
timerCorner.CornerRadius = UDim.new(0, 12)
timerCorner.Parent = timerSection

local timerTitle = Instance.new("TextLabel")
timerTitle.Size = UDim2.new(1, 0, 0, 30)
timerTitle.Position = UDim2.new(0, 15, 0, 5)
timerTitle.BackgroundTransparency = 1
timerTitle.Text = "FISHING TIMER"
timerTitle.Font = Enum.Font.GothamBold
timerTitle.TextSize = 14
timerTitle.TextXAlignment = Enum.TextXAlignment.Left
timerTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
timerTitle.Parent = timerSection

local timerDisplay = Instance.new("TextLabel")
timerDisplay.Size = UDim2.new(1, -30, 0, 40)
timerDisplay.Position = UDim2.new(0, 15, 0, 35)
timerDisplay.BackgroundTransparency = 1
timerDisplay.Text = "00:00"
timerDisplay.Font = Enum.Font.GothamBold
timerDisplay.TextSize = 24
timerDisplay.TextXAlignment = Enum.TextXAlignment.Left
timerDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
timerDisplay.Parent = timerSection

local timerButton = Instance.new("TextButton")
timerButton.Size = UDim2.new(0, 60, 0, 25)
timerButton.Position = UDim2.new(1, -70, 0, 10)
timerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 140)
timerButton.Text = "START"
timerButton.Font = Enum.Font.GothamBold
timerButton.TextSize = 12
timerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
timerButton.Parent = timerSection

local timerCornerBtn = Instance.new("UICorner")
timerCornerBtn.CornerRadius = UDim.new(0, 6)
timerCornerBtn.Parent = timerButton

-- Stats Section
local statsSection = Instance.new("Frame")
statsSection.Size = UDim2.new(1, -40, 0, 100)
statsSection.Position = UDim2.new(0, 20, 0, 115)
statsSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statsSection.Parent = body

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsSection

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, 0, 0, 30)
statsTitle.Position = UDim2.new(0, 15, 0, 5)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "SESSION STATS"
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
statsTitle.Parent = statsSection

local fishCaughtLabel = Instance.new("TextLabel")
fishCaughtLabel.Size = UDim2.new(0.5, -10, 0, 20)
fishCaughtLabel.Position = UDim2.new(0, 15, 0, 35)
fishCaughtLabel.BackgroundTransparency = 1
fishCaughtLabel.Text = "Fish Caught: 0"
fishCaughtLabel.Font = Enum.Font.Gotham
fishCaughtLabel.TextSize = 12
fishCaughtLabel.TextXAlignment = Enum.TextXAlignment.Left
fishCaughtLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fishCaughtLabel.Parent = statsSection

local coinsEarnedLabel = Instance.new("TextLabel")
coinsEarnedLabel.Size = UDim2.new(0.5, -10, 0, 20)
coinsEarnedLabel.Position = UDim2.new(0.5, 5, 0, 35)
coinsEarnedLabel.BackgroundTransparency = 1
coinsEarnedLabel.Text = "Coins: 0"
coinsEarnedLabel.Font = Enum.Font.Gotham
coinsEarnedLabel.TextSize = 12
coinsEarnedLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsEarnedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
coinsEarnedLabel.Parent = statsSection

local efficiencyLabel = Instance.new("TextLabel")
efficiencyLabel.Size = UDim2.new(1, -30, 0, 20)
efficiencyLabel.Position = UDim2.new(0, 15, 0, 60)
efficiencyLabel.BackgroundTransparency = 1
efficiencyLabel.Text = "Efficiency: 0 fish/min"
efficiencyLabel.Font = Enum.Font.Gotham
efficiencyLabel.TextSize = 12
efficiencyLabel.TextXAlignment = Enum.TextXAlignment.Left
efficiencyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
efficiencyLabel.Parent = statsSection

local resetStatsButton = Instance.new("TextButton")
resetStatsButton.Size = UDim2.new(0, 80, 0, 25)
resetStatsButton.Position = UDim2.new(1, -90, 0, 10)
resetStatsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
resetStatsButton.Text = "RESET"
resetStatsButton.Font = Enum.Font.GothamBold
resetStatsButton.TextSize = 12
resetStatsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetStatsButton.Parent = statsSection

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetStatsButton

-- VARIABLES & FUNCTIONS
local timerRunning = false
local startTime = 0
local fishCount = 0
local coinsCount = 0

-- Timer Function
local function updateTimer()
	while timerRunning do
		local currentTime = os.time() - startTime
		local minutes = math.floor(currentTime / 60)
		local seconds = currentTime % 60
		timerDisplay.Text = string.format("%02d:%02d", minutes, seconds)
		
		-- Update efficiency
		if minutes > 0 then
			local efficiency = fishCount / minutes
			efficiencyLabel.Text = string.format("Efficiency: %.1f fish/min", efficiency)
		end
		
		wait(1)
	end
end

-- Timer Button
timerButton.MouseButton1Click:Connect(function()
	if not timerRunning then
		-- Start Timer
		timerRunning = true
		startTime = os.time()
		timerButton.Text = "STOP"
		timerButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		spawn(updateTimer)
	else
		-- Stop Timer
		timerRunning = false
		timerButton.Text = "START"
		timerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 140)
	end
end)

-- Reset Stats
resetStatsButton.MouseButton1Click:Connect(function()
	fishCount = 0
	coinsCount = 0
	fishCaughtLabel.Text = "Fish Caught: 0"
	coinsEarnedLabel.Text = "Coins: 0"
	efficiencyLabel.Text = "Efficiency: 0 fish/min"
end)

-- MANUAL FISHING TRACKER (Legal)
-- Ini hanya contoh - Anda perlu sesuaikan dengan game specific events
local function trackFishingAction()
	-- Contoh: Detect ketika player mendapatkan fish
	-- Ini harus menggunakan event yang disediakan game secara legal
	-- Misalnya: game:GetService("ReplicatedStorage").Events.FishCaught.OnClientEvent:Connect(function(fishData)
	--    fishCount = fishCount + 1
	--    coinsCount = coinsCount + (fishData.Reward or 0)
	--    fishCaughtLabel.Text = "Fish Caught: " .. fishCount
	--    coinsEarnedLabel.Text = "Coins: " .. coinsCount
	-- end)
end

-- Dragging Functionality
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

-- Initialize
spawn(trackFishingAction)

print("Fishing Assistant Loaded - Legal & Helpful!")
