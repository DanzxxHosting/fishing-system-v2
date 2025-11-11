-- UI-Only: Premium Neon Dashboard - Kaitun Fish It
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 1000
local HEIGHT = 600
local SIDEBAR_W = 260
local ACCENT = Color3.fromRGB(255, 65, 65) -- Neon Red
local ACCENT2 = Color3.fromRGB(0, 150, 255) -- Neon Blue
local BG = Color3.fromRGB(8, 8, 8) -- Pure Black
local SECOND = Color3.fromRGB(18, 18, 20) -- Dark Gray
local CARD_BG = Color3.fromRGB(15, 15, 18)

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

print("[UI] Premium Dashboard Initialized")

-- Main container dengan efek glass morphism
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundColor3 = BG
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
container.Parent = screen

-- Background Blur Effect
local blur = Instance.new("BlurEffect")
blur.Size = 24
blur.Parent = game:GetService("Lighting")

-- Outer glow dengan multiple layers
local glow1 = Instance.new("ImageLabel")
glow1.Name = "Glow1"
glow1.AnchorPoint = Vector2.new(0.5,0.5)
glow1.Size = UDim2.new(0, WIDTH+120, 0, HEIGHT+120)
glow1.Position = UDim2.new(0.5, 0, 0.5, 0)
glow1.BackgroundTransparency = 1
glow1.Image = "rbxassetid://5050741616"
glow1.ImageColor3 = ACCENT
glow1.ImageTransparency = 0.94
glow1.ZIndex = 0
glow1.Parent = container

local glow2 = Instance.new("ImageLabel")
glow2.Name = "Glow2"
glow2.AnchorPoint = Vector2.new(0.5,0.5)
glow2.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow2.Position = UDim2.new(0.5, 0, 0.5, 0)
glow2.BackgroundTransparency = 1
glow2.Image = "rbxassetid://5050741616"
glow2.ImageColor3 = ACCENT2
glow2.ImageTransparency = 0.92
glow2.ZIndex = 1
glow2.Parent = container

-- Main card dengan rounded corners
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 16)
cardCorner.Parent = card

-- Inner container dengan padding
local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1
inner.Parent = card

-- Title bar dengan gradient effect
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundColor3 = SECOND
titleBar.BorderSizePixel = 0
titleBar.Parent = inner

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

-- Gradient overlay untuk title bar
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 65, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
})
gradient.Rotation = 90
gradient.Parent = titleBar

-- Title text dengan efek glow
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,20,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Text = "⚡ KAITUN FISH IT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.8
title.TextStrokeColor3 = Color3.fromRGB(255, 65, 65)
title.Parent = titleBar

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0.4,0,0,20)
subtitle.Position = UDim2.new(0,20,0,35)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.Text = "PREMIUM FISHING AUTOMATION"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleBar

-- Window Controls dengan modern design
local windowControls = Instance.new("Frame")
windowControls.Size = UDim2.new(0, 100, 1, 0)
windowControls.Position = UDim2.new(1, -110, 0, 0)
windowControls.BackgroundTransparency = 1
windowControls.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.Position = UDim2.new(0, 8, 0.5, -18)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.Font = Enum.Font.GothamBlack
minimizeBtn.TextSize = 16
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = windowControls

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(0, 52, 0.5, -18)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = windowControls

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- System status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.3,-120,1,0)
statusLabel.Position = UDim2.new(0.7,20,0,0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.Text = "🟢 SYSTEM ONLINE"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.Parent = titleBar

-- Sidebar dengan modern design
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -80)
sidebar.Position = UDim2.new(0, 0, 0, 70)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
sidebar.Parent = inner

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 12)
sbCorner.Parent = sidebar

-- Sidebar header dengan logo
local sbHeader = Instance.new("Frame")
sbHeader.Size = UDim2.new(1,0,0,100)
sbHeader.BackgroundTransparency = 1
sbHeader.Parent = sidebar

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(1, -20, 0, 80)
logoContainer.Position = UDim2.new(0, 10, 0, 10)
logoContainer.BackgroundColor3 = CARD_BG
logoContainer.BorderSizePixel = 0
logoContainer.Parent = sbHeader

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 12)
logoCorner.Parent = logoContainer

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,50,0,50)
logo.Position = UDim2.new(0, 15, 0.5, -25)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904"
logo.ImageColor3 = ACCENT
logo.Parent = logoContainer

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1,-80,0,30)
sTitle.Position = UDim2.new(0, 75, 0, 15)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBlack
sTitle.TextSize = 16
sTitle.Text = "KAITUN V4"
sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = logoContainer

local sSubtitle = Instance.new("TextLabel")
sSubtitle.Size = UDim2.new(1,-80,0,20)
sSubtitle.Position = UDim2.new(0, 75, 0, 45)
sSubtitle.BackgroundTransparency = 1
sSubtitle.Font = Enum.Font.Gotham
sSubtitle.TextSize = 11
sSubtitle.Text = "PREMIUM EDITION"
sSubtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
sSubtitle.TextXAlignment = Enum.TextXAlignment.Left
sSubtitle.Parent = logoContainer

-- Menu container
local menuFrame = Instance.new("ScrollingFrame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(1,-12,1, -130)
menuFrame.Position = UDim2.new(0, 6, 0, 110)
menuFrame.BackgroundTransparency = 1
menuFrame.ScrollBarThickness = 4
menuFrame.ScrollBarImageColor3 = ACCENT
menuFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
menuFrame.Parent = sidebar

local menuLayout = Instance.new("UIListLayout")
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)
menuLayout.Parent = menuFrame

-- Modern menu item function
local function makeMenuItem(name, icon, desc, isNew)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 70)
    row.BackgroundColor3 = CARD_BG
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = row
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    stroke.Parent = row
    
    -- Left icon area
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0,50,1,0)
    left.Position = UDim2.new(0,10,0,0)
    left.BackgroundTransparency = 1
    left.Parent = row
    
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0,40,0,40)
    iconBg.Position = UDim2.new(0,0,0.5,-20)
    iconBg.BackgroundColor3 = ACCENT
    iconBg.BorderSizePixel = 0
    iconBg.Parent = left
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = iconBg
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1,0,1,0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBlack
    iconLabel.TextSize = 16
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.Parent = iconBg
    
    -- Text content area
    local textArea = Instance.new("Frame")
    textArea.Size = UDim2.new(1,-70,1,0)
    textArea.Position = UDim2.new(0,60,0,0)
    textArea.BackgroundTransparency = 1
    textArea.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,24)
    label.Position = UDim2.new(0,0,0,12)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = textArea
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1,0,0,16)
    descLabel.Position = UDim2.new(0,0,0,38)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(180,180,200)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = textArea
    
    -- New badge
    if isNew then
        local newBadge = Instance.new("Frame")
        newBadge.Size = UDim2.new(0, 30, 0, 16)
        newBadge.Position = UDim2.new(1, -35, 0, 12)
        newBadge.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        newBadge.BorderSizePixel = 0
        newBadge.Parent = row
        
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 4)
        badgeCorner.Parent = newBadge
        
        local badgeText = Instance.new("TextLabel")
        badgeText.Size = UDim2.new(1,0,1,0)
        badgeText.BackgroundTransparency = 1
        badgeText.Font = Enum.Font.GothamBold
        badgeText.TextSize = 9
        badgeText.Text = "NEW"
        badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        badgeText.TextXAlignment = Enum.TextXAlignment.Center
        badgeText.TextYAlignment = Enum.TextYAlignment.Center
        badgeText.Parent = newBadge
    end
    
    -- Hover effects
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = ACCENT}):Play()
        TweenService:Create(iconBg, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT2}):Play()
    end)
    
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2), {BackgroundColor3 = CARD_BG}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(iconBg, TweenInfo.new(0.2), {BackgroundColor3 = ACCENT}):Play()
    end)

    return row
end

-- Create premium menu items
local menuItems = {
    {"Fishing Hub", "🎣", "Smart Fishing Automation", true},
    {"Performance", "⚡", "Optimization & Settings", false},
    {"Teleport", "📍", "Location Management", false},
    {"Player", "👤", "Character Modifications", false},
    {"Visuals", "👁️", "UI & Graphics Settings", false},
    {"Security", "🛡️", "Anti-Detection & Safety", false}
}

local menuButtons = {}
for i, v in ipairs(menuItems) do
    local btn = makeMenuItem(v[1], v[2], v[3], v[4])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- Update menu canvas size
menuFrame.CanvasSize = UDim2.new(0, 0, 0, #menuItems * 78)

-- Content panel dengan glass effect
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 24, 1, -80)
content.Position = UDim2.new(0, SIDEBAR_W + 12, 0, 70)
content.BackgroundColor3 = CARD_BG
content.BackgroundTransparency = 0.1
content.BorderSizePixel = 0
content.Parent = inner

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = content

-- Content stroke
local contentStroke = Instance.new("UIStroke")
contentStroke.Color = Color3.fromRGB(40, 40, 40)
contentStroke.Thickness = 1
contentStroke.Parent = content

-- Content header
local cHeader = Instance.new("Frame")
cHeader.Size = UDim2.new(1, 0, 0, 70)
cHeader.BackgroundTransparency = 1
cHeader.Parent = content

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(0.6,0,0,36)
cTitle.Position = UDim2.new(0,20,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBlack
cTitle.TextSize = 24
cTitle.Text = "FISHING HUB"
cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = cHeader

local cSubtitle = Instance.new("TextLabel")
cSubtitle.Size = UDim2.new(0.6,0,0,20)
cSubtitle.Position = UDim2.new(0,20,0,45)
cSubtitle.BackgroundTransparency = 1
cSubtitle.Font = Enum.Font.Gotham
cSubtitle.TextSize = 12
cSubtitle.Text = "Advanced fishing automation system"
cSubtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
cSubtitle.TextXAlignment = Enum.TextXAlignment.Left
cSubtitle.Parent = cHeader

-- Content area dengan scrolling
local contentArea = Instance.new("ScrollingFrame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -24, 1, -90)
contentArea.Position = UDim2.new(0, 12, 0, 80)
contentArea.BackgroundTransparency = 1
contentArea.ScrollBarThickness = 6
contentArea.ScrollBarImageColor3 = ACCENT
contentArea.CanvasSize = UDim2.new(0, 0, 0, 800)
contentArea.Parent = content

-- Welcome card dengan gradient
local welcomeCard = Instance.new("Frame")
welcomeCard.Size = UDim2.new(1, 0, 0, 120)
welcomeCard.BackgroundColor3 = SECOND
welcomeCard.BorderSizePixel = 0
welcomeCard.Parent = contentArea

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 12)
welcomeCorner.Parent = welcomeCard

local welcomeGradient = Instance.new("UIGradient")
welcomeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 65, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
})
welcomeGradient.Rotation = 45
welcomeGradient.Parent = welcomeCard

local welcomeTitle = Instance.new("TextLabel")
welcomeTitle.Size = UDim2.new(0.7,0,0,40)
welcomeTitle.Position = UDim2.new(0,20,0,20)
welcomeTitle.BackgroundTransparency = 1
welcomeTitle.Font = Enum.Font.GothamBlack
welcomeTitle.TextSize = 24
welcomeTitle.Text = "WELCOME TO KAITUN V4"
welcomeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
welcomeTitle.Parent = welcomeCard

local welcomeDesc = Instance.new("TextLabel")
welcomeDesc.Size = UDim2.new(0.7,0,0,40)
welcomeDesc.Position = UDim2.new(0,20,0,60)
welcomeDesc.BackgroundTransparency = 1
welcomeDesc.Font = Enum.Font.Gotham
welcomeDesc.TextSize = 14
welcomeDesc.Text = "Premium fishing automation with advanced features and superior performance."
welcomeDesc.TextColor3 = Color3.fromRGB(230, 230, 255)
welcomeDesc.TextXAlignment = Enum.TextXAlignment.Left
welcomeDesc.TextWrapped = true
welcomeDesc.Parent = welcomeCard

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 160, 0, 45)
startButton.Position = UDim2.new(1, -180, 0.5, -22)
startButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBlack
startButton.TextSize = 14
startButton.Text = "🚀 GET STARTED"
startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
startButton.AutoButtonColor = false
startButton.Parent = welcomeCard

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startButton

-- Features grid
local featuresTitle = Instance.new("TextLabel")
featuresTitle.Size = UDim2.new(1, 0, 0, 40)
featuresTitle.Position = UDim2.new(0, 0, 0, 140)
featuresTitle.BackgroundTransparency = 1
featuresTitle.Font = Enum.Font.GothamBold
featuresTitle.TextSize = 18
featuresTitle.Text = "PREMIUM FEATURES"
featuresTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
featuresTitle.TextXAlignment = Enum.TextXAlignment.Left
featuresTitle.Parent = contentArea

-- Feature card function
local function createFeatureCard(title, desc, icon, x, y)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 220, 0, 100)
    card.Position = UDim2.new(0, x, 0, y)
    card.BackgroundColor3 = SECOND
    card.BorderSizePixel = 0
    card.Parent = contentArea
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    stroke.Parent = card
    
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 50, 0, 50)
    iconBg.Position = UDim2.new(0, 15, 0, 15)
    iconBg.BackgroundColor3 = ACCENT
    iconBg.BorderSizePixel = 0
    iconBg.Parent = card
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = iconBg
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1,0,1,0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBlack
    iconLabel.TextSize = 18
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.Parent = iconBg
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 24)
    titleLabel.Position = UDim2.new(0, 75, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -80, 0, 40)
    descLabel.Position = UDim2.new(0, 75, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = card
    
    -- Hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = ACCENT}):Play()
    end)
    
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = SECOND}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 50)}):Play()
    end)
    
    return card
end

-- Create feature cards
local features = {
    {"Smart AI Fishing", "Advanced pattern recognition", "🤖", 0, 190},
    {"Performance Boost", "Optimized for maximum FPS", "⚡", 230, 190},
    {"Anti-Detection", "Advanced safety systems", "🛡️", 460, 190},
    {"Multi-Spot Fishing", "Fish multiple locations", "🎯", 0, 310},
    {"Auto Perfection", "Always perfect catches", "⭐", 230, 310},
    {"Ultra Speed", "5x faster than normal", "🚀", 460, 310}
}

for i, feature in ipairs(features) do
    createFeatureCard(feature[1], feature[2], feature[3], feature[4], feature[5])
end

-- Stats panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 80)
statsPanel.Position = UDim2.new(0, 0, 0, 430)
statsPanel.BackgroundColor3 = SECOND
statsPanel.BorderSizePixel = 0
statsPanel.Parent = contentArea

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsPanel

-- Stats items
local stats = {
    {"System Status", "🟢 ONLINE", Color3.fromRGB(100, 255, 100)},
    {"Performance", "⚡ OPTIMAL", Color3.fromRGB(255, 215, 0)},
    {"Memory Usage", "💾 12.4 MB", Color3.fromRGB(100, 200, 255)},
    {"Uptime", "⏱️ 00:00:00", Color3.fromRGB(200, 100, 255)}
}

for i, stat in ipairs(stats) do
    local statFrame = Instance.new("Frame")
    statFrame.Size = UDim2.new(0.24, -10, 1, -20)
    statFrame.Position = UDim2.new((i-1)*0.25 + 0.02, 0, 0, 10)
    statFrame.BackgroundTransparency = 1
    statFrame.Parent = statsPanel
    
    local statTitle = Instance.new("TextLabel")
    statTitle.Size = UDim2.new(1,0,0,20)
    statTitle.BackgroundTransparency = 1
    statTitle.Font = Enum.Font.Gotham
    statTitle.TextSize = 11
    statTitle.Text = stat[1]
    statTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    statTitle.TextXAlignment = Enum.TextXAlignment.Left
    statTitle.Parent = statFrame
    
    local statValue = Instance.new("TextLabel")
    statValue.Size = UDim2.new(1,0,0,24)
    statValue.Position = UDim2.new(0,0,0,25)
    statValue.BackgroundTransparency = 1
    statValue.Font = Enum.Font.GothamBold
    statValue.TextSize = 14
    statValue.Text = stat[2]
    statValue.TextColor3 = stat[3]
    statValue.TextXAlignment = Enum.TextXAlignment.Left
    statValue.Parent = statFrame
end

-- Update content area size
contentArea.CanvasSize = UDim2.new(0, 0, 0, 530)

-- Tray Icon (akan muncul ketika minimize)
local trayIcon = Instance.new("ImageButton")
trayIcon.Name = "TrayIcon"
trayIcon.Size = UDim2.new(0, 0, 0, 0)
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

-- Window Controls Functionality
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
    TweenService:Create(glow1, TweenInfo.new(0.4), {ImageTransparency = 0.94}):Play()
    TweenService:Create(glow2, TweenInfo.new(0.4), {ImageTransparency = 0.92}):Play()
    
    hideTrayIcon()
    uiOpen = true
    print("[UI] Premium Dashboard Opened")
end
