-- UI-Only: Neon Panel dengan Tray Icon + Enhanced Instant Fishing + FISHING V2 FIXED
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

-- ... [UI Setup Code Tetap Sama] ...
-- Untuk menghemat space, saya skip bagian UI setup yang sama
-- dan fokus pada perbaikan fungsi fishing V2

-- ═══════════════════════════════════════════════════════════
-- FISHING V2 FIXED FUNCTIONS - DIPERBAIKI UNTUK FISH IT
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

-- FIXED FISHING DETECTION untuk Fish It
local function FindFishingProximityPrompt()
    local char = player.Character
    if not char then return nil end
    
    -- Cari ProximityPrompt di character (untuk fishing)
    for _, descendant in pairs(char:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
            local objectText = descendant.ObjectText and descendant.ObjectText:lower() or ""
            
            if actionText:find("cast") or actionText:find("fish") or 
               objectText:find("cast") or objectText:find("fish") then
                return descendant
            end
        end
    end
    return nil
end

-- FIXED INSTANT REEL DETECTION untuk Fish It
local function DetectFishBite()
    if not fishingV2Config.instantReel then return false end
    
    local success, result = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Cari tanda seru (!) atau indikator bite di ScreenGui
        for _, guiObject in pairs(playerGui:GetDescendants()) do
            if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
                local text = guiObject.Text or ""
                local name = guiObject.Name:lower()
                
                -- Deteksi tanda seru atau teks fishing related
                if text:find("!") or text:find("Bite") or text:find("PULL") or 
                   name:find("bite") or name:find("pull") or name:find("catch") then
                    if guiObject.Visible then
                        print("[Fishing V2] Fish bite detected! -", text)
                        return true
                    end
                end
            end
            
            -- Cari ImageLabel dengan gambar fishing related
            if guiObject:IsA("ImageLabel") then
                local name = guiObject.Name:lower()
                if name:find("bite") or name:find("fish") or name:find("catch") then
                    if guiObject.Visible then
                        print("[Fishing V2] Fishing UI detected!")
                        return true
                    end
                end
            end
        end
        
        return false
    end)
    
    return success and result or false
end

-- FIXED FISHING ACTION untuk Fish It
local function PerformFishingCast()
    local prompt = FindFishingProximityPrompt()
    if prompt and prompt.Enabled then
        fireproximityprompt(prompt)
        fishingStats.lastAction = "Casting"
        print("[Fishing V2] Casting fishing rod...")
        return true
    end
    return false
end

local function PerformFishingReel()
    local prompt = FindFishingProximityPrompt()
    if prompt and prompt.Enabled then
        fireproximityprompt(prompt)
        fishingStats.lastAction = "Reeling"
        print("[Fishing V2] Reeling fish...")
        return true
    end
    return false
end

-- FIXED ANTI-AFK SYSTEM
local function AntiAFK()
    if not fishingV2Config.antiAfk then return end
    
    antiAfkTime = antiAfkTime + 1
    if antiAfkTime >= 45 then -- Reset setiap 45 detik
        antiAfkTime = 0
        
        -- Gerakkan mouse sedikit
        pcall(function()
            local currentPos = Vector2.new(100, 100)
            VirtualInputManager:SendMouseMoveEvent(100, 100, Workspace)
            task.wait(0.1)
            VirtualInputManager:SendMouseMoveEvent(150, 150, Workspace)
            task.wait(0.1)
            VirtualInputManager:SendMouseMoveEvent(100, 100, Workspace)
        end)
        
        print("[Anti-AFK] Anti-AFK action performed")
    end
end

-- FIXED FISHING V2 MAIN LOOP - DIPERBAIKI UNTUK FISH IT
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
        
        -- Anti-AFK
        AntiAFK()
        
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
-- FISHING V2 UI CONTENT - DIPERBAIKI
-- ═══════════════════════════════════════════════════════════

local fishingV2Content = Instance.new("ScrollingFrame")
fishingV2Content.Name = "FishingV2Content"
fishingV2Content.Size = UDim2.new(1, -24, 1, -24)
fishingV2Content.Position = UDim2.new(0, 12, 0, 12)
fishingV2Content.BackgroundTransparency = 1
fishingV2Content.Visible = false
fishingV2Content.ScrollBarThickness = 6
fishingV2Content.ScrollBarImageColor3 = ACCENT
fishingV2Content.CanvasSize = UDim2.new(0, 0, 0, 650)
fishingV2Content.Parent = content

-- Container for V2 content
local v2ContentContainer = Instance.new("Frame")
v2ContentContainer.Name = "V2ContentContainer"
v2ContentContainer.Size = UDim2.new(1, 0, 0, 650)
v2ContentContainer.BackgroundTransparency = 1
v2ContentContainer.Parent = fishingV2Content

-- V2 Stats Panel
local v2StatsPanel = Instance.new("Frame")
v2StatsPanel.Size = UDim2.new(1, 0, 0, 140) -- Increased height
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
v2StatsTitle.Text = "🚀 FISH IT - AI FISHING STATS"
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

local v2InstantLabel = Instance.new("TextLabel")
v2InstantLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2InstantLabel.Position = UDim2.new(0.5,4,0,40)
v2InstantLabel.BackgroundTransparency = 1
v2InstantLabel.Font = Enum.Font.Gotham
v2InstantLabel.TextSize = 13
v2InstantLabel.Text = "Instant Catches: 0"
v2InstantLabel.TextColor3 = Color3.fromRGB(255,215,0)
v2InstantLabel.TextXAlignment = Enum.TextXAlignment.Left
v2InstantLabel.Parent = v2StatsPanel

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

local v2StatusLabel = Instance.new("TextLabel")
v2StatusLabel.Size = UDim2.new(0.5, -8, 0, 24)
v2StatusLabel.Position = UDim2.new(0.5,4,0,68)
v2StatusLabel.BackgroundTransparency = 1
v2StatusLabel.Font = Enum.Font.Gotham
v2StatusLabel.TextSize = 13
v2StatusLabel.Text = "Status: Idle"
v2StatusLabel.TextColor3 = Color3.fromRGB(255,200,255)
v2StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2StatusLabel.Parent = v2StatsPanel

local v2EfficiencyLabel = Instance.new("TextLabel")
v2EfficiencyLabel.Size = UDim2.new(1, -24, 0, 24)
v2EfficiencyLabel.Position = UDim2.new(0,12,0,96)
v2EfficiencyLabel.BackgroundTransparency = 1
v2EfficiencyLabel.Font = Enum.Font.Gotham
v2EfficiencyLabel.TextSize = 13
v2EfficiencyLabel.Text = "Efficiency: 0% | Last Action: None"
v2EfficiencyLabel.TextColor3 = Color3.fromRGB(200,255,255)
v2EfficiencyLabel.TextXAlignment = Enum.TextXAlignment.Left
v2EfficiencyLabel.Parent = v2StatsPanel

local v2AFKLabel = Instance.new("TextLabel")
v2AFKLabel.Size = UDim2.new(1, -24, 0, 24)
v2AFKLabel.Position = UDim2.new(0,12,0,120)
v2AFKLabel.BackgroundTransparency = 1
v2AFKLabel.Font = Enum.Font.Gotham
v2AFKLabel.TextSize = 13
v2AFKLabel.Text = "Anti-AFK: 0s | Cast Delay: 2s | Reel Delay: 0.5s"
v2AFKLabel.TextColor3 = Color3.fromRGB(180,180,255)
v2AFKLabel.TextXAlignment = Enum.TextXAlignment.Left
v2AFKLabel.Parent = v2StatsPanel

-- V2 Controls Panel
local v2ControlsPanel = Instance.new("Frame")
v2ControlsPanel.Size = UDim2.new(1, 0, 0, 100)
v2ControlsPanel.Position = UDim2.new(0, 0, 0, 152)
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
v2ControlsTitle.Text = "🎮 AI FISHING CONTROLS"
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
local v2ActiveStatusLabel = Instance.new("TextLabel")
v2ActiveStatusLabel.Size = UDim2.new(0.5, -16, 0, 50)
v2ActiveStatusLabel.Position = UDim2.new(0, 224, 0, 40)
v2ActiveStatusLabel.BackgroundTransparency = 1
v2ActiveStatusLabel.Font = Enum.Font.GothamBold
v2ActiveStatusLabel.TextSize = 12
v2ActiveStatusLabel.Text = "⭕ AI OFFLINE"
v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
v2ActiveStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
v2ActiveStatusLabel.Parent = v2ControlsPanel

-- V2 Features Panel
local v2FeaturesPanel = Instance.new("Frame")
v2FeaturesPanel.Size = UDim2.new(1, 0, 0, 280)
v2FeaturesPanel.Position = UDim2.new(0, 0, 0, 264)
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
v2FeaturesTitle.Text = "⚙️ FISH IT AI SETTINGS"
v2FeaturesTitle.TextColor3 = Color3.fromRGB(235,235,235)
v2FeaturesTitle.TextXAlignment = Enum.TextXAlignment.Left
v2FeaturesTitle.Parent = v2FeaturesPanel

-- Toggle Helper Function untuk V2
local function CreateV2Toggle(name, desc, default, callback, parent, yPos)
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

-- Create V2 Toggles dengan settings yang sesuai untuk Fish It
CreateV2Toggle("🤖 AI Fishing System", "Enable automatic fishing", fishingV2Config.enabled, function(v)
    fishingV2Config.enabled = v
    if v and fishingV2Active then
        StopFishingV2()
    end
    print("[Fishing V2] AI System:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 36)

CreateV2Toggle("⚡ Instant Reel", "Auto reel when ! appears", fishingV2Config.instantReel, function(v)
    fishingV2Config.instantReel = v
    print("[Fishing V2] Instant Reel:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 76)

CreateV2Toggle("📡 Fishing Radar", "Show nearby fishing spots", fishingV2Config.radarEnabled, function(v)
    fishingV2Config.radarEnabled = v
    if v and fishingV2Active then
        StartRadar()
    else
        StopRadar()
    end
    print("[Fishing V2] Fishing Radar:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 116)

CreateV2Toggle("🛡️ Anti-AFK", "Prevent AFK detection", fishingV2Config.antiAfk, function(v)
    fishingV2Config.antiAfk = v
    print("[Fishing V2] Anti-AFK:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 156)

CreateV2Toggle("🎯 Smart Detection", "Auto-detect fishing prompts", fishingV2Config.smartDetection, function(v)
    fishingV2Config.smartDetection = v
    print("[Fishing V2] Smart Detection:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 196)

CreateV2Toggle("🔧 Proximity Only", "Use only proximity prompts", fishingV2Config.useProximityOnly, function(v)
    fishingV2Config.useProximityOnly = v
    print("[Fishing V2] Proximity Only:", v and "ENABLED" or "DISABLED")
end, v2FeaturesPanel, 236)

-- V2 Fishing Button Handler
v2FishingButton.MouseButton1Click:Connect(function()
    if fishingV2Active then
        StopFishingV2()
        v2FishingButton.Text = "🤖 START AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        v2ActiveStatusLabel.Text = "⭕ AI OFFLINE"
        v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        StartFishingV2()
        v2FishingButton.Text = "⏹️ STOP AI FISHING"
        v2FishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        v2ActiveStatusLabel.Text = "✅ AI FISHING ACTIVE"
        v2ActiveStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

-- Update stats loop untuk V2
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        local efficiency = fishingStats.fishCaught / math.max(1, fishingStats.attempts) * 100
        
        -- Update V2 Stats
        v2FishCountLabel.Text = string.format("Total Fish: %d", fishingStats.fishCaught)
        v2InstantLabel.Text = string.format("Instant Catches: %d", fishingStats.instantCatches)
        v2SpotsLabel.Text = string.format("Spots Found: %d", fishingStats.spotsFound)
        v2StatusLabel.Text = string.format("Status: %s", fishingStats.lastAction)
        v2EfficiencyLabel.Text = string.format("Efficiency: %.1f%% | Last Action: %s", efficiency, fishingStats.lastAction)
        v2AFKLabel.Text = string.format("Anti-AFK: %ds | Cast Delay: %ds | Reel Delay: %.1fs", antiAfkTime, fishingV2Config.castDelay, fishingV2Config.reelDelay)
        
        wait(0.3)
    end
end)

-- ... [Rest of the code remains the same] ...
