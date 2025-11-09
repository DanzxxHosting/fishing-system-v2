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
-- FISHING V1 FUNCTIONS (BASIC)
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
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("rod") or name:find("pole") or name:find("fishing") then
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
                    if name:find("rod") or name:find("pole") or name:find("fishing") then
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
            return false 
        end
        
        if rod.Parent == player.Backpack then
            local humanoid = SafeGetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.1)
                return true
            end
        end
        
        return rod.Parent == player.Character
    end)
    
    return success
end

-- INSTANT FISHING METHODS
local function InstantFishProximity()
    local success = pcall(function()
        local char = SafeGetCharacter()
        if not char then return false end
        
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local objText = descendant.ObjectText and descendant.ObjectText:lower() or ""
                local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
                
                if objText:find("fish") or objText:find("cast") or objText:find("catch") or
                   actionText:find("fish") or actionText:find("cast") or actionText:find("catch") then
                    
                    if descendant.Enabled then
                        fireproximityprompt(descendant)
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
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("catch") or name:find("reel") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("Cast")
                        remote:FireServer("Reel")
                        remote:FireServer("Catch")
                        return true
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer("Cast")
                        remote:InvokeServer("Reel")
                        remote:InvokeServer("Catch")
                        return true
                    end
                end
            end
        end
        
        return false
    end)
    
    return success
end

-- MASTER INSTANT FISHING FUNCTION (V1 - IMPROVED)
local function InstantFish()
    if not fishingActive then return end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    -- Pastikan rod equipped
    local rod = GetFishingRod()
    if not rod then
        fishingStats.lastAction = "No Rod Found"
        return
    end
    
    if not EquipRod() then
        fishingStats.lastAction = "Rod Not Equipped"
        return
    end
    
    local success = false
    
    -- Method 1: ProximityPrompt (paling reliable)
    if InstantFishProximity() then
        success = true
        fishingStats.lastAction = "Caught (Proximity)"
    end
    
    -- Method 2: RemoteEvent/Function
    if fishingConfig.blantantMode and InstantFishRemote() then
        success = true  
        fishingStats.lastAction = "Caught (Remote)"
    end
    
    -- Method 3: Direct tool activation (backup)
    if not success and rod.Parent == player.Character then
        pcall(function()
            rod:Activate()
            success = true
            fishingStats.lastAction = "Caught (Tool Activate)"
        end)
    end
    
    if success then
        fishingStats.fishCaught = fishingStats.fishCaught + 1
    end
end

-- Start Fishing V1 (IMPROVED)
local function StartFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    
    print("[Fishing] Starting instant fishing...")
    print("[Fishing] Mode:", fishingConfig.blantantMode and "BLATANT" or (fishingConfig.instantFishing and "INSTANT" or "NORMAL"))
    
    -- Equip rod first
    if not EquipRod() then
        print("[Fishing] ⚠️ Please equip fishing rod first!")
        fishingActive = false
        return
    end
    
    -- Main fishing loop
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        pcall(InstantFish)
        
        -- Delay based on mode
        local delay = fishingConfig.fishingDelay
        if fishingConfig.blantantMode then
            delay = 0.001
        elseif fishingConfig.instantFishing then
            delay = 0.01
        end
        
        task.wait(delay)
    end)
    
    print("[Fishing] ✅ Instant fishing started!")
end

local function StopFishing()
    fishingActive = false
    
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    
    print("[Fishing] Stopped fishing")
    print("[Fishing] Total fish caught:", fishingStats.fishCaught)
end

-- ═══════════════════════════════════════════════════════════
-- EVENT HANDLERS
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

-- Menu navigation
local activeMenu = "Fishing V1"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        cTitle.Text = name
        
        fishingContent.Visible = (name == "Fishing V1")
        fishingV2Content.Visible = (name == "Fishing V2")
        teleportContent.Visible = (name == "Teleport")
        settingsContent.Visible = (name == "Settings")
        
        print("[UI] Switched to:", name)
    end)
end

-- Highlight fishing menu by default
menuButtons["Fishing V1"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- WINDOW CONTROLS FUNCTIONALITY
local uiOpen = true

-- Show Tray Icon
local function showTrayIcon()
    trayIcon.Visible = true
    TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency = 0.7}):Play()
end

-- Hide Tray Icon  
local function hideTrayIcon()
    TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    wait(0.3)
    trayIcon.Visible = false
end

-- Show Main UI
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

-- Hide Main UI (ke tray)
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

-- Minimize Function
local function minimizeUI()
    hideMainUI()
end

-- Close Function  
local function closeUI()
    hideMainUI()
end

-- Tray Icon Click - Show Main UI
trayIcon.MouseButton1Click:Connect(function()
    showMainUI()
end)

-- Tray Icon Hover Effects
trayIcon.MouseEnter:Connect(function()
    TweenService:Create(trayIcon, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.2), {ImageTransparency = 0.6}):Play()
end)

trayIcon.MouseLeave:Connect(function()
    TweenService:Create(trayIcon, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.2), {ImageTransparency = 0.7}):Play()
end)

-- Window Controls Hover Effects
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

-- Button Clicks
minimizeBtn.MouseButton1Click:Connect(minimizeUI)
closeBtn.MouseButton1Click:Connect(closeUI)

-- Stats Update Loop
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        local efficiency = fishingStats.fishCaught / math.max(1, fishingStats.attempts) * 100
        
        -- Update V1 Stats
        fishCountLabel.Text = string.format("Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("Rate: %.2f/s", rate)
        attemptsLabel.Text = string.format("Attempts: %d", fishingStats.attempts)
        memLabel.Text = string.format("Memory: %d KB | Fish: %d", math.floor(collectgarbage("count")), fishingStats.fishCaught)
        successLabel.Text = string.format("Success: %.1f%%", efficiency)
        
        -- Update V2 Stats
        v2FishCountLabel.Text = string.format("Total Fish: %d", fishingStats.fishCaught)
        v2InstantLabel.Text = string.format("Instant Catches: %d", fishingStats.instantCatches)
        v2SpotsLabel.Text = string.format("Spots Found: %d", fishingStats.spotsFound)
        v2StatusLabel.Text = string.format("Status: %s", fishingStats.lastAction)
        v2EfficiencyLabel.Text = string.format("Efficiency: %.1f%% | Last Action: %s", efficiency, fishingStats.lastAction)
        v2AFKLabel.Text = string.format("Anti-AFK: %ds | Cast Delay: %ds | Reel Delay: %.1fs", antiAfkTime, fishingV2Config.castDelay, fishingV2Config.reelDelay)
        
        wait(0.3)
    end
end)

-- Start dengan UI terbuka
showMainUI()

print("[Kaitun Fish It V2] UI Loaded Successfully!")
print("🎣 Fishing V1 - Basic instant fishing")
print("🚀 Fishing V2 - Advanced AI fishing system")
print("🎣 Click - to minimize to tray")
print("🎣 Click 🗙 to close to tray") 
print("🎣 Click tray icon to reopen UI")

-- Test jika UI muncul
wait(1)
if screen and screen.Parent then
    print("✅ UI successfully created!")
else
    print("❌ UI failed to create!")
end
-- FISHING V1 UI CONTENT
-- ═══════════════════════════════════════════════════════════

local fishingContent = Instance.new("Frame")
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -24)
fishingContent.Position = UDim2.new(0, 12, 0, 12)
fishingContent.BackgroundTransparency = 1
fishingContent.Visible = true
fishingContent.Parent = content

-- Stats Panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 100)
statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
statsPanel.BorderSizePixel = 0
statsPanel.Parent = fishingContent

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0,8)
statsCorner.Parent = statsPanel

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -24, 0, 28)
statsTitle.Position = UDim2.new(0,12,0,8)
statsTitle.BackgroundTransparency = 1
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.Text = "📊 Fishing Statistics"
statsTitle.TextColor3 = Color3.fromRGB(235,235,235)
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsPanel

local fishCountLabel = Instance.new("TextLabel")
fishCountLabel.Size = UDim2.new(0.5, -8, 0, 24)
fishCountLabel.Position = UDim2.new(0,12,0,40)
fishCountLabel.BackgroundTransparency = 1
fishCountLabel.Font = Enum.Font.Gotham
fishCountLabel.TextSize = 13
fishCountLabel.Text = "Fish Caught: 0"
fishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
fishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
fishCountLabel.Parent = statsPanel

local rateLabel = Instance.new("TextLabel")
rateLabel.Size = UDim2.new(0.5, -8, 0, 24)
rateLabel.Position = UDim2.new(0.5,4,0,40)
rateLabel.BackgroundTransparency = 1
rateLabel.Font = Enum.Font.Gotham
rateLabel.TextSize = 13
rateLabel.Text = "Rate: 0/s"
rateLabel.TextColor3 = Color3.fromRGB(200,220,255)
rateLabel.TextXAlignment = Enum.TextXAlignment.Left
rateLabel.Parent = statsPanel

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Size = UDim2.new(0.5, -8, 0, 24)
attemptsLabel.Position = UDim2.new(0,12,0,68)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.Font = Enum.Font.Gotham
attemptsLabel.TextSize = 13
attemptsLabel.Text = "Attempts: 0"
attemptsLabel.TextColor3 = Color3.fromRGB(255,220,200)
attemptsLabel.TextXAlignment = Enum.TextXAlignment.Left
attemptsLabel.Parent = statsPanel

local successLabel = Instance.new("TextLabel")
successLabel.Size = UDim2.new(0.5, -8, 0, 24)
successLabel.Position = UDim2.new(0.5,4,0,68)
successLabel.BackgroundTransparency = 1
successLabel.Font = Enum.Font.Gotham
successLabel.TextSize = 13
successLabel.Text = "Success: 0%"
successLabel.TextColor3 = Color3.fromRGB(255,200,255)
successLabel.TextXAlignment = Enum.TextXAlignment.Left
successLabel.Parent = statsPanel

-- Controls Panel
local controlsPanel = Instance.new("Frame")
controlsPanel.Size = UDim2.new(1, 0, 0, 100)
controlsPanel.Position = UDim2.new(0, 0, 0, 112)
controlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
controlsPanel.BorderSizePixel = 0
controlsPanel.Parent = fishingContent

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0,8)
controlsCorner.Parent = controlsPanel

local controlsTitle = Instance.new("TextLabel")
controlsTitle.Size = UDim2.new(1, -24, 0, 28)
controlsTitle.Position = UDim2.new(0,12,0,8)
controlsTitle.BackgroundTransparency = 1
controlsTitle.Font = Enum.Font.GothamBold
controlsTitle.TextSize = 14
controlsTitle.Text = "⚡ Fishing Controls"
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
togglesPanel.Size = UDim2.new(1, 0, 0, 200)
togglesPanel.Position = UDim2.new(0, 0, 0, 224)
togglesPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
togglesPanel.BorderSizePixel = 0
togglesPanel.Parent = fishingContent

local togglesCorner = Instance.new("UICorner")
togglesCorner.CornerRadius = UDim.new(0,8)
togglesCorner.Parent = togglesPanel

local togglesTitle = Instance.new("TextLabel")
togglesTitle.Size = UDim2.new(1, -24, 0, 28)
togglesTitle.Position = UDim2.new(0,12,0,8)
togglesTitle.BackgroundTransparency = 1
togglesTitle.Font = Enum.Font.GothamBold
togglesTitle.TextSize = 14
togglesTitle.Text = "🔧 Instant Fishing Settings"
togglesTitle.TextColor3 = Color3.fromRGB(235,235,235)
togglesTitle.TextXAlignment = Enum.TextXAlignment.Left
togglesTitle.Parent = togglesPanel

-- Toggle Helper Function
local function CreateToggle(name, desc, default, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(180,180,180)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 24)
    button.Position = UDim2.new(0.75, 0, 0.2, 0)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(30,30,30)
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,4)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        callback(new)
    end)

    return frame
end

-- Create Toggles untuk V1
CreateToggle("⚡ Instant Fishing", "Max speed casting & catching", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    if v then
        fishingConfig.fishingDelay = 0.01
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
        print("[Fishing] Blatant Mode: ENABLED (0.001s delay)")
    else
        fishingConfig.fishingDelay = 0.1
        fishingConfig.instantFishing = false
        print("[Fishing] Blatant Mode: DISABLED")
    end
end, togglesPanel, 76)

CreateToggle("🎯 Perfect Cast", "Always perfect casting", fishingConfig.perfectCast, function(v)
    fishingConfig.perfectCast = v
    print("[Fishing] Perfect Cast:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 116)

CreateToggle("🔄 Auto Reel", "Auto reel minigame", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
    print("[Fishing] Auto Reel:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 156)

-- FISHING V2 UI CONTENT - FIXED
-- ═══════════════════════════════════════════════════════════

local fishingV2Content = Instance.new("ScrollingFrame")
fishingV2Content.Name = "FishingV2Content"
fishingV2Content.Size = UDim2.new(1, -24, 1, -68)
fishingV2Content.Position = UDim2.new(0, 12, 0, 56)
fishingV2Content.BackgroundTransparency = 1
fishingV2Content.Visible = false
fishingV2Content.ScrollBarThickness = 6
fishingV2Content.ScrollBarImageColor3 = ACCENT
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 600)
fishingV2Content.BorderSizePixel = 0
fishingV2Content.Parent = content

-- Container for V2 content
local v2ContentContainer = Instance.new("Frame")
v2ContentContainer.Name = "V2ContentContainer"
v2ContentContainer.Size = UDim2.new(1, 0, 0, 600)
v2ContentContainer.BackgroundTransparency = 1
v2ContentContainer.Parent = fishingV2Content

-- V2 Stats Panel
local v2StatsPanel = Instance.new("Frame")
v2StatsPanel.Size = UDim2.new(1, 0, 0, 140)
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
v2StatsTitle.Text = "🚀 FISH IT - AI FISHING STATS"
v2StatsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
v2StatsTitle.Parent = v2StatsPanel

local v2FishCountLabel = Instance.new("TextLabel")
v2FishCountLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2FishCountLabel.Position = UDim2.new(0,12,0,40)
v2FishCountLabel.BackgroundTransparency = 1
v2FishCountLabel.Font = Enum.Font.Gotham
v2FishCountLabel.TextSize = 13
v2FishCountLabel.Text = "Total Fish: 0"
v2FishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
v2FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
v2FishCountLabel.Parent = v2StatsPanel

local v2InstantLabel = Instance.new("TextLabel")
v2InstantLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2InstantLabel.Position = UDim2.new(0.5,4,0,40)
v2InstantLabel.BackgroundTransparency = 1
v2InstantLabel.Font = Enum.Font.Gotham
v2InstantLabel.TextSize = 13
v2InstantLabel.Text = "Instant Catches: 0"
v2InstantLabel.TextColor3 = Color3.fromRGB(255,215,0)
v2InstantLabel.TextXAlignment = Enum.TextXAlignment.Left
v2InstantLabel.Parent = v2StatsPanel

local v2SpotsLabel = Instance.new("TextLabel")
v2SpotsLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2SpotsLabel.Position = UDim2.new(0,12,0,68)
v2SpotsLabel.BackgroundTransparency = 1
v2SpotsLabel.Font = Enum.Font.Gotham
v2SpotsLabel.TextSize = 13
v2SpotsLabel.Text = "Spots Found: 0"
v2SpotsLabel.TextColor3 = Color3.fromRGB(200,220,255)
v2SpotsLabel.TextXAlignment = Enum.TextXAlignment.Left
v2SpotsLabel.Parent = v2StatsPanel

local v2StatusLabel = Instance.new("TextLabel")
v2StatusLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2StatusLabel.Position = UDim2.new(0.5,4,0,68)
v2StatusLabel.BackgroundTransparency = 1
v2StatusLabel.Font = Enum.Font.Gotham
v2StatusLabel.TextSize = 13
v2StatusLabel.Text = "Status: Idle"
v2StatusLabel.TextColor3 = Color3.fromRGB(255,200,255)
v2StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2StatusLabel.Parent = v2StatsPanel

local v2EfficiencyLabel = Instance.new("TextLabel")
v2EfficiencyLabel.Size = UDim2.new(1, -24, 0, 24)
v2EfficiencyLabel.Position = UDim2.new(0,12,0,96)
v2EfficiencyLabel.BackgroundTransparency = 1
v2EfficiencyLabel.Font = Enum.Font.Gotham
v2EfficiencyLabel.TextSize = 13
v2EfficiencyLabel.Text = "Efficiency: 0% | Last Action: None"
v2EfficiencyLabel.TextColor3 = Color3.fromRGB(200,255,255)
v2EfficiencyLabel.TextXAlignment = Enum.TextXAlignment.Left
v2EfficiencyLabel.Parent = v2StatsPanel

local v2AFKLabel = Instance.new("TextLabel")
v2AFKLabel.Size = UDim2.new(1, -24, 0, 24)
v2AFKLabel.Position = UDim2.new(0,12,0,120)
v2AFKLabel.BackgroundTransparency = 1
v2AFKLabel.Font = Enum.Font.Gotham
v2AFKLabel.TextSize = 13
v2AFKLabel.Text = "Anti-AFK: 0s | Cast Delay: 2s | Reel Delay: 0.5s"
v2AFKLabel.TextColor3 = Color3.fromRGB(180,180,255)
v2AFKLabel.TextXAlignment = Enum.TextXAlignment.Left
v2AFKLabel.Parent = v2StatsPanel

-- V2 Controls Panel
local v2ControlsPanel = Instance.new("Frame")
v2ControlsPanel.Size = UDim2.new(1, 0, 0, 100)
v2ControlsPanel.Position = UDim2.new(0, 0, 0, 152)
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
v2FeaturesPanel.Size = UDim2.new(1, 0, 0, 280)
v2FeaturesPanel.Position = UDim2.new(0, 0, 0, 264)
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
v2FeaturesTitle.Text = "⚙️ FISH IT AI SETTINGS"
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
end, v2FeaturesPanel, 76)

CreateToggle("📡 Fishing Radar", "Show nearby fishing spots", fishingV2Config.radarEnabled, function(v)
    fishingV2Config.radarEnabled = v
    if v and fishingV2Active then
        StartRadar()
    else
        StopRadar()
    end
    print("[Fishing V2] Fishing Radar:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 116)

CreateToggle("🛡️ Anti-AFK", "Prevent AFK detection", fishingV2Config.antiAfk, function(v)
    fishingV2Config.antiAfk = v
    print("[Fishing V2] Anti-AFK:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 156)

CreateToggle("🎯 Smart Detection", "Auto-detect fishing prompts", fishingV2Config.smartDetection, function(v)
    fishingV2Config.smartDetection = v
    print("[Fishing V2] Smart Detection:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 196)

CreateToggle("🔧 Proximity Only", "Use only proximity prompts", fishingV2Config.useProximityOnly, function(v)
    fishingV2Config.useProximityOnly = v
    print("[Fishing V2] Proximity Only:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 236)

-- Update canvas size
v2ContentContainer.Size = UDim2.new(1, 0, 0, 264 + 280 + 20)
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 264 + 280 + 20)

-- TELEPORT UI (FULL FEATURES)
local teleportContent = Instance.new("ScrollingFrame")
teleportContent.Name = "TeleportContent"
teleportContent.Size = UDim2.new(1, -24, 1, -68)
teleportContent.Position = UDim2.new(0, 12, 0, 56)
teleportContent.BackgroundTransparency = 1
teleportContent.Visible = false
teleportContent.ScrollBarThickness = 6
teleportContent.ScrollBarImageColor3 = ACCENT
teleportContent.CanvasSize = UDim2.new(0, 0, 0, 800)
teleportContent.BorderSizePixel = 0
teleportContent.Parent = content

-- Teleport Container
local teleportContainer = Instance.new("Frame")
teleportContainer.Name = "TeleportContainer"
teleportContainer.Size = UDim2.new(1, 0, 0, 800)
teleportContainer.BackgroundTransparency = 1
teleportContainer.Parent = teleportContent

-- Teleport Locations
local teleportLocations = {
    {name = "🏝️ Fisherman Island", position = Vector3.new(-184, 138, 196)},
    {name = "🌊 Ocean", position = Vector3.new(-1500, 133, -1089)},
    {name = "🏔️ Mountain Lake", position = Vector3.new(2653, 139, 2522)},
    {name = "🌲 Forest Pond", position = Vector3.new(-1746, 137, 1314)},
    {name = "❄️ Ice Lake", position = Vector3.new(-2654, 135, 2603)},
    {name = "🏖️ Beach", position = Vector3.new(0, 130, -100)},
    {name = "🌋 Volcano Lake", position = Vector3.new(3000, 150, -2500)},
    {name = "🎪 Carnival Pond", position = Vector3.new(1200, 135, 800)},
}

-- Create Teleport Buttons
local function CreateTeleportButton(data, index)
    local yPos = (index - 1) * 60
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(14,14,16)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = teleportContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, -16, 1, 0)
    nameLabel.Position = UDim2.new(0, 16, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = data.name
    nameLabel.TextColor3 = Color3.fromRGB(240,240,240)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 120, 0, 34)
    tpBtn.Position = UDim2.new(1, -132, 0.5, -17)
    tpBtn.BackgroundColor3 = ACCENT
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 12
    tpBtn.Text = "TELEPORT"
    tpBtn.TextColor3 = Color3.fromRGB(30,30,30)
    tpBtn.AutoButtonColor = false
    tpBtn.Parent = btn
    
    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 6)
    tpCorner.Parent = tpBtn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24,24,26)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(14,14,16)}):Play()
    end)
    
    tpBtn.MouseEnter:Connect(function()
        TweenService:Create(tpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 82, 82)}):Play()
    end)
    
    tpBtn.MouseLeave:Connect(function()
        TweenService:Create(tpBtn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
    end)
    
    -- Teleport function
    tpBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(data.position)
            print("[Teleport] Teleported to:", data.name)
        end
    end)
end

for i, location in ipairs(teleportLocations) do
    CreateTeleportButton(location, i)
end

-- Update canvas size
teleportContainer.Size = UDim2.new(1, 0, 0, #teleportLocations * 60)
teleportContent.CanvasSize = UDim2.new(0, 0, 0, #teleportLocations * 60 + 20)

-- SETTINGS UI (Placeholder)
local settingsContent = Instance.new("Frame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -24, 1, -68)
settingsContent.Position = UDim2.new(0, 12, 0, 56)
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
-- FISHING V2 FIXED FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local radarParts = {}
local radarBeams = {}
local currentRod = nil

-- Helper: Cari Fishing Rod di inventory
local function FindFishingRodTool()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("rod") or name:find("pole") or name:find("fishing") then
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
                if name:find("rod") or name:find("pole") or name:find("fishing") then
                    return item
                end
            end
        end
    end
    
    return nil
end

-- Helper: Equip fishing rod
local function EquipFishingRod()
    local rod = FindFishingRodTool()
    if not rod then 
        print("[Fishing V2] No fishing rod found!")
        return false 
    end
    
    if rod.Parent == player.Backpack then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(rod)
            task.wait(0.2)
            currentRod = rod
            return true
        end
    elseif rod.Parent == player.Character then
        currentRod = rod
        return true
    end
    
    return false
end

-- FIXED RADAR SYSTEM
local function StartRadar()
    if not fishingV2Config.radarEnabled then return end
    
    print("[Radar] Starting fishing radar...")
    
    radarConnection = RunService.Heartbeat:Connect(function()
        if not fishingV2Config.radarEnabled or not fishingV2Active then 
            StopRadar()
            return 
        end
        
        -- Cleanup old radar parts (setiap 2 detik)
        if tick() % 2 < 0.1 then
            for _, part in pairs(radarParts) do
                if part then pcall(function() part:Destroy() end) end
            end
            for _, beam in pairs(radarBeams) do
                if beam then pcall(function() beam:Destroy() end) end
            end
            radarParts = {}
            radarBeams = {}
            
            -- Cari fishing spots terdekat
            local character = player.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Deteksi ProximityPrompts untuk fishing
            local nearbySpots = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local parent = obj.Parent
                    if parent and parent:IsA("BasePart") then
                        local distance = (rootPart.Position - parent.Position).Magnitude
                        if distance <= fishingV2Config.fishingSpotRadius then
                            local actionText = obj.ActionText and obj.ActionText:lower() or ""
                            local objectText = obj.ObjectText and obj.ObjectText:lower() or ""
                            
                            if actionText:find("cast") or actionText:find("fish") or 
                               objectText:find("cast") or objectText:find("fish") then
                                table.insert(nearbySpots, parent)
                            end
                        end
                    end
                end
            end
            
            -- Buat radar indicator
            for _, spot in pairs(nearbySpots) do
                local radarPart = Instance.new("Part")
                radarPart.Name = "FishingRadarIndicator"
                radarPart.Size = Vector3.new(2, 2, 2)
                radarPart.Position = spot.Position + Vector3.new(0, 5, 0)
                radarPart.Anchored = true
                radarPart.CanCollide = false
                radarPart.Material = Enum.Material.Neon
                radarPart.BrickColor = BrickColor.new("Bright green")
                radarPart.Transparency = 0.4
                
                local pointLight = Instance.new("PointLight")
                pointLight.Brightness = 2
                pointLight.Range = 15
                pointLight.Color = Color3.new(0, 1, 0)
                pointLight.Parent = radarPart
                
                radarPart.Parent = Workspace
                table.insert(radarParts, radarPart)
            end
            
            fishingStats.spotsFound = #nearbySpots
        end
    end)
end

local function StopRadar()
    if radarConnection then
        radarConnection:Disconnect()
        radarConnection = nil
    end
    
    for _, part in pairs(radarParts) do
        if part then pcall(function() part:Destroy() end) end
    end
    for _, beam in pairs(radarBeams) do
        if beam then pcall(function() beam:Destroy() end) end
    end
    radarParts = {}
    radarBeams = {}
    
    print("[Radar] Fishing radar stopped")
end

-- FIXED FISHING DETECTION
local function FindFishingProximityPrompt()
    -- Cari ProximityPrompt di Workspace untuk fishing
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            if not parent then continue end
            
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            
            -- Cek jarak ke prompt
            local distance = (char.HumanoidRootPart.Position - parent.Position).Magnitude
            if distance > obj.MaxActivationDistance then continue end
            
            local actionText = obj.ActionText and obj.ActionText:lower() or ""
            local objectText = obj.ObjectText and obj.ObjectText:lower() or ""
            
            -- Deteksi fishing related prompts
            if actionText:find("cast") or actionText:find("fish") or actionText:find("reel") or
               objectText:find("cast") or objectText:find("fish") or objectText:find("reel") then
                return obj
            end
        end
    end
    
    return nil
end

-- FIXED INSTANT REEL DETECTION  
local function DetectFishBite()
    if not fishingV2Config.instantReel then return false end
    
    local success, result = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Method 1: Cari GUI dengan tanda bite
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, obj in pairs(gui:GetDescendants()) do
                    -- Cek TextLabel/TextButton untuk indikator bite
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = obj.Text or ""
                        local name = obj.Name:lower()
                        
                        if obj.Visible and (text:find("!") or text:find("REEL") or text:find("PULL") or 
                           name:find("bite") or name:find("reel") or name:find("exclamation")) then
                            print("[Fishing V2] Bite detected via GUI:", text)
                            return true
                        end
                    end
                    
                    -- Cek ImageLabel untuk icon bite
                    if obj:IsA("ImageLabel") and obj.Visible then
                        local name = obj.Name:lower()
                        if name:find("bite") or name:find("exclamation") or name:find("alert") then
                            print("[Fishing V2] Bite detected via Image!")
                            return true
                        end
                    end
                end
            end
        end
        
        -- Method 2: Cek ProximityPrompt yang berubah text
        local prompt = FindFishingProximityPrompt()
        if prompt then
            local actionText = prompt.ActionText and prompt.ActionText:lower() or ""
            if actionText:find("reel") or actionText:find("pull") or actionText:find("catch") then
                print("[Fishing V2] Bite detected via Prompt change!")
                return true
            end
        end
        
        return false
    end)
    
    return success and result or false
end

-- FIXED FISHING ACTIONS
local function PerformFishingCast()
    local prompt = FindFishingProximityPrompt()
    if prompt and prompt.Enabled then
        local actionText = prompt.ActionText and prompt.ActionText:lower() or ""
        
        -- Pastikan ini prompt untuk CAST bukan REEL
        if actionText:find("cast") or actionText:find("throw") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            fishingStats.lastAction = "Casting"
            print("[Fishing V2] Casting fishing rod...")
            return true
        end
    end
    return false
end

local function PerformFishingReel()
    local prompt = FindFishingProximityPrompt()
    if prompt and prompt.Enabled then
        local actionText = prompt.ActionText and prompt.ActionText:lower() or ""
        
        -- Pastikan ini prompt untuk REEL
        if actionText:find("reel") or actionText:find("pull") or actionText:find("catch") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            fishingStats.lastAction = "Reeling"
            print("[Fishing V2] Reeling fish...")
            return true
        end
    end
    return false
end

-- FIXED ANTI-AFK SYSTEM
local function AntiAFK()
    if not fishingV2Config.antiAfk then return end
    
    antiAfkTime = antiAfkTime + 1
    if antiAfkTime >= 45 then
        antiAfkTime = 0
        
        -- Gerakkan mouse sedikit
        pcall(function()
            VirtualInputManager:SendMouseMoveEvent(100, 100, Workspace)
            task.wait(0.1)
            VirtualInputManager:SendMouseMoveEvent(150, 150, Workspace)
            task.wait(0.1)
            VirtualInputManager:SendMouseMoveEvent(100, 100, Workspace)
        end)
        
        print("[Anti-AFK] Anti-AFK action performed")
    end
end

-- FIXED FISHING V2 MAIN LOOP
local function StartFishingV2()
    if fishingV2Active then 
        print("[Fishing V2] Already fishing!")
        return 
    end
    
    fishingV2Active = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting"
    isCasting = false
    isReeling = false
    lastCastTime = 0
    lastReelTime = 0
    
    print("[Fishing V2] Starting AI Fishing for Fish It...")
    print("[Fishing V2] Instant Reel:", fishingV2Config.instantReel and "ENABLED" or "DISABLED")
    print("[Fishing V2] Radar:", fishingV2Config.radarEnabled and "ENABLED" or "DISABLED")
    
    -- Equip rod terlebih dahulu
    if not EquipFishingRod() then
        print("[Fishing V2] Failed to equip fishing rod!")
        fishingV2Active = false
        return
    end
    
    -- Start radar jika dienable
    if fishingV2Config.radarEnabled then
        StartRadar()
    end
    
    v2Connection = RunService.Heartbeat:Connect(function()
        if not fishingV2Active then return end
        
        -- Anti-AFK
        AntiAFK()
        
        -- Pastikan karakter dan rod ada
        local character = player.Character
        if not character then 
            fishingStats.lastAction = "No Character"
            return 
        end
        
        -- Pastikan rod masih equipped
        if not currentRod or currentRod.Parent ~= character then
            if not EquipFishingRod() then
                fishingStats.lastAction = "No Rod Equipped"
                task.wait(1)
                return
            end
        end
        
        local currentTime = tick()
        
        -- PRIORITY: Instant Reel Detection
        if fishingV2Config.instantReel and isCasting then
            if DetectFishBite() then
                fishingStats.lastAction = "Bite Detected - Instant Reeling"
                print("[Fishing V2] 🐟 BITE DETECTED! Instant reeling...")
                
                -- Spam reel untuk memastikan catch
                for i = 1, 3 do
                    if PerformFishingReel() then
                        task.wait(0.05)
                    end
                end
                
                fishingStats.instantCatches = fishingStats.instantCatches + 1
                fishingStats.fishCaught = fishingStats.fishCaught + 1
                fishingStats.lastAction = "Fish Caught (Instant)"
                
                -- Reset cycle
                isCasting = false
                isReeling = false
                lastCastTime = currentTime
                
                task.wait(fishingV2Config.castDelay)
                return
            end
        end
        
        -- PHASE 1: CASTING
        if not isCasting and not isReeling and (currentTime - lastCastTime >= fishingV2Config.castDelay) then
            fishingStats.lastAction = "Attempting Cast"
            
            if PerformFishingCast() then
                isCasting = true
                isReeling = false
                lastCastTime = currentTime
                fishingStats.attempts = fishingStats.attempts + 1
                fishingStats.lastAction = "Cast Success - Waiting"
                print("[Fishing V2] ✅ Cast successful!")
            else
                fishingStats.lastAction = "Cast Failed - Retrying"
                task.wait(0.5)
            end
            
            return
        end
        
        -- PHASE 2: WAITING FOR BITE (dengan timeout)
        if isCasting and not isReeling then
            local waitTime = currentTime - lastCastTime
            
            -- Jika sudah menunggu terlalu lama, coba reel manual
            if waitTime >= 8 then
                fishingStats.lastAction = "Timeout - Manual Reel"
                print("[Fishing V2] ⏰ Timeout, attempting manual reel...")
                
                if PerformFishingReel() then
                    fishingStats.fishCaught = fishingStats.fishCaught + 1
                    fishingStats.lastAction = "Fish Caught (Timeout)"
                end
                
                isCasting = false
                isReeling = false
                lastCastTime = currentTime
                task.wait(fishingV2Config.castDelay)
            else
                fishingStats.lastAction = string.format("Waiting for Bite (%.1fs)", waitTime)
            end
            
            return
        end
    end)
    
    print("[Fishing V2] ✅ AI Fishing started successfully!")
end

local function StopFishingV2()
    fishingV2Active = false
    isCasting = false
    isReeling = false
    fishingStats.lastAction = "Stopped"
    
    if v2Connection then
        v2Connection:Disconnect()
        v2Connection = nil
    end
    
    StopRadar()
    
    print("[Fishing V2] AI Fishing stopped")
    print("[Fishing V2] Total fish caught:", fishingStats.fishCaught)
    print("[Fishing V2] Instant catches:", fishingStats.instantCatches)
end

-- ═══════════════════════════════════════════════════════════
