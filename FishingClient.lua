-- Kaitun Fish It - Blantant Auto Fishing Edition
-- Paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62)
local BG = Color3.fromRGB(12,12,12)
local SECOND = Color3.fromRGB(24,24,26)

-- Theme colors
local theme = {
    Accent = ACCENT,
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 170, 0),
    Error = Color3.fromRGB(255, 70, 70),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
}

-- CONFIG
local config = {
    autoFishing = false,
    blantantMode = false,
    superBlantantMode = false,
    fishingDelay = 0.01,
    autoEquipRod = true,
    autoSell = false,
    antiAFK = false,
    autoShake = true,
    autoReel = true,
    perfectCatch = true,
    instantCatch = false,
    bypassDetection = false
}

-- STATS
local stats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successfulCatch = 0,
    failedCatch = 0
}

-- STATE
local fishingActive = false
local fishingLoop = nil
local reelLoop = nil
local shakeLoop = nil

-- Cleanup old
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

-- Main container (CENTERED)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow (CENTERED)
local glow = Instance.new("ImageLabel", container)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1

-- Card
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

-- Inner container
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
title.Size = UDim2.new(0.5,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT - BLANTANT"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("TextLabel", titleBar)
Status.Size = UDim2.new(0.4,-80,1,0)
Status.Position = UDim2.new(0.5,0,0,0)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.Text = "🔴 Ready"
Status.TextColor3 = Color3.fromRGB(200,200,200)
Status.TextXAlignment = Enum.TextXAlignment.Right

-- Control buttons
local controlFrame = Instance.new("Frame", titleBar)
controlFrame.Size = UDim2.new(0, 60, 1, 0)
controlFrame.Position = UDim2.new(1, -65, 0, 0)
controlFrame.BackgroundTransparency = 1

local minimizeBtn = Instance.new("TextButton", controlFrame)
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(0, 0, 0.5, -12)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
minimizeBtn.TextSize = 14
minimizeBtn.AutoButtonColor = false
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 6)

local maximizeBtn = Instance.new("TextButton", controlFrame)
maximizeBtn.Size = UDim2.new(0, 25, 0, 25)
maximizeBtn.Position = UDim2.new(0, 30, 0.5, -12)
maximizeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.Text = "□"
maximizeBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
maximizeBtn.TextSize = 12
maximizeBtn.AutoButtonColor = false
local maxCorner = Instance.new("UICorner", maximizeBtn)
maxCorner.CornerRadius = UDim.new(0, 6)

-- Sidebar
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 8)

-- Sidebar header
local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1

local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904"
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

-- Menu frame
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)

-- Menu helper
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

    local icon = Instance.new("TextLabel", row)
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.Position = UDim2.new(0, 8, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

-- Menu items
local items = {
    {"Fishing", "🎣"},
    {"Teleport", "📍"},
    {"Settings", "⚙"},
    {"Stats", "📊"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- Content panel
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0
local contentCorner = Instance.new("UICorner", content)
contentCorner.CornerRadius = UDim.new(0, 8)

-- Content title
local cTitle = Instance.new("TextLabel", content)
cTitle.Name = "ContentTitle"
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Blantant Auto Fishing"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- =============================================
-- BLANTANT AUTO FISHING FUNCTIONS
-- =============================================

local function GetCharacter()
    return player.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRod()
    local char = GetCharacter()
    if not char then return nil end
    
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fish")) then
            return item
        end
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fish")) then
                return item
            end
        end
    end
    
    return nil
end

local function EquipRod()
    if not config.autoEquipRod then return true end
    
    local rod = GetRod()
    if not rod then return false end
    
    if rod.Parent == player.Character then return true end
    
    local humanoid = GetHumanoid()
    if humanoid then
        pcall(function()
            humanoid:EquipTool(rod)
        end)
        task.wait(0.1)
    end
    
    return rod.Parent == player.Character
end

-- Cast dengan semua method
local function Cast()
    stats.attempts = stats.attempts + 1
    
    local rod = GetRod()
    if not rod then return false end
    
    -- Method 1: FireServer events
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            local castEvent = events:FindFirstChild("cast")
            if castEvent then
                castEvent:FireServer(100, 1)
            end
        end
    end)
    
    -- Method 2: Tool Activate
    pcall(function()
        if rod.Parent == player.Character then
            rod:Activate()
        end
    end)
    
    -- Method 3: Click simulation
    pcall(function()
        mouse.Button1Down:Fire()
        task.wait(0.01)
        mouse.Button1Up:Fire()
    end)
    
    return true
end

-- Auto Reel Function
local function AutoReel()
    while config.autoReel and fishingActive do
        pcall(function()
            -- Method 1: Check reel UI
            local reelUI = playerGui:FindFirstChild("reel")
            if reelUI then
                local bar = reelUI:FindFirstChild("bar")
                if bar then
                    local reelfinish = bar:FindFirstChild("reelfinish")
                    if reelfinish and reelfinish.Visible then
                        -- Fire reel event
                        local events = ReplicatedStorage:FindFirstChild("events")
                        if events then
                            local reelEvent = events:FindFirstChild("reelfinished")
                            if reelEvent then
                                reelEvent:FireServer(100, true)
                                stats.successfulCatch = stats.successfulCatch + 1
                                stats.fishCaught = stats.fishCaught + 1
                            end
                        end
                    end
                end
            end
            
            -- Method 2: Check any fishing GUI
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("TextButton") then
                            local text = obj.Text:lower()
                            if text:find("reel") or text:find("catch") then
                                for _, connection in pairs(getconnections(obj.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.01)
    end
end

-- Auto Shake Function
local function AutoShake()
    while config.autoShake and fishingActive do
        pcall(function()
            local shakeUI = playerGui:FindFirstChild("shakeui")
            if shakeUI and shakeUI.Enabled then
                local safezone = shakeUI:FindFirstChild("safezone")
                if safezone then
                    local button = shakeUI:FindFirstChild("button")
                    if button then
                        -- Perfect shake position
                        local events = ReplicatedStorage:FindFirstChild("events")
                        if events then
                            local shakeEvent = events:FindFirstChild("shake") or events:FindFirstChild("shakereeled")
                            if shakeEvent then
                                shakeEvent:FireServer(100, true)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.01)
    end
end

-- Perfect Catch Function
local function PerfectCatch()
    while config.perfectCatch and fishingActive do
        pcall(function()
            -- Auto perfect timing untuk semua minigame
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    -- Check untuk bar/slider minigame
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("Frame") and obj.Name:lower():find("perfect") then
                            local events = ReplicatedStorage:FindFirstChild("events")
                            if events then
                                for _, event in pairs(events:GetChildren()) do
                                    if event:IsA("RemoteEvent") then
                                        event:FireServer(100, true, "perfect")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.01)
    end
end

-- Main Blantant Fishing Loop
local function BlantantFishing()
    while fishingActive do
        pcall(function()
            -- Equip rod
            if not EquipRod() then
                Status.Text = "⚠️ No Rod Found!"
                Status.TextColor3 = theme.Warning
                task.wait(1)
                return
            end
            
            -- Cast
            if Cast() then
                Status.Text = string.format("⚡ BLANTANT | Fish: %d", stats.fishCaught)
                Status.TextColor3 = theme.Success
            end
            
            task.wait(config.fishingDelay)
        end)
    end
end

local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    stats.startTime = tick()
    Status.Text = "⚡ FISHING ACTIVE"
    Status.TextColor3 = theme.Success
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⚡ BLANTANT AUTO FISHING STARTED")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Start all loops
    fishingLoop = task.spawn(BlantantFishing)
    reelLoop = task.spawn(AutoReel)
    shakeLoop = task.spawn(AutoShake)
    task.spawn(PerfectCatch)
end

local function StopFishing()
    fishingActive = false
    Status.Text = "🔴 STOPPED"
    Status.TextColor3 = theme.Error
    
    if fishingLoop then
        task.cancel(fishingLoop)
        fishingLoop = nil
    end
    if reelLoop then
        task.cancel(reelLoop)
        reelLoop = nil
    end
    if shakeLoop then
        task.cancel(shakeLoop)
        shakeLoop = nil
    end
    
    print("🔴 Fishing stopped")
end

-- =============================================
-- AUTO SELL FUNCTION
-- =============================================

local function AutoSell()
    pcall(function()
        local merchant = workspace:FindFirstChild("world")
        if merchant then
            merchant = merchant:FindFirstChild("npcs")
            if merchant then
                merchant = merchant:FindFirstChild("Merchant")
            end
        end
        
        if merchant and merchant:FindFirstChild("HumanoidRootPart") then
            local char = GetCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                local oldPos = char.HumanoidRootPart.CFrame
                char.HumanoidRootPart.CFrame = merchant.HumanoidRootPart.CFrame
                task.wait(0.5)
                
                local events = ReplicatedStorage:FindFirstChild("events")
                if events then
                    local sellEvent = events:FindFirstChild("sellfish")
                    if sellEvent then
                        sellEvent:FireServer()
                        Status.Text = "💰 SOLD FISH!"
                        Status.TextColor3 = theme.Success
                    end
                end
                
                task.wait(0.5)
                char.HumanoidRootPart.CFrame = oldPos
            end
        end
    end)
end

-- Auto sell loop
task.spawn(function()
    while task.wait(60) do
        if config.autoSell and fishingActive then
            AutoSell()
        end
    end
end)

-- =============================================
-- ANTI AFK
-- =============================================

task.spawn(function()
    while task.wait(120) do
        if config.antiAFK then
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- =============================================
-- UI CREATION FUNCTIONS
-- =============================================

local function ClearContent()
    for _, child in pairs(content:GetChildren()) do
        if child.Name ~= "ContentTitle" then
            child:Destroy()
        end
    end
end

local function CreateScrollFrame()
    local scroll = Instance.new("ScrollingFrame", content)
    scroll.Size = UDim2.new(1, -24, 1, -72)
    scroll.Position = UDim2.new(0, 12, 0, 64)
    scroll.BackgroundColor3 = Color3.fromRGB(14,14,16)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
    local corner = Instance.new("UICorner", scroll)
    corner.CornerRadius = UDim.new(0,8)
    return scroll
end

local function CreateButton(parent, text, pos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 200, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = theme.Accent
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(30,30,30)
    btn.TextSize = 16
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = theme.Accent}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local yOffset = 20
local function CreateToggle(parent, name, desc, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -40, 0, 60)
    frame.Position = UDim2.new(0, 20, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,22)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0,6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 0.5, 0)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLabel = Instance.new("TextLabel", frame)
    descLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    descLabel.Position = UDim2.new(0, 10, 0.5, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(150,150,150)
    descLabel.TextSize = 11
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -70, 0.5, -15)
    toggle.BackgroundColor3 = default and theme.Success or theme.Error
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(30,30,30)
    toggle.TextSize = 12
    toggle.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner", toggle)
    toggleCorner.CornerRadius = UDim.new(0,6)
    
    toggle.MouseButton1Click:Connect(function()
        local new = toggle.Text == "OFF"
        toggle.Text = new and "ON" or "OFF"
        toggle.BackgroundColor3 = new and theme.Success or theme.Error
        callback(new)
    end)
    
    yOffset = yOffset + 70
    return frame
end

-- =============================================
-- CONTENT PANELS
-- =============================================

local function ShowFishingContent()
    ClearContent()
    yOffset = 20
    
    local scroll = CreateScrollFrame()
    
    -- Giant warning
    local warning = Instance.new("Frame", scroll)
    warning.Size = UDim2.new(1, -40, 0, 80)
    warning.Position = UDim2.new(0, 20, 0, 20)
    warning.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    warning.BorderSizePixel = 0
    local wCorner = Instance.new("UICorner", warning)
    wCorner.CornerRadius = UDim.new(0,8)
    
    local wText = Instance.new("TextLabel", warning)
    wText.Size = UDim2.new(1, -20, 1, 0)
    wText.Position = UDim2.new(0, 10, 0, 0)
    wText.BackgroundTransparency = 1
    wText.Font = Enum.Font.GothamBold
    wText.Text = "⚠️ BLANTANT MODE ACTIVE ⚠️\nULTRA FAST FISHING - HIGH DETECTION RISK"
    wText.TextColor3 = Color3.fromRGB(255, 255, 100)
    wText.TextSize = 14
    wText.TextWrapped = true
    
    -- Start/Stop button
    yOffset = 120
    local startBtn = CreateButton(scroll, "⚡ START BLANTANT FISHING", UDim2.new(0, 20, 0, 120), function()
        if fishingActive then
            StopFishing()
            startBtn.Text = "⚡ START BLANTANT FISHING"
            startBtn.BackgroundColor3 = theme.Accent
        else
            StartFishing()
            startBtn.Text = "⏹️ STOP FISHING"
            startBtn.BackgroundColor3 = theme.Error
        end
    end)
    
    yOffset = 200
    
    CreateToggle(scroll, "⚡ Blantant Mode", "Ultra fast fishing (0.01s delay)", config.blantantMode, function(v)
        config.blantantMode = v
        config.fishingDelay = v and 0.01 or 0.1
    end)
    
    CreateToggle(scroll, "Auto Reel", "Auto reel when fish bites", config.autoReel, function(v)
        config.autoReel = v
    end)
    
    CreateToggle(scroll, "Auto Shake", "Auto shake minigame", config.autoShake, function(v)
        config.autoShake = v
    end)
    
    CreateToggle(scroll, "Perfect Catch", "Auto perfect timing", config.perfectCatch, function(v)
        config.perfectCatch = v
    end)
    
    CreateToggle(scroll, "Auto Sell Fish", "Auto sell to merchant every 60s", config.autoSell, function(v)
        config.autoSell = v
    end)
    
    CreateToggle(scroll, "Anti AFK", "Prevent AFK kick", config.antiAFK, function(v)
        config.antiAFK = v
    end)
end

local function ShowStatsContent()
    ClearContent()
    
    local panel = Instance.new("Frame", content)
    panel.Size = UDim2.new(1, -24, 1, -72)
    panel.Position = UDim2.new(0, 12, 0, 64)
    panel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    panel.BorderSizePixel = 0
    local corner = Instance.new("UICorner", panel)
    corner.CornerRadius = UDim.new(0,8)
    
    local function CreateStat(name, value, pos)
        local stat = Instance.new("Frame", panel)
        stat.Size = UDim2.new(0.45, 0, 0, 70)
        stat.Position = pos
        stat.BackgroundColor3 = Color3.fromRGB(20,20,22)
        stat.BorderSizePixel = 0
        local statCorner = Instance.new("UICorner", stat)
        statCorner.CornerRadius = UDim.new(0,8)
        
        local nameLabel = Instance.new("TextLabel", stat)
        nameLabel.Size = UDim2.new(1, -20, 0, 25)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Text = name
        nameLabel.TextColor3 = theme.TextSecondary
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel", stat)
        valueLabel.Size = UDim2.new(1, -20, 0, 35)
        valueLabel.Position = UDim2.new(0, 10, 0, 30)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Text = value
        valueLabel.TextColor3 = theme.Text
        valueLabel.TextSize = 20
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        return stat, valueLabel
    end
    
    local fishStat, fishValue = CreateStat("🎣 Fish Caught", "0", UDim2.new(0, 20, 0, 20))
    local attemptStat, attemptValue = CreateStat("🔄 Attempts", "0", UDim2.new(0.52, 0, 0, 20))
    local successStat, successValue = CreateStat("✅ Success Rate", "0%", UDim2.new(0, 20, 0, 110))
    local rateStat, rateValue = CreateStat("⚡ Fish/Second", "0.00", UDim2.new(0.52, 0, 0, 110))
    local timeStat, timeValue = CreateStat("⏱️ Session Time", "0:00:00", UDim2.new(0, 20, 0, 200))
    local statusStat, statusValue = CreateStat("📊 Status", "Idle", UDim2.new(0.52, 0, 0, 200))
    
    -- Update stats in real-time
    task.spawn(function()
        while task.wait(0.5) do
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            local successRate = stats.attempts > 0 and (stats.successfulCatch / stats.attempts * 100) or 0
            
            fishValue.Text = tostring(stats.fishCaught)
            attemptValue.Text = tostring(stats.attempts)
            successValue.Text = string.format("%.1f%%", successRate)
            rateValue.Text = string.format("%.2f", rate)
            
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)
            timeValue.Text = string.format("%d:%02d:%02d", hours, minutes, seconds)
            
            statusValue.Text = fishingActive and "⚡ ACTIVE" or "🔴 Idle"
            statusValue.TextColor3 = fishingActive and theme.Success or theme.Error
        end
    end)
end

local function ShowTeleportContent()
    ClearContent()
    yOffset = 20
    
    local scroll = CreateScrollFrame()
    
    local islands = {
        {name = "Moosewood", pos = CFrame.new(382, 135, 268)},
        {name = "Roslit Bay", pos = CFrame.new(-1472, 135, 694)},
        {name = "Sunstone Island", pos = CFrame.new(-933, 135, -1044)},
        {name = "Snowcap Island", pos = CFrame.new(2648, 135, 2522)},
        {name = "Mushgrove Swamp", pos = CFrame.new(2501, 135, -720)},
        {name = "The Arch", pos = CFrame.new(1007, 135, -801)},
        {name = "Forsaken Shores", pos = CFrame.new(-2538, 135, 1564)},
        {name = "Ancient Isle", pos = CFrame.new(5930, 135, 497)},
    }
    
    for i, island in ipairs(islands) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -40, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, yOffset)
        btn.BackgroundColor3 = Color3.fromRGB(20,20,22)
        btn.Font = Enum.Font.GothamBold
        btn.Text = "📍 " .. island.name
        btn.TextColor3 = theme.Text
        btn.TextSize = 14
        btn.AutoButtonColor = false
        
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0,6)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40,10,10)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20,20,22)}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            pcall(function()
                local char = GetCharacter()
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = island.pos
                    Status.Text = "📍 Teleported to " .. island.name
                    Status.TextColor3 = theme.Success
                end
            end)
        end)
        
        yOffset = yOffset + 60
    end
    
    -- Sell Fish button
    yOffset = yOffset + 20
    CreateButton(scroll, "💰 SELL FISH NOW", UDim2.new(0, 20, 0, yOffset), function()
        AutoSell()
    end)
end

local function ShowSettingsContent()
    ClearContent()
    yOffset = 20
    
    local scroll = CreateScrollFrame()
    
    local settingsTitle = Instance.new("TextLabel", scroll)
    settingsTitle.Size = UDim2.new(1, -40, 0, 40)
    settingsTitle.Position = UDim2.new(0, 20, 0, 20)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Text = "⚙️ Settings & Configuration"
    settingsTitle.TextColor3 = theme.Text
    settingsTitle.TextSize = 16
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    yOffset = 70
    
    CreateToggle(scroll, "Anti AFK", "Prevent AFK kick", config.antiAFK, function(v)
        config.antiAFK = v
        print("[Settings] Anti AFK:", v)
    end)
    
    CreateToggle(scroll, "Auto Equip Rod", "Auto equip fishing rod", config.autoEquipRod, function(v)
        config.autoEquipRod = v
        print("[Settings] Auto Equip:", v)
    end)
    
    CreateToggle(scroll, "Auto Sell", "Auto sell every 60s", config.autoSell, function(v)
        config.autoSell = v
        print("[Settings] Auto Sell:", v)
    end)
    
    -- Delay slider
    yOffset = yOffset + 20
    local sliderFrame = Instance.new("Frame", scroll)
    sliderFrame.Size = UDim2.new(1, -40, 0, 80)
    sliderFrame.Position = UDim2.new(0, 20, 0, yOffset)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
    sliderFrame.BorderSizePixel = 0
    local sliderCorner = Instance.new("UICorner", sliderFrame)
    sliderCorner.CornerRadius = UDim.new(0,6)
    
    local sliderLabel = Instance.new("TextLabel", sliderFrame)
    sliderLabel.Size = UDim2.new(1, -20, 0, 25)
    sliderLabel.Position = UDim2.new(0, 10, 0, 5)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.Text = string.format("Fishing Delay: %.3fs", config.fishingDelay)
    sliderLabel.TextColor3 = theme.Text
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame", sliderFrame)
    sliderBg.Size = UDim2.new(1, -40, 0, 8)
    sliderBg.Position = UDim2.new(0, 20, 0, 45)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    sliderBg.BorderSizePixel = 0
    local sliderBgCorner = Instance.new("UICorner", sliderBg)
    sliderBgCorner.CornerRadius = UDim.new(1,0)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(config.fishingDelay / 1, 0, 1, 0)
    sliderFill.BackgroundColor3 = theme.Accent
    sliderFill.BorderSizePixel = 0
    local sliderFillCorner = Instance.new("UICorner", sliderFill)
    sliderFillCorner.CornerRadius = UDim.new(1,0)
    
    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(0, 24, 0, 24)
    sliderBtn.Position = UDim2.new(config.fishingDelay / 1, -12, 0.5, -12)
    sliderBtn.BackgroundColor3 = theme.Accent
    sliderBtn.Text = ""
    sliderBtn.AutoButtonColor = false
    local sliderBtnCorner = Instance.new("UICorner", sliderBtn)
    sliderBtnCorner.CornerRadius = UDim.new(1,0)
    
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderSize = sliderBg.AbsoluteSize.X
            local relative = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            
            config.fishingDelay = math.clamp(relative * 1, 0.01, 1)
            sliderLabel.Text = string.format("Fishing Delay: %.3fs", config.fishingDelay)
            sliderFill.Size = UDim2.new(relative, 0, 1, 0)
            sliderBtn.Position = UDim2.new(relative, -12, 0.5, -12)
        end
    end)
    
    yOffset = yOffset + 100
    
    -- Reset Stats button
    CreateButton(scroll, "🔄 RESET STATS", UDim2.new(0, 20, 0, yOffset), function()
        stats.fishCaught = 0
        stats.attempts = 0
        stats.successfulCatch = 0
        stats.failedCatch = 0
        stats.startTime = tick()
        Status.Text = "📊 Stats Reset"
        Status.TextColor3 = theme.Success
    end)
    
    yOffset = yOffset + 70
    
    -- Info panel
    local infoPanel = Instance.new("Frame", scroll)
    infoPanel.Size = UDim2.new(1, -40, 0, 120)
    infoPanel.Position = UDim2.new(0, 20, 0, yOffset)
    infoPanel.BackgroundColor3 = Color3.fromRGB(15,15,20)
    infoPanel.BorderSizePixel = 0
    local infoCorner = Instance.new("UICorner", infoPanel)
    infoCorner.CornerRadius = UDim.new(0,8)
    
    local infoText = Instance.new("TextLabel", infoPanel)
    infoText.Size = UDim2.new(1, -20, 1, -10)
    infoText.Position = UDim2.new(0, 10, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.Gotham
    infoText.Text = [[ℹ️ BLANTANT MODE INFO:

⚡ Ultra fast fishing with 0.01s delay
🎯 Auto reel, shake, and perfect catch
💰 Auto sell every 60 seconds
🛡️ Anti AFK protection
⚠️ HIGH DETECTION RISK - Use at own risk]]
    infoText.TextColor3 = theme.TextSecondary
    infoText.TextSize = 12
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.TextWrapped = true
end

-- =============================================
-- MENU NAVIGATION
-- =============================================

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
            ShowStatsContent()
        elseif name == "Teleport" then
            ShowTeleportContent()
        elseif name == "Settings" then
            ShowSettingsContent()
        end
    end)
end

-- Initialize
ShowFishingContent()
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- =============================================
-- UI STATE MANAGEMENT
-- =============================================

local uiState = {
    isMinimized = false,
    isVisible = true
}

local function MinimizeUI()
    uiState.isMinimized = true
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 350, 0, 80)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 430, 0, 160),
        ImageTransparency = 0.95
    }):Play()
    
    sidebar.Visible = false
    content.Visible = false
    
    title.Text = "⚡ Kaitun Fish"
    Status.Text = "⬇️ Minimized"
end

local function MaximizeUI()
    uiState.isMinimized = false
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80),
        ImageTransparency = 0.92
    }):Play()
    
    sidebar.Visible = true
    content.Visible = true
    
    title.Text = "⚡ KAITUN FISH IT - BLANTANT"
    Status.Text = fishingActive and "⚡ ACTIVE" or "🔴 Ready"
end

local function ToggleMinimize()
    if uiState.isMinimized then
        MaximizeUI()
    else
        MinimizeUI()
    end
end

-- Button events
minimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
maximizeBtn.MouseButton1Click:Connect(ToggleMinimize)

-- Hover effects
minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 170, 0)}):Play()
end)

maximizeBtn.MouseEnter:Connect(function()
    TweenService:Create(maximizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 230, 255)}):Play()
end)
maximizeBtn.MouseLeave:Connect(function()
    TweenService:Create(maximizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
end)

-- Make UI draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    local newX = startPos.X.Scale
    local newXOffset = startPos.X.Offset + delta.X
    local newY = startPos.Y.Scale
    local newYOffset = startPos.Y.Offset + delta.Y
    
    container.Position = UDim2.new(newX, newXOffset, newY, newYOffset)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Initialize UI
MaximizeUI()

-- =============================================
-- FINAL INITIALIZATION
-- =============================================

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("⚡ KAITUN FISH IT - BLANTANT AUTO FISHING")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ UI Loaded Successfully")
print("⚡ Blantant Mode: READY")
print("🎣 Auto Fishing: READY")
print("🎯 Auto Reel/Shake: READY")
print("📍 Teleport: READY")
print("💰 Auto Sell: READY")
print("🛡️ Anti AFK: READY")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎮 Features:")
print("   • Ultra Fast Fishing (0.01s delay)")
print("   • Auto Cast, Reel, Shake, Perfect Catch")
print("   • Auto Sell every 60 seconds")
print("   • Island Teleport")
print("   • Real-time Stats")
print("   • Draggable UI (drag title bar)")
print("   • Minimize/Maximize (- and □ buttons)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("⚠️ WARNING: BLANTANT MODE IS VERY FAST")
print("⚠️ HIGH DETECTION RISK - USE AT OWN RISK")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🚀 Ready! Click START BLANTANT FISHING")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━") Equip Rod", "Auto equip fishing rod", config.autoEquipRod, function(v)
        config.autoEquipRod = v
    end)
    
    CreateToggle(scroll, "Auto
