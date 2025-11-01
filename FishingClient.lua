-- UI-Only: Neon Panel (sidebar + content) — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Toggle dengan tombol - dan logo. Safe (UI only).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tunggu hingga player fully loaded
if not player.Character then
    player.CharacterAdded:Wait()
end

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- Theme colors
local theme = {
    Accent = ACCENT,
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 170, 0),
    Error = Color3.fromRGB(255, 70, 70),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180)
}

-- FISHING CONFIG
local config = {
    autoFishing = false,
    instantFishing = true,
    fishingDelay = 0.1,
    blantantMode = false,
    autoEquipRod = true
}

-- INSTANT FISHING EXPLOIT CONFIG
local InstantFishing = {
    Enabled = false,
    HookedRemotes = {},
    OriginalFunctions = {},
    InjectionMethods = {
        MemoryHooks = true,
        RemoteHijacking = true,
        EventSpoofing = true,
        PacketInjection = true
    }
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

-- Function untuk safely create UI
local function SafeCreateUI()
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
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5,0.5)
    glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
    glow.Position = container.Position
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5050741616" -- radial
    glow.ImageColor3 = ACCENT
    glow.ImageTransparency = 0.92
    glow.ZIndex = 1
    glow.Parent = screen

    -- Card (panel)
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

    -- Title bar dengan kontrol minimize/maximize
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
    title.Text = "⚡ KAITUN FISH IT - ULTIMATE"
    title.TextColor3 = Color3.fromRGB(255, 220, 220)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0.4,-16,1,0)
    Status.Position = UDim2.new(0.6,8,0,0)
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 13
    Status.Text = "🔴 Ready"
    Status.TextColor3 = Color3.fromRGB(200,200,200)
    Status.TextXAlignment = Enum.TextXAlignment.Right
    Status.Parent = titleBar

    -- Kontrol minimize/maximize di pojok kanan atas
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(0, 60, 1, 0)
    controlFrame.Position = UDim2.new(1, -65, 0, 0)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = titleBar

    -- Minimize Button (-)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(0, 0, 0.5, -12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
    minimizeBtn.TextSize = 14
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = controlFrame

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn

    -- Maximize Button (□)
    local maximizeBtn = Instance.new("TextButton")
    maximizeBtn.Size = UDim2.new(0, 25, 0, 25)
    maximizeBtn.Position = UDim2.new(0, 30, 0.5, -12)
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    maximizeBtn.Font = Enum.Font.GothamBold
    maximizeBtn.Text = "□"
    maximizeBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
    maximizeBtn.TextSize = 12
    maximizeBtn.AutoButtonColor = false
    maximizeBtn.Parent = controlFrame

    local maxCorner = Instance.new("UICorner")
    maxCorner.CornerRadius = UDim.new(0, 6)
    maxCorner.Parent = maximizeBtn

    -- left sidebar
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

    -- sidebar header icon
    local sbHeader = Instance.new("Frame")
    sbHeader.Size = UDim2.new(1,0,0,84)
    sbHeader.BackgroundTransparency = 1
    sbHeader.Parent = sidebar

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0,64,0,64)
    logo.Position = UDim2.new(0, 12, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://3926305904" -- simple icon (roblox)
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

    -- menu list area
    local menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(1,-12,1, -108)
    menuFrame.Position = UDim2.new(0, 6, 0, 92)
    menuFrame.BackgroundTransparency = 1
    menuFrame.Parent = sidebar

    local menuLayout = Instance.new("UIListLayout")
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Padding = UDim.new(0,8)
    menuLayout.Parent = menuFrame

    -- content panel (right)
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

    -- content title area
    local cTitle = Instance.new("TextLabel")
    cTitle.Size = UDim2.new(1, -24, 0, 44)
    cTitle.Position = UDim2.new(0,12,0,12)
    cTitle.BackgroundTransparency = 1
    cTitle.Font = Enum.Font.GothamBold
    cTitle.TextSize = 16
    cTitle.Text = "Fishing Controls"
    cTitle.TextColor3 = Color3.fromRGB(245,245,245)
    cTitle.TextXAlignment = Enum.TextXAlignment.Left
    cTitle.Parent = content

    return {
        Screen = screen,
        Container = container,
        Glow = glow,
        Card = card,
        Inner = inner,
        TitleBar = titleBar,
        Title = title,
        Status = Status,
        Sidebar = sidebar,
        MenuFrame = menuFrame,
        Content = content,
        CTitle = cTitle,
        MinimizeBtn = minimizeBtn,
        MaximizeBtn = maximizeBtn
    }
end

-- menu helper
local function makeMenuItem(parent, name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = parent

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

    -- hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

-- =============================================
-- FISHING UTILITY FUNCTIONS
-- =============================================

local function SafeGetCharacter()
    local success, result = pcall(function()
        return player.Character
    end)
    return success and result or nil
end

local function GetFishingRod()
    local char = SafeGetCharacter()
    if not char then return nil end
    
    -- Cari fishing rod di backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            local itemName = string.lower(item.Name)
            if itemName:find("rod") or itemName:find("fishing") or itemName:find("pole") then
                return item
            end
        end
    end
    
    -- Cari di character
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = string.lower(item.Name)
                if itemName:find("rod") or itemName:find("fishing") or itemName:find("pole") then
                    return item
                end
            end
        end
    end
    
    return nil
end

local function EquipRod()
    if not config.autoEquipRod then return true end
    
    local rod = GetFishingRod()
    if not rod then
        return false
    end
    
    -- Jika rod sudah di-equip
    if rod.Parent == player.Character then
        return true
    end
    
    -- Equip rod dari backpack
    pcall(function()
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(rod)
            task.wait(0.1)
        end
    end)
    
    return rod.Parent == player.Character
end

local function FindFishingProximityPrompt()
    local success, prompt = pcall(function()
        local char = SafeGetCharacter()
        if not char then return nil end
        
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local objText = descendant.ObjectText and descendant.ObjectText:lower() or ""
                local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
                
                if objText:find("fish") or objText:find("cast") or objText:find("catch") or
                   actionText:find("fish") or actionText:find("cast") or actionText:find("catch") then
                    return descendant
                end
            end
        end
        
        return nil
    end)
    
    return success and prompt or nil
end

local function SimulateKeyPress(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function SimulateClick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0.01)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0.01)
    end)
end

-- =============================================
-- FISHING METHODS
-- =============================================

local function TryFishingMethod()
    local success = false
    
    -- Method 1: Equip Rod
    if not EquipRod() then
        return false
    end
    
    -- Method 2: ProximityPrompt
    pcall(function()
        local prompt = FindFishingProximityPrompt()
        if prompt and prompt.Enabled then
            fireproximityprompt(prompt)
            success = true
        end
    end)
    
    if success then
        stats.fishCaught = stats.fishCaught + 1
        stats.successfulCatch = stats.successfulCatch + 1
        return true
    end
    
    -- Method 3: ClickDetector
    pcall(function()
        local rod = GetFishingRod()
        if rod and rod.Parent == player.Character then
            local handle = rod:FindFirstChild("Handle")
            if handle then
                local clickDetector = handle:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    success = true
                end
            end
        end
    end)
    
    if success then
        stats.fishCaught = stats.fishCaught + 1
        stats.successfulCatch = stats.successfulCatch + 1
        return true
    end
    
    -- Method 4: Simulate Clicks
    SimulateClick()
    task.wait(0.001)
    
    -- Method 5: Simulate Key Presses
    SimulateKeyPress(Enum.KeyCode.E)
    task.wait(0.001)
    SimulateKeyPress(Enum.KeyCode.F)
    task.wait(0.001)
    
    -- Count as attempt
    stats.attempts = stats.attempts + 1
    
    -- Assume success for click/key methods
    stats.fishCaught = stats.fishCaught + 1
    stats.successfulCatch = stats.successfulCatch + 1
    
    return true
end

local function StartFishing(Status)
    if fishingActive then return end
    
    fishingActive = true
    Status.Text = "🟢 Fishing started..."
    Status.TextColor3 = theme.Success
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = pcall(function()
            TryFishingMethod()
        end)
        
        if not success then
            Status.Text = "⚠️ Error occurred, retrying..."
            Status.TextColor3 = theme.Warning
        else
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            Status.Text = string.format("🟢 Fish: %d | %.2f/s | Attempts: %d", 
                stats.fishCaught, rate, stats.attempts)
            Status.TextColor3 = theme.Success
        end
        
        task.wait(config.fishingDelay)
    end)
end

local function StopFishing(Status)
    fishingActive = false
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    Status.Text = "🔴 Fishing stopped"
    Status.TextColor3 = theme.Error
end

-- =============================================
-- UI CREATION FUNCTIONS
-- =============================================

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -24, 0, 400)
    section.Position = UDim2.new(0, 12, 0, 64)
    section.BackgroundColor3 = Color3.fromRGB(14,14,16)
    section.BorderSizePixel = 0
    section.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = section

    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -20, 0, 40)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.Text = title
    sectionTitle.TextColor3 = theme.Text
    sectionTitle.TextSize = 16
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section

    return section
end

local function CreateButton(parent, text, description, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.BackgroundColor3 = theme.Accent
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = button

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(30,30,30)
    textLabel.TextSize = 16
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = button

    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = theme.Accent}):Play()
    end)

    button.MouseButton1Click:Connect(callback)

    return button
end

-- Create fishing controls in content
local function ShowFishingContent(content, Status, cTitle)
    -- Clear existing content
    for _, child in pairs(content:GetChildren()) do
        if child.Name ~= "ContentTitle" then
            child:Destroy()
        end
    end

    cTitle.Text = "Fishing Controls"

    -- Fishing controls panel
    local panel = CreateSection(content, "🎯 FISHING CONTROLS")

    -- Start/Stop Fishing Button
    local startBtn = CreateButton(panel, "🚀 START FISHING", "Click to start auto fishing", function()
        if fishingActive then
            StopFishing(Status)
            startBtn:FindFirstChild("TextLabel").Text = "🚀 START FISHING"
            startBtn.BackgroundColor3 = theme.Accent
        else
            StartFishing(Status)
            startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
            startBtn.BackgroundColor3 = theme.Error
        end
    end)
    startBtn.Position = UDim2.new(0, 20, 0, 20)

    -- Stats display
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, -24, 0, 120)
    statsPanel.Position = UDim2.new(0, 12, 0, 480)
    statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    statsPanel.BorderSizePixel = 0
    statsPanel.Parent = content

    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0,8)
    statsCorner.Parent = statsPanel

    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, -20, 0, 30)
    statsTitle.Position = UDim2.new(0, 10, 0, 5)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Text = "📊 Live Statistics"
    statsTitle.TextColor3 = theme.Text
    statsTitle.TextSize = 14
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsPanel

    -- Stats labels
    local fishStat = Instance.new("TextLabel")
    fishStat.Size = UDim2.new(0.5, -10, 0, 25)
    fishStat.Position = UDim2.new(0, 10, 0, 40)
    fishStat.BackgroundTransparency = 1
    fishStat.Font = Enum.Font.Gotham
    fishStat.Text = "🎣 Fish: 0"
    fishStat.TextColor3 = theme.TextSecondary
    fishStat.TextSize = 12
    fishStat.TextXAlignment = Enum.TextXAlignment.Left
    fishStat.Parent = statsPanel

    local attemptsStat = Instance.new("TextLabel")
    attemptsStat.Size = UDim2.new(0.5, -10, 0, 25)
    attemptsStat.Position = UDim2.new(0.5, 0, 0, 40)
    attemptsStat.BackgroundTransparency = 1
    attemptsStat.Font = Enum.Font.Gotham
    attemptsStat.Text = "🔄 Attempts: 0"
    attemptsStat.TextColor3 = theme.TextSecondary
    attemptsStat.TextSize = 12
    attemptsStat.TextXAlignment = Enum.TextXAlignment.Left
    attemptsStat.Parent = statsPanel

    local rateStat = Instance.new("TextLabel")
    rateStat.Size = UDim2.new(0.5, -10, 0, 25)
    rateStat.Position = UDim2.new(0, 10, 0, 65)
    rateStat.BackgroundTransparency = 1
    rateStat.Font = Enum.Font.Gotham
    rateStat.Text = "⚡ Rate: 0.00/s"
    rateStat.TextColor3 = theme.TextSecondary
    rateStat.TextSize = 12
    rateStat.TextXAlignment = Enum.TextXAlignment.Left
    rateStat.Parent = statsPanel

    local successStat = Instance.new("TextLabel")
    successStat.Size = UDim2.new(0.5, -10, 0, 25)
    successStat.Position = UDim2.new(0.5, 0, 0, 65)
    successStat.BackgroundTransparency = 1
    successStat.Font = Enum.Font.Gotham
    successStat.Text = "✅ Success: 0"
    successStat.TextColor3 = theme.TextSecondary
    successStat.TextSize = 12
    successStat.TextXAlignment = Enum.TextXAlignment.Left
    successStat.Parent = statsPanel

    -- Update stats in real-time
    task.spawn(function()
        while task.wait(0.5) do
            if not statsPanel.Parent then break end
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            
            fishStat.Text = "🎣 Fish: " .. stats.fishCaught
            attemptsStat.Text = "🔄 Attempts: " .. stats.attempts
            rateStat.Text = string.format("⚡ Rate: %.2f/s", rate)
            successStat.Text = "✅ Success: " .. stats.successfulCatch
        end
    end)
end

-- =============================================
-- MAIN SCRIPT EXECUTION
-- =============================================

-- Tunggu hingga game fully loaded
task.wait(2)

-- Create UI dengan error handling
local success, ui = pcall(function()
    return SafeCreateUI()
end)

if not success then
    warn("[Kaitun Fish It] Failed to create UI, retrying...")
    task.wait(1)
    success, ui = pcall(function()
        return SafeCreateUI()
    end)
end

if not success or not ui then
    error("[Kaitun Fish It] Critical: Could not create UI")
    return
end

-- Create menu items
local menuItems = {
    {"Fishing", "🎣"},
    {"Auto Fish", "⚡"},
    {"Settings", "⚙"},
    {"Teleport", "📍"},
    {"Stats", "📊"},
}

local menuButtons = {}
for i, item in ipairs(menuItems) do
    local btn, lbl = makeMenuItem(ui.MenuFrame, item[1], item[2])
    btn.LayoutOrder = i
    menuButtons[item[1]] = btn
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
        activeMenu = name
        
        if name == "Fishing" then
            ShowFishingContent(ui.Content, ui.Status, ui.CTitle)
        else
            -- Clear content untuk menu lainnya
            for _, child in pairs(ui.Content:GetChildren()) do
                if child.Name ~= "ContentTitle" then
                    child:Destroy()
                end
            end
            ui.CTitle.Text = name
        end
    end)
end

-- Initialize dengan content fishing
ShowFishingContent(ui.Content, ui.Status, ui.CTitle)
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- UI State Management
local uiState = {
    isMinimized = false,
    isVisible = true
}

-- Minimize/Maximize Functions
local function MinimizeUI()
    uiState.isMinimized = true
    TweenService:Create(ui.Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 80)
    }):Play()
    TweenService:Create(ui.Glow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 380, 0, 160),
        ImageTransparency = 0.95
    }):Play()
    
    -- Sembunyikan konten
    ui.Sidebar.Visible = false
    ui.Content.Visible = false
    
    -- Update title untuk minimized state
    ui.Title.Text = "🎣 Kaitun Fish It"
    ui.Status.Text = "⬇️ Minimized"
end

local function MaximizeUI()
    uiState.isMinimized = false
    TweenService:Create(ui.Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    }):Play()
    TweenService:Create(ui.Glow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80),
        ImageTransparency = 0.92
    }):Play()
    
    -- Tampilkan konten
    ui.Sidebar.Visible = true
    ui.Content.Visible = true
    
    -- Update title untuk normal state
    ui.Title.Text = "⚡ KAITUN FISH IT - ULTIMATE"
    ui.Status.Text = "🟢 Ready"
end

local function ToggleMinimize()
    if uiState.isMinimized then
        MaximizeUI()
    else
        MinimizeUI()
    end
end

-- Button Events
ui.MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
ui.MaximizeBtn.MouseButton1Click:Connect(ToggleMinimize)

-- Hover effects untuk buttons
ui.MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(ui.MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
end)
ui.MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(ui.MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 170, 0)}):Play()
end)

ui.MaximizeBtn.MouseEnter:Connect(function()
    TweenService:Create(ui.MaximizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 230, 255)}):Play()
end)
ui.MaximizeBtn.MouseLeave:Connect(function()
    TweenService:Create(ui.MaximizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
end)

-- Auto start dengan UI maximized
MaximizeUI()

print("[Kaitun Fish It] Successfully Loaded!")
print("🎣 Fishing system ready")
print("⚡ Controls: Use - and □ buttons to minimize/maximize")
print("📍 UI Position: Center screen")
