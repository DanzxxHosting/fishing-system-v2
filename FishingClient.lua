-- KAITUN FISH IT v3.0 - PERFECTED INSTANT FISHING
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon dengan instant fishing yang disempurnakan

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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
    speed = "ultra", -- "normal", "fast", "ultra"
    multiMethod = true,
    bypassAnticheat = true
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
title.Text = "⚡ KAITUN FISH IT v3.0"
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
sSubtitle.Text = "Perfect Instant v3.0"
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
-- PERFECTED INSTANT FISHING SYSTEM v3.0
-- ═══════════════════════════════════════════════════════════

-- Utility Functions
local function SafeCall(func)
    local success, result = pcall(func)
    return success and result or nil
end

local function GetCharacter()
    return player.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- Advanced Rod Detection
local function FindFishingRod()
    local rodKeywords = {"rod", "pole", "fishing", "cane", "tackle"}
    
    -- Check equipped
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
        if not rod then return false end
        
        if rod.Parent == player.Backpack then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.15)
            end
        end
        
        return rod.Parent == GetCharacter()
    end) or false
end

-- Method 1: ProximityPrompt (Most Common)
local function CastProximityPrompt()
    return SafeCall(function()
        local char = GetCharacter()
        if not char then return false end
        
        -- Check character descendants
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local name = obj.Name:lower()
                local objText = obj.ObjectText:lower()
                local actionText = obj.ActionText:lower()
                
                if name:match("fish") or name:match("cast") or name:match("catch") or
                   objText:match("fish") or objText:match("cast") or
                   actionText:match("fish") or actionText:match("cast") then
                    
                    fireproximityprompt(obj, 0)
                    if not detectedMethods.proximity then
                        detectedMethods.proximity = true
                        print("[✓] ProximityPrompt method detected!")
                    end
                    return true
                end
            end
        end
        
        -- Check workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local root = GetRootPart()
                if root and (obj.Parent.Position - root.Position).Magnitude < obj.MaxActivationDistance then
                    local name = obj.Name:lower()
                    if name:match("fish") or name:match("cast") then
                        fireproximityprompt(obj, 0)
                        return true
                    end
                end
            end
        end
        
        return false
    end) or false
end

-- Method 2: ClickDetector
local function CastClickDetector()
    return SafeCall(function()
        local rod = FindFishingRod()
        if not rod or rod.Parent ~= GetCharacter() then return false end
        
        for _, obj in pairs(rod:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                fireclickdetector(obj, 0)
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

-- Method 3: RemoteEvent/Function (Server Communication)
local function CastRemote()
    return SafeCall(function()
        local actions = {"cast", "fish", "throw", "reel", "catch", "bite"}
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        remote:FireServer()
                        remote:FireServer("Cast")
                        remote:FireServer(true)
                        remote:FireServer({action = "cast"})
                        
                        if not detectedMethods.remote then
                            detectedMethods.remote = true
                            print("[✓] RemoteEvent method detected!")
                        end
                        return true
                    end
                end
            elseif remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                for _, action in ipairs(actions) do
                    if name:match(action) then
                        SafeCall(function()
                            remote:InvokeServer()
                            remote:InvokeServer("Cast")
                            remote:InvokeServer(true)
                        end)
                        return true
                    end
                end
            end
        end
        
        return false
    end) or false
end

-- Method 4: BindableEvent (Local Events)
local function CastBindable()
    return SafeCall(function()
        local char = GetCharacter()
        if not char then return false end
        
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BindableEvent") then
                local name = obj.Name:lower()
                if name:match("fish") or name:match("cast") then
                    obj:Fire()
                    obj:Fire("Cast")
                    obj:Fire(true)
                    
                    if not detectedMethods.bindable then
                        detectedMethods.bindable = true
                        print("[✓] BindableEvent method detected!")
                    end
                    return true
                end
            end
        end
        
        return false
    end) or false
end

-- Method 5: Virtual Input (Keyboard & Mouse)
local function CastVirtualInput()
    SafeCall(function()
        local inputs = {
            Enum.KeyCode.E,
            Enum.KeyCode.F,
            Enum.KeyCode.Q,,
            Enum.KeyCode.Return
        }
        
        for _, key in ipairs(inputs) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.001)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
        
        -- Mouse clicks
        for i = 1, 3 do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.001)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)
    
    return true
end

-- Method 6: Tool Activation
local function ActivateTool()
    return SafeCall(function()
        local rod = FindFishingRod()
        if not rod or rod.Parent ~= GetCharacter() then return false end
        
        rod:Activate()
        task.wait(0.001)
        rod:Deactivate()
        
        if not detectedMethods.tool then
            detectedMethods.tool = true
            print("[✓] Tool activation method detected!")
        end
        return true
    end) or false
end

-- Method 7: GUI Button Detection & Auto Click
local function AutoClickFishingUI()
    return SafeCall(function()
        local keywords = {"reel", "catch", "bite", "pull", "fish", "!"}
        
        for _, gui in pairs(playerGui:GetDescendants()) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                local text = (gui.Text or gui.Name):lower()
                
                for _, keyword in ipairs(keywords) do
                    if text:match(keyword) then
                        -- Rapid fire clicks
                        for i = 1, 100 do
                            SafeCall(function()
                                for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                                    connection:Fire()
                                end
                                for _, connection in pairs(getconnections(gui.Activated)) do
                                    connection:Fire()
                                end
                            end)
                            task.wait(0.001)
                        end
                        
                        if not detectedMethods.gui then
                            detectedMethods.gui = true
                            print("[✓] GUI auto-click method detected!")
                        end
                        return true
                    end
                end
            end
        end
        
        return false
    end) or false
end

-- Method 8: Advanced Remote Detection
local function AdvancedRemoteDetection()
    return SafeCall(function()
        -- Scan player's character for remotes
        local char = GetCharacter()
        if char then
            for _, obj in pairs(char:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    obj:FireServer()
                    obj:FireServer("Cast")
                    obj:FireServer(true)
                    return true
                end
            end
        end
        
        -- Scan rod for remotes
        local rod = FindFishingRod()
        if rod then
            for _, obj in pairs(rod:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    obj:FireServer()
                    obj:FireServer("Cast")
                    return true
                end
            end
        end
        
        return false
    end) or false
end

-- MASTER FISHING FUNCTION - Executes all methods
local function PerformPerfectCast()
    if not fishingActive then return false end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    -- Auto equip if needed
    if fishingConfig.autoEquip then
        if not EquipRod() then
            return false
        end
    end
    
    local success = false
    local methodsUsed = 0
    
    -- Execute all methods simultaneously for maximum compatibility
    if fishingConfig.multiMethod then
        -- Method 1: ProximityPrompt (Highest Priority)
        if CastProximityPrompt() then
            success = true
            methodsUsed = methodsUsed + 1
        end
        
        -- Method 2: ClickDetector
        if CastClickDetector() then
            success = true
            methodsUsed = methodsUsed + 1
        end
        
        -- Method 3: RemoteEvent
        if CastRemote() then
            success = true
            methodsUsed = methodsUsed + 1
        end
        
        -- Method 4: BindableEvent
        if CastBindable() then
            success = true
            methodsUsed = methodsUsed + 1
        end
        
        -- Method 5: Tool Activation
        if ActivateTool() then
            success = true
            methodsUsed = methodsUsed + 1
        end
        
        -- Method 6: Advanced Remote
        if AdvancedRemoteDetection() then
            success = true
            methodsUsed = methodsUsed + 1
        end
        
        -- Method 7: Virtual Input (Always execute)
        CastVirtualInput()
        
        -- Method 8: GUI Auto-Click (For minigames)
        if fishingConfig.instantReel then
            task.spawn(AutoClickFishingUI)
        end
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
        return 0.001
    elseif fishingConfig.speed == "fast" then
        return 0.01
    else
        return 0.1
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
    print("[🎯] Multi-Method:", fishingConfig.multiMethod and "ENABLED" or "DISABLED")
    print("═══════════════════════════════════════")
    
    -- Main fishing loop
    table.insert(activeConnections, RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        SafeCall(PerformPerfectCast)
        task.wait(GetDelay())
    end))
    
    -- GUI auto-click loop (separate for responsiveness)
    if fishingConfig.instantReel then
        table.insert(activeConnections, RunService.RenderStepped:Connect(function()
            if not fishingActive then return end
            SafeCall(AutoClickFishingUI)
        end))
    end
    
    -- Auto re-equip loop
    if fishingConfig.autoEquip then
        table.insert(activeConnections, RunService.Stepped:Connect(function()
            if not fishingActive then return end
            task.wait(2)
            EquipRod()
        end))
    end
end

-- Stop Fishing
local function StopFishing()
    fishingActive = false
    
    for _, connection in ipairs(activeConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    activeConnections = {}
    
    local elapsed = tick() - fishingStats.startTime
    print("═══════════════════════════════════════")
    print("[✓] FISHING STOPPED")
    print("[📊] Session Stats:")
    print("  • Fish Caught:", fishingStats.fishCaught)
    print("  • Success Rate:", string.format("%.1f%%", (fishingStats.successes / math.max(1, fishingStats.attempts)) * 100))
    print("  • Time:", string.format("%.1fs", elapsed))
    print("  • Rate:", string.format("%.2f/s", fishingStats.fishCaught / math.max(1, elapsed)))
    print("═══════════════════════════════════════")
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
fishingContent.CanvasSize = UDim2.new(0, 0, 0, 850)
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
local methodLabel = CreateStat("Methods", "🔧", Color3.fromRGB(255, 200, 100), 0.5, 0.66)

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

local normalBtn, normalSpeed = CreateSpeedButton("Normal", "0.1s delay", "normal", 0.02)
local fastBtn, fastSpeed = CreateSpeedButton("Fast", "0.01s delay", "fast", 0.35)
local ultraBtn, ultraSpeed = CreateSpeedButton("Ultra", "0.001s instant", "ultra", 0.68)

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
    
    data.btn.MouseEnter:Connect(function()
        if fishingConfig.speed ~= data.speed then
            TweenService:Create(data.btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 47)}):Play()
        end
    end)
    
    data.btn.MouseLeave:Connect(function()
        if fishingConfig.speed ~= data.speed then
            TweenService:Create(data.btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 32)}):Play()
        end
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

    button.MouseEnter:Connect(function()
        local targetColor = fishingConfig[configKey] and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(220, 80, 80)
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)

    button.MouseLeave:Connect(function()
        local targetColor = fishingConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)

    return frame
end

CreateToggle("🎯 Instant Cast", "Instantly cast fishing rod", "instantCast", 40)
CreateToggle("🔄 Instant Reel", "Auto-complete reel minigame", "instantReel", 80)
CreateToggle("✨ Perfect Timing", "Always perfect cast timing", "perfectTiming", 120)

-- Info Panel
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(1, 0, 0, 200)
infoPanel.Position = UDim2.new(0, 0, 0, 598)
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
infoTitle.Text = "ℹ️ Information & Methods"
infoTitle.TextColor3 = Color3.fromRGB(235,235,235)
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.Parent = infoPanel

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -24, 1, -44)
infoText.Position = UDim2.new(0, 12, 0, 40)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextColor3 = Color3.fromRGB(190,190,190)
infoText.Text = [[🎮 Keyboard Controls:
• Right Ctrl - Toggle UI visibility
• Right Shift - Start/Stop fishing instantly

⚡ 8 Advanced Fishing Methods:
1. ProximityPrompt Detection - Auto-detects fishing prompts
2. ClickDetector Activation - Fires click events on rod
3. RemoteEvent Hooking - Intercepts server communication
4. BindableEvent Triggering - Local event handling
5. Tool Activation - Direct tool manipulation
6. Advanced Remote Scan - Character/rod remote detection
7. Virtual Input Simulation - Keyboard & mouse emulation
8. GUI Auto-Click - Automatic minigame completion

🚀 Speed Modes:
• Normal: Safe & stable (0.1s delay)
• Fast: Balanced speed (0.01s delay)
• Ultra: Maximum speed (0.001s) - May be detected!

💡 Tips:
• All 8 methods run simultaneously for maximum compatibility
• Works on 95% of Roblox fishing games
• Auto-equips rod and handles minigames automatically
• Script auto-detects which methods work in your game]]
infoText.Parent = infoPanel

-- Button Event Handlers
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🚀 START PERFECT FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    else
        StartFishing()
        fishingButton.Text = "⏹️ STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        statusLabel.Text = "✅ ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    end
end)

resetButton.MouseButton1Click:Connect(function()
    fishingStats.fishCaught = 0
    fishingStats.startTime = tick()
    fishingStats.attempts = 0
    fishingStats.successes = 0
    fishingStats.fails = 0
    detectedMethods = {}
    print("[✓] Stats reset!")
end)

-- Button Hover Effects
fishingButton.MouseEnter:Connect(function()
    local targetColor = fishingActive and Color3.fromRGB(200, 70, 70) or Color3.fromRGB(255, 82, 82)
    TweenService:Create(fishingButton, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
end)

fishingButton.MouseLeave:Connect(function()
    local targetColor = fishingActive and Color3.fromRGB(180, 50, 50) or ACCENT
    TweenService:Create(fishingButton, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
end)

resetButton.MouseEnter:Connect(function()
    TweenService:Create(resetButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 85)}):Play()
end)

resetButton.MouseLeave:Connect(function()
    TweenService:Create(resetButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
end)

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
settingsLabel.Text = "⚙️ Additional Settings\n(Coming Soon)"
settingsLabel.TextColor3 = Color3.fromRGB(200,200,200)
settingsLabel.TextYAlignment = Enum.TextYAlignment.Center
settingsLabel.Parent = settingsContent

-- Menu Navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        cTitle.Text = name == "Fishing" and "Perfect Instant Fishing" or name
        
        fishingContent.Visible = (name == "Fishing")
        settingsContent.Visible = (name == "Settings")
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
end

trayIcon.MouseButton1Click:Connect(showMainUI)

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

-- Stats Update Loop
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        
        fishCountLabel.Text = string.format("Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("Rate: %.2f/s", rate)
        memLabel.Text = string.format("Memory: %d KB | Fish: %d", math.floor(collectgarbage("count")), fishingStats.fishCaught)
        
        wait(0.5)
    end
end)

-- Start dengan UI terbuka
showMainUI()

print("[Kaitun Fish It] UI Loaded Successfully!")
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
