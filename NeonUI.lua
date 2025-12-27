-- UI.lua
-- Main UI Interface untuk semua fitur

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cek apakah game sudah dimuat
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

-- Load module fitur
local AutoFishingModule
local function loadAutoFishing()
    local success, module = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/DanzxxHosting/fishing-system-v2/refs/heads/main/Main/autofishing.lua"))()
        -- Atau untuk local execution:
        -- return require(script.Parent.Fitur.autofishing)
    end)
    
    if success and module then
        AutoFishingModule = module
        print("[UI] Auto Fishing module loaded successfully")
        return true
    else
        warn("[UI] Failed to load Auto Fishing module:", module)
        return false
    end
end

-- Konfigurasi UI
local UIConfig = {
    MainColor = Color3.fromRGB(30, 30, 40),
    SecondaryColor = Color3.fromRGB(45, 45, 55),
    AccentColor = Color3.fromRGB(0, 170, 255),
    SuccessColor = Color3.fromRGB(0, 200, 100),
    ErrorColor = Color3.fromRGB(220, 60, 60),
    TextColor = Color3.fromRGB(240, 240, 240)
}

-- Class untuk membuat UI element
local UIElement = {}
UIElement.__index = UIElement

function UIElement.new(name, size, position)
    local self = setmetatable({}, UIElement)
    self.Name = name or "UIElement"
    self.Elements = {}
    return self
end

function UIElement:CreateLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Name = self.Name .. "_Label"
    label.Size = size or UDim2.new(1, 0, 0, 30)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = UIConfig.TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = parent
    
    table.insert(self.Elements, label)
    return label
end

function UIElement:CreateButton(parent, text, size, position, callback)
    local button = Instance.new("TextButton")
    button.Name = self.Name .. "_Button"
    button.Size = size or UDim2.new(1, -20, 0, 35)
    button.Position = position or UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = UIConfig.AccentColor
    button.Text = text
    button.TextColor3 = UIConfig.TextColor
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = true
    button.Parent = parent
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 190, 255)
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = UIConfig.AccentColor
        })
        tween:Play()
    end)
    
    table.insert(self.Elements, button)
    return button
end

function UIElement:CreateFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Name = self.Name .. "_Frame"
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = UIConfig.MainColor
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    table.insert(self.Elements, frame)
    return frame
end

function UIElement:Destroy()
    for _, element in ipairs(self.Elements) do
        if element and element.Parent then
            element:Destroy()
        end
    end
    self.Elements = {}
end

-- Main UI Manager
local UIManager = {
    ActiveWindows = {},
    IsVisible = true
}

function UIManager:CreateMainWindow()
    -- Hapus UI lama jika ada
    local oldUI = player:FindFirstChild("FishItHubGUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Buat ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishItHubGUI"
    screenGui.DisplayOrder = 999
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = UIConfig.MainColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local mainShadow = Instance.new("ImageLabel")
    mainShadow.Name = "Shadow"
    mainShadow.Size = UDim2.new(1, 0, 1, 0)
    mainShadow.Position = UDim2.new(0, 0, 0, 0)
    mainShadow.BackgroundTransparency = 1
    mainShadow.Image = "rbxassetid://1316045217"
    mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    mainShadow.ImageTransparency = 0.88
    mainShadow.ScaleType = Enum.ScaleType.Slice
    mainShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    mainShadow.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = UIConfig.SecondaryColor
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12, 0, 0)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎣 Fish It Hub"
    titleLabel.TextColor3 = UIConfig.TextColor
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = UIConfig.ErrorColor
    closeBtn.Text = "X"
    closeBtn.TextColor3 = UIConfig.TextColor
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 35)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -20, 0, 25)
    statusBar.Position = UDim2.new(0, 10, 1, -30)
    statusBar.BackgroundColor3 = UIConfig.SecondaryColor
    statusBar.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusBar
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = UIConfig.TextColor
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBar
    
    -- Tab System
    local tabs = {
        {Name = "Auto Fishing", Icon = "🎣"},
        {Name = "Settings", Icon = "⚙️"}
    }
    
    local currentTab = "Auto Fishing"
    
    local function createTabButton(tabName, index)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Size = UDim2.new(0.5, -5, 1, 0)
        tabBtn.Position = UDim2.new((index-1) * 0.5, 0, 0, 0)
        tabBtn.BackgroundColor3 = (tabName == currentTab) and UIConfig.AccentColor or UIConfig.SecondaryColor
        tabBtn.Text = tabName
        tabBtn.TextColor3 = UIConfig.TextColor
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 14
        tabBtn.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            currentTab = tabName
            -- Update semua tab button
            for _, child in ipairs(tabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child.Text == currentTab) and UIConfig.AccentColor or UIConfig.SecondaryColor
                end
            end
            
            -- Tampilkan konten tab yang dipilih
            updateTabContent()
        end)
        
        return tabBtn
    end
    
    local function createAutoFishingTab()
        -- Clear content
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        -- Header
        local header = Instance.new("TextLabel")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 40)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.BackgroundTransparency = 1
        header.Text = "🎣 Auto Fishing Settings"
        header.TextColor3 = UIConfig.TextColor
        header.Font = Enum.Font.GothamBold
        header.TextSize = 16
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = contentFrame
        
        -- Status Panel
        local statusPanel = Instance.new("Frame")
        statusPanel.Name = "StatusPanel"
        statusPanel.Size = UDim2.new(1, 0, 0, 80)
        statusPanel.Position = UDim2.new(0, 0, 0, 45)
        statusPanel.BackgroundColor3 = UIConfig.SecondaryColor
        statusPanel.Parent = contentFrame
        
        local panelCorner = Instance.new("UICorner")
        panelCorner.CornerRadius = UDim.new(0, 8)
        panelCorner.Parent = statusPanel
        
        -- Status Indicator
        local statusIndicator = Instance.new("Frame")
        statusIndicator.Name = "StatusIndicator"
        statusIndicator.Size = UDim2.new(0, 15, 0, 15)
        statusIndicator.Position = UDim2.new(0, 15, 0, 15)
        statusIndicator.BackgroundColor3 = UIConfig.ErrorColor
        statusIndicator.Parent = statusPanel
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = statusIndicator
        
        local statusText = Instance.new("TextLabel")
        statusText.Name = "StatusText"
        statusText.Size = UDim2.new(1, -40, 0, 20)
        statusText.Position = UDim2.new(0, 40, 0, 13)
        statusText.BackgroundTransparency = 1
        statusText.Text = "Auto Fishing: OFF"
        statusText.TextColor3 = UIConfig.TextColor
        statusText.Font = Enum.Font.GothamBold
        statusText.TextSize = 14
        statusText.TextXAlignment = Enum.TextXAlignment.Left
        statusText.Parent = statusPanel
        
        local infoText = Instance.new("TextLabel")
        infoText.Name = "InfoText"
        infoText.Size = UDim2.new(1, -20, 0, 30)
        infoText.Position = UDim2.new(0, 10, 0, 45)
        infoText.BackgroundTransparency = 1
        infoText.Text = "Automatically catch fish while AFK"
        infoText.TextColor3 = Color3.fromRGB(180, 180, 180)
        infoText.Font = Enum.Font.Gotham
        infoText.TextSize = 12
        infoText.TextXAlignment = Enum.TextXAlignment.Left
        infoText.Parent = statusPanel
        
        -- Control Buttons
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = "ButtonContainer"
        buttonContainer.Size = UDim2.new(1, 0, 0, 120)
        buttonContainer.Position = UDim2.new(0, 0, 0, 140)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = contentFrame
        
        -- Enable Button
        local enableBtn = Instance.new("TextButton")
        enableBtn.Name = "EnableButton"
        enableBtn.Size = UDim2.new(1, 0, 0, 50)
        enableBtn.Position = UDim2.new(0, 0, 0, 0)
        enableBtn.BackgroundColor3 = UIConfig.SuccessColor
        enableBtn.Text = "🔄 ENABLE AUTO FISHING"
        enableBtn.TextColor3 = UIConfig.TextColor
        enableBtn.Font = Enum.Font.GothamBold
        enableBtn.TextSize = 16
        enableBtn.Parent = buttonContainer
        
        local enableCorner = Instance.new("UICorner")
        enableCorner.CornerRadius = UDim.new(0, 8)
        enableCorner.Parent = enableBtn
        
        -- Disable Button
        local disableBtn = Instance.new("TextButton")
        disableBtn.Name = "DisableButton"
        disableBtn.Size = UDim2.new(1, 0, 0, 50)
        disableBtn.Position = UDim2.new(0, 0, 0, 65)
        disableBtn.BackgroundColor3 = UIConfig.ErrorColor
        disableBtn.Text = "⏹️ DISABLE AUTO FISHING"
        disableBtn.TextColor3 = UIConfig.TextColor
        disableBtn.Font = Enum.Font.GothamBold
        disableBtn.TextSize = 16
        disableBtn.Parent = buttonContainer
        
        local disableCorner = Instance.new("UICorner")
        disableCorner.CornerRadius = UDim.new(0, 8)
        disableCorner.Parent = disableBtn
        
        -- Function untuk update status
        local function updateStatus(isEnabled)
            if isEnabled then
                statusIndicator.BackgroundColor3 = UIConfig.SuccessColor
                statusText.Text = "Auto Fishing: ON"
                statusLabel.Text = "Auto Fishing is enabled"
            else
                statusIndicator.BackgroundColor3 = UIConfig.ErrorColor
                statusText.Text = "Auto Fishing: OFF"
                statusLabel.Text = "Auto Fishing is disabled"
            end
        end
        
        -- Button events
        enableBtn.MouseButton1Click:Connect(function()
            if AutoFishingModule and AutoFishingModule.enable then
                local success = AutoFishingModule.enable()
                updateStatus(success)
                if success then
                    statusLabel.Text = "Auto Fishing enabled successfully"
                else
                    statusLabel.Text = "Failed to enable Auto Fishing"
                end
            else
                statusLabel.Text = "Auto Fishing module not loaded"
            end
        end)
        
        disableBtn.MouseButton1Click:Connect(function()
            if AutoFishingModule and AutoFishingModule.disable then
                local success = AutoFishingModule.disable()
                updateStatus(not success)
                if success then
                    statusLabel.Text = "Auto Fishing disabled successfully"
                else
                    statusLabel.Text = "Failed to disable Auto Fishing"
                end
            else
                statusLabel.Text = "Auto Fishing module not loaded"
            end
        end)
        
        -- Load initial status
        updateStatus(false)
    end
    
    local function createSettingsTab()
        -- Clear content
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        -- Header
        local header = Instance.new("TextLabel")
        header.Name = "SettingsHeader"
        header.Size = UDim2.new(1, 0, 0, 40)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.BackgroundTransparency = 1
        header.Text = "⚙️ Settings"
        header.TextColor3 = UIConfig.TextColor
        header.Font = Enum.Font.GothamBold
        header.TextSize = 16
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = contentFrame
        
        -- Toggle UI Visibility
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "ToggleFrame"
        toggleFrame.Size = UDim2.new(1, 0, 0, 50)
        toggleFrame.Position = UDim2.new(0, 0, 0, 50)
        toggleFrame.BackgroundColor3 = UIConfig.SecondaryColor
        toggleFrame.Parent = contentFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggleFrame
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "ToggleLabel"
        toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        toggleLabel.Position = UDim2.new(0, 15, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = "UI Visibility"
        toggleLabel.TextColor3 = UIConfig.TextColor
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextSize = 14
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "ToggleButton"
        toggleBtn.Size = UDim2.new(0, 60, 0, 30)
        toggleBtn.Position = UDim2.new(1, -80, 0.5, -15)
        toggleBtn.BackgroundColor3 = UIConfig.SuccessColor
        toggleBtn.Text = "ON"
        toggleBtn.TextColor3 = UIConfig.TextColor
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 12
        toggleBtn.Parent = toggleFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = toggleBtn
        
        toggleBtn.MouseButton1Click:Connect(function()
            UIManager.IsVisible = not UIManager.IsVisible
            screenGui.Enabled = UIManager.IsVisible
            toggleBtn.Text = UIManager.IsVisible and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = UIManager.IsVisible and UIConfig.SuccessColor or UIConfig.ErrorColor
            statusLabel.Text = UIManager.IsVisible and "UI is visible" or "UI is hidden"
        end)
    end
    
    local function updateTabContent()
        if currentTab == "Auto Fishing" then
            createAutoFishingTab()
        elseif currentTab == "Settings" then
            createSettingsTab()
        end
    end
    
    -- Create tab buttons
    for i, tab in ipairs(tabs) do
        createTabButton(tab.Name, i)
    end
    
    -- Initialize with Auto Fishing tab
    updateTabContent()
    
    -- Make window draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Close button event
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        UIManager.ActiveWindows["Main"] = nil
        statusLabel.Text = "UI Closed - Re-execute script to reopen"
    end)
    
    -- Toggle UI dengan keybind (F9)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F9 then
            UIManager.IsVisible = not UIManager.IsVisible
            screenGui.Enabled = UIManager.IsVisible
            statusLabel.Text = UIManager.IsVisible and "UI toggled ON (F9)" or "UI toggled OFF (F9)"
        end
    end)
    
    UIManager.ActiveWindows["Main"] = screenGui
    return screenGui
end

-- Initialize UI
local function initialize()
    print("=== Fish It Hub UI Initializing ===")
    
    -- Load modules
    loadAutoFishing()
    
    -- Create main window
    wait(2)
    UIManager:CreateMainWindow()
    
    print("UI Initialized! Press F9 to toggle visibility")
end

-- Start UI
local success, err = pcall(initialize)
if not success then
    warn("[UI ERROR]:", err)
end

-- Export UIManager untuk akses eksternal
return UIManager