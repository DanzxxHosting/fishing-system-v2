-- NeonUi.lua - Modern Control Panel untuk Auto Fishing Modules
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Pilih modul yang ingin digunakan (sesuaikan dengan preferensi)
local MODULE_URL = "https://raw.githubusercontent.com/username/repo/main/BlatantV2.lua"  -- Ganti dengan URL modul Anda
local AutoFishingModule = loadstring(game:HttpGet(MODULE_URL))()

-- Warna tema Neon
local THEME_COLORS = {
    Primary = Color3.fromRGB(0, 255, 255),     -- Cyan
    Secondary = Color3.fromRGB(255, 0, 255),   -- Magenta
    Accent = Color3.fromRGB(255, 255, 0),      -- Yellow
    Background = Color3.fromRGB(10, 10, 20),
    Card = Color3.fromRGB(20, 20, 35),
    Text = Color3.fromRGB(240, 240, 255),
    Success = Color3.fromRGB(0, 255, 128),
    Warning = Color3.fromRGB(255, 100, 0),
    Danger = Color3.fromRGB(255, 50, 50)
}

-- Variabel global
local NeonUI = {}
NeonUI.Visible = true

----------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------

local function createGlowEffect(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "NeonGlow"
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8992231223"  -- Glow texture
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(100, 100, 100, 100)
    glow.Parent = parent
    
    -- Animasi glow pulse
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function(delta)
        glow.ImageTransparency = 0.65 + math.sin(tick() * 3) * 0.1
    end)
    
    return glow, pulseConnection
end

local function createNeonButton(name, text, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 180, 0, 45)
    button.BackgroundColor3 = color
    button.BackgroundTransparency = 0.1
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    
    -- UI Effects
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.7
    stroke.Parent = button
    
    -- Hover effects
    local originalColor = button.BackgroundColor3
    local originalSize = button.Size
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = originalSize + UDim2.new(0, 5, 0, 5)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = originalSize
        }):Play()
    end)
    
    -- Glow effect
    createGlowEffect(button, color)
    
    return button
end

----------------------------------------------------------------
-- MAIN UI CREATION
----------------------------------------------------------------

local function createMainUI()
    -- Destroy existing UI if any
    if playerGui:FindFirstChild("NeonFishingUI") then
        playerGui.NeonFishingUI:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeonFishingUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = THEME_COLORS.Background
    mainFrame.BackgroundTransparency = 0.05
    
    -- UI Effects for main frame
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = THEME_COLORS.Primary
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = THEME_COLORS.Card
    titleBar.BackgroundTransparency = 0.1
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ NEON FISHING CONTROL"
    title.TextColor3 = THEME_COLORS.Primary
    title.TextSize = 22
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeTransparency = 0.7
    title.TextStrokeColor3 = THEME_COLORS.Primary
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = THEME_COLORS.Danger
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    
    -- Drag functionality
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
            mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
    
    -- Status Display
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, -40, 0, 80)
    statusFrame.Position = UDim2.new(0, 20, 0, 60)
    statusFrame.BackgroundColor3 = THEME_COLORS.Card
    statusFrame.BackgroundTransparency = 0.1
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: IDLE"
    statusLabel.TextColor3 = THEME_COLORS.Warning
    statusLabel.TextSize = 18
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 40)
    statsLabel.Position = UDim2.new(0, 10, 0, 35)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Casts: 0 | Runtime: 0s | CPS: 0.0"
    statsLabel.TextColor3 = THEME_COLORS.Text
    statsLabel.TextSize = 14
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Control Buttons Container
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -40, 0, 100)
    buttonsFrame.Position = UDim2.new(0, 20, 0, 150)
    buttonsFrame.BackgroundTransparency = 1
    
    -- Create Control Buttons
    local startButton = createNeonButton("StartButton", "▶ START FISHING", THEME_COLORS.Success)
    startButton.Position = UDim2.new(0, 0, 0, 0)
    
    local stopButton = createNeonButton("StopButton", "⏹ STOP FISHING", THEME_COLORS.Danger)
    stopButton.Position = UDim2.new(0, 190, 0, 0)
    
    -- Settings Panel
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Size = UDim2.new(1, -40, 0, 200)
    settingsFrame.Position = UDim2.new(0, 20, 0, 260)
    settingsFrame.BackgroundColor3 = THEME_COLORS.Card
    settingsFrame.BackgroundTransparency = 0.1
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 10)
    settingsCorner.Parent = settingsFrame
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 30)
    settingsTitle.Position = UDim2.new(0, 15, 0, 5)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙️ ADVANCED SETTINGS"
    settingsTitle.TextColor3 = THEME_COLORS.Secondary
    settingsTitle.TextSize = 16
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Slider Creation Function
    local function createSlider(name, label, defaultValue, min, max, yPosition)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name .. "SliderFrame"
        sliderFrame.Size = UDim2.new(1, -30, 0, 50)
        sliderFrame.Position = UDim2.new(0, 15, 0, yPosition)
        sliderFrame.BackgroundTransparency = 1
        
        local labelText = Instance.new("TextLabel")
        labelText.Name = name .. "Label"
        labelText.Size = UDim2.new(1, 0, 0, 20)
        labelText.BackgroundTransparency = 1
        labelText.Text = label .. ": " .. defaultValue
        labelText.TextColor3 = THEME_COLORS.Text
        labelText.TextSize = 14
        labelText.Font = Enum.Font.Gotham
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        
        local slider = Instance.new("Frame")
        slider.Name = name .. "Slider"
        slider.Size = UDim2.new(1, 0, 0, 8)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(1, 0)
        sliderCorner.Parent = slider
        
        local fill = Instance.new("Frame")
        fill.Name = name .. "Fill"
        fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = THEME_COLORS.Primary
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        
        local handle = Instance.new("TextButton")
        handle.Name = name .. "Handle"
        handle.Size = UDim2.new(0, 20, 0, 20)
        handle.Position = UDim2.new((defaultValue - min) / (max - min), -10, 0.5, -10)
        handle.BackgroundColor3 = THEME_COLORS.Accent
        handle.Text = ""
        handle.AutoButtonColor = false
        
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(1, 0)
        handleCorner.Parent = handle
        
        -- Slider logic
        local dragging = false
        
        local function updateSlider(value)
            local percent = math.clamp((value - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            handle.Position = UDim2.new(percent, -10, 0.5, -10)
            labelText.Text = label .. ": " .. string.format("%.3f", value)
            
            return value
        end
        
        handle.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                local value = min + (max - min) * math.clamp(percent, 0, 1)
                updateSlider(value)
                
                -- Update module settings
                if name == "CompleteDelay" then
                    AutoFishingModule.UpdateSettings(value, nil)
                elseif name == "CancelDelay" then
                    AutoFishingModule.UpdateSettings(nil, value)
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                local value = min + (max - min) * math.clamp(percent, 0, 1)
                value = updateSlider(value)
                
                -- Update module settings
                if name == "CompleteDelay" then
                    AutoFishingModule.UpdateSettings(value, nil)
                elseif name == "CancelDelay" then
                    AutoFishingModule.UpdateSettings(nil, value)
                end
            end
        end)
        
        -- Assembly
        fill.Parent = slider
        handle.Parent = slider
        labelText.Parent = sliderFrame
        slider.Parent = sliderFrame
        
        return sliderFrame
    end
    
    -- Create sliders
    local completeSlider = createSlider("CompleteDelay", "Complete Delay", 0.73, 0.1, 2.0, 35)
    local cancelSlider = createSlider("CancelDelay", "Cancel Delay", 0.3, 0.1, 1.0, 90)
    local recastSlider = createSlider("ReCastDelay", "Re-Cast Delay", 0.001, 0.001, 0.5, 145)
    
    -- Module Selector
    local moduleFrame = Instance.new("Frame")
    moduleFrame.Name = "ModuleFrame"
    moduleFrame.Size = UDim2.new(1, -40, 0, 40)
    moduleFrame.Position = UDim2.new(0, 20, 0, 470)
    moduleFrame.BackgroundTransparency = 1
    
    local moduleLabel = Instance.new("TextLabel")
    moduleLabel.Name = "ModuleLabel"
    moduleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    moduleLabel.BackgroundTransparency = 1
    moduleLabel.Text = "Module: BlatantV2"
    moduleLabel.TextColor3 = THEME_COLORS.Text
    moduleLabel.TextSize = 14
    moduleLabel.Font = Enum.Font.Gotham
    moduleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local moduleButton = createNeonButton("ModuleButton", "SWITCH MODULE", THEME_COLORS.Secondary)
    moduleButton.Size = UDim2.new(0, 150, 0, 35)
    moduleButton.Position = UDim2.new(0.5, 10, 0, 0)
    moduleButton.TextSize = 14
    
    -- Assembly Hierarchy
    moduleLabel.Parent = moduleFrame
    moduleButton.Parent = moduleFrame
    
    recastSlider.Parent = settingsFrame
    cancelSlider.Parent = settingsFrame
    completeSlider.Parent = settingsFrame
    
    startButton.Parent = buttonsFrame
    stopButton.Parent = buttonsFrame
    
    closeButton.Parent = titleBar
    title.Parent = titleBar
    statusLabel.Parent = statusFrame
    statsLabel.Parent = statusFrame
    
    titleBar.Parent = mainFrame
    statusFrame.Parent = mainFrame
    buttonsFrame.Parent = mainFrame
    settingsFrame.Parent = mainFrame
    moduleFrame.Parent = mainFrame
    
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui
    
    -- Add glow to main frame
    createGlowEffect(mainFrame, THEME_COLORS.Primary)
    
    -----------------------------------------------------------------
    -- UI FUNCTIONALITY
    -----------------------------------------------------------------
    
    -- Update stats in real-time
    local statsUpdateConnection
    statsUpdateConnection = RunService.Heartbeat:Connect(function()
        if AutoFishingModule.GetStats then
            local stats = AutoFishingModule.GetStats()
            
            -- Update status
            if stats.isActive then
                statusLabel.Text = "STATUS: ACTIVE 🔥"
                statusLabel.TextColor3 = THEME_COLORS.Success
            else
                statusLabel.Text = "STATUS: IDLE 💤"
                statusLabel.TextColor3 = THEME_COLORS.Warning
            end
            
            -- Update stats
            statsLabel.Text = string.format("Casts: %d | Runtime: %ds | CPS: %.1f | Cycle: %s",
                stats.castCount,
                stats.runtime,
                stats.cps,
                stats.isInCycle and "ACTIVE" or "WAITING")
        end
    end)
    
    -- Button Functionality
    startButton.MouseButton1Click:Connect(function()
        local success = AutoFishingModule.Start()
        if success then
            -- Visual feedback
            TweenService:Create(startButton, TweenInfo.new(0.2), {
                BackgroundColor3 = THEME_COLORS.Success,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        local success = AutoFishingModule.Stop()
        if success then
            -- Visual feedback
            TweenService:Create(stopButton, TweenInfo.new(0.2), {
                BackgroundColor3 = THEME_COLORS.Danger,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        -- Fade out animation
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Position = mainFrame.Position + UDim2.new(0, 0, -0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.3)
        screenGui:Destroy()
        if statsUpdateConnection then
            statsUpdateConnection:Disconnect()
        end
        NeonUI.Visible = false
    end)
    
    -- Module switcher functionality
    local currentModule = 1
    local modules = {
        {name = "BlatantV1", url = "URL_BLATANTV1"},
        {name = "BlatantV2", url = "URL_BLATANTV2"},
        {name = "BlatantFixedV1", url = "URL_FIXEDV1"}
    }
    
    moduleButton.MouseButton1Click:Connect(function()
        currentModule = (currentModule % #modules) + 1
        local newModule = modules[currentModule]
        
        moduleLabel.Text = "Module: " .. newModule.name
        
        -- Reload module
        AutoFishingModule.Stop()
        task.wait(0.1)
        AutoFishingModule = loadstring(game:HttpGet(newModule.url))()
        
        -- Visual feedback
        TweenService:Create(moduleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME_COLORS.Accent
        }):Play()
        
        task.wait(0.2)
        TweenService:Create(moduleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME_COLORS.Secondary
        }):Play()
    end)
    
    -- Toggle UI visibility with keybind (F5)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F5 then
            NeonUI.Visible = not NeonUI.Visible
            mainFrame.Visible = NeonUI.Visible
            
            if NeonUI.Visible then
                -- Fade in
                mainFrame.BackgroundTransparency = 1
                mainFrame.Position = mainFrame.Position + UDim2.new(0, 0, -0.2, 0)
                TweenService:Create(mainFrame, TweenInfo.new(0.3), {
                    Position = UDim2.new(0.5, -200, 0.5, -250),
                    BackgroundTransparency = 0.05
                }):Play()
            end
        end
    end)
    
    return {
        GUI = screenGui,
        UpdateStatus = function(text, color)
            statusLabel.Text = text
            statusLabel.TextColor3 = color or THEME_COLORS.Text
        end
    }
end

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

-- Create and display the UI
local ui = createMainUI()

print("✅ Neon Fishing UI loaded successfully!")
print("📌 Press F5 to toggle visibility")
print("🎣 Module: BlatantV2 loaded")

return NeonUI