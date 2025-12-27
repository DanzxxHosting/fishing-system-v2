-- Neon Dashboard UI Premium
-- Tema: Glass Effect + Neon Red
-- Keybind: G untuk toggle
-- Navigation System: Dashboard, Teleport, Shop, Settings, About

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 520
local HEIGHT = 280
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
title.Text = "⚡ NEON UI"
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
sTitle.Text = "NAVIGATION"
sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = sbHeader

local sSubtitle = Instance.new("TextLabel")
sSubtitle.Size = UDim2.new(1, -96, 0, 20)
sSubtitle.Position = UDim2.new(0, 88, 0, 45)
sSubtitle.BackgroundTransparency = 1
sSubtitle.Font = Enum.Font.Gotham
sSubtitle.TextSize = 12
sSubtitle.Text = "Select Feature"
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

-- Function to create navigation button
local function createNavButton(text, icon, id, order)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn" .. id
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.BackgroundTransparency = 0.3
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = menuContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(40, 40, 50)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 8, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 20
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.Parent = btn
    
    -- Text
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 56, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 14
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 10, 10),
            BackgroundTransparency = 0.1
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {
            Color = ACCENT
        }):Play()
        TweenService:Create(iconLabel, TweenInfo.new(0.2), {
            TextColor3 = ACCENT
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        local isActive = btn:GetAttribute("Active") or false
        if not isActive then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(40, 40, 50)
            }):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(180, 180, 200)
            }):Play()
        end
    end)
    
    return btn, iconLabel, btnStroke
end

-- Create navigation buttons
local btnMain, iconMain, strokeMain = createNavButton("Dashboard", "🏠", "Main", 1)
local btnTeleport, iconTeleport, strokeTeleport = createNavButton("Teleport", "🌍", "Teleport", 2)
local btnShop, iconShop, strokeShop = createNavButton("Shop", "🛒", "Shop", 3)
local btnSettings, iconSettings, strokeSettings = createNavButton("Settings", "⚙️", "Settings", 4)
local btnInfo, iconInfo, strokeInfo = createNavButton("About", "ℹ️", "Info", 5)

-- Set Dashboard as active by default
btnMain:SetAttribute("Active", true)
btnMain.BackgroundColor3 = Color3.fromRGB(35, 10, 10)
btnMain.BackgroundTransparency = 0.1
strokeMain.Color = ACCENT
iconMain.TextColor3 = ACCENT

-- Update canvas size
menuContainer.CanvasSize = UDim2.new(0, 0, 0, 5 * 54)

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
contentTitle.BackgroundTransparency = 1
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 18
contentTitle.Text = "MAIN DASHBOARD"
contentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentHeader

local contentSubtitle = Instance.new("TextLabel")
contentSubtitle.Size = UDim2.new(0.4, -10, 1, 0)
contentSubtitle.Position = UDim2.new(0.6, 10, 0, 0)
contentSubtitle.BackgroundTransparency = 1
contentSubtitle.Font = Enum.Font.Gotham
contentSubtitle.TextSize = 12
contentSubtitle.Text = "Welcome to Neon UI"
contentSubtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
contentSubtitle.TextXAlignment = Enum.TextXAlignment.Right
contentSubtitle.Parent = contentHeader

-- Content pages container
local pagesContainer = Instance.new("Frame")
pagesContainer.Name = "Pages"
pagesContainer.Size = UDim2.new(1, -24, 1, -80)
pagesContainer.Position = UDim2.new(0, 12, 0, 64)
pagesContainer.BackgroundTransparency = 1
pagesContainer.ClipsDescendants = true
pagesContainer.Parent = content

-- Function to switch pages
local currentPage = "Main"
local pages = {}

local function switchPage(pageId, titleText)
    -- Update current page
    currentPage = pageId
    
    -- Update content title
    contentTitle.Text = titleText:upper()
    
    -- Update all buttons active state
    local buttons = {
        Main = {btn = btnMain, icon = iconMain, stroke = strokeMain},
        Teleport = {btn = btnTeleport, icon = iconTeleport, stroke = strokeTeleport},
        Shop = {btn = btnShop, icon = iconShop, stroke = strokeShop},
        Settings = {btn = btnSettings, icon = iconSettings, stroke = strokeSettings},
        Info = {btn = btnInfo, icon = iconInfo, stroke = strokeInfo}
    }
    
    for name, data in pairs(buttons) do
        local isActive = (name == pageId)
        data.btn:SetAttribute("Active", isActive)
        
        if isActive then
            -- Active button
            TweenService:Create(data.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 10, 10),
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.2), {
                Color = ACCENT
            }):Play()
            TweenService:Create(data.icon, TweenInfo.new(0.2), {
                TextColor3 = ACCENT
            }):Play()
        else
            -- Inactive button
            TweenService:Create(data.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(40, 40, 50)
            }):Play()
            TweenService:Create(data.icon, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(180, 180, 200)
            }):Play()
        end
    end
    
    -- Show selected page, hide others
    for pageName, pageFrame in pairs(pages) do
        if pageName == pageId then
            pageFrame.Visible = true
            TweenService:Create(pageFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
        else
            pageFrame.Visible = false
            pageFrame.Position = UDim2.new(1, 0, 0, 0)
        end
    end
    
    -- Content animation
    TweenService:Create(contentStroke, TweenInfo.new(0.3), {
        Color = ACCENT
    }):Play()
    
    wait(0.1)
    
    TweenService:Create(contentStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(40, 40, 50)
    }):Play()
    
    print("[Neon UI] Switched to page:", pageId)
end

-- Function to create page
local function createPage(pageId, title)
    local page = Instance.new("Frame")
    page.Name = "Page_" .. pageId
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pagesContainer
    
    -- Page title
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 40)
    pageTitle.Position = UDim2.new(0, 0, 0, 0)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextSize = 16
    pageTitle.Text = title
    pageTitle.TextColor3 = Color3.fromRGB(255, 220, 220)
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.Parent = page
    
    -- Page content
    local pageContent = Instance.new("Frame")
    pageContent.Size = UDim2.new(1, 0, 1, -50)
    pageContent.Position = UDim2.new(0, 0, 0, 50)
    pageContent.BackgroundTransparency = 1
    pageContent.Parent = page
    
    pages[pageId] = page
    return pageContent
end

-- Create all pages
local mainContent = createPage("Main", "Dashboard Overview")
local teleportContent = createPage("Teleport", "Teleport System")
local shopContent = createPage("Shop", "Shop Features")
local settingsContent = createPage("Settings", "Settings Panel")
local infoContent = createPage("Info", "About Neon UI")

-- Main Page Content
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(1, 0, 0.6, 0)
mainPanel.Position = UDim2.new(0, 0, 0, 0)
mainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainPanel.BackgroundTransparency = 0.2
mainPanel.Parent = mainContent

local mainPanelCorner = Instance.new("UICorner")
mainPanelCorner.CornerRadius = UDim.new(0, 12)
mainPanelCorner.Parent = mainPanel

local mainPanelStroke = Instance.new("UIStroke")
mainPanelStroke.Color = ACCENT
mainPanelStroke.Transparency = 0.7
mainPanelStroke.Thickness = 1
mainPanelStroke.Parent = mainPanel

-- Status indicator
local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(1, -24, 0, 80)
statusContainer.Position = UDim2.new(0, 12, 0, 12)
statusContainer.BackgroundTransparency = 1
statusContainer.Parent = mainPanel

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
statusDesc.Text = "Neon UI Premium Edition loaded successfully. Select a feature from the navigation panel."
statusDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
statusDesc.TextXAlignment = Enum.TextXAlignment.Left
statusDesc.TextYAlignment = Enum.TextYAlignment.Top
statusDesc.Parent = statusContainer

-- Feature grid
local featuresGrid = Instance.new("Frame")
featuresGrid.Size = UDim2.new(1, -24, 0, 120)
featuresGrid.Position = UDim2.new(0, 12, 0, 104)
featuresGrid.BackgroundTransparency = 1
featuresGrid.Parent = mainPanel

local featuresTitle = Instance.new("TextLabel")
featuresTitle.Size = UDim2.new(1, 0, 0, 25)
featuresTitle.Position = UDim2.new(0, 0, 0, 0)
featuresTitle.BackgroundTransparency = 1
featuresTitle.Font = Enum.Font.GothamBold
featuresTitle.TextSize = 14
featuresTitle.Text = "Available Features:"
featuresTitle.TextColor3 = Color3.fromRGB(255, 220, 220)
featuresTitle.TextXAlignment = Enum.TextXAlignment.Left
featuresTitle.Parent = featuresGrid

local feature1 = Instance.new("TextLabel")
feature1.Size = UDim2.new(0.5, -10, 0, 25)
feature1.Position = UDim2.new(0, 0, 0, 35)
feature1.BackgroundTransparency = 1
feature1.Font = Enum.Font.Gotham
feature1.TextSize = 13
feature1.Text = "✓ Teleport System"
feature1.TextColor3 = Color3.fromRGB(180, 255, 180)
feature1.TextXAlignment = Enum.TextXAlignment.Left
feature1.Parent = featuresGrid

local feature2 = Instance.new("TextLabel")
feature2.Size = UDim2.new(0.5, -10, 0, 25)
feature2.Position = UDim2.new(0.5, 10, 0, 35)
feature2.BackgroundTransparency = 1
feature2.Font = Enum.Font.Gotham
feature2.TextSize = 13
feature2.Text = "✓ Shop Features"
feature2.TextColor3 = Color3.fromRGB(180, 255, 180)
feature2.TextXAlignment = Enum.TextXAlignment.Left
feature2.Parent = featuresGrid

local feature3 = Instance.new("TextLabel")
feature3.Size = UDim2.new(0.5, -10, 0, 25)
feature3.Position = UDim2.new(0, 0, 0, 65)
feature3.BackgroundTransparency = 1
feature3.Font = Enum.Font.Gotham
feature3.TextSize = 13
feature3.Text = "✓ Settings Panel"
feature3.TextColor3 = Color3.fromRGB(180, 255, 180)
feature3.TextXAlignment = Enum.TextXAlignment.Left
feature3.Parent = featuresGrid

local feature4 = Instance.new("TextLabel")
feature4.Size = UDim2.new(0.5, -10, 0, 25)
feature4.Position = UDim2.new(0.5, 10, 0, 65)
feature4.BackgroundTransparency = 1
feature4.Font = Enum.Font.Gotham
feature4.TextSize = 13
feature4.Text = "✓ Premium UI"
feature4.TextColor3 = Color3.fromRGB(180, 255, 180)
feature4.TextXAlignment = Enum.TextXAlignment.Left
feature4.Parent = featuresGrid

-- Teleport Page Content (Placeholder)
local teleportTitle = Instance.new("TextLabel")
teleportTitle.Size = UDim2.new(1, 0, 0, 40)
teleportTitle.Position = UDim2.new(0, 0, 0, 0)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 14
teleportTitle.Text = "Teleport System - Coming Soon"
teleportTitle.TextColor3 = Color3.fromRGB(255, 200, 200)
teleportTitle.TextXAlignment = Enum.TextXAlignment.Center
teleportTitle.Parent = teleportContent

-- Shop Page Content (Placeholder)
local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 40)
shopTitle.Position = UDim2.new(0, 0, 0, 0)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 14
shopTitle.Text = "Shop Features - Coming Soon"
shopTitle.TextColor3 = Color3.fromRGB(255, 200, 200)
shopTitle.TextXAlignment = Enum.TextXAlignment.Center
shopTitle.Parent = shopContent

-- Settings Page Content (Placeholder)
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 40)
settingsTitle.Position = UDim2.new(0, 0, 0, 0)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 14
settingsTitle.Text = "Settings Panel - Coming Soon"
settingsTitle.TextColor3 = Color3.fromRGB(255, 200, 200)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Center
settingsTitle.Parent = settingsContent

-- Info Page Content
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(1, 0, 0.7, 0)
infoPanel.Position = UDim2.new(0, 0, 0, 0)
infoPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
infoPanel.BackgroundTransparency = 0.2
infoPanel.Parent = infoContent

local infoPanelCorner = Instance.new("UICorner")
infoPanelCorner.CornerRadius = UDim.new(0, 12)
infoPanelCorner.Parent = infoPanel

local infoPanelStroke = Instance.new("UIStroke")
infoPanelStroke.Color = ACCENT
infoPanelStroke.Transparency = 0.7
infoPanelStroke.Thickness = 1
infoPanelStroke.Parent = infoPanel

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -24, 1, -24)
infoText.Position = UDim2.new(0, 12, 0, 12)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 13
infoText.Text = [[
⚡ NEON UI PREMIUM EDITION

Version: 2.0
Developer: Kaitun Team
Status: Active

Features:
• Premium Glass UI Design
• Smooth Animations
• Navigation System
• Performance Monitor
• Custom Keybinds

Press G to toggle interface
]]
infoText.TextColor3 = Color3.fromRGB(220, 220, 240)
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoPanel

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

-- Connect button click events
btnMain.MouseButton1Click:Connect(function() 
    switchPage("Main", "Main Dashboard") 
end)

btnTeleport.MouseButton1Click:Connect(function() 
    switchPage("Teleport", "Teleport System") 
end)

btnShop.MouseButton1Click:Connect(function() 
    switchPage("Shop", "Shop Features") 
end)

btnSettings.MouseButton1Click:Connect(function() 
    switchPage("Settings", "Settings") 
end)

btnInfo.MouseButton1Click:Connect(function() 
    switchPage("Info", "About Neon") 
end)

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
switchPage("Main", "Main Dashboard")

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
print("🎮 Navigation System: Dashboard, Teleport, Shop, Settings, About")
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
    end,
    
    Destroy = function()
        screen:Destroy()
    end,
    
    SwitchPage = switchPage
}