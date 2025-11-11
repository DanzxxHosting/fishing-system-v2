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
container.Visible = true -- PASTIKAN VISIBLE

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
card.Visible = true -- PASTIKAN VISIBLE

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
local toggleButton = Instance.new("TextButton", screen) -- Parent ke screen agar selalu visible
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(1, -110, 0, 10)
toggleButton.BackgroundColor3 = ACCENT_RED
toggleButton.BackgroundTransparency = 0.2
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Text = "Open UI"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false
toggleButton.ZIndex = 100 -- High zindex agar selalu di atas
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
logo.Image = "rbxassetid://3926305904" -- simple icon (roblox)
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
    row.BackgroundTransparency = 0.3 -- TRANSPARAN
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

-- menu items (order like photo)
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

-- content panel (right) - TRANSPARAN
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 12, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 8, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BackgroundTransparency = 0.4 -- TRANSPARAN
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
cTitle.Text = "Teleport"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- inside content: example teleport UI (dropdown + buttons)
local panel = Instance.new("Frame", content)
panel.Size = UDim2.new(1, -16, 0, 180)
panel.Position = UDim2.new(0, 8, 0, 52)
panel.BackgroundColor3 = Color3.fromRGB(14,14,16)
panel.BackgroundTransparency = 0.3 -- TRANSPARAN
panel.BorderSizePixel = 0

local pCorner = Instance.new("UICorner", panel)
pCorner.CornerRadius = UDim.new(0,8)

local pTitle = Instance.new("TextLabel", panel)
pTitle.Size = UDim2.new(1, -16, 0, 24)
pTitle.Position = UDim2.new(0,8,0,6)
pTitle.BackgroundTransparency = 1
pTitle.Font = Enum.Font.GothamBold
pTitle.TextSize = 14
pTitle.Text = "Teleport"
pTitle.TextColor3 = Color3.fromRGB(235,235,235)
pTitle.TextXAlignment = Enum.TextXAlignment.Left

-- dropdown label
local ddLabel = Instance.new("TextLabel", panel)
ddLabel.Size = UDim2.new(0.6,0,0,20)
ddLabel.Position = UDim2.new(0,8,0,36)
ddLabel.BackgroundTransparency = 1
ddLabel.Font = Enum.Font.Gotham
ddLabel.TextSize = 12
ddLabel.Text = "Island"
ddLabel.TextColor3 = Color3.fromRGB(200,200,200)
ddLabel.TextXAlignment = Enum.TextXAlignment.Left

-- dropdown button - TRANSPARAN
local ddBtn = Instance.new("TextButton", panel)
ddBtn.Size = UDim2.new(1, -16, 0, 28)
ddBtn.Position = UDim2.new(0, 8, 0, 58)
ddBtn.BackgroundColor3 = Color3.fromRGB(20,20,22)
ddBtn.BackgroundTransparency = 0.3 -- TRANSPARAN
ddBtn.Font = Enum.Font.GothamBold
ddBtn.TextSize = 12
ddBtn.Text = "Select island"
ddBtn.TextColor3 = Color3.fromRGB(230,230,230)
ddBtn.AutoButtonColor = false
local ddCorner = Instance.new("UICorner", ddBtn); ddCorner.CornerRadius = UDim.new(0,6)

-- dropdown list (frame) - TRANSPARAN
local ddList = Instance.new("Frame", panel)
ddList.Size = UDim2.new(1, -16, 0, 0)
ddList.Position = UDim2.new(0, 8, 0, 88)
ddList.BackgroundColor3 = Color3.fromRGB(18,18,20)
ddList.BackgroundTransparency = 0.2 -- TRANSPARAN
ddList.BorderSizePixel = 0
ddList.ClipsDescendants = true
local ddListCorner = Instance.new("UICorner", ddList); ddListCorner.CornerRadius = UDim.new(0,6)

local ddLayout = Instance.new("UIListLayout", ddList)
ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
ddLayout.Padding = UDim.new(0,4)

-- sample islands
local islandNames = {"None","Main Island","Tropical Island","Frozen Island","Volcano Island","Pirate Cove"}
for i, name in ipairs(islandNames) do
    local it = Instance.new("TextButton", ddList)
    it.Size = UDim2.new(1, -8, 0, 24)
    it.Position = UDim2.new(0,4,0, (i-1)*28)
    it.BackgroundColor3 = Color3.fromRGB(24,24,26)
    it.BackgroundTransparency = 0.2 -- TRANSPARAN
    it.Text = "  "..name
    it.Font = Enum.Font.Gotham
    it.TextSize = 11
    it.TextColor3 = Color3.fromRGB(230,230,230)
    it.AutoButtonColor = false
    it.LayoutOrder = i

    local itCorner = Instance.new("UICorner", it); itCorner.CornerRadius = UDim.new(0,6)
    it.MouseEnter:Connect(function() TweenService:Create(it, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,8,8), BackgroundTransparency = 0.1}):Play() end)
    it.MouseLeave:Connect(function() TweenService:Create(it, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(24,24,26), BackgroundTransparency = 0.2}):Play() end)
    it.MouseButton1Click:Connect(function()
        ddBtn.Text = name
        -- close list
        TweenService:Create(ddList, TweenInfo.new(0.18), {Size = UDim2.new(0, ddList.Size.X.Offset, 0, 0)}):Play()
        print("[UI] Selected island:", name)
    end)
end

-- action buttons
local action1 = Instance.new("TextButton", panel)
action1.Size = UDim2.new(0, 120, 0, 30)
action1.Position = UDim2.new(0, 8, 0, 130)
action1.BackgroundColor3 = ACCENT_RED
action1.BackgroundTransparency = 0.2 -- TRANSPARAN
action1.Font = Enum.Font.GothamBold
action1.TextSize = 12
action1.Text = "Teleport"
action1.TextColor3 = Color3.fromRGB(30,30,30)
local actionCorner = Instance.new("UICorner", action1); actionCorner.CornerRadius = UDim.new(0,6)

local action2 = Instance.new("TextButton", panel)
action2.Size = UDim2.new(0, 100, 0, 30)
action2.Position = UDim2.new(0, 134, 0, 130)
action2.BackgroundColor3 = Color3.fromRGB(40,40,40)
action2.BackgroundTransparency = 0.3 -- TRANSPARAN
action2.Font = Enum.Font.GothamBold
action2.TextSize = 12
action2.Text = "Sell Fish"
action2.TextColor3 = Color3.fromRGB(230,230,230)
local action2Corner = Instance.new("UICorner", action2); action2Corner.CornerRadius = UDim.new(0,6)

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

-- interactions
local ddOpen = false
ddBtn.MouseButton1Click:Connect(function()
    ddOpen = not ddOpen
    if ddOpen then
        TweenService:Create(ddList, TweenInfo.new(0.18), {Size = UDim2.new(0, ddList.Size.X.Offset, 0, #islandNames * 28)}):Play()
    else
        TweenService:Create(ddList, TweenInfo.new(0.14), {Size = UDim2.new(0, ddList.Size.X.Offset, 0, 0)}):Play()
    end
end)

action1.MouseButton1Click:Connect(function()
    print("[UI] Teleport button pressed. Selected:", ddBtn.Text)
    -- placeholder: show feedback label
    local f = Instance.new("TextLabel", panel)
    f.Size = UDim2.new(1, -16, 0, 24)
    f.Position = UDim2.new(0,8,0,165)
    f.BackgroundTransparency = 1
    f.Font = Enum.Font.GothamBold
    f.TextSize = 11
    f.Text = "Teleporting to: "..ddBtn.Text
    f.TextColor3 = Color3.fromRGB(200,255,200)
    wait(1.2)
    if f and f.Parent then f:Destroy() end
end)

action2.MouseButton1Click:Connect(function()
    print("[UI] Sell Fish clicked")
    local f = Instance.new("TextLabel", panel)
    f.Size = UDim2.new(1, -16, 0, 24)
    f.Position = UDim2.new(0,8,0,165)
    f.BackgroundTransparency = 1
    f.Font = Enum.Font.GothamBold
    f.TextSize = 11
    f.Text = "Sell action (ui demo)"
    f.TextColor3 = Color3.fromRGB(255,220,120)
    wait(1.2)
    if f and f.Parent then f:Destroy() end
end)

-- menu navigation: highlight active and update content title (demo)
local activeMenu = "Teleport"
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
        print("[UI] Menu selected:", name)
        -- For demo: if selected not Teleport, show placeholder panel text
        if name ~= "Teleport" then
            pTitle.Text = name
            ddBtn.Text = "Select option"
        else
            pTitle.Text = "Teleport"
        end
    end)
end

-- FIXED: SIMPLE toggle function
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
        print("[UI] Opened")
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
            print("[UI] Closed")
        end)
    end
end

-- FIXED: Simple toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    toggleUI(not uiOpen)
end)

-- Initial state - UI hidden
container.Visible = false
toggleButton.Text = "Open UI"

-- small update loop for mem label (demo)
spawn(function()
    while true do
        local mem = math.floor(collectgarbage("count"))
        memLabel.Text = "Memory: "..mem.." KB"
        wait(1.2)
    end
end)

print("[NeonDashboardUI] Loaded (Mobile UI). Use the toggle button to open/close.")
