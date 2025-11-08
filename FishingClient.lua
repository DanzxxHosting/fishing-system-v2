-- UI-Only: Neon Panel dengan Tray Icon + Enhanced Instant Fishing + FISHING V2 IMPROVED
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
    rareFishPriority = false, -- Disabled untuk Fish It
    multiSpotFishing = false,
    fishingSpotRadius = 50,
    maxFishingSpots = 3,
    sellDelay = 5,
    avoidPlayers = false, -- Disabled untuk Fish It
    radarEnabled = false,
    instantReel = true, -- Auto reel ketika ada notif
    castDelay = 2, -- Increased untuk Fish It
    reelDelay = 0.5, -- Increased untuk Fish It
    useProximityOnly = true -- FIX: Hanya gunakan proximity prompt untuk Fish It
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
-- ENHANCED INSTANT FISHING FUNCTIONS (V1)
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
        
        -- Cari RemoteEvent fishing
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
        -- Mouse Click
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        -- E key
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        
        -- F key
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
    
    return true
end

-- INSTANT FISHING - Method 6: Auto Reel
local function AutoReelFish()
    local success = pcall(function()
        local char = SafeGetCharacter()
        if not char then return false end
        
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Cari UI fishing
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
    
    -- Pastikan rod equipped
    if not EquipRod() then
        return
    end
    
    local success = false
    
    -- Try all methods simultaneously for maximum speed
    if fishingConfig.instantFishing or fishingConfig.blantantMode then
        -- Method 1: ProximityPrompt (paling umum)
        if InstantFishProximity() then
            success = true
        end
        
        -- Method 2: ClickDetector
        if InstantFishClickDetector() then
            success = true
        end
        
        -- Method 3: RemoteEvent
        if InstantFishRemote() then
            success = true
        end
        
        -- Method 4: BindableEvent
        if InstantFishBindable() then
            success = true
        end
        
        -- Method 5: Virtual Input
        if InstantFishVirtualInput() then
            success = true
        end
        
        -- Method 6: Auto Reel (jika ada minigame)
        if fishingConfig.autoReel then
            AutoReelFish()
        end
    end
    
    if success then
        fishingStats.fishCaught = fishingStats.fishCaught + 1
    end
end

-- Start Fishing dengan connection yang proper
local function StartFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    
    print("[Fishing] Starting instant fishing...")
    print("[Fishing] Delay:", fishingConfig.fishingDelay)
    
    -- Main fishing loop
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        pcall(InstantFish)
        
        -- Delay based on mode
        if fishingConfig.blantantMode then
            task.wait(0.001) -- Ultra fast
        elseif fishingConfig.instantFishing then
            task.wait(0.01) -- Fast
        else
            task.wait(fishingConfig.fishingDelay)
        end
    end)
    
    -- Auto reel connection (terpisah untuk minigame)
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
-- FISHING V2 - ADVANCED FEATURES IMPROVED
-- ═══════════════════════════════════════════════════════════

local radarParts = {}
local radarBeams = {}

-- FIXED RADAR SYSTEM untuk Fish It
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
        
        -- Cari fishing spots terdekat
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Deteksi fishing spots dalam radius
        local nearbySpots = {}
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") then
                local distance = (rootPart.Position - part.Position).Magnitude
                if distance <= fishingV2Config.fishingSpotRadius then
                    local name = part.Name:lower()
                    if name:find("water") or name:find("pond") or name:find("lake") or name:find("river") or name:find("ocean") then
                        table.insert(nearbySpots, part)
                    end
                end
            end
        end
        
        -- Buat radar indicator untuk setiap spot
        for _, spot in pairs(nearbySpots) do
            local radarPart = Instance.new("Part")
            radarPart.Name = "FishingRadarIndicator"
            radarPart.Size = Vector3.new(3, 3, 3)
            radarPart.Position = spot.Position + Vector3.new(0, 8, 0)
            radarPart.Anchored = true
            radarPart.CanCollide = false
            radarPart.Material = Enum.Material.Neon
            radarPart.BrickColor = BrickColor.new("Bright green")
            radarPart.Transparency = 0.3
            
            -- Glow effect
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 2
            pointLight.Range = 10
            pointLight.Color = Color3.new(0, 1, 0)
            pointLight.Parent = radarPart
            
            radarPart.Parent = Workspace
            table.insert(radarParts, radarPart)
            
            -- Beam ke spot
            local beam = Instance.new("Beam")
            local attachment0 = Instance.new("Attachment")
            local attachment1 = Instance.new("Attachment")
            
            attachment0.Parent = radarPart
            attachment1.Parent = spot
            
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Color = ColorSequence.new(Color3.new(0, 1, 0))
            beam.Width0 = 0.3
            beam.Width1 = 0.1
            beam.Brightness = 1
            beam.Parent = radarPart
            
            table.insert(radarBeams, beam)
        end
        
        fishingStats.spotsFound = #nearbySpots
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

-- Improved Fishing Spot Detection
local function FindFishingSpots()
    local spots = {}
    
    -- Method 1: Cari part dengan nama fishing-related
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("MeshPart") then
            local name = part.Name:lower()
            if name:find("fish") or name:find("water") or name:find("pond") or name:find("lake") or name:find("river") or name:find("ocean") then
                table.insert(spots, part)
            end
        end
    end
    
    -- Method 2: Cari ProximityPrompt di workspace
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local text = (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
            if text:find("fish") or text:find("cast") or text:find("catch") or text:find("reel") then
                table.insert(spots, prompt.Parent)
            end
        end
    end
    
    -- Method 3: Cari part dengan material water
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("Part") and part.Material == Enum.Material.Water then
            table.insert(spots, part)
        end
    end
    
    fishingStats.spotsFound = #spots
    return spots
end

-- Smart Pathfinding ke Fishing Spot
local function MoveToFishingSpot(spot)
    if not spot or not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    -- Hitung posisi terdekat ke fishing spot
    local targetPosition = spot.Position
    if spot:IsA("Part") then
        targetPosition = spot.Position + Vector3.new(0, 3, 0) -- Berdiri di atas spot
    end
    
    -- Gerakkan karakter ke spot
    humanoid:MoveTo(targetPosition)
    
    -- Tunggu sampai sampai
    local waitTime = 0
    while (rootPart.Position - targetPosition).Magnitude > 5 and waitTime < 5 do
        wait(0.1)
        waitTime = waitTime + 0.1
    end
    
    return (rootPart.Position - targetPosition).Magnitude <= 5
end

-- Anti-AFK System
local function AntiAFK()
    if not fishingV2Config.antiAfk then return end
    
    antiAfkTime = antiAfkTime + 1
    if antiAfkTime >= 30 then -- Reset setiap 30 detik
        antiAfkTime = 0
        
        -- Gerakkan karakter sedikit
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            humanoid:MoveTo(char.HumanoidRootPart.Position + Vector3.new(1, 0, 1))
            wait(0.2)
            humanoid:MoveTo(char.HumanoidRootPart.Position + Vector3.new(-1, 0, -1))
        end
        
        -- Rotasi kamera
        local cam = Workspace.CurrentCamera
        if cam then
            local original = cam.CFrame
            cam.CFrame = original * CFrame.Angles(0, math.rad(5), 0)
            wait(0.1)
            cam.CFrame = original
        end
    end
end

-- Auto Sell System
local function AutoSellFish()
    if not fishingV2Config.autoSell then return end
    
    -- Cari NPC seller
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and (npc.Name:lower():find("npc") or npc.Name:lower():find("seller") or npc.Name:lower():find("merchant")) then
            local humanoid = npc:FindFirstChild("Humanoid")
            if humanoid then
                -- Teleport ke NPC
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = npc:GetPivot() + Vector3.new(0, 0, -5)
                    wait(1)
                    
                    -- Cari ProximityPrompt untuk jual
                    for _, prompt in pairs(npc:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local text = (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                            if text:find("sell") or text:find("trade") or text:find("vendor") then
                                for i = 1, 10 do
                                    fireproximityprompt(prompt)
                                    wait(0.1)
                                end
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Player Avoidance System
local function ShouldAvoidSpot(spot)
    if not fishingV2Config.avoidPlayers then return false end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - spot.Position).Magnitude < 10 then
                return true -- Ada player lain terlalu dekat
            end
        end
    end
    return false
end

-- INSTANT REEL DETECTION SYSTEM
local function DetectFishingUI()
    if not fishingV2Config.instantReel then return false end
    
    local success = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Cari tanda seru (!) atau indikator bite di UI
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("ImageLabel") then
                local text = gui.Text and gui.Text:lower() or ""
                local name = gui.Name:lower()
                
                -- Deteksi tanda seru atau indikator bite
                if text:find("!") or text:find("bite") or text:find("pull") or 
                   name:find("bite") or name:find("pull") or name:find("catch") then
                    if gui.Visible then
                        print("[Fishing V2] Detected bite indicator!")
                        return true
                    end
                end
            end
        end
        
        -- Cari partikel atau efek visual fishing
        for _, effect in pairs(Workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
                local name = effect.Name:lower()
                if name:find("fish") or name:find("bite") or name:find("splash") then
                    return true
                end
            end
        end
        
        return false
    end)
    
    return success
end

-- Enhanced Fishing Action with Instant Reel
local function PerformFishingAction()
    local caughtFish = false
    
    -- Method 1: ProximityPrompt
    if InstantFishProximity() then
        caughtFish = true
    end
    
    -- Method 2: Remote Events
    if InstantFishRemote() then
        caughtFish = true
    end
    
    -- Method 3: Virtual Input (fallback)
    if not caughtFish then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
    
    return caughtFish
end

-- INSTANT REEL SYSTEM - Auto reel when ! appears
local function InstantReelSystem()
    if not fishingV2Config.instantReel then return false end
    
    if DetectFishingUI() then
        print("[Fishing V2] Instant reel activated!")
        
        -- Lakukan reel action berulang kali untuk memastikan
        for i = 1, 10 do
            PerformFishingAction()
            task.wait(0.01)
        end
        
        fishingStats.instantCatches = fishingStats.instantCatches + 1
        fishingStats.fishCaught = fishingStats.fishCaught + 1
        return true
    end
    
    return false
end

-- Improved Main Fishing V2 Loop
local function StartFishingV2()
    if fishingV2Active then 
        print("[Fishing V2] Already fishing!")
        return 
    end
    
    fishingV2Active = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting"
    
    print("[Fishing V2] Starting AI Fishing for Fish It...")
    print("[Fishing V2] Instant Reel:", fishingV2Config.instantReel and "ENABLED" or "DISABLED")
    print("[Fishing V2] Radar:", fishingV2Config.radarEnabled and "ENABLED" : "DISABLED")
    
    -- Start radar jika dienable
    if fishingV2Config.radarEnabled then
        StartRadar()
    end
    
    v2Connection = RunService.Heartbeat:Connect(function()
        if not fishingV2Active then return end
        
        -- Cek jika karakter ada
        local character = player.Character
        if not character then 
            fishingStats.lastAction = "No Character"
            return 
        end
        
        -- FIXED: Cek instant reel terlebih dahulu
        if fishingV2Config.instantReel then
            if DetectFishBite() then
                fishingStats.lastAction = "Instant Reel Detected"
                print("[Fishing V2] Instant reel triggered!")
                
                -- Lakukan reel berulang untuk memastikan
                for i = 1, 5 do
                    if PerformFishingReel() then
                        fishingStats.instantCatches = fishingStats.instantCatches + 1
                        fishingStats.fishCaught = fishingStats.fishCaught + 1
                        fishingStats.lastAction = "Fish Caught (Instant)"
                        print("[Fishing V2] Fish caught with instant reel!")
                    end
                    task.wait(0.1)
                end
                
                -- Tunggu sebelum cast lagi
                task.wait(fishingV2Config.castDelay)
                return
            end
        end
        
        -- FIXED: Fishing cycle normal
        local currentTime = tick()
        
        -- CASTING PHASE
        if not isCasting and (currentTime - lastCastTime > fishingV2Config.castDelay) then
            fishingStats.lastAction = "Attempting Cast"
            if PerformFishingCast() then
                isCasting = true
                lastCastTime = currentTime
                fishingStats.attempts = fishingStats.attempts + 1
                fishingStats.lastAction = "Casting Success"
                print("[Fishing V2] Cast successful, waiting for fish...")
            else
                fishingStats.lastAction = "Cast Failed - No Prompt"
            end
        end
        
        -- REELING PHASE (setelah delay tertentu)
        if isCasting and (currentTime - lastCastTime > fishingV2Config.reelDelay) and not isReeling then
            fishingStats.lastAction = "Attempting Reel"
            if PerformFishingReel() then
                isReeling = true
                lastReelTime = currentTime
                fishingStats.lastAction = "Reeling Success"
                
                -- Reset fishing cycle
                spawn(function()
                    task.wait(1) -- Tunggu hasil reel
                    isCasting = false
                    isReeling = false
                    fishingStats.lastAction = "Cycle Complete"
                end)
            else
                fishingStats.lastAction = "Reel Failed"
                -- Reset jika reel gagal
                isCasting = false
                isReeling = false
            end
        end
        
        -- Update status
        if isCasting and not isReeling then
            fishingStats.lastAction = "Waiting for Bite"
        elseif isCasting and isReeling then
            fishingStats.lastAction = "Reeling in Progress"
        end
        
    end)
    
    print("[Fishing V2] AI Fishing started successfully!")
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

-- Create Toggles
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

-- Fishing Button Handler
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

-- ═══════════════════════════════════════════════════════════
-- FISHING V2 UI CONTENT - IMPROVED WITH SCROLL
-- ═══════════════════════════════════════════════════════════

local fishingV2Content = Instance.new("ScrollingFrame") -- CHANGED TO SCROLLING FRAME
fishingV2Content.Name = "FishingV2Content"
fishingV2Content.Size = UDim2.new(1, -24, 1, -24)
fishingV2Content.Position = UDim2.new(0, 12, 0, 12)
fishingV2Content.BackgroundTransparency = 1
fishingV2Content.Visible = false
fishingV2Content.ScrollBarThickness = 6
fishingV2Content.ScrollBarImageColor3 = ACCENT
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 600) -- Adjust based on content
fishingV2Content.Parent = content

-- Container for V2 content
local v2ContentContainer = Instance.new("Frame")
v2ContentContainer.Name = "V2ContentContainer"
v2ContentContainer.Size = UDim2.new(1, 0, 0, 600) -- Height will adjust
v2ContentContainer.BackgroundTransparency = 1
v2ContentContainer.Parent = fishingV2Content

-- V2 Stats Panel
local v2StatsPanel = Instance.new("Frame")
v2StatsPanel.Size = UDim2.new(1, 0, 0, 120)
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
v2StatsTitle.Text = "🚀 ADVANCED FISHING STATS"
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

local v2RareLabel = Instance.new("TextLabel")
v2RareLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2RareLabel.Position = UDim2.new(0.5,4,0,40)
v2RareLabel.BackgroundTransparency = 1
v2RareLabel.Font = Enum.Font.Gotham
v2RareLabel.TextSize = 13
v2RareLabel.Text = "Rare Fish: 0"
v2RareLabel.TextColor3 = Color3.fromRGB(255,215,0)
v2RareLabel.TextXAlignment = Enum.TextXAlignment.Left
v2RareLabel.Parent = v2StatsPanel

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

local v2ValueLabel = Instance.new("TextLabel")
v2ValueLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2ValueLabel.Position = UDim2.new(0.5,4,0,68)
v2ValueLabel.BackgroundTransparency = 1
v2ValueLabel.Font = Enum.Font.Gotham
v2ValueLabel.TextSize = 13
v2ValueLabel.Text = "Total Value: $0"
v2ValueLabel.TextColor3 = Color3.fromRGB(100,255,100)
v2ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
v2ValueLabel.Parent = v2StatsPanel

local v2EfficiencyLabel = Instance.new("TextLabel")
v2EfficiencyLabel.Size = UDim2.new(1, -24, 0, 24)
v2EfficiencyLabel.Position = UDim2.new(0,12,0,96)
v2EfficiencyLabel.BackgroundTransparency = 1
v2EfficiencyLabel.Font = Enum.Font.Gotham
v2EfficiencyLabel.TextSize = 13
v2EfficiencyLabel.Text = "Efficiency: 0% | Instant: 0"
v2EfficiencyLabel.TextColor3 = Color3.fromRGB(255,200,255)
v2EfficiencyLabel.TextXAlignment = Enum.TextXAlignment.Left
v2EfficiencyLabel.Parent = v2StatsPanel

-- V2 Controls Panel
local v2ControlsPanel = Instance.new("Frame")
v2ControlsPanel.Size = UDim2.new(1, 0, 0, 100)
v2ControlsPanel.Position = UDim2.new(0, 0, 0, 132)
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
v2ControlsTitle.Text = "🤖 AI Fishing Controls"
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
local v2StatusLabel = Instance.new("TextLabel")
v2StatusLabel.Size = UDim2.new(0.5, -16, 0, 50)
v2StatusLabel.Position = UDim2.new(0, 224, 0, 40)
v2StatusLabel.BackgroundTransparency = 1
v2StatusLabel.Font = Enum.Font.GothamBold
v2StatusLabel.TextSize = 12
v2StatusLabel.Text = "⭕ AI OFFLINE"
v2StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
v2StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2StatusLabel.Parent = v2ControlsPanel

-- V2 Features Panel - EXTENDED
local v2FeaturesPanel = Instance.new("Frame")
v2FeaturesPanel.Size = UDim2.new(1, 0, 0, 320) -- Increased height
v2FeaturesPanel.Position = UDim2.new(0, 0, 0, 244)
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
v2FeaturesTitle.Text = "🔧 AI Fishing Features"
v2FeaturesTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2FeaturesTitle.TextXAlignment = Enum.TextXAlignment.Left
v2FeaturesTitle.Parent = v2FeaturesPanel

-- Update canvas size based on content
v2ContentContainer.Size = UDim2.new(1, 0, 0, 244 + 320 + 20) -- controls + features + margin
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 244 + 320 + 20)

-- Create V2 Toggles with new features
CreateToggle("🤖 AI Fishing System", "Enable advanced AI fishing", fishingV2Config.enabled, function(v)
    fishingV2Config.enabled = v
    print("[Fishing V2] AI System:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 36)

CreateToggle("🎯 Smart Detection", "Auto-detect fishing spots", fishingV2Config.smartDetection, function(v)
    fishingV2Config.smartDetection = v
    print("[Fishing V2] Smart Detection:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 76)

CreateToggle("🛡️ Anti-AFK", "Prevent AFK detection", fishingV2Config.antiAfk, function(v)
    fishingV2Config.antiAfk = v
    print("[Fishing V2] Anti-AFK:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 116)

CreateToggle("💰 Auto Sell", "Automatically sell fish", fishingV2Config.autoSell, function(v)
    fishingV2Config.autoSell = v
    print("[Fishing V2] Auto Sell:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 156)

CreateToggle("🎣 Rare Priority", "Focus on rare fish spots", fishingV2Config.rareFishPriority, function(v)
    fishingV2Config.rareFishPriority = v
    print("[Fishing V2] Rare Priority:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 196)

-- NEW: Radar Fishing Toggle
CreateToggle("📡 Radar Fishing", "Show fishing spot radar", fishingV2Config.radarEnabled, function(v)
    fishingV2Config.radarEnabled = v
    if v then
        StartRadar()
    else
        StopRadar()
    end
    print("[Fishing V2] Radar:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 236)

-- NEW: Instant Reel Toggle
CreateToggle("⚡ Instant Reel", "Auto reel when ! appears", fishingV2Config.instantReel, function(v)
    fishingV2Config.instantReel = v
    print("[Fishing V2] Instant Reel:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 276)

-- V2 Fishing Button Handler
v2FishingButton.MouseButton1Click:Connect(function()
    if fishingV2Active then
        StopFishingV2()
        v2FishingButton.Text = "🤖 START AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        v2StatusLabel.Text = "⭕ AI OFFLINE"
        v2StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishingV2()
        v2FishingButton.Text = "⏹️ STOP AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        v2StatusLabel.Text = "✅ AI FISHING ACTIVE"
        v2StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

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

-- menu navigation
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
        
        -- Update V1 Stats
        fishCountLabel.Text = string.format("Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("Rate: %.2f/s", rate)
        memLabel.Text = string.format("Memory: %d KB | Fish: %d", math.floor(collectgarbage("count")), fishingStats.fishCaught)
        
        -- Update V2 Stats
        v2FishCountLabel.Text = string.format("Total Fish: %d", fishingStats.fishCaught)
        v2RareLabel.Text = string.format("Rare Fish: %d", fishingStats.rareFish)
        v2SpotsLabel.Text = string.format("Spots Found: %d", fishingStats.spotsFound)
        v2ValueLabel.Text = string.format("Total Value: $%d", fishingStats.totalValue)
        v2EfficiencyLabel.Text = string.format("Efficiency: %.1f%% | Instant: %d", 
            (fishingStats.fishCaught / math.max(1, fishingStats.attempts)) * 100, 
            fishingStats.instantCatches)
        
        wait(0.5)
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
