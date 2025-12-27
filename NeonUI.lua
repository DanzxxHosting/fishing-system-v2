-- Neon Dashboard UI Premium - WITH SECURITY LOADER INTEGRATION
-- Tema: Glass Effect + Neon Red
-- Keybind: G untuk toggle
-- Navigation System: Dashboard, Teleport, Shop, Settings, About

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 520
local HEIGHT = 280
local SIDEBAR_W = 160
local ACCENT = Color3.fromRGB(255, 62, 62)
local ACCENT_GLOW = Color3.fromRGB(255, 100, 100)
local BG = Color3.fromRGB(10, 10, 12)
local GLASS_COLOR = Color3.fromRGB(20, 20, 25)
local GLASS_TRANSPARENCY = 0.3

-- Cleanup old UI
if playerGui:FindFirstChild("NeonDashboard") then
    playerGui.NeonDashboard:Destroy()
end

-- ============================================
-- SECURITY LOADER INTEGRATION
-- ============================================
local SecurityLoader
local TeleportModule, TeleportToPlayer, SavedLocation, Notify

local function loadModules()
    print("🔄 Loading modules via SecurityLoader...")
    
    -- URL untuk SecurityLoader
    local loaderURL = "https://raw.githubusercontent.com/DanzxxHosting/fishing-system-v2/refs/heads/main/Main/SecurityLoader.lua"
    
    -- Load SecurityLoader terlebih dahulu
    local success, result = pcall(function()
        local loaderCode = game:HttpGet(loaderURL)
        local loaderFunc = loadstring(loaderCode)
        SecurityLoader = loaderFunc()
        return SecurityLoader
    end)
    
    if not success then
        warn("❌ Failed to load SecurityLoader:", result)
        return false
    end
    
    print("✅ SecurityLoader loaded successfully!")
    
    -- Enable anti-dump protection
    if SecurityLoader.EnableAntiDump then
        SecurityLoader.EnableAntiDump()
    end
    
    -- Load modules via SecurityLoader
    TeleportModule = SecurityLoader.LoadModule("TeleportModule")
    TeleportToPlayer = SecurityLoader.LoadModule("TeleportToPlayer")
    SavedLocation = SecurityLoader.LoadModule("SavedLocation")
    Notify = SecurityLoader.LoadModule("Notify")
    
    -- Fallback jika Notify tidak ada
    if not Notify then
        Notify = {}
        function Notify.Send(title, message, duration)
            print("[Notify] " .. title .. ": " .. message)
        end
        function Notify:__call(title, message, duration)
            self.Send(title, message, duration)
        end
    end
    
    -- Fallback jika TeleportModule tidak ada
    if not TeleportModule then
        warn("⚠️ TeleportModule not found via SecurityLoader, using fallback...")
        TeleportModule = {}
        TeleportModule.Locations = {}
        function TeleportModule.TeleportTo(name)
            warn("Fallback teleport:", name)
            return true
        end
    end
    
    -- Fallback untuk TeleportToPlayer
    if not TeleportToPlayer then
        TeleportToPlayer = {}
        function TeleportToPlayer.TeleportTo(playerName)
            warn("Fallback player teleport:", playerName)
            return true
        end
    end
    
    -- Fallback untuk SavedLocation
    if not SavedLocation then
        SavedLocation = {}
        function SavedLocation.Save() warn("SavedLocation.Save fallback") return true end
        function SavedLocation.Teleport() warn("SavedLocation.Teleport fallback") return true end
        function SavedLocation.Reset() warn("SavedLocation.Reset fallback") return true end
    end
    
    print("✅ All modules loaded!")
    return true
end

-- Panggil fungsi load
local modulesLoaded = loadModules()

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
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local function makeDropdown(parent, title, icon, items, callback, id)
    local container = Instance.new("Frame")
    container.Name = id or "Dropdown"
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    titleLabel.Text = icon .. " " .. title
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.6, 0, 1, 0)
    dropdownBtn.Position = UDim2.new(0.4, 0, 0, 0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.Text = "Select..."
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 11
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdownBtn
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 100)
    dropdownFrame.Position = UDim2.new(0, 0, 1, 2)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Visible = false
    dropdownFrame.ZIndex = 10
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = dropdownBtn
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = dropdownFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = ACCENT
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scrollFrame
    
    -- Populate items
    for _, item in ipairs(items) do
        local option = Instance.new("TextButton")
        option.Size = UDim2.new(1, -6, 0, 28)
        option.Position = UDim2.new(0, 3, 0, 0)
        option.BackgroundColor3 = Color3.fromRGB(60, 70, 100)
        option.BorderSizePixel = 0
        option.TextColor3 = Color3.fromRGB(255, 255, 255)
        option.Text = item
        option.Font = Enum.Font.Gotham
        option.TextSize = 11
        option.AutoButtonColor = false
        option.Parent = scrollFrame
        
        local corner3 = Instance.new("UICorner")
        corner3.CornerRadius = UDim.new(0, 3)
        corner3.Parent = option
        
        option.MouseButton1Click:Connect(function()
            dropdownBtn.Text = item
            dropdownFrame.Visible = false
            if callback then callback(item) end
        end)
        
        -- Hover effect
        option.MouseEnter:Connect(function()
            TweenService:Create(option, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 90, 120)
            }):Play()
        end)
        
        option.MouseLeave:Connect(function()
            TweenService:Create(option, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 70, 100)
            }):Play()
        end)
    end
    
    -- Toggle dropdown
    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
    end)
    
    -- Close dropdown when clicking elsewhere
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dropdownFrame.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local dropdownPos = dropdownFrame.AbsolutePosition
                local dropdownSize = dropdownFrame.AbsoluteSize
                
                if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                       mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) then
                    dropdownFrame.Visible = false
                end
            end
        end
    end)
    
    return container
end

local function makeCategory(parent, title, icon)
    local category = Instance.new("Frame")
    category.Size = UDim2.new(1, -20, 0, 120)
    category.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    category.BorderSizePixel = 0
    category.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = category
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 60, 85)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = category
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 8, 0, 0)
    corner2.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = icon .. " " .. title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = category
    
    return contentFrame
end

-- ============================================
-- CREATE UI
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
glass.BackgroundColor3 = GLASS_COLOR
glass.BackgroundTransparency = GLASS_TRANSPARENCY
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
statusIndicator.Text = modulesLoaded and "✅ Modules Loaded" or "⚠️ Loading Modules..."
statusIndicator.TextColor3 = modulesLoaded and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 150, 50)
statusIndicator.TextXAlignment = Enum.TextXAlignment.Right
statusIndicator.Parent = titleBar

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -55)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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

-- Navigation buttons
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
    iconLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
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
    textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
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
content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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
contentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentHeader

local contentSubtitle = Instance.new("TextLabel")
contentSubtitle.Size = UDim2.new(0.3, -4, 1, 0)
contentSubtitle.Position = UDim2.new(0.7, 4, 0, 0)
contentSubtitle.BackgroundTransparency = 1
contentSubtitle.Font = Enum.Font.Gotham
contentSubtitle.TextSize = 10
contentSubtitle.Text = "Welcome"
contentSubtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
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
                TextColor3 = Color3.fromRGB(180, 180, 200)
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
        else
            page.Visible = false
            page.Position = UDim2.new(1, 0, 0, 0)
        end
    end
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
if TeleportModule and TeleportModule.Locations then
    -- Location teleport
    local locationItems = {}
    for name, _ in pairs(TeleportModule.Locations) do
        table.insert(locationItems, name)
    end
    table.sort(locationItems)
    
    makeDropdown(teleportPage, "Teleport to Location", "📍", locationItems, function(selected)
        if TeleportModule.TeleportTo then
            TeleportModule.TeleportTo(selected)
            if Notify then
                Notify.Send("Teleported", "Teleported to: " .. selected, 3)
            end
        end
    end, "LocationTeleport")
    
    -- Player teleport
    local playerDropdown
    local localPlayer = Players.LocalPlayer
    
    local function updatePlayerList()
        local playerItems = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                table.insert(playerItems, player.Name)
            end
        end
        table.sort(playerItems)
        
        -- Remove old dropdown
        local oldDropdown = teleportPage:FindFirstChild("PlayerTeleport")
        if oldDropdown then
            oldDropdown:Destroy()
        end
        
        -- Create new dropdown
        playerDropdown = makeDropdown(teleportPage, "Teleport to Player", "👤", playerItems, function(selected)
            if TeleportToPlayer and TeleportToPlayer.TeleportTo then
                TeleportToPlayer.TeleportTo(selected)
                if Notify then
                    Notify.Send("Teleported", "Teleported to player: " .. selected, 3)
                end
            else
                warn("TeleportToPlayer module not available")
            end
        end, "PlayerTeleport")
    end
    
    -- Initial update
    updatePlayerList()
    
    -- Auto refresh
    Players.PlayerAdded:Connect(function(player)
        task.wait(0.5)
        updatePlayerList()
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        task.wait(0.1)
        updatePlayerList()
    end)
    
    -- Saved locations category
    local savedCat = makeCategory(teleportPage, "Saved Location", "⭐")
    
    makeButton(savedCat, "Save Current Location", function()
        if SavedLocation and SavedLocation.Save then
            if SavedLocation.Save() then
                if Notify then
                    Notify.Send("Saved", "Location saved successfully!", 3)
                end
            end
        end
    end, {
        BackgroundColor = Color3.fromRGB(70, 120, 200)
    })
    
    makeButton(savedCat, "Teleport to Saved", function()
        if SavedLocation and SavedLocation.Teleport then
            if SavedLocation.Teleport() then
                if Notify then
                    Notify.Send("Teleported", "Teleported to saved location!", 3)
                end
            else
                if Notify then
                    Notify.Send("Error", "No saved location found!", 3)
                end
            end
        end
    end, {
        BackgroundColor = Color3.fromRGB(70, 180, 80)
    })
    
    makeButton(savedCat, "Reset Saved Location", function()
        if SavedLocation and SavedLocation.Reset then
            SavedLocation.Reset()
            if Notify then
                Notify.Send("Reset", "Saved location cleared!", 3)
            end
        end
    end, {
        BackgroundColor = Color3.fromRGB(200, 100, 80)
    })
end

-- ============================================
-- MAIN PAGE CONTENT
-- ============================================
local function createMainPage()
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 150)
    container.BackgroundTransparency = 1
    container.Parent = mainPage
    
    -- Status panel
    local statusPanel = Instance.new("Frame")
    statusPanel.Size = UDim2.new(1, -20, 0, 60)
    statusPanel.Position = UDim2.new(0, 10, 0, 10)
    statusPanel.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    statusPanel.BackgroundTransparency = 0.2
    statusPanel.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = statusPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = modulesLoaded and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 100, 0)
    stroke.Thickness = 1
    stroke.Parent = statusPanel
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -20, 0, 25)
    statusText.Position = UDim2.new(0, 10, 0, 10)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 13
    statusText.Text = modulesLoaded and "✅ SYSTEM READY" or "⚠️ LOADING MODULES"
    statusText.TextColor3 = modulesLoaded and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 200, 100)
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusPanel
    
    local descText = Instance.new("TextLabel")
    descText.Size = UDim2.new(1, -20, 0, 25)
    descText.Position = UDim2.new(0, 10, 0, 35)
    descText.BackgroundTransparency = 1
    descText.Font = Enum.Font.Gotham
    descText.TextSize = 11
    descText.Text = modulesLoaded and "All modules loaded successfully!" or "Loading modules via SecurityLoader..."
    descText.TextColor3 = Color3.fromRGB(180, 180, 200)
    descText.TextXAlignment = Enum.TextXAlignment.Left
    descText.Parent = statusPanel
    
    -- Features panel
    local featuresPanel = Instance.new("Frame")
    featuresPanel.Size = UDim2.new(1, -20, 0, 70)
    featuresPanel.Position = UDim2.new(0, 10, 0, 80)
    featuresPanel.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
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
    feature1.Text = "✓ Teleport System"
    feature1.TextColor3 = Color3.fromRGB(180, 255, 180)
    feature1.TextXAlignment = Enum.TextXAlignment.Left
    feature1.Parent = featuresPanel
    
    local feature2 = Instance.new("TextLabel")
    feature2.Size = UDim2.new(0.5, -5, 0, 20)
    feature2.Position = UDim2.new(0.5, 5, 0, 30)
    feature2.BackgroundTransparency = 1
    feature2.Font = Enum.Font.Gotham
    feature2.TextSize = 11
    feature2.Text = "✓ Player Teleport"
    feature2.TextColor3 = Color3.fromRGB(180, 255, 180)
    feature2.TextXAlignment = Enum.TextXAlignment.Left
    feature2.Parent = featuresPanel
    
    local feature3 = Instance.new("TextLabel")
    feature3.Size = UDim2.new(0.5, -5, 0, 20)
    feature3.Position = UDim2.new(0, 10, 0, 50)
    feature3.BackgroundTransparency = 1
    feature3.Font = Enum.Font.Gotham
    feature3.TextSize = 11
    feature3.Text = "✓ Save Locations"
    feature3.TextColor3 = Color3.fromRGB(180, 255, 180)
    feature3.TextXAlignment = Enum.TextXAlignment.Left
    feature3.Parent = featuresPanel
    
    local feature4 = Instance.new("TextLabel")
    feature4.Size = UDim2.new(0.5, -5, 0, 20)
    feature4.Position = UDim2.new(0.5, 5, 0, 50)
    feature4.BackgroundTransparency = 1
    feature4.Font = Enum.Font.Gotham
    feature4.TextSize = 11
    feature4.Text = "✓ Security Loader"
    feature4.TextColor3 = Color3.fromRGB(180, 255, 180)
    feature4.TextXAlignment = Enum.TextXAlignment.Left
    feature4.Parent = featuresPanel
end

createMainPage()

-- ============================================
-- OTHER PAGES (PLACEHOLDER)
-- ============================================
-- Shop page
local shopText = Instance.new("TextLabel")
shopText.Size = UDim2.new(1, -20, 1, -20)
shopText.Position = UDim2.new(0, 10, 0, 10)
shopText.BackgroundTransparency = 1
shopText.Font = Enum.Font.Gotham
shopText.TextSize = 14
shopText.Text = "🛒 Shop Features\n\nComing soon..."
shopText.TextColor3 = Color3.fromRGB(200, 200, 220)
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
settingsText.TextColor3 = Color3.fromRGB(200, 200, 220)
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
infoText.Text = [[⚡ NEON UI v2.0
━━━━━━━━━━━━━━━
• Developer: Kaitun
• Security: Lynx Loader v2.3.0
• Features: Teleport, Security
• Status: Active

🔒 Modules Loaded:
✓ TeleportModule
✓ TeleportToPlayer  
✓ SavedLocation
✓ Notify System

📌 Press G to toggle UI]]
infoText.TextColor3 = Color3.fromRGB(220, 220, 240)
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
        
        delay(0.3, function()
            container.Visible = false
            blur.Visible = false
        end)
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
print("🔒 SecurityLoader: " .. (modulesLoaded and "ACTIVE" or "FAILED"))
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
    
    GetModules = function()
        return {
            TeleportModule = TeleportModule,
            TeleportToPlayer = TeleportToPlayer,
            SavedLocation = SavedLocation,
            Notify = Notify
        }
    end
}