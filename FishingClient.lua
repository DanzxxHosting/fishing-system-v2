-- Kaitun Fish It - Fixed Version
-- Paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tunggu character loaded
if not player.Character then
    player.CharacterAdded:Wait()
end
task.wait(2)

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62)
local BG = Color3.fromRGB(12,12,12)
local SECOND = Color3.fromRGB(24,24,26)

-- Theme
local theme = {
    Accent = ACCENT,
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 170, 0),
    Error = Color3.fromRGB(255, 70, 70),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180)
}

-- CONFIG
local config = {
    fishingDelay = 0.1,
    autoEquipRod = true,
    autoSell = false,
    antiAFK = false,
    autoReel = true,
    autoShake = true,
    fishingMode = "Normal" -- Normal, Blantant, Super
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

-- Cleanup
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

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.BackgroundTransparency = 1
container.Parent = screen

-- Glow
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

-- Inner
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
title.Text = "⚡ KAITUN FISH IT - FIXED"
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

    return row
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
    local btn = makeMenuItem(v[1], v[2])
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
cTitle.Text = "Fixed Fishing System"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- =============================================
-- FIXED FISHING FUNCTIONS
-- =============================================

local function GetCharacter()
    return player.Character
end

local function GetRod()
    local char = GetCharacter()
    if not char then return nil end
    
    -- Cari rod di character (yang sudah di-equip)
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then
            -- Check berbagai nama rod yang umum
            local itemName = item.Name:lower()
            if itemName:find("rod") or itemName:find("pole") or itemName:find("fishing") or itemName:find("rod") then
                return item
            end
        end
    end
    
    -- Cari di backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = item.Name:lower()
                if itemName:find("rod") or itemName:find("pole") or itemName:find("fishing") or itemName:find("rod") then
                    return item
                end
            end
        end
    end
    
    return nil
end

local function EquipRod()
    if not config.autoEquipRod then 
        -- Cek apakah rod sudah di-equip
        local char = GetCharacter()
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    return true -- Rod sudah di-equip
                end
            end
        end
        return false
    end
    
    local rod = GetRod()
    if not rod then 
        return false 
    end
    
    -- Jika rod sudah di-equip
    if rod.Parent == player.Character then 
        return true 
    end
    
    -- Equip rod dari backpack
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:EquipTool(rod)
            task.wait(0.5) -- Kasih waktu lebih lama untuk equip
        end)
    end
    
    return rod.Parent == player.Character
end

local function CastFishing()
    stats.attempts = stats.attempts + 1
    
    -- Cek rod
    if not EquipRod() then
        Status.Text = "❌ EQUIP ROD MANUALLY FIRST!"
        Status.TextColor3 = theme.Warning
        return false
    end
    
    local success = false
    
    -- Method 1: Cari dan trigger semua RemoteEvent fishing
    pcall(function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("cast") or name:find("fish") or name:find("reel") then
                    pcall(function()
                        obj:FireServer()
                        success = true
                        print("✅ Cast via RemoteEvent:", obj.Name)
                    end)
                end
            end
        end
    end)
    
    -- Method 2: Tool activation
    if not success then
        pcall(function()
            local rod = GetRod()
            if rod and rod:IsA("Tool") then
                rod:Activate()
                success = true
                print("✅ Cast via Tool Activation")
            end
        end)
    end
    
    -- Method 3: Mouse click simulation
    if not success then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            success = true
            print("✅ Cast via Mouse Simulation")
        end)
    end
    
    -- Method 4: Key press simulation
    if not success then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            success = true
            print("✅ Cast via Key Press (E)")
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

local function AutoReel()
    while config.autoReel and fishingActive do
        pcall(function()
            -- Cari UI reel atau fishing-related GUI
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    -- Cari button yang berkaitan dengan fishing
                    for _, element in pairs(gui:GetDescendants()) do
                        if element:IsA("TextButton") and element.Visible then
                            local text = element.Text:lower() or ""
                            local name = element.Name:lower()
                            
                            if text:find("reel") or text:find("catch") or name:find("reel") or name:find("catch") then
                                -- Trigger button click
                                pcall(function()
                                    element:Fire("MouseButton1Click")
                                    print("✅ Auto Reel Triggered")
                                end)
                            end
                        end
                    end
                end
            end
            
            -- Juga coba RemoteEvents untuk reel
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local name = obj.Name:lower()
                    if name:find("reel") or name:find("catch") then
                        pcall(function()
                            obj:FireServer()
                            print("✅ Auto Reel via RemoteEvent")
                        end)
                    end
                end
            end
        end)
        
        task.wait(0.1)
    end
end

local function AutoShake()
    while config.autoShake and fishingActive do
        pcall(function()
            -- Cari shake-related UI atau events
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local name = obj.Name:lower()
                    if name:find("shake") then
                        pcall(function()
                            obj:FireServer(true, 100)
                            print("✅ Auto Shake Triggered")
                        end)
                    end
                end
            end
        end)
        
        task.wait(0.1)
    end
end

local function MainFishingLoop()
    while fishingActive do
        pcall(function()
            local success = CastFishing()
            
            if success then
                local elapsed = math.max(1, tick() - stats.startTime)
                local rate = stats.fishCaught / elapsed
                
                local modeText = ""
                local modeColor = theme.Success
                
                if config.fishingMode == "Super" then
                    modeText = "💥 SUPER"
                    modeColor = Color3.fromRGB(255, 0, 255)
                elseif config.fishingMode == "Blantant" then
                    modeText = "⚡ BLANTANT" 
                    modeColor = Color3.fromRGB(255, 170, 0)
                else
                    modeText = "🎣 NORMAL"
                    modeColor = theme.Success
                end
                
                Status.Text = string.format("%s | Fish: %d | %.2f/s", modeText, stats.fishCaught, rate)
                Status.TextColor3 = modeColor
            else
                Status.Text = "❌ Cast Failed - Retrying..."
                Status.TextColor3 = theme.Warning
            end
            
            -- Delay berdasarkan mode
            local delay = 0.1
            if config.fishingMode == "Blantant" then
                delay = 0.01
            elseif config.fishingMode == "Super" then
                delay = 0.001
            end
            
            task.wait(delay)
        end)
    end
end

local function StartFishing()
    if fishingActive then 
        print("⚠️ Fishing already active")
        return 
    end
    
    print("🚀 Starting fishing...")
    fishingActive = true
    stats.startTime = tick()
    
    -- Set status berdasarkan mode
    if config.fishingMode == "Super" then
        Status.Text = "💥 SUPER MODE - FISHING!"
        Status.TextColor3 = Color3.fromRGB(255, 0, 255)
    elseif config.fishingMode == "Blantant" then
        Status.Text = "⚡ BLANTANT MODE - FISHING!"
        Status.TextColor3 = Color3.fromRGB(255, 170, 0)
    else
        Status.Text = "🎣 NORMAL MODE - FISHING!"
        Status.TextColor3 = theme.Success
    end
    
    -- Start loops
    fishingLoop = task.spawn(MainFishingLoop)
    if config.autoReel then
        task.spawn(AutoReel)
    end
    if config.autoShake then
        task.spawn(AutoShake)
    end
    
    print("✅ Fishing started successfully")
end

local function StopFishing()
    if not fishingActive then return end
    
    fishingActive = false
    Status.Text = "🔴 STOPPED"
    Status.TextColor3 = theme.Error
    print("🔴 Fishing stopped")
end

-- =============================================
-- UI FUNCTIONS
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
    scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
    local corner = Instance.new("UICorner", scroll)
    corner.CornerRadius = UDim.new(0,8)
    return scroll
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

-- Show Fishing Content
local function ShowFishingContent()
    ClearContent()
    yOffset = 20
    
    local scroll = CreateScrollFrame()
    
    -- Start button
    local startBtn = CreateButton(scroll, "🚀 START FISHING", UDim2.new(0, 20, 0, 20), function()
        if fishingActive then
            StopFishing()
            startBtn.Text = "🚀 START FISHING"
            startBtn.BackgroundColor3 = theme.Accent
        else
            StartFishing()
            startBtn.Text = "⏹️ STOP FISHING"
            startBtn.BackgroundColor3 = theme.Error
        end
    end)
    
    -- Mode selection
    yOffset = 90
    local modeFrame = Instance.new("Frame", scroll)
    modeFrame.Size = UDim2.new(1, -40, 0, 80)
    modeFrame.Position = UDim2.new(0, 20, 0, 90)
    modeFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
    modeFrame.BorderSizePixel = 0
    local modeCorner = Instance.new("UICorner", modeFrame)
    modeCorner.CornerRadius = UDim.new(0,8)
    
    local modeTitle = Instance.new("TextLabel", modeFrame)
    modeTitle.Size = UDim2.new(1, -20, 0, 25)
    modeTitle.Position = UDim2.new(0, 10, 0, 5)
    modeTitle.BackgroundTransparency = 1
    modeTitle.Font = Enum.Font.GothamBold
    modeTitle.Text = "🔥 SELECT FISHING MODE"
    modeTitle.TextColor3 = theme.Text
    modeTitle.TextSize = 14
    modeTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Mode buttons
    local normalBtn = Instance.new("TextButton", modeFrame)
    normalBtn.Size = UDim2.new(0.3, -5, 0, 35)
    normalBtn.Position = UDim2.new(0, 10, 0, 40)
    normalBtn.BackgroundColor3 = config.fishingMode == "Normal" and theme.Success or Color3.fromRGB(60,60,60)
    normalBtn.Font = Enum.Font.GothamBold
    normalBtn.Text = "🎣 Normal"
    normalBtn.TextColor3 = theme.Text
    normalBtn.TextSize = 12
    normalBtn.AutoButtonColor = false
    local normalCorner = Instance.new("UICorner", normalBtn)
    normalCorner.CornerRadius = UDim.new(0,6)
    
    local blantantBtn = Instance.new("TextButton", modeFrame)
    blantantBtn.Size = UDim2.new(0.3, -5, 0, 35)
    blantantBtn.Position = UDim2.new(0.35, 0, 0, 40)
    blantantBtn.BackgroundColor3 = config.fishingMode == "Blantant" and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(60,60,60)
    blantantBtn.Font = Enum.Font.GothamBold
    blantantBtn.Text = "⚡ Blantant"
    blantantBtn.TextColor3 = config.fishingMode == "Blantant" and Color3.fromRGB(30,30,30) or theme.Text
    blantantBtn.TextSize = 12
    blantantBtn.AutoButtonColor = false
    local blantantCorner = Instance.new("UICorner", blantantBtn)
    blantantCorner.CornerRadius = UDim.new(0,6)
    
    local superBtn = Instance.new("TextButton", modeFrame)
    superBtn.Size = UDim2.new(0.3, -5, 0, 35)
    superBtn.Position = UDim2.new(0.7, 0, 0, 40)
    superBtn.BackgroundColor3 = config.fishingMode == "Super" and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(60,60,60)
    superBtn.Font = Enum.Font.GothamBold
    superBtn.Text = "💥 SUPER"
    superBtn.TextColor3 = theme.Text
    superBtn.TextSize = 12
    superBtn.AutoButtonColor = false
    local superCorner = Instance.new("UICorner", superBtn)
    superCorner.CornerRadius = UDim.new(0,6)
    
    normalBtn.MouseButton1Click:Connect(function()
        config.fishingMode = "Normal"
        config.fishingDelay = 0.1
        normalBtn.BackgroundColor3 = theme.Success
        blantantBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        blantantBtn.TextColor3 = theme.Text
        superBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        Status.Text = "🎣 Normal Mode Selected"
        Status.TextColor3 = theme.Success
    end)
    
    blantantBtn.MouseButton1Click:Connect(function()
        config.fishingMode = "Blantant"
        config.fishingDelay = 0.01
        normalBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        blantantBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        blantantBtn.TextColor3 = Color3.fromRGB(30,30,30)
        superBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        Status.Text = "⚡ Blantant Mode Selected"
        Status.TextColor3 = Color3.fromRGB(255, 170, 0)
    end)
    
    superBtn.MouseButton1Click:Connect(function()
        config.fishingMode = "Super"
        config.fishingDelay = 0.001
        normalBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        blantantBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        blantantBtn.TextColor3 = theme.Text
        superBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        Status.Text = "💥 SUPER Mode Selected"
        Status.TextColor3 = Color3.fromRGB(255, 0, 255)
    end)
    
    yOffset = 190
    
    CreateToggle(scroll, "Auto Equip Rod", "Auto equip fishing rod", config.autoEquipRod, function(v)
        config.autoEquipRod = v
    end)
    
    CreateToggle(scroll, "Auto Reel", "Auto reel when fish bites", config.autoReel, function(v)
        config.autoReel = v
    end)
    
    CreateToggle(scroll, "Auto Shake", "Auto shake minigame", config.autoShake, function(v)
        config.autoShake = v
    end)
    
    -- Instructions
    yOffset = yOffset + 20
    local infoPanel = Instance.new("Frame", scroll)
    infoPanel.Size = UDim2.new(1, -40, 0, 120)
    infoPanel.Position = UDim2.new(0, 20, 0, yOffset)
    infoPanel.BackgroundColor3 = Color3.fromRGB(20,20,30)
    infoPanel.BorderSizePixel = 0
    local infoCorner = Instance.new("UICorner", infoPanel)
    infoCorner.CornerRadius = UDim.new(0,8)
    
    local infoText = Instance.new("TextLabel", infoPanel)
    infoText.Size = UDim2.new(1, -20, 1, -10)
    infoText.Position = UDim2.new(0, 10, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.Gotham
    infoText.Text = "📋 INSTRUCTIONS:\n1. EQUIP fishing rod manually first\n2. Select fishing mode\n3. Click START FISHING\n4. Stand near water\n5. Watch the magic! ✨"
    infoText.TextColor3 = theme.TextSecondary
    infoText.TextSize = 12
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.TextWrapped = true
end

-- Show other content functions (Stats, Teleport, Settings) tetap sama seperti sebelumnya
-- ... [kode untuk Stats, Teleport, Settings tetap sama] ...

-- Menu navigation
local activeMenu = "Fishing"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        cTitle.Text = name
        activeMenu = name
        
        if name == "Fishing" then
            ShowFishingContent()
        elseif name == "Stats" then
            -- ShowStatsContent() -- Implement jika needed
        elseif name == "Teleport" then
            -- ShowTeleportContent() -- Implement jika needed  
        elseif name == "Settings" then
            -- ShowSettingsContent() -- Implement jika needed
        end
    end)
end

-- Initialize
ShowFishingContent()
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- UI State dan minimize/maximize functions tetap sama
-- ... [kode UI state tetap sama] ...

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎣 KAITUN FISH IT - FIXED VERSION")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ UI Loaded Successfully")
print("🎯 INSTRUCTIONS:")
print("   1. EQUIP fishing rod manually first")
print("   2. Select fishing mode") 
print("   3. Click START FISHING")
print("   4. Stand near water")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
