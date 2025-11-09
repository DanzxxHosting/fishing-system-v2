-- KANTUN FISH IT V2 - FISHING ONLY VERSION
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

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
local WIDTH = 800
local HEIGHT = 500
local ACCENT = Color3.fromRGB(255, 62, 62)
local BG = Color3.fromRGB(12,12,12)
local SECOND = Color3.fromRGB(24,24,26)

-- FISHING CONFIG
local fishingConfig = {
    autoFishing = false,
    instantFishing = true,
    fishingDelay = 0.1,
    blantantMode = false,
    perfectCast = true,
    autoReel = true
}

-- FISHING V2 CONFIG - 3x LEBIH CEPAT
local fishingV2Config = {
    enabled = false,
    smartDetection = true,
    antiAfk = true,
    radarEnabled = false,
    instantReel = true,
    castDelay = 0.3,
    reelDelay = 0.1
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    spotsFound = 0,
    instantCatches = 0,
    lastAction = "Idle"
}

local fishingActive = false
local fishingV2Active = false
local fishingConnection, v2Connection, radarConnection
local antiAfkTime = 0
local radarParts = {}

-- Cleanup old UI
if playerGui:FindFirstChild("FishingUI") then
    playerGui.FishingUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "FishingUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundColor3 = BG
container.Parent = screen

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = container

-- Outer glow
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+40, 0, HEIGHT+40)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = -1
glow.Parent = container

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = SECOND
titleBar.Parent = container

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = "🎣 KANTUN FISHING SCRIPT"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Tab buttons
local tabs = {"Fishing V1", "Fishing V2"}
local tabButtons = {}
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -30, 0, 40)
tabFrame.Position = UDim2.new(0, 15, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = container

for i, tabName in ipairs(tabs) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.48, 0, 1, 0)
    tab.Position = UDim2.new((i-1) * 0.5, 0, 0, 0)
    tab.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 10, 10) or Color3.fromRGB(30, 30, 30)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 14
    tab.Text = tabName
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.AutoButtonColor = false
    tab.Parent = tabFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tab
    
    tabButtons[tabName] = tab
end

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -30, 1, -110)
content.Position = UDim2.new(0, 15, 0, 100)
content.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
content.Parent = container

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = content

-- FISHING V1 CONTENT
local fishingV1Content = Instance.new("Frame")
fishingV1Content.Size = UDim2.new(1, 0, 1, 0)
fishingV1Content.BackgroundTransparency = 1
fishingV1Content.Visible = true
fishingV1Content.Parent = content

-- Stats
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -20, 0, 80)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(14,14,16)
statsFrame.Parent = fishingV1Content

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsFrame

local fishCountLabel = Instance.new("TextLabel")
fishCountLabel.Size = UDim2.new(0.5, -5, 0, 25)
fishCountLabel.Position = UDim2.new(0, 10, 0, 10)
fishCountLabel.BackgroundTransparency = 1
fishCountLabel.Font = Enum.Font.Gotham
fishCountLabel.TextSize = 12
fishCountLabel.Text = "🎣 Fish Caught: 0"
fishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
fishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
fishCountLabel.Parent = statsFrame

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Size = UDim2.new(0.5, -5, 0, 25)
attemptsLabel.Position = UDim2.new(0.5, 5, 0, 10)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.Font = Enum.Font.Gotham
attemptsLabel.TextSize = 12
attemptsLabel.Text = "🔄 Attempts: 0"
attemptsLabel.TextColor3 = Color3.fromRGB(255,220,200)
attemptsLabel.TextXAlignment = Enum.TextXAlignment.Left
attemptsLabel.Parent = statsFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Text = "⭕ Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(200,200,255)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statsFrame

-- Controls
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, -20, 0, 60)
controlsFrame.Position = UDim2.new(0, 10, 0, 100)
controlsFrame.BackgroundColor3 = Color3.fromRGB(14,14,16)
controlsFrame.Parent = fishingV1Content

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0, 6)
controlsCorner.Parent = controlsFrame

local fishingButton = Instance.new("TextButton")
fishingButton.Size = UDim2.new(0, 200, 0, 40)
fishingButton.Position = UDim2.new(0.5, -100, 0.5, -20)
fishingButton.BackgroundColor3 = ACCENT
fishingButton.Font = Enum.Font.GothamBold
fishingButton.TextSize = 14
fishingButton.Text = "🎣 START FISHING V1"
fishingButton.TextColor3 = Color3.fromRGB(30,30,30)
fishingButton.AutoButtonColor = false
fishingButton.Parent = controlsFrame

local fishingBtnCorner = Instance.new("UICorner")
fishingBtnCorner.CornerRadius = UDim.new(0, 6)
fishingBtnCorner.Parent = fishingButton

-- Settings
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, -20, 0, 180)
settingsFrame.Position = UDim2.new(0, 10, 0, 170)
settingsFrame.BackgroundColor3 = Color3.fromRGB(14,14,16)
settingsFrame.Parent = fishingV1Content

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -20, 0, 30)
settingsTitle.Position = UDim2.new(0, 10, 0, 5)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 14
settingsTitle.Text = "⚙️ FISHING SETTINGS"
settingsTitle.TextColor3 = Color3.fromRGB(235,235,235)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsFrame

-- Toggle function
local function CreateToggle(name, default, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 25)
    button.Position = UDim2.new(1, -50, 0.5, -12)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(30,30,30)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        callback(new)
    end)

    return frame
end

-- Create V1 Toggles
CreateToggle("⚡ Instant Fishing", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    print("[Fishing] Instant Fishing:", v and "ENABLED" or "DISABLED")
end, settingsFrame, 35)

CreateToggle("💥 Blatant Mode", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    print("[Fishing] Blatant Mode:", v and "ENABLED" or "DISABLED")
end, settingsFrame, 65)

CreateToggle("🎯 Perfect Cast", fishingConfig.perfectCast, function(v)
    fishingConfig.perfectCast = v
    print("[Fishing] Perfect Cast:", v and "ENABLED" or "DISABLED")
end, settingsFrame, 95)

CreateToggle("🔄 Auto Reel", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
    print("[Fishing] Auto Reel:", v and "ENABLED" or "DISABLED")
end, settingsFrame, 125)

-- FISHING V2 CONTENT
local fishingV2Content = Instance.new("Frame")
fishingV2Content.Size = UDim2.new(1, 0, 1, 0)
fishingV2Content.BackgroundTransparency = 1
fishingV2Content.Visible = false
fishingV2Content.Parent = content

-- V2 Stats
local v2StatsFrame = Instance.new("Frame")
v2StatsFrame.Size = UDim2.new(1, -20, 0, 100)
v2StatsFrame.Position = UDim2.new(0, 10, 0, 10)
v2StatsFrame.BackgroundColor3 = Color3.fromRGB(14,14,16)
v2StatsFrame.Parent = fishingV2Content

local v2StatsCorner = Instance.new("UICorner")
v2StatsCorner.CornerRadius = UDim.new(0, 6)
v2StatsCorner.Parent = v2StatsFrame

local v2FishCountLabel = Instance.new("TextLabel")
v2FishCountLabel.Size = UDim2.new(0.5, -5, 0, 25)
v2FishCountLabel.Position = UDim2.new(0, 10, 0, 10)
v2FishCountLabel.BackgroundTransparency = 1
v2FishCountLabel.Font = Enum.Font.Gotham
v2FishCountLabel.TextSize = 12
v2FishCountLabel.Text = "🎣 Total Fish: 0"
v2FishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
v2FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
v2FishCountLabel.Parent = v2StatsFrame

local v2InstantLabel = Instance.new("TextLabel")
v2InstantLabel.Size = UDim2.new(0.5, -5, 0, 25)
v2InstantLabel.Position = UDim2.new(0.5, 5, 0, 10)
v2InstantLabel.BackgroundTransparency = 1
v2InstantLabel.Font = Enum.Font.Gotham
v2InstantLabel.TextSize = 12
v2InstantLabel.Text = "⚡ Instant: 0"
v2InstantLabel.TextColor3 = Color3.fromRGB(255,215,0)
v2InstantLabel.TextXAlignment = Enum.TextXAlignment.Left
v2InstantLabel.Parent = v2StatsFrame

local v2StatusLabel = Instance.new("TextLabel")
v2StatusLabel.Size = UDim2.new(1, -20, 0, 25)
v2StatusLabel.Position = UDim2.new(0, 10, 0, 40)
v2StatusLabel.BackgroundTransparency = 1
v2StatusLabel.Font = Enum.Font.Gotham
v2StatusLabel.TextSize = 12
v2StatusLabel.Text = "🤖 AI Status: Offline"
v2StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
v2StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2StatusLabel.Parent = v2StatsFrame

local v2SpeedLabel = Instance.new("TextLabel")
v2SpeedLabel.Size = UDim2.new(1, -20, 0, 25)
v2SpeedLabel.Position = UDim2.new(0, 10, 0, 70)
v2SpeedLabel.BackgroundTransparency = 1
v2SpeedLabel.Font = Enum.Font.GothamBold
v2SpeedLabel.TextSize = 12
v2SpeedLabel.Text = "⚡ SPEED: 3x FASTER THAN V1"
v2SpeedLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
v2SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
v2SpeedLabel.Parent = v2StatsFrame

-- V2 Controls
local v2ControlsFrame = Instance.new("Frame")
v2ControlsFrame.Size = UDim2.new(1, -20, 0, 60)
v2ControlsFrame.Position = UDim2.new(0, 10, 0, 120)
v2ControlsFrame.BackgroundColor3 = Color3.fromRGB(14,14,16)
v2ControlsFrame.Parent = fishingV2Content

local v2ControlsCorner = Instance.new("UICorner")
v2ControlsCorner.CornerRadius = UDim.new(0, 6)
v2ControlsCorner.Parent = v2ControlsFrame

local v2FishingButton = Instance.new("TextButton")
v2FishingButton.Size = UDim2.new(0, 200, 0, 40)
v2FishingButton.Position = UDim2.new(0.5, -100, 0.5, -20)
v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
v2FishingButton.Font = Enum.Font.GothamBold
v2FishingButton.TextSize = 14
v2FishingButton.Text = "🤖 START AI FISHING"
v2FishingButton.TextColor3 = Color3.fromRGB(30,30,30)
v2FishingButton.AutoButtonColor = false
v2FishingButton.Parent = v2ControlsFrame

local v2FishingBtnCorner = Instance.new("UICorner")
v2FishingBtnCorner.CornerRadius = UDim.new(0, 6)
v2FishingBtnCorner.Parent = v2FishingButton

-- V2 Settings
local v2SettingsFrame = Instance.new("Frame")
v2SettingsFrame.Size = UDim2.new(1, -20, 0, 150)
v2SettingsFrame.Position = UDim2.new(0, 10, 0, 190)
v2SettingsFrame.BackgroundColor3 = Color3.fromRGB(14,14,16)
v2SettingsFrame.Parent = fishingV2Content

local v2SettingsCorner = Instance.new("UICorner")
v2SettingsCorner.CornerRadius = UDim.new(0, 6)
v2SettingsCorner.Parent = v2SettingsFrame

local v2SettingsTitle = Instance.new("TextLabel")
v2SettingsTitle.Size = UDim2.new(1, -20, 0, 30)
v2SettingsTitle.Position = UDim2.new(0, 10, 0, 5)
v2SettingsTitle.BackgroundTransparency = 1
v2SettingsTitle.Font = Enum.Font.GothamBold
v2SettingsTitle.TextSize = 14
v2SettingsTitle.Text = "⚙️ AI FISHING SETTINGS"
v2SettingsTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
v2SettingsTitle.Parent = v2SettingsFrame

-- Create V2 Toggles
CreateToggle("🤖 AI System", fishingV2Config.enabled, function(v)
    fishingV2Config.enabled = v
    print("[Fishing V2] AI System:", v and "ENABLED" or "DISABLED")
end, v2SettingsFrame, 35)

CreateToggle("⚡ Instant Reel", fishingV2Config.instantReel, function(v)
    fishingV2Config.instantReel = v
    print("[Fishing V2] Instant Reel:", v and "ENABLED" or "DISABLED")
end, v2SettingsFrame, 65)

CreateToggle("📡 Fishing Radar", fishingV2Config.radarEnabled, function(v)
    fishingV2Config.radarEnabled = v
    if v and fishingV2Active then
        StartRadar()
    else
        StopRadar()
    end
    print("[Fishing V2] Fishing Radar:", v and "ENABLED" or "DISABLED")
end, v2SettingsFrame, 95)

CreateToggle("🛡️ Anti-AFK", fishingV2Config.antiAfk, function(v)
    fishingV2Config.antiAfk = v
    print("[Fishing V2] Anti-AFK:", v and "ENABLED" or "DISABLED")
end, v2SettingsFrame, 125)

-- ═══════════════════════════════════════════════════════════
-- FISHING FUNCTIONS
-- ═══════════════════════════════════════════════════════════

-- IMPROVED FISHING PROMPT DETECTION
local function FindFishingPrompt()
    -- Method 1: Check workspace for ANY proximity prompts
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            local actionText = descendant.ActionText and string.lower(descendant.ActionText) or ""
            local objectText = descendant.ObjectText and string.lower(descendant.ObjectText) or ""
            
            if actionText:find("fish") or actionText:find("cast") or actionText:find("angle") or 
               objectText:find("fish") or objectText:find("cast") or objectText:find("angle") then
                return descendant
            end
        end
    end
    
    -- Method 2: Check character
    local character = player.Character
    if character then
        for _, descendant in pairs(character:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                return descendant
            end
        end
    end
    
    -- Method 3: Check GUI buttons
    local playerGui = player:WaitForChild("PlayerGui")
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Visible then
            local text = gui.Text and string.lower(gui.Text) or ""
            if text:find("fish") or text:find("cast") or text:find("reel") then
                return gui
            end
        end
    end
    
    return nil
end

-- IMPROVED FISHING ACTION
local function PerformFishingAction()
    local prompt = FindFishingPrompt()
    
    if prompt then
        if prompt:IsA("ProximityPrompt") then
            fireproximityprompt(prompt)
            fishingStats.lastAction = "ProximityPrompt"
            return true
        elseif prompt:IsA("TextButton") then
            pcall(function() prompt:FireServer() end)
            pcall(function() prompt:FireServer("Cast") end)
            pcall(function() prompt:FireServer("Fish") end)
            fishingStats.lastAction = "GUI Button"
            return true
        end
    end
    
    -- Try remote events
    if ReplicatedStorage then
        for _, item in pairs(ReplicatedStorage:GetDescendants()) do
            if item:IsA("RemoteEvent") then
                local name = string.lower(item.Name)
                if name:find("fish") or name:find("cast") then
                    pcall(function() item:FireServer() end)
                    pcall(function() item:FireServer("Cast") end)
                    fishingStats.lastAction = "RemoteEvent"
                    return true
                end
            end
        end
    end
    
    fishingStats.lastAction = "No fishing method found"
    return false
end

-- FISH DETECTION
local function DetectFishCaught()
    local playerGui = player:WaitForChild("PlayerGui")
    
    for _, gui in pairs(playerGui:GetDescendants()) do
        if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible then
            local text = gui.Text and string.lower(gui.Text) or ""
            if text:find("caught") or text:find("success") or text:find("!") then
                return true
            end
        end
    end
    
    return false
end

-- FISHING V1
local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting V1"
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        fishingStats.attempts = fishingStats.attempts + 1
        
        local success = PerformFishingAction()
        
        if success then
            fishingStats.lastAction = "Fishing Attempt #" .. fishingStats.attempts
            
            local waitTime = fishingConfig.blantantMode and 0.3 or 
                           fishingConfig.instantFishing and 0.5 or 1.0
            task.wait(waitTime)
            
            if DetectFishCaught() then
                fishingStats.fishCaught = fishingStats.fishCaught + 1
                fishingStats.instantCatches = fishingStats.instantCatches + 1
                fishingStats.lastAction = "FISH CAUGHT! Total: " .. fishingStats.fishCaught
            end
        else
            fishingStats.lastAction = "Searching for spot..."
            if fishingStats.attempts % 10 == 0 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end
        end
        
        -- Anti-AFK
        if fishingStats.attempts % 30 == 0 then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
        end
    end)
end

local function StopFishing()
    fishingActive = false
    fishingStats.lastAction = "V1 Stopped"
    
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
end

-- FISHING V2 (3x FASTER)
local function StartFishingV2()
    if fishingV2Active then return end
    
    fishingV2Active = true
    fishingStats.startTime = tick()
    fishingStats.lastAction = "Starting AI V2"
    
    local lastCastTime = 0
    
    v2Connection = RunService.Heartbeat:Connect(function()
        if not fishingV2Active then return end
        
        local currentTime = tick()
        
        if currentTime - lastCastTime >= fishingV2Config.castDelay then
            fishingStats.attempts = fishingStats.attempts + 1
            
            local success = PerformFishingAction()
            
            if success then
                fishingStats.lastAction = "AI Casting #" .. fishingStats.attempts
                lastCastTime = currentTime
                
                task.wait(fishingV2Config.reelDelay)
                
                if fishingV2Config.instantReel then
                    PerformFishingAction()
                    task.wait(0.2)
                    
                    if DetectFishCaught() then
                        fishingStats.fishCaught = fishingStats.fishCaught + 1
                        fishingStats.instantCatches = fishingStats.instantCatches + 1
                        fishingStats.lastAction = "AI CAUGHT FISH! Total: " .. fishingStats.fishCaught
                    end
                end
            else
                fishingStats.lastAction = "AI Searching..."
                if fishingStats.attempts % 5 == 0 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                end
            end
        end
        
        -- Anti-AFK
        antiAfkTime = antiAfkTime + 1
        if antiAfkTime >= 15 and fishingV2Config.antiAfk then
            antiAfkTime = 0
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end
    end)
end

local function StopFishingV2()
    fishingV2Active = false
    fishingStats.lastAction = "AI V2 Stopped"
    
    if v2Connection then
        v2Connection:Disconnect()
        v2Connection = nil
    end
    
    StopRadar()
end

-- RADAR SYSTEM
local function StartRadar()
    if not fishingV2Config.radarEnabled then return end
    
    StopRadar()
    
    radarConnection = RunService.Heartbeat:Connect(function()
        if not fishingV2Config.radarEnabled then 
            StopRadar()
            return 
        end
        
        for _, part in pairs(radarParts) do
            if part then part:Destroy() end
        end
        radarParts = {}
        
        local spotCount = 0
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") then
                local name = string.lower(part.Name)
                if name:find("water") or name:find("pond") or name:find("lake") then
                    local radarPart = Instance.new("Part")
                    radarPart.Size = Vector3.new(4, 4, 4)
                    radarPart.Position = part.Position + Vector3.new(0, 8, 0)
                    radarPart.Anchored = true
                    radarPart.CanCollide = false
                    radarPart.Material = Enum.Material.Neon
                    radarPart.BrickColor = BrickColor.new("Bright blue")
                    radarPart.Transparency = 0.4
                    radarPart.Parent = Workspace
                    
                    table.insert(radarParts, radarPart)
                    spotCount = spotCount + 1
                    
                    if spotCount >= 8 then break end
                end
            end
        end
        
        fishingStats.spotsFound = #radarParts
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
    radarParts = {}
    fishingStats.spotsFound = 0
end

-- ═══════════════════════════════════════════════════════════
-- EVENT HANDLERS
-- ═══════════════════════════════════════════════════════════

-- Fishing V1 Button
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🎣 START FISHING V1"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ Status: Stopped"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishing()
        fishingButton.Text = "⏹️ STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        statusLabel.Text = "✅ Status: Fishing Active"
        statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end)

-- Fishing V2 Button
v2FishingButton.MouseButton1Click:Connect(function()
    if fishingV2Active then
        StopFishingV2()
        v2FishingButton.Text = "🤖 START AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        v2StatusLabel.Text = "🤖 AI Status: Offline"
        v2StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishingV2()
        v2FishingButton.Text = "⏹️ STOP AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        v2StatusLabel.Text = "✅ AI Status: Active"
        v2StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end)

-- Tab navigation
for tabName, tab in pairs(tabButtons) do
    tab.MouseButton1Click:Connect(function()
        for name, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = name == tabName and Color3.fromRGB(40, 10, 10) or Color3.fromRGB(30, 30, 30)
        end
        
        fishingV1Content.Visible = (tabName == "Fishing V1")
        fishingV2Content.Visible = (tabName == "Fishing V2")
    end)
end

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- Stats update loop
spawn(function()
    while screen.Parent do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        
        -- Update V1 Stats
        fishCountLabel.Text = string.format("🎣 Fish Caught: %d", fishingStats.fishCaught)
        attemptsLabel.Text = string.format("🔄 Attempts: %d", fishingStats.attempts)
        statusLabel.Text = string.format("📊 Status: %s", fishingStats.lastAction)
        
        -- Update V2 Stats
        v2FishCountLabel.Text = string.format("🎣 Total Fish: %d", fishingStats.fishCaught)
        v2InstantLabel.Text = string.format("⚡ Instant: %d", fishingStats.instantCatches)
        v2StatusLabel.Text = string.format("🤖 AI Status: %s", fishingV2Active and "Active" or "Offline")
        
        wait(0.5)
    end
end)

print("[Kantun Fishing] Simplified Fishing Script Loaded!")
print("🎣 Fishing V1 - Basic automatic fishing")
print("🚀 Fishing V2 - AI fishing (3x FASTER)")
print("✅ Ready to use!")
