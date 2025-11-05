
-- KAITUN FISH IT v4.0 - ULTIMATE FISHING SUITE
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
-- PERFECTED INSTANT FISHING SYSTEM v4.0
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

-- Advanced Rod Detection
local function FindFishingRod()
    local rodKeywords = {"rod", "pole", "fishing", "cane", "tackle"}
    
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
    
    return nil
end

-- Smart Rod Equip
local function EquipRod()
    return SafeCall(function()
        local rod = FindFishingRod()
        if not rod then 
            return false 
        end
        
        if rod.Parent == player.Backpack then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.2)
            end
        end
        
        return rod.Parent == GetCharacter()
    end) or false
end

-- Fishing Methods (sama seperti sebelumnya)
local function CastProximityPrompt()
    return SafeCall(function()
        local char = GetCharacter()
        if not char then return false end
        
        local foundPrompt = false
        
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local name = obj.Name:lower()
                local objText = obj.ObjectText and obj.ObjectText:lower() or ""
                local actionText = obj.ActionText and obj.ActionText:lower() or ""
                
                if name:match("fish") or name:match("cast") or name:match("catch") or
                   objText:match("fish") or objText:match("cast") or
                   actionText:match("fish") or actionText:match("cast") then
                    
                    for i = 1, 3 do
                        fireproximityprompt(obj)
                        task.wait(0.01)
                    end
                    
                    if not detectedMethods.proximity then
                        detectedMethods.proximity = true
                        print("[✓] ProximityPrompt method detected!")
                    end
                    foundPrompt = true
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
                for i = 1, 5 do
                    fireclickdetector(obj)
                    task.wait(0.01)
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

local function CastRemote()
    return SafeCall(function()
        local actions = {"cast", "fish", "throw", "reel", "catch", "bite", "hook"}
        local foundRemote = false
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        remote:FireServer()
                        remote:FireServer("Cast")
                        remote:FireServer(true)
                        remote:FireServer("Fishing")
                        remote:FireServer("Start")
                        
                        if not detectedMethods.remote then
                            detectedMethods.remote = true
                            print("[✓] RemoteEvent method detected:", remote.Name)
                        end
                        foundRemote = true
                    end
                end
            elseif remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        SafeCall(function() remote:InvokeServer() end)
                        SafeCall(function() remote:InvokeServer("Cast") end)
                        SafeCall(function() remote:InvokeServer(true) end)
                        foundRemote = true
                    end
                end
            end
        end
        
        return foundRemote
    end) or false
end

-- MASTER FISHING FUNCTION
local function PerformPerfectCast()
    if not fishingActive then return false end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    if fishingConfig.autoEquip then
        if not EquipRod() then
            fishingStats.fails = fishingStats.fails + 1
            return false
        end
    end
    
    local success = false
    local methodsUsed = 0
    
    if fishingConfig.multiMethod then
        if CastProximityPrompt() then success = true; methodsUsed = methodsUsed + 1 end
        if CastClickDetector() then success = true; methodsUsed = methodsUsed + 1 end
        if CastRemote() then success = true; methodsUsed = methodsUsed + 1 end
        
        -- Virtual Input
        SafeCall(function()
            for i = 1, 8 do
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.001)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(0.001)
            end
        end)
    end
    
    if success then
        fishingStats.successes = fishingStats.successes + 1
        fishingStats.fishCaught = fishingStats.fishCaught + 1
        fishingStats.lastCatch = tick()
    else
        fishingStats.fails = fishingStats.fails + 1
    end
    
    return success
end

-- Get delay based on speed setting
local function GetDelay()
    if fishingConfig.speed == "ultra" then
        return 0.1
    elseif fishingConfig.speed == "fast" then
        return 0.3
    else
        return 0.5
    end
end

-- Start Fishing
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
    print("═══════════════════════════════════════")
    
    local mainLoop = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        SafeCall(PerformPerfectCast)
        task.wait(GetDelay())
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
    
    print("═══════════════════════════════════════")
    print("[✓] FISHING STOPPED")
    print("[📊] Fish Caught:", fishingStats.fishCaught)
    print("  • Success Rate:", string.format("%.1f%%", successRate))
    print("  • Time:", string.format("%.1fs", elapsed))
    print("═══════════════════════════════════════")
end

-- ═══════════════════════════════════════════════════════════
-- NEW FEATURES SYSTEM
-- ═══════════════════════════════════════════════════════════

-- Player Modifications
local function ApplyPlayerMods()
    SafeCall(function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = featureConfig.walkSpeed
            humanoid.JumpPower = featureConfig.jumpPower
        end
    end)
end

-- Infinite Jump
local infiniteJumpConnection
local function ToggleInfiniteJump()
    if featureConfig.infiniteJump then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            SafeCall(function()
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
        print("[✓] Infinite Jump: ENABLED")
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
            print("[✓] Infinite Jump: DISABLED")
        end
    end
end

-- No Clip
local noClipConnection
local function ToggleNoClip()
    if featureConfig.noClip then
        noClipConnection = RunService.Stepped:Connect(function()
            SafeCall(function()
                local char = GetCharacter()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
        print("[✓] No Clip: ENABLED")
    else
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
            print("[✓] No Clip: DISABLED")
        end
    end
end

-- Fishing Radar
local radarBeam
local function ToggleFishingRadar()
    if featureConfig.fishingRadar then
        SafeCall(function()
            if not radarBeam then
                radarBeam = Instance.new("Part")
                radarBeam.Name = "FishingRadar"
                radarBeam.Size = Vector3.new(50, 1, 50)
                radarBeam.Anchored = true
                radarBeam.CanCollide = false
                radarBeam.Material = Enum.Material.Neon
                radarBeam.BrickColor = BrickColor.new("Bright blue")
                radarBeam.Transparency = 0.7
                radarBeam.Parent = Workspace
                
                local beamConnection = RunService.Heartbeat:Connect(function()
                    SafeCall(function()
                        local char = GetCharacter()
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            radarBeam.Position = char.HumanoidRootPart.Position - Vector3.new(0, 10, 0)
                        end
                    end)
                end)
                table.insert(activeConnections, beamConnection)
            end
        end)
        print("[✓] Fishing Radar: ENABLED")
    else
        SafeCall(function()
            if radarBeam then
                radarBeam:Destroy()
                radarBeam = nil
            end
        end)
        print("[✓] Fishing Radar: DISABLED")
    end
end

-- Auto Sell Fish
local function AutoSellFish()
    if not featureConfig.autoSell then return end
    
    SafeCall(function()
        -- Look for sell buttons or NPCs
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local name = obj.Name:lower()
                local action = obj.ActionText and obj.ActionText:lower() or ""
                
                if name:match("sell") or action:match("sell") or name:match("vendor") then
                    fireproximityprompt(obj)
                end
            end
        end
        
        -- Look for sell remotes
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("sell") then
                    remote:FireServer()
                    remote:FireServer("SellAll")
                    remote:FireServer(true)
                end
            end
        end
    end)
end

-- Auto Complete Quests
local function AutoCompleteQuests()
    if not featureConfig.autoCompleteQuests then return end
    
    SafeCall(function()
        -- Complete quests via remotes
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("quest") or name:match("mission") then
                    remote:FireServer("Complete")
                    remote:FireServer("Claim")
                    remote:FireServer("Finish")
                end
            end
        end
        
        -- Interact with quest NPCs
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local action = obj.ActionText and obj.ActionText:lower() or ""
                if action:match("quest") or action:match("mission") then
                    fireproximityprompt(obj)
                end
            end
        end
    end)
end

-- Spawn Boat
local function SpawnBoat()
    if not featureConfig.spawnBoat then return end
    
    SafeCall(function()
        -- Try to spawn boat via remotes
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("boat") or name:match("spawn") then
                    remote:FireServer("Boat")
                    remote:FireServer("SpawnBoat")
                    remote:FireServer("BoatSpawn")
                end
            end
        end
    end)
end

-- X-Ray Vision
local xRayConnection
local function ToggleXRayVision()
    if featureConfig.xrayVision then
        xRayConnection = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") and obj.Name:match("fish") then
                        obj.Material = Enum.Material.Neon
                        obj.Transparency = 0.3
                        obj.BrickColor = BrickColor.new("Bright red")
                    end
                end
            end)
        end)
        print("[✓] X-Ray Vision: ENABLED")
    else
        if xRayConnection then
            xRayConnection:Disconnect()
            xRayConnection = nil
        end
        print("[✓] X-Ray Vision: DISABLED")
    end
end

-- Full Bright
local function ToggleFullBright()
    if featureConfig.fullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        print("[✓] Full Bright: ENABLED")
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        print("[✓] Full Bright: DISABLED")
    end
end

-- Auto Upgrade Rod
local function AutoUpgradeRod()
    if not featureConfig.autoUpgrade then return end
    
    SafeCall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("upgrade") or name:match("enchant") then
                    remote:FireServer()
                    remote:FireServer("Upgrade")
                    remote:FireServer("Enchant")
                    remote:FireServer("DoubleEnchant")
                end
            end
        end
    end)
end

-- Unlock All Areas
local function UnlockAllAreas()
    if not featureConfig.unlockAllAreas then return end
    
    SafeCall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("unlock") or name:match("area") then
                    remote:FireServer("UnlockAll")
                    remote:FireServer("AllAreas")
                end
            end
        end
    end)
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

local normalBtn, normalSpeed = CreateSpeedButton("Normal", "0.5s delay", "normal", 0.02)
local fastBtn, fastSpeed = CreateSpeedButton("Fast", "0.3s delay", "fast", 0.35)
local ultraBtn, ultraSpeed = CreateSpeedButton("Ultra", "0.1s instant", "ultra", 0.68)

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
-- TELEPORT UI CONTENT
-- ═══════════════════════════════════════════════════════════

local teleportContent = Instance.new("ScrollingFrame")
teleportContent.Name = "TeleportContent"
teleportContent.Size = UDim2.new(1, -24, 1, -68)
teleportContent.Position = UDim2.new(0, 12, 0, 56)
teleportContent.BackgroundTransparency = 1
teleportContent.BorderSizePixel = 0
teleportContent.ScrollBarThickness = 6
teleportContent.ScrollBarImageColor3 = ACCENT
teleportContent.CanvasSize = UDim2.new(0, 0, 0, 800)
teleportContent.Visible = false
teleportContent.Parent = content

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Size = UDim2.new(1, -24, 0, 44)
teleportTitle.Position = UDim2.new(0,12,0,12)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 16
teleportTitle.Text = "📍 Teleport Locations"
teleportTitle.TextColor3 = Color3.fromRGB(245,245,245)
teleportTitle.TextXAlignment = Enum.TextXAlignment.Left
teleportTitle.Parent = teleportContent

-- Teleport Locations
local teleportLocations = {
    {"🏝️ Starter Island", Vector3.new(0, 10, 0)},
    {"🌊 Ocean Center", Vector3.new(100, 5, 100)},
    {"❄️ Ice Realm", Vector3.new(-200, 20, -200)},
    {"🔥 Volcano", Vector3.new(300, 50, 0)},
    {"🌴 Palm Island", Vector3.new(150, 15, -150)},
    {"⚡ Stormy Seas", Vector3.new(-100, 10, 200)},
    {"💎 Crystal Cave", Vector3.new(0, -50, 300)},
    {"🌅 Sunset Beach", Vector3.new(-300, 10, -100)},
    {"🐉 Dragon's Lair", Vector3.new(400, 100, 400)},
    {"🌌 Deep Ocean", Vector3.new(0, -100, 0)},
    {"🏔️ Mountain Peak", Vector3.new(0, 200, 0)},
    {"🕳️ Abyss", Vector3.new(0, -200, 0)}
}

local function CreateTeleportButton(name, position, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 50)
    btn.Position = UDim2.new(0, 12, 0, 60 + (index * 60))
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    btn.AutoButtonColor = false
    btn.Parent = teleportContent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SafeCall(function()
            local char = GetCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(position)
                print("[Teleport] Teleported to:", name)
            end
        end)
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
    end)
    
    return btn
end

for i, location in ipairs(teleportLocations) do
    CreateTeleportButton(location[1], location[2], i)
end

-- ═══════════════════════════════════════════════════════════
-- PLAYER MODS UI CONTENT
-- ═══════════════════════════════════════════════════════════

local playerContent = Instance.new("ScrollingFrame")
playerContent.Name = "PlayerContent"
playerContent.Size = UDim2.new(1, -24, 1, -68)
playerContent.Position = UDim2.new(0, 12, 0, 56)
playerContent.BackgroundTransparency = 1
playerContent.BorderSizePixel = 0
playerContent.ScrollBarThickness = 6
playerContent.ScrollBarImageColor3 = ACCENT
playerContent.CanvasSize = UDim2.new(0, 0, 0, 600)
playerContent.Visible = false
playerContent.Parent = content

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1, -24, 0, 44)
playerTitle.Position = UDim2.new(0,12,0,12)
playerTitle.BackgroundTransparency = 1
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextSize = 16
playerTitle.Text = "👤 Player Modifications"
playerTitle.TextColor3 = Color3.fromRGB(245,245,245)
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.Parent = playerContent

-- Walk Speed Slider
local walkSpeedFrame = Instance.new("Frame")
walkSpeedFrame.Size = UDim2.new(1, -24, 0, 80)
walkSpeedFrame.Position = UDim2.new(0, 12, 0, 60)
walkSpeedFrame.BackgroundTransparency = 1
walkSpeedFrame.Parent = playerContent

local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Size = UDim2.new(1, 0, 0, 24)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.Font = Enum.Font.GothamBold
walkSpeedLabel.TextSize = 14
walkSpeedLabel.Text = "🚶 Walk Speed: 16"
walkSpeedLabel.TextColor3 = Color3.fromRGB(240,240,240)
walkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
walkSpeedLabel.Parent = walkSpeedFrame

local walkSpeedSlider = Instance.new("Frame")
walkSpeedSlider.Size = UDim2.new(1, 0, 0, 30)
walkSpeedSlider.Position = UDim2.new(0, 0, 0, 30)
walkSpeedSlider.BackgroundColor3 = Color3.fromRGB(40,40,45)
walkSpeedSlider.BorderSizePixel = 0
walkSpeedSlider.Parent = walkSpeedFrame

local walkSpeedCorner = Instance.new("UICorner")
walkSpeedCorner.CornerRadius = UDim.new(0,6)
walkSpeedCorner.Parent = walkSpeedSlider

local walkSpeedFill = Instance.new("Frame")
walkSpeedFill.Size = UDim2.new(0.4, 0, 1, 0)
walkSpeedFill.BackgroundColor3 = ACCENT
walkSpeedFill.BorderSizePixel = 0
walkSpeedFill.Parent = walkSpeedSlider

local walkSpeedFillCorner = Instance.new("UICorner")
walkSpeedFillCorner.CornerRadius = UDim.new(0,6)
walkSpeedFillCorner.Parent = walkSpeedFill

walkSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = walkSpeedSlider.AbsolutePosition
            local sliderSize = walkSpeedSlider.AbsoluteSize.X
            local relativeX = math.clamp(mouse.X - sliderPos.X, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            featureConfig.walkSpeed = math.floor(16 + (percentage * 50))
            walkSpeedLabel.Text = "🚶 Walk Speed: " .. featureConfig.walkSpeed
            walkSpeedFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            ApplyPlayerMods()
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Jump Power Slider
local jumpPowerFrame = Instance.new("Frame")
jumpPowerFrame.Size = UDim2.new(1, -24, 0, 80)
jumpPowerFrame.Position = UDim2.new(0, 12, 0, 160)
jumpPowerFrame.BackgroundTransparency = 1
jumpPowerFrame.Parent = playerContent

local jumpPowerLabel = Instance.new("TextLabel")
jumpPowerLabel.Size = UDim2.new(1, 0, 0, 24)
jumpPowerLabel.BackgroundTransparency = 1
jumpPowerLabel.Font = Enum.Font.GothamBold
jumpPowerLabel.TextSize = 14
jumpPowerLabel.Text = "🦘 Jump Power: 50"
jumpPowerLabel.TextColor3 = Color3.fromRGB(240,240,240)
jumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpPowerLabel.Parent = jumpPowerFrame

local jumpPowerSlider = Instance.new("Frame")
jumpPowerSlider.Size = UDim2.new(1, 0, 0, 30)
jumpPowerSlider.Position = UDim2.new(0, 0, 0, 30)
jumpPowerSlider.BackgroundColor3 = Color3.fromRGB(40,40,45)
jumpPowerSlider.BorderSizePixel = 0
jumpPowerSlider.Parent = jumpPowerFrame

local jumpPowerCorner = Instance.new("UICorner")
jumpPowerCorner.CornerRadius = UDim.new(0,6)
jumpPowerCorner.Parent = jumpPowerSlider

local jumpPowerFill = Instance.new("Frame")
jumpPowerFill.Size = UDim2.new(0.5, 0, 1, 0)
jumpPowerFill.BackgroundColor3 = ACCENT
jumpPowerFill.BorderSizePixel = 0
jumpPowerFill.Parent = jumpPowerSlider

local jumpPowerFillCorner = Instance.new("UICorner")
jumpPowerFillCorner.CornerRadius = UDim.new(0,6)
jumpPowerFillCorner.Parent = jumpPowerFill

jumpPowerSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = jumpPowerSlider.AbsolutePosition
            local sliderSize = jumpPowerSlider.AbsoluteSize.X
            local relativeX = math.clamp(mouse.X - sliderPos.X, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            featureConfig.jumpPower = math.floor(50 + (percentage * 100))
            jumpPowerLabel.Text = "🦘 Jump Power: " .. featureConfig.jumpPower
            jumpPowerFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            ApplyPlayerMods()
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end
end)

-- Player Toggles
local function CreatePlayerToggle(name, desc, configKey, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = playerContent

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
    button.BackgroundColor3 = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = featureConfig[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        featureConfig[configKey] = not featureConfig[configKey]
        button.Text = featureConfig[configKey] and "ON" or "OFF"
        local targetColor = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        if configKey == "infiniteJump" then
            ToggleInfiniteJump()
        elseif configKey == "noClip" then
            ToggleNoClip()
        end
        
        print("[Player]", name, ":", featureConfig[configKey] and "ON" or "OFF")
    end)

    return frame
end

CreatePlayerToggle("∞ Infinite Jump", "Jump infinitely in air", "infiniteJump", 260)
CreatePlayerToggle("🚫 No Clip", "Walk through walls", "noClip", 300)
CreatePlayerToggle("📡 Fishing Radar", "Show fishing spots", "fishingRadar", 340)
CreatePlayerToggle("💰 Auto Sell", "Automatically sell fish", "autoSell", 380)
CreatePlayerToggle("⚡ Auto Upgrade", "Auto upgrade fishing rod", "autoUpgrade", 420)
CreatePlayerToggle("🛥️ Spawn Boat", "Spawn fishing boat", "spawnBoat", 460)
CreatePlayerToggle("📜 Auto Quests", "Auto complete quests", "autoCompleteQuests", 500)
CreatePlayerToggle("🔓 Unlock All", "Unlock all areas", "unlockAllAreas", 540)

-- ═══════════════════════════════════════════════════════════
-- SHOP UI CONTENT
-- ═══════════════════════════════════════════════════════════

local shopContent = Instance.new("ScrollingFrame")
shopContent.Name = "ShopContent"
shopContent.Size = UDim2.new(1, -24, 1, -68)
shopContent.Position = UDim2.new(0, 12, 0, 56)
shopContent.BackgroundTransparency = 1
shopContent.BorderSizePixel = 0
shopContent.ScrollBarThickness = 6
shopContent.ScrollBarImageColor3 = ACCENT
shopContent.CanvasSize = UDim2.new(0, 0, 0, 600)
shopContent.Visible = false
shopContent.Parent = content

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -24, 0, 44)
shopTitle.Position = UDim2.new(0,12,0,12)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 16
shopTitle.Text = "🛒 Shop & Items"
shopTitle.TextColor3 = Color3.fromRGB(245,245,245)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent = shopContent

-- Shop Items
local shopItems = {
    {"🎣 Basic Rod", "basic_rod"},
    {"⚡ Element Rod", "element_rod"},
    {"👻 Ghostfin Rod", "ghostfin_rod"},
    {"✨ Enchant Rod", "enchant_rod"},
    {"🌟 Double Enchant", "double_enchant"},
    {"🦐 Premium Bait", "premium_bait"},
    {"🧭 Fishing Radar", "fishing_radar"},
    {"🛥️ Speed Boat", "speed_boat"},
    {"💎 Diamond Hook", "diamond_hook"},
    {"🔥 Fire Bait", "fire_bait"},
    {"❄️ Ice Bait", "ice_bait"},
    {"⚡ Lightning Bait", "lightning_bait"}
}

local function CreateShopItem(name, itemId, index)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 70)
    frame.Position = UDim2.new(0, 12, 0, 60 + (index * 80))
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = shopContent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0,8)
    frameCorner.Parent = frame
    
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    itemLabel.Position = UDim2.new(0, 15, 0, 8)
    itemLabel.BackgroundTransparency = 1
    itemLabel.Font = Enum.Font.GothamBold
    itemLabel.TextSize = 14
    itemLabel.Text = name
    itemLabel.TextColor3 = Color3.fromRGB(240,240,240)
    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    descLabel.Position = UDim2.new(0, 15, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.Text = "Item ID: " .. itemId
    descLabel.TextColor3 = Color3.fromRGB(180,180,180)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame
    
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.3, -10, 0, 36)
    buyBtn.Position = UDim2.new(0.7, 5, 0.5, -18)
    buyBtn.BackgroundColor3 = ACCENT
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 12
    buyBtn.Text = "BUY FREE"
    buyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    buyBtn.AutoButtonColor = false
    buyBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = buyBtn
    
    buyBtn.MouseButton1Click:Connect(function()
        SafeCall(function()
            -- Try to purchase item via remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local remoteName = remote.Name:lower()
                    if remoteName:match("buy") or remoteName:match("purchase") or remoteName:match("shop") then
                        remote:FireServer(itemId)
                        remote:FireServer("Buy", itemId)
                        remote:FireServer(itemId, 1)
                    end
                end
            end
            print("[Shop] Attempting to buy:", name)
        end)
    end)
    
    buyBtn.MouseEnter:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 82, 82)}):Play()
    end)
    
    buyBtn.MouseLeave:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
    end)
    
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    end)
    
    frame.MouseLeave:Connect(function()
    TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
end)

return frame
end

for i, item in ipairs(shopItems) do
    CreateShopItem(item[1], item[2], i)
end

-- ═══════════════════════════════════════════════════════════
-- QUESTS UI CONTENT
-- ═══════════════════════════════════════════════════════════

local questsContent = Instance.new("ScrollingFrame")
questsContent.Name = "QuestsContent"
questsContent.Size = UDim2.new(1, -24, 1, -68)
questsContent.Position = UDim2.new(0, 12, 0, 56)
questsContent.BackgroundTransparency = 1
questsContent.BorderSizePixel = 0
questsContent.ScrollBarThickness = 6
questsContent.ScrollBarImageColor3 = ACCENT
questsContent.CanvasSize = UDim2.new(0, 0, 0, 400)
questsContent.Visible = false
questsContent.Parent = content

local questsTitle = Instance.new("TextLabel")
questsTitle.Size = UDim2.new(1, -24, 0, 44)
questsTitle.Position = UDim2.new(0,12,0,12)
questsTitle.BackgroundTransparency = 1
questsTitle.Font = Enum.Font.GothamBold
questsTitle.TextSize = 16
questsTitle.Text = "📜 Quest Automation"
questsTitle.TextColor3 = Color3.fromRGB(245,245,245)
questsTitle.TextXAlignment = Enum.TextXAlignment.Left
questsTitle.Parent = questsContent

-- Quest Automation
local questFrame = Instance.new("Frame")
questFrame.Size = UDim2.new(1, -24, 0, 120)
questFrame.Position = UDim2.new(0, 12, 0, 60)
questFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
questFrame.BorderSizePixel = 0
questFrame.Parent = questsContent

local questCorner = Instance.new("UICorner")
questCorner.CornerRadius = UDim.new(0,8)
questCorner.Parent = questFrame

local questLabel = Instance.new("TextLabel")
questLabel.Size = UDim2.new(1, -24, 0, 40)
questLabel.Position = UDim2.new(0, 12, 0, 8)
questLabel.BackgroundTransparency = 1
questLabel.Font = Enum.Font.GothamBold
questLabel.TextSize = 14
questLabel.Text = "🎯 Auto Quest System"
questLabel.TextColor3 = Color3.fromRGB(240,240,240)
questLabel.TextXAlignment = Enum.TextXAlignment.Left
questLabel.Parent = questFrame

local questDesc = Instance.new("TextLabel")
questDesc.Size = UDim2.new(1, -24, 0, 30)
questDesc.Position = UDim2.new(0, 12, 0, 40)
questDesc.BackgroundTransparency = 1
questDesc.Font = Enum.Font.Gotham
questDesc.TextSize = 11
questDesc.Text = "Automatically completes available quests"
questDesc.TextColor3 = Color3.fromRGB(180,180,180)
questDesc.TextXAlignment = Enum.TextXAlignment.Left
questDesc.Parent = questFrame

local questButton = Instance.new("TextButton")
questButton.Size = UDim2.new(0, 140, 0, 36)
questButton.Position = UDim2.new(0.5, -70, 0, 75)
questButton.BackgroundColor3 = ACCENT
questButton.Font = Enum.Font.GothamBold
questButton.TextSize = 13
questButton.Text = "🚀 RUN AUTO QUESTS"
questButton.TextColor3 = Color3.fromRGB(255,255,255)
questButton.AutoButtonColor = false
questButton.Parent = questFrame

local questBtnCorner = Instance.new("UICorner")
questBtnCorner.CornerRadius = UDim.new(0,6)
questBtnCorner.Parent = questButton

questButton.MouseButton1Click:Connect(function()
    AutoCompleteQuests()
    print("[Quests] Auto quest system activated!")
end)

-- ═══════════════════════════════════════════════════════════
-- VISUAL UI CONTENT
-- ═══════════════════════════════════════════════════════════

local visualContent = Instance.new("ScrollingFrame")
visualContent.Name = "VisualContent"
visualContent.Size = UDim2.new(1, -24, 1, -68)
visualContent.Position = UDim2.new(0, 12, 0, 56)
visualContent.BackgroundTransparency = 1
visualContent.BorderSizePixel = 0
visualContent.ScrollBarThickness = 6
visualContent.ScrollBarImageColor3 = ACCENT
visualContent.CanvasSize = UDim2.new(0, 0, 0, 300)
visualContent.Visible = false
visualContent.Parent = content

local visualTitle = Instance.new("TextLabel")
visualTitle.Size = UDim2.new(1, -24, 0, 44)
visualTitle.Position = UDim2.new(0,12,0,12)
visualTitle.BackgroundTransparency = 1
visualTitle.Font = Enum.Font.GothamBold
visualTitle.TextSize = 16
visualTitle.Text = "👁️ Visual Enhancements"
visualTitle.TextColor3 = Color3.fromRGB(245,245,245)
visualTitle.TextXAlignment = Enum.TextXAlignment.Left
visualTitle.Parent = visualContent

-- Visual Toggles
local function CreateVisualToggle(name, desc, configKey, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = visualContent

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
    button.BackgroundColor3 = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = featureConfig[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        featureConfig[configKey] = not featureConfig[configKey]
        button.Text = featureConfig[configKey] and "ON" or "OFF"
        local targetColor = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        if configKey == "xrayVision" then
            ToggleXRayVision()
        elseif configKey == "fullBright" then
            ToggleFullBright()
        end
        
        print("[Visual]", name, ":", featureConfig[configKey] and "ON" or "OFF")
    end)

    return frame
end

CreateVisualToggle("🔍 X-Ray Vision", "See fish through walls", "xrayVision", 60)
CreateVisualToggle("💡 Full Bright", "Remove darkness", "fullBright", 100)

-- ═══════════════════════════════════════════════════════════
-- SETTINGS UI CONTENT
-- ═══════════════════════════════════════════════════════════

local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -24, 1, -68)
settingsContent.Position = UDim2.new(0, 12, 0, 56)
settingsContent.BackgroundTransparency = 1
settingsContent.BorderSizePixel = 0
settingsContent.ScrollBarThickness = 6
settingsContent.ScrollBarImageColor3 = ACCENT
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 400)
settingsContent.Visible = false
settingsContent.Parent = content

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -24, 0, 44)
settingsTitle.Position = UDim2.new(0,12,0,12)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 16
settingsTitle.Text = "⚙ Settings & Info"
settingsTitle.TextColor3 = Color3.fromRGB(245,245,245)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsContent

-- Info Panel
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, -24, 0, 120)
infoFrame.Position = UDim2.new(0, 12, 0, 60)
infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
infoFrame.BorderSizePixel = 0
infoFrame.Parent = settingsContent

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0,8)
infoCorner.Parent = infoFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -24, 1, -8)
infoLabel.Position = UDim2.new(0, 12, 0, 4)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.Text = "⚡ KAITUN FISH IT v4.0\n\n• Perfect Instant Fishing\n• Advanced Player Mods\n• Auto Quest System\n• Visual Enhancements\n• Teleport System\n• Shop Automation"
infoLabel.TextColor3 = Color3.fromRGB(200,200,200)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = infoFrame

-- Reset Button
local resetAllBtn = Instance.new("TextButton")
resetAllBtn.Size = UDim2.new(1, -24, 0, 50)
resetAllBtn.Position = UDim2.new(0, 12, 0, 200)
resetAllBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
resetAllBtn.Font = Enum.Font.GothamBold
resetAllBtn.TextSize = 14
resetAllBtn.Text = "🔄 RESET ALL SETTINGS"
resetAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
resetAllBtn.AutoButtonColor = false
resetAllBtn.Parent = settingsContent

local resetAllCorner = Instance.new("UICorner")
resetAllCorner.CornerRadius = UDim.new(0,8)
resetAllCorner.Parent = resetAllBtn

resetAllBtn.MouseButton1Click:Connect(function()
    -- Reset fishing config
    for key, value in pairs(fishingConfig) do
        if type(value) == "boolean" then
            fishingConfig[key] = false
        elseif key == "speed" then
            fishingConfig[key] = "ultra"
        end
    end
    
    -- Reset feature config
    for key, value in pairs(featureConfig) do
        if type(value) == "boolean" then
            featureConfig[key] = false
        elseif key == "walkSpeed" then
            featureConfig[key] = 16
        elseif key == "jumpPower" then
            featureConfig[key] = 50
        end
    end
    
    -- Reset stats
    fishingStats = {
        fishCaught = 0,
        startTime = tick(),
        attempts = 0,
        successes = 0,
        fails = 0,
        lastCatch = 0
    }
    
    -- Stop fishing
    StopFishing()
    
    -- Disable all features
    ToggleInfiniteJump()
    ToggleNoClip()
    ToggleFishingRadar()
    ToggleXRayVision()
    ToggleFullBright()
    
    print("[Settings] All settings reset to default!")
end)

-- ═══════════════════════════════════════════════════════════
-- UI INTERACTIONS & ANIMATIONS
-- ═══════════════════════════════════════════════════════════

-- Content Management
local currentContent = fishingContent
local contents = {
    Fishing = fishingContent,
    Teleport = teleportContent,
    Player = playerContent,
    Shop = shopContent,
    Quests = questsContent,
    Visual = visualContent,
    Settings = settingsContent
}

-- Menu Navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Update content title
        cTitle.Text = btn:FindFirstChildOfClass("TextLabel").Text
        
        -- Hide all contents
        for _, contentFrame in pairs(contents) do
            contentFrame.Visible = false
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
    
    -- Auto features
    if featureConfig.autoSell then
        AutoSellFish()
    end
    
    if featureConfig.autoUpgrade then
        AutoUpgradeRod()
    end
    
    if featureConfig.autoCompleteQuests then
        AutoCompleteQuests()
    end
    
    if featureConfig.spawnBoat then
        SpawnBoat()
    end
    
    if featureConfig.unlockAllAreas then
        UnlockAllAreas()
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function()
    task.wait(1) -- Wait for character to load
    ApplyPlayerMods()
    ToggleInfiniteJump()
    ToggleNoClip()
end)

-- Initial setup
ApplyPlayerMods()
ToggleInfiniteJump()
ToggleNoClip()
ToggleFishingRadar()
ToggleXRayVision()
ToggleFullBright()

print("═══════════════════════════════════════")
print("⚡ KAITUN FISH IT v4.0 LOADED!")
print("🎣 Perfect Instant Fishing System")
print("👤 Advanced Player Modifications") 
print("📍 Teleport System")
print("🛒 Shop Automation")
print("📜 Quest System")
print("👁️ Visual Enhancements")
print("═══════════════════════════════════════")

-- Cleanup on script termination
screen.AncestryChanged:Connect(function()
    memoryUpdate:Disconnect()
    StopFishing()
    ToggleInfiniteJump()
    ToggleNoClip()
    ToggleFishingRadar()
    ToggleXRayVision()
    ToggleFullBright()
end)
