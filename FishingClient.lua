-- NeonDashboardUI + Safe Simulated Fishing Features (InstantFishing + PerfectCast)
-- Paste into StarterPlayer -> StarterPlayerScripts as LocalScript
-- SAFE: This script DOES NOT call FireServer/InvokeServer/remote exploits or manipulate other players.
-- It simulates instant/perfect catches locally for testing and dev only.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- FISHING CONFIG (simulation-safe)
local fishingConfig = {
    autoFishing = false,         -- run simulation loop
    instantFishing = true,       -- simulated instant-catch behavior
    fishingDelay = 0.5,          -- base delay between simulated casts
    blantantMode = false,        -- speeds up simulation only
    ultraSpeed = false,
    perfectCast = true,          -- use PerfectionFishing logic
    autoReel = true,             -- simulate reel minigame auto-success
    bypassDetection = false,     -- not used in safe version
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successRate = 0
}

local fishingActive = false
local fishingConnection

-- CLEANUP old UI
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- Build UI (based on your provided layout)
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Tray icon (kept for UI)
local trayIcon = Instance.new("ImageButton")
trayIcon.Name = "TrayIcon"
trayIcon.Size = UDim2.new(0, 60, 0, 60)
trayIcon.Position = UDim2.new(1, -70, 0, 20)
trayIcon.BackgroundColor3 = ACCENT
trayIcon.Image = "rbxassetid://3926305904"
trayIcon.Visible = false
trayIcon.ZIndex = 10
trayIcon.Parent = screen
local trayCorner = Instance.new("UICorner", trayIcon); trayCorner.CornerRadius = UDim.new(0,12)
local trayGlow = Instance.new("ImageLabel", trayIcon)
trayGlow.Name = "TrayGlow"; trayGlow.Size = UDim2.new(1,20,1,20); trayGlow.Position = UDim2.new(0,-10,0,-10)
trayGlow.BackgroundTransparency = 1; trayGlow.Image = "rbxassetid://5050741616"; trayGlow.ImageColor3 = ACCENT; trayGlow.ImageTransparency = 0.8

-- Main container + glow
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

local glow = Instance.new("ImageLabel", container)
glow.Name = "Glow"; glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1; glow.Image = "rbxassetid://5050741616"; glow.ImageColor3 = ACCENT; glow.ImageTransparency = 0.92; glow.ZIndex = 1

local card = Instance.new("Frame", container)
card.Name = "Card"; card.Size = UDim2.new(0, WIDTH, 0, HEIGHT); card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG; card.BorderSizePixel = 0; card.ZIndex = 2
local cardCorner = Instance.new("UICorner", card); cardCorner.CornerRadius = UDim.new(0,12)

local inner = Instance.new("Frame", card)
inner.Name = "Inner"; inner.Size = UDim2.new(1, -24, 1, -24); inner.Position = UDim2.new(0,12,0,12); inner.BackgroundTransparency = 1

-- Title bar and controls
local titleBar = Instance.new("Frame", inner); titleBar.Size = UDim2.new(1,0,0,48); titleBar.BackgroundTransparency = 1
local title = Instance.new("TextLabel", titleBar); title.Size = UDim2.new(0.6,0,1,0); title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT (SAFE SIM)"; title.TextColor3 = Color3.fromRGB(255,220,220); title.TextXAlignment = Enum.TextXAlignment.Left

local windowControls = Instance.new("Frame", titleBar); windowControls.Size = UDim2.new(0,80,1,0); windowControls.Position = UDim2.new(1, -85, 0, 0); windowControls.BackgroundTransparency = 1
local minimizeBtn = Instance.new("TextButton", windowControls); minimizeBtn.Size = UDim2.new(0,32,0,32); minimizeBtn.Position = UDim2.new(0,0,0.5,-16)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); minimizeBtn.Font = Enum.Font.GothamBold; minimizeBtn.Text = "-"; minimizeBtn.TextColor3 = Color3.fromRGB(200,200,200); minimizeBtn.AutoButtonColor = false
local closeBtn = Instance.new("TextButton", windowControls); closeBtn.Size = UDim2.new(0,32,0,32); closeBtn.Position = UDim2.new(0,40,0.5,-16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40); closeBtn.Font = Enum.Font.GothamBold; closeBtn.Text = "🗙"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.AutoButtonColor = false
local memLabel = Instance.new("TextLabel", titleBar); memLabel.Size = UDim2.new(0.4,-100,1,0); memLabel.Position = UDim2.new(0.6,8,0,0); memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham; memLabel.TextSize = 11; memLabel.Text = "Memory: 0 KB | Fish: 0"; memLabel.TextColor3 = Color3.fromRGB(200,200,200); memLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar
local sidebar = Instance.new("Frame", inner); sidebar.Name="Sidebar"; sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64); sidebar.Position = UDim2.new(0,0,0,56); sidebar.BackgroundColor3 = SECOND; sidebar.ZIndex = 3
local sbCorner = Instance.new("UICorner", sidebar); sbCorner.CornerRadius = UDim.new(0,8)
local sbHeader = Instance.new("Frame", sidebar); sbHeader.Size = UDim2.new(1,0,0,84); sbHeader.BackgroundTransparency = 1
local logo = Instance.new("ImageLabel", sbHeader); logo.Size = UDim2.new(0,64,0,64); logo.Position = UDim2.new(0,12,0,10); logo.BackgroundTransparency = 1; logo.Image = "rbxassetid://3926305904"; logo.ImageColor3 = ACCENT
local sTitle = Instance.new("TextLabel", sbHeader); sTitle.Size = UDim2.new(1,-96,0,32); sTitle.Position = UDim2.new(0,88,0,12); sTitle.BackgroundTransparency = 1; sTitle.Font = Enum.Font.GothamBold; sTitle.TextSize = 14; sTitle.Text = "Kaitun"; sTitle.TextColor3 = Color3.fromRGB(240,240,240); sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Menu items
local menuFrame = Instance.new("Frame", sidebar); menuFrame.Size = UDim2.new(1,-12,1,-108); menuFrame.Position = UDim2.new(0,6,0,92); menuFrame.BackgroundTransparency = 1
local menuLayout = Instance.new("UIListLayout", menuFrame); menuLayout.SortOrder = Enum.SortOrder.LayoutOrder; menuLayout.Padding = UDim.new(0,8)

local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner", row); corner.CornerRadius = UDim.new(0,8)
    local left = Instance.new("Frame", row); left.Size = UDim2.new(0,40,1,0); left.Position = UDim2.new(0,8,0,0); left.BackgroundTransparency = 1
    local icon = Instance.new("TextLabel", left); icon.Size = UDim2.new(1,0,1,0); icon.BackgroundTransparency = 1; icon.Font = Enum.Font.GothamBold; icon.TextSize = 18; icon.Text = iconText; icon.TextColor3 = ACCENT; icon.TextXAlignment = Enum.TextXAlignment.Center; icon.TextYAlignment = Enum.TextYAlignment.Center
    local label = Instance.new("TextLabel", row); label.Size = UDim2.new(0.8,0,1,0); label.Position = UDim2.new(0,56,0,0); label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 14; label.Text = name; label.TextColor3 = Color3.fromRGB(230,230,230); label.TextXAlignment = Enum.TextXAlignment.Left

    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play() end)

    return row, label
end

local items = { {"Fishing","🎣"}, {"Teleport","📍"}, {"Settings","⚙"} }
local menuButtons = {}
for i,v in ipairs(items) do
    local btn,_ = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- Content panel
local content = Instance.new("Frame", inner); content.Name = "Content"; content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64); content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56); content.BackgroundColor3 = Color3.fromRGB(18,18,20)
local contentCorner = Instance.new("UICorner", content); contentCorner.CornerRadius = UDim.new(0,8)

local cTitle = Instance.new("TextLabel", content); cTitle.Size = UDim2.new(1, -24, 0, 44); cTitle.Position = UDim2.new(0,12,0,12); cTitle.BackgroundTransparency = 1; cTitle.Font = Enum.Font.GothamBold; cTitle.TextSize = 16; cTitle.Text = "Fishing"; cTitle.TextColor3 = Color3.fromRGB(245,245,245); cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- === PerfectionFishing module (safe, client-only simulation) ===
local PerfectionFishing = {}
PerfectionFishing.Enabled = fishingConfig.perfectCast
PerfectionFishing.ReactionBase = 0.16
PerfectionFishing.Threshold = 0.06

function PerfectionFishing:Toggle(state)
    self.Enabled = state and true or false
    fishingConfig.perfectCast = self.Enabled
    StarterGui:SetCore("SendNotification", {Title="PerfectionFishing", Text = self.Enabled and "ON" or "OFF", Duration=1})
end

-- Simulate "bar" and return when to reel for perfect catch
-- This function blocks until a perfect timing is reached (simulated), but respects Enabled flag
function PerfectionFishing:WaitForPerfect(maxWait)
    if not self.Enabled then
        -- if disabled, return a conservative delay
        task.wait(math.min(maxWait or 2.0, 0.25))
        return true
    end

    maxWait = maxWait or 4.0
    local start = tick()
    local progress = 0
    local dir = 1
    -- variable speed to simulate real indicator
    local speed = 0.01 + math.random() * 0.02
    while tick() - start < maxWait do
        progress = progress + speed * dir
        if progress >= 1 then dir = -1; progress = 1 end
        if progress <= 0 then dir = 1; progress = 0 end

        if math.abs(progress - 0.5) <= self.Threshold then
            -- small human reaction delay
            local reaction = PerfectionFishing.ReactionBase + (math.random() * 0.06)
            task.wait(reaction)
            return true
        end
        task.wait(0.02)
    end
    return false
end

-- === InstantFishing (SAFE client-side simulation) ===
-- This function simulates detecting a bobber and instantly "reels" it in locally.
-- IMPORTANT: It does NOT call any RemoteEvent, fireproximityprompt, or other server-affecting APIs.
local function SafeInstantCatch()
    -- Visual feedback + stat update
    fishingStats.attempts = fishingStats.attempts + 1

    -- If perfectCast enabled, wait for perfect timing (simulated)
    if PerfectionFishing.Enabled then
        local ok = PerfectionFishing:WaitForPerfect(3.5)
        if not ok then
            -- failed to get perfect within time - simulate miss
            StarterGui:SetCore("SendNotification", {Title="Fishing", Text="Missed timing (simulated)", Duration=1})
            return false
        end
    else
        -- small realistic delay when not perfection mode
        task.wait(0.1 + math.random() * 0.2)
    end

    -- simulate auto-reel success
    if fishingConfig.autoReel then
        -- simulate some reel action visuals (notification)
        StarterGui:SetCore("SendNotification", {Title="Fishing", Text="Auto-Reel successful (simulated)", Duration=0.9})
        task.wait(0.08)
    end

    -- success
    fishingStats.fishCaught = fishingStats.fishCaught + 1
    return true
end

-- Start / Stop simulation loop
local function StartFishingSim()
    if fishingActive then return end
    fishingActive = true
    fishingStats.startTime = tick()
    StarterGui:SetCore("SendNotification", {Title="Fishing", Text="Simulation started", Duration=1.2})

    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end

        -- if instant mode, try quick attempt
        if fishingConfig.instantFishing or fishingConfig.blantantMode then
            local success = pcall(SafeInstantCatch)
            -- adapt delay by mode
            if fishingConfig.blantantMode then
                task.wait(0.02)
            else
                task.wait(math.clamp(fishingConfig.fishingDelay, 0.01, 2))
            end
        else
            -- regular simulated cast -> wait -> attempt
            task.wait(fishingConfig.fishingDelay)
            pcall(SafeInstantCatch)
        end
    end)
end

local function StopFishingSim()
    fishingActive = false
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    StarterGui:SetCore("SendNotification", {Title="Fishing", Text="Simulation stopped", Duration=1.2})
end

-- === UI: Fishing content (stats + controls) ===
local fishingContent = Instance.new("Frame", content)
fishingContent.Name = "FishingContent"; fishingContent.Size = UDim2.new(1, -24, 1, -24); fishingContent.Position = UDim2.new(0,12,0,12); fishingContent.BackgroundTransparency = 1

-- Stats panel
local statsPanel = Instance.new("Frame", fishingContent); statsPanel.Size = UDim2.new(1,0,0,100); statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16); statsPanel.BorderSizePixel = 0
local statsCorner = Instance.new("UICorner", statsPanel); statsCorner.CornerRadius = UDim.new(0,8)
local statsTitle = Instance.new("TextLabel", statsPanel); statsTitle.Size = UDim2.new(1,-24,0,28); statsTitle.Position = UDim2.new(0,12,0,8); statsTitle.BackgroundTransparency = 1; statsTitle.Font = Enum.Font.GothamBold; statsTitle.TextSize = 14; statsTitle.Text = "📊 Fishing Statistics"; statsTitle.TextColor3 = Color3.fromRGB(235,235,235); statsTitle.TextXAlignment = Enum.TextXAlignment.Left
local fishCountLabel = Instance.new("TextLabel", statsPanel); fishCountLabel.Size = UDim2.new(0.5,-8,0,24); fishCountLabel.Position = UDim2.new(0,12,0,40); fishCountLabel.BackgroundTransparency = 1; fishCountLabel.Font = Enum.Font.Gotham; fishCountLabel.TextSize = 13; fishCountLabel.Text = "Fish Caught: 0"; fishCountLabel.TextColor3 = Color3.fromRGB(200,255,200); fishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
local rateLabel = Instance.new("TextLabel", statsPanel); rateLabel.Size = UDim2.new(0.5,-8,0,24); rateLabel.Position = UDim2.new(0.5,4,0,40); rateLabel.BackgroundTransparency = 1; rateLabel.Font = Enum.Font.Gotham; rateLabel.TextSize = 13; rateLabel.Text = "Rate: 0/s"; rateLabel.TextColor3 = Color3.fromRGB(200,220,255)
local attemptsLabel = Instance.new("TextLabel", statsPanel); attemptsLabel.Size = UDim2.new(0.5,-8,0,24); attemptsLabel.Position = UDim2.new(0,12,0,68); attemptsLabel.BackgroundTransparency = 1; attemptsLabel.Font = Enum.Font.Gotham; attemptsLabel.TextSize = 13; attemptsLabel.Text = "Attempts: 0"; attemptsLabel.TextColor3 = Color3.fromRGB(255,220,200)
local successLabel = Instance.new("TextLabel", statsPanel); successLabel.Size = UDim2.new(0.5,-8,0,24); successLabel.Position = UDim2.new(0.5,4,0,68); successLabel.BackgroundTransparency = 1; successLabel.Font = Enum.Font.Gotham; successLabel.TextSize = 13; successLabel.Text = "Success: 0%"; successLabel.TextColor3 = Color3.fromRGB(255,200,255)

-- Controls panel
local controlsPanel = Instance.new("Frame", fishingContent); controlsPanel.Size = UDim2.new(1,0,0,100); controlsPanel.Position = UDim2.new(0,0,0,112); controlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
local controlsCorner = Instance.new("UICorner", controlsPanel); controlsCorner.CornerRadius = UDim.new(0,8)
local controlsTitle = Instance.new("TextLabel", controlsPanel); controlsTitle.Size = UDim2.new(1,-24,0,28); controlsTitle.Position = UDim2.new(0,12,0,8); controlsTitle.BackgroundTransparency = 1; controlsTitle.Font = Enum.Font.GothamBold; controlsTitle.TextSize = 14; controlsTitle.Text = "⚡ Fishing Controls"; controlsTitle.TextColor3 = Color3.fromRGB(235,235,235); controlsTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Start/Stop button
local fishingButton = Instance.new("TextButton", controlsPanel); fishingButton.Size = UDim2.new(0,200,0,50); fishingButton.Position = UDim2.new(0,12,0,40); fishingButton.BackgroundColor3 = ACCENT; fishingButton.Font = Enum.Font.GothamBold; fishingButton.TextSize = 14; fishingButton.Text = "🚀 START SIM FISHING"; fishingButton.TextColor3 = Color3.fromRGB(30,30,30); fishingButton.AutoButtonColor = false
local fishingBtnCorner = Instance.new("UICorner", fishingButton); fishingBtnCorner.CornerRadius = UDim.new(0,6)
local statusLabel = Instance.new("TextLabel", controlsPanel); statusLabel.Size = UDim2.new(0.5,-16,0,50); statusLabel.Position = UDim2.new(0,224,0,40); statusLabel.BackgroundTransparency = 1; statusLabel.Font = Enum.Font.GothamBold; statusLabel.TextSize = 12; statusLabel.Text = "⭕ OFFLINE"; statusLabel.TextColor3 = Color3.fromRGB(255,100,100); statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggles (re-using helper)
local togglesPanel = Instance.new("Frame", fishingContent); togglesPanel.Size = UDim2.new(1,0,0,200); togglesPanel.Position = UDim2.new(0,0,0,224); togglesPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
local togglesCorner = Instance.new("UICorner", togglesPanel); togglesCorner.CornerRadius = UDim.new(0,8)
local togglesTitle = Instance.new("TextLabel", togglesPanel); togglesTitle.Size = UDim2.new(1,-24,0,28); togglesTitle.Position = UDim2.new(0,12,0,8); togglesTitle.BackgroundTransparency = 1; togglesTitle.Font = Enum.Font.GothamBold; togglesTitle.TextSize = 14; togglesTitle.Text = "🔧 Instant Fishing Settings"; togglesTitle.TextColor3 = Color3.fromRGB(235,235,235); togglesTitle.TextXAlignment = Enum.TextXAlignment.Left

local function CreateToggle(name, desc, default, callback, parent, yPos)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, -24, 0, 36); frame.Position = UDim2.new(0,12,0,yPos); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(0.7,0,0,16); label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold; label.TextSize = 12; label.Text = name; label.TextColor3 = Color3.fromRGB(230,230,230); label.TextXAlignment = Enum.TextXAlignment.Left
    local descLabel = Instance.new("TextLabel", frame); descLabel.Size = UDim2.new(0.7,0,0,16); descLabel.Position = UDim2.new(0,0,0,18); descLabel.BackgroundTransparency = 1; descLabel.Font = Enum.Font.Gotham; descLabel.TextSize = 10; descLabel.Text = desc; descLabel.TextColor3 = Color3.fromRGB(180,180,180); descLabel.TextXAlignment = Enum.TextXAlignment.Left
    local button = Instance.new("TextButton", frame); button.Size = UDim2.new(0,60,0,24); button.Position = UDim2.new(0.75,0,0.2,0); button.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0); button.Font = Enum.Font.GothamBold; button.TextSize = 11; button.Text = default and "ON" or "OFF"; button.TextColor3 = Color3.fromRGB(30,30,30)
    local btnCorner = Instance.new("UICorner", button); btnCorner.CornerRadius = UDim.new(0,4)
    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
        callback(new)
    end)
    return frame
end

-- Create toggles wiring to fishingConfig
CreateToggle("⚡ Instant Fishing","Simulated instant catch (client-only)", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    StarterGui:SetCore("SendNotification", {Title="Config", Text = "Instant Fishing "..(v and "ON" or "OFF"), Duration=1})
end, togglesPanel, 36)

CreateToggle("💥 Blatant Mode","Simulated ultra-speed (client-only)", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then fishingConfig.fishingDelay = 0.02 else fishingConfig.fishingDelay = 0.5 end
    StarterGui:SetCore("SendNotification", {Title="Config", Text = "Blatant Mode "..(v and "ON" or "OFF"), Duration=1})
end, togglesPanel, 76)

CreateToggle("🎯 Perfect Cast","Use PerfectionFishing logic", fishingConfig.perfectCast, function(v)
    PerfectionFishing:Toggle(v)
end, togglesPanel, 116)

CreateToggle("🔄 Auto Reel","Simulate auto-reel success", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
    StarterGui:SetCore("SendNotification", {Title="Config", Text = "Auto Reel "..(v and "ON" or "OFF"), Duration=1})
end, togglesPanel, 156)

-- Fishing button handler
fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then
        StopFishingSim()
        fishingButton.Text = "🚀 START SIM FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusLabel.Text = "⭕ OFFLINE"; statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
    else
        StartFishingSim()
        fishingButton.Text = "⏹️ STOP SIM FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(255,100,100)
        statusLabel.Text = "✅ SIM ACTIVE"; statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
    end
end)

-- Menu navigation content placeholders
local teleportContent = Instance.new("Frame", content); teleportContent.Name="TeleportContent"; teleportContent.Size = UDim2.new(1,-24,1,-24); teleportContent.Position = UDim2.new(0,12,0,12); teleportContent.BackgroundTransparency = 1; teleportContent.Visible = false
local teleportLabel = Instance.new("TextLabel", teleportContent); teleportLabel.Size = UDim2.new(1,0,1,0); teleportLabel.BackgroundTransparency = 1; teleportLabel.Font = Enum.Font.GothamBold; teleportLabel.TextSize = 16; teleportLabel.Text = "Teleport Feature\n(Coming Soon - safe demo)"; teleportLabel.TextColor3 = Color3.fromRGB(200,200,200); teleportLabel.TextYAlignment = Enum.TextYAlignment.Center

local settingsContent = Instance.new("Frame", content); settingsContent.Name="SettingsContent"; settingsContent.Size = UDim2.new(1,-24,1,-24); settingsContent.Position = UDim2.new(0,12,0,12); settingsContent.BackgroundTransparency = 1; settingsContent.Visible = false
local settingsLabel = Instance.new("TextLabel", settingsContent); settingsLabel.Size = UDim2.new(1,0,1,0); settingsLabel.BackgroundTransparency = 1; settingsLabel.Font = Enum.Font.GothamBold; settingsLabel.TextSize = 16; settingsLabel.Text = "Settings\n(Coming Soon)"; settingsLabel.TextColor3 = Color3.fromRGB(200,200,200); settingsLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Menu navigation wiring
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n,b in pairs(menuButtons) do b.BackgroundColor3 = Color3.fromRGB(20,20,20) end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        cTitle.Text = name
        fishingContent.Visible = (name == "Fishing")
        teleportContent.Visible = (name == "Teleport")
        settingsContent.Visible = (name == "Settings")
    end)
end
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- Window controls: minimize/close to tray
local uiOpen = true
local function showTrayIcon() trayIcon.Visible = true; TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size=UDim2.new(0,60,0,60)}):Play(); TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency=0.7}):Play() end
local function hideTrayIcon() TweenService:Create(trayIcon, TweenInfo.new(0.3), {Size=UDim2.new(0,0,0,0)}):Play(); TweenService:Create(trayGlow, TweenInfo.new(0.3), {ImageTransparency=1}):Play(); wait(0.3); trayIcon.Visible = false end
local function showMainUI() container.Visible = true; TweenService:Create(container, TweenInfo.new(0.4), {Size=UDim2.new(0,WIDTH,0,HEIGHT), Position=UDim2.new(0.5,-WIDTH/2,0.5,-HEIGHT/2)}):Play(); TweenService:Create(glow,TweenInfo.new(0.4),{ImageTransparency=0.85}):Play(); hideTrayIcon(); uiOpen=true end
local function hideMainUI() TweenService:Create(container, TweenInfo.new(0.3), {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}):Play(); TweenService:Create(glow,TweenInfo.new(0.3),{ImageTransparency=1}):Play(); wait(0.3); container.Visible=false; showTrayIcon(); uiOpen=false end
minimizeBtn.MouseButton1Click:Connect(function() hideMainUI() end)
closeBtn.MouseButton1Click:Connect(function() hideMainUI() end)
trayIcon.MouseButton1Click:Connect(function() showMainUI() end)

-- Stats update loop
spawn(function()
    while true do
        local elapsed = math.max(1, tick() - fishingStats.startTime)
        local rate = fishingStats.fishCaught / elapsed
        fishCountLabel.Text = string.format("Fish Caught: %d", fishingStats.fishCaught)
        rateLabel.Text = string.format("Rate: %.2f/s", rate)
        attemptsLabel.Text = string.format("Attempts: %d", fishingStats.attempts)
        local successPct = fishingStats.attempts > 0 and math.floor((fishingStats.fishCaught / fishingStats.attempts) * 100) or 0
        successLabel.Text = string.format("Success: %d%%", successPct)
        memLabel.Text = string.format("Memory: %d KB | Fish: %d", math.floor(collectgarbage("count")), fishingStats.fishCaught)
        wait(0.6)
    end
end)

-- Start with UI visible
container.Visible = true
print("[Kaitun Fish It - SAFE SIM] UI Loaded. Use controls to start simulated fishing.")
