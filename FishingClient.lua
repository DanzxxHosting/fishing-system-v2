-- NeonPanel + Enhanced (SAFE) InstantFishing & PerfectionFishing
-- PASTE ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- IMPORTANT: SAFE SIMULATION ONLY — NO remote:FireServer / no exploit calls

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== CONFIG =====
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- Fishing config (client-side simulation)
local fishingConfig = {
    autoFishing = false,        -- loop auto (sim)
    instantFishing = true,      -- feature enabled (sim)
    fishingDelay = 0.1,         -- base delay (s)
    blantantMode = false,       -- client-only speed boost
    ultraSpeed = false,         -- unused
    perfectCast = true,         -- perfect-cast simulator
    autoReel = true,            -- client-only auto-reel simulator
    legitMode = false,          -- humanize delays
    perfectThreshold = 0.05,    -- used by PerfectionFishing
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0
}

local fishingActive = false
local fishingLoopConn

-- ===== Safety: Disable risky helper methods (left as placeholders) =====
-- NOTE: The original code referenced VirtualInputManager/RemoteEvents, etc.
-- Those are intentionally NOT used here to keep the script safe.

-- ===== UI BUILD (your base UI) =====
-- cleanup old
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

local glow = Instance.new("ImageLabel", screen)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = container.Position
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1

local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2
local cardCorner = Instance.new("UICorner", card); cardCorner.CornerRadius = UDim.new(0, 12)

local inner = Instance.new("Frame", card)
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1

-- Title bar
local titleBar = Instance.new("Frame", inner)
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local memLabel = Instance.new("TextLabel", titleBar)
memLabel.Size = UDim2.new(0.4,-16,1,0)
memLabel.Position = UDim2.new(0.6,8,0,0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 11
memLabel.Text = "Memory: 0 KB | Fish: 0"
memLabel.TextColor3 = Color3.fromRGB(200,200,200)
memLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
local sbCorner = Instance.new("UICorner", sidebar); sbCorner.CornerRadius = UDim.new(0, 8)

local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1
local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,64,0,64); logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1; logo.Image = "rbxassetid://3926305904"; logo.ImageColor3 = ACCENT
local sTitle = Instance.new("TextLabel", sbHeader)
sTitle.Size = UDim2.new(1,-96,0,32); sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1; sTitle.Font = Enum.Font.GothamBold; sTitle.TextSize = 14
sTitle.Text = "Kaitun"; sTitle.TextColor3 = Color3.fromRGB(240,240,240); sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Menu
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-12,1, -108); menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1
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
    local icon = Instance.new("TextLabel", left); icon.Size = UDim2.new(1,0,1,0); icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold; icon.TextSize = 18; icon.Text = iconText; icon.TextColor3 = ACCENT; icon.TextXAlignment = Enum.TextXAlignment.Center
    local label = Instance.new("TextLabel", row); label.Size = UDim2.new(0.8,0,1,0); label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 14; label.Text = name; label.TextColor3 = Color3.fromRGB(230,230,230)
    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play() end)
    return row, label
end

local items = { {"Fishing","🎣"}, {"Teleport","📍"}, {"Settings","⚙"} }
local menuButtons = {}
for i,v in ipairs(items) do
    local b, lbl = makeMenuItem(v[1], v[2])
    b.LayoutOrder = i
    menuButtons[v[1]] = b
end

-- Content
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0

local contentCorner = Instance.new("UICorner", content); contentCorner.CornerRadius = UDim.new(0, 8)
local cTitle = Instance.new("TextLabel", content)
cTitle.Size = UDim2.new(1, -24, 0, 44); cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1; cTitle.Font = Enum.Font.GothamBold; cTitle.TextSize = 16
cTitle.Text = "Fishing"; cTitle.TextColor3 = Color3.fromRGB(245,245,245); cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Fishing content panel
local fishingContent = Instance.new("Frame", content)
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -24)
fishingContent.Position = UDim2.new(0,12,0,12)
fishingContent.BackgroundTransparency = 1

-- stats panel
local statsPanel = Instance.new("Frame", fishingContent)
statsPanel.Size = UDim2.new(1,0,0,100); statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
local statsCorner = Instance.new("UICorner", statsPanel); statsCorner.CornerRadius = UDim.new(0,8)
local statsTitle = Instance.new("TextLabel", statsPanel)
statsTitle.Size = UDim2.new(1, -24, 0, 28); statsTitle.Position = UDim2.new(0,12,0,8)
statsTitle.BackgroundTransparency = 1; statsTitle.Font = Enum.Font.GothamBold; statsTitle.TextSize = 14
statsTitle.Text = "📊 Fishing Statistics"; statsTitle.TextColor3 = Color3.fromRGB(235,235,235); statsTitle.TextXAlignment = Enum.TextXAlignment.Left

local fishCountLabel = Instance.new("TextLabel", statsPanel)
fishCountLabel.Size = UDim2.new(0.5, -8, 0, 24); fishCountLabel.Position = UDim2.new(0,12,0,40)
fishCountLabel.BackgroundTransparency = 1; fishCountLabel.Font = Enum.Font.Gotham; fishCountLabel.TextSize = 13
fishCountLabel.Text = "Fish Caught: 0"; fishCountLabel.TextColor3 = Color3.fromRGB(200,255,200)
local rateLabel = Instance.new("TextLabel", statsPanel)
rateLabel.Size = UDim2.new(0.5, -8, 0, 24); rateLabel.Position = UDim2.new(0.5,4,0,40)
rateLabel.BackgroundTransparency = 1; rateLabel.Font = Enum.Font.Gotham; rateLabel.TextSize = 13
rateLabel.Text = "Rate: 0/s"; rateLabel.TextColor3 = Color3.fromRGB(200,220,255)
local attemptsLabel = Instance.new("TextLabel", statsPanel)
attemptsLabel.Size = UDim2.new(0.5, -8, 0, 24); attemptsLabel.Position = UDim2.new(0,12,0,68)
attemptsLabel.BackgroundTransparency = 1; attemptsLabel.Font = Enum.Font.Gotham; attemptsLabel.TextSize = 13
attemptsLabel.Text = "Attempts: 0"; attemptsLabel.TextColor3 = Color3.fromRGB(255,220,200)
local successLabel = Instance.new("TextLabel", statsPanel)
successLabel.Size = UDim2.new(0.5, -8, 0, 24); successLabel.Position = UDim2.new(0.5,4,0,68)
successLabel.BackgroundTransparency = 1; successLabel.Font = Enum.Font.Gotham; successLabel.TextSize = 13
successLabel.Text = "Success: 0%"; successLabel.TextColor3 = Color3.fromRGB(255,200,255)

-- Controls panel
local controlsPanel = Instance.new("Frame", fishingContent)
controlsPanel.Size = UDim2.new(1,0,0,100); controlsPanel.Position = UDim2.new(0,0,0,112); controlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
local controlsCorner = Instance.new("UICorner", controlsPanel); controlsCorner.CornerRadius = UDim.new(0,8)
local controlsTitle = Instance.new("TextLabel", controlsPanel)
controlsTitle.Size = UDim2.new(1, -24, 0, 28); controlsTitle.Position = UDim2.new(0,12,0,8)
controlsTitle.BackgroundTransparency = 1; controlsTitle.Font = Enum.Font.GothamBold; controlsTitle.TextSize = 14
controlsTitle.Text = "⚡ Fishing Controls"; controlsTitle.TextColor3 = Color3.fromRGB(235,235,235)

local fishingButton = Instance.new("TextButton", controlsPanel)
fishingButton.Size = UDim2.new(0,200,0,50); fishingButton.Position = UDim2.new(0,12,0,40)
fishingButton.BackgroundColor3 = ACCENT; fishingButton.Font = Enum.Font.GothamBold; fishingButton.TextSize = 14
fishingButton.Text = "🚀 START INSTANT FISHING"; fishingButton.TextColor3 = Color3.fromRGB(30,30,30)
local fishingBtnCorner = Instance.new("UICorner", fishingButton); fishingBtnCorner.CornerRadius = UDim.new(0,6)

local statusLabel = Instance.new("TextLabel", controlsPanel)
statusLabel.Size = UDim2.new(0.5,-16,0,50); statusLabel.Position = UDim2.new(0,224,0,40)
statusLabel.BackgroundTransparency = 1; statusLabel.Font = Enum.Font.GothamBold; statusLabel.TextSize = 12
statusLabel.Text = "⭕ OFFLINE"; statusLabel.TextColor3 = Color3.fromRGB(255,100,100); statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggles panel
local togglesPanel = Instance.new("Frame", fishingContent)
togglesPanel.Size = UDim2.new(1,0,0,200); togglesPanel.Position = UDim2.new(0,0,0,224); togglesPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
local togglesCorner = Instance.new("UICorner", togglesPanel); togglesCorner.CornerRadius = UDim.new(0,8)
local togglesTitle = Instance.new("TextLabel", togglesPanel)
togglesTitle.Size = UDim2.new(1, -24, 0, 28); togglesTitle.Position = UDim2.new(0,12,0,8)
togglesTitle.BackgroundTransparency = 1; togglesTitle.Font = Enum.Font.GothamBold; togglesTitle.TextSize = 14
togglesTitle.Text = "🔧 Instant Fishing Settings"; togglesTitle.TextColor3 = Color3.fromRGB(235,235,235)

local function CreateToggle(name, desc, default, callback, parent, yPos)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local descLabel = Instance.new("TextLabel", frame)
    descLabel.Size = UDim2.new(0.7, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(180,180,180)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0, 60, 0, 24)
    button.Position = UDim2.new(0.75, 0, 0.2, 0)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(30,30,30)

    local btnCorner = Instance.new("UICorner", button); btnCorner.CornerRadius = UDim.new(0,4)

    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        callback(new)
    end)

    return frame
end

-- Create toggles wired to fishingConfig (these update config only)
CreateToggle("⚡ Instant Fishing", "Max speed casting & catching (sim)", fishingConfig.instantFishing, function(v)
    fishingConfig.instantFishing = v
    if v then fishingConfig.fishingDelay = 0.05 else fishingConfig.fishingDelay = 0.1 end
end, togglesPanel, 36)

CreateToggle("💥 Blatant Mode", "Ultra fast (client-only)", fishingConfig.blantantMode, function(v)
    fishingConfig.blantantMode = v
    if v then fishingConfig.fishingDelay = 0.005 else fishingConfig.fishingDelay = 0.1 end
end, togglesPanel, 76)

CreateToggle("🎯 Perfect Cast", "Simulate perfect timing", fishingConfig.perfectCast, function(v)
    fishingConfig.perfectCast = v
end, togglesPanel, 116)

CreateToggle("🔄 Auto Reel", "Auto reel minigame (client-only)", fishingConfig.autoReel, function(v)
    fishingConfig.autoReel = v
end, togglesPanel, 156)

-- ===== PerfectionFishing (client-side) =====
local PerfectionFishing = {}
PerfectionFishing.Enabled = false
PerfectionFishing.ReactionBase = 0.14
PerfectionFishing.Threshold = fishingConfig.perfectThreshold or 0.05

function PerfectionFishing:Toggle(state)
    self.Enabled = state and true or false
    if self.Enabled then
        -- small feedback
        local note = Instance.new("TextLabel", content)
        note.Size = UDim2.new(0.4,0,0,24)
        note.Position = UDim2.new(0,12,1,-36)
        note.BackgroundTransparency = 1
        note.Font = Enum.Font.Gotham
        note.TextSize = 13
        note.TextColor3 = Color3.fromRGB(120,255,170)
        note.Text = "Perfection Mode: ON"
        delay(1.2, function() if note and note.Parent then note:Destroy() end end)
    end
    print("[PerfectionFishing] Enabled:", self.Enabled)
end

-- Simulate performing a perfect catch (client-side only)
function PerfectionFishing:PerformSimulatedCatch()
    if not self.Enabled then return false end
    -- Simulate bar sweep, wait until in perfect window then "catch"
    local sweep = 0
    local dir = 1
    local maxLoops = 300 -- safety
    for i = 1, maxLoops do
        sweep = sweep + dir * 0.03
        if sweep >= 1 then dir = -1 end
        if sweep <= 0 then dir = 1 end
        if math.abs(sweep - 0.5) <= PerfectionFishing.Threshold then
            local delay = PerfectionFishing.ReactionBase + math.random(0, 6) / 100
            task.wait(delay)
            -- simulate success feedback
            fishingStats.fishCaught = fishingStats.fishCaught + 1
            fishingStats.attempts = fishingStats.attempts + 1
            print(string.format("[PerfectionFishing] Perfect catch! delay=%.2f sweep=%.2f", delay, sweep))
            -- visual toast
            pcall(function()
                local t = Instance.new("TextLabel", content)
                t.Size = UDim2.new(0.4,0,0,24)
                t.Position = UDim2.new(0,12,1,-64)
                t.BackgroundTransparency = 1
                t.Font = Enum.Font.GothamBold
                t.TextSize = 14
                t.TextColor3 = Color3.fromRGB(120,255,170)
                t.Text = "🎯 PERFECT CATCH!"
                delay(1.2, function() if t and t.Parent then t:Destroy() end end)
            end)
            return true
        end
        task.wait(0.02)
    end
    return false
end

-- ===== InstantFishing (client-side safe) =====
local InstantFishing = {}
InstantFishing.Enabled = fishingConfig.instantFishing

-- Utility: try to find local "bobber" part or GUI indicator
local function FindLocalBobber()
    -- heuristics: look for parts named 'Bobber' or 'Buoy' in Workspace (client may see them)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("bobber") or name:find("buoy") or name:find("float") then
                -- basic distance check
                local char = player.Character
                if char and char.PrimaryPart then
                    if (char.PrimaryPart.Position - obj.Position).Magnitude < 200 then
                        return obj
                    end
                else
                    return obj
                end
            end
        end
    end
    -- fallback: search for BillboardGui with text "!" or Exclamation
    for _, gui in pairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") then
            local txt = gui:FindFirstChildWhichIsA("TextLabel")
            if txt and txt.Text:find("!") then
                if gui.Adornee and gui.Adornee:IsA("BasePart") then
                    return gui.Adornee
                end
            end
        end
    end
    return nil
end

-- Instant trigger when bobber shows "!" (client-only simulation)
local function CheckAndPerformInstant()
    if not InstantFishing.Enabled then return false end
    local bob = FindLocalBobber()
    if not bob then return false end

    -- check for nearby '!' indicators (BillboardGui text)
    for _, child in pairs(bob:GetDescendants()) do
        if child:IsA("BillboardGui") then
            local txt = child:FindFirstChildWhichIsA("TextLabel")
            if txt and txt.Text:find("!") then
                -- Simulate immediate reel/catch locally
                fishingStats.attempts = fishingStats.attempts + 1
                fishingStats.fishCaught = fishingStats.fishCaught + 1
                -- Visual feedback near bobber
                pcall(function()
                    local pop = Instance.new("BillboardGui", bob)
                    pop.Size = UDim2.new(0, 120, 0, 28)
                    pop.StudsOffset = Vector3.new(0,2,0)
                    pop.AlwaysOnTop = true
                    local label = Instance.new("TextLabel", pop)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 18
                    label.TextColor3 = Color3.fromRGB(120,255,170)
                    label.Text = "🐟 CAUGHT!"
                    delay(0.9, function() if pop and pop.Parent then pop:Destroy() end end)
                end)
                print("[InstantFishing] Detected '!' on bobber — performed local instant catch.")
                return true
            end
        end
    end

    -- If no '!' UI found, if perfectCast is enabled we can attempt perfection simulator instead
    if fishingConfig.perfectCast and PerfectionFishing.Enabled then
        return PerfectionFishing:PerformSimulatedCatch()
    end

    return false
end

-- Master instant function invoked by loop (client-side safe)
local function DoInstantFishingCycle()
    -- This function must not call remote:FireServer in this safe version.
    -- It only simulates detection & local catch feedback.
    local ok = false
    -- Equip rod (local)
    -- Note: EquipRod in original code tries to equip actual Tool — keep safe: we won't force server-side equip.
    -- We'll just attempt to find rod visually for UI feedback but won't manipulate server game state.
    local rod = nil
    pcall(function()
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, it in pairs(bp:GetChildren()) do
                if it:IsA("Tool") and (it.Name:lower():find("rod") or it.Name:lower():find("pole")) then
                    rod = it
                    break
                end
            end
        end
        if not rod and player.Character then
            for _, it in pairs(player.Character:GetChildren()) do
                if it:IsA("Tool") and (it.Name:lower():find("rod") or it.Name:lower():find("pole")) then
                    rod = it; break
                end
            end
        end
    end)

    -- Attempt detection-based instant catch
    if InstantFishing.Enabled then
        ok = CheckAndPerformInstant()
    end

    -- If still not ok and perfectCast enabled, try simulated perfect
    if (not ok) and fishingConfig.perfectCast and PerfectionFishing.Enabled then
        ok = PerfectionFishing:PerformSimulatedCatch()
    end

    -- update stats labels handled in stats loop
    return ok
end

-- ===== Auto Fishing Loop (client-only) =====
local function StartFishing()
    if fishingActive then return end
    fishingActive = true
    fishingStats.startTime = tick()
    print("[Fishing] Starting (SIMULATION) ...")
    -- loop job
    fishingLoopConn = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        -- control speed
        local delaySec = fishingConfig.fishingDelay or 0.1
        if fishingConfig.blantantMode then delaySec = math.max(0.001, delaySec * 0.1) end
        -- perform one cycle
        pcall(function()
            DoInstantFishingCycle()
        end)
        -- client-side wait (do not block RunService; use task.wait to avoid freezing)
        task.wait(delaySec)
    end)
    -- status UI
    statusLabel.Text = "✅ FISHING ACTIVE (SIM)"
    statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
    fishingButton.Text = "⏹ STOP (SIM)"
    fishingButton.BackgroundColor3 = Color3.fromRGB(255,100,100)
end

local function StopFishing()
    if not fishingActive then return end
    fishingActive = false
    if fishingLoopConn then
        fishingLoopConn:Disconnect()
        fishingLoopConn = nil
    end
    statusLabel.Text = "⭕ OFFLINE"
    statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
    fishingButton.Text = "🚀 START INSTANT FISHING"
    fishingButton.BackgroundColor3 = ACCENT
    print("[Fishing] Stopped (SIMULATION). Fish caught:", fishingStats.fishCaught)
end

fishingButton.MouseButton1Click:Connect(function()
    if fishingActive then StopFishing() else StartFishing() end
end)

-- ===== Wire Perfection & Instant toggles to UI =====
-- Add a small Perfection toggle button in controls (for convenience)
local perfectionBtn = Instance.new("TextButton", controlsPanel)
perfectionBtn.Size = UDim2.new(0, 160, 0, 34)
perfectionBtn.Position = UDim2.new(0, 224, 0, 48)
perfectionBtn.BackgroundColor3 = PerfectionFishing.Enabled and ACCENT or Color3.fromRGB(36,36,36)
perfectionBtn.Font = Enum.Font.GothamBold
perfectionBtn.TextSize = 12
perfectionBtn.Text = PerfectionFishing.Enabled and "🎯 Perfection: ON" or "🎯 Perfection: OFF"
local perfectionCorner = Instance.new("UICorner", perfectionBtn); perfectionCorner.CornerRadius = UDim.new(0,6)

perfectionBtn.MouseButton1Click:Connect(function()
    local new = not PerfectionFishing.Enabled
    PerfectionFishing:Toggle(new)
    perfectionBtn.BackgroundColor3 = new and ACCENT or Color3.fromRGB(36,36,36)
    perfectionBtn.Text = new and "🎯 Perfection: ON" or "🎯 Perfection: OFF"
end)

-- InstantFishing toggle (quick)
local instantBtn = Instance.new("TextButton", controlsPanel)
instantBtn.Size = UDim2.new(0, 120, 0, 34)
instantBtn.Position = UDim2.new(0, 24, 0, 48)
instantBtn.BackgroundColor3 = InstantFishing.Enabled and ACCENT or Color3.fromRGB(36,36,36)
instantBtn.Font = Enum.Font.GothamBold
instantBtn.TextSize = 12
instantBtn.Text = InstantFishing.Enabled and "⚡ Instant: ON" or "⚡ Instant: OFF"
local instantCorner = Instance.new("UICorner", instantBtn); instantCorner.CornerRadius = UDim.new(0,6)

instantBtn.MouseButton1Click:Connect(function()
    InstantFishing.Enabled = not InstantFishing.Enabled
    instantBtn.BackgroundColor3 = InstantFishing.Enabled and ACCENT or Color3.fromRGB(36,36,36)
    instantBtn.Text = InstantFishing.Enabled and "⚡ Instant: ON" or "⚡ Instant: OFF"
end)

-- ===== Teleport placeholder (ke UI teleport panel) =====
local teleportContent = Instance.new("Frame", content)
teleportContent.Name = "TeleportContent"
teleportContent.Size = UDim2.new(1, -24, 1, -24)
teleportContent.Position = UDim2.new(0, 12, 0, 12)
teleportContent.BackgroundTransparency = 1
teleportContent.Visible = false

local teleportLabel = Instance.new("TextLabel", teleportContent)
teleportLabel.Size = UDim2.new(1,0,1,0); teleportLabel.BackgroundTransparency = 1
teleportLabel.Font = Enum.Font.GothamBold; teleportLabel.TextSize = 16
teleportLabel.Text = "Teleport Feature (client-side demo)"; teleportLabel.TextColor3 = Color3.fromRGB(200,200,200)
teleportLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Settings placeholder
local settingsContent = Instance.new("Frame", content)
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -24, 1, -24)
settingsContent.Position = UDim2.new(0, 12, 0, 12)
settingsContent.BackgroundTransparency = 1
settingsContent.Visible = false
local settingsLabel = Instance.new("TextLabel", settingsContent)
settingsLabel.Size = UDim2.new(1,0,1,0); settingsLabel.BackgroundTransparency = 1
settingsLabel.Font = Enum.Font.GothamBold; settingsLabel.TextSize = 16
settingsLabel.Text = "Settings (Coming Soon)"; settingsLabel.TextColor3 = Color3.fromRGB(200,200,200)
settingsLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Menu navigation wiring
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, b in pairs(menuButtons) do b.BackgroundColor3 = Color3.fromRGB(20,20,20) end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        cTitle.Text = name
        fishingContent.Visible = (name == "Fishing")
        teleportContent.Visible = (name == "Teleport")
        settingsContent.Visible = (name == "Settings")
    end)
end
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

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
        task.wait(0.6)
    end
end)

-- initial show
container.Visible = true
card.Visible = true
glow.Visible = true

print("[Kaitun Fish It] UI + Safe Instant/Perfection integrated (SIMULATION).")
print("⚠️ REMEMBER: This is safe client-side simulation only (no remote calls).")
