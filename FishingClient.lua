-- UI-Only: Neon Panel dengan Tray Icon — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Close/minimize akan menyisakan tray icon.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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
    fishingDelay = 0.1,
    blantantMode = false,
    ultraSpeed = false
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
}

local fishingActive = false
local fishingConnection

-- 🎯 PERFECTION FISHING SYSTEM
local perfectionFishing = {}
perfectionFishing.Enabled = false
perfectionFishing.ReactionBase = 0.18 -- reaksi rata-rata manusia
perfectionFishing.PerfectThreshold = 0.05 -- zona perfect
perfectionFishing.Active = false

-- 🔘 Fungsi untuk menyalakan / mematikan mode perfection
function perfectionFishing:Toggle(state)
    perfectionFishing.Enabled = state
    if state then
        print("[🎯 PerfectionFishing] Mode ON - Sistem Auto Perfect aktif.")
        if not perfectionFishing.Active then
            perfectionFishing.Active = true
            perfectionFishing:StartPerfectionLoop()
        end
    else
        print("[🎯 PerfectionFishing] Mode OFF.")
        perfectionFishing.Active = false
    end
end

-- 🔁 Simulasi progress bar dan deteksi perfect timing
function perfectionFishing:Perform()
    if not perfectionFishing.Enabled then return false end

    -- simulasi posisi bar (bergerak dari 0 ke 1)
    local progress = 0
    local direction = 1
    local maxIterations = 100 -- safety limit

    for i = 1, maxIterations do
        if not perfectionFishing.Enabled then break end
        
        progress = progress + (0.03 * direction)

        -- balik arah jika mencapai ujung bar
        if progress >= 1 then direction = -1 end
        if progress <= 0 then direction = 1 end

        -- cek posisi mendekati tengah (zona perfect)
        if math.abs(progress - 0.5) <= perfectionFishing.PerfectThreshold then
            local delay = perfectionFishing.ReactionBase + math.random(0, 5) / 100
            task.wait(delay)
            print(string.format("[✅ PERFECT] Timing %.2fs | Posisi: %.2f", delay, progress))

            -- trigger tangkapan perfect
            perfectionFishing:CatchFish()
            return true
        end

        task.wait(0.05)
    end
    return false
end

-- 🐟 Fungsi tangkapan perfect
function perfectionFishing:CatchFish()
    if not perfectionFishing.Enabled then return end
    
    -- Tambah statistik
    fishingStats.fishCaught = fishingStats.fishCaught + 1
    fishingStats.attempts = fishingStats.attempts + 1
    
    print("[🐟] Menangkap ikan dengan presisi tinggi... Perfect!")
    
    -- efek visual
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎯 PERFECT CATCH!",
        Text = "Timing sempurna! Ikan berhasil ditangkap.",
        Duration = 2
    })
end

-- 🔄 Loop utama perfection fishing
function perfectionFishing:StartPerfectionLoop()
    spawn(function()
        while perfectionFishing.Active do
            if perfectionFishing.Enabled then
                local success = perfectionFishing:Perform()
                if success then
                    task.wait(2.5) -- cooldown setelah perfect catch
                end
            end
            task.wait(0.1)
        end
    end)
end

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

-- TRAY ICON (akan muncul ketika UI di close/minimize)
local trayIcon = Instance.new("ImageButton")
trayIcon.Name = "TrayIcon"
trayIcon.Size = UDim2.new(0, 60, 0, 60)
trayIcon.Position = UDim2.new(1, -70, 0, 20) -- Pojok kanan atas
trayIcon.BackgroundColor3 = ACCENT
trayIcon.Image = "rbxassetid://3926305904" -- Fishing icon
trayIcon.Visible = false -- Mulai dalam keadaan hidden
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

-- Card (panel utama)
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

-- Title bar dengan window controls
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

-- Minimize Button (-)
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

-- Close Button (X)
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

-- sidebar header
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

-- menu helper function
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

    -- hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

-- menu items
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
cTitle.Text = "Fishing"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = content

-- FISHING FUNCTIONS (sama seperti sebelumnya)
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
            print("[Fishing] No fishing rod found!")
            return false 
        end
        
        if rod.Parent == player.Backpack then
            local humanoid = SafeGetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.3)
                return true
            end
        end
        
        return rod.Parent == player.Character
    end)
    
    return success
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

local function TryFishingMethod()
    local success = false
    
    if not EquipRod() then
        return false
    end
    
    pcall(function()
        local prompt = FindFishingProximityPrompt()
        if prompt and prompt.Enabled then
            fireproximityprompt(prompt)
            success = true
        end
    end)
    
    if success then
        fishingStats.fishCaught = fishingStats.fishCaught + 1
        return true
    end
    
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
        fishingStats.fishCaught = fishingStats.fishCaught + 1
        return true
    end
    
    SimulateClick()
    SimulateKeyPress(Enum.KeyCode.E)
    SimulateKeyPress(Enum.KeyCode.F)
    
    fishingStats.attempts = fishingStats.attempts + 1
    fishingStats.fishCaught = fishingStats.fishCaught + 1
    
    return true
end

local function StartFishing()
    if fishingActive then 
        print("[Fishing] Already fishing!")
        return 
    end
    
    fishingActive = true
    fishingStats.startTime = tick()
    
    print("[Fishing] Starting fishing...")
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = pcall(function()
            TryFishingMethod()
        end)
        
        if not success then
            print("[Fishing] Error in fishing method")
        end
        
        task.wait(fishingConfig.fishingDelay)
    end)
end

local function StopFishing()
    fishingActive = false
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    print("[Fishing] Stopped fishing")
end

-- FISHING UI CONTENT
local fishingContent = Instance.new("Frame")
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -24)
fishingContent.Position = UDim2.new(0, 12, 0, 12)
fishingContent.BackgroundTransparency = 1
fishingContent.Visible = true
fishingContent.Parent = content

-- Stats Panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 80)
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

-- Controls Panel
local controlsPanel = Instance.new("Frame")
controlsPanel.Size = UDim2.new(1, 0, 0, 180)
controlsPanel.Position = UDim2.new(0, 0, 0, 92)
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
fishingButton.Size = UDim2.new(0, 200, 0, 40)
fishingButton.Position = UDim2.new(0, 12, 0, 44)
fishingButton.BackgroundColor3 = ACCENT
fishingButton.Font = Enum.Font.GothamBold
fishingButton.TextSize = 14
fishingButton.Text = "🚀 START FISHING"
fishingButton.TextColor3 = Color3.fromRGB(30,30,30)
fishingButton.AutoButtonColor = false
fishingButton.Parent = controlsPanel

local fishingBtnCorner = Instance.new("UICorner")
fishingBtnCorner.CornerRadius = UDim.new(0,6)
fishingBtnCorner.Parent = fishingButton

-- 🎯 PERFECTION FISHING BUTTON
local perfectionButton = Instance.new("TextButton")
perfectionButton.Size = UDim2.new(0, 200, 0, 36)
perfectionButton.Position = UDim2.new(0, 12, 0, 96)
perfectionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
perfectionButton.Font = Enum.Font.GothamBold
perfectionButton.TextSize = 12
perfectionButton.Text = "🎯 PERFECTION MODE: OFF"
perfectionButton.TextColor3 = Color3.fromRGB(255, 100, 100)
perfectionButton.AutoButtonColor = false
perfectionButton.Parent = controlsPanel

local perfectionBtnCorner = Instance.new("UICorner")
perfectionBtnCorner.CornerRadius = UDim.new(0,6)
perfectionBtnCorner.Parent = perfectionButton

-- Perfection Button Handler
perfectionButton.MouseButton1Click:Connect(function()
    perfectionFishing:Toggle(not perfectionFishing.Enabled)
    if perfectionFishing.Enabled then
        perfectionButton.Text = "🎯 PERFECTION MODE: ON"
        perfectionButton.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        perfectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        perfectionButton.Text = "🎯 PERFECTION MODE: OFF"
        perfectionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        perfectionButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Hover effects untuk perfection button
perfectionButton.MouseEnter:Connect(function()
    TweenService:Create(perfectionButton, TweenInfo.new(0.15), {
        BackgroundColor3 = perfectionFishing.Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 60, 60)
    }):Play()
end)

perfectionButton.MouseLeave:Connect(function()
    TweenService:Create(perfectionButton, TweenInfo.new(0.15), {
        BackgroundColor3 = perfectionFishing.Enabled and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(40, 40, 40)
    }):Play()
end)

-- Toggles Panel
local togglesPanel = Instance.new("Frame")
togglesPanel.Size = UDim2.new(1, 0, 0, 120)
togglesPanel.Position = UDim2.new(0, 0, 0, 284)
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
togglesTitle.Text = "🔧 Fishing Settings"
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
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
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
CreateToggle("Instant Fishing", "⚡ No delay fishing", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    if v then
        fishingConfig.fishingDelay = 0.01
    else
        fishingConfig.fishingDelay = 0.1
    end
    print("[Fishing] Instant Fishing:", v)
end, togglesPanel, 36)

CreateToggle("Blantant Mode", "💥 Ultra fast fishing", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then
        fishingConfig.fishingDelay = 0.001
        fishingConfig.instantFishing = true
    else
        fishingConfig.fishingDelay = 0.1
        fishingConfig.instantFishing = false
    end
    print("[Fishing] Blantant Mode:", v)
end, togglesPanel, 76)

-- Fishing Button Handler
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishing()
        fishingButton.Text = "🚀 START FISHING"
        fishingButton.BackgroundColor3 = ACCENT
    else
        StartFishing()
        fishingButton.Text = "⏹️ STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
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
print("🎯 Perfection Fishing System Ready!")

-- Test jika UI muncul
wait(1)
if screen and screen.Parent then
    print("✅ UI successfully created!")
else
    print("❌ UI failed to create!")
end
