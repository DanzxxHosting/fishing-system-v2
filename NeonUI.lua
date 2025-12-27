-- Neon Dashboard UI Premium
-- Tema: Glass Effect + Neon Red
-- Keybind: G untuk toggle
-- Safe: UI only

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 900
local HEIGHT = 500
local SIDEBAR_W = 200
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local ACCENT_GLOW = Color3.fromRGB(255, 100, 100)
local BG = Color3.fromRGB(10, 10, 12) -- hitam gelap
local GLASS_COLOR = Color3.fromRGB(20, 20, 25)
local GLASS_TRANSPARENCY = 0.3

-- Cleanup old UI
if playerGui:FindFirstChild("NeonDashboard") then
    playerGui.NeonDashboard:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboard"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Background blur effect
local blur = Instance.new("Frame")
blur.Name = "BlurBackground"
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blur.BackgroundTransparency = 0.5
blur.BorderSizePixel = 0
blur.Parent = container
blur.Visible = false

-- Glass Panel
local glass = Instance.new("Frame")
glass.Name = "GlassPanel"
glass.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
glass.Position = UDim2.new(0, 0, 0, 0)
glass.BackgroundColor3 = GLASS_COLOR
glass.BackgroundTransparency = GLASS_TRANSPARENCY
glass.BorderSizePixel = 0
glass.Parent = container

-- Glass effect
local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 16)
glassCorner.Parent = glass

local glassStroke = Instance.new("UIStroke")
glassStroke.Color = Color3.fromRGB(40, 40, 50)
glassStroke.Thickness = 2
glassStroke.Parent = glass

-- Outer glow
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Size = UDim2.new(1, 40, 1, 40)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://8992236561" -- Circular glow
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.9
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(256, 256, 256, 256)
glow.Parent = glass
glow.ZIndex = -1

-- Inner container
local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1
inner.Parent = glass

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = inner

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Text = "⚡ KAITUN FISH IT"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local titleGlow = Instance.new("TextLabel")
titleGlow.Size = title.Size
titleGlow.Position = title.Position
titleGlow.BackgroundTransparency = 1
titleGlow.Font = title.Font
titleGlow.TextSize = title.TextSize
titleGlow.Text = title.Text
titleGlow.TextColor3 = ACCENT_GLOW
titleGlow.TextTransparency = 0.7
titleGlow.TextXAlignment = Enum.TextXAlignment.Left
titleGlow.Parent = titleBar
titleGlow.ZIndex = -1

-- Stats bar
local statsBar = Instance.new("Frame")
statsBar.Size = UDim2.new(0.4, -16, 1, 0)
statsBar.Position = UDim2.new(0.6, 12, 0, 0)
statsBar.BackgroundTransparency = 1
statsBar.Parent = titleBar

local memLabel = Instance.new("TextLabel")
memLabel.Size = UDim2.new(1, 0, 0.5, 0)
memLabel.Position = UDim2.new(0, 0, 0, 0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 12
memLabel.Text = "RAM: 0 MB"
memLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
memLabel.TextXAlignment = Enum.TextXAlignment.Right
memLabel.Parent = statsBar

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
fpsLabel.Position = UDim2.new(0, 0, 0.5, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 12
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsLabel.Parent = statsBar

-- Sidebar (Glass)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -70)
sidebar.Position = UDim2.new(0, 0, 0, 60)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0
sidebar.Parent = inner

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(40, 40, 50)
sidebarStroke.Thickness = 1
sidebarStroke.Parent = sidebar

-- Sidebar header
local sbHeader = Instance.new("Frame")
sbHeader.Size = UDim2.new(1, 0, 0, 80)
sbHeader.BackgroundTransparency = 1
sbHeader.Parent = sidebar

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 60, 0, 60)
logoContainer.Position = UDim2.new(0, 16, 0, 10)
logoContainer.BackgroundTransparency = 1
logoContainer.Parent = sbHeader

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(1, 0, 1, 0)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926307971" -- Fish icon
logo.ImageColor3 = ACCENT
logo.Parent = logoContainer

local logoGlow = Instance.new("ImageLabel")
logoGlow.Size = UDim2.new(1, 10, 1, 10)
logoGlow.Position = UDim2.new(0, -5, 0, -5)
logoGlow.BackgroundTransparency = 1
logoGlow.Image = "rbxassetid://8992236561"
logoGlow.ImageColor3 = ACCENT
logoGlow.ImageTransparency = 0.8
logoGlow.Parent = logoContainer
logoGlow.ZIndex = -1

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1, -96, 0, 30)
sTitle.Position = UDim2.new(0, 88, 0, 15)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 18
sTitle.Text = "KAITUN"
sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = sbHeader

local sSubtitle = Instance.new("TextLabel")
sSubtitle.Size = UDim2.new(1, -96, 0, 20)
sSubtitle.Position = UDim2.new(0, 88, 0, 45)
sSubtitle.BackgroundTransparency = 1
sSubtitle.Font = Enum.Font.Gotham
sSubtitle.TextSize = 12
sSubtitle.Text = "Premium Hub"
sSubtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
sSubtitle.TextXAlignment = Enum.TextXAlignment.Left
sSubtitle.Parent = sbHeader

-- Menu container
local menuContainer = Instance.new("ScrollingFrame")
menuContainer.Size = UDim2.new(1, -12, 1, -100)
menuContainer.Position = UDim2.new(0, 6, 0, 88)
menuContainer.BackgroundTransparency = 1
menuContainer.BorderSizePixel = 0
menuContainer.ScrollBarThickness = 3
menuContainer.ScrollBarImageColor3 = ACCENT
menuContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
menuContainer.Parent = sidebar

local menuLayout = Instance.new("UIListLayout")
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0, 8)
menuLayout.Parent = menuContainer

-- Menu item function
local function createMenuItem(name, icon)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, 0, 0, 46)
    item.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    item.BackgroundTransparency = 0.3
    item.AutoButtonColor = false
    item.BorderSizePixel = 0
    item.Text = ""
    item.LayoutOrder = #menuContainer:GetChildren()
    item.Parent = menuContainer
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 10)
    itemCorner.Parent = item
    
    local itemStroke = Instance.new("UIStroke")
    itemStroke.Color = Color3.fromRGB(40, 40, 50)
    itemStroke.Thickness = 1
    itemStroke.Parent = item
    
    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 8, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 18
    iconLabel.Text = icon
    iconLabel.TextColor3 = ACCENT
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.Parent = item
    
    -- Text
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 56, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 14
    textLabel.Text = name
    textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = item
    
    -- Hover effects
    item.MouseEnter:Connect(function()
        TweenService:Create(item, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 10, 10),
            BackgroundTransparency = 0.1
        }):Play()
        TweenService:Create(itemStroke, TweenInfo.new(0.2), {
            Color = ACCENT
        }):Play()
    end)
    
    item.MouseLeave:Connect(function()
        TweenService:Create(item, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BackgroundTransparency = 0.3
        }):Play()
        TweenService:Create(itemStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(40, 40, 50)
        }):Play()
    end)
    
    return item
end

-- Create menu items
local menuItems = {
    {"Main", "★"},
    {"Spawn Boat", "⛵"},
    {"Buy Rod", "🎣"},
    {"Buy Weather", "☁️"},
    {"Buy Bait", "🪱"},
    {"Teleport", "📍"},
    {"Settings", "⚙️"},
}

local menuButtons = {}
for _, item in ipairs(menuItems) do
    local btn = createMenuItem(item[1], item[2])
    menuButtons[item[1]] = btn
end

-- Update canvas size
menuContainer.CanvasSize = UDim2.new(0, 0, 0, #menuItems * 54)

-- Content area (Glass)
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 30, 1, -70)
content.Position = UDim2.new(0, SIDEBAR_W + 20, 0, 60)
content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
content.BackgroundTransparency = 0.2
content.BorderSizePixel = 0
content.Parent = inner

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = content

local contentStroke = Instance.new("UIStroke")
contentStroke.Color = Color3.fromRGB(40, 40, 50)
contentStroke.Thickness = 1
contentStroke.Parent = content

-- Content header
local contentHeader = Instance.new("Frame")
contentHeader.Size = UDim2.new(1, -24, 0, 50)
contentHeader.Position = UDim2.new(0, 12, 0, 12)
contentHeader.BackgroundTransparency = 1
contentHeader.Parent = content

local contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(0.6, 0, 1, 0)
contentTitle.Position = UDim2.new(0, 0, 0, 0)
contentHeader.BackgroundTransparency = 1
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 18
contentTitle.Text = "DASHBOARD"
contentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentHeader

-- Demo panel
local demoPanel = Instance.new("Frame")
demoPanel.Size = UDim2.new(1, -24, 0.6, 0)
demoPanel.Position = UDim2.new(0, 12, 0, 74)
demoPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
demoPanel.BackgroundTransparency = 0.2
demoPanel.Parent = content

local demoCorner = Instance.new("UICorner")
demoCorner.CornerRadius = UDim.new(0, 12)
demoCorner.Parent = demoPanel

local demoStroke = Instance.new("UIStroke")
demoStroke.Color = ACCENT
demoStroke.Transparency = 0.7
demoStroke.Thickness = 1
demoStroke.Parent = demoPanel

-- Panel title
local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -24, 0, 40)
panelTitle.Position = UDim2.new(0, 12, 0, 8)
panelTitle.BackgroundTransparency = 1
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 16
panelTitle.Text = "⚡ PREMIUM FEATURES"
panelTitle.TextColor3 = Color3.fromRGB(255, 220, 220)
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Parent = demoPanel

-- Status indicator
local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(1, -24, 0, 80)
statusContainer.Position = UDim2.new(0, 12, 0, 60)
statusContainer.BackgroundTransparency = 1
statusContainer.Parent = demoPanel

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 12, 0, 12)
statusDot.Position = UDim2.new(0, 0, 0, 10)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
statusDot.Parent = statusContainer

local statusDotGlow = Instance.new("Frame")
statusDotGlow.Size = UDim2.new(0, 20, 0, 20)
statusDotGlow.Position = UDim2.new(0, -4, 0, 6)
statusDotGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
statusDotGlow.BackgroundTransparency = 0.7
statusDotGlow.Parent = statusContainer
statusDotGlow.ZIndex = -1

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = statusDotGlow

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -40, 0, 30)
statusText.Position = UDim2.new(0, 30, 0, 5)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamSemibold
statusText.TextSize = 14
statusText.Text = "Status: READY"
statusText.TextColor3 = Color3.fromRGB(200, 255, 200)
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusContainer

local statusDesc = Instance.new("TextLabel")
statusDesc.Size = UDim2.new(1, -40, 0, 40)
statusDesc.Position = UDim2.new(0, 30, 0, 30)
statusDesc.BackgroundTransparency = 1
statusDesc.Font = Enum.Font.Gotham
statusDesc.TextSize = 12
statusDesc.Text = "Premium UI loaded successfully. Press G to toggle visibility."
statusDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
statusDesc.TextXAlignment = Enum.TextXAlignment.Left
statusDesc.TextYAlignment = Enum.TextYAlignment.Top
statusDesc.Parent = statusContainer

-- Bottom info
local bottomInfo = Instance.new("Frame")
bottomInfo.Size = UDim2.new(1, -24, 0, 30)
bottomInfo.Position = UDim2.new(0, 12, 1, -40)
bottomInfo.BackgroundTransparency = 1
bottomInfo.Parent = content

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(0.5, 0, 1, 0)
versionText.Position = UDim2.new(0, 0, 0, 0)
versionText.BackgroundTransparency = 1
versionText.Font = Enum.Font.Gotham
versionText.TextSize = 11
versionText.Text = "NeonUI v2.0 • Premium Edition"
versionText.TextColor3 = Color3.fromRGB(150, 150, 170)
versionText.TextXAlignment = Enum.TextXAlignment.Left
versionText.Parent = bottomInfo

local keybindText = Instance.new("TextLabel")
keybindText.Size = UDim2.new(0.5, 0, 1, 0)
keybindText.Position = UDim2.new(0.5, 0, 0, 0)
keybindText.BackgroundTransparency = 1
keybindText.Font = Enum.Font.Gotham
keybindText.TextSize = 11
keybindText.Text = "Toggle: [G] Key"
keybindText.TextColor3 = ACCENT
keybindText.TextXAlignment = Enum.TextXAlignment.Right
keybindText.Parent = bottomInfo

-- Menu navigation
local activeMenu = "Main"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        activeMenu = name
        
        -- Update all buttons
        for n, b in pairs(menuButtons) do
            local stroke = b:FindFirstChild("UIStroke")
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.2), {
                    Color = (n == name) and ACCENT or Color3.fromRGB(40, 40, 50)
                }):Play()
            end
        end
        
        -- Update content title
        contentTitle.Text = name:upper()
        
        -- Animate content change
        TweenService:Create(contentStroke, TweenInfo.new(0.3), {
            Color = ACCENT
        }):Play()
        
        wait(0.1)
        TweenService:Create(contentStroke, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(40, 40, 50)
        }):Play()
    end)
end

-- UI Toggle System
local uiVisible = false

local function toggleUI(show)
    uiVisible = show
    
    if show then
        -- Show with animation
        container.Visible = true
        blur.Visible = true
        
        -- Scale up animation
        container.Size = UDim2.new(0, 0, 0, 0)
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, WIDTH, 0, HEIGHT),
            Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        }):Play()
        
        -- Fade in blur
        blur.BackgroundTransparency = 1
        TweenService:Create(blur, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.5
        }):Play()
        
        -- Glow effect
        glow.ImageTransparency = 0.9
        TweenService:Create(glow, TweenInfo.new(0.4), {
            ImageTransparency = 0.7
        }):Play()
    else
        -- Hide with animation
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        -- Fade out blur
        TweenService:Create(blur, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        
        -- Fade glow
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.9
        }):Play()
        
        delay(0.3, function()
            container.Visible = false
            blur.Visible = false
        end)
    end
end

-- Keybind system
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        toggleUI(not uiVisible)
    end
end)

-- Performance monitor
spawn(function()
    while true do
        -- Update memory usage
        local mem = math.floor(collectgarbage("count") / 1024 * 10) / 10
        memLabel.Text = string.format("RAM: %.1f MB", mem)
        
        -- Update FPS
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        fpsLabel.Text = string.format("FPS: %d", math.min(fps, 999))
        
        wait(1)
    end
end)

-- Initial state
toggleUI(false)

-- Loading animation
spawn(function()
    wait(0.5)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    statusDotGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    statusText.Text = "Status: READY"
    statusText.TextColor3 = Color3.fromRGB(200, 255, 200)
end)

print("=======================================")
print("⚡ NEON UI LOADED SUCCESSFULLY")
print("📌 Press G to toggle the interface")
print("🎮 Premium Glass Effect Activated")
print("=======================================")

-- Return UI controller
return {
    Toggle = function()
        toggleUI(not uiVisible)
    end,
    
    Show = function()
        toggleUI(true)
    end,
    
    Hide = function()
        toggleUI(false)
    end
}