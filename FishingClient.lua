-- UI-Only: Neon Panel dengan Tray Icon + Enhanced Instant Fishing + FISHING V2 FIXED
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- FISHING CONFIG
local fishingConfig = {
    autoFishing = false,
    instantFishing = true,
    fishingDelay = 0.001,
    blantantMode = false,
    ultraSpeed = false,
    perfectCast = true,
    autoReel = true,
    bypassDetection = true
}

-- FISHING V2 CONFIG - FIXED
local fishingV2Config = {
    enabled = false,
    smartDetection = true,
    antiAfk = true,
    autoSell = false,
    rareFishPriority = false,
    multiSpotFishing = false,
    fishingSpotRadius = 50,
    maxFishingSpots = 3,
    sellDelay = 5,
    avoidPlayers = false,
    radarEnabled = false,
    instantReel = true,
    castDelay = 2,
    reelDelay = 0.5,
    useProximityOnly = true
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successRate = 0,
    rareFish = 0,
    totalValue = 0,
    spotsFound = 0,
    instantCatches = 0,
    lastAction = "Idle"
}

local fishingActive = false
local fishingV2Active = false
local fishingConnection, reelConnection, v2Connection, radarConnection
local currentFishingSpot = nil
local fishingSpots = {}
local antiAfkTime = 0
local lastCastTime = 0
local lastReelTime = 0
local isCasting = false
local isReeling = false

-- Cleanup old UI
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

print("[UI] ScreenGui created")

-- TRAY ICON
local trayIcon = Instance.new("ImageButton")
trayIcon.Name = "TrayIcon"
trayIcon.Size = UDim2.new(0, 60, 0, 60)
trayIcon.Position = UDim2.new(1, -70, 0, 20)
trayIcon.BackgroundColor3 = ACCENT
trayIcon.Image = "rbxassetid://3926305904"
trayIcon.Visible = false
trayIcon.ZIndex = 10
trayIcon.Parent = screen

local trayCorner = Instance.new("UICorner")
trayCorner.CornerRadius = UDim.new(0, 12)
trayCorner.Parent = trayIcon

local trayGlow = Instance.new("ImageLabel")
trayGlow.Name = "TrayGlow"
trayGlow.Size = UDim2.new(1, 20, 1, 20)
trayGlow.Position = UDim2.new(0, -10, 0, -10)
trayGlow.BackgroundTransparency = 1
trayGlow.Image = "rbxassetid://5050741616"
trayGlow.ImageColor3 = ACCENT
trayGlow.ImageTransparency = 0.8
trayGlow.ZIndex = 9
trayGlow.Parent = trayIcon

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1
glow.Parent = container

-- Card
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

-- inner container
local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1
inner.Parent = card

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = inner

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT V2"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Window Controls
local windowControls = Instance.new("Frame")
windowControls.Size = UDim2.new(0, 80, 1, 0)
windowControls.Position = UDim2.new(1, -85, 0, 0)
windowControls.BackgroundTransparency = 1
windowControls.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(0, 0, 0.5, -16)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = windowControls

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(0, 40, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "🗙"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = windowControls

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local memLabel = Instance.new("TextLabel")
memLabel.Size = UDim2.new(0.4,-100,1,0)
memLabel.Position = UDim2.new(0.6,8,0,0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 11
memLabel.Text = "Memory: 0 KB | Fish: 0"
memLabel.TextColor3 = Color3.fromRGB(200,200,200)
memLabel.TextXAlignment = Enum.TextXAlignment.Left
memLabel.Parent = titleBar

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
sidebar.Parent = inner

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = sidebar

local sbHeader = Instance.new("Frame")
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1
sbHeader.Parent = sidebar

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904"
logo.ImageColor3 = ACCENT
logo.Parent = sbHeader

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1,-96,0,32)
sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun V2"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = sbHeader

-- Menu
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1
menuFrame.Parent = sidebar

local menuLayout = Instance.new("UIListLayout")
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)
menuLayout.Parent = menuFrame

local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = row

    local left = Instance.new("Frame")
    left.Size = UDim2.new(0,40,1,0)
    left.Position = UDim2.new(0,8,0,0)
    left.BackgroundTransparency = 1
    left.Parent = row

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center
    icon.Parent = left

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

local items = {
    {"Fishing V1", "🎣"},
    {"Fishing V2", "🚀"},
    {"Teleport", "📍"},
    {"Settings", "⚙"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- Content panel
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0
content.Parent = inner

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = content

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Fishing V1"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = content

-- ═══════════════════════════════════════════════════════════
-- FISHING V1 UI CONTENT - IMPROVED
-- ═══════════════════════════════════════════════════════════

local fishingContent = Instance.new("ScrollingFrame")
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -24)
fishingContent.Position = UDim2.new(0, 12, 0, 12)
fishingContent.BackgroundTransparency = 1
fishingContent.Visible = true
fishingContent.ScrollBarThickness = 6
fishingContent.ScrollBarImageColor3 = ACCENT
fishingContent.CanvasSize = UDim2.new(0, 0, 0, 600)
fishingContent.Parent = content

local fishingContainer = Instance.new("Frame")
fishingContainer.Name = "FishingContainer"
fishingContainer.Size = UDim2.new(1, 0, 0, 600)
fishingContainer.BackgroundTransparency = 1
fishingContainer.Parent = fishingContent

-- Stats Panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 120)
statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
statsPanel.BorderSizePixel = 0
statsPanel.Parent = fishingContainer

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0,8)
statsCorner.Parent = statsPanel

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -24, 0, 28)
statsTitle.Position = UDim2.new(0,12,0,8)
statsTitle.BackgroundTransparency = 1
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.Text = "📊 FISHING STATISTICS"
statsTitle.TextColor3 = Color3.fromRGB(235,235,235)
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsPanel

local fishCountLabel = Instance.new("TextLabel")
fishCountLabel.Size = UDim2.new(0.5, -8, 0, 24)
fishCountLabel.Position = UDim2.new(0,12,0,40)
fishCountLabel.BackgroundTransparency = 1
fishCountLabel.Font = Enum.Font.Gotham
fishCountLabel.TextSize = 13
fishCountLabel.Text = "🎣 Fish Caught: 0"
fishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
fishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
fishCountLabel.Parent = statsPanel

local rateLabel = Instance.new("TextLabel")
rateLabel.Size = UDim2.new(0.5, -8, 0, 24)
rateLabel.Position = UDim2.new(0.5,4,0,40)
rateLabel.BackgroundTransparency = 1
rateLabel.Font = Enum.Font.Gotham
rateLabel.TextSize = 13
rateLabel.Text = "📈 Rate: 0/s"
rateLabel.TextColor3 = Color3.fromRGB(200,220,255)
rateLabel.TextXAlignment = Enum.TextXAlignment.Left
rateLabel.Parent = statsPanel

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Size = UDim2.new(0.5, -8, 0, 24)
attemptsLabel.Position = UDim2.new(0,12,0,68)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.Font = Enum.Font.Gotham
attemptsLabel.TextSize = 13
attemptsLabel.Text = "🔄 Attempts: 0"
attemptsLabel.TextColor3 = Color3.fromRGB(255,220,200)
attemptsLabel.TextXAlignment = Enum.TextXAlignment.Left
attemptsLabel.Parent = statsPanel

local successLabel = Instance.new("TextLabel")
successLabel.Size = UDim2.new(0.5, -8, 0, 24)
successLabel.Position = UDim2.new(0.5,4,0,68)
successLabel.BackgroundTransparency = 1
successLabel.Font = Enum.Font.Gotham
successLabel.TextSize = 13
successLabel.Text = "✅ Success: 0%"
successLabel.TextColor3 = Color3.fromRGB(255,200,255)
successLabel.TextXAlignment = Enum.TextXAlignment.Left
successLabel.Parent = statsPanel

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, -24, 0, 24)
timeLabel.Position = UDim2.new(0,12,0,96)
timeLabel.BackgroundTransparency = 1
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextSize = 13
timeLabel.Text = "⏱️ Session Time: 0s"
timeLabel.TextColor3 = Color3.fromRGB(200,255,255)
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = statsPanel

-- Controls Panel
local controlsPanel = Instance.new("Frame")
controlsPanel.Size = UDim2.new(1, 0, 0, 120)
controlsPanel.Position = UDim2.new(0, 0, 0, 132)
controlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
controlsPanel.BorderSizePixel = 0
controlsPanel.Parent = fishingContainer

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0,8)
controlsCorner.Parent = controlsPanel

local controlsTitle = Instance.new("TextLabel")
controlsTitle.Size = UDim2.new(1, -24, 0, 28)
controlsTitle.Position = UDim2.new(0,12,0,8)
controlsTitle.BackgroundTransparency = 1
controlsTitle.Font = Enum.Font.GothamBold
controlsTitle.TextSize = 14
controlsTitle.Text = "⚡ FISHING CONTROLS"
controlsTitle.TextColor3 = Color3.fromRGB(235,235,235)
controlsTitle.TextXAlignment = Enum.TextXAlignment.Left
controlsTitle.Parent = controlsPanel

-- Start/Stop Button
local fishingButton = Instance.new("TextButton")
fishingButton.Size = UDim2.new(0, 200, 0, 50)
fishingButton.Position = UDim2.new(0, 12, 0, 40)
fishingButton.BackgroundColor3 = ACCENT
fishingButton.Font = Enum.Font.GothamBold
fishingButton.TextSize = 14
fishingButton.Text = "🚀 START INSTANT FISHING"
fishingButton.TextColor3 = Color3.fromRGB(30,30,30)
fishingButton.AutoButtonColor = false
fishingButton.Parent = controlsPanel

local fishingBtnCorner = Instance.new("UICorner")
fishingBtnCorner.CornerRadius = UDim.new(0,6)
fishingBtnCorner.Parent = fishingButton

-- Status Indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, -16, 0, 50)
statusLabel.Position = UDim2.new(0, 224, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.Text = "⭕ OFFLINE"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = controlsPanel

-- Toggles Panel
local togglesPanel = Instance.new("Frame")
togglesPanel.Size = UDim2.new(1, 0, 0, 280)
togglesPanel.Position = UDim2.new(0, 0, 0, 264)
togglesPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
togglesPanel.BorderSizePixel = 0
togglesPanel.Parent = fishingContainer

local togglesCorner = Instance.new("UICorner")
togglesCorner.CornerRadius = UDim.new(0,8)
togglesCorner.Parent = togglesPanel

local togglesTitle = Instance.new("TextLabel")
togglesTitle.Size = UDim2.new(1, -24, 0, 28)
togglesTitle.Position = UDim2.new(0,12,0,8)
togglesTitle.BackgroundTransparency = 1
togglesTitle.Font = Enum.Font.GothamBold
togglesTitle.TextSize = 14
togglesTitle.Text = "🔧 INSTANT FISHING SETTINGS"
togglesTitle.TextColor3 = Color3.fromRGB(235,235,235)
togglesTitle.TextXAlignment = Enum.TextXAlignment.Left
togglesTitle.Parent = togglesPanel

-- Toggle Helper Function - IMPROVED
local function CreateToggle(name, desc, default, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 48)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(180,180,180)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 28)
    button.Position = UDim2.new(0.75, 0, 0.2, 0)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(30,30,30)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = default and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(220, 0, 0)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        }):Play()
    end)

    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        callback(new)
    end)

    return frame
end

-- Create Toggles untuk V1 - IMPROVED LAYOUT
CreateToggle("⚡ Instant Fishing", "Max speed casting & catching", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    if v then
        fishingConfig.fishingDelay = 0.01
        fishingConfig.autoReel = true
        print("[Fishing] Instant Fishing: ENABLED")
    else
        fishingConfig.fishingDelay = 0.1
        print("[Fishing] Instant Fishing: DISABLED")
    end
end, togglesPanel, 36)

CreateToggle("💥 Blatant Mode", "Ultra fast (may be detected)", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then
        fishingConfig.fishingDelay = 0.001
        fishingConfig.instantFishing = true
        fishingConfig.autoReel = true
        print("[Fishing] Blatant Mode: ENABLED (0.001s delay)")
    else
        fishingConfig.fishingDelay = 0.1
        fishingConfig.instantFishing = false
        print("[Fishing] Blatant Mode: DISABLED")
    end
end, togglesPanel, 88)

CreateToggle("🎯 Perfect Cast", "Always perfect casting", fishingConfig.perfectCast, function(v)
    fishingConfig.perfectCast = v
    print("[Fishing] Perfect Cast:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 140)

CreateToggle("🔄 Auto Reel", "Auto reel minigame", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
    print("[Fishing] Auto Reel:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 192)

CreateToggle("🛡️ Bypass Detection", "Anti-anti-cheat measures", fishingConfig.bypassDetection, function(v)
    fishingConfig.bypassDetection = v
    print("[Fishing] Bypass Detection:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 244)

-- Update canvas size
fishingContainer.Size = UDim2.new(1, 0, 0, 264 + 280 + 20)
fishingContent.CanvasSize = UDim2.new(0, 0, 0, 264 + 280 + 20)

-- ═══════════════════════════════════════════════════════════
-- FISHING V2 UI CONTENT - IMPROVED
-- ═══════════════════════════════════════════════════════════

local fishingV2Content = Instance.new("ScrollingFrame")
fishingV2Content.Name = "FishingV2Content"
fishingV2Content.Size = UDim2.new(1, -24, 1, -24)
fishingV2Content.Position = UDim2.new(0, 12, 0, 12)
fishingV2Content.BackgroundTransparency = 1
fishingV2Content.Visible = false
fishingV2Content.ScrollBarThickness = 6
fishingV2Content.ScrollBarImageColor3 = ACCENT
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 800)
fishingV2Content.Parent = content

-- Container for V2 content
local v2ContentContainer = Instance.new("Frame")
v2ContentContainer.Name = "V2ContentContainer"
v2ContentContainer.Size = UDim2.new(1, 0, 0, 800)
v2ContentContainer.BackgroundTransparency = 1
v2ContentContainer.Parent = fishingV2Content

-- V2 Stats Panel
local v2StatsPanel = Instance.new("Frame")
v2StatsPanel.Size = UDim2.new(1, 0, 0, 160)
v2StatsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
v2StatsPanel.BorderSizePixel = 0
v2StatsPanel.Parent = v2ContentContainer

local v2StatsCorner = Instance.new("UICorner")
v2StatsCorner.CornerRadius = UDim.new(0,8)
v2StatsCorner.Parent = v2StatsPanel

local v2StatsTitle = Instance.new("TextLabel")
v2StatsTitle.Size = UDim2.new(1, -24, 0, 28)
v2StatsTitle.Position = UDim2.new(0,12,0,8)
v2StatsTitle.BackgroundTransparency = 1
v2StatsTitle.Font = Enum.Font.GothamBold
v2StatsTitle.TextSize = 14
v2StatsTitle.Text = "🚀 AI FISHING STATISTICS"
v2StatsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
v2StatsTitle.Parent = v2StatsPanel

local v2FishCountLabel = Instance.new("TextLabel")
v2FishCountLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2FishCountLabel.Position = UDim2.new(0,12,0,40)
v2FishCountLabel.BackgroundTransparency = 1
v2FishCountLabel.Font = Enum.Font.Gotham
v2FishCountLabel.TextSize = 13
v2FishCountLabel.Text = "🎣 Total Fish: 0"
v2FishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
v2FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
v2FishCountLabel.Parent = v2StatsPanel

local v2InstantLabel = Instance.new("TextLabel")
v2InstantLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2InstantLabel.Position = UDim2.new(0.5,4,0,40)
v2InstantLabel.BackgroundTransparency = 1
v2InstantLabel.Font = Enum.Font.Gotham
v2InstantLabel.TextSize = 13
v2InstantLabel.Text = "⚡ Instant Catches: 0"
v2InstantLabel.TextColor3 = Color3.fromRGB(255,215,0)
v2InstantLabel.TextXAlignment = Enum.TextXAlignment.Left
v2InstantLabel.Parent = v2StatsPanel

local v2SpotsLabel = Instance.new("TextLabel")
v2SpotsLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2SpotsLabel.Position = UDim2.new(0,12,0,68)
v2SpotsLabel.BackgroundTransparency = 1
v2SpotsLabel.Font = Enum.Font.Gotham
v2SpotsLabel.TextSize = 13
v2SpotsLabel.Text = "📍 Spots Found: 0"
v2SpotsLabel.TextColor3 = Color3.fromRGB(200,220,255)
v2SpotsLabel.TextXAlignment = Enum.TextXAlignment.Left
v2SpotsLabel.Parent = v2StatsPanel

local v2StatusLabel = Instance.new("TextLabel")
v2StatusLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2StatusLabel.Position = UDim2.new(0.5,4,0,68)
v2StatusLabel.BackgroundTransparency = 1
v2StatusLabel.Font = Enum.Font.Gotham
v2StatusLabel.TextSize = 13
v2StatusLabel.Text = "📊 Status: Idle"
v2StatusLabel.TextColor3 = Color3.fromRGB(255,200,255)
v2StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2StatusLabel.Parent = v2StatsPanel

local v2EfficiencyLabel = Instance.new("TextLabel")
v2EfficiencyLabel.Size = UDim2.new(1, -24, 0, 24)
v2EfficiencyLabel.Position = UDim2.new(0,12,0,96)
v2EfficiencyLabel.BackgroundTransparency = 1
v2EfficiencyLabel.Font = Enum.Font.Gotham
v2EfficiencyLabel.TextSize = 13
v2EfficiencyLabel.Text = "📈 Efficiency: 0% | Last Action: None"
v2EfficiencyLabel.TextColor3 = Color3.fromRGB(200,255,255)
v2EfficiencyLabel.TextXAlignment = Enum.TextXAlignment.Left
v2EfficiencyLabel.Parent = v2StatsPanel

local v2AFKLabel = Instance.new("TextLabel")
v2AFKLabel.Size = UDim2.new(1, -24, 0, 24)
v2AFKLabel.Position = UDim2.new(0,12,0,120)
v2AFKLabel.BackgroundTransparency = 1
v2AFKLabel.Font = Enum.Font.Gotham
v2AFKLabel.TextSize = 13
v2AFKLabel.Text = "🛡️ Anti-AFK: 0s | Cast Delay: 2s | Reel Delay: 0.5s"
v2AFKLabel.TextColor3 = Color3.fromRGB(180,180,255)
v2AFKLabel.TextXAlignment = Enum.TextXAlignment.Left
v2AFKLabel.Parent = v2StatsPanel

-- V2 Controls Panel
local v2ControlsPanel = Instance.new("Frame")
v2ControlsPanel.Size = UDim2.new(1, 0, 0, 120)
v2ControlsPanel.Position = UDim2.new(0, 0, 0, 172)
v2ControlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
v2ControlsPanel.BorderSizePixel = 0
v2ControlsPanel.Parent = v2ContentContainer

local v2ControlsCorner = Instance.new("UICorner")
v2ControlsCorner.CornerRadius = UDim.new(0,8)
v2ControlsCorner.Parent = v2ControlsPanel

local v2ControlsTitle = Instance.new("TextLabel")
v2ControlsTitle.Size = UDim2.new(1, -24, 0, 28)
v2ControlsTitle.Position = UDim2.new(0,12,0,8)
v2ControlsTitle.BackgroundTransparency = 1
v2ControlsTitle.Font = Enum.Font.GothamBold
v2ControlsTitle.TextSize = 14
v2ControlsTitle.Text = "🎮 AI FISHING CONTROLS"
v2ControlsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2ControlsTitle.TextXAlignment = Enum.TextXAlignment.Left
v2ControlsTitle.Parent = v2ControlsPanel

-- V2 Start/Stop Button
local v2FishingButton = Instance.new("TextButton")
v2FishingButton.Size = UDim2.new(0, 200, 0, 50)
v2FishingButton.Position = UDim2.new(0, 12, 0, 40)
v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
v2FishingButton.Font = Enum.Font.GothamBold
v2FishingButton.TextSize = 14
v2FishingButton.Text = "🤖 START AI FISHING"
v2FishingButton.TextColor3 = Color3.fromRGB(30,30,30)
v2FishingButton.AutoButtonColor = false
v2FishingButton.Parent = v2ControlsPanel

local v2FishingBtnCorner = Instance.new("UICorner")
v2FishingBtnCorner.CornerRadius = UDim.new(0,6)
v2FishingBtnCorner.Parent = v2FishingButton

-- V2 Status Indicator
local v2ActiveStatusLabel = Instance.new("TextLabel")
v2ActiveStatusLabel.Size = UDim2.new(0.5, -16, 0, 50)
v2ActiveStatusLabel.Position = UDim2.new(0, 224, 0, 40)
v2ActiveStatusLabel.BackgroundTransparency = 1
v2ActiveStatusLabel.Font = Enum.Font.GothamBold
v2ActiveStatusLabel.TextSize = 12
v2ActiveStatusLabel.Text = "⭕ AI OFFLINE"
v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
v2ActiveStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2ActiveStatusLabel.Parent = v2ControlsPanel

-- V2 Features Panel
local v2FeaturesPanel = Instance.new("Frame")
v2FeaturesPanel.Size = UDim2.new(1, 0, 0, 380)
v2FeaturesPanel.Position = UDim2.new(0, 0, 0, 304)
v2FeaturesPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
v2FeaturesPanel.BorderSizePixel = 0
v2FeaturesPanel.Parent = v2ContentContainer

local v2FeaturesCorner = Instance.new("UICorner")
v2FeaturesCorner.CornerRadius = UDim.new(0,8)
v2FeaturesCorner.Parent = v2FeaturesPanel

local v2FeaturesTitle = Instance.new("TextLabel")
v2FeaturesTitle.Size = UDim2.new(1, -24, 0, 28)
v2FeaturesTitle.Position = UDim2.new(0,12,0,8)
v2FeaturesTitle.BackgroundTransparency = 1
v2FeaturesTitle.Font = Enum.Font.GothamBold
v2FeaturesTitle.TextSize = 14
v2FeaturesTitle.Text = "⚙️ AI FISHING SETTINGS"
v2FeaturesTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2FeaturesTitle.TextXAlignment = Enum.TextXAlignment.Left
v2FeaturesTitle.Parent = v2FeaturesPanel

-- Create V2 Toggles - IMPROVED LAYOUT
CreateToggle("🤖 AI Fishing System", "Enable automatic fishing", fishingV2Config.enabled, function(v)
    fishingV2Config.enabled = v
    if v and fishingV2Active then
        StopFishingV2()
    end
    print("[Fishing V2] AI System:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 36)

CreateToggle("⚡ Instant Reel", "Auto reel when ! appears", fishingV2Config.instantReel, function(v)
    fishingV2Config.instantReel = v
    print("[Fishing V2] Instant Reel:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 88)

CreateToggle("📡 Fishing Radar", "Show nearby fishing spots", fishingV2Config.radarEnabled, function(v)
    fishingV2Config.radarEnabled = v
    if v and fishingV2Active then
        StartRadar()
    else
        StopRadar()
    end
    print("[Fishing V2] Fishing Radar:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 140)

CreateToggle("🛡️ Anti-AFK", "Prevent AFK detection", fishingV2Config.antiAfk, function(v)
    fishingV2Config.antiAfk = v
    print("[Fishing V2] Anti-AFK:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 192)

CreateToggle("🎯 Smart Detection", "Auto-detect fishing prompts", fishingV2Config.smartDetection, function(v)
    fishingV2Config.smartDetection = v
    print("[Fishing V2] Smart Detection:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 244)

CreateToggle("🔧 Proximity Only", "Use only proximity prompts", fishingV2Config.useProximityOnly, function(v)
    fishingV2Config.useProximityOnly = v
    print("[Fishing V2] Proximity Only:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 296)

CreateToggle("📍 Multi-Spot Fishing", "Fish at multiple spots", fishingV2Config.multiSpotFishing, function(v)
    fishingV2Config.multiSpotFishing = v
    print("[Fishing V2] Multi-Spot Fishing:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 348)

-- Update canvas size
v2ContentContainer.Size = UDim2.new(1, 0, 0, 304 + 380 + 20)
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 304 + 380 + 20)

-- TELEPORT UI (Placeholder)
local teleportContent = Instance.new("Frame")
teleportContent.Name = "TeleportContent"
teleportContent.Size = UDim2.new(1, -24, 1, -24)
teleportContent.Position = UDim2.new(0, 12, 0, 12)
teleportContent.BackgroundTransparency = 1
teleportContent.Visible = false
teleportContent.Parent = content

local teleportLabel = Instance.new("TextLabel")
teleportLabel.Size = UDim2.new(1, 0, 1, 0)
teleportLabel.BackgroundTransparency = 1
teleportLabel.Font = Enum.Font.GothamBold
teleportLabel.TextSize = 16
teleportLabel.Text = "Teleport Feature\n(Coming Soon)"
teleportLabel.TextColor3 = Color3.fromRGB(200,200,200)
teleportLabel.TextYAlignment = Enum.TextYAlignment.Center
teleportLabel.Parent = teleportContent

-- SETTINGS UI (Placeholder)
local settingsContent = Instance.new("Frame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -24, 1, -24)
settingsContent.Position = UDim2.new(0, 12, 0, 12)
settingsContent.BackgroundTransparency = 1
settingsContent.Visible = false
settingsContent.Parent = content

local settingsLabel = Instance.new("TextLabel")
settingsLabel.Size = UDim2.new(1, 0, 1, 0)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Font = Enum.Font.GothamBold
settingsLabel.TextSize = 16
settingsLabel.Text = "Settings\n(Coming Soon)"
settingsLabel.TextColor3 = Color3.fromRGB(200,200,200)
settingsLabel.TextYAlignment = Enum.TextYAlignment.Center
settingsLabel.Parent = settingsContent

-- ═══════════════════════════════════════════════════════════
-- ENHANCED FISHING FUNCTIONS - IMPROVED
-- ═══════════════════════════════════════════════════════════

local radarParts = {}
local radarBeams = {}

-- ENHANCED RADAR SYSTEM
local function StartRadar()
    if not fishingV2Config.radarEnabled then return end
    
    print("[Radar] Starting fishing radar...")
    
    radarConnection = RunService.Heartbeat:Connect(function()
        if not fishingV2Config.radarEnabled or not fishingV2Active then 
            StopRadar()
            return 
        end
        
        -- Cleanup old radar parts
        for _, part in pairs(radarParts) do
            if part then part:Destroy() end
        end
        for _, beam in pairs(radarBeams) do
            if beam then beam:Destroy() end
        end
        radarParts = {}
        radarBeams = {}
        
        -- Find fishing spots
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Enhanced spot detection
        local nearbySpots = {}
        local waterParts = {}
        
        -- Find water bodies
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") then
                local distance = (rootPart.Position - part.Position).Magnitude
                if distance <= fishingV2Config.fishingSpotRadius then
                    local name = part.Name:lower()
                    local material = part.Material.Name:lower()
                    
                    -- Enhanced detection criteria
                    if name:find("water") or name:find("pond") or name:find("lake") or 
                       name:find("river") or name:find("ocean") or name:find("sea") or
                       material:find("water") or part.BrickColor == BrickColor.new("Bright blue") then
                        table.insert(waterParts, part)
                    end
                    
                    -- Look for fishing-specific objects
                    if name:find("fish") or name:find("spot") or name:find("dock") or
                       name:find("pier") or name:find("boat") then
                        table.insert(nearbySpots, part)
                    end
                end
            end
        end
        
        -- Create radar indicators for water spots
        for _, spot in pairs(waterParts) do
            local radarPart = Instance.new("Part")
            radarPart.Name = "FishingRadarIndicator"
            radarPart.Size = Vector3.new(4, 4, 4)
            radarPart.Position = spot.Position + Vector3.new(0, 10, 0)
            radarPart.Anchored = true
            radarPart.CanCollide = false
            radarPart.Material = Enum.Material.Neon
            radarPart.BrickColor = BrickColor.new("Bright green")
            radarPart.Transparency = 0.2
            
            -- Enhanced glow effect
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 3
            pointLight.Range = 12
            pointLight.Color = Color3.new(0, 1, 0)
            pointLight.Parent = radarPart
            
            -- Surface GUI
            local surfaceGui = Instance.new("SurfaceGui")
            surfaceGui.Parent = radarPart
            surfaceGui.AlwaysOnTop = true
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "🎣"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextScaled = true
            label.Parent = surfaceGui
            
            radarPart.Parent = Workspace
            table.insert(radarParts, radarPart)
            
            -- Beam to spot
            local beam = Instance.new("Beam")
            local attachment0 = Instance.new("Attachment")
            local attachment1 = Instance.new("Attachment")
            
            attachment0.Parent = radarPart
            attachment1.Parent = spot
            
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Color = ColorSequence.new(Color3.new(0, 1, 0))
            beam.Width0 = 0.4
            beam.Width1 = 0.1
            beam.Brightness = 2
            beam.Parent = radarPart
            
            table.insert(radarBeams, beam)
        end
        
        fishingStats.spotsFound = #waterParts + #nearbySpots
    end)
end

local function StopRadar()
    if radarConnection then
        radarConnection:Disconnect()
        radarConnection = nil
    end
    
    for _, part in pairs(radarParts) do
        if part then part:Destroy() end
    end
    for _, beam in pairs(radarBeams) do
        if beam then beam:Destroy() end
    end
    radarParts = {}
    radarBeams = {}
    
    print("[Radar] Fishing radar stopped")
end

-- ENHANCED FISHING DETECTION
local function FindFishingProximityPrompt()
    local char = player.Character
    if not char then return nil end
    
    -- Enhanced prompt detection
    for _, descendant in pairs(char:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
            local objectText = descendant.ObjectText and descendant.ObjectText:lower() or ""
            local name = descendant.Name:lower()
            
            -- Enhanced fishing detection keywords
            if actionText:find("cast") or actionText:find("fish") or actionText:find("reel") or
               objectText:find("cast") or objectText:find("fish") or objectText:find("reel") or
               name:find("cast") or name:find("fish") or name:find("reel") then
                return descendant
            end
        end
    end
    
    -- Check workspace for fishing prompts
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
            local objectText = descendant.ObjectText and descendant.ObjectText:lower() or ""
            
            if actionText:find("cast") or actionText:find("fish") or 
               objectText:find("cast") or objectText:find("fish") then
                return descendant
            end
        end
    end
    
    return nil
end

-- ENHANCED INSTANT REEL DETECTION
local function DetectFishBite()
    if not fishingV2Config.instantReel then return false end
    
    local success, result = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Enhanced UI detection
        for _, guiObject in pairs(playerGui:GetDescendants()) do
            if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
                local text = guiObject.Text or ""
                local name = guiObject.Name:lower()
                
                -- Enhanced bite detection patterns
                if text:find("!") or text:find("Bite") or text:find("PULL") or 
                   text:find("Catch") or text:find("Fish") or text:find("Reel") or
                   name:find("bite") or name:find("pull") or name:find("catch") or
                   name:find("fish") or name:find("reel") then
                    if guiObject.Visible then
                        print("[Fishing V2] Fish bite detected! -", text)
                        return true
                    end
                end
            end
            
            -- Enhanced ImageLabel detection
            if guiObject:IsA("ImageLabel") then
                local name = guiObject.Name:lower()
                if name:find("bite") or name:find("fish") or name:find("catch") or
                   name:find("reel") or name:find("hook") then
                    if guiObject.Visible then
                        print("[Fishing V2] Fishing UI detected!")
                        return true
                    end
                end
            end
            
            -- Enhanced Frame detection for fishing minigames
            if guiObject:IsA("Frame") then
                local name = guiObject.Name:lower()
                if name:find("fish") or name:find("minigame") or name:find("reel") then
                    if guiObject.Visible then
                        print("[Fishing V2] Fishing minigame detected!")
                        return true
                    end
                end
            end
        end
        
        return false
    end)
    
    return success and result or false
end

-- ENHANCED FISHING ACTION
local function PerformFishingCast()
    local prompt = FindFishingProximityPrompt()
    if prompt and prompt.Enabled then
        fireproximityprompt(prompt)
        fishingStats.lastAction = "Casting Line"
        print("[Fishing V2] Casting fishing rod...")
        
        -- Enhanced: Try multiple methods
        task.spawn(function()
            -- Method 1: Proximity prompt
            for i = 1, 3 do
                fireproximityprompt(prompt)
                task.wait(0.1)
            end
            
            -- Method 2: Virtual key presses
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        
        return true
    end
    return false
end

local function PerformFishingReel()
    local prompt = FindFishingProximityPrompt()
    if prompt and prompt.Enabled then
        fireproximityprompt(prompt)
        fishingStats.lastAction = "Reeling Fish"
        print("[Fishing V2] Reeling fish...")
        
        -- Enhanced: Multiple reel attempts
        task.spawn(function()
            for i = 1, 5 do
                fireproximityprompt(prompt)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.05)
            end
        end)
        
        return true
    end
    return false
end

-- ENHANCED ANTI-AFK SYSTEM
local function AntiAFK()
    if not fishingV2Config.antiAfk then return end
    
    antiAfkTime = antiAfkTime + 1
    if antiAfkTime >= 30 then -- Reduced from 45 to 30 for better anti-afk
        antiAfkTime = 0
        
        -- Enhanced anti-afk: Multiple movement patterns
        pcall(function()
            -- Mouse movement
            local x, y = math.random(100, 200), math.random(100, 200)
            VirtualInputManager:SendMouseMoveEvent(x, y, Workspace)
            task.wait(0.1)
            
            -- Key presses
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
        end)
        
        print("[Anti-AFK] Enhanced anti-AFK action performed")
    end
end

-- ENHANCED FISHING V2 MAIN LOOP
local function StartFishingV2()
    if fishingV2Active then 
        print("[Fishing V2] Already fishing!")
        return 
    end
    
    fishingV2Active = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Initializing AI Fishing"
    
    print("[Fishing V2] Starting Enhanced AI Fishing System...")
    print("[Fishing V2] Instant Reel:", fishingV2Config.instantReel and "ENABLED" or "DISABLED")
    print("[Fishing V2] Radar:", fishingV2Config.radarEnabled and "ENABLED" or "DISABLED")
    print("[Fishing V2] Smart Detection:", fishingV2Config.smartDetection and "ENABLED" or "DISABLED")
    
    -- Start radar if enabled
    if fishingV2Config.radarEnabled then
        StartRadar()
    end
    
    v2Connection = RunService.Heartbeat:Connect(function()
        if not fishingV2Active then return end
        
        -- Enhanced Anti-AFK
        AntiAFK()
        
        -- Check if character exists
        local character = player.Character
        if not character then 
            fishingStats.lastAction = "No Character Found"
            return 
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            fishingStats.lastAction = "Character Dead"
            return
        end
        
        -- Enhanced instant reel detection
        if fishingV2Config.instantReel then
            if DetectFishBite() then
                fishingStats.lastAction = "Instant Reel Triggered"
                print("[Fishing V2] Fish bite detected! Performing instant reel...")
                
                -- Enhanced reel sequence
                for i = 1, 8 do -- Increased attempts
                    if PerformFishingReel() then
                        fishingStats.instantCatches = fishingStats.instantCatches + 1
                        fishingStats.fishCaught = fishingStats.fishCaught + 1
                        fishingStats.lastAction = "Fish Caught (Instant)"
                        print("[Fishing V2] Fish caught with instant reel! Total:", fishingStats.fishCaught)
                        break
                    end
                    task.wait(0.1)
                end
                
                -- Wait before next cast
                task.wait(fishingV2Config.castDelay)
                return
            end
        end
        
        -- Enhanced fishing cycle
        local currentTime = tick()
        
        -- CASTING PHASE - Enhanced
        if not isCasting and (currentTime - lastCastTime > fishingV2Config.castDelay) then
            fishingStats.lastAction = "Attempting Enhanced Cast"
            fishingStats.attempts = fishingStats.attempts + 1
            
            if PerformFishingCast() then
                isCasting = true
                lastCastTime = currentTime
                fishingStats.lastAction = "Casting Successful"
                print("[Fishing V2] Enhanced cast successful, waiting for fish...")
            else
                fishingStats.lastAction = "Cast Failed - No Fishing Prompt"
            end
        end
        
        -- REELING PHASE - Enhanced (with dynamic delay)
        if isCasting and (currentTime - lastCastTime > fishingV2Config.reelDelay) and not isReeling then
            fishingStats.lastAction = "Attempting Enhanced Reel"
            
            if PerformFishingReel() then
                isReeling = true
                lastReelTime = currentTime
                fishingStats.lastAction = "Reeling Successful"
                fishingStats.fishCaught = fishingStats.fishCaught + 1
                
                -- Enhanced: Reset fishing cycle with success
                spawn(function()
                    task.wait(1.5) -- Slightly longer wait after success
                    isCasting = false
                    isReeling = false
                    fishingStats.lastAction = "Fishing Cycle Complete"
                end)
            else
                fishingStats.lastAction = "Reel Failed - No Fish"
                -- Enhanced: Shorter wait on failure
                spawn(function()
                    task.wait(0.5)
                    isCasting = false
                    isReeling = false
                end)
            end
        end
        
        -- Enhanced status updates
        if isCasting and not isReeling then
            local waitTime = currentTime - lastCastTime
            fishingStats.lastAction = string.format("Waiting for Bite (%.1fs)", waitTime)
        elseif isCasting and isReeling then
            fishingStats.lastAction = "Reeling in Progress"
        end
    end)
    
    print("[Fishing V2] Enhanced AI Fishing started successfully!")
end

local function StopFishingV2()
    fishingV2Active = false
    isCasting = false
    isReeling = false
    fishingStats.lastAction = "System Stopped"
    
    if v2Connection then
        v2Connection:Disconnect()
        v2Connection = nil
    end
    
    StopRadar()
    
    print("[Fishing V2] Enhanced AI Fishing stopped")
    print("[Fishing V2] Session Summary:")
    print("[Fishing V2] - Total fish caught:", fishingStats.fishCaught)
    print("[Fishing V2] - Instant catches:", fishingStats.instantCatches)
    print("[Fishing V2] - Total attempts:", fishingStats.attempts)
    print("[Fishing V2] - Spots found:", fishingStats.spotsFound)
end

-- ═══════════════════════════════════════════════════════════
-- ENHANCED FISHING V1 FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function SafeGetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function SafeGetHumanoid()
    local char = SafeGetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function GetFishingRod()
    local success, result = pcall(function()
        -- Enhanced rod detection
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("rod") or name:find("pole") or name:find("fishing") or
                       name:find("kail") or name:find("pancing") then
                        return item
                    end
                end
            end
        end
        
        local char = player.Character
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("rod") or name:find("pole") or name:find("fishing") or
                       name:find("kail") or name:find("pancing") then
                        return item
                    end
                end
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

local function EquipRod()
    local success = pcall(function()
        local rod = GetFishingRod()
        if not rod then 
            print("[Fishing] No fishing rod found!")
            return false 
        end
        
        if rod.Parent == player.Backpack then
            local humanoid = SafeGetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.2) -- Slightly longer wait for equip
                return true
            end
        end
        
        return rod.Parent == player.Character
    end)
    
    return success
end

-- ENHANCED INSTANT FISHING METHODS
local function InstantFishProximity()
    local success = pcall(function()
        local char = SafeGetCharacter()
        if not char then return false end
        
        -- Enhanced proximity detection
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local objText = descendant.ObjectText and descendant.ObjectText:lower() or ""
                local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
                local name = descendant.Name:lower()
                
                -- Enhanced fishing keywords
                if objText:find("fish") or objText:find("cast") or objText:find("catch") or
                   objText:find("reel") or actionText:find("fish") or actionText:find("cast") or 
                   actionText:find("catch") or actionText:find("reel") or name:find("fish") or
                   name:find("cast") or name:find("reel") then
                    
                    if descendant.Enabled then
                        -- Enhanced: Multiple trigger attempts
                        for i = 1, 3 do
                            fireproximityprompt(descendant)
                            task.wait(0.05)
                        end
                        return true
                    end
                end
            end
        end
        
        return false
    end)
    
    return success
end

local function InstantFishRemote()
    local success = pcall(function()
        if not ReplicatedStorage then return false end
        
        -- Enhanced remote event detection
        local remotesFound = 0
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("catch") or 
                   name:find("reel") or name:find("pancing") or name:find("kail") then
                    
                    if remote:IsA("RemoteEvent") then
                        -- Enhanced: Try multiple fishing commands
                        local commands = {"Cast", "Fish", "Catch", "Reel", "Start", "Activate"}
                        for _, cmd in ipairs(commands) do
                            pcall(function() remote:FireServer(cmd) end)
                            task.wait(0.05)
                        end
                        remotesFound = remotesFound + 1
                    elseif remote:IsA("RemoteFunction") then
                        local commands = {"Cast", "Fish", "Catch", "Reel", "Start"}
                        for _, cmd in ipairs(commands) do
                            pcall(function() remote:InvokeServer(cmd) end)
                            task.wait(0.05)
                        end
                        remotesFound = remotesFound + 1
                    end
                end
            end
        end
        
        return remotesFound > 0
    end)
    
    return success
end

-- ENHANCED MASTER INSTANT FISHING FUNCTION
local function InstantFish()
    if not fishingActive then return end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    -- Enhanced: Ensure rod is equipped
    if not EquipRod() then
        fishingStats.lastAction = "No Fishing Rod"
        return
    end
    
    local success = false
    
    -- Enhanced fishing methods based on config
    if fishingConfig.instantFishing or fishingConfig.blantantMode then
        -- Method 1: Proximity prompts (most common)
        if InstantFishProximity() then
            success = true
            fishingStats.lastAction = "Proximity Fishing"
        end
        
        -- Method 2: Remote events
        if InstantFishRemote() then
            success = true
            fishingStats.lastAction = "Remote Fishing"
        end
        
        -- Method 3: Virtual inputs (enhanced)
        if fishingConfig.blantantMode then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
        end
    end
    
    if success then
        fishingStats.fishCaught = fishingStats.fishCaught + 1
        fishingStats.lastAction = "Fish Caught!"
    else
        fishingStats.lastAction = "Fishing Attempt Failed"
    end
end

-- ENHANCED Start Fishing V1
local function StartFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting Enhanced Fishing"
    
    print("[Fishing] Starting Enhanced Instant Fishing...")
    print("[Fishing] Mode:", fishingConfig.blantantMode and "BLATANT" 
          and fishingConfig.instantFishing and "INSTANT" or "NORMAL")
    
    -- Main fishing loop
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        pcall(InstantFish)
        
        -- Enhanced delay system
        if fishingConfig.blantantMode then
            task.wait(0.001) -- Ultra fast
        elseif fishingConfig.instantFishing then
            task.wait(0.02) -- Fast
        else
            task.wait(fishingConfig.fishingDelay) -- Normal
        end
    end)
end

local function StopFishing()
    fishingActive = false
    fishingStats.lastAction = "Fishing Stopped"
    
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    
    print("[Fishing] Enhanced fishing stopped")
    print("[Fishing] Session Summary:")
    print("[Fishing] - Total fish caught:", fishingStats.fishCaught)
    print("[Fishing] - Total attempts:", fishingStats.attempts)
end

-- ═══════════════════════════════════════════════════════════
-- ENHANCED EVENT HANDLERS
-- ═══════════════════════════════════════════════════════════

-- Enhanced Fishing V1 Button Handler
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🚀 START INSTANT FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        TweenService:Create(fishingButton, TweenInfo.new(0.3), {
            BackgroundColor3 = ACCENT
        }):Play()
    else
        StartFishing()
        fishingButton.Text = "⏹️ STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✅ FISHING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        TweenService:Create(fishingButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        }):Play()
    end
end)

-- Enhanced Fishing V2 Button Handler
v2FishingButton.MouseButton1Click:Connect(function()
    if fishingV2Active then
        StopFishingV2()
        v2FishingButton.Text = "🤖 START AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        v2ActiveStatusLabel.Text = "⭕ AI OFFLINE"
        v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        TweenService:Create(v2FishingButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        }):Play()
    else
        StartFishingV2()
        v2FishingButton.Text = "⏹️ STOP AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        v2ActiveStatusLabel.Text = "✅ AI FISHING ACTIVE"
        v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        TweenService:Create(v2FishingButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        }):Play()
    end
end)

-- Enhanced menu navigation
local activeMenu = "Fishing V1"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Enhanced visual feedback
        for n, b in pairs(menuButtons) do
            TweenService:Create(b, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(20,20,20)
            }):Play()
        end
        
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(32,8,8)
        }):Play()
        
        cTitle.Text = name
        
        -- Enhanced content switching
        fishingContent.Visible = (name == "Fishing V1")
        fishingV2Content.Visible = (name == "Fishing V2")
        teleportContent.Visible = (name == "Teleport")
        settingsContent.Visible = (name == "Settings")
        
        print("[UI] Switched to:", name)
    end)
end

-- Highlight fishing menu by default with animation
spawn(function()
    wait(0.5)
    TweenService:Create(menuButtons["Fishing V1"], TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(32,8,8)
    }):Play()
end)

-- WINDOW CONTROLS FUNCTIONALITY
local uiOpen = true

-- Enhanced Tray Icon Functions
local function showTrayIcon()
    trayIcon.Visible = true
    TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency = 0.7}):Play()
end

local function hideTrayIcon()  
    TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    wait(0.3)
    trayIcon.Visible = false
end

-- Enhanced Show Main UI
local function showMainUI()
    container.Visible = true
    TweenService:Create(container, TweenInfo.new(0.4), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT),
        Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.4), {ImageTransparency = 0.85}):Play()
    
    hideTrayIcon()
    uiOpen = true
    print("[UI] Main UI shown")
end

-- Enhanced Hide Main UI (ke tray)
local function hideMainUI()
    TweenService:Create(container, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    
    wait(0.3)
    container.Visible = false
    
    showTrayIcon()
    uiOpen = false
    print("[UI] Main UI hidden to tray")
end

-- Enhanced Minimize Function
local function minimizeUI()
    hideMainUI()
end

-- Enhanced Close Function  
local function closeUI()
    hideMainUI()
end

-- Enhanced Tray Icon Interactions
trayIcon.MouseButton1Click:Connect(function()
    showMainUI()
end)

trayIcon.MouseEnter:Connect(function()
    TweenService:Create(trayIcon, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.2), {ImageTransparency = 0.6}):Play()
end)

trayIcon.MouseLeave:Connect(function()
    TweenService:Create(trayIcon, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.2), {ImageTransparency = 0.7}):Play()
end)

-- Enhanced Window Controls
minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
end)

minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 40, 40)}):Play()
end)

-- Button Clicks with enhanced feedback
minimizeBtn.MouseButton1Click:Connect(minimizeUI)
closeBtn.MouseButton1Click:Connect(closeUI)

-- Enhanced Stats Update Loop
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        local efficiency = fishingStats.attempts > 0 and (fishingStats.fishCaught / fishingStats.attempts) * 100 or 0
        
        -- Enhanced V1 Stats
        fishCountLabel.Text = string.format("🎣 Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("📈 Rate: %.2f/s", rate)
        memLabel.Text = string.format("💾 Memory: %d KB | 🎣 Fish: %d", math.floor(collectgarbage("count")), fishingStats.fishCaught)
        attemptsLabel.Text = string.format("🔄 Attempts: %d", fishingStats.attempts)
        successLabel.Text = string.format("✅ Success: %.1f%%", efficiency)
        timeLabel.Text = string.format("⏱️ Session Time: %ds", math.floor(elapsed))
        
        -- Enhanced V2 Stats
        v2FishCountLabel.Text = string.format("🎣 Total Fish: %d", fishingStats.fishCaught)
        v2InstantLabel.Text = string.format("⚡ Instant Catches: %d", fishingStats.instantCatches)
        v2SpotsLabel.Text = string.format("📍 Spots Found: %d", fishingStats.spotsFound)
        v2StatusLabel.Text = string.format("📊 Status: %s", fishingStats.lastAction)
        v2EfficiencyLabel.Text = string.format("📈 Efficiency: %.1f%% | Last Action: %s", efficiency, fishingStats.lastAction)
        v2AFKLabel.Text = string.format("🛡️ Anti-AFK: %ds | Cast Delay: %ds | Reel Delay: %.1fs", antiAfkTime, fishingV2Config.castDelay, fishingV2Config.reelDelay)
        
        wait(0.3)
    end
end)

-- Start dengan UI terbuka
showMainUI()

print("[Kaitun Fish It V2] Enhanced UI Loaded Successfully!")
print("🎣 Fishing V1 - Enhanced instant fishing system")
print("🚀 Fishing V2 - Advanced AI fishing with smart detection")
print("🎣 Click [-] to minimize to tray")
print("🎣 Click [🗙] to close to tray") 
print("🎣 Click tray icon to reopen UI")

-- Enhanced initialization check
wait(1)
if screen and screen.Parent then
    print("✅ Enhanced UI successfully created!")
    print("✅ All fishing systems initialized!")
    print("✅ Ready for fishing operations!")
else
    print("❌ UI failed to create!")
end
