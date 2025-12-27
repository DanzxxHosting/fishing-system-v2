-- UI.lua
-- Simple UI untuk Fish It

-- Tunggu game selesai load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Tunggu player
local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItHub"
screenGui.DisplayOrder = 999
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 300, 0, 350)
mainWindow.Position = UDim2.new(0.5, -150, 0.5, -175)
mainWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainWindow.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainWindow

mainWindow.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10, 0, 0)
titleCorner.Parent = titleBar

titleBar.Parent = mainWindow

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🎣 Fish It Hub"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = true

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

closeBtn.Parent = titleBar

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainWindow

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -20, 1, -120)
contentArea.Position = UDim2.new(0, 10, 0, 85)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainWindow

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, -20, 0, 25)
statusBar.Position = UDim2.new(0, 10, 1, -30)
statusBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
statusBar.BorderSizePixel = 0

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 5)
statusCorner.Parent = statusBar

statusBar.Parent = mainWindow

-- Status Text
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 1, 0)
statusText.Position = UDim2.new(0, 5, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Ready"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusBar

-- Buat Tab Buttons
local tabs = {"Auto Fishing", "Settings"}
local currentTab = "Auto Fishing"

for i, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.5, -5, 1, 0)
    tabBtn.Position = UDim2.new((i-1) * 0.5, 0, 0, 0)
    
    if tabName == currentTab then
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
    
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 13
    tabBtn.AutoButtonColor = false
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 5)
    tabCorner.Parent = tabBtn
    
    tabBtn.Parent = tabContainer
    
    -- Tab Click Handler
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = tabName
        
        -- Update semua tab button warna
        for _, child in ipairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                if child.Text == currentTab then
                    child.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                else
                    child.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end
            end
        end
        
        -- Update content
        updateTabContent()
    end)
end

-- Fungsi untuk load Auto Fishing Tab
local function loadAutoFishingTab()
    -- Clear content dulu
    for _, child in ipairs(contentArea:GetChildren()) do
        child:Destroy()
    end
    
    -- Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = contentArea
    
    -- Status Panel
    local statusPanel = Instance.new("Frame")
    statusPanel.Size = UDim2.new(1, 0, 0, 70)
    statusPanel.Position = UDim2.new(0, 0, 0, 0)
    statusPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    statusPanel.BorderSizePixel = 0
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 8)
    panelCorner.Parent = statusPanel
    
    statusPanel.Parent = container
    
    -- Status Indicator
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.new(0, 15, 0, 15)
    statusIndicator.Position = UDim2.new(0, 10, 0, 10)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = statusIndicator
    
    statusIndicator.Parent = statusPanel
    
    -- Status Text
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -30, 0, 20)
    statusLabel.Position = UDim2.new(0, 30, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Auto Fishing: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusPanel
    
    -- Info Text
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 30)
    infoText.Position = UDim2.new(0, 10, 0, 35)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Automatically catch fish while AFK"
    infoText.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 12
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Parent = statusPanel
    
    -- Button Container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 110)
    buttonContainer.Position = UDim2.new(0, 0, 0, 80)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = container
    
    -- Enable Button
    local enableBtn = Instance.new("TextButton")
    enableBtn.Size = UDim2.new(1, 0, 0, 45)
    enableBtn.Position = UDim2.new(0, 0, 0, 0)
    enableBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    enableBtn.Text = "🔄 ENABLE AUTO FISHING"
    enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 14
    enableBtn.AutoButtonColor = true
    
    local enableCorner = Instance.new("UICorner")
    enableCorner.CornerRadius = UDim.new(0, 6)
    enableCorner.Parent = enableBtn
    
    enableBtn.Parent = buttonContainer
    
    -- Disable Button
    local disableBtn = Instance.new("TextButton")
    disableBtn.Size = UDim2.new(1, 0, 0, 45)
    disableBtn.Position = UDim2.new(0, 0, 0, 55)
    disableBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    disableBtn.Text = "⏹️ DISABLE AUTO FISHING"
    disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    disableBtn.Font = Enum.Font.GothamBold
    disableBtn.TextSize = 14
    disableBtn.AutoButtonColor = true
    
    local disableCorner = Instance.new("UICorner")
    disableCorner.CornerRadius = UDim.new(0, 6)
    disableCorner.Parent = disableBtn
    
    disableBtn.Parent = buttonContainer
    
    -- Fungsi update status
    local function updateStatus(isEnabled)
        if isEnabled then
            statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            statusLabel.Text = "Auto Fishing: ON"
            statusLabel.TextColor3 = Color3.fromRGB(0, 180, 0)
        else
            statusIndicator.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            statusLabel.Text = "Auto Fishing: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(220, 60, 60)
        end
    end
    
    -- Button Click Handlers
    enableBtn.MouseButton1Click:Connect(function()
        -- Panggil fitur auto fishing
        local success = pcall(function()
            local args = {true}
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
                :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net"):WaitForChild("RF/UpdateAutoFishingState")
            
            remote:InvokeServer(unpack(args))
            return true
        end)
        
        if success then
            updateStatus(true)
            statusText.Text = "Auto fishing enabled!"
        else
            statusText.Text = "Failed to enable auto fishing"
        end
    end)
    
    disableBtn.MouseButton1Click:Connect(function()
        -- Panggil fitur auto fishing
        local success = pcall(function()
            local args = {false}
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
                :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net"):WaitForChild("RF/UpdateAutoFishingState")
            
            remote:InvokeServer(unpack(args))
            return true
        end)
        
        if success then
            updateStatus(false)
            statusText.Text = "Auto fishing disabled!"
        else
            statusText.Text = "Failed to disable auto fishing"
        end
    end)
    
    -- Set initial status
    updateStatus(false)
end

-- Fungsi untuk load Settings Tab
local function loadSettingsTab()
    -- Clear content dulu
    for _, child in ipairs(contentArea:GetChildren()) do
        child:Destroy()
    end
    
    -- Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = contentArea
    
    -- Toggle UI Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 45)
    toggleBtn.Position = UDim2.new(0, 0, 0, 20)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    toggleBtn.Text = "Toggle UI Visibility (F9)"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.AutoButtonColor = true
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn
    
    toggleBtn.Parent = container
    
    -- Keybind Info
    local keybindInfo = Instance.new("TextLabel")
    keybindInfo.Size = UDim2.new(1, 0, 0, 30)
    keybindInfo.Position = UDim2.new(0, 0, 0, 75)
    keybindInfo.BackgroundTransparency = 1
    keybindInfo.Text = "Press F9 to toggle UI"
    keybindInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
    keybindInfo.Font = Enum.Font.Gotham
    keybindInfo.TextSize = 12
    keybindInfo.Parent = container
    
    -- Version Info
    local versionInfo = Instance.new("TextLabel")
    versionInfo.Size = UDim2.new(1, 0, 0, 20)
    versionInfo.Position = UDim2.new(0, 0, 1, -25)
    versionInfo.BackgroundTransparency = 1
    versionInfo.Text = "Fish It Hub v1.0"
    versionInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    versionInfo.Font = Enum.Font.Gotham
    versionInfo.TextSize = 11
    versionInfo.Parent = container
    
    -- Toggle Button Handler
    toggleBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            statusText.Text = "UI is visible"
        else
            statusText.Text = "UI is hidden"
        end
    end)
end

-- Fungsi update tab content
local function updateTabContent()
    if currentTab == "Auto Fishing" then
        loadAutoFishingTab()
    elseif currentTab == "Settings" then
        loadSettingsTab()
    end
end

-- Initial load
updateTabContent()

-- Draggable Window
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainWindow.Position
        
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
        mainWindow.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close Button Handler
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- F9 Keybind untuk toggle UI
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F9 then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            statusText.Text = "UI toggled ON (F9)"
        else
            statusText.Text = "UI toggled OFF (F9)"
        end
    end
end)

print("🎣 Fish It Hub UI Loaded!")
print("📌 Press F9 to toggle UI")
print("🎯 Use tabs to navigate")

return {
    Toggle = function()
        screenGui.Enabled = not screenGui.Enabled
    end,
    
    Destroy = function()
        screenGui:Destroy()
    end
}