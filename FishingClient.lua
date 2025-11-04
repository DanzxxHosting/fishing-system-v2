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
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- ULTRA FAST FISHING CONFIG
local fishingConfig = {
    autoFishing = false,
    instantFishing = true,
    fishingDelay = 0.0002, -- 5x lebih cepat (dari 0.001)
    blantantMode = false,
    ultraSpeed = true, -- Mode ultra speed baru
    perfectCast = true,
    autoReel = true,
    bypassDetection = true,
    multiThread = true -- Multi-threading untuk kecepatan maksimal
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
-- ULTRA FAST FISHING FUNCTIONS (5x LEBIH CEPAT)
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
                task.wait(0.05)
                return true
            end
        end
        
        return rod.Parent == player.Character
    end)
    
    return success
end

-- PERFECT CAST FUNCTIONS
local function EnablePerfectCast()
    local success = pcall(function()
        -- Method 1: Remote untuk perfect cast
        if ReplicatedStorage then
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local name = remote.Name:lower()
                    if name:find("perfect") or name:find("accuracy") or name:find("precision") then
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(true)
                            remote:FireServer("Perfect")
                            remote:FireServer("Enable")
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(true)
                            remote:InvokeServer("Perfect")
                            remote:InvokeServer("Enable")
                        end
                    end
                end
            end
        end

        -- Method 2: Virtual input untuk timing sempurna
        spawn(function()
            while fishingConfig.perfectCast and fishingActive do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                task.wait(0.3)
            end
        end)

        return true
    end)
    
    return success
end

local function DisablePerfectCast()
    pcall(function()
        -- Disable via remotes
        if ReplicatedStorage then
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local name = remote.Name:lower()
                    if name:find("perfect") or name:find("accuracy") then
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(false)
                            remote:FireServer("Normal")
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(false)
                            remote:InvokeServer("Normal")
                        end
                    end
                end
            end
        end
    end)
end

-- ULTRA FAST FISHING METHODS
local function UltraFastFishProximity()
    local success = pcall(function()
        local char = SafeGetCharacter()
        if not char then return false end
        
        local prompts = {}
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                table.insert(prompts, descendant)
            end
        end
        
        for _, prompt in ipairs(prompts) do
            spawn(function()
                for i = 1, 10 do
                    fireproximityprompt(prompt)
                    task.wait(0.0001)
                end
            end)
        end
        
        return #prompts > 0
    end)
    
    return success
end

local function UltraFastFishRemote()
    local success = pcall(function()
        if not ReplicatedStorage then return false end
        
        local remotes = {}
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                local name = remote.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("catch") or name:find("reel") then
                    table.insert(remotes, remote)
                end
            end
        end
        
        for _, remote in ipairs(remotes) do
            spawn(function()
                local commands = {"Cast", "Reel", "Catch", "Fish", "Start", "Pull", "Hook"}
                for _, cmd in ipairs(commands) do
                    if remote:IsA("RemoteEvent") then
                        for i = 1, 5 do
                            remote:FireServer(cmd)
                            remote:FireServer(cmd, true)
                            remote:FireServer(cmd, 1.0)
                            task.wait(0.0001)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        for i = 1, 3 do
                            pcall(function() remote:InvokeServer(cmd) end)
                            pcall(function() remote:InvokeServer(cmd, true) end)
                            task.wait(0.0001)
                        end
                    end
                end
            end)
        end
        
        return #remotes > 0
    end)
    
    return success
end

local function UltraFastVirtualInput()
    pcall(function()
        local fishingKeys = {
            Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.R, 
            Enum.KeyCode.Space, Enum.KeyCode.Q, Enum.KeyCode.X,
            Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.Z
        }
        
        for i = 1, 15 do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.0001)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.0001)
        end
        
        for _, key in ipairs(fishingKeys) do
            spawn(function()
                for i = 1, 8 do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.0001)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    task.wait(0.0001)
                end
            end)
        end
    end)
    
    return true
end

local function UltraFastClickDetector()
    local success = pcall(function()
        local rod = GetFishingRod()
        if not rod then return false end
        
        local handle = rod:FindFirstChild("Handle")
        if not handle then return false end
        
        local clickDetector = handle:FindFirstChild("ClickDetector")
        if clickDetector then
            for i = 1, 20 do
                fireclickdetector(clickDetector)
                task.wait(0.0001)
            end
            return true
        end
        
        return false
    end)
    
    return success
end

local function UltraFastUIButtons()
    local success = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local buttons = {}
        
        for _, gui in pairs(playerGui:GetDescendants()) do
            if (gui:IsA("ImageButton") or gui:IsA("TextButton")) and gui.Visible then
                local name = gui.Name:lower()
                local text = gui.Text and gui.Text:lower() or ""
                
                if name:find("fish") or name:find("cast") or name:find("reel") or 
                   name:find("catch") or text:find("fish") or text:find("cast") or
                   text:find("reel") or text:find("catch") then
                    table.insert(buttons, gui)
                end
            end
        end
        
        for _, button in ipairs(buttons) do
            spawn(function()
                for i = 1, 25 do
                    pcall(function() button.Activated:Fire() end)
                    task.wait(0.0001)
                end
            end)
        end
        
        return #buttons > 0
    end)
    
    return success
end

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
                            task.wait(0.0005)
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

-- MASTER ULTRA FAST FISHING FUNCTION
local function UltraFastInstantFish()
    if not fishingActive then return end
    
    fishingStats.attempts = fishingStats.attempts + 1
    
    if not EquipRod() then
        return
    end

    if fishingConfig.perfectCast then
        EnablePerfectCast()
    end

    local success = false
    
    if fishingConfig.ultraSpeed then
        spawn(function() if UltraFastFishProximity() then success = true end end)
        spawn(function() if UltraFastFishRemote() then success = true end end)
        spawn(function() if UltraFastVirtualInput() then success = true end end)
        spawn(function() if UltraFastClickDetector() then success = true end end)
        spawn(function() if UltraFastUIButtons() then success = true end end)
        
        task.wait(0.001)
        
    elseif fishingConfig.instantFishing or fishingConfig.blantantMode then
        if UltraFastFishProximity() then success = true end
        if UltraFastFishRemote() then success = true end
        if UltraFastVirtualInput() then success = true end
        if UltraFastClickDetector() then success = true end
        
        if fishingConfig.autoReel then
            AutoReelFish()
        end
    end
    
    if success then
        fishingStats.fishCaught = fishingStats.fishCaught + 1
    end
end

-- ULTRA FAST FISHING START FUNCTION
local function StartUltraFastFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    
    print("[Fishing] 🚀 STARTING ULTRA FAST FISHING (5x SPEED)")
    print("[Fishing] Delay:", fishingConfig.fishingDelay)
    print("[Fishing] Multi-Thread:", fishingConfig.multiThread)
    
    if fishingConfig.perfectCast then
        EnablePerfectCast()
    end
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        if fishingConfig.multiThread then
            for i = 1, 3 do
                spawn(function()
                    pcall(UltraFastInstantFish)
                end)
            end
        else
            pcall(UltraFastInstantFish)
        end
        
        if fishingConfig.ultraSpeed then
            task.wait(0.0002)
        elseif fishingConfig.blantantMode then
            task.wait(0.001)
        else
            task.wait(fishingConfig.fishingDelay)
        end
    end)
    
    if fishingConfig.autoReel then
        reelConnection = RunService.RenderStepped:Connect(function()
            if not fishingActive then return end
            for i = 1, 3 do
                pcall(AutoReelFish)
            end
        end)
    end
    
    if fishingConfig.ultraSpeed then
        spawn(function()
            while fishingActive do
                pcall(UltraFastVirtualInput)
                task.wait(0.01)
            end
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
fishingButton.Text = "🚀 START ULTRA FAST FISHING"
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
togglesPanel.Size = UDim2.new(1, 0, 0, 240)
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
togglesTitle.Text = "🔧 Ultra Fast Fishing Settings"
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

-- Create ULTRA FAST Toggles
CreateToggle("⚡ Ultra Speed", "5x faster multi-thread fishing", fishingConfig.ultraSpeed, function(v)
    fishingConfig.ultraSpeed = v
    if v then
        fishingConfig.fishingDelay = 0.0002
        fishingConfig.multiThread = true
        fishingConfig.instantFishing = true
        print("[Fishing] ⚡ ULTRA SPEED: ENABLED (5x Faster)")
    else
        fishingConfig.fishingDelay = 0.1
        fishingConfig.multiThread = false
        print("[Fishing] Ultra Speed: DISABLED")
    end
end, togglesPanel, 36)

CreateToggle("💥 Blatant Mode", "3x faster fishing", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then
        fishingConfig.fishingDelay = 0.001
        fishingConfig.instantFishing = true
        fishingConfig.ultraSpeed = false
        print("[Fishing] Blatant Mode: ENABLED (0.001s delay)")
    else
        fishingConfig.fishingDelay = 0.1
        print("[Fishing] Blatant Mode: DISABLED")
    end
end, togglesPanel, 76)

CreateToggle("🎯 Perfect Cast", "Always perfect casting", fishingConfig.perfectCast, function(v)
    fishingConfig.perfectCast = v
    if v then
        EnablePerfectCast()
        print("[Fishing] Perfect Cast: ENABLED")
    else
        DisablePerfectCast()
        print("[Fishing] Perfect Cast: DISABLED")
    end
end, togglesPanel, 116)

CreateToggle("🔄 Auto Reel", "Auto reel minigame", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
    print("[Fishing] Auto Reel:", v and "ENABLED" or "DISABLED")
end, togglesPanel, 156)

CreateToggle("🧵 Multi-Thread", "Parallel execution for max speed", fishingConfig.multiThread, function(v)
    fishingConfig.multiThread = v
    if v then
        fishingConfig.ultraSpeed = true
        print("[Fishing] Multi-Thread: ENABLED - Maximum performance")
    else
        print("[Fishing] Multi-Thread: DISABLED")
    end
end, togglesPanel, 196)

-- Fishing Button Handler
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🚀 START ULTRA FAST FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartUltraFastFishing()
        fishingButton.Text = "⏹️ STOP ULTRA FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        statusLabel.Text = "⚡ ULTRA FAST ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
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
local activeMenu = "Fishing"
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

-- Highlight fishing menu by default
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

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
        
        fishCountLabel.Text = string.format("Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("Rate: %.2f/s", rate)
        
        local speedStatus = ""
        if fishingConfig.ultraSpeed then
            speedStatus = " | ⚡ ULTRA SPEED"
        elseif fishingConfig.blantantMode then
            speedStatus = " | 💥 FAST"
        else
            speedStatus = " | 🐢 NORMAL"
        end
        
        memLabel.Text = string.format("Memory: %d KB | Fish: %d%s", 
            math.floor(collectgarbage("count")), fishingStats.fishCaught, speedStatus)
        
        wait(0.3)
    end
end)

-- Start dengan UI terbuka
showMainUI()

print("[Kaitun Fish It] 🚀 ULTRA FAST FISHING LOADED!")
print("⚡ Ultra Speed Mode: 5x Faster Fishing")
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
