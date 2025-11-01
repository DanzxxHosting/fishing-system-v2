-- UI-Only: Neon Panel (sidebar + content) — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Toggle dengan tombol G. Safe (UI only).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
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

-- STATE VARIABLES
local autoFarmEnabled = false
local autoCastEnabled = false
local autoReelEnabled = false
local autoShakeEnabled = false
local autoSellEnabled = false
local selectedIsland = "None"
local selectedRod = "None"
local selectedBait = "None"

-- cleanup old if exist
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container (centered)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow (image behind)
local glow = Instance.new("ImageLabel", screen)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = container.Position
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616" -- radial
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1

-- Card (panel)
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner", card)
cardCorner.CornerRadius = UDim.new(0, 12)

-- inner container
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
title.Text = "⚡ KAITUN FISH IT — Full Featured"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local memLabel = Instance.new("TextLabel", titleBar)
memLabel.Size = UDim2.new(0.4,-16,1,0)
memLabel.Position = UDim2.new(0.6,8,0,0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 13
memLabel.Text = "Client Memory Usage: 0 MB"
memLabel.TextColor3 = Color3.fromRGB(200,200,200)
memLabel.TextXAlignment = Enum.TextXAlignment.Right

-- left sidebar
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3

local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 8)

-- sidebar header icon
local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1

local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904" -- simple icon (roblox)
logo.ImageColor3 = ACCENT

local sTitle = Instance.new("TextLabel", sbHeader)
sTitle.Size = UDim2.new(1,-96,0,32)
sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- menu list area
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)

-- menu helper
local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner", row)
    corner.CornerRadius = UDim.new(0,8)

    local left = Instance.new("Frame", row)
    left.Size = UDim2.new(0,40,1,0)
    left.Position = UDim2.new(0,8,0,0)
    left.BackgroundTransparency = 1

    local icon = Instance.new("TextLabel", left)
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

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
    {"Main", "★"},
    {"Spawn Boat", "⛵"},
    {"Buy Rod", "🪝"},
    {"Buy Weather", "☁"},
    {"Buy Bait", "🍤"},
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
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0

local contentCorner = Instance.new("UICorner", content)
contentCorner.CornerRadius = UDim.new(0, 8)

-- content title area
local cTitle = Instance.new("TextLabel", content)
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Main"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- HELPER FUNCTIONS FOR UI ELEMENTS
local function createToggle(parent, labelText, posY, callback)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(1, -24, 0, 40)
    toggleFrame.Position = UDim2.new(0, 12, 0, posY)
    toggleFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", toggleFrame)
    toggle.Size = UDim2.new(0, 50, 0, 26)
    toggle.Position = UDim2.new(1, -50, 0.5, -13)
    toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    local tCorner = Instance.new("UICorner", toggle)
    tCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(1, 0)

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10)}):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10)}):Play()
        end
        if callback then callback(state) end
    end)

    return toggleFrame, toggle
end

local function createDropdown(parent, labelText, options, posY, callback)
    local ddFrame = Instance.new("Frame", parent)
    ddFrame.Size = UDim2.new(1, -24, 0, 70)
    ddFrame.Position = UDim2.new(0, 12, 0, posY)
    ddFrame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", ddFrame)
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local ddBtn = Instance.new("TextButton", ddFrame)
    ddBtn.Size = UDim2.new(0, 200, 0, 32)
    ddBtn.Position = UDim2.new(0, 0, 0, 28)
    ddBtn.BackgroundColor3 = Color3.fromRGB(20,20,22)
    ddBtn.Font = Enum.Font.GothamBold
    ddBtn.TextSize = 14
    ddBtn.Text = options[1] or "Select"
    ddBtn.TextColor3 = Color3.fromRGB(230,230,230)
    ddBtn.AutoButtonColor = false
    local ddCorner = Instance.new("UICorner", ddBtn)
    ddCorner.CornerRadius = UDim.new(0,6)

    local ddList = Instance.new("Frame", ddFrame)
    ddList.Size = UDim2.new(0, 200, 0, 0)
    ddList.Position = UDim2.new(0, 0, 0, 64)
    ddList.BackgroundColor3 = Color3.fromRGB(18,18,20)
    ddList.BorderSizePixel = 0
    ddList.ClipsDescendants = true
    ddList.ZIndex = 10
    local ddListCorner = Instance.new("UICorner", ddList)
    ddListCorner.CornerRadius = UDim.new(0,6)

    local ddLayout = Instance.new("UIListLayout", ddList)
    ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ddLayout.Padding = UDim.new(0,4)

    for i, name in ipairs(options) do
        local it = Instance.new("TextButton", ddList)
        it.Size = UDim2.new(1, -8, 0, 28)
        it.BackgroundColor3 = Color3.fromRGB(24,24,26)
        it.Text = "  "..name
        it.Font = Enum.Font.Gotham
        it.TextSize = 13
        it.TextColor3 = Color3.fromRGB(230,230,230)
        it.AutoButtonColor = false
        it.LayoutOrder = i

        local itCorner = Instance.new("UICorner", it)
        itCorner.CornerRadius = UDim.new(0,6)
        
        it.MouseEnter:Connect(function()
            TweenService:Create(it, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,8,8)}):Play()
        end)
        it.MouseLeave:Connect(function()
            TweenService:Create(it, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(24,24,26)}):Play()
        end)
        it.MouseButton1Click:Connect(function()
            ddBtn.Text = name
            TweenService:Create(ddList, TweenInfo.new(0.18), {Size = UDim2.new(0,200,0,0)}):Play()
            if callback then callback(name) end
        end)
    end

    local ddOpen = false
    ddBtn.MouseButton1Click:Connect(function()
        ddOpen = not ddOpen
        if ddOpen then
            TweenService:Create(ddList, TweenInfo.new(0.18), {Size = UDim2.new(0,200,0, #options*34)}):Play()
        else
            TweenService:Create(ddList, TweenInfo.new(0.14), {Size = UDim2.new(0,200,0,0)}):Play()
        end
    end)

    return ddFrame, ddBtn
end

local function createButton(parent, text, posX, posY, width, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, width, 0, 34)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = ACCENT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(30,30,30)
    btn.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

-- CREATE CONTENT PANELS FOR EACH MENU
local contentPanels = {}

-- MAIN PANEL
local mainPanel = Instance.new("ScrollingFrame", content)
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(1, -24, 1, -72)
mainPanel.Position = UDim2.new(0, 12, 0, 64)
mainPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
mainPanel.BorderSizePixel = 0
mainPanel.ScrollBarThickness = 6
mainPanel.CanvasSize = UDim2.new(0, 0, 0, 600)
local mainCorner = Instance.new("UICorner", mainPanel)
mainCorner.CornerRadius = UDim.new(0,8)

createToggle(mainPanel, "Auto Farm", 10, function(state)
    autoFarmEnabled = state
    print("[Auto Farm]", state)
end)

createToggle(mainPanel, "Auto Cast", 60, function(state)
    autoCastEnabled = state
    print("[Auto Cast]", state)
end)

createToggle(mainPanel, "Auto Reel", 110, function(state)
    autoReelEnabled = state
    print("[Auto Reel]", state)
end)

createToggle(mainPanel, "Auto Shake", 160, function(state)
    autoShakeEnabled = state
    print("[Auto Shake]", state)
end)

createToggle(mainPanel, "Auto Sell Fish", 210, function(state)
    autoSellEnabled = state
    print("[Auto Sell]", state)
end)

createButton(mainPanel, "Start All", 12, 270, 120, function()
    print("[UI] Start All Features")
end)

createButton(mainPanel, "Stop All", 144, 270, 120, function()
    print("[UI] Stop All Features")
end)

contentPanels["Main"] = mainPanel

-- SPAWN BOAT PANEL
local boatPanel = Instance.new("Frame", content)
boatPanel.Name = "BoatPanel"
boatPanel.Size = UDim2.new(1, -24, 1, -72)
boatPanel.Position = UDim2.new(0, 12, 0, 64)
boatPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
boatPanel.BorderSizePixel = 0
boatPanel.Visible = false
local boatCorner = Instance.new("UICorner", boatPanel)
boatCorner.CornerRadius = UDim.new(0,8)

local boatLabel = Instance.new("TextLabel", boatPanel)
boatLabel.Size = UDim2.new(1, -24, 0, 28)
boatLabel.Position = UDim2.new(0, 12, 0, 12)
boatLabel.BackgroundTransparency = 1
boatLabel.Font = Enum.Font.GothamBold
boatLabel.TextSize = 14
boatLabel.Text = "Spawn Boat"
boatLabel.TextColor3 = Color3.fromRGB(235,235,235)
boatLabel.TextXAlignment = Enum.TextXAlignment.Left

createDropdown(boatPanel, "Select Boat Type", {"Small Boat", "Medium Boat", "Large Boat", "Speed Boat"}, 50, function(boat)
    print("[Boat Selected]", boat)
end)

createButton(boatPanel, "Spawn Boat", 12, 150, 140, function()
    print("[UI] Spawn Boat")
end)

contentPanels["Spawn Boat"] = boatPanel

-- BUY ROD PANEL
local rodPanel = Instance.new("Frame", content)
rodPanel.Name = "RodPanel"
rodPanel.Size = UDim2.new(1, -24, 1, -72)
rodPanel.Position = UDim2.new(0, 12, 0, 64)
rodPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
rodPanel.BorderSizePixel = 0
rodPanel.Visible = false
local rodCorner = Instance.new("UICorner", rodPanel)
rodCorner.CornerRadius = UDim.new(0,8)

local rodLabel = Instance.new("TextLabel", rodPanel)
rodLabel.Size = UDim2.new(1, -24, 0, 28)
rodLabel.Position = UDim2.new(0, 12, 0, 12)
rodLabel.BackgroundTransparency = 1
rodLabel.Font = Enum.Font.GothamBold
rodLabel.TextSize = 14
rodLabel.Text = "Buy Rod"
rodLabel.TextColor3 = Color3.fromRGB(235,235,235)
rodLabel.TextXAlignment = Enum.TextXAlignment.Left

createDropdown(rodPanel, "Select Rod", {"Basic Rod", "Carbon Rod", "Fast Rod", "Lucky Rod", "Kings Rod"}, 50, function(rod)
    selectedRod = rod
    print("[Rod Selected]", rod)
end)

createButton(rodPanel, "Buy Rod", 12, 150, 140, function()
    print("[UI] Buy Rod:", selectedRod)
end)

contentPanels["Buy Rod"] = rodPanel

-- BUY BAIT PANEL
local baitPanel = Instance.new("Frame", content)
baitPanel.Name = "BaitPanel"
baitPanel.Size = UDim2.new(1, -24, 1, -72)
baitPanel.Position = UDim2.new(0, 12, 0, 64)
baitPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
baitPanel.BorderSizePixel = 0
baitPanel.Visible = false
local baitCorner = Instance.new("UICorner", baitPanel)
baitCorner.CornerRadius = UDim.new(0,8)

local baitLabel = Instance.new("TextLabel", baitPanel)
baitLabel.Size = UDim2.new(1, -24, 0, 28)
baitLabel.Position = UDim2.new(0, 12, 0, 12)
baitLabel.BackgroundTransparency = 1
baitLabel.Font = Enum.Font.GothamBold
baitLabel.TextSize = 14
baitLabel.Text = "Buy Bait"
baitLabel.TextColor3 = Color3.fromRGB(235,235,235)
baitLabel.TextXAlignment = Enum.TextXAlignment.Left

createDropdown(baitPanel, "Select Bait", {"Worm", "Fish Head", "Insect", "Squid", "Shrimp"}, 50, function(bait)
    selectedBait = bait
    print("[Bait Selected]", bait)
end)

createButton(baitPanel, "Buy Bait", 12, 150, 140, function()
    print("[UI] Buy Bait:", selectedBait)
end)

contentPanels["Buy Bait"] = baitPanel

-- TELEPORT PANEL
local tpPanel = Instance.new("Frame", content)
tpPanel.Name = "TeleportPanel"
tpPanel.Size = UDim2.new(1, -24, 1, -72)
tpPanel.Position = UDim2.new(0, 12, 0, 64)
tpPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
tpPanel.BorderSizePixel = 0
tpPanel.Visible = false
local tpCorner = Instance.new("UICorner", tpPanel)
tpCorner.CornerRadius = UDim.new(0,8)

local tpLabel = Instance.new("TextLabel", tpPanel)
tpLabel.Size = UDim2.new(1, -24, 0, 28)
tpLabel.Position = UDim2.new(0, 12, 0, 12)
tpLabel.BackgroundTransparency = 1
tpLabel.Font = Enum.Font.GothamBold
tpLabel.TextSize = 14
tpLabel.Text = "Teleport"
tpLabel.TextColor3 = Color3.fromRGB(235,235,235)
tpLabel.TextXAlignment = Enum.TextXAlignment.Left

createDropdown(tpPanel, "Island", {"None","Main Island","Tropical Island","Frozen Island","Volcano Island","Pirate Cove"}, 50, function(island)
    selectedIsland = island
    print("[Island Selected]", island)
end)

createButton(tpPanel, "Teleport", 12, 150, 140, function()
    print("[UI] Teleport to:", selectedIsland)
end)

createButton(tpPanel, "Sell Fish", 164, 150, 120, function()
    print("[UI] Sell Fish")
end)

contentPanels["Teleport"] = tpPanel

-- SETTINGS PANEL
local settingsPanel = Instance.new("Frame", content)
settingsPanel.Name = "SettingsPanel"
settingsPanel.Size = UDim2.new(1, -24, 1, -72)
settingsPanel.Position = UDim2.new(0, 12, 0, 64)
settingsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
settingsPanel.BorderSizePixel = 0
settingsPanel.Visible = false
local settingsCorner = Instance.new("UICorner", settingsPanel)
settingsCorner.CornerRadius = UDim.new(0,8)

local settingsLabel = Instance.new("TextLabel", settingsPanel)
settingsLabel.Size = UDim2.new(1, -24, 0, 28)
settingsLabel.Position = UDim2.new(0, 12, 0, 12)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Font = Enum.Font.GothamBold
settingsLabel.TextSize = 14
settingsLabel.Text = "Settings"
settingsLabel.TextColor3 = Color3.fromRGB(235,235,235)
settingsLabel.TextXAlignment = Enum.TextXAlignment.Left

createToggle(settingsPanel, "Anti AFK", 60, function(state)
    print("[Anti AFK]", state)
end)

createToggle(settingsPanel, "Notifications", 110, function(state)
    print("[Notifications]", state)
end)

contentPanels["Settings"] = settingsPanel

-- BUY WEATHER PANEL (placeholder)
local weatherPanel = Instance.new("Frame", content)
weatherPanel.Name = "WeatherPanel"
weatherPanel.Size = UDim2.new(1, -24, 1, -72)
weatherPanel.Position = UDim2.new(0, 12, 0, 64)
weatherPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
weatherPanel.BorderSizePixel = 0
weatherPanel.Visible = false
local weatherCorner = Instance.new("UICorner", weatherPanel)
weatherCorner.CornerRadius = UDim.new(0,8)

local weatherLabel = Instance.new("TextLabel", weatherPanel)
weatherLabel.Size = UDim2.new(1, -24, 0, 28)
weatherLabel.Position = UDim2.new(0, 12, 0, 12)
weatherLabel.BackgroundTransparency = 1
weatherLabel.Font = Enum.Font.GothamBold
weatherLabel.TextSize = 14
weatherLabel.Text = "Buy Weather"
weatherLabel.TextColor3 = Color3.fromRGB(235,235,235)
weatherLabel.TextXAlignment = Enum.TextXAlignment.Left

createDropdown(weatherPanel, "Select Weather", {"Clear", "Rain", "Storm", "Fog", "Aurora"}, 50, function(weather)
    print("[Weather Selected]", weather)
end)

createButton(weatherPanel, "Buy Weather", 12, 150, 140, function()
    print("[UI] Buy Weather")
end)

contentPanels["Buy Weather"] = weatherPanel

-- MENU NAVIGATION
local activeMenu = "Main"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- highlight selected
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        -- hide all panels
        for panelName, panel in pairs(contentPanels) do
            panel.Visible = false
        end
        
        -- show selected panel
        if contentPanels[name] then
            contentPanels[name].Visible = true
        end
        
        -- set content title
        cTitle.Text = name
        activeMenu = name
        print("[UI] Menu selected:", name)
    end)
end

-- Set Main as default
menuButtons["Main"].BackgroundColor3 = Color3.fromRGB(32,8,8)
mainPanel.Visible = true

-- AUTOMATION FUNCTIONS
local function autoCast()
    while autoCastEnabled do
        pcall(function()
            local rod = player.Character:FindFirstChild("Rod")
            if rod then
                local castEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(100)
                    print("[Auto Cast] Casting rod")
                end
            end
        end)
        wait(0.5)
    end
end

local function autoReel()
    while autoReelEnabled do
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local reelFinish = playerGui:FindFirstChild("reel"):FindFirstChild("bar"):FindFirstChild("reelfinish")
                if reelFinish and reelFinish.Visible then
                    local reelEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("reelfinished")
                    if reelEvent then
                        reelEvent:FireServer(100, true)
                        print("[Auto Reel] Reeling complete")
                    end
                end
            end
        end)
        wait(0.1)
    end
end

local function autoShake()
    while autoShakeEnabled do
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local shakeUI = playerGui:FindFirstChild("shakeui")
                if shakeUI and shakeUI.Enabled then
                    local safezone = shakeUI:FindFirstChild("safezone")
                    if safezone then
                        local shakeEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("shakereeled")
                        if shakeEvent then
                            shakeEvent:FireServer(100, true)
                            print("[Auto Shake] Shake completed")
                        end
                    end
                end
            end
        end)
        wait(0.1)
    end
end

local function autoSell()
    while autoSellEnabled do
        pcall(function()
            local sellPoint = workspace:FindFirstChild("world"):FindFirstChild("npcs"):FindFirstChild("Merchant")
            if sellPoint then
                player.Character:WaitForChild("HumanoidRootPart").CFrame = sellPoint.HumanoidRootPart.CFrame
                wait(0.5)
                local sellEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("sellfish")
                if sellEvent then
                    sellEvent:FireServer()
                    print("[Auto Sell] Fish sold")
                end
            end
        end)
        wait(10)
    end
end

-- Start automation loops
spawn(function()
    while wait(0.5) do
        if autoCastEnabled and not autoFarmEnabled then
            spawn(autoCast)
        end
        if autoReelEnabled and not autoFarmEnabled then
            spawn(autoReel)
        end
        if autoShakeEnabled and not autoFarmEnabled then
            spawn(autoShake)
        end
        if autoSellEnabled and not autoFarmEnabled then
            spawn(autoSell)
        end
    end
end)

-- AUTO FARM (all-in-one)
spawn(function()
    while wait(0.5) do
        if autoFarmEnabled then
            -- Auto Cast
            pcall(function()
                local rod = player.Character:FindFirstChild("Rod")
                if rod then
                    local castEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("cast")
                    if castEvent then
                        castEvent:FireServer(100)
                    end
                end
            end)
            
            -- Auto Reel
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local reelFinish = playerGui:FindFirstChild("reel"):FindFirstChild("bar"):FindFirstChild("reelfinish")
                    if reelFinish and reelFinish.Visible then
                        local reelEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("reelfinished")
                        if reelEvent then
                            reelEvent:FireServer(100, true)
                        end
                    end
                end
            end)
            
            -- Auto Shake
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local shakeUI = playerGui:FindFirstChild("shakeui")
                    if shakeUI and shakeUI.Enabled then
                        local safezone = shakeUI:FindFirstChild("safezone")
                        if safezone then
                            local shakeEvent = ReplicatedStorage:FindFirstChild("events"):FindFirstChild("shakereeled")
                            if shakeEvent then
                                shakeEvent:FireServer(100, true)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ANTI AFK
local antiAFK = false
spawn(function()
    while wait(60) do
        if antiAFK then
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- TOGGLE UI (with animation)
local uiOpen = false
local function toggleUI(show)
    uiOpen = show
    if show then
        card.Visible = true
        glow.Visible = true
        container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
        container.AnchorPoint = Vector2.new(0.5,0.5)
        container.ZIndex = 2
        card:TweenSize(UDim2.new(0, WIDTH,0,HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.28, true)
        TweenService:Create(glow, TweenInfo.new(0.28), {ImageTransparency = 0.8}):Play()
    else
        TweenService:Create(glow, TweenInfo.new(0.18), {ImageTransparency = 0.96}):Play()
        card:TweenSize(UDim2.new(0, WIDTH*0.9,0,HEIGHT*0.9), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.16, true)
        delay(0.16, function()
            card.Visible = false
            glow.Visible = false
        end)
    end
end

-- initial hide
toggleUI(false)

-- Keybind toggle (G)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        toggleUI(not uiOpen)
    end
end)

-- Memory usage update
spawn(function()
    while true do
        local mem = math.floor(collectgarbage("count"))
        memLabel.Text = "Client Memory: "..mem.." KB"
        wait(1.2)
    end
end)

print("[NeonDashboardUI] Loaded with all features. Press G to toggle.")
print("[Info] Auto Farm includes: Cast, Reel, Shake automatically")
print("[Info] Individual toggles available when Auto Farm is OFF")
