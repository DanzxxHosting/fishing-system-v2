-- NeonUI_Main.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cleanup old UI
if playerGui:FindFirstChild("NeonDashboard") then
    playerGui.NeonDashboard:Destroy()
end

-- CONFIG
local WIDTH = 520
local HEIGHT = 280
local SIDEBAR_W = 160
local ACCENT = Color3.fromRGB(255, 62, 62)
local ACCENT_GLOW = Color3.fromRGB(255, 100, 100)
local BG_DARK = Color3.fromRGB(10, 10, 12)
local BG_LIGHT = Color3.fromRGB(20, 20, 25)
local TEXT_WHITE = Color3.fromRGB(240, 240, 255)
local TEXT_GRAY = Color3.fromRGB(180, 180, 200)
local SUCCESS_COLOR = Color3.fromRGB(100, 255, 100)
local WARNING_COLOR = Color3.fromRGB(255, 200, 100)
local ERROR_COLOR = Color3.fromRGB(255, 100, 100)

-- ============================================
-- LOAD SECURITY LOADER & TELEPORT SYSTEM
-- ============================================
local SecurityLoader
local teleportSystem
local teleportLoaded = false

local function loadTeleportSystem()
    print("🔄 Loading Teleport System via SecurityLoader...")
    
    local loaderURL = "https://raw.githubusercontent.com/DanzxxHosting/fishing-system-v2/refs/heads/main/Main/SecurityLoader.lua"
    
    local success, result = pcall(function()
        local code = game:HttpGet(loaderURL)
        local func = loadstring(code)
        SecurityLoader = func()
        return SecurityLoader
    end)
    
    if not success then
        warn("❌ Failed to load SecurityLoader:", result)
        return false
    end
    
    if SecurityLoader and SecurityLoader.LoadTeleportSystem then
        teleportSystem = SecurityLoader.LoadTeleportSystem()
        teleportLoaded = teleportSystem ~= nil
    end
    
    return teleportLoaded
end

-- Load teleport system
teleportLoaded = loadTeleportSystem()

-- ============================================
-- UI COMPONENT FUNCTIONS
-- ============================================
local function makeButton(parent, text, onClick, options)
    options = options or {}
    
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. (options.Name or text)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = options.Position or UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = options.BackgroundColor or Color3.fromRGB(60, 80, 120)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = options.StrokeColor or Color3.fromRGB(40, 60, 90)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Text = text
    label.TextColor3 = TEXT_WHITE
    label.Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 100, 140)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = ACCENT
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = options.BackgroundColor or Color3.fromRGB(60, 80, 120)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = options.StrokeColor or Color3.fromRGB(40, 60, 90)
        }):Play()
    end)
    
    -- Click effect
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0
        }):Play()
        onClick()
    end)
    
    return btn
end

-- ============================================
-- CREATE MAIN UI
-- ============================================
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboard"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

local blur = Instance.new("Frame")
blur.Name = "BlurBackground"
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blur.BackgroundTransparency = 0.5
blur.BorderSizePixel = 0
blur.Parent = container
blur.Visible = false

local glass = Instance.new("Frame")
glass.Name = "GlassPanel"
glass.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
glass.Position = UDim2.new(0, 0, 0, 0)
glass.BackgroundColor3 = BG_LIGHT
glass.BackgroundTransparency = 0.3
glass.BorderSizePixel = 0
glass.Parent = container

local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 12)
glassCorner.Parent = glass

local glassStroke = Instance.new("UIStroke")
glassStroke.Color = Color3.fromRGB(40, 40, 50)
glassStroke.Thickness = 1
glassStroke.Parent = glass

local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://8992236561"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.9
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(256, 256, 256, 256)
glow.Parent = glass
glow.ZIndex = -1

local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, -16, 1, -16)
inner.Position = UDim2.new(0, 8, 0, 8)
inner.BackgroundTransparency = 1
inner.Parent = glass

-- Header
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = inner

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = "⚡ NEON UI"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local statusIndicator = Instance.new("TextLabel")
statusIndicator.Size = UDim2.new(0.4, -8, 1, 0)
statusIndicator.Position = UDim2.new(0.6, 8, 0, 0)
statusIndicator.BackgroundTransparency = 1
statusIndicator.Font = Enum.Font.Gotham
statusIndicator.TextSize = 10
statusIndicator.Text = teleportLoaded and "✅ READY" or "⚠️ LOADING"
statusIndicator.TextColor3 = teleportLoaded and SUCCESS_COLOR or WARNING_COLOR
statusIndicator.TextXAlignment = Enum.TextXAlignment.Right
statusIndicator.Parent = titleBar

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -55)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = BG_DARK
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0
sidebar.Parent = inner

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(40, 40, 50)
sidebarStroke.Thickness = 1
sidebarStroke.Parent = sidebar

-- Navigation container
local navContainer = Instance.new("ScrollingFrame")
navContainer.Size = UDim2.new(1, -8, 1, -16)
navContainer.Position = UDim2.new(0, 4, 0, 8)
navContainer.BackgroundTransparency = 1
navContainer.BorderSizePixel = 0
navContainer.ScrollBarThickness = 2
navContainer.ScrollBarImageColor3 = ACCENT
navContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
navContainer.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 5)
navLayout.Parent = navContainer

-- Navigation buttons
local navBtns = {}

local function createNavBtn(text, icon, id)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. id
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.BackgroundTransparency = 0.3
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = #navBtns + 1
    btn.Parent = navContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(40, 40, 50)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 16
    iconLabel.Text = icon
    iconLabel.TextColor3 = TEXT_GRAY
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center
    iconLabel.Parent = btn
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 40, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 12
    textLabel.Text = text
    textLabel.TextColor3 = TEXT_WHITE
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = btn
    
    navBtns[id] = {btn = btn, icon = iconLabel, stroke = btnStroke, text = textLabel}
    return btn
end

-- Create navigation buttons
createNavBtn("Dashboard", "🏠", "Main")
createNavBtn("Teleport", "🌍", "Teleport")
createNavBtn("Shop", "🛒", "Shop")
createNavBtn("Settings", "⚙️", "Settings")
createNavBtn("About", "ℹ️", "Info")

navContainer.CanvasSize = UDim2.new(0, 0, 0, #navBtns * 41)

-- Content area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 12, 1, -55)
content.Position = UDim2.new(0, SIDEBAR_W + 8, 0, 45)
content.BackgroundColor3 = BG_DARK
content.BackgroundTransparency = 0.2
content.BorderSizePixel = 0
content.Parent = inner

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = content

local contentStroke = Instance.new("UIStroke")
contentStroke.Color = Color3.fromRGB(40, 40, 50)
contentStroke.Thickness = 1
contentStroke.Parent = content

local contentHeader = Instance.new("Frame")
contentHeader.Size = UDim2.new(1, -16, 0, 35)
contentHeader.Position = UDim2.new(0, 8, 0, 8)
contentHeader.BackgroundTransparency = 1
contentHeader.Parent = content

local contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(0.7, 0, 1, 0)
contentTitle.Position = UDim2.new(0, 0, 0, 0)
contentTitle.BackgroundTransparency = 1
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 14
contentTitle.Text = "DASHBOARD"
contentTitle.TextColor3 = TEXT_WHITE
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentHeader

local contentSubtitle = Instance.new("TextLabel")
contentSubtitle.Size = UDim2.new(0.3, -4, 1, 0)
contentSubtitle.Position = UDim2.new(0.7, 4, 0, 0)
contentSubtitle.BackgroundTransparency = 1
contentSubtitle.Font = Enum.Font.Gotham
contentSubtitle.TextSize = 10
contentSubtitle.Text = "Welcome"
contentSubtitle.TextColor3 = TEXT_GRAY
contentSubtitle.TextXAlignment = Enum.TextXAlignment.Right
contentSubtitle.Parent = contentHeader

-- Pages container
local pagesContainer = Instance.new("Frame")
pagesContainer.Name = "Pages"
pagesContainer.Size = UDim2.new(1, -16, 1, -60)
pagesContainer.Position = UDim2.new(0, 8, 0, 48)
pagesContainer.BackgroundTransparency = 1
pagesContainer.ClipsDescendants = true
pagesContainer.Parent = content

-- Create pages
local pages = {}

local function createPage(id, title)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. id
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = ACCENT
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = pagesContainer
    
    pages[id] = page
    return page
end

local mainPage = createPage("Main", "Dashboard")
local teleportPage = createPage("Teleport", "Teleport System")
local shopPage = createPage("Shop", "Shop")
local settingsPage = createPage("Settings", "Settings")
local infoPage = createPage("Info", "About")

-- Page switching
local currentPage = "Main"

local function switchPage(pageId, title)
    currentPage = pageId
    
    -- Update title
    contentTitle.Text = title:upper()
    contentSubtitle.Text = pageId
    
    -- Update button states
    for id, btnData in pairs(navBtns) do
        local isActive = (id == pageId)
        
        if isActive then
            TweenService:Create(btnData.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 10, 10),
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(btnData.stroke, TweenInfo.new(0.2), {
                Color = ACCENT
            }):Play()
            TweenService:Create(btnData.icon, TweenInfo.new(0.2), {
                TextColor3 = ACCENT
            }):Play()
        else
            TweenService:Create(btnData.btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(btnData.stroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(40, 40, 50)
            }):Play()
            TweenService:Create(btnData.icon, TweenInfo.new(0.2), {
                TextColor3 = TEXT_GRAY
            }):Play()
        end
    end
    
    -- Show selected page
    for id, page in pairs(pages) do
        if id == pageId then
            page.Visible = true
            TweenService:Create(page, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            -- Load specific page content
            if id == "Teleport" then
                loadTeleportPageContent(page)
            elseif id == "Main" then
                loadMainPageContent(page)
            end
        else
            page.Visible = false
            page.Position = UDim2.new(1, 0, 0, 0)
        end
    end
    
    -- Content animation
    TweenService:Create(contentStroke, TweenInfo.new(0.3), {
        Color = ACCENT
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(contentStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(40, 40, 50)
    }):Play()
end

-- Connect navigation buttons
for id, btnData in pairs(navBtns) do
    btnData.btn.MouseButton1Click:Connect(function()
        switchPage(id, id)
    end)
end

-- ============================================
-- TELEPORT PAGE CONTENT
-- ============================================
local function loadTeleportPageContent(page)
    -- Clear existing content
    for _, child in ipairs(page:GetChildren()) do
        child:Destroy()
    end
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(1, 0, 0, 400)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = page
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -20, 0, 50)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundColor3 = BG_DARK
    header.BackgroundTransparency = 0.2
    header.Parent = mainContainer
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local headerStroke = Instance.new("UIStroke")
    headerStroke.Color = ACCENT
    headerStroke.Thickness = 1
    headerStroke.Transparency = 0.5
    headerStroke.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -20, 0, 25)
    headerTitle.Position = UDim2.new(0, 10, 0, 5)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 16
    headerTitle.Text = teleportLoaded and "🌍 TELEPORT SYSTEM" or "⚠️ SYSTEM LOADING"
    headerTitle.TextColor3 = teleportLoaded and ACCENT or WARNING_COLOR
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    local headerSubtitle = Instance.new("TextLabel")
    headerSubtitle.Size = UDim2.new(1, -20, 0, 20)
    headerSubtitle.Position = UDim2.new(0, 10, 0, 30)
    headerSubtitle.BackgroundTransparency = 1
    headerSubtitle.Font = Enum.Font.Gotham
    headerSubtitle.TextSize = 12
    headerSubtitle.Text = teleportLoaded and "Instant teleport to locations and players" or "Loading modules via SecurityLoader..."
    headerSubtitle.TextColor3 = TEXT_GRAY
    headerSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    headerSubtitle.Parent = header
    
    if not teleportLoaded or not teleportSystem then
        -- Show loading message
        local loadingMsg = Instance.new("TextLabel")
        loadingMsg.Size = UDim2.new(1, -40, 0, 100)
        loadingMsg.Position = UDim2.new(0, 20, 0, 70)
        loadingMsg.BackgroundTransparency = 1
        loadingMsg.Font = Enum.Font.Gotham
        loadingMsg.TextSize = 14
        loadingMsg.Text = "🔒 Loading Teleport System...\n\nPlease wait while modules are loaded\nvia SecurityLoader"
        loadingMsg.TextColor3 = WARNING_COLOR
        loadingMsg.TextYAlignment = Enum.TextYAlignment.Center
        loadingMsg.TextXAlignment = Enum.TextXAlignment.Center
        loadingMsg.Parent = mainContainer
        return
    end
    
    -- Content grid
    local contentGrid = Instance.new("Frame")
    contentGrid.Size = UDim2.new(1, -20, 0, 320)
    contentGrid.Position = UDim2.new(0, 10, 0, 70)
    contentGrid.BackgroundTransparency = 1
    contentGrid.Parent = mainContainer
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.CellSize = UDim2.new(0.5, -5, 0, 150)
    gridLayout.Parent = contentGrid
    
    -- Location Teleport Card
    local locationCard = Instance.new("Frame")
    locationCard.BackgroundColor3 = BG_LIGHT
    locationCard.BackgroundTransparency = 0.1
    locationCard.Parent = contentGrid
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = locationCard
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = ACCENT
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.7
    cardStroke.Parent = locationCard
    
    -- Card header
    local cardHeader = Instance.new("Frame")
    cardHeader.Size = UDim2.new(1, 0, 0, 40)
    cardHeader.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
    cardHeader.BackgroundTransparency = 0.3
    cardHeader.Parent = locationCard
    
    local headerCorner2 = Instance.new("UICorner")
    headerCorner2.CornerRadius = UDim.new(0, 10, 0, 0)
    headerCorner2.Parent = cardHeader
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -20, 1, 0)
    cardTitle.Position = UDim2.new(0, 10, 0, 0)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextSize = 14
    cardTitle.Text = "📍 LOCATION TELEPORT"
    cardTitle.TextColor3 = ACCENT
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = cardHeader
    
    -- Teleport button
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(1, -20, 0, 35)
    teleportBtn.Position = UDim2.new(0, 10, 0, 50)
    teleportBtn.BackgroundColor3 = ACCENT
    teleportBtn.AutoButtonColor = false
    teleportBtn.Text = "SELECT LOCATION"
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextSize = 12
    teleportBtn.TextColor3 = TEXT_WHITE
    teleportBtn.Parent = locationCard
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 6)
    teleportCorner.Parent = teleportBtn
    
    teleportBtn.MouseButton1Click:Connect(function()
        if teleportSystem.TeleportModule and teleportSystem.TeleportModule.Locations then
            local locationNames = {}
            for name, _ in pairs(teleportSystem.TeleportModule.Locations) do
                table.insert(locationNames, name)
            end
            table.sort(locationNames)
            
            -- Show location selection (simple version)
            teleportBtn.Text = #locationNames .. " LOCATIONS"
            if #locationNames > 0 and teleportSystem.TeleportModule.TeleportTo then
                teleportSystem.TeleportModule.TeleportTo(locationNames[1])
                if teleportSystem.Notify then
                    teleportSystem.Notify("Teleported", "📍 To: " .. locationNames[1], 3)
                end
                
                teleportBtn.Text = "✓ TELEPORTED!"
                teleportBtn.BackgroundColor3 = SUCCESS_COLOR
                task.wait(1)
                teleportBtn.Text = "SELECT LOCATION"
                teleportBtn.BackgroundColor3 = ACCENT
            end
        end
    end)
    
    -- Player Teleport Card
    local playerCard = Instance.new("Frame")
    playerCard.BackgroundColor3 = BG_LIGHT
    playerCard.BackgroundTransparency = 0.1
    playerCard.Parent = contentGrid
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 10)
    playerCorner.Parent = playerCard
    
    local playerStroke = Instance.new("UIStroke")
    playerStroke.Color = Color3.fromRGB(100, 150, 255)
    playerStroke.Thickness = 1
    playerStroke.Transparency = 0.7
    playerStroke.Parent = playerCard
    
    -- Player card header
    local playerHeader = Instance.new("Frame")
    playerHeader.Size = UDim2.new(1, 0, 0, 40)
    playerHeader.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    playerHeader.BackgroundTransparency = 0.3
    playerHeader.Parent = playerCard
    
    local playerHeaderCorner = Instance.new("UICorner")
    playerHeaderCorner.CornerRadius = UDim.new(0, 10, 0, 0)
    playerHeaderCorner.Parent = playerHeader
    
    local playerTitle = Instance.new("TextLabel")
    playerTitle.Size = UDim2.new(1, -20, 1, 0)
    playerTitle.Position = UDim2.new(0, 10, 0, 0)
    playerTitle.BackgroundTransparency = 1
    playerTitle.Font = Enum.Font.GothamBold
    playerTitle.TextSize = 14
    playerTitle.Text = "👤 PLAYER TELEPORT"
    playerTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
    playerTitle.TextXAlignment = Enum.TextXAlignment.Left
    playerTitle.Parent = playerHeader
    
    -- Player teleport button
    local teleportToPlayerBtn = Instance.new("TextButton")
    teleportToPlayerBtn.Size = UDim2.new(1, -20, 0, 35)
    teleportToPlayerBtn.Position = UDim2.new(0, 10, 0, 50)
    teleportToPlayerBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    teleportToPlayerBtn.AutoButtonColor = false
    teleportToPlayerBtn.Text = "TELEPORT TO PLAYER"
    teleportToPlayerBtn.Font = Enum.Font.GothamBold
    teleportToPlayerBtn.TextSize = 12
    teleportToPlayerBtn.TextColor3 = TEXT_WHITE
    teleportToPlayerBtn.Parent = playerCard
    
    local playerTeleportCorner = Instance.new("UICorner")
    playerTeleportCorner.CornerRadius = UDim.new(0, 6)
    playerTeleportCorner.Parent = teleportToPlayerBtn
    
    teleportToPlayerBtn.MouseButton1Click:Connect(function()
        local playerCount = 0
        local localPlayer = Players.LocalPlayer
        local playerNames = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                table.insert(playerNames, player.Name)
                playerCount += 1
            end
        end
        
        teleportToPlayerBtn.Text = playerCount .. " PLAYERS ONLINE"
        
        if playerCount > 0 and teleportSystem.TeleportToPlayer and teleportSystem.TeleportToPlayer.TeleportTo then
            teleportSystem.TeleportToPlayer.TeleportTo(playerNames[1])
            if teleportSystem.Notify then
                teleportSystem.Notify("Teleported", "👤 To: " .. playerNames[1], 3)
            end
            
            teleportToPlayerBtn.Text = "✓ TELEPORTED!"
            teleportToPlayerBtn.BackgroundColor3 = SUCCESS_COLOR
            task.wait(1)
            teleportToPlayerBtn.Text = "TELEPORT TO PLAYER"
            teleportToPlayerBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        end
    end)
    
    -- Saved Locations Card
    local savedCard = Instance.new("Frame")
    savedCard.BackgroundColor3 = BG_LIGHT
    savedCard.BackgroundTransparency = 0.1
    savedCard.Parent = contentGrid
    
    local savedCorner = Instance.new("UICorner")
    savedCorner.CornerRadius = UDim.new(0, 10)
    savedCorner.Parent = savedCard
    
    local savedStroke = Instance.new("UIStroke")
    savedStroke.Color = Color3.fromRGB(255, 200, 50)
    savedStroke.Thickness = 1
    savedStroke.Transparency = 0.7
    savedStroke.Parent = savedCard
    
    -- Saved card header
    local savedHeader = Instance.new("Frame")
    savedHeader.Size = UDim2.new(1, 0, 0, 40)
    savedHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 10)
    savedHeader.BackgroundTransparency = 0.3
    savedHeader.Parent = savedCard
    
    local savedHeaderCorner = Instance.new("UICorner")
    savedHeaderCorner.CornerRadius = UDim.new(0, 10, 0, 0)
    savedHeaderCorner.Parent = savedHeader
    
    local savedTitle = Instance.new("TextLabel")
    savedTitle.Size = UDim2.new(1, -20, 1, 0)
    savedTitle.Position = UDim2.new(0, 10, 0, 0)
    savedTitle.BackgroundTransparency = 1
    savedTitle.Font = Enum.Font.GothamBold
    savedTitle.TextSize = 14
    savedTitle.Text = "⭐ SAVED LOCATIONS"
    savedTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
    savedTitle.TextXAlignment = Enum.TextXAlignment.Left
    savedTitle.Parent = savedHeader
    
    -- Saved buttons container
    local savedButtons = Instance.new("Frame")
    savedButtons.Size = UDim2.new(1, -20, 0, 90)
    savedButtons.Position = UDim2.new(0, 10, 0, 50)
    savedButtons.BackgroundTransparency = 1
    savedButtons.Parent = savedCard
    
    local savedLayout = Instance.new("UIListLayout")
    savedLayout.Padding = UDim.new(0, 8)
    savedLayout.FillDirection = Enum.FillDirection.Vertical
    savedLayout.Parent = savedButtons
    
    -- Save Location Button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, 0, 0, 35)
    saveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    saveBtn.AutoButtonColor = false
    saveBtn.Text = "💾 SAVE LOCATION"
    saveBtn.Font = Enum.Font.GothamSemibold
    saveBtn.TextSize = 11
    saveBtn.TextColor3 = TEXT_WHITE
    saveBtn.Parent = savedButtons
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 6)
    saveCorner.Parent = saveBtn
    
    saveBtn.MouseButton1Click:Connect(function()
        if teleportSystem.SavedLocation and teleportSystem.SavedLocation.Save then
            teleportSystem.SavedLocation.Save()
            if teleportSystem.Notify then
                teleportSystem.Notify("Saved", "💾 Location saved!", 3)
            end
            
            saveBtn.Text = "✓ SAVED!"
            saveBtn.BackgroundColor3 = SUCCESS_COLOR
            task.wait(1)
            saveBtn.Text = "💾 SAVE LOCATION"
            saveBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        end
    end)
    
    -- Teleport to Saved Button
    local teleportSavedBtn = Instance.new("TextButton")
    teleportSavedBtn.Size = UDim2.new(1, 0, 0, 35)
    teleportSavedBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    teleportSavedBtn.AutoButtonColor = false
    teleportSavedBtn.Text = "🚀 TELEPORT TO SAVED"
    teleportSavedBtn.Font = Enum.Font.GothamSemibold
    teleportSavedBtn.TextSize = 11
    teleportSavedBtn.TextColor3 = TEXT_WHITE
    teleportSavedBtn.Parent = savedButtons
    
    local teleportSavedCorner = Instance.new("UICorner")
    teleportSavedCorner.CornerRadius = UDim.new(0, 6)
    teleportSavedCorner.Parent = teleportSavedBtn
    
    teleportSavedBtn.MouseButton1Click:Connect(function()
        if teleportSystem.SavedLocation and teleportSystem.SavedLocation.Teleport then
            local success = teleportSystem.SavedLocation.Teleport()
            if success then
                if teleportSystem.Notify then
                    teleportSystem.Notify("Teleported", "🚀 To saved location!", 3)
                end
                
                teleportSavedBtn.Text = "✓ TELEPORTED!"
                teleportSavedBtn.BackgroundColor3 = SUCCESS_COLOR
            else
                teleportSavedBtn.Text = "❌ NO LOCATION"
                teleportSavedBtn.BackgroundColor3 = ERROR_COLOR
            end
            task.wait(1)
            teleportSavedBtn.Text = "🚀 TELEPORT TO SAVED"
            teleportSavedBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        end
    end)
    
    -- Quick Teleport Card
    local quickCard = Instance.new("Frame")
    quickCard.BackgroundColor3 = BG_LIGHT
    quickCard.BackgroundTransparency = 0.1
    quickCard.Parent = contentGrid
    
    local quickCorner = Instance.new("UICorner")
    quickCorner.CornerRadius = UDim.new(0, 10)
    quickCorner.Parent = quickCard
    
    local quickStroke = Instance.new("UIStroke")
    quickStroke.Color = Color3.fromRGB(150, 100, 255)
    quickStroke.Thickness = 1
    quickStroke.Transparency = 0.7
    quickStroke.Parent = quickCard
    
    -- Quick card header
    local quickHeader = Instance.new("Frame")
    quickHeader.Size = UDim2.new(1, 0, 0, 40)
    quickHeader.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
    quickHeader.BackgroundTransparency = 0.3
    quickHeader.Parent = quickCard
    
    local quickHeaderCorner = Instance.new("UICorner")
    quickHeaderCorner.CornerRadius = UDim.new(0, 10, 0, 0)
    quickHeaderCorner.Parent = quickHeader
    
    local quickTitle = Instance.new("TextLabel")
    quickTitle.Size = UDim2.new(1, -20, 1, 0)
    quickTitle.Position = UDim2.new(0, 10, 0, 0)
    quickTitle.BackgroundTransparency = 1
    quickTitle.Font = Enum.Font.GothamBold
    quickTitle.TextSize = 14
    quickTitle.Text = "⚡ QUICK TELEPORT"
    quickTitle.TextColor3 = Color3.fromRGB(150, 100, 255)
    quickTitle.TextXAlignment = Enum.TextXAlignment.Left
    quickTitle.Parent = quickHeader
    
    -- Quick buttons grid
    local quickGrid = Instance.new("Frame")
    quickGrid.Size = UDim2.new(1, -20, 0, 90)
    quickGrid.Position = UDim2.new(0, 10, 0, 50)
    quickGrid.BackgroundTransparency = 1
    quickGrid.Parent = quickCard
    
    local quickGridLayout = Instance.new("UIGridLayout")
    quickGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    quickGridLayout.CellSize = UDim2.new(0.5, -2.5, 0, 40)
    quickGridLayout.Parent = quickGrid
    
    -- Spawn button
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    spawnBtn.AutoButtonColor = false
    spawnBtn.Text = "🏠 SPAWN"
    spawnBtn.Font = Enum.Font.GothamSemibold
    spawnBtn.TextSize = 11
    spawnBtn.TextColor3 = TEXT_WHITE
    spawnBtn.Parent = quickGrid
    
    local spawnCorner = Instance.new("UICorner")
    spawnCorner.CornerRadius = UDim.new(0, 6)
    spawnCorner.Parent = spawnBtn
    
    spawnBtn.MouseButton1Click:Connect(function()
        if teleportSystem.TeleportModule and teleportSystem.TeleportModule.TeleportTo then
            teleportSystem.TeleportModule.TeleportTo("Spawn Point")
            if teleportSystem.Notify then
                teleportSystem.Notify("Teleported", "🏠 To Spawn", 2)
            end
        end
    end)
    
    -- Market button
    local marketBtn = Instance.new("TextButton")
    marketBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 60)
    marketBtn.AutoButtonColor = false
    marketBtn.Text = "🛒 MARKET"
    marketBtn.Font = Enum.Font.GothamSemibold
    marketBtn.TextSize = 11
    marketBtn.TextColor3 = TEXT_WHITE
    marketBtn.Parent = quickGrid
    
    local marketCorner = Instance.new("UICorner")
    marketCorner.CornerRadius = UDim.new(0, 6)
    marketCorner.Parent = marketBtn
    
    marketBtn.MouseButton1Click:Connect(function()
        if teleportSystem.TeleportModule and teleportSystem.TeleportModule.TeleportTo then
            teleportSystem.TeleportModule.TeleportTo("Market Center")
            if teleportSystem.Notify then
                teleportSystem.Notify("Teleported", "🛒 To Market", 2)
            end
        end
    end)
    
    -- Bank button
    local bankBtn = Instance.new("TextButton")
    bankBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 80)
    bankBtn.AutoButtonColor = false
    bankBtn.Text = "🏦 BANK"
    bankBtn.Font = Enum.Font.GothamSemibold
    bankBtn.TextSize = 11
    bankBtn.TextColor3 = TEXT_WHITE
    bankBtn.Parent = quickGrid
    
    local bankCorner = Instance.new("UICorner")
    bankCorner.CornerRadius = UDim.new(0, 6)
    bankCorner.Parent = bankBtn
    
    bankBtn.MouseButton1Click:Connect(function()
        if teleportSystem.TeleportModule and teleportSystem.TeleportModule.TeleportTo then
            teleportSystem.TeleportModule.TeleportTo("Bank")
            if teleportSystem.Notify then
                teleportSystem.Notify("Teleported", "🏦 To Bank", 2)
            end
        end
    end)
    
    -- Warehouse button
    local warehouseBtn = Instance.new("TextButton")
    warehouseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    warehouseBtn.AutoButtonColor = false
    warehouseBtn.Text = "📦 WAREHOUSE"
    warehouseBtn.Font = Enum.Font.GothamSemibold
    warehouseBtn.TextSize = 11
    warehouseBtn.TextColor3 = TEXT_WHITE
    warehouseBtn.Parent = quickGrid
    
    local warehouseCorner = Instance.new("UICorner")
    warehouseCorner.CornerRadius = UDim.new(0, 6)
    warehouseCorner.Parent = warehouseBtn
    
    warehouseBtn.MouseButton1Click:Connect(function()
        if teleportSystem.TeleportModule and teleportSystem.TeleportModule.TeleportTo then
            teleportSystem.TeleportModule.TeleportTo("Warehouse")
            if teleportSystem.Notify then
                teleportSystem.Notify("Teleported", "📦 To Warehouse", 2)
            end
        end
    end)
end

-- ============================================
-- MAIN PAGE CONTENT
-- ============================================
local function loadMainPageContent(page)
    for _, child in ipairs(page:GetChildren()) do
        child:Destroy()
    end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 200)
    container.BackgroundTransparency = 1
    container.Parent = page
    
    -- Status panel
    local statusPanel = Instance.new("Frame")
    statusPanel.Size = UDim2.new(1, -20, 0, 60)
    statusPanel.Position = UDim2.new(0, 10, 0, 10)
    statusPanel.BackgroundColor3 = BG_DARK
    statusPanel.BackgroundTransparency = 0.2
    statusPanel.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = statusPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = teleportLoaded and SUCCESS_COLOR or WARNING_COLOR
    stroke.Thickness = 1
    stroke.Parent = statusPanel
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -20, 0, 25)
    statusText.Position = UDim2.new(0, 10, 0, 10)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 13
    statusText.Text = teleportLoaded and "✅ SYSTEM READY" or "⚠️ LOADING MODULES"
    statusText.TextColor3 = teleportLoaded and SUCCESS_COLOR or WARNING_COLOR
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusPanel
    
    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, -20, 0, 25)
    descText.Position = UDim2.new(0, 10, 0, 35)
    descText.BackgroundTransparency = 1
    descText.Font = Enum.Font.Gotham
    descText.TextSize = 11
    descText.Text = teleportLoaded and "Teleport System loaded successfully!" or "Loading via SecurityLoader..."
    descText.TextColor3 = TEXT_GRAY
    descText.TextXAlignment = Enum.TextXAlignment.Left
    descText.Parent = statusPanel
    
    -- Features panel
    local featuresPanel = Instance.new("Frame")
    featuresPanel.Size = UDim2.new(1, -20, 0, 120)
    featuresPanel.Position = UDim2.new(0, 10, 0, 80)
    featuresPanel.BackgroundColor3 = BG_DARK
    featuresPanel.BackgroundTransparency = 0.2
    featuresPanel.Parent = container
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 8)
    corner2.Parent = featuresPanel
    
    local featuresTitle = Instance.new("TextLabel")
    featuresTitle.Size = UDim2.new(1, -20, 0, 20)
    featuresTitle.Position = UDim2.new(0, 10, 0, 5)
    featuresTitle.BackgroundTransparency = 1
    featuresTitle.Font = Enum.Font.GothamBold
    featuresTitle.TextSize = 12
    featuresTitle.Text = "ACTIVE FEATURES"
    featuresTitle.TextColor3 = ACCENT
    featuresTitle.TextXAlignment = Enum.TextXAlignment.Left
    featuresTitle.Parent = featuresPanel
    
    local feature1 = Instance.new("TextLabel")
    feature1.Size = UDim2.new(0.5, -5, 0, 20)
    feature1.Position = UDim2.new(0, 10, 0, 30)
    feature1.BackgroundTransparency = 1
    feature1.Font = Enum.Font.Gotham
    feature1.TextSize = 11
    feature1.Text = teleportLoaded and "✓ Teleport System" or "⏳ Teleport System"
    feature1.TextColor3 = teleportLoaded and SUCCESS_COLOR or TEXT_GRAY
    feature1.TextXAlignment = Enum.TextXAlignment.Left
    feature1.Parent = featuresPanel
    
    local feature2 = Instance.new("TextLabel")
    feature2.Size = UDim2.new(0.5, -5, 0, 20)
    feature2.Position = UDim2.new(0.5, 5, 0, 30)
    feature2.BackgroundTransparency = 1
    feature2.Font = Enum.Font.Gotham
    feature2.TextSize = 11
    feature2.Text = "✓ Premium UI"
    feature2.TextColor3 = SUCCESS_COLOR
    feature2.TextXAlignment = Enum.TextXAlignment.Left
    feature2.Parent = featuresPanel
    
    local feature3 = Instance.new("TextLabel")
    feature3.Size = UDim2.new(0.5, -5, 0, 20)
    feature3.Position = UDim2.new(0, 10, 0, 50)
    feature3.BackgroundTransparency = 1
    feature3.Font = Enum.Font.Gotham
    feature3.TextSize = 11
    feature3.Text = "✓ Security Loader"
    feature3.TextColor3 = SUCCESS_COLOR
    feature3.TextXAlignment = Enum.TextXAlignment.Left
    feature3.Parent = featuresPanel
    
    local feature4 = Instance.new("TextLabel")
    feature4.Size = UDim2.new(0.5, -5, 0, 20)
    feature4.Position = UDim2.new(0.5, 5, 0, 50)
    feature4.BackgroundTransparency = 1
    feature4.Font = Enum.Font.Gotham
    feature4.TextSize = 11
    feature4.Text = "✓ Player Teleport"
    feature4.TextColor3 = SUCCESS_COLOR
    feature4.TextXAlignment = Enum.TextXAlignment.Left
    feature4.Parent = featuresPanel
end

-- ============================================
-- OTHER PAGES
-- ============================================
-- Shop page
local shopText = Instance.new("TextLabel")
shopText.Size = UDim2.new(1, -20, 1, -20)
shopText.Position = UDim2.new(0, 10, 0, 10)
shopText.BackgroundTransparency = 1
shopText.Font = Enum.Font.Gotham
shopText.TextSize = 14
shopText.Text = "🛒 Shop Features\n\nComing soon..."
shopText.TextColor3 = TEXT_GRAY
shopText.TextYAlignment = Enum.TextYAlignment.Center
shopText.TextXAlignment = Enum.TextXAlignment.Center
shopText.Parent = shopPage

-- Settings page
local settingsText = Instance.new("TextLabel")
settingsText.Size = UDim2.new(1, -20, 1, -20)
settingsText.Position = UDim2.new(0, 10, 0, 10)
settingsText.BackgroundTransparency = 1
settingsText.Font = Enum.Font.Gotham
settingsText.TextSize = 14
settingsText.Text = "⚙️ Settings\n\nComing soon..."
settingsText.TextColor3 = TEXT_GRAY
settingsText.TextYAlignment = Enum.TextYAlignment.Center
settingsText.TextXAlignment = Enum.TextXAlignment.Center
settingsText.Parent = settingsPage

-- Info page
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -20, 1, -20)
infoText.Position = UDim2.new(0, 10, 0, 10)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.Text = string.format([[
⚡ NEON UI v2.4
━━━━━━━━━━━━━━━
• Developer: Kaitun
• Security: Lynx Loader
• Status: %s

📌 Features:
✓ Premium Glass UI
✓ Teleport System
✓ Security Integration
✓ Smooth Animations

🔑 Toggle: [G] Key]], teleportLoaded and "ACTIVE" or "LOADING")
infoText.TextColor3 = TEXT_WHITE
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoPage

-- ============================================
-- UI TOGGLE SYSTEM
-- ============================================
local uiVisible = false

local function toggleUI(show)
    uiVisible = show
    
    if show then
        container.Visible = true
        blur.Visible = true
        
        container.Size = UDim2.new(0, 0, 0, 0)
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, WIDTH, 0, HEIGHT),
            Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        }):Play()
        
        blur.BackgroundTransparency = 1
        TweenService:Create(blur, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.5
        }):Play()
        
        glow.ImageTransparency = 0.9
        TweenService:Create(glow, TweenInfo.new(0.4), {
            ImageTransparency = 0.7
        }):Play()
    else
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        TweenService:Create(blur, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.9
        }):Play()
        
        task.wait(0.3)
        container.Visible = false
        blur.Visible = false
    end
end

-- Keybind
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        toggleUI(not uiVisible)
    end
end)

-- ============================================
-- INITIALIZE
-- ============================================
toggleUI(false)
switchPage("Main", "Dashboard")

print("=======================================")
print("⚡ NEON UI LOADED SUCCESSFULLY")
print("🔒 SecurityLoader: " .. (teleportLoaded and "ACTIVE" or "FAILED"))
print("📌 Press G to toggle UI")
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
    
    SwitchPage = switchPage,
    
    GetSecurityLoader = function()
        return SecurityLoader
    end,
    
    GetTeleportSystem = function()
        return teleportSystem
    end,
    
    ReloadTeleportSystem = function()
        teleportLoaded = loadTeleportSystem()
        statusIndicator.Text = teleportLoaded and "✅ READY" or "⚠️ LOADING"
        statusIndicator.TextColor3 = teleportLoaded and SUCCESS_COLOR or WARNING_COLOR
        return teleportLoaded
    end
}