-- UI-Only: Neon Panel (sidebar + content) — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam transparan + neon merah & biru. Mobile-friendly dengan toggle button. Safe (UI only).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 400  -- Diperkecil untuk mobile
local HEIGHT = 500 -- Diperkecil untuk mobile
local SIDEBAR_W = 150 -- Diperkecil untuk mobile
local ACCENT_RED = Color3.fromRGB(255, 62, 62) -- neon merah
local ACCENT_BLUE = Color3.fromRGB(62, 62, 255) -- neon biru
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

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
container.Visible = true

-- Outer glow (image behind)
local glow = Instance.new("ImageLabel", container)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(1, 80, 1, 80)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616" -- radial
glow.ImageColor3 = ACCENT_RED
glow.ImageTransparency = 0.92
glow.ZIndex = 1

-- Card (panel) - TRANSPARAN
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(1, 0, 1, 0)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BackgroundTransparency = 0.3 -- TRANSPARAN
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2
card.Visible = true

local cardCorner = Instance.new("UICorner", card)
cardCorner.CornerRadius = UDim.new(0, 12)

-- inner container
local inner = Instance.new("Frame", card)
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1

-- Title bar - TRANSPARAN
local titleBar = Instance.new("Frame", inner)
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundColor3 = BG
titleBar.BackgroundTransparency = 0.4 -- TRANSPARAN
titleBar.BorderSizePixel = 0

local titleBarCorner = Instance.new("UICorner", titleBar)
titleBarCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = "⚡ KAITUN FISH IT"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local memLabel = Instance.new("TextLabel", titleBar)
memLabel.Size = UDim2.new(0.4,-16,1,0)
memLabel.Position = UDim2.new(0.6,8,0,0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 11
memLabel.Text = "Memory: 0 KB"
memLabel.TextColor3 = Color3.fromRGB(200,200,200)
memLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Toggle Button untuk Mobile (di pojok kanan atas)
local toggleButton = Instance.new("TextButton", screen)
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(1, -110, 0, 10)
toggleButton.BackgroundColor3 = ACCENT_RED
toggleButton.BackgroundTransparency = 0.2
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Text = "Open UI"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false
toggleButton.ZIndex = 100
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 6)

-- Hover effect untuk toggle button
toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
end)
toggleButton.MouseLeave:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
end)

-- left sidebar - TRANSPARAN
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BackgroundTransparency = 0.4 -- TRANSPARAN
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3

local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 8)

-- sidebar header icon
local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,60)
sbHeader.BackgroundTransparency = 1

local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,40,0,40)
logo.Position = UDim2.new(0, 8, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904"
logo.ImageColor3 = ACCENT_RED

local sTitle = Instance.new("TextLabel", sbHeader)
sTitle.Size = UDim2.new(1,-56,0,24)
sTitle.Position = UDim2.new(0, 56, 0, 18)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- menu list area
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-8,1, -76)
menuFrame.Position = UDim2.new(0, 4, 0, 68)
menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,6)

-- menu helper
local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.BackgroundTransparency = 0.3
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner", row)
    corner.CornerRadius = UDim.new(0,6)

    local left = Instance.new("Frame", row)
    left.Size = UDim2.new(0,32,1,0)
    left.Position = UDim2.new(0,6,0,0)
    left.BackgroundTransparency = 1

    local icon = Instance.new("TextLabel", left)
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 14
    icon.Text = iconText
    icon.TextColor3 = ACCENT_RED
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,44,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10), BackgroundTransparency = 0.2}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20), BackgroundTransparency = 0.3}):Play()
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
    {"Auto Fishing", "🎣"},
    {"Settings", "⚙"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- content panel (right) - TRANSPARAN
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 12, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 8, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BackgroundTransparency = 0.4
content.BorderSizePixel = 0

local contentCorner = Instance.new("UICorner", content)
contentCorner.CornerRadius = UDim.new(0, 8)

-- content title area
local cTitle = Instance.new("TextLabel", content)
cTitle.Size = UDim2.new(1, -16, 0, 36)
cTitle.Position = UDim2.new(0,8,0,8)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Main"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- EFEK PARTIKEL MERAH & BIRU
local particleContainer = Instance.new("Frame", container)
particleContainer.Name = "ParticleContainer"
particleContainer.Size = UDim2.new(1, 0, 1, 0)
particleContainer.Position = UDim2.new(0, 0, 0, 0)
particleContainer.BackgroundTransparency = 1
particleContainer.ZIndex = 0

local particles = {}
local particleCount = 20

-- Fungsi untuk membuat partikel
local function createParticle()
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
    particle.Position = UDim2.new(0, math.random(-50, WIDTH + 50), 0, math.random(-50, HEIGHT + 50))
    particle.BackgroundColor3 = math.random() > 0.5 and ACCENT_RED or ACCENT_BLUE
    particle.BackgroundTransparency = 0.7
    particle.BorderSizePixel = 0
    particle.ZIndex = 0
    particle.Parent = particleContainer
    
    local corner = Instance.new("UICorner", particle)
    corner.CornerRadius = UDim.new(1, 0)
    
    return {
        frame = particle,
        speedX = (math.random() - 0.5) * 1.5,
        speedY = (math.random() - 0.5) * 1.5,
        opacity = 0.7,
        pulseSpeed = math.random() * 0.02 + 0.01
    }
end

-- Buat partikel
for i = 1, particleCount do
    table.insert(particles, createParticle())
end

-- Update partikel
local particleConnection
local function startParticles()
    if particleConnection then
        particleConnection:Disconnect()
    end
    
    particleConnection = RunService.Heartbeat:Connect(function(delta)
        for _, p in ipairs(particles) do
            local posX = p.frame.Position.X.Offset + p.speedX
            local posY = p.frame.Position.Y.Offset + p.speedY
            
            -- Boundary check
            if posX < -50 then posX = WIDTH + 50 end
            if posX > WIDTH + 50 then posX = -50 end
            if posY < -50 then posY = HEIGHT + 50 end
            if posY > HEIGHT + 50 then posY = -50 end
            
            p.frame.Position = UDim2.new(0, posX, 0, posY)
            
            -- Pulsing effect
            p.opacity = 0.5 + math.sin(tick() * p.pulseSpeed) * 0.2
            p.frame.BackgroundTransparency = 1 - p.opacity
        end
    end)
end

-- =============================================
-- CONTENT FUNCTIONS
-- =============================================

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child.Name ~= "ContentCorner" then
            child:Destroy()
        end
    end
end

local function showDefaultContent(menuName)
    clearContent()
    
    local placeholder = Instance.new("TextLabel", content)
    placeholder.Size = UDim2.new(1, -24, 1, -24)
    placeholder.Position = UDim2.new(0, 12, 0, 12)
    placeholder.BackgroundTransparency = 1
    placeholder.Font = Enum.Font.GothamBold
    placeholder.TextSize = 18
    placeholder.Text = menuName .. "\n\n(Content Coming Soon)"
    placeholder.TextColor3 = Color3.fromRGB(200,200,200)
    placeholder.TextYAlignment = Enum.TextYAlignment.Center
    placeholder.TextXAlignment = Enum.TextXAlignment.Center
end

-- TELEPORT CONTENT
local function showTeleportContent()
    clearContent()
    
    local teleportPanel = Instance.new("Frame", content)
    teleportPanel.Name = "TeleportPanel"
    teleportPanel.Size = UDim2.new(1, -24, 1, -24)
    teleportPanel.Position = UDim2.new(0, 12, 0, 12)
    teleportPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    teleportPanel.BackgroundTransparency = 0.3
    teleportPanel.BorderSizePixel = 0
    
    local panelCorner = Instance.new("UICorner", teleportPanel)
    panelCorner.CornerRadius = UDim.new(0,8)
    
    -- Title
    local title = Instance.new("TextLabel", teleportPanel)
    title.Size = UDim2.new(1, -16, 0, 32)
    title.Position = UDim2.new(0, 8, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Text = "Teleport System"
    title.TextColor3 = Color3.fromRGB(255, 220, 220)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Location Selection
    local locationFrame = Instance.new("Frame", teleportPanel)
    locationFrame.Size = UDim2.new(1, -16, 0, 120)
    locationFrame.Position = UDim2.new(0, 8, 0, 48)
    locationFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
    locationFrame.BackgroundTransparency = 0.4
    locationFrame.BorderSizePixel = 0
    
    local locationCorner = Instance.new("UICorner", locationFrame)
    locationCorner.CornerRadius = UDim.new(0,6)
    
    local locationLabel = Instance.new("TextLabel", locationFrame)
    locationLabel.Size = UDim2.new(1, -12, 0, 24)
    locationLabel.Position = UDim2.new(0, 6, 0, 6)
    locationLabel.BackgroundTransparency = 1
    locationLabel.Font = Enum.Font.GothamBold
    locationLabel.TextSize = 14
    locationLabel.Text = "Select Destination:"
    locationLabel.TextColor3 = Color3.fromRGB(200,200,200)
    locationLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Location Dropdown
    local locationBtn = Instance.new("TextButton", locationFrame)
    locationBtn.Size = UDim2.new(1, -12, 0, 32)
    locationBtn.Position = UDim2.new(0, 6, 0, 34)
    locationBtn.BackgroundColor3 = Color3.fromRGB(30,30,32)
    locationBtn.BackgroundTransparency = 0.3
    locationBtn.Font = Enum.Font.Gotham
    locationBtn.TextSize = 12
    locationBtn.Text = "Click to select location"
    locationBtn.TextColor3 = Color3.fromRGB(230,230,230)
    locationBtn.AutoButtonColor = false
    
    local locationBtnCorner = Instance.new("UICorner", locationBtn)
    locationBtnCorner.CornerRadius = UDim.new(0,6)
    
    -- Location List
    local locationList = Instance.new("ScrollingFrame", locationFrame)
    locationList.Size = UDim2.new(1, -12, 0, 0)
    locationList.Position = UDim2.new(0, 6, 0, 70)
    locationList.BackgroundColor3 = Color3.fromRGB(25,25,28)
    locationList.BackgroundTransparency = 0.2
    locationList.BorderSizePixel = 0
    locationList.ScrollBarThickness = 4
    locationList.ClipsDescendants = true
    locationList.Visible = false
    
    local locationListCorner = Instance.new("UICorner", locationList)
    locationListCorner.CornerRadius = UDim.new(0,6)
    
    local locationListLayout = Instance.new("UIListLayout", locationList)
    locationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    locationListLayout.Padding = UDim.new(0,4)
    
    -- Locations Data
    local locations = {
        {"Spawn Point", "Spawn Area", Color3.fromRGB(100, 200, 100)},
        {"Fishing Spot 1", "Best fishing location", Color3.fromRGB(100, 150, 255)},
        {"Fishing Spot 2", "Rare fish area", Color3.fromRGB(100, 150, 255)},
        {"Market", "Sell your fish", Color3.fromRGB(255, 200, 100)},
        {"Boat Shop", "Buy boats", Color3.fromRGB(255, 150, 100)},
        {"Rod Shop", "Upgrade rods", Color3.fromRGB(200, 100, 255)},
        {"Secret Island", "Hidden location", Color3.fromRGB(255, 100, 200)}
    }
    
    local selectedLocation = nil
    
    -- Create location buttons
    for i, location in ipairs(locations) do
        local locationItem = Instance.new("TextButton", locationList)
        locationItem.Size = UDim2.new(1, -8, 0, 40)
        locationItem.Position = UDim2.new(0, 4, 0, (i-1)*44)
        locationItem.BackgroundColor3 = Color3.fromRGB(35,35,38)
        locationItem.BackgroundTransparency = 0.3
        locationItem.Text = ""
        locationItem.AutoButtonColor = false
        locationItem.LayoutOrder = i
        
        local itemCorner = Instance.new("UICorner", locationItem)
        itemCorner.CornerRadius = UDim.new(0,4)
        
        local nameLabel = Instance.new("TextLabel", locationItem)
        nameLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.Text = location[1]
        nameLabel.TextColor3 = location[3]
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLabel = Instance.new("TextLabel", locationItem)
        descLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
        descLabel.Position = UDim2.new(0, 8, 0, 22)
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 10
        descLabel.Text = location[2]
        descLabel.TextColor3 = Color3.fromRGB(180,180,180)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Hover effects
        locationItem.MouseEnter:Connect(function()
            TweenService:Create(locationItem, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45,45,48), BackgroundTransparency = 0.2}):Play()
        end)
        locationItem.MouseLeave:Connect(function()
            TweenService:Create(locationItem, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35,35,38), BackgroundTransparency = 0.3}):Play()
        end)
        
        locationItem.MouseButton1Click:Connect(function()
            selectedLocation = location[1]
            locationBtn.Text = location[1]
            locationList.Visible = false
            locationList.Size = UDim2.new(1, -12, 0, 0)
        end)
    end
    
    -- Toggle location list
    locationBtn.MouseButton1Click:Connect(function()
        locationList.Visible = not locationList.Visible
        if locationList.Visible then
            locationList.Size = UDim2.new(1, -12, 0, 160)
        else
            locationList.Size = UDim2.new(1, -12, 0, 0)
        end
    end)
    
    -- Action Buttons
    local actionFrame = Instance.new("Frame", teleportPanel)
    actionFrame.Size = UDim2.new(1, -16, 0, 80)
    actionFrame.Position = UDim2.new(0, 8, 1, -88)
    actionFrame.BackgroundTransparency = 1
    actionFrame.BorderSizePixel = 0
    
    local teleportBtn = Instance.new("TextButton", actionFrame)
    teleportBtn.Size = UDim2.new(0.6, -4, 0, 40)
    teleportBtn.Position = UDim2.new(0, 0, 0, 0)
    teleportBtn.BackgroundColor3 = ACCENT_RED
    teleportBtn.BackgroundTransparency = 0.2
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextSize = 14
    teleportBtn.Text = "TELEPORT"
    teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportBtn.AutoButtonColor = false
    
    local teleportCorner = Instance.new("UICorner", teleportBtn)
    teleportCorner.CornerRadius = UDim.new(0,6)
    
    local cancelBtn = Instance.new("TextButton", actionFrame)
    cancelBtn.Size = UDim2.new(0.4, -4, 0, 40)
    cancelBtn.Position = UDim2.new(0.6, 4, 0, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(60,60,65)
    cancelBtn.BackgroundTransparency = 0.3
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 14
    cancelBtn.Text = "CANCEL"
    cancelBtn.TextColor3 = Color3.fromRGB(200,200,200)
    cancelBtn.AutoButtonColor = false
    
    local cancelCorner = Instance.new("UICorner", cancelBtn)
    cancelCorner.CornerRadius = UDim.new(0,6)
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel", teleportPanel)
    statusLabel.Size = UDim2.new(1, -16, 0, 24)
    statusLabel.Position = UDim2.new(0, 8, 1, -120)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Text = "Select a location to teleport"
    statusLabel.TextColor3 = Color3.fromRGB(180,180,180)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Teleport Function
    local function teleportPlayer()
        if not selectedLocation then
            statusLabel.Text = "Please select a location first!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        statusLabel.Text = "Teleporting to " .. selectedLocation .. "..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        -- Simulate teleport process
        wait(2)
        
        -- Success message
        statusLabel.Text = "Successfully teleported to " .. selectedLocation .. "!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        print("[Teleport] Teleported to:", selectedLocation)
    end
    
    -- Button Clicks
    teleportBtn.MouseButton1Click:Connect(teleportPlayer)
    
    cancelBtn.MouseButton1Click:Connect(function()
        selectedLocation = nil
        locationBtn.Text = "Click to select location"
        statusLabel.Text = "Teleport cancelled"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end)
    
    -- Hover Effects
    teleportBtn.MouseEnter:Connect(function()
        TweenService:Create(teleportBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
    end)
    teleportBtn.MouseLeave:Connect(function()
        TweenService:Create(teleportBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
    end)
    
    cancelBtn.MouseEnter:Connect(function()
        TweenService:Create(cancelBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
    end)
    cancelBtn.MouseLeave:Connect(function()
        TweenService:Create(cancelBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play()
    end)
    
    locationBtn.MouseEnter:Connect(function()
        TweenService:Create(locationBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
    end)
    locationBtn.MouseLeave:Connect(function()
        TweenService:Create(locationBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play()
    end)
end

-- AUTO FISHING CONTENT
local AutoFishing = {
    Enabled = false,
    Fishing = false,
    LastCatch = 0,
    TotalCatches = 0
}

local function showAutoFishingContent()
    clearContent()
    
    local fishingPanel = Instance.new("Frame", content)
    fishingPanel.Name = "FishingPanel"
    fishingPanel.Size = UDim2.new(1, -24, 1, -24)
    fishingPanel.Position = UDim2.new(0, 12, 0, 12)
    fishingPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    fishingPanel.BackgroundTransparency = 0.3
    fishingPanel.BorderSizePixel = 0
    
    local panelCorner = Instance.new("UICorner", fishingPanel)
    panelCorner.CornerRadius = UDim.new(0,8)
    
    -- Title
    local title = Instance.new("TextLabel", fishingPanel)
    title.Size = UDim2.new(1, -16, 0, 32)
    title.Position = UDim2.new(0, 8, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Text = "Auto Fishing System"
    title.TextColor3 = Color3.fromRGB(255, 220, 220)
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Status Indicator
    local statusFrame = Instance.new("Frame", fishingPanel)
    statusFrame.Size = UDim2.new(1, -16, 0, 60)
    statusFrame.Position = UDim2.new(0, 8, 0, 48)
    statusFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
    statusFrame.BackgroundTransparency = 0.4
    statusFrame.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner", statusFrame)
    statusCorner.CornerRadius = UDim.new(0,6)
    
    local statusLabel = Instance.new("TextLabel", statusFrame)
    statusLabel.Size = UDim2.new(1, -12, 0, 24)
    statusLabel.Position = UDim2.new(0, 6, 0, 6)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14
    statusLabel.Text = "Status: IDLE"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local statsLabel = Instance.new("TextLabel", statusFrame)
    statsLabel.Size = UDim2.new(1, -12, 0, 24)
    statsLabel.Position = UDim2.new(0, 6, 0, 30)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextSize = 12
    statsLabel.Text = "Total Catches: 0 | Last: Never"
    statsLabel.TextColor3 = Color3.fromRGB(180,180,180)
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton", fishingPanel)
    toggleBtn.Size = UDim2.new(1, -16, 0, 40)
    toggleBtn.Position = UDim2.new(0, 8, 0, 120)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Text = "START AUTO FISHING"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(0,6)
    
    -- Settings
    local settingsFrame = Instance.new("Frame", fishingPanel)
    settingsFrame.Size = UDim2.new(1, -16, 0, 80)
    settingsFrame.Position = UDim2.new(0, 8, 0, 170)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
    settingsFrame.BackgroundTransparency = 0.4
    settingsFrame.BorderSizePixel = 0
    
    local settingsCorner = Instance.new("UICorner", settingsFrame)
    settingsCorner.CornerRadius = UDim.new(0,6)
    
    -- Delay Setting
    local delayLabel = Instance.new("TextLabel", settingsFrame)
    delayLabel.Size = UDim2.new(0.6, 0, 0, 24)
    delayLabel.Position = UDim2.new(0, 8, 0, 8)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Font = Enum.Font.Gotham
    delayLabel.TextSize = 12
    delayLabel.Text = "Fishing Delay (seconds):"
    delayLabel.TextColor3 = Color3.fromRGB(200,200,200)
    delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local delayValue = Instance.new("TextLabel", settingsFrame)
    delayValue.Size = UDim2.new(0.3, -8, 0, 24)
    delayValue.Position = UDim2.new(0.7, 0, 0, 8)
    delayValue.BackgroundTransparency = 1
    delayValue.Font = Enum.Font.GothamBold
    delayValue.TextSize = 12
    delayValue.Text = "5"
    delayValue.TextColor3 = ACCENT_RED
    delayValue.TextXAlignment = Enum.TextXAlignment.Right
    
    local delaySlider = Instance.new("TextButton", settingsFrame)
    delaySlider.Size = UDim2.new(1, -16, 0, 20)
    delaySlider.Position = UDim2.new(0, 8, 0, 32)
    delaySlider.BackgroundColor3 = Color3.fromRGB(40,40,42)
    delaySlider.BackgroundTransparency = 0.3
    delaySlider.Font = Enum.Font.Gotham
    delaySlider.TextSize = 10
    delaySlider.Text = "← 3 • 5 • 7 →"
    delaySlider.TextColor3 = Color3.fromRGB(180,180,180)
    delaySlider.AutoButtonColor = false
    
    local sliderCorner = Instance.new("UICorner", delaySlider)
    sliderCorner.CornerRadius = UDim.new(0,4)
    
    -- Auto Sell Toggle
    local autoSellToggle = Instance.new("TextButton", settingsFrame)
    autoSellToggle.Size = UDim2.new(1, -16, 0, 24)
    autoSellToggle.Position = UDim2.new(0, 8, 0, 56)
    autoSellToggle.BackgroundColor3 = Color3.fromRGB(40,40,42)
    autoSellToggle.BackgroundTransparency = 0.3
    autoSellToggle.Font = Enum.Font.Gotham
    autoSellToggle.TextSize = 12
    autoSellToggle.Text = "Auto Sell: OFF"
    autoSellToggle.TextColor3 = Color3.fromRGB(200,200,200)
    autoSellToggle.AutoButtonColor = false
    
    local toggleSellCorner = Instance.new("UICorner", autoSellToggle)
    toggleSellCorner.CornerRadius = UDim.new(0,4)
    
    -- Fishing Functions
    local function simulateFishing()
        if not AutoFishing.Enabled then return end
        
        AutoFishing.Fishing = true
        statusLabel.Text = "Status: FISHING..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        -- Simulate fishing process
        wait(2)
        
        if AutoFishing.Enabled then
            -- Simulate catch
            AutoFishing.TotalCatches = AutoFishing.TotalCatches + 1
            AutoFishing.LastCatch = os.time()
            
            -- Update stats
            local timeAgo = "Just now"
            statsLabel.Text = string.format("Total Catches: %d | Last: %s", AutoFishing.TotalCatches, timeAgo)
            
            -- Simulate auto sell
            if autoSellToggle.Text == "Auto Sell: ON" then
                statusLabel.Text = "Status: SELLING FISH..."
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                wait(1)
            end
            
            statusLabel.Text = "Status: WAITING..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end
    
    local function startFishingLoop()
        AutoFishing.Enabled = true
        toggleBtn.Text = "STOP AUTO FISHING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        statusLabel.Text = "Status: STARTING..."
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        spawn(function()
            while AutoFishing.Enabled do
                if not AutoFishing.Fishing then
                    simulateFishing()
                end
                
                local delay = tonumber(delayValue.Text)
                wait(delay)
                
                if AutoFishing.Enabled then
                    AutoFishing.Fishing = false
                end
            end
        end)
    end
    
    local function stopFishingLoop()
        AutoFishing.Enabled = false
        AutoFishing.Fishing = false
        toggleBtn.Text = "START AUTO FISHING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        statusLabel.Text = "Status: IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    end
    
    -- Toggle Button Click
    toggleBtn.MouseButton1Click:Connect(function()
        if AutoFishing.Enabled then
            stopFishingLoop()
        else
            startFishingLoop()
        end
    end)
    
    -- Delay Slider
    delaySlider.MouseButton1Click:Connect(function()
        local current = tonumber(delayValue.Text)
        if current == 3 then
            delayValue.Text = "5"
        elseif current == 5 then
            delayValue.Text = "7"
        else
            delayValue.Text = "3"
        end
    end)
    
    -- Auto Sell Toggle
    local autoSellEnabled = false
    autoSellToggle.MouseButton1Click:Connect(function()
        autoSellEnabled = not autoSellEnabled
        if autoSellEnabled then
            autoSellToggle.Text = "Auto Sell: ON"
            autoSellToggle.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        else
            autoSellToggle.Text = "Auto Sell: OFF"
            autoSellToggle.BackgroundColor3 = Color3.fromRGB(40,40,42)
        end
    end)
    
    -- Hover Effects
    toggleBtn.MouseEnter:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
    end)
    toggleBtn.MouseLeave:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
    end)
    
    delaySlider.MouseEnter:Connect(function()
        TweenService:Create(delaySlider, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
    end)
    delaySlider.MouseLeave:Connect(function()
        TweenService:Create(delaySlider, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play()
    end)
    
    autoSellToggle.MouseEnter:Connect(function()
        TweenService:Create(autoSellToggle, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
    end)
    autoSellToggle.MouseLeave:Connect(function()
        TweenService:Create(autoSellToggle, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play()
    end)
end

-- =============================================
-- MAIN UI SYSTEM
-- =============================================

-- Menu Navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- highlight selected
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
            b.BackgroundTransparency = 0.3
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        btn.BackgroundTransparency = 0.2
        
        -- set content title
        cTitle.Text = name
        
        -- Update content berdasarkan menu yang dipilih
        if name == "Teleport" then
            showTeleportContent()
        elseif name == "Auto Fishing" then
            showAutoFishingContent()
        else
            showDefaultContent(name)
        end
    end)
end

-- Toggle UI Function
local uiOpen = false
local function toggleUI(show)
    uiOpen = show
    
    if show then
        -- Show UI dengan animasi
        container.Visible = true
        container.BackgroundTransparency = 1
        
        -- Scale animation
        container.Size = UDim2.new(0, WIDTH * 0.8, 0, HEIGHT * 0.8)
        container.Position = UDim2.new(0.5, -WIDTH * 0.4, 0.5, -HEIGHT * 0.4)
        
        local openTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, WIDTH, 0, HEIGHT),
            Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        })
        openTween:Play()
        
        TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.8}):Play()
        
        startParticles()
        toggleButton.Text = "Close UI"
    else
        -- Hide UI dengan animasi
        TweenService:Create(glow, TweenInfo.new(0.2), {ImageTransparency = 0.96}):Play()
        
        local closeTween = TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, WIDTH * 0.8, 0, HEIGHT * 0.8),
            Position = UDim2.new(0.5, -WIDTH * 0.4, 0.5, -HEIGHT * 0.4)
        })
        closeTween:Play()
        
        closeTween.Completed:Connect(function()
            container.Visible = false
            if particleConnection then
                particleConnection:Disconnect()
                particleConnection = nil
            end
            toggleButton.Text = "Open UI"
        end)
    end
end

-- Toggle Button Functionality
toggleButton.MouseButton1Click:Connect(function()
    toggleUI(not uiOpen)
end)

-- Initial state - UI hidden
container.Visible = false
toggleButton.Text = "Open UI"

-- Memory monitor
spawn(function()
    while true do
        local mem = math.floor(collectgarbage("count"))
        memLabel.Text = "Memory: "..mem.." KB"
        wait(1.2)
    end
end)

-- Show default content pertama kali
showDefaultContent("Main")

print("[Kaitun Fish IT] UI Loaded Successfully!")
print("- Toggle Button: Click to open/close")
print("- Features: Teleport, Auto Fishing, and more!")
