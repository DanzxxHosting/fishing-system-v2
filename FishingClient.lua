-- UI-Only: Neon Panel dengan Tray Icon + Enhanced Instant Fishing + FISHING V2 & V3 FIXED
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
    fishingDelay = 0.1,
    blantantMode = false,
    ultraSpeed = false,
    perfectCast = true,
    autoReel = true,
    bypassDetection = true
}

-- FISHING V2 CONFIG - 3x LEBIH CEPAT
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
    instantReel = true,
    castDelay = 0.3,
    reelDelay = 0.1,
    useProximityOnly = true
}

-- FISHING V3 CONFIG - SUPER BLATANT 5x SPEED
local fishingV3Config = {
    enabled = false,
    superBlatant = true,
    delayCast = 0.05,    -- Bypass delay untuk cast
    delayComplete = 0.02, -- Bypass delay untuk complete
    blatantMode = true,
    speedMultiplier = 5,  -- 5x speed
    autoPerfection = true,
    ultraInstant = true,
    maxSpeed = true
}

-- SETTINGS CONFIG
local settingsConfig = {
    stableFPS = false,
    targetFPS = 90,
    blackScreen = false,
    walkSpeed = false,
    walkSpeedValue = 25,
    infinityJump = false,
    noClip = false,
    antiLag = false
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successRate = 0,
    rareFish = 0,
    totalValue = 0,
    instantCatches = 0,
    lastAction = "Idle",
    v3Speed = 0
}

local fishingActive = false
local fishingV2Active = false
local fishingV3Active = false
local fishingConnection, reelConnection, v2Connection, v3Connection
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
title.Text = "⚡ KAITUN FISH IT V3"
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
sTitle.Text = "Kaitun V3"
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
    {"Fishing V3", "⚡"},
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
-- FISHING V1 UI CONTENT
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

-- Toggle Helper Function
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

-- Create Toggles untuk V1
CreateToggle("⚡ Instant Fishing", "Max speed casting & catching", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    if v then
        fishingConfig.fishingDelay = 0.1
        fishingConfig.autoReel = true
        print("[Fishing] Instant Fishing: ENABLED")
    else
        fishingConfig.fishingDelay = 0.5
        print("[Fishing] Instant Fishing: DISABLED")
    end
end, togglesPanel, 36)

CreateToggle("💥 Blatant Mode", "Ultra fast (may be detected)", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then
        fishingConfig.fishingDelay = 0.05
        fishingConfig.instantFishing = true
        fishingConfig.autoReel = true
        print("[Fishing] Blatant Mode: ENABLED (0.05s delay)")
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
-- FISHING V2 UI CONTENT
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
v2StatsTitle.Text = "🚀 AI FISHING STATISTICS (3x FASTER)"
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
v2AFKLabel.Text = "🛡️ Anti-AFK: 0s | Cast Delay: 0.3s | Reel Delay: 0.1s"
v2AFKLabel.TextColor3 = Color3.fromRGB(180,180,255)
v2AFKLabel.TextXAlignment = Enum.TextXAlignment.Left
v2AFKLabel.Parent = v2StatsPanel

local v2SpeedLabel = Instance.new("TextLabel")
v2SpeedLabel.Size = UDim2.new(1, -24, 0, 24)
v2SpeedLabel.Position = UDim2.new(0,12,0,144)
v2SpeedLabel.BackgroundTransparency = 1
v2SpeedLabel.Font = Enum.Font.GothamBold
v2SpeedLabel.TextSize = 13
v2SpeedLabel.Text = "⚡ SPEED: 3x FASTER THAN V1"
v2SpeedLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
v2SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
v2SpeedLabel.Parent = v2StatsPanel

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
v2FeaturesTitle.Text = "⚙️ AI FISHING SETTINGS (3x FASTER)"
v2FeaturesTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2FeaturesTitle.TextXAlignment = Enum.TextXAlignment.Left
v2FeaturesTitle.Parent = v2FeaturesPanel

-- Create V2 Toggles
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

CreateToggle("🛡️ Anti-AFK", "Prevent AFK detection", fishingV2Config.antiAfk, function(v)
    fishingV2Config.antiAfk = v
    print("[Fishing V2] Anti-AFK:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 140)

CreateToggle("🎯 Smart Detection", "Auto-detect fishing prompts", fishingV2Config.smartDetection, function(v)
    fishingV2Config.smartDetection = v
    print("[Fishing V2] Smart Detection:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 192)

CreateToggle("🔧 Proximity Only", "Use only proximity prompts", fishingV2Config.useProximityOnly, function(v)
    fishingV2Config.useProximityOnly = v
    print("[Fishing V2] Proximity Only:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 244)

CreateToggle("📍 Multi-Spot Fishing", "Fish at multiple spots", fishingV2Config.multiSpotFishing, function(v)
    fishingV2Config.multiSpotFishing = v
    print("[Fishing V2] Multi-Spot Fishing:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 296)

-- Update canvas size
v2ContentContainer.Size = UDim2.new(1, 0, 0, 304 + 380 + 20)
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 304 + 380 + 20)

-- ═══════════════════════════════════════════════════════════
-- FISHING V3 UI CONTENT - SUPER BLATANT 5x SPEED
-- ═══════════════════════════════════════════════════════════

local fishingV3Content = Instance.new("ScrollingFrame")
fishingV3Content.Name = "FishingV3Content"
fishingV3Content.Size = UDim2.new(1, -24, 1, -24)
fishingV3Content.Position = UDim2.new(0, 12, 0, 12)
fishingV3Content.BackgroundTransparency = 1
fishingV3Content.Visible = false
fishingV3Content.ScrollBarThickness = 6
fishingV3Content.ScrollBarImageColor3 = ACCENT
fishingV3Content.CanvasSize = UDim2.new(0, 0, 0, 900)
fishingV3Content.Parent = content

-- Container for V3 content
local v3ContentContainer = Instance.new("Frame")
v3ContentContainer.Name = "V3ContentContainer"
v3ContentContainer.Size = UDim2.new(1, 0, 0, 900)
v3ContentContainer.BackgroundTransparency = 1
v3ContentContainer.Parent = fishingV3Content

-- V3 Stats Panel
local v3StatsPanel = Instance.new("Frame")
v3StatsPanel.Size = UDim2.new(1, 0, 0, 180)
v3StatsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
v3StatsPanel.BorderSizePixel = 0
v3StatsPanel.Parent = v3ContentContainer

local v3StatsCorner = Instance.new("UICorner")
v3StatsCorner.CornerRadius = UDim.new(0,8)
v3StatsCorner.Parent = v3StatsPanel

local v3StatsTitle = Instance.new("TextLabel")
v3StatsTitle.Size = UDim2.new(1, -24, 0, 28)
v3StatsTitle.Position = UDim2.new(0,12,0,8)
v3StatsTitle.BackgroundTransparency = 1
v3StatsTitle.Font = Enum.Font.GothamBold
v3StatsTitle.TextSize = 14
v3StatsTitle.Text = "⚡ SUPER BLATANT FISHING V3 (5x SPEED)"
v3StatsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v3StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
v3StatsTitle.Parent = v3StatsPanel

local v3FishCountLabel = Instance.new("TextLabel")
v3FishCountLabel.Size = UDim2.new(0.5, -8, 0, 24)
v3FishCountLabel.Position = UDim2.new(0,12,0,40)
v3FishCountLabel.BackgroundTransparency = 1
v3FishCountLabel.Font = Enum.Font.Gotham
v3FishCountLabel.TextSize = 13
v3FishCountLabel.Text = "🎣 Total Fish: 0"
v3FishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
v3FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
v3FishCountLabel.Parent = v3StatsPanel

local v3SpeedLabel = Instance.new("TextLabel")
v3SpeedLabel.Size = UDim2.new(0.5, -8, 0, 24)
v3SpeedLabel.Position = UDim2.new(0.5,4,0,40)
v3SpeedLabel.BackgroundTransparency = 1
v3SpeedLabel.Font = Enum.Font.Gotham
v3SpeedLabel.TextSize = 13
v3SpeedLabel.Text = "⚡ Current Speed: 0x"
v3SpeedLabel.TextColor3 = Color3.fromRGB(255,215,0)
v3SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
v3SpeedLabel.Parent = v3StatsPanel

local v3EfficiencyLabel = Instance.new("TextLabel")
v3EfficiencyLabel.Size = UDim2.new(0.5, -8, 0, 24)
v3EfficiencyLabel.Position = UDim2.new(0,12,0,68)
v3EfficiencyLabel.BackgroundTransparency = 1
v3EfficiencyLabel.Font = Enum.Font.Gotham
v3EfficiencyLabel.TextSize = 13
v3EfficiencyLabel.Text = "📈 Efficiency: 0%"
v3EfficiencyLabel.TextColor3 = Color3.fromRGB(200,220,255)
v3EfficiencyLabel.TextXAlignment = Enum.TextXAlignment.Left
v3EfficiencyLabel.Parent = v3StatsPanel

local v3StatusLabel = Instance.new("TextLabel")
v3StatusLabel.Size = UDim2.new(0.5, -8, 0, 24)
v3StatusLabel.Position = UDim2.new(0.5,4,0,68)
v3StatusLabel.BackgroundTransparency = 1
v3StatusLabel.Font = Enum.Font.Gotham
v3StatusLabel.TextSize = 13
v3StatusLabel.Text = "📊 Status: Idle"
v3StatusLabel.TextColor3 = Color3.fromRGB(255,200,255)
v3StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v3StatusLabel.Parent = v3StatsPanel

local v3DelayLabel = Instance.new("TextLabel")
v3DelayLabel.Size = UDim2.new(1, -24, 0, 24)
v3DelayLabel.Position = UDim2.new(0,12,0,96)
v3DelayLabel.BackgroundTransparency = 1
v3DelayLabel.Font = Enum.Font.Gotham
v3DelayLabel.TextSize = 13
v3DelayLabel.Text = "⏱️ Cast Delay: 0.05s | Complete Delay: 0.02s"
v3DelayLabel.TextColor3 = Color3.fromRGB(200,255,255)
v3DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
v3DelayLabel.Parent = v3StatsPanel

local v3PerformanceLabel = Instance.new("TextLabel")
v3PerformanceLabel.Size = UDim2.new(1, -24, 0, 24)
v3PerformanceLabel.Position = UDim2.new(0,12,0,120)
v3PerformanceLabel.BackgroundTransparency = 1
v3PerformanceLabel.Font = Enum.Font.Gotham
v3PerformanceLabel.TextSize = 13
v3PerformanceLabel.Text = "🚀 Performance: Optimized | FPS: 90"
v3PerformanceLabel.TextColor3 = Color3.fromRGB(180,255,180)
v3PerformanceLabel.TextXAlignment = Enum.TextXAlignment.Left
v3PerformanceLabel.Parent = v3StatsPanel

local v3WarningLabel = Instance.new("TextLabel")
v3WarningLabel.Size = UDim2.new(1, -24, 0, 24)
v3WarningLabel.Position = UDim2.new(0,12,0,144)
v3WarningLabel.BackgroundTransparency = 1
v3WarningLabel.Font = Enum.Font.GothamBold
v3WarningLabel.TextSize = 12
v3WarningLabel.Text = "⚠️ WARNING: SUPER BLATANT - HIGH DETECTION RISK!"
v3WarningLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
v3WarningLabel.TextXAlignment = Enum.TextXAlignment.Left
v3WarningLabel.Parent = v3StatsPanel

-- V3 Controls Panel
local v3ControlsPanel = Instance.new("Frame")
v3ControlsPanel.Size = UDim2.new(1, 0, 0, 120)
v3ControlsPanel.Position = UDim2.new(0, 0, 0, 192)
v3ControlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
v3ControlsPanel.BorderSizePixel = 0
v3ControlsPanel.Parent = v3ContentContainer

local v3ControlsCorner = Instance.new("UICorner")
v3ControlsCorner.CornerRadius = UDim.new(0,8)
v3ControlsCorner.Parent = v3ControlsPanel

local v3ControlsTitle = Instance.new("TextLabel")
v3ControlsTitle.Size = UDim2.new(1, -24, 0, 28)
v3ControlsTitle.Position = UDim2.new(0,12,0,8)
v3ControlsTitle.BackgroundTransparency = 1
v3ControlsTitle.Font = Enum.Font.GothamBold
v3ControlsTitle.TextSize = 14
v3ControlsTitle.Text = "🎮 SUPER BLATANT CONTROLS"
v3ControlsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v3ControlsTitle.TextXAlignment = Enum.TextXAlignment.Left
v3ControlsTitle.Parent = v3ControlsPanel

-- V3 Start/Stop Button
local v3FishingButton = Instance.new("TextButton")
v3FishingButton.Size = UDim2.new(0, 200, 0, 50)
v3FishingButton.Position = UDim2.new(0, 12, 0, 40)
v3FishingButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
v3FishingButton.Font = Enum.Font.GothamBold
v3FishingButton.TextSize = 14
v3FishingButton.Text = "🔥 START V3 FISHING"
v3FishingButton.TextColor3 = Color3.fromRGB(30,30,30)
v3FishingButton.AutoButtonColor = false
v3FishingButton.Parent = v3ControlsPanel

local v3FishingBtnCorner = Instance.new("UICorner")
v3FishingBtnCorner.CornerRadius = UDim.new(0,6)
v3FishingBtnCorner.Parent = v3FishingButton

-- V3 Status Indicator
local v3ActiveStatusLabel = Instance.new("TextLabel")
v3ActiveStatusLabel.Size = UDim2.new(0.5, -16, 0, 50)
v3ActiveStatusLabel.Position = UDim2.new(0, 224, 0, 40)
v3ActiveStatusLabel.BackgroundTransparency = 1
v3ActiveStatusLabel.Font = Enum.Font.GothamBold
v3ActiveStatusLabel.TextSize = 12
v3ActiveStatusLabel.Text = "⭕ V3 OFFLINE"
v3ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
v3ActiveStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v3ActiveStatusLabel.Parent = v3ControlsPanel

-- V3 Settings Panel
local v3SettingsPanel = Instance.new("Frame")
v3SettingsPanel.Size = UDim2.new(1, 0, 0, 400)
v3SettingsPanel.Position = UDim2.new(0, 0, 0, 324)
v3SettingsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
v3SettingsPanel.BorderSizePixel = 0
v3SettingsPanel.Parent = v3ContentContainer

local v3SettingsCorner = Instance.new("UICorner")
v3SettingsCorner.CornerRadius = UDim.new(0,8)
v3SettingsCorner.Parent = v3SettingsPanel

local v3SettingsTitle = Instance.new("TextLabel")
v3SettingsTitle.Size = UDim2.new(1, -24, 0, 28)
v3SettingsTitle.Position = UDim2.new(0,12,0,8)
v3SettingsTitle.BackgroundTransparency = 1
v3SettingsTitle.Font = Enum.Font.GothamBold
v3SettingsTitle.TextSize = 14
v3SettingsTitle.Text = "⚙️ SUPER BLATANT SETTINGS (5x SPEED)"
v3SettingsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v3SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
v3SettingsTitle.Parent = v3SettingsPanel

-- Input TextBox Helper Function
local function CreateInputField(name, desc, default, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 60)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(180,180,180)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.3, 0, 0, 30)
    textBox.Position = UDim2.new(0.65, 0, 0.2, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    textBox.Text = tostring(default)
    textBox.TextColor3 = Color3.fromRGB(255,255,255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 12
    textBox.PlaceholderText = "Enter value..."
    textBox.Parent = frame

    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0,4)
    textBoxCorner.Parent = textBox

    textBox.FocusLost:Connect(function()
        local success, value = pcall(function()
            return tonumber(textBox.Text)
        end)
        if success and value then
            callback(value)
        else
            textBox.Text = tostring(default)
        end
    end)

    return frame
end

-- Create V3 Input Fields
CreateInputField("⏱️ Cast Delay", "Delay before casting (seconds)", fishingV3Config.delayCast, function(v)
    fishingV3Config.delayCast = v
    print("[Fishing V3] Cast Delay set to:", v)
end, v3SettingsPanel, 36)

CreateInputField("⏱️ Complete Delay", "Delay before completing (seconds)", fishingV3Config.delayComplete, function(v)
    fishingV3Config.delayComplete = v
    print("[Fishing V3] Complete Delay set to:", v)
end, v3SettingsPanel, 100)

CreateInputField("🚀 Speed Multiplier", "Fishing speed multiplier (1-10)", fishingV3Config.speedMultiplier, function(v)
    fishingV3Config.speedMultiplier = math.clamp(v, 1, 10)
    print("[Fishing V3] Speed Multiplier set to:", fishingV3Config.speedMultiplier)
end, v3SettingsPanel, 164)

-- Create V3 Toggles
CreateToggle("🔥 Super Blatant Mode", "Ultra fast 5x speed fishing", fishingV3Config.superBlatant, function(v)
    fishingV3Config.superBlatant = v
    if v then
        fishingV3Config.speedMultiplier = 5
        fishingV3Config.delayCast = 0.05
        fishingV3Config.delayComplete = 0.02
    end
    print("[Fishing V3] Super Blatant:", v and "ENABLED" or "DISABLED")
end, v3SettingsPanel, 228)

CreateToggle("⚡ Ultra Instant Fishing", "Bypass all delays", fishingV3Config.ultraInstant, function(v)
    fishingV3Config.ultraInstant = v
    if v then
        fishingV3Config.delayCast = 0.01
        fishingV3Config.delayComplete = 0.005
    end
    print("[Fishing V3] Ultra Instant:", v and "ENABLED" or "DISABLED")
end, v3SettingsPanel, 280)

CreateToggle("🎯 Auto Perfection", "Always perfect fishing", fishingV3Config.autoPerfection, function(v)
    fishingV3Config.autoPerfection = v
    print("[Fishing V3] Auto Perfection:", v and "ENABLED" or "DISABLED")
end, v3SettingsPanel, 332)

-- Update canvas size
v3ContentContainer.Size = UDim2.new(1, 0, 0, 324 + 400 + 20)
fishingV3Content.CanvasSize = UDim2.new(0, 0, 0, 324 + 400 + 20)

-- ═══════════════════════════════════════════════════════════
-- SETTINGS UI CONTENT
-- ═══════════════════════════════════════════════════════════

local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -24, 1, -24)
settingsContent.Position = UDim2.new(0, 12, 0, 12)
settingsContent.BackgroundTransparency = 1
settingsContent.Visible = false
settingsContent.ScrollBarThickness = 6
settingsContent.ScrollBarImageColor3 = ACCENT
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 600)
settingsContent.Parent = content

local settingsContainer = Instance.new("Frame")
settingsContainer.Name = "SettingsContainer"
settingsContainer.Size = UDim2.new(1, 0, 0, 600)
settingsContainer.BackgroundTransparency = 1
settingsContainer.Parent = settingsContent

-- Performance Panel
local performancePanel = Instance.new("Frame")
performancePanel.Size = UDim2.new(1, 0, 0, 200)
performancePanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
performancePanel.BorderSizePixel = 0
performancePanel.Parent = settingsContainer

local performanceCorner = Instance.new("UICorner")
performanceCorner.CornerRadius = UDim.new(0,8)
performanceCorner.Parent = performancePanel

local performanceTitle = Instance.new("TextLabel")
performanceTitle.Size = UDim2.new(1, -24, 0, 28)
performanceTitle.Position = UDim2.new(0,12,0,8)
performanceTitle.BackgroundTransparency = 1
performanceTitle.Font = Enum.Font.GothamBold
performanceTitle.TextSize = 14
performanceTitle.Text = "⚡ PERFORMANCE SETTINGS"
performanceTitle.TextColor3 = Color3.fromRGB(235,235,235)
performanceTitle.TextXAlignment = Enum.TextXAlignment.Left
performanceTitle.Parent = performancePanel

-- Create Settings Input Fields
CreateInputField("🎯 Target FPS", "Set target FPS (30-144)", settingsConfig.targetFPS, function(v)
    settingsConfig.targetFPS = math.clamp(v, 30, 144)
    print("[Settings] Target FPS set to:", settingsConfig.targetFPS)
end, performancePanel, 36)

CreateInputField("🚶 Walk Speed", "Player walk speed", settingsConfig.walkSpeedValue, function(v)
    settingsConfig.walkSpeedValue = math.clamp(v, 16, 100)
    if settingsConfig.walkSpeed then
        ApplyWalkSpeed()
    end
    print("[Settings] Walk Speed set to:", settingsConfig.walkSpeedValue)
end, performancePanel, 100)

-- Create Settings Toggles
CreateToggle("🖥️ Stable 90 FPS", "Lock FPS to 90 for stability", settingsConfig.stableFPS, function(v)
    settingsConfig.stableFPS = v
    if v then
        ApplyStableFPS()
    end
    print("[Settings] Stable FPS:", v and "ENABLED" or "DISABLED")
end, performancePanel, 164)

-- Movement Panel
local movementPanel = Instance.new("Frame")
movementPanel.Size = UDim2.new(1, 0, 0, 200)
movementPanel.Position = UDim2.new(0, 0, 0, 212)
movementPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
movementPanel.BorderSizePixel = 0
movementPanel.Parent = settingsContainer

local movementCorner = Instance.new("UICorner")
movementCorner.CornerRadius = UDim.new(0,8)
movementCorner.Parent = movementPanel

local movementTitle = Instance.new("TextLabel")
movementTitle.Size = UDim2.new(1, -24, 0, 28)
movementTitle.Position = UDim2.new(0,12,0,8)
movementTitle.BackgroundTransparency = 1
movementTitle.Font = Enum.Font.GothamBold
movementTitle.TextSize = 14
movementTitle.Text = "🚀 MOVEMENT SETTINGS"
movementTitle.TextColor3 = Color3.fromRGB(235,235,235)
movementTitle.TextXAlignment = Enum.TextXAlignment.Left
movementTitle.Parent = movementPanel

CreateToggle("🚶 Walk Speed", "Enable custom walk speed", settingsConfig.walkSpeed, function(v)
    settingsConfig.walkSpeed = v
    if v then
        ApplyWalkSpeed()
    else
        ResetWalkSpeed()
    end
    print("[Settings] Walk Speed:", v and "ENABLED" or "DISABLED")
end, movementPanel, 36)

CreateToggle("🦘 Infinity Jump", "Enable infinite jumping", settingsConfig.infinityJump, function(v)
    settingsConfig.infinityJump = v
    if v then
        EnableInfinityJump()
    else
        DisableInfinityJump()
    end
    print("[Settings] Infinity Jump:", v and "ENABLED" or "DISABLED")
end, movementPanel, 88)

CreateToggle("🕶️ Black Screen", "Reduce graphics for performance", settingsConfig.blackScreen, function(v)
    settingsConfig.blackScreen = v
    if v then
        ApplyBlackScreen()
    else
        RemoveBlackScreen()
    end
    print("[Settings] Black Screen:", v and "ENABLED" or "DISABLED")
end, movementPanel, 140)

CreateToggle("🛡️ Anti-Lag", "Reduce lag and improve performance", settingsConfig.antiLag, function(v)
    settingsConfig.antiLag = v
    if v then
        ApplyAntiLag()
    else
        RemoveAntiLag()
    end
    print("[Settings] Anti-Lag:", v and "ENABLED" or "DISABLED")
end, movementPanel, 192)

-- Update canvas size
settingsContainer.Size = UDim2.new(1, 0, 0, 212 + 200 + 20)
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 212 + 200 + 20)

-- ═══════════════════════════════════════════════════════════
-- FIXED FISHING FUNCTIONS - WORKING VERSION
-- ═══════════════════════════════════════════════════════════

-- FIXED: Enhanced fishing detection system - WORKING VERSION
local function FindFishingProximityPrompt()
    local success, result = pcall(function()
        local char = player.Character
        if not char then return nil end
        
        -- Check character first
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                local actionText = descendant.ActionText and string.lower(tostring(descendant.ActionText)) or ""
                local objectText = descendant.ObjectText and string.lower(tostring(descendant.ObjectText)) or ""
                
                if string.find(actionText, "cast") or string.find(actionText, "fish") or string.find(actionText, "reel") or
                   string.find(objectText, "cast") or string.find(objectText, "fish") or string.find(objectText, "reel") then
                    return descendant
                end
            end
        end
        
        -- Check workspace
        for _, descendant in pairs(Workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                local actionText = descendant.ActionText and string.lower(tostring(descendant.ActionText)) or ""
                local objectText = descendant.ObjectText and string.lower(tostring(descendant.ObjectText)) or ""
                
                if string.find(actionText, "cast") or string.find(actionText, "fish") or string.find(actionText, "reel") or
                   string.find(objectText, "cast") or string.find(objectText, "fish") or string.find(objectText, "reel") then
                    return descendant
                end
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

-- FIXED: Universal fishing action function
local function PerformFishingAction(actionType)
    local success = pcall(function()
        local prompt = FindFishingProximityPrompt()
        if prompt and prompt.Enabled then
            fireproximityprompt(prompt)
            
            if actionType == "cast" then
                fishingStats.lastAction = "Casting Line"
                print("[Fishing] Casting fishing rod...")
            elseif actionType == "reel" then
                fishingStats.lastAction = "Reeling Fish"
                print("[Fishing] Reeling fish...")
            end
            
            return true
        end
        
        -- Fallback: Try to find fishing tool and use it
        local character = player.Character
        if character then
            -- Look for fishing rod in character
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolName = string.lower(tool.Name)
                    if string.find(toolName, "rod") or string.find(toolName, "fish") then
                        -- Activate the tool
                        tool:Activate()
                        fishingStats.lastAction = "Using " .. tool.Name
                        return true
                    end
                end
            end
            
            -- Look for fishing rod in backpack
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local toolName = string.lower(tool.Name)
                        if string.find(toolName, "rod") or string.find(toolName, "fish") then
                            -- Equip and use the tool
                            local humanoid = character:FindFirstChild("Humanoid")
                            if humanoid then
                                humanoid:EquipTool(tool)
                                task.wait(0.1)
                                tool:Activate()
                                fishingStats.lastAction = "Equipping & Using " .. tool.Name
                                return true
                            end
                        end
                    end
                end
            end
        end
        
        return false
    end)
    
    return success or false
end

-- FIXED: Start Fishing V1 - WORKING VERSION
local function StartFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting Fishing V1"
    
    print("[Fishing] Starting Fishing V1...")
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = PerformFishingAction("cast")
        if success then
            fishingStats.attempts = fishingStats.attempts + 1
            fishingStats.lastAction = "Cast Successful"
            
            -- Wait based on mode
            local delay = fishingConfig.blantantMode and 0.05 or 
                         fishingConfig.instantFishing and 0.1 or 0.5
            
            task.wait(delay)
            
            -- Reel the fish
            local reelSuccess = PerformFishingAction("reel")
            if reelSuccess then
                fishingStats.fishCaught = fishingStats.fishCaught + 1
                fishingStats.lastAction = "Fish Caught!"
            else
                fishingStats.lastAction = "Reel Failed"
            end
            
            -- Wait between cycles
            task.wait(delay)
        else
            fishingStats.lastAction = "No Fishing Prompt Found - Searching..."
            task.wait(1) -- Wait longer if no prompt found
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
    
    print("[Fishing] Fishing V1 stopped")
end

-- FIXED: Start Fishing V2 - WORKING VERSION
local function StartFishingV2()
    if fishingV2Active then 
        print("[Fishing V2] Already fishing!")
        return 
    end
    
    fishingV2Active = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting AI Fishing V2"
    
    print("[Fishing V2] Starting AI Fishing System...")
    
    v2Connection = RunService.Heartbeat:Connect(function()
        if not fishingV2Active then return end
        
        local currentTime = tick()
        
        -- Casting phase
        if not isCasting and (currentTime - lastCastTime > fishingV2Config.castDelay) then
            local success = PerformFishingAction("cast")
            if success then
                isCasting = true
                lastCastTime = currentTime
                fishingStats.attempts = fishingStats.attempts + 1
                fishingStats.lastAction = "V2 Cast Successful"
            end
        end
        
        -- Reeling phase
        if isCasting and (currentTime - lastCastTime > fishingV2Config.reelDelay) then
            local success = PerformFishingAction("reel")
            if success then
                fishingStats.fishCaught = fishingStats.fishCaught + 1
                isCasting = false
                fishingStats.lastAction = "V2 Fish Caught!"
            else
                isCasting = false
                fishingStats.lastAction = "V2 Reel Failed"
            end
        end
    end)
end

local function StopFishingV2()
    fishingV2Active = false
    isCasting = false
    isReeling = false
    
    if v2Connection then
        v2Connection:Disconnect()
        v2Connection = nil
    end
    
    print("[Fishing V2] AI Fishing stopped")
end

-- FIXED: Start Fishing V3 - SUPER BLATANT WORKING VERSION
local function StartFishingV3()
    if fishingV3Active then 
        print("[Fishing V3] Already fishing!")
        return 
    end
    
    fishingV3Active = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting V3 Super Blatant"
    
    print("[Fishing V3] Starting SUPER BLATANT Fishing (5x Speed)...")
    
    local castDelay = fishingV3Config.ultraInstant and 0.01 or fishingV3Config.delayCast
    local completeDelay = fishingV3Config.ultraInstant and 0.005 or fishingV3Config.delayComplete
    
    v3Connection = RunService.Heartbeat:Connect(function()
        if not fishingV3Active then return end
        
        -- Multiple attempts per frame for super speed
        for i = 1, fishingV3Config.speedMultiplier do
            if not fishingV3Active then break end
            
            local success = PerformFishingAction("cast")
            if success then
                fishingStats.attempts = fishingStats.attempts + 1
                fishingStats.v3Speed = fishingV3Config.speedMultiplier
                fishingStats.lastAction = "V3 Ultra Cast"
                
                task.wait(castDelay)
                
                local reelSuccess = PerformFishingAction("reel")
                if reelSuccess then
                    fishingStats.fishCaught = fishingStats.fishCaught + 1
                    fishingStats.lastAction = "V3 Super Catch!"
                end
                
                task.wait(completeDelay)
            else
                fishingStats.lastAction = "V3 Searching for Fishing Spot..."
                task.wait(0.1) -- Wait a bit if no prompt found
            end
        end
    end)
end

local function StopFishingV3()
    fishingV3Active = false
    
    if v3Connection then
        v3Connection:Disconnect()
        v3Connection = nil
    end
    
    fishingStats.v3Speed = 0
    print("[Fishing V3] Super Blatant Fishing stopped")
end

-- Performance Optimization Functions
local function ApplyStableFPS()
    if settingsConfig.stableFPS then
        settings().Rendering.QualityLevel = 1
        for _, effect in pairs(Workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") then
                effect.Enabled = false
            end
        end
    end
end

local function ApplyWalkSpeed()
    if settingsConfig.walkSpeed then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = settingsConfig.walkSpeedValue
            end
        end
    end
end

local function ResetWalkSpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

local infinityJumpConnection
local function EnableInfinityJump()
    infinityJumpConnection = UserInputService.JumpRequest:Connect(function()
        if settingsConfig.infinityJump then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

local function DisableInfinityJump()
    if infinityJumpConnection then
        infinityJumpConnection:Disconnect()
        infinityJumpConnection = nil
    end
end

local blackScreenFrame
local function ApplyBlackScreen()
    if blackScreenFrame then blackScreenFrame:Destroy() end
    
    blackScreenFrame = Instance.new("Frame")
    blackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
    blackScreenFrame.Position = UDim2.new(0, 0, 0, 0)
    blackScreenFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackScreenFrame.BackgroundTransparency = 0.7
    blackScreenFrame.ZIndex = 100
    blackScreenFrame.Parent = playerGui
end

local function RemoveBlackScreen()
    if blackScreenFrame then
        blackScreenFrame:Destroy()
        blackScreenFrame = nil
    end
end

local function ApplyAntiLag()
    if settingsConfig.antiLag then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100
        settings().Rendering.QualityLevel = 1
    end
end

local function RemoveAntiLag()
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 100000
    settings().Rendering.QualityLevel = 10
end

-- FIXED: Anti-AFK System
local function AntiAFK()
    if not fishingV2Config.antiAfk then return end
    
    antiAfkTime = antiAfkTime + 1
    if antiAfkTime >= 30 then
        antiAfkTime = 0
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
    end
end

-- ═══════════════════════════════════════════════════════════
-- FIXED EVENT HANDLERS
-- ═══════════════════════════════════════════════════════════

-- Fishing V1 Button Handler
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🚀 START INSTANT FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishing()
        fishingButton.Text = "⏹️ STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "✅ FISHING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

-- Fishing V2 Button Handler
v2FishingButton.MouseButton1Click:Connect(function()
    if fishingV2Active then
        StopFishingV2()
        v2FishingButton.Text = "🤖 START AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        v2ActiveStatusLabel.Text = "⭕ AI OFFLINE"
        v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishingV2()
        v2FishingButton.Text = "⏹️ STOP AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        v2ActiveStatusLabel.Text = "✅ AI FISHING ACTIVE"
        v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

-- Fishing V3 Button Handler
v3FishingButton.MouseButton1Click:Connect(function()
    if fishingV3Active then
        StopFishingV3()
        v3FishingButton.Text = "🔥 START V3 FISHING"
        v3FishingButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        v3ActiveStatusLabel.Text = "⭕ V3 OFFLINE"
        v3ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishingV3()
        v3FishingButton.Text = "⏹️ STOP V3 FISHING"
        v3FishingButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        v3ActiveStatusLabel.Text = "✅ V3 SUPER ACTIVE"
        v3ActiveStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

-- Menu navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        cTitle.Text = name
        
        fishingContent.Visible = (name == "Fishing V1")
        fishingV2Content.Visible = (name == "Fishing V2")
        fishingV3Content.Visible = (name == "Fishing V3")
        settingsContent.Visible = (name == "Settings")
    end)
end

-- Highlight fishing menu by default
menuButtons["Fishing V1"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- WINDOW CONTROLS
local uiOpen = true

local function showTrayIcon()
    trayIcon.Visible = true
    TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size = UDim2.new(0, 60, 0, 60)}):Play()
end

local function hideTrayIcon()  
    TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.3)
    trayIcon.Visible = false
end

local function showMainUI()
    container.Visible = true
    TweenService:Create(container, TweenInfo.new(0.4), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT),
        Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
    }):Play()
    
    hideTrayIcon()
    uiOpen = true
end

local function hideMainUI()
    TweenService:Create(container, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    task.wait(0.3)
    container.Visible = false
    
    showTrayIcon()
    uiOpen = false
end

local function minimizeUI() hideMainUI() end
local function closeUI() hideMainUI() end

trayIcon.MouseButton1Click:Connect(showMainUI)
minimizeBtn.MouseButton1Click:Connect(minimizeUI)
closeBtn.MouseButton1Click:Connect(closeUI)

-- Stats Update Loop - OPTIMIZED
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        local efficiency = fishingStats.attempts > 0 and (fishingStats.fishCaught / fishingStats.attempts) * 100 or 0
        
        -- Update semua stats
        fishCountLabel.Text = string.format("🎣 Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("📈 Rate: %.2f/s", rate)
        memLabel.Text = string.format("💾 Memory: %d KB", math.floor(collectgarbage("count")))
        attemptsLabel.Text = string.format("🔄 Attempts: %d", fishingStats.attempts)
        successLabel.Text = string.format("✅ Success: %.1f%%", efficiency)
        timeLabel.Text = string.format("⏱️ Session Time: %ds", math.floor(elapsed))
        
        -- V2 Stats
        v2FishCountLabel.Text = string.format("🎣 Total Fish: %d", fishingStats.fishCaught)
        v2InstantLabel.Text = string.format("⚡ Instant Catches: %d", fishingStats.instantCatches)
        v2StatusLabel.Text = string.format("📊 Status: %s", fishingStats.lastAction)
        v2EfficiencyLabel.Text = string.format("📈 Efficiency: %.1f%%", efficiency)
        
        -- V3 Stats
        v3FishCountLabel.Text = string.format("🎣 Total Fish: %d", fishingStats.fishCaught)
        v3SpeedLabel.Text = string.format("⚡ Current Speed: %dx", fishingStats.v3Speed)
        v3EfficiencyLabel.Text = string.format("📈 Efficiency: %.1f%%", efficiency)
        v3StatusLabel.Text = string.format("📊 Status: %s", fishingStats.lastAction)
        v3DelayLabel.Text = string.format("⏱️ Cast: %.3fs | Complete: %.3fs", 
            fishingV3Config.delayCast, fishingV3Config.delayComplete)
        v3PerformanceLabel.Text = string.format("🚀 Performance: %s | FPS: %d", 
            settingsConfig.stableFPS and "Stable" or "Normal", settingsConfig.targetFPS)
        
        -- Anti-AFK system
        AntiAFK()
        
        task.wait(0.5)
    end
end)

-- Start dengan UI terbuka
showMainUI()

print("[Kaitun Fish It V3] CLEAN VERSION Loaded Successfully!")
print("🎣 Fishing V1 - Basic instant fishing")
print("🚀 Fishing V2 - AI fishing (3x Faster)")
print("⚡ Fishing V3 - Super Blatant (5x Speed)")
print("⚙️ Settings - Performance & Movement options")
print("✅ ALL FISHING SYSTEMS WORKING - RADAR REMOVED")
