-- UI.lua
-- File UI utama

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Get local player
local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

-- Theme Configuration
local Theme = {
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(0, 200, 100),
    Error = Color3.fromRGB(220, 60, 60),
    Warning = Color3.fromRGB(255, 165, 0),
    Border = Color3.fromRGB(60, 60, 70)
}

-- UI Manager
local UIManager = {
    Windows = {},
    IsVisible = true,
    CurrentTheme = Theme
}

-- Utility Functions
local function createRoundedFrame(name, size, position)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size or UDim2.new(0, 100, 0, 100)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Theme.Primary
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return frame
end

local function createTextLabel(text, size, position)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size or UDim2.new(0, 100, 0, 30)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    return label
end

local function createButton(text, size, position)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = size or UDim2.new(0, 120, 0, 35)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Theme.Accent
    button.TextColor3 = Theme.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

-- Main Window Creation
function UIManager:CreateMainWindow()
    -- Remove old UI if exists
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("FishItHub_Main")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishItHub_Main"
    screenGui.DisplayOrder = 999
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main Container
    local mainContainer = createRoundedFrame("MainContainer", 
        UDim2.new(0, 350, 0, 400),
        UDim2.new(0.5, -175, 0.5, -200))
    mainContainer.Parent = screenGui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainContainer
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleText = createTextLabel("🎣 Fish It Hub", 
        UDim2.new(0.7, 0, 1, 0),
        UDim2.new(0, 15, 0, 0))
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeBtn = createButton("X", 
        UDim2.new(0, 30, 0, 30),
        UDim2.new(1, -35, 0.5, -15))
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.Parent = titleBar
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 35)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainContainer
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -130)
    contentArea.Position = UDim2.new(0, 10, 0, 95)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainContainer
    
    -- Status Bar
    local statusBar = createRoundedFrame("StatusBar",
        UDim2.new(1, -20, 0, 25),
        UDim2.new(0, 10, 1, -30))
    statusBar.BackgroundColor3 = Theme.Secondary
    statusBar.Parent = mainContainer
    
    local statusText = createTextLabel("Ready",
        UDim2.new(1, -10, 1, 0),
        UDim2.new(0, 5, 0, 0))
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 12
    statusText.Parent = statusBar
    
    -- Create Tabs
    local tabs = {"Auto Fishing", "Settings"}
    local currentTab = "Auto Fishing"
    
    local function createTabButton(tabName, index)
        local tabBtn = createButton(tabName,
            UDim2.new(0.5, -5, 1, 0),
            UDim2.new((index-1) * 0.5, 0, 0, 0))
        tabBtn.BackgroundColor3 = (tabName == currentTab) and Theme.Accent or Theme.Secondary
        tabBtn.Parent = tabContainer
        
        tabBtn.MouseButton1Click:Connect(function()
            currentTab = tabName
            -- Update all tab buttons
            for _, child in ipairs(tabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child.Text == currentTab) and Theme.Accent or Theme.Secondary
                end
            end
            -- Update content
            loadTabContent(tabName)
        end)
        
        return tabBtn
    end
    
    local function loadTabContent(tabName)
        -- Clear content area
        for _, child in ipairs(contentArea:GetChildren()) do
            child:Destroy()
        end
        
        if tabName == "Auto Fishing" then
            loadAutoFishingTab(contentArea, statusText)
        elseif tabName == "Settings" then
            loadSettingsTab(contentArea, statusText)
        end
    end
    
    local function loadAutoFishingTab(parent, statusLabel)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        -- Status Display
        local statusDisplay = createRoundedFrame("StatusDisplay",
            UDim2.new(1, 0, 0, 80),
            UDim2.new(0, 0, 0, 0))
        statusDisplay.BackgroundColor3 = Theme.Secondary
        statusDisplay.Parent = container
        
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 15, 0, 15)
        indicator.Position = UDim2.new(0, 15, 0, 15)
        indicator.BackgroundColor3 = Theme.Error
        indicator.Parent = statusDisplay
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator
        
        local statusLabel = createTextLabel("Auto Fishing: OFF",
            UDim2.new(1, -40, 0, 20),
            UDim2.new(0, 40, 0, 13))
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = statusDisplay
        
        -- Control Buttons
        local enableBtn = createButton("🔄 ENABLE",
            UDim2.new(1, 0, 0, 45),
            UDim2.new(0, 0, 0, 100))
        enableBtn.BackgroundColor3 = Theme.Success
        enableBtn.Parent = container
        
        local disableBtn = createButton("⏹️ DISABLE",
            UDim2.new(1, 0, 0, 45),
            UDim2.new(0, 0, 0, 155))
        disableBtn.BackgroundColor3 = Theme.Error
        disableBtn.Parent = container
        
        -- Button Functions
        local function updateStatus(isEnabled)
            if isEnabled then
                indicator.BackgroundColor3 = Theme.Success
                statusLabel.Text = "Auto Fishing: ON"
            else
                indicator.BackgroundColor3 = Theme.Error
                statusLabel.Text = "Auto Fishing: OFF"
            end
        end
        
        enableBtn.MouseButton1Click:Connect(function()
            -- Load and use auto fishing module
            local success, module = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/username/FishItHub/main/Fitur/autofishing.lua"))()
            end)
            
            if success and module then
                local enabled = module.enable()
                updateStatus(enabled)
                statusLabel.Text = enabled and "Auto fishing enabled!" or "Failed to enable"
            else
                statusLabel.Text = "Module load failed"
            end
        end)
        
        disableBtn.MouseButton1Click:Connect(function()
            local success, module = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/username/FishItHub/main/Fitur/autofishing.lua"))()
            end)
            
            if success and module then
                local disabled = module.disable()
                updateStatus(not disabled)
                statusLabel.Text = disabled and "Auto fishing disabled!" or "Failed to disable"
            else
                statusLabel.Text = "Module load failed"
            end
        end)
        
        updateStatus(false)
    end
    
    local function loadSettingsTab(parent, statusLabel)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local uiToggle = createButton("Toggle UI (F9)",
            UDim2.new(1, 0, 0, 45),
            UDim2.new(0, 0, 0, 20))
        uiToggle.Parent = container
        
        uiToggle.MouseButton1Click:Connect(function()
            screenGui.Enabled = not screenGui.Enabled
            statusLabel.Text = screenGui.Enabled and "UI toggled ON" or "UI toggled OFF"
        end)
    end
    
    -- Create tab buttons
    for i, tab in ipairs(tabs) do
        createTabButton(tab, i)
    end
    
    -- Load initial tab
    loadTabContent(currentTab)
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainContainer.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- F9 toggle
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F9 then
            screenGui.Enabled = not screenGui.Enabled
            statusText.Text = screenGui.Enabled and "UI toggled ON (F9)" or "UI toggled OFF (F9)"
        end
    end)
    
    UIManager.Windows["Main"] = screenGui
    return screenGui
end

-- Initialize UI
local function init()
    print("[UI] Initializing Fish It Hub UI...")
    wait(1)
    
    local success, err = pcall(function()
        return UIManager:CreateMainWindow()
    end)
    
    if success then
        print("[UI] ✅ UI loaded successfully!")
    else
        warn("[UI] ❌ Failed to load UI:", err)
    end
end

-- Start initialization
spawn(init)

return UIManager