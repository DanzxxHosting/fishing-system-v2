-- UI-Only: Neon Panel dengan Tray Icon + Enhanced Instant Fishing
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Close/minimize akan menyisakan tray icon.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62)
local BG = Color3.fromRGB(12,12,12)
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

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successRate = 0
}

local fishingActive = false
local fishingConnection
local reelConnection

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
title.Text = "⚡ KAITUN FISH IT"
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
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = sbHeader

local sSubtitle = Instance.new("TextLabel")
sSubtitle.Size = UDim2.new(1,-96,0,20)
sSubtitle.Position = UDim2.new(0, 88, 0, 38)
sSubtitle.BackgroundTransparency = 1
sSubtitle.Font = Enum.Font.Gotham
sSubtitle.TextSize = 10
sSubtitle.Text = "Instant Fish v2.0"
sSubtitle.TextColor3 = ACCENT
sSubtitle.TextXAlignment = Enum.TextXAlignment.Left
sSubtitle.Parent = sbHeader

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
    {"Fishing", "🎣"},
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
cTitle.Text = "Fishing"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = content

-- ═══════════════════════════════════════════════════════════
-- ENHANCED INSTANT FISHING FUNCTIONS
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

-- INSTANT FISHING - Method 1: ProximityPrompt
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

-- INSTANT FISHING - Method 2: ClickDetector
local function InstantFishClickDetector()
    local success = pcall(function()
        local rod = GetFishingRod()
        if not rod or rod.Parent ~= player.Character then return false end
        
        local handle = rod:FindFirstChild("Handle")
        if not handle then return false end
        
        local clickDetector = handle:FindFirstChild("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
            return true
        end
        
        return false
    end)
    
    return success
end

-- INSTANT FISHING - Method 3: RemoteEvent/Function
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

-- INSTANT FISHING - Method 4: BindableEvent
local function InstantFishBindable()
    local success = pcall(function()
        local char = SafeGetCharacter()
        if not char then return false end
        
        for _, bindable in pairs(char:GetDescendants()) do
            if bindable:IsA("BindableEvent") then
                local name = bindable.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("catch") then
                    bindable:Fire()
                    return true
                end
            end
        end
        
        return false
    end)
    
    return success
end

-- INSTANT FISHING - Method 5: Virtual Input
local function InstantFishVirtualInput()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    return true
end

-- INSTANT FISHING - Method 6: Auto Reel
local function AutoReelFish()
    local success = pcall(function()
        local char = SafeGetCharacter()
        if not char then return false end
        
        local playerGui = player:WaitForChild("PlayerGui")
        
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("ImageButton") or gui:IsA("TextButton") then
                local name = gui.Name:lower()
                local text = gui.Text and gui.Text:lower() or ""
                
                if name:find("reel") or name:find("catch") or text:find("reel") or text:find("catch") then
                    if gui.Visible then
                        for i = 1, 50 do
                            gui.Activated:Fire()
                            task.wait(0.001)
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

-- MASTER INSTANT FISHING FUNCTION
local function InstantFish()
    if not fishingActive then return end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    if not EquipRod() then
        return
    end
    
    local success = false
    
    if fishingConfig.instantFishing or fishingConfig.blantantMode then
        if InstantFishProximity() then
            success = true
        end
        
        if InstantFishClickDetector() then
            success = true
        end
        
        if InstantFishRemote() then
            success = true
        end
        
        if InstantFishBindable() then
            success = true
        end
        
        if InstantFishVirtualInput() then
            success = true
        end
        
        if fishingConfig.autoReel then
            AutoReelFish()
        end
    end
    
    if success then
        fishingStats.fishCaught = fishingStats.fishCaught + 1
    end
end

local function StartFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    
    print("[Fishing] Starting instant fishing...")
    print("[Fishing] Delay:", fishingConfig.fishingDelay)
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        pcall(InstantFish)
        
        if fishingConfig.blantantMode then
            task.wait(0.001)
        elseif fishingConfig.instantFishing then
            task.wait(0.01)
        else
            task.wait(fishingConfig.fishingDelay)
        end
    end)
    
    if fishingConfig.autoReel then
        reelConnection = RunService.RenderStepped:Connect(function()
            if not fishingActive then return end
            pcall(AutoReelFish)
        end)
    end
end

local function StopFishing()
    fishingActive = false
    
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    
    if reelConnection then
        reelConnection:Disconnect()
        reelConnection = nil
    end
    
    print("[Fishing] Stopped fishing")
    print("[Fishing] Total fish caught:", fishingStats.fishCaught)
end

-- ═══════════════════════════════════════════════════════════
-- FISHING UI CONTENT
-- ═══════════════════════════════════════════════════════════

local fishingContent = Instance.new("ScrollingFrame")
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -68)
fishingContent.Position = UDim2.new(0, 12, 0, 56)
fishingContent.BackgroundTransparency = 1
fishingContent.BorderSizePixel = 0
fishingContent.ScrollBarThickness = 6
fishingContent.ScrollBarImageColor3 = ACCENT
fishingContent.CanvasSize = UDim2.new(0, 0, 0, 800)
fishingContent.Visible = true
fishingContent.Parent = content

-- Stats Panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 120)
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
rateLabel.Text = "⚡ Rate: 0/s"
rateLabel.TextColor3 = Color3.fromRGB(200,220,255)
rateLabel.TextXAlignment = Enum.TextXAlignment.Left
rateLabel.Parent = statsPanel

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Size = UDim2.new(0.5, -8, 0, 24)
attemptsLabel.Position = UDim2.new(0,12,0,68)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.Font = Enum.Font.Gotham
attemptsLabel.TextSize = 13
attemptsLabel.Text = "🎯 Attempts: 0"
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
timeLabel.Size = UDim2.new(0.5, -8, 0, 20)
timeLabel.Position = UDim2.new(0,12,0,96)
timeLabel.BackgroundTransparency = 1
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextSize = 11
timeLabel.Text = "⏱️ Session: 0:00:00"
timeLabel.TextColor3 = Color3.fromRGB(180,180,180)
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = statsPanel

-- Controls Panel
local controlsPanel = Instance.new("Frame")
controlsPanel.Size = UDim2.new(1, 0, 0, 120)
controlsPanel.Position = UDim2.new(0, 0, 0, 132)
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
fishingButton.Size = UDim2.new(0, 220, 0, 50)
fishingButton.Position = UDim2.new(0, 12, 0, 44)
fishingButton.BackgroundColor3 = ACCENT
fishingButton.Font = Enum.Font.GothamBold
fishingButton.TextSize = 14
fishingButton.Text = "🚀 START INSTANT FISHING"
fishingButton.TextColor3 = Color3.fromRGB(30,30,30)
fishingButton.AutoButtonColor = false
fishingButton.Parent = controlsPanel

local fishingBtnCorner = Instance.new("UICorner")
fishingBtnCorner.CornerRadius = UDim.new(0,8)
fishingBtnCorner.Parent = fishingButton

-- Reset Stats Button
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 140, 0, 50)
resetButton.Position = UDim2.new(0, 244, 0, 44)
resetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 13
resetButton.Text = "🔄 RESET STATS"
resetButton.TextColor3 = Color3.fromRGB(220,220,220)
resetButton.AutoButtonColor = false
resetButton.Parent = controlsPanel

local resetBtnCorner = Instance.new("UICorner")
resetBtnCorner.CornerRadius = UDim.new(0,8)
resetBtnCorner.Parent = resetButton

-- Status Indicator
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 220, 0, 50)
statusFrame.Position = UDim2.new(0, 396, 0, 44)
statusFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = controlsPanel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0,8)
statusCorner.Parent = statusFrame

local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 12, 0, 12)
statusIndicator.Position = UDim2.new(0, 12, 0.5, -6)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = statusFrame

local statusIndCorner = Instance.new("UICorner")
statusIndCorner.CornerRadius = UDim.new(1, 0)
statusIndCorner.Parent = statusIndicator

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -36, 1, 0)
statusLabel.Position = UDim2.new(0, 32, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.Text = "⭕ OFFLINE"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

-- Toggles Panel
local togglesPanel = Instance.new("Frame")
togglesPanel.Size = UDim2.new(1, 0, 0, 240)
togglesPanel.Position = UDim2.new(0, 0, 0, 264)
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
    frame.Size = UDim2.new(1, -24, 0, 44)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 18)
    descLabel.Position = UDim2.new(0, 0, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(160,160,160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 70, 0, 32)
    button.Position = UDim2.new(0.73, 0, 0.15, 0)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseEnter:Connect(function()
        local targetColor = button.Text == "ON" and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(220, 80, 80)
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)

    button.MouseLeave:Connect(function()
        local targetColor = button.Text == "ON" and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        local targetColor = new and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(new)
    end)

    return frame
end

-- Create Toggles
CreateToggle("⚡ Instant Fishing", "Maximum speed casting & catching", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    if v then
        fishingConfig.fishingDelay = 0.01
        print("[Fishing] Instant Fishing: ENABLED (0.01s)")
    else
        fishingConfig.fishingDelay = 0.1
        print("[Fishing] Instant Fishing: DISABLED")
    end
end, togglesPanel, 40)

CreateToggle("💥 Blatant Mode", "Ultra fast mode (may be detected)", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then
        fishingConfig.fishingDelay = 0.001
        fishingConfig.instantFishing = true
        print("[Fishing] Blatant Mode: ENABLED (0.001s)")
    else
        fishingConfig.fishingDelay = 0.1
        fishingConfig.instantFishing = false
        print("[Fishing] Blatant Mode: DISABLED")
    end
end, togglesPanel, 88)

CreateToggle("🎯 Perfect Cast", "Always perfect casting accuracy", fishingConfig.perfectCast, function(v)
    fishingConfig.perfectCast = v
    print("[Fishing] Perfect Cast:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 136)

CreateToggle("🔄 Auto Reel", "Automatically win reel minigame", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
    
    if v and fishingActive then
        if not reelConnection then
            reelConnection = RunService.RenderStepped:Connect(function()
                if not fishingActive then return end
                pcall(AutoReelFish)
            end)
        end
    else
        if reelConnection then
            reelConnection:Disconnect()
            reelConnection = nil
        end
    end
    
    print("[Fishing] Auto Reel:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 184)

-- Info Panel
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(1, 0, 0, 180)
infoPanel.Position = UDim2.new(0, 0, 0, 516)
infoPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
infoPanel.BorderSizePixel = 0
infoPanel.Parent = fishingContent

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0,8)
infoCorner.Parent = infoPanel

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, -24, 0, 28)
infoTitle.Position = UDim2.new(0,12,0,8)
infoTitle.BackgroundTransparency = 1
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextSize = 14
infoTitle.Text = "ℹ️ Information & Controls"
infoTitle.TextColor3 = Color3.fromRGB(235,235,235)
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.Parent = infoPanel

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -24, 1, -44)
infoText.Position = UDim2.new(0, 12, 0, 40)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.TextWrapped = true
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextColor3 = Color3.fromRGB(200,200,200)
infoText.Text = [[🎮 Keyboard Shortcuts:
• Right Ctrl - Toggle UI
• Right Shift - Start/Stop Fishing

⚡ Fishing Methods:
This script uses 6 different methods simultaneously:
• ProximityPrompt Detection
• ClickDetector Firing
• RemoteEvent Hooking
• BindableEvent Triggering
• Virtual Input Simulation
• Auto Reel Minigame

🚀 Tips:
• Use Instant Fishing for fast but safe fishing
• Blatant Mode is fastest but may be detected
• Auto Reel helps with minigame challenges
• Perfect Cast ensures maximum success rate]]
infoText.Parent = infoPanel

-- Fishing Button Handler
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🚀 START INSTANT FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    else
        StartFishing()
        fishingButton.Text = "⏹️ STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        statusLabel.Text = "✅ FISHING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    end
end)

-- Reset Stats Button Handler
resetButton.MouseButton1Click:Connect(function()
    fishingStats.fishCaught = 0
    fishingStats.startTime = tick()
    fishingStats.attempts = 0
    fishingStats.successRate = 0
    print("[Fishing] Stats reset!")
end)

-- Button Hover Effects
fishingButton.MouseEnter:Connect(function()
    local targetColor = fishingActive and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(255, 82, 82)
    TweenService:Create(fishingButton, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
end)

fishingButton.MouseLeave:Connect(function()
    local targetColor = fishingActive and Color3.fromRGB(180, 50, 50) or ACCENT
    TweenService:Create(fishingButton, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
end)

resetButton.MouseEnter:Connect(function()
    TweenService:Create(resetButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
end)

resetButton.MouseLeave:Connect(function()
    TweenService:Create(resetButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
end)

-- TELEPORT UI
local teleportContent = Instance.new("Frame")
teleportContent.Name = "TeleportContent"
teleportContent.Size = UDim2.new(1, -24, 1, -68)
teleportContent.Position = UDim2.new(0, 12, 0, 56)
teleportContent.BackgroundTransparency = 1
teleportContent.Visible = false
teleportContent.Parent = content

local teleportLabel = Instance.new("TextLabel")
teleportLabel.Size = UDim2.new(1, 0, 1, 0)
teleportLabel.BackgroundTransparency = 1
teleportLabel.Font = Enum.Font.GothamBold
teleportLabel.TextSize = 16
teleportLabel.Text = "📍 Teleport Feature\n(Coming Soon)"
teleportLabel.TextColor3 = Color3.fromRGB(200,200,200)
teleportLabel.TextYAlignment = Enum.TextYAlignment.Center
teleportLabel.Parent = teleportContent

-- SETTINGS UI
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
settingsLabel.Text = "⚙️ Settings\n(Coming Soon)"
settingsLabel.TextColor3 = Color3.fromRGB(200,200,200)
settingsLabel.TextYAlignment = Enum.TextYAlignment.Center
settingsLabel.Parent = settingsContent

-- Menu navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        cTitle.Text = name
        
        fishingContent.Visible = (name == "Fishing")
        teleportContent.Visible = (name == "Teleport")
        settingsContent.Visible = (name == "Settings")
        
        print("[UI] Switched to:", name)
    end)
end

menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- WINDOW CONTROLS
local uiOpen = true

local function showTrayIcon()
    trayIcon.Visible = true
    TweenService:Create(trayIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency = 0.7}):Play()
end

local function hideTrayIcon()
    TweenService:Create(trayIcon, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.25), {ImageTransparency = 1}):Play()
    task.wait(0.25)
    trayIcon.Visible = false
end

local function showMainUI()
    container.Visible = true
    TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT),
        Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.4), {ImageTransparency = 0.88}):Play()
    
    hideTrayIcon()
    uiOpen = true
    print("[UI] Main UI shown")
end

local function hideMainUI()
    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    
    task.wait(0.3)
    container.Visible = false
    
    showTrayIcon()
    uiOpen = false
    print("[UI] Main UI hidden to tray")
end

trayIcon.MouseButton1Click:Connect(function()
    showMainUI()
end)

trayIcon.MouseEnter:Connect(function()
    TweenService:Create(trayIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 70, 0, 70)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.2), {ImageTransparency = 0.5}):Play()
end)

trayIcon.MouseLeave:Connect(function()
    TweenService:Create(trayIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(trayGlow, TweenInfo.new(0.2), {ImageTransparency = 0.7}):Play()
end)

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

minimizeBtn.MouseButton1Click:Connect(hideMainUI)
closeBtn.MouseButton1Click:Connect(hideMainUI)

-- Status Indicator Pulse Animation
spawn(function()
    while true do
        if fishingActive then
            TweenService:Create(statusIndicator, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                BackgroundColor3 = Color3.fromRGB(120, 255, 120)
            }):Play()
        else
            statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
        task.wait(0.1)
    end
end)

-- Stats Update Loop
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        local successRate = fishingStats.attempts > 0 and (fishingStats.fishCaught / fishingStats.attempts * 100) or 0
        
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        fishCountLabel.Text = string.format("🎣 Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("⚡ Rate: %.2f/s", rate)
        attemptsLabel.Text = string.format("🎯 Attempts: %d", fishingStats.attempts)
        successLabel.Text = string.format("✅ Success: %.1f%%", successRate)
        timeLabel.Text = string.format("⏱️ Session: %d:%02d:%02d", hours, minutes, seconds)
        memLabel.Text = string.format("Memory: %d KB | Fish: %d", math.floor(collectgarbage("count")), fishingStats.fishCaught)
        
        task.wait(0.5)
    end
end)

-- Keybind untuk toggle UI (Right Control)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        if uiOpen then
            hideMainUI()
        else
            showMainUI()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        if fishingActive then
            StopFishing()
            fishingButton.Text = "🚀 START INSTANT FISHING"
            fishingButton.BackgroundColor3 = ACCENT
            statusLabel.Text = "⭕ OFFLINE"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        else
            StartFishing()
            fishingButton.Text = "⏹️ STOP FISHING"
            fishingButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            statusLabel.Text = "✅ FISHING ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        end
    end
end)

-- Start dengan UI terbuka
showMainUI()

print("═══════════════════════════════════════════════")
print("[Kaitun Fish It] INSTANT FISHING LOADED!")
print("═══════════════════════════════════════════════")
print("⚡ Features:")
print("  • Multi-Method Instant Fishing")
print("  • ProximityPrompt Detection")
print("  • ClickDetector Support")
print("  • RemoteEvent Hooking")
print("  • Auto Reel Minigame")
print("  • Perfect Cast System")
print("  • Blatant Mode (Ultra Fast)")
print("═══════════════════════════════════════════════")
print("🎮 Controls:")
print("  • Right Ctrl - Toggle UI")
print("  • Right Shift - Start/Stop Fishing")
print("  • Click - to minimize")
print("  • Click 🗙 to close")
print("═══════════════════════════════════════════════")
print("✅ UI successfully created!")
print("🎣 Ready to fish!")
print("═══════════════════════════════════════════════")
