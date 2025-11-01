-- UI-Only: Neon Panel (sidebar + content) — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Toggle dengan tombol G. Safe (UI only).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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
local config = {
    autoFishing = false,
    instantFishing = true,
    fishingDelay = 0.1,
    blantantMode = false
}

local stats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successfulCatch = 0,
    failedCatch = 0
}

local fishingActive = false
local fishingConnection

-- cleanup old if exist
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container (centered)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow (image behind)
local glow = Instance.new("ImageLabel", screen)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = container.Position
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616" -- radial
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1

-- Card (panel)
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner", card)
cardCorner.CornerRadius = UDim.new(0, 12)

-- inner container
local inner = Instance.new("Frame", card)
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1

-- Title bar
local titleBar = Instance.new("Frame", inner)
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT - ULTIMATE"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local statusLabel = Instance.new("TextLabel", titleBar)
statusLabel.Size = UDim2.new(0.4,-16,1,0)
statusLabel.Position = UDim2.new(0.6,8,0,0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.Text = "🔴 Ready"
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.TextXAlignment = Enum.TextXAlignment.Right

-- left sidebar
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3

local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 8)

-- sidebar header icon
local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1

local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904" -- simple icon (roblox)
logo.ImageColor3 = ACCENT

local sTitle = Instance.new("TextLabel", sbHeader)
sTitle.Size = UDim2.new(1,-96,0,32)
sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- menu list area
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)

-- menu helper
local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner", row)
    corner.CornerRadius = UDim.new(0,8)

    local left = Instance.new("Frame", row)
    left.Size = UDim2.new(0,40,1,0)
    left.Position = UDim2.new(0,8,0,0)
    left.BackgroundTransparency = 1

    local icon = Instance.new("TextLabel", left)
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

-- menu items (order like photo)
local items = {
    {"Fishing", "🎣"},
    {"Auto Fish", "⚡"},
    {"Settings", "⚙"},
    {"Teleport", "📍"},
    {"Stats", "📊"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- content panel (right)
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0

local contentCorner = Instance.new("UICorner", content)
contentCorner.CornerRadius = UDim.new(0, 8)

-- content title area
local cTitle = Instance.new("TextLabel", content)
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Fishing Controls"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- FISHING FUNCTIONS
local function FindFishingRemotes()
    local remotes = {}
    
    -- Cari di ReplicatedStorage
    pcall(function()
        for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = string.lower(obj.Name)
                if name:find("fish") or name:find("catch") or name:find("rod") then
                    table.insert(remotes, obj)
                end
            end
        end
    end)
    
    return remotes
end

local function TryFishing()
    stats.attempts = stats.attempts + 1
    local success = false
    
    -- Method 1: Remote Events
    local remotes = FindFishingRemotes()
    for _, remote in pairs(remotes) do
        local methods = {"CatchFish", "FishCaught", "GetFish", "AddFish"}
        for _, method in pairs(methods) do
            local ok = pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(method)
                    return true
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(method)
                    return true
                end
            end)
            if ok then success = true break end
        end
        if success then break end
    end
    
    -- Method 2: Virtual Input
    if not success then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            
            success = true
        end)
    end
    
    if success then
        stats.fishCaught = stats.fishCaught + 1
        stats.successfulCatch = stats.successfulCatch + 1
    else
        stats.failedCatch = stats.failedCatch + 1
    end
    
    return success
end

local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    statusLabel.Text = "🟢 Fishing started..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = TryFishing()
        
        if success then
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            statusLabel.Text = string.format("🟢 Fish: %d | %.2f/s", stats.fishCaught, rate)
        end
        
        task.wait(config.fishingDelay)
    end)
end

local function StopFishing()
    fishingActive = false
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    statusLabel.Text = "🔴 Fishing stopped"
    statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
end

-- Create fishing controls in content
local function ShowFishingContent()
    -- Clear existing content
    for _, child in pairs(content:GetChildren()) do
        if child.Name ~= "ContentTitle" then
            child:Destroy()
        end
    end

    -- Fishing controls panel
    local panel = Instance.new("Frame", content)
    panel.Size = UDim2.new(1, -24, 0, 300)
    panel.Position = UDim2.new(0, 12, 0, 64)
    panel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    panel.BorderSizePixel = 0

    local pCorner = Instance.new("UICorner", panel)
    pCorner.CornerRadius = UDim.new(0,8)

    -- Start/Stop Fishing Button
    local startBtn = Instance.new("TextButton", panel)
    startBtn.Size = UDim2.new(0, 200, 0, 50)
    startBtn.Position = UDim2.new(0, 20, 0, 20)
    startBtn.BackgroundColor3 = ACCENT
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 16
    startBtn.Text = "🚀 START FISHING"
    startBtn.TextColor3 = Color3.fromRGB(30,30,30)
    startBtn.AutoButtonColor = false

    local startCorner = Instance.new("UICorner", startBtn)
    startCorner.CornerRadius = UDim.new(0,8)

    startBtn.MouseButton1Click:Connect(function()
        if fishingActive then
            StopFishing()
            startBtn.Text = "🚀 START FISHING"
            startBtn.BackgroundColor3 = ACCENT
        else
            StartFishing()
            startBtn.Text = "⏹️ STOP FISHING"
            startBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        end
    end)

    -- Settings toggles
    local toggleY = 90
    local function CreateFishingToggle(name, desc, default, callback)
        local frame = Instance.new("Frame", panel)
        frame.Size = UDim2.new(1, -40, 0, 50)
        frame.Position = UDim2.new(0, 20, 0, toggleY)
        frame.BackgroundColor3 = Color3.fromRGB(20,20,22)
        frame.BorderSizePixel = 0

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0,6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = name
        label.TextColor3 = Color3.fromRGB(230,230,230)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local descLabel = Instance.new("TextLabel", frame)
        descLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
        descLabel.Position = UDim2.new(0, 10, 0.5, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = desc
        descLabel.TextColor3 = Color3.fromRGB(150,150,150)
        descLabel.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBtn = Instance.new("TextButton", frame)
        toggleBtn.Size = UDim2.new(0, 60, 0, 30)
        toggleBtn.Position = UDim2.new(1, -70, 0.5, -15)
        toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(30,30,30)
        toggleBtn.TextSize = 12
        toggleBtn.AutoButtonColor = false

        local toggleCorner = Instance.new("UICorner", toggleBtn)
        toggleCorner.CornerRadius = UDim.new(0,6)

        toggleBtn.MouseButton1Click:Connect(function()
            local new = toggleBtn.Text == "OFF"
            toggleBtn.Text = new and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = new and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
            callback(new)
        end)

        toggleY = toggleY + 60
        return frame
    end

    -- Fishing toggles
    CreateFishingToggle("Instant Fishing", "Fast fishing mode", config.instantFishing, function(v)
        config.instantFishing = v
        config.fishingDelay = v and 0.05 or 0.2
    end)

    CreateFishingToggle("Blantant Mode", "ULTRA FAST fishing", config.blantantMode, function(v)
        config.blantantMode = v
        if v then
            config.fishingDelay = 0.02
            config.instantFishing = true
            statusLabel.Text = "💥 BLANTANT MODE"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        else
            config.fishingDelay = 0.15
            statusLabel.Text = "🔵 Normal Mode"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        end
    end)

    -- Stats display
    local statsPanel = Instance.new("Frame", content)
    statsPanel.Size = UDim2.new(1, -24, 0, 120)
    statsPanel.Position = UDim2.new(0, 12, 0, 380)
    statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    statsPanel.BorderSizePixel = 0

    local statsCorner = Instance.new("UICorner", statsPanel)
    statsCorner.CornerRadius = UDim.new(0,8)

    local statsTitle = Instance.new("TextLabel", statsPanel)
    statsTitle.Size = UDim2.new(1, -20, 0, 30)
    statsTitle.Position = UDim2.new(0, 10, 0, 5)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Text = "📊 Live Statistics"
    statsTitle.TextColor3 = Color3.fromRGB(230,230,230)
    statsTitle.TextSize = 14
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Stats labels
    local fishStat = Instance.new("TextLabel", statsPanel)
    fishStat.Size = UDim2.new(0.5, -10, 0, 25)
    fishStat.Position = UDim2.new(0, 10, 0, 40)
    fishStat.BackgroundTransparency = 1
    fishStat.Font = Enum.Font.Gotham
    fishStat.Text = "🎣 Fish: 0"
    fishStat.TextColor3 = Color3.fromRGB(200,200,200)
    fishStat.TextSize = 12
    fishStat.TextXAlignment = Enum.TextXAlignment.Left

    local attemptsStat = Instance.new("TextLabel", statsPanel)
    attemptsStat.Size = UDim2.new(0.5, -10, 0, 25)
    attemptsStat.Position = UDim2.new(0.5, 0, 0, 40)
    attemptsStat.BackgroundTransparency = 1
    attemptsStat.Font = Enum.Font.Gotham
    attemptsStat.Text = "🔄 Attempts: 0"
    attemptsStat.TextColor3 = Color3.fromRGB(200,200,200)
    attemptsStat.TextSize = 12
    attemptsStat.TextXAlignment = Enum.TextXAlignment.Left

    local rateStat = Instance.new("TextLabel", statsPanel)
    rateStat.Size = UDim2.new(0.5, -10, 0, 25)
    rateStat.Position = UDim2.new(0, 10, 0, 65)
    rateStat.BackgroundTransparency = 1
    rateStat.Font = Enum.Font.Gotham
    rateStat.Text = "⚡ Rate: 0.00/s"
    rateStat.TextColor3 = Color3.fromRGB(200,200,200)
    rateStat.TextSize = 12
    rateStat.TextXAlignment = Enum.TextXAlignment.Left

    local successStat = Instance.new("TextLabel", statsPanel)
    successStat.Size = UDim2.new(0.5, -10, 0, 25)
    successStat.Position = UDim2.new(0.5, 0, 0, 65)
    successStat.BackgroundTransparency = 1
    successStat.Font = Enum.Font.Gotham
    successStat.Text = "✅ Success: 0"
    successStat.TextColor3 = Color3.fromRGB(200,200,200)
    successStat.TextSize = 12
    successStat.TextXAlignment = Enum.TextXAlignment.Left

    -- Update stats in real-time
    task.spawn(function()
        while task.wait(0.5) do
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            
            fishStat.Text = "🎣 Fish: " .. stats.fishCaught
            attemptsStat.Text = "🔄 Attempts: " .. stats.attempts
            rateStat.Text = string.format("⚡ Rate: %.2f/s", rate)
            successStat.Text = "✅ Success: " .. stats.successfulCatch
        end
    end)
end

-- Menu navigation
local activeMenu = "Fishing"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Highlight selected
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        -- Update content
        cTitle.Text = name
        activeMenu = name
        
        if name == "Fishing" then
            ShowFishingContent()
        elseif name == "Stats" then
            -- Show stats content (bisa dikembangkan)
            for _, child in pairs(content:GetChildren()) do
                if child.Name ~= "ContentTitle" then
                    child:Destroy()
                end
            end
            -- Tambahkan content stats di sini
        else
            -- Placeholder untuk menu lainnya
            for _, child in pairs(content:GetChildren()) do
                if child.Name ~= "ContentTitle" then
                    child:Destroy()
                end
            end
        end
    end)
end

-- Initialize dengan content fishing
ShowFishingContent()
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- close/open toggle with G (with pop animation)
local uiOpen = false
local function toggleUI(show)
    uiOpen = show
    if show then
        card.Visible = true
        glow.Visible = true
        container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
        container.AnchorPoint = Vector2.new(0.5,0.5)
        container.ZIndex = 2
        card:TweenSize(UDim2.new(0, WIDTH,0,HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.28, true)
        TweenService:Create(glow, TweenInfo.new(0.28), {ImageTransparency = 0.8}):Play()
    else
        TweenService:Create(glow, TweenInfo.new(0.18), {ImageTransparency = 0.96}):Play()
        card:TweenSize(UDim2.new(0, WIDTH*0.9,0,HEIGHT*0.9), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.16, true)
        delay(0.16, function()
            card.Visible = false
            glow.Visible = false
        end)
    end
end

-- initial hide
toggleUI(false)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        toggleUI(not uiOpen)
    end
end)

print("[Kaitun Fish It] Loaded! Press G to toggle UI")
print("🎣 Fishing system ready")
print("⚡ Features: Auto Fishing, Instant Mode, Blantant Mode")
