-- Neon Fishing UI v2 - Premium Control Panel
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Load auto fishing module (sesuaikan URL)
local MODULE_URL = "https://raw.githubusercontent.com/DanzxxHosting/fishing-system-v2/refs/heads/main/Main/BlatantV1.lua"  

local AutoFishingModule = loadstring(game:HttpGet(MODULE_URL))()

-- Enhanced Neon Theme with gradient support
local THEME = {
    -- Main colors with gradient variants
    Primary = {
        Main = Color3.fromRGB(0, 255, 255),
        Light = Color3.fromRGB(100, 255, 255),
        Dark = Color3.fromRGB(0, 200, 200)
    },
    Secondary = {
        Main = Color3.fromRGB(255, 0, 255),
        Light = Color3.fromRGB(255, 100, 255),
        Dark = Color3.fromRGB(200, 0, 200)
    },
    Accent = {
        Main = Color3.fromRGB(255, 255, 0),
        Light = Color3.fromRGB(255, 255, 100),
        Dark = Color3.fromRGB(200, 200, 0)
    },
    Background = {
        Main = Color3.fromRGB(5, 5, 15),
        Card = Color3.fromRGB(15, 15, 30),
        Light = Color3.fromRGB(25, 25, 45)
    },
    Status = {
        Success = Color3.fromRGB(0, 255, 128),
        Warning = Color3.fromRGB(255, 180, 0),
        Danger = Color3.fromRGB(255, 50, 100),
        Info = Color3.fromRGB(100, 150, 255)
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(200, 200, 220),
        Disabled = Color3.fromRGB(150, 150, 170)
    }
}

-- Global UI variables
local NeonUI = {
    Visible = true,
    Draggable = false,
    CurrentPosition = UDim2.new(0.5, -200, 0.5, -250)
}

----------------------------------------------------------------
-- PREMIUM VISUAL EFFECTS
----------------------------------------------------------------

local function createGlassEffect(frame)
    -- Glass morphic background
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = THEME.Background.Card
    
    -- Glass blur effect (simulated)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0.9),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    gradient.Rotation = 45
    gradient.Parent = frame
    
    -- Border with gradient
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(255, 255, 255)
    border.Thickness = 2
    border.Transparency = 0.7
    border.Parent = frame
    
    return gradient, border
end

local function createNeonGlow(parent, color, intensity)
    -- Main glow
    local outerGlow = Instance.new("ImageLabel")
    outerGlow.Name = "OuterGlow"
    outerGlow.Size = UDim2.new(1, 40, 1, 40)
    outerGlow.Position = UDim2.new(0, -20, 0, -20)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image = "rbxassetid://8992231223"
    outerGlow.ImageColor3 = color
    outerGlow.ImageTransparency = 0.8
    outerGlow.ScaleType = Enum.ScaleType.Slice
    outerGlow.SliceCenter = Rect.new(100, 100, 100, 100)
    outerGlow.ZIndex = -1
    outerGlow.Parent = parent
    
    -- Inner glow
    local innerGlow = outerGlow:Clone()
    innerGlow.Name = "InnerGlow"
    innerGlow.Size = UDim2.new(1, 20, 1, 20)
    innerGlow.Position = UDim2.new(0, -10, 0, -10)
    innerGlow.ImageTransparency = 0.6
    innerGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    innerGlow.ZIndex = -1
    innerGlow.Parent = parent
    
    -- Pulsing animation
    coroutine.wrap(function()
        while parent and parent.Parent do
            local time = tick()
            local pulse = math.sin(time * 2) * 0.1 + 0.9
            outerGlow.ImageTransparency = 0.9 - (pulse * 0.2)
            innerGlow.ImageTransparency = 0.7 - (pulse * 0.1)
            RunService.Heartbeat:Wait()
        end
    end)()
    
    return {outerGlow, innerGlow}
end

local function createPremiumButton(name, text, color, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 200, 0, 50)
    button.BackgroundColor3 = color.Main
    button.BackgroundTransparency = 0.2
    button.Text = icon and (icon .. "  " .. text) or text
    button.TextColor3 = THEME.Text.Primary
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Premium corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color.Light),
        ColorSequenceKeypoint.new(0.5, color.Main),
        ColorSequenceKeypoint.new(1, color.Dark)
    })
    gradient.Rotation = 90
    gradient.Parent = button
    
    -- Neon border
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    -- Icon frame (jika ada icon)
    if icon then
        local iconFrame = Instance.new("Frame")
        iconFrame.Name = "IconFrame"
        iconFrame.Size = UDim2.new(0, 40, 1, -10)
        iconFrame.Position = UDim2.new(0, 5, 0.5, 0)
        iconFrame.AnchorPoint = Vector2.new(0, 0.5)
        iconFrame.BackgroundTransparency = 1
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = THEME.Text.Primary
        iconLabel.TextSize = 24
        iconLabel.Font = Enum.Font.GothamBlack
        iconLabel.Parent = iconFrame
        
        iconFrame.Parent = button
        button.PaddingLeft = UDim.new(0, 50)
    end
    
    -- Hover effects
    local hoverTween
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 210, 0, 52)
        })
        hoverTween:Play()
        
        TweenService:Create(stroke, TweenInfo.new(0.3), {
            Transparency = 0.2,
            Thickness = 3
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, 200, 0, 50)
        })
        hoverTween:Play()
        
        TweenService:Create(stroke, TweenInfo.new(0.3), {
            Transparency = 0.5,
            Thickness = 2
        }):Play()
    end)
    
    -- Click effect
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0,
            Position = button.Position + UDim2.new(0, 0, 0, 2)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.2,
            Position = button.Position - UDim2.new(0, 0, 0, 2)
        }):Play()
    end)
    
    -- Add glow
    createNeonGlow(button, color.Main, 0.5)
    
    return button
end

local function createAnimatedSlider(name, label, defaultValue, min, max, yPos, color)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = name .. "Container"
    sliderContainer.Size = UDim2.new(1, -30, 0, 70)
    sliderContainer.Position = UDim2.new(0, 15, 0, yPos)
    sliderContainer.BackgroundTransparency = 1
    
    -- Label with value
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "LabelFrame"
    labelFrame.Size = UDim2.new(1, 0, 0, 30)
    labelFrame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = THEME.Text.Primary
    labelText.TextSize = 16
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueText = Instance.new("TextLabel")
    valueText.Name = "Value"
    valueText.Size = UDim2.new(0.3, 0, 1, 0)
    valueText.Position = UDim2.new(0.7, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = string.format("%.3fs", defaultValue)
    valueText.TextColor3 = color.Main
    valueText.TextSize = 16
    valueText.Font = Enum.Font.GothamBold
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 35)
    track.BackgroundColor3 = THEME.Background.Light
    track.BackgroundTransparency = 0.3
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Slider fill with gradient
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = color.Main
    
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color.Light),
        ColorSequenceKeypoint.new(1, color.Main)
    })
    fillGradient.Parent = fill
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Slider handle
    local handle = Instance.new("TextButton")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 24, 0, 24)
    handle.Position = UDim2.new((defaultValue - min) / (max - min), -12, 0.5, -12)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Text = ""
    handle.AutoButtonColor = false
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local handleGlow = Instance.new("ImageLabel")
    handleGlow.Name = "HandleGlow"
    handleGlow.Size = UDim2.new(1, 10, 1, 10)
    handleGlow.Position = UDim2.new(0, -5, 0, -5)
    handleGlow.BackgroundTransparency = 1
    handleGlow.Image = "rbxassetid://8992231223"
    handleGlow.ImageColor3 = color.Main
    handleGlow.ImageTransparency = 0.7
    handleGlow.ZIndex = -1
    
    -- Slider logic
    local dragging = false
    local currentValue = defaultValue
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = value
        
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        handle.Position = UDim2.new(percent, -12, 0.5, -12)
        valueText.Text = string.format("%.3fs", value)
        
        -- Animate fill color based on value
        local hue = (percent * 120) / 360  -- 0° (red) to 120° (green)
        local rgb = Color3.fromHSV(hue, 0.8, 1)
        fill.BackgroundColor3 = rgb
        
        return value
    end
    
    -- Input handling
    handle.MouseButton1Down:Connect(function()
        dragging = true
        TweenService:Create(handle, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 28, 0, 28),
            Position = handle.Position - UDim2.new(0, 2, 0, 2)
        }):Play()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false
                TweenService:Create(handle, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = handle.Position + UDim2.new(0, 2, 0, 2)
                }):Play()
            end
        end
    end)
    
    local function handleDrag(input)
        if dragging then
            local percent = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            local value = min + (max - min) * math.clamp(percent, 0, 1)
            value = updateSlider(value)
            
            -- Update module settings in real-time
            if name == "CompleteDelay" then
                AutoFishingModule.UpdateSettings(value, nil)
            elseif name == "CancelDelay" then
                AutoFishingModule.UpdateSettings(nil, value)
            end
        end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local percent = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            handleDrag(input)
        end
    end)
    
    -- Assembly
    handleGlow.Parent = handle
    handle.Parent = track
    fill.Parent = track
    labelText.Parent = labelFrame
    valueText.Parent = labelFrame
    labelFrame.Parent = sliderContainer
    track.Parent = sliderContainer
    
    return sliderContainer
end

----------------------------------------------------------------
-- MAIN UI CREATION - PREMIUM VERSION
----------------------------------------------------------------

local function createPremiumUI()
    -- Cleanup existing UI
    if playerGui:FindFirstChild("PremiumFishingUI") then
        playerGui.PremiumFishingUI:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PremiumFishingUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    -- Background dimmer
    local dimmer = Instance.new("Frame")
    dimmer.Name = "BackgroundDimmer"
    dimmer.Size = UDim2.new(1, 0, 1, 0)
    dimmer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dimmer.BackgroundTransparency = 0.7
    dimmer.ZIndex = 0
    
    -- Main container with centered position
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, 450, 0, 600)
    mainContainer.Position = NeonUI.CurrentPosition
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.BackgroundTransparency = 1
    mainContainer.ZIndex = 10
    
    -- Glass effect panel
    local glassPanel = Instance.new("Frame")
    glassPanel.Name = "GlassPanel"
    glassPanel.Size = UDim2.new(1, 0, 1, 0)
    glassPanel.BackgroundColor3 = THEME.Background.Main
    glassPanel.BackgroundTransparency = 0.2
    
    local glassCorner = Instance.new("UICorner")
    glassCorner.CornerRadius = UDim.new(0, 20)
    glassCorner.Parent = glassPanel
    
    createGlassEffect(glassPanel)
    createNeonGlow(glassPanel, THEME.Primary.Main, 0.3)
    
    -- Header with gradient
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -40, 0, 80)
    header.Position = UDim2.new(0, 20, 0, 20)
    header.BackgroundTransparency = 0.3
    header.BackgroundColor3 = THEME.Background.Card
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.Primary.Dark),
        ColorSequenceKeypoint.new(0.5, THEME.Primary.Main),
        ColorSequenceKeypoint.new(1, THEME.Secondary.Main)
    })
    headerGradient.Rotation = 90
    headerGradient.Parent = header
    
    -- Title with icon
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.Size = UDim2.new(1, 0, 1, 0)
    titleContainer.BackgroundTransparency = 1
    
    local titleIcon = Instance.new("TextLabel")
    titleIcon.Name = "TitleIcon"
    titleIcon.Size = UDim2.new(0, 60, 1, 0)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "🎣"
    titleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleIcon.TextSize = 40
    titleIcon.Font = Enum.Font.GothamBlack
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -70, 0.5, 0)
    titleText.Position = UDim2.new(0, 70, 0, 10)
    titleText.BackgroundTransparency = 1
    titleText.Text = "NEON FISHING PRO"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 28
    titleText.Font = Enum.Font.GothamBlack
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -70, 0.5, 0)
    subtitle.Position = UDim2.new(0, 70, 0, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Premium Auto-Fishing Control Panel"
    subtitle.TextColor3 = THEME.Text.Secondary
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button (premium style)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 36, 0, 36)
    closeButton.Position = UDim2.new(1, -40, 0, 20)
    closeButton.BackgroundColor3 = THEME.Status.Danger
    closeButton.BackgroundTransparency = 0.3
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.AutoButtonColor = false
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    -- Status display (enhanced)
    local statusPanel = Instance.new("Frame")
    statusPanel.Name = "StatusPanel"
    statusPanel.Size = UDim2.new(1, -40, 0, 120)
    statusPanel.Position = UDim2.new(0, 20, 0, 110)
    statusPanel.BackgroundTransparency = 0.2
    statusPanel.BackgroundColor3 = THEME.Background.Card
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 15)
    statusCorner.Parent = statusPanel
    
    -- Live stats with icons
    local statsGrid = Instance.new("UIGridLayout")
    statsGrid.Name = "StatsGrid"
    statsGrid.CellSize = UDim2.new(0.5, -10, 0.5, -10)
    statsGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    statsGrid.StartCorner = Enum.StartCorner.TopLeft
    statsGrid.Parent = statusPanel
    
    local function createStatCard(icon, label, value, color)
        local card = Instance.new("Frame")
        card.Name = label .. "Card"
        card.BackgroundColor3 = THEME.Background.Light
        card.BackgroundTransparency = 0.3
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 10)
        cardCorner.Parent = card
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 40, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = color
        iconLabel.TextSize = 24
        iconLabel.Font = Enum.Font.GothamBlack
        
        local textContainer = Instance.new("Frame")
        textContainer.Name = "TextContainer"
        textContainer.Size = UDim2.new(1, -45, 1, 0)
        textContainer.Position = UDim2.new(0, 45, 0, 0)
        textContainer.BackgroundTransparency = 1
        
        local statLabel = Instance.new("TextLabel")
        statLabel.Name = "Label"
        statLabel.Size = UDim2.new(1, 0, 0.5, 0)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = label
        statLabel.TextColor3 = THEME.Text.Secondary
        statLabel.TextSize = 12
        statLabel.Font = Enum.Font.GothamMedium
        statLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local statValue = Instance.new("TextLabel")
        statValue.Name = "Value"
        statValue.Size = UDim2.new(1, 0, 0.5, 0)
        statValue.Position = UDim2.new(0, 0, 0.5, 0)
        statValue.BackgroundTransparency = 1
        statValue.Text = value
        statValue.TextColor3 = THEME.Text.Primary
        statValue.TextSize = 18
        statValue.Font = Enum.Font.GothamBold
        statValue.TextXAlignment = Enum.TextXAlignment.Left
        
        statValue.Parent = textContainer
        statLabel.Parent = textContainer
        iconLabel.Parent = card
        textContainer.Parent = card
        
        return card, statValue
    end
    
    local castCard, castValue = createStatCard("🎯", "TOTAL CASTS", "0", THEME.Primary.Main)
    local timeCard, timeValue = createStatCard("⏱️", "RUNTIME", "0s", THEME.Secondary.Main)
    local cpsCard, cpsValue = createStatCard("📈", "CASTS/SEC", "0.0", THEME.Accent.Main)
    local statusCard, statusValue = createStatCard("⚡", "STATUS", "IDLE", THEME.Status.Warning)
    
    -- Control buttons (premium style)
    local controlPanel = Instance.new("Frame")
    controlPanel.Name = "ControlPanel"
    controlPanel.Size = UDim2.new(1, -40, 0, 120)
    controlPanel.Position = UDim2.new(0, 20, 0, 240)
    controlPanel.BackgroundTransparency = 1
    
    local startButton = createPremiumButton("StartButton", "START FISHING", THEME.Status.Success, "▶")
    startButton.Position = UDim2.new(0, 0, 0, 0)
    
    local stopButton = createPremiumButton("StopButton", "STOP FISHING", THEME.Status.Danger, "⏹")
    stopButton.Position = UDim2.new(0, 220, 0, 0)
    
    local pauseButton = createPremiumButton("PauseButton", "PAUSE", THEME.Status.Warning, "⏸")
    pauseButton.Position = UDim2.new(0, 0, 0, 60)
    pauseButton.Visible = false  -- Optional feature
    
    -- Settings panel (enhanced)
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(1, -40, 0, 250)
    settingsPanel.Position = UDim2.new(0, 20, 0, 370)
    settingsPanel.BackgroundTransparency = 0.2
    settingsPanel.BackgroundColor3 = THEME.Background.Card
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 15)
    settingsCorner.Parent = settingsPanel
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, -20, 0, 40)
    settingsTitle.Position = UDim2.new(0, 10, 0, 0)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙️ ADVANCED SETTINGS"
    settingsTitle.TextColor3 = THEME.Accent.Main
    settingsTitle.TextSize = 18
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Premium sliders
    local completeSlider = createAnimatedSlider("CompleteDelay", "Complete Delay", 0.73, 0.1, 2.0, 40, THEME.Primary)
    local cancelSlider = createAnimatedSlider("CancelDelay", "Cancel Delay", 0.3, 0.1, 1.0, 120, THEME.Secondary)
    local recastSlider = createAnimatedSlider("ReCastDelay", "Re-Cast Delay", 0.001, 0.001, 0.5, 200, THEME.Accent)
    
    -- Assembly
    recastSlider.Parent = settingsPanel
    cancelSlider.Parent = settingsPanel
    completeSlider.Parent = settingsPanel
    settingsTitle.Parent = settingsPanel
    
    startButton.Parent = controlPanel
    stopButton.Parent = controlPanel
    pauseButton.Parent = controlPanel
    
    castCard.Parent = statusPanel
    timeCard.Parent = statusPanel
    cpsCard.Parent = statusPanel
    statusCard.Parent = statusPanel
    
    titleIcon.Parent = titleContainer
    titleText.Parent = titleContainer
    subtitle.Parent = titleContainer
    titleContainer.Parent = header
    
    closeButton.Parent = glassPanel
    header.Parent = glassPanel
    statusPanel.Parent = glassPanel
    controlPanel.Parent = glassPanel
    settingsPanel.Parent = glassPanel
    
    glassPanel.Parent = mainContainer
    mainContainer.Parent = screenGui
    dimmer.Parent = screenGui
    screenGui.Parent = playerGui
    
    -- Entrance animation
    mainContainer.Position = UDim2.new(0.5, -200, -0.5, -250)
    mainContainer.BackgroundTransparency = 1
    
    local entranceTween = TweenService:Create(mainContainer, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = NeonUI.CurrentPosition,
        BackgroundTransparency = 0
    })
    
    dimmer.BackgroundTransparency = 1
    TweenService:Create(dimmer, TweenInfo.new(0.5), {
        BackgroundTransparency = 0.7
    }):Play()
    
    entranceTween:Play()
    
    -----------------------------------------------------------------
    -- UI FUNCTIONALITY
    -----------------------------------------------------------------
    
    -- Real-time stats update
    local statsUpdateConnection
    statsUpdateConnection = RunService.Heartbeat:Connect(function()
        if AutoFishingModule.GetStats then
            local stats = AutoFishingModule.GetStats()
            
            -- Update stat cards
            castValue.Text = tostring(stats.castCount)
            timeValue.Text = tostring(stats.runtime) .. "s"
            cpsValue.Text = string.format("%.1f", stats.cps)
            
            -- Update status with color coding
            if stats.isActive then
                statusValue.Text = "ACTIVE"
                statusValue.TextColor3 = THEME.Status.Success
                statusCard.Icon.TextColor3 = THEME.Status.Success
            else
                statusValue.Text = "IDLE"
                statusValue.TextColor3 = THEME.Status.Warning
                statusCard.Icon.TextColor3 = THEME.Status.Warning
            end
            
            -- Update button states
            if stats.isActive then
                startButton.BackgroundColor3 = THEME.Status.Success.Dark
                stopButton.BackgroundColor3 = THEME.Status.Danger.Main
            else
                startButton.BackgroundColor3 = THEME.Status.Success.Main
                stopButton.BackgroundColor3 = THEME.Status.Danger.Dark
            end
        end
    end)
    
    -- Button functionality
    startButton.MouseButton1Click:Connect(function()
        local success = AutoFishingModule.Start()
        if success then
            -- Premium feedback
            createNeonGlow(startButton, THEME.Status.Success.Main, 0.8)
            TweenService:Create(startButton, TweenInfo.new(0.3), {
                BackgroundColor3 = THEME.Status.Success.Light
            }):Play()
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        local success = AutoFishingModule.Stop()
        if success then
            createNeonGlow(stopButton, THEME.Status.Danger.Main, 0.8)
            TweenService:Create(stopButton, TweenInfo.new(0.3), {
                BackgroundColor3 = THEME.Status.Danger.Light
            }):Play()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        -- Exit animation
        local exitTween = TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -200, -0.5, -250),
            BackgroundTransparency = 1
        })
        
        TweenService:Create(dimmer, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
        
        exitTween:Play()
        exitTween.Completed:Wait()
        
        screenGui:Destroy()
        if statsUpdateConnection then
            statsUpdateConnection:Disconnect()
        end
        NeonUI.Visible = false
    end)
    
    -- Close on background click
    dimmer.MouseButton1Click:Connect(function()
        closeButton.MouseButton1Click:Fire()
    end)
    
    -- Toggle UI with F5 (always centers)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F5 then
            NeonUI.Visible = not NeonUI.Visible
            
            if NeonUI.Visible then
                -- Show with animation
                screenGui.Parent = playerGui
                mainContainer.Position = UDim2.new(0.5, -200, -0.5, -250)
                mainContainer.BackgroundTransparency = 1
                
                TweenService:Create(dimmer, TweenInfo.new(0.3), {
                    BackgroundTransparency = 0.7
                }):Play()
                
                TweenService:Create(mainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -200, 0.5, -250),
                    BackgroundTransparency = 0
                }):Play()
            else
                closeButton.MouseButton1Click:Fire()
            end
        end
    end)
    
    return {
        GUI = screenGui,
        UpdateStats = function(stats)
            castValue.Text = tostring(stats.castCount)
            timeValue.Text = tostring(stats.runtime) .. "s"
            cpsValue.Text = string.format("%.1f", stats.cps)
        end
    }
end

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

-- Create the premium UI
local ui = createPremiumUI()

-- Console message with style
print([[
╔══════════════════════════════════════════════╗
║        🎣 NEON FISHING UI v2 LOADED         ║
║  • Premium Control Panel                    ║
║  • Real-time Statistics                     ║
║  • Advanced Settings                        ║
║  • Press F5 to toggle                      ║
╚══════════════════════════════════════════════╝
]])

return NeonUI