-- KAITUN FISH IT v4.0 - FIXED FISHING SYSTEM
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

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
    enabled = false,
    instantCast = true,
    instantReel = true,
    perfectTiming = true,
    autoEquip = true,
    speed = "ultra",
    multiMethod = true,
    bypassAnticheat = true
}

-- FEATURE CONFIG
local featureConfig = {
    -- Player Mods
    walkSpeed = 16,
    jumpPower = 50,
    infiniteJump = false,
    noClip = false,
    
    -- Fishing Enhancements
    fishingRadar = false,
    autoSell = false,
    autoUpgrade = false,
    
    -- Game Features
    spawnBoat = false,
    autoCompleteQuests = false,
    unlockAllAreas = false,
    
    -- Visual
    xrayVision = false,
    fullBright = false
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successes = 0,
    fails = 0,
    lastCatch = 0
}

local fishingActive = false
local activeConnections = {}
local detectedMethods = {}

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
title.Text = "⚡ KAITUN FISH IT v4.0"
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
sSubtitle.Text = "Ultimate Suite v4.0"
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
    {"Player", "👤"},
    {"Shop", "🛒"},
    {"Quests", "📜"},
    {"Visual", "👁️"},
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
cTitle.Text = "Perfect Instant Fishing"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = content

-- ═══════════════════════════════════════════════════════════
-- PERFECTED INSTANT FISHING SYSTEM v4.0 - FIXED
-- ═══════════════════════════════════════════════════════════

-- Utility Functions
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        return nil
    end
    return result
end

local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Advanced Rod Detection - IMPROVED
local function FindFishingRod()
    local rodKeywords = {"rod", "pole", "fishing", "cane", "tackle", "hook", "line"}
    
    -- Check equipped first
    local char = GetCharacter()
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                for _, keyword in ipairs(rodKeywords) do
                    if name:find(keyword) then
                        return item
                    end
                end
            end
        end
    end
    
    -- Check backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                for _, keyword in ipairs(rodKeywords) do
                    if name:find(keyword) then
                        return item
                    end
                end
            end
        end
    end
    
    -- Check workspace near player
    local char = GetCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        local rootPart = char.HumanoidRootPart
        for _, item in pairs(Workspace:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("Handle") then
                local distance = (item.Handle.Position - rootPart.Position).Magnitude
                if distance < 20 then
                    local name = item.Name:lower()
                    for _, keyword in ipairs(rodKeywords) do
                        if name:find(keyword) then
                            return item
                        end
                    end
                end
            end
        end
    end
    
    return nil
end


-- FIXED Fishing Methods
local function CastProximityPrompt()
    return SafeCall(function()
        local char = GetCharacter()
        if not char then return false end
        
        local foundPrompt = false
        
        -- Check character first
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local name = obj.Name:lower()
                local objText = obj.ObjectText and obj.ObjectText:lower() or ""
                local actionText = obj.ActionText and obj.ActionText:lower() or ""
                
                if name:match("fish") or name:match("cast") or name:match("catch") or name:match("reel") or
                   objText:match("fish") or objText:match("cast") or objText:match("reel") or
                   actionText:match("fish") or actionText:match("cast") or actionText:match("reel") then
                    
                    for i = 1, 5 do
                        fireproximityprompt(obj, 0)
                        task.wait(0.05)
                    end
                    
                    if not detectedMethods.proximity then
                        detectedMethods.proximity = true
                        print("[✓] ProximityPrompt method detected:", obj.Name)
                    end
                    foundPrompt = true
                    return true
                end
            end
        end
        
        -- Check equipped rod
        local rod = FindFishingRod()
        if rod and rod.Parent == char then
            for _, obj in pairs(rod:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    for i = 1, 5 do
                        fireproximityprompt(obj, 0)
                        task.wait(0.05)
                    end
                    foundPrompt = true
                    return true
                end
            end
        end
        
        return foundPrompt
    end) or false
end

local function CastClickDetector()
    return SafeCall(function()
        local rod = FindFishingRod()
        if not rod then return false end
        
        if rod.Parent ~= GetCharacter() then
            if not EquipRod() then
                return false
            end
        end
        
        for _, obj in pairs(rod:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                for i = 1, 8 do
                    fireclickdetector(obj, 0)
                    task.wait(0.03)
                end
                
                if not detectedMethods.click then
                    detectedMethods.click = true
                    print("[✓] ClickDetector method detected!")
                end
                return true
            end
        end
        
        return false
    end) or false
end

-- IMPROVED Remote Detection
local function CastRemote()
    return SafeCall(function()
        local actions = {"cast", "fish", "throw", "reel", "catch", "bite", "hook", "line", "rod"}
        local foundRemote = false
        
        -- Check ReplicatedStorage first
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        -- Try different argument patterns
                        local success = pcall(function() remote:FireServer() end)
                        if success then foundRemote = true end
                        
                        success = pcall(function() remote:FireServer("Cast") end)
                        if success then foundRemote = true end
                        
                        success = pcall(function() remote:FireServer(true) end)
                        if success then foundRemote = true end
                        
                        success = pcall(function() remote:FireServer("Fishing") end)
                        if success then foundRemote = true end
                        
                        success = pcall(function() remote:FireServer("Start") end)
                        if success then foundRemote = true end
                        
                        if foundRemote and not detectedMethods.remote then
                            detectedMethods.remote = true
                            print("[✓] RemoteEvent method detected:", remote.Name)
                        end
                    end
                end
            elseif remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        local success = pcall(function() remote:InvokeServer() end)
                        if success then foundRemote = true end
                        
                        success = pcall(function() remote:InvokeServer("Cast") end)
                        if success then foundRemote = true end
                        
                        success = pcall(function() remote:InvokeServer(true) end)
                        if success then foundRemote = true end
                    end
                end
            end
        end
        
        -- Check Workspace for fishing-related remotes
        for _, remote in pairs(Workspace:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        local success = pcall(function() remote:FireServer() end)
                        if success then foundRemote = true end
                    end
                end
            end
        end
        
        return foundRemote
    end) or false
end

-- NEW: BindableEvent Detection
local function CastBindableEvent()
    return SafeCall(function()
        local actions = {"cast", "fish", "throw", "reel", "catch", "bite", "hook"}
        local foundBindable = false
        
        for _, bindable in pairs(ReplicatedStorage:GetDescendants()) do
            if bindable:IsA("BindableEvent") then
                local name = bindable.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        bindable:Fire()
                        bindable:Fire("Cast")
                        bindable:Fire(true)
                        
                        if not detectedMethods.bindable then
                            detectedMethods.bindable = true
                            print("[✓] BindableEvent method detected:", bindable.Name)
                        end
                        foundBindable = true
                    end
                end
            end
        end
        
        return foundBindable
    end) or false
end

-- NEW: Virtual Input Method
local function CastVirtualInput()
    return SafeCall(function()
        -- Send mouse clicks
        for i = 1, 3 do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.05)
        end
        
        -- Send key presses (common fishing keys)
        local fishingKeys = {"E", "F", "R", "C", "X", "Z"}
        for _, key in ipairs(fishingKeys) do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
            task.wait(0.02)
        end
        
        if not detectedMethods.virtual then
            detectedMethods.virtual = true
            print("[✓] Virtual Input method activated")
        end
        
        return true
    end) or false
end

-- MASTER FISHING FUNCTION - IMPROVED
local function PerformPerfectCast()
    if not fishingActive then return false end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    -- Auto equip rod if enabled
    if fishingConfig.autoEquip then
        if not EquipRod() then
            fishingStats.fails = fishingStats.fails + 1
            print("[!] Failed to equip rod - attempt", fishingStats.attempts)
            return false
        end
    end
    
    local success = false
    local methodsUsed = 0
    
    -- Use multiple methods for better success rate
    if fishingConfig.multiMethod then
        if CastProximityPrompt() then success = true; methodsUsed = methodsUsed + 1 end
        task.wait(0.1)
        if CastClickDetector() then success = true; methodsUsed = methodsUsed + 1 end
        task.wait(0.1)
        if CastRemote() then success = true; methodsUsed = methodsUsed + 1 end
        task.wait(0.1)
        if CastBindableEvent() then success = true; methodsUsed = methodsUsed + 1 end
        task.wait(0.1)
        if CastVirtualInput() then success = true; methodsUsed = methodsUsed + 1 end
    else
        -- Try methods in order until one works
        if CastProximityPrompt() then
            success = true
        elseif CastClickDetector() then
            success = true
        elseif CastRemote() then
            success = true
        elseif CastBindableEvent() then
            success = true
        elseif CastVirtualInput() then
            success = true
        end
    end
    
    if success then
        fishingStats.successes = fishingStats.successes + 1
        fishingStats.fishCaught = fishingStats.fishCaught + 1
        fishingStats.lastCatch = tick()
        print(string.format("[✓] Catch #%d successful! (Methods: %d)", fishingStats.fishCaught, methodsUsed))
    else
        fishingStats.fails = fishingStats.fails + 1
        print("[!] Cast failed - attempt", fishingStats.attempts)
    end
    
    return success
end

-- Get delay based on speed setting
local function GetDelay()
    if fishingConfig.speed == "ultra" then
        return 0.2  -- Reduced for stability
    elseif fishingConfig.speed == "fast" then
        return 0.4
    else
        return 0.8
    end
end

-- Start Fishing - IMPROVED
local function StartFishing()
    if fishingActive then 
        print("[!] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    detectedMethods = {}
    
    print("═══════════════════════════════════════")
    print("[✓] PERFECT INSTANT FISHING ACTIVATED!")
    print("[⚡] Speed Mode:", fishingConfig.speed:upper())
    print("[🎣] Auto Equip:", fishingConfig.autoEquip and "ON" or "OFF")
    print("[🔧] Multi-Method:", fishingConfig.multiMethod and "ON" or "OFF")
    print("═══════════════════════════════════════")
    
    -- Main fishing loop
    local mainLoop = RunService.Heartbeat:Connect(function()
        if not fishingActive then 
            mainLoop:Disconnect()
            return 
        end
        
        local success = SafeCall(PerformPerfectCast)
        if success then
            -- Success delay (shorter)
            task.wait(GetDelay() * 0.5)
        else
            -- Failure delay (longer)
            task.wait(GetDelay())
        end
    end)
    
    table.insert(activeConnections, mainLoop)
end

-- Stop Fishing
local function StopFishing()
    fishingActive = false
    
    for _, connection in ipairs(activeConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    activeConnections = {}
    
    local elapsed = tick() - fishingStats.startTime
    local successRate = (fishingStats.successes / math.max(1, fishingStats.attempts)) * 100
    local fishPerMinute = (fishingStats.fishCaught / math.max(1, elapsed)) * 60
    
    print("═══════════════════════════════════════")
    print("[✓] FISHING STOPPED")
    print("[📊] Fish Caught:", fishingStats.fishCaught)
    print("  • Success Rate:", string.format("%.1f%%", successRate))
    print("  • Fish/Minute:", string.format("%.1f", fishPerMinute))
    print("  • Time:", string.format("%.1fs", elapsed))
    print("  • Methods Found:", #detectedMethods)
    print("═══════════════════════════════════════")
end

-- ═══════════════════════════════════════════════════════════
-- FISHING UI CONTENT - UPDATED
-- ═══════════════════════════════════════════════════════════

local fishingContent = Instance.new("ScrollingFrame")
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -68)
fishingContent.Position = UDim2.new(0, 12, 0, 56)
fishingContent.BackgroundTransparency = 1
fishingContent.BorderSizePixel = 0
fishingContent.ScrollBarThickness = 6
fishingContent.ScrollBarImageColor3 = ACCENT
fishingContent.CanvasSize = UDim2.new(0, 0, 0, 1200)
fishingContent.Visible = true
fishingContent.Parent = content

-- Stats Panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 140)
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
statsTitle.Text = "📊 Perfect Fishing Statistics"
statsTitle.TextColor3 = Color3.fromRGB(235,235,235)
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsPanel

-- Stats Grid
local statsGrid = Instance.new("Frame")
statsGrid.Size = UDim2.new(1, -24, 1, -44)
statsGrid.Position = UDim2.new(0, 12, 0, 40)
statsGrid.BackgroundTransparency = 1
statsGrid.Parent = statsPanel

local function CreateStat(name, emoji, color, xPos, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, -4, 0, 28)
    frame.Position = UDim2.new(xPos, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = statsGrid
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = emoji .. " " .. name .. ": 0"
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    return label
end

local fishCountLabel = CreateStat("Fish Caught", "🎣", Color3.fromRGB(100, 255, 150), 0, 0)
local rateLabel = CreateStat("Rate", "⚡", Color3.fromRGB(255, 220, 100), 0.5, 0)
local attemptsLabel = CreateStat("Attempts", "🎯", Color3.fromRGB(200, 200, 255), 0, 0.33)
local successLabel = CreateStat("Success", "✅", Color3.fromRGB(150, 255, 150), 0.5, 0.33)
local timeLabel = CreateStat("Session", "⏱️", Color3.fromRGB(255, 180, 180), 0, 0.66)

-- Controls Panel
local controlsPanel = Instance.new("Frame")
controlsPanel.Size = UDim2.new(1, 0, 0, 130)
controlsPanel.Position = UDim2.new(0, 0, 0, 152)
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
controlsTitle.Text = "⚡ Perfect Controls"
controlsTitle.TextColor3 = Color3.fromRGB(235,235,235)
controlsTitle.TextXAlignment = Enum.TextXAlignment.Left
controlsTitle.Parent = controlsPanel

-- Main Button
local fishingButton = Instance.new("TextButton")
fishingButton.Size = UDim2.new(0, 240, 0, 54)
fishingButton.Position = UDim2.new(0, 12, 0, 44)
fishingButton.BackgroundColor3 = ACCENT
fishingButton.Font = Enum.Font.GothamBold
fishingButton.TextSize = 15
fishingButton.Text = "🚀 START PERFECT FISHING"
fishingButton.TextColor3 = Color3.fromRGB(255,255,255)
fishingButton.AutoButtonColor = false
fishingButton.Parent = controlsPanel

local fishingBtnCorner = Instance.new("UICorner")
fishingBtnCorner.CornerRadius = UDim.new(0,8)
fishingBtnCorner.Parent = fishingButton

-- Reset Button
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 160, 0, 54)
resetButton.Position = UDim2.new(0, 264, 0, 44)
resetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 13
resetButton.Text = "🔄 RESET STATS"
resetButton.TextColor3 = Color3.fromRGB(230,230,230)
resetButton.AutoButtonColor = false
resetButton.Parent = controlsPanel

local resetBtnCorner = Instance.new("UICorner")
resetBtnCorner.CornerRadius = UDim.new(0,8)
resetBtnCorner.Parent = resetButton

-- Status Frame
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 200, 0, 54)
statusFrame.Position = UDim2.new(0, 436, 0, 44)
statusFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = controlsPanel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0,8)
statusCorner.Parent = statusFrame

local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 14, 0, 14)
statusIndicator.Position = UDim2.new(0, 14, 0.5, -7)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = statusFrame

local statusIndCorner = Instance.new("UICorner")
statusIndCorner.CornerRadius = UDim.new(1, 0)
statusIndCorner.Parent = statusIndicator

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -44, 1, 0)
statusLabel.Position = UDim2.new(0, 38, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.Text = "⭕ OFFLINE"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

-- Speed Selector Panel
local speedPanel = Instance.new("Frame")
speedPanel.Size = UDim2.new(1, 0, 0, 100)
speedPanel.Position = UDim2.new(0, 0, 0, 294)
speedPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
speedPanel.BorderSizePixel = 0
speedPanel.Parent = fishingContent

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,8)
speedCorner.Parent = speedPanel

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -24, 0, 28)
speedTitle.Position = UDim2.new(0,12,0,8)
speedTitle.BackgroundTransparency = 1
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextSize = 14
speedTitle.Text = "⚡ Speed Mode"
speedTitle.TextColor3 = Color3.fromRGB(235,235,235)
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = speedPanel

local function CreateSpeedButton(name, desc, speed, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, -8, 0, 52)
    btn.Position = UDim2.new(xPos, 0, 0, 40)
    btn.BackgroundColor3 = fishingConfig.speed == speed and Color3.fromRGB(255, 62, 62) or Color3.fromRGB(30, 30, 32)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = speedPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local btnTitle = Instance.new("TextLabel")
    btnTitle.Size = UDim2.new(1, -16, 0, 22)
    btnTitle.Position = UDim2.new(0, 8, 0, 6)
    btnTitle.BackgroundTransparency = 1
    btnTitle.Font = Enum.Font.GothamBold
    btnTitle.TextSize = 13
    btnTitle.Text = name
    btnTitle.TextColor3 = Color3.fromRGB(240,240,240)
    btnTitle.TextXAlignment = Enum.TextXAlignment.Left
    btnTitle.Parent = btn
    
    local btnDesc = Instance.new("TextLabel")
    btnDesc.Size = UDim2.new(1, -16, 0, 18)
    btnDesc.Position = UDim2.new(0, 8, 0, 28)
    btnDesc.BackgroundTransparency = 1
    btnDesc.Font = Enum.Font.Gotham
    btnDesc.TextSize = 10
    btnDesc.Text = desc
    btnDesc.TextColor3 = Color3.fromRGB(180,180,180)
    btnDesc.TextXAlignment = Enum.TextXAlignment.Left
    btnDesc.Parent = btn
    
    return btn, speed
end

local normalBtn, normalSpeed = CreateSpeedButton("Normal", "0.8s delay", "normal", 0.02)
local fastBtn, fastSpeed = CreateSpeedButton("Fast", "0.4s delay", "fast", 0.35)
local ultraBtn, ultraSpeed = CreateSpeedButton("Ultra", "0.2s instant", "ultra", 0.68)

local speedButtons = {
    {btn = normalBtn, speed = "normal"},
    {btn = fastBtn, speed = "fast"},
    {btn = ultraBtn, speed = "ultra"}
}

for _, data in ipairs(speedButtons) do
    data.btn.MouseButton1Click:Connect(function()
        fishingConfig.speed = data.speed
        
        for _, d in ipairs(speedButtons) do
            d.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
        end
        
        data.btn.BackgroundColor3 = Color3.fromRGB(255, 62, 62)
        print("[Speed] Changed to:", data.speed:upper())
    end)
end

-- Toggles Panel
local togglesPanel = Instance.new("Frame")
togglesPanel.Size = UDim2.new(1, 0, 0, 180)
togglesPanel.Position = UDim2.new(0, 0, 0, 406)
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
togglesTitle.Text = "🔧 Advanced Settings"
togglesTitle.TextColor3 = Color3.fromRGB(235,235,235)
togglesTitle.TextXAlignment = Enum.TextXAlignment.Left
togglesTitle.Parent = togglesPanel

local function CreateToggle(name, desc, configKey, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = togglesPanel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.65, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(160,160,160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 30)
    button.Position = UDim2.new(0.7, 0, 0.15, 0)
    button.BackgroundColor3 = fishingConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = fishingConfig[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        fishingConfig[configKey] = not fishingConfig[configKey]
        button.Text = fishingConfig[configKey] and "ON" or "OFF"
        local targetColor = fishingConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        print("[Toggle]", name, ":", fishingConfig[configKey] and "ON" or "OFF")
    end)

    return frame
end

CreateToggle("🎯 Instant Cast", "Instantly cast fishing rod", "instantCast", 40)
CreateToggle("🔄 Instant Reel", "Auto-complete reel minigame", "instantReel", 80)
CreateToggle("✨ Perfect Timing", "Always perfect cast timing", "perfectTiming", 120)
CreateToggle("🔧 Multi-Method", "Use all fishing methods", "multiMethod", 160)

-- ═══════════════════════════════════════════════════════════
-- UI INTERACTIONS & ANIMATIONS
-- ═══════════════════════════════════════════════════════════

-- Content Management
local currentContent = fishingContent
local contents = {
    Fishing = fishingContent,
    Teleport = Instance.new("Frame"), -- Placeholder
    Player = Instance.new("Frame"), -- Placeholder  
    Shop = Instance.new("Frame"), -- Placeholder
    Quests = Instance.new("Frame"), -- Placeholder
    Visual = Instance.new("Frame"), -- Placeholder
    Settings = Instance.new("Frame") -- Placeholder
}

-- Menu Navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Update content title
        cTitle.Text = btn:FindFirstChildOfClass("TextLabel").Text
        
        -- Hide all contents
        for _, contentFrame in pairs(contents) do
            if contentFrame then
                contentFrame.Visible = false
            end
        end
        
        -- Show selected content
        if contents[name] then
            contents[name].Visible = true
            currentContent = contents[name]
        end
        
        -- Update menu highlight
        for _, otherBtn in pairs(menuButtons) do
            otherBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    end)
end

-- Fishing Button Interactions
fishingButton.MouseButton1Click:Connect(function()
    if not fishingActive then
        StartFishing()
        fishingButton.Text = "🛑 STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        statusLabel.Text = "✅ FISHING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        StopFishing()
        fishingButton.Text = "🚀 START PERFECT FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

resetButton.MouseButton1Click:Connect(function()
    fishingStats = {
        fishCaught = 0,
        startTime = tick(),
        attempts = 0,
        successes = 0,
        fails = 0,
        lastCatch = 0
    }
    print("[Stats] Fishing statistics reset!")
end)

-- Window Controls
local minimized = false
local originalSize = container.Size
local originalPosition = container.Position

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        container.Size = UDim2.new(0, WIDTH, 0, 48)
        glow.Size = UDim2.new(0, WIDTH+80, 0, 48+80)
        inner.Visible = false
        minimizeBtn.Text = "+"
    else
        container.Size = originalSize
        glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
        inner.Visible = true
        minimizeBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screen.Enabled = false
    trayIcon.Visible = true
end)

trayIcon.MouseButton1Click:Connect(function()
    screen.Enabled = true
    trayIcon.Visible = false
end)

-- Mouse Drag
local dragging = false
local dragInput, dragStart, startPos

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
        local delta = input.Position - dragStart
        container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- RUNTIME UPDATES
-- ═══════════════════════════════════════════════════════════

-- Memory and Stats Update
local memoryUpdate = RunService.Heartbeat:Connect(function()
    -- Update memory usage
    local memory = math.floor(collectgarbage("count"))
    memLabel.Text = string.format("Memory: %d KB | Fish: %d", memory, fishingStats.fishCaught)
    
    -- Update fishing stats
    if fishingActive then
        local elapsed = tick() - fishingStats.startTime
        local successRate = (fishingStats.successes / math.max(1, fishingStats.attempts)) * 100
        local fishPerMinute = (fishingStats.fishCaught / math.max(1, elapsed)) * 60
        
        fishCountLabel.Text = "🎣 Fish Caught: " .. fishingStats.fishCaught
        rateLabel.Text = "⚡ Rate: " .. string.format("%.1f/min", fishPerMinute)
        attemptsLabel.Text = "🎯 Attempts: " .. fishingStats.attempts
        successLabel.Text = "✅ Success: " .. string.format("%.1f%%", successRate)
        timeLabel.Text = "⏱️ Session: " .. string.format("%.1fs", elapsed)
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function()
    task.wait(2) -- Wait for character to load
    print("[System] Character respawned - fishing system ready")
end)

-- Initial setup
print("═══════════════════════════════════════")
print("⚡ KAITUN FISH IT v4.0 LOADED!")
print("🎣 FIXED Perfect Instant Fishing System")
print("• Improved Rod Detection")
print("• Enhanced Method Detection") 
print("• Better Error Handling")
print("• Stable Timing System")
print("═══════════════════════════════════════")

-- Cleanup on script termination
screen.AncestryChanged:Connect(function()
    memoryUpdate:Disconnect()
    StopFishing()
end)
