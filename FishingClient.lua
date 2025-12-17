
-- Clean Centered UI with 50% Transparency
-- ui.lua - Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create RemoteEvent for communication
if not ReplicatedStorage:FindFirstChild("HighlightToggle") then
    Instance.new("RemoteEvent", ReplicatedStorage).Name = "HighlightToggle"
end

-- Create main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Enabled = false

-- Background Blur
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Name = "UIBlur"
blur.Parent = game:GetService("Lighting")

-- Main Container (Centered, 50% transparent)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 400, 0, 500)
mainContainer.Position = UDim2.new(0.5, -200, 0.5, -250)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainContainer.BackgroundTransparency = 0.5 -- 50% transparent
mainContainer.BorderSizePixel = 0

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = mainContainer

local containerStroke = Instance.new("UIStroke")
containerStroke.Name = "ContainerStroke"
containerStroke.Color = Color3.fromRGB(60, 60, 80)
containerStroke.Thickness = 2
containerStroke.Transparency = 0.3
containerStroke.Parent = mainContainer

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PLAYER HIGHLIGHTS"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 32, 0, 32)
icon.Position = UDim2.new(0, 20, 0.5, -16)
icon.AnchorPoint = Vector2.new(0, 0.5)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://3926305904"
icon.ImageRectOffset = Vector2.new(124, 124)
icon.ImageRectSize = Vector2.new(36, 36)
icon.ImageColor3 = Color3.fromRGB(100, 200, 255)

-- Toggle Switch
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(0, 100, 0, 40)
toggleFrame.Position = UDim2.new(1, -120, 0.5, -20)
toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
toggleFrame.BackgroundTransparency = 1

local toggleBackground = Instance.new("Frame")
toggleBackground.Name = "ToggleBackground"
toggleBackground.Size = UDim2.new(1, 0, 0, 24)
toggleBackground.Position = UDim2.new(0, 0, 0.5, -12)
toggleBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
toggleBackground.BorderSizePixel = 0

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleBackground

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 36, 0, 36)
toggleButton.Position = UDim2.new(0, -2, 0.5, -18)
toggleButton.AnchorPoint = Vector2.new(0, 0.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleButton.Text = ""
toggleButton.AutoButtonColor = false

local toggleButtonCorner = Instance.new("UICorner")
toggleButtonCorner.CornerRadius = UDim.new(1, 0)
toggleButtonCorner.Parent = toggleButton

local toggleStatus = Instance.new("TextLabel")
toggleStatus.Name = "ToggleStatus"
toggleStatus.Size = UDim2.new(1, 0, 0, 20)
toggleStatus.Position = UDim2.new(0, 0, 1, 5)
toggleStatus.BackgroundTransparency = 1
toggleStatus.Text = "OFF"
toggleStatus.TextColor3 = Color3.fromRGB(255, 120, 120)
toggleStatus.TextSize = 12
toggleStatus.Font = Enum.Font.GothamSemibold
toggleStatus.TextXAlignment = Enum.TextXAlignment.Center

-- Close Button
local closeButton = Instance.new("ImageButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0.5, -20)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeButton.BackgroundTransparency = 0.3
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageRectOffset = Vector2.new(284, 4)
closeButton.ImageRectSize = Vector2.new(24, 24)
closeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Content Area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -40, 1, -80)
content.Position = UDim2.new(0, 20, 0, 70)
content.BackgroundTransparency = 1

-- Color Selection Section
local colorSection = Instance.new("Frame")
colorSection.Name = "ColorSection"
colorSection.Size = UDim2.new(1, 0, 0, 120)
colorSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
colorSection.BackgroundTransparency = 0.3
colorSection.BorderSizePixel = 0

local colorCorner = Instance.new("UICorner")
colorCorner.CornerRadius = UDim.new(0, 8)
colorCorner.Parent = colorSection

local colorTitle = Instance.new("TextLabel")
colorTitle.Name = "ColorTitle"
colorTitle.Size = UDim2.new(1, -20, 0, 30)
colorTitle.Position = UDim2.new(0, 15, 0, 10)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "HIGHLIGHT COLOR"
colorTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
colorTitle.TextSize = 16
colorTitle.Font = Enum.Font.GothamSemibold
colorTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Color Grid
local colorGrid = Instance.new("UIGridLayout")
colorGrid.Name = "ColorGrid"
colorGrid.CellSize = UDim2.new(0, 40, 0, 40)
colorGrid.CellPadding = UDim2.new(0, 8, 0, 8)
colorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
colorGrid.SortOrder = Enum.SortOrder.LayoutOrder
colorGrid.StartCorner = Enum.StartCorner.TopLeft

-- Color Options
local colors = {
    {Color3.fromRGB(100, 200, 255), "Sky Blue"},
    {Color3.fromRGB(0, 230, 118), "Emerald"},
    {Color3.fromRGB(255, 82, 82), "Ruby"},
    {Color3.fromRGB(255, 214, 0), "Gold"},
    {Color3.fromRGB(255, 94, 247), "Pink"},
    {Color3.fromRGB(0, 230, 230), "Cyan"},
    {Color3.fromRGB(255, 170, 0), "Orange"},
    {Color3.fromRGB(230, 230, 230), "White"}
}

local colorButtons = {}
local colorContainer = Instance.new("Frame")
colorContainer.Name = "ColorContainer"
colorContainer.Size = UDim2.new(1, -30, 0, 80)
colorContainer.Position = UDim2.new(0, 15, 0, 40)
colorContainer.BackgroundTransparency = 1

-- Settings Section
local settingsSection = Instance.new("Frame")
settingsSection.Name = "SettingsSection"
settingsSection.Size = UDim2.new(1, 0, 0, 160)
settingsSection.Position = UDim2.new(0, 0, 0, 130)
settingsSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
settingsSection.BackgroundTransparency = 0.3
settingsSection.BorderSizePixel = 0

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 8)
settingsCorner.Parent = settingsSection

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Name = "SettingsTitle"
settingsTitle.Size = UDim2.new(1, -20, 0, 30)
settingsTitle.Position = UDim2.new(0, 15, 0, 10)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "SETTINGS"
settingsTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
settingsTitle.TextSize = 16
settingsTitle.Font = Enum.Font.GothamSemibold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Preview Section
local previewSection = Instance.new("Frame")
previewSection.Name = "PreviewSection"
previewSection.Size = UDim2.new(1, 0, 0, 140)
previewSection.Position = UDim2.new(0, 0, 0, 300)
previewSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
previewSection.BackgroundTransparency = 0.3
previewSection.BorderSizePixel = 0

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 8)
previewCorner.Parent = previewSection

local previewTitle = Instance.new("TextLabel")
previewTitle.Name = "PreviewTitle"
previewTitle.Size = UDim2.new(1, -20, 0, 30)
previewTitle.Position = UDim2.new(0, 15, 0, 10)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "LIVE PREVIEW"
previewTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
previewTitle.TextSize = 16
previewTitle.Font = Enum.Font.GothamSemibold
previewTitle.TextXAlignment = Enum.TextXAlignment.Left

local previewFrame = Instance.new("Frame")
previewFrame.Name = "PreviewFrame"
previewFrame.Size = UDim2.new(1, -30, 0, 80)
previewFrame.Position = UDim2.new(0, 15, 0, 45)
previewFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
previewFrame.BackgroundTransparency = 0.2
previewFrame.BorderSizePixel = 0

local previewFrameCorner = Instance.new("UICorner")
previewFrameCorner.CornerRadius = UDim.new(0, 6)
previewFrameCorner.Parent = previewFrame

local previewCharacter = Instance.new("Frame")
previewCharacter.Name = "PreviewCharacter"
previewCharacter.Size = UDim2.new(0, 60, 0, 100)
previewCharacter.Position = UDim2.new(0.5, -30, 0.5, -50)
previewCharacter.AnchorPoint = Vector2.new(0.5, 0.5)
previewCharacter.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
previewCharacter.BorderSizePixel = 0

local previewCharacterCorner = Instance.new("UICorner")
previewCharacterCorner.CornerRadius = UDim.new(0, 4)
previewCharacterCorner.Parent = previewCharacter

local previewHighlight = Instance.new("Frame")
previewHighlight.Name = "PreviewHighlight"
previewHighlight.Size = UDim2.new(1, 8, 1, 8)
previewHighlight.Position = UDim2.new(0, -4, 0, -4)
previewHighlight.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
previewHighlight.BackgroundTransparency = 0.5
previewHighlight.BorderSizePixel = 0
previewHighlight.ZIndex = -1

local previewHighlightCorner = Instance.new("UICorner")
previewHighlightCorner.CornerRadius = UDim.new(0, 6)
previewHighlightCorner.Parent = previewHighlight

-- Assemble UI
previewHighlight.Parent = previewCharacter
previewCharacter.Parent = previewFrame
previewFrame.Parent = previewSection
previewTitle.Parent = previewSection

settingsTitle.Parent = settingsSection

colorTitle.Parent = colorSection
colorGrid.Parent = colorContainer
colorContainer.Parent = colorSection

toggleBackground.Parent = toggleFrame
toggleButton.Parent = toggleFrame
toggleStatus.Parent = toggleFrame
toggleFrame.Parent = header
icon.Parent = header
title.Parent = header
closeButton.Parent = header
header.Parent = mainContainer

colorSection.Parent = content
settingsSection.Parent = content
previewSection.Parent = content
content.Parent = mainContainer
mainContainer.Parent = screenGui
screenGui.Parent = playerGui

-- Create color buttons
for i, colorData in ipairs(colors) do
    local colorButton = Instance.new("TextButton")
    colorButton.Name = "Color_" .. colorData[2]
    colorButton.Size = UDim2.new(0, 40, 0, 40)
    colorButton.BackgroundColor3 = colorData[1]
    colorButton.Text = ""
    colorButton.AutoButtonColor = false
    
    local colorButtonCorner = Instance.new("UICorner")
    colorButtonCorner.CornerRadius = UDim.new(1, 0)
    colorButtonCorner.Parent = colorButton
    
    -- Selection indicator
    local selectionRing = Instance.new("Frame")
    selectionRing.Name = "SelectionRing"
    selectionRing.Size = UDim2.new(1, 6, 1, 6)
    selectionRing.Position = UDim2.new(0, -3, 0, -3)
    selectionRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selectionRing.BackgroundTransparency = 0.7
    selectionRing.BorderSizePixel = 0
    selectionRing.Visible = (i == 1) -- First color selected by default
    
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(1, 0)
    selectionCorner.Parent = selectionRing
    
    selectionRing.Parent = colorButton
    colorButton.Parent = colorContainer
    colorButtons[colorButton] = {
        color = colorData[1],
        name = colorData[2],
        ring = selectionRing
    }
end

-- Create settings sliders
local function createSlider(parent, name, label, defaultValue, minValue, maxValue, step)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = name .. "Container"
    sliderContainer.Size = UDim2.new(1, -30, 0, 50)
    sliderContainer.Position = UDim2.new(0, 15, 0, 40 + (#parent:GetChildren() - 1) * 55)
    sliderContainer.BackgroundTransparency = 1
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = name .. "Label"
    sliderLabel.Size = UDim2.new(0.4, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = label
    sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    sliderLabel.TextSize = 14
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderValue = Instance.new("TextLabel")
    sliderValue.Name = name .. "Value"
    sliderValue.Size = UDim2.new(0.2, 0, 0, 20)
    sliderValue.Position = UDim2.new(0.8, 0, 0, 0)
    sliderValue.BackgroundTransparency = 1
    sliderValue.Text = tostring(defaultValue)
    sliderValue.TextColor3 = Color3.fromRGB(200, 200, 200)
    sliderValue.TextSize = 14
    sliderValue.Font = Enum.Font.GothamSemibold
    sliderValue.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = name .. "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderTrack.BorderSizePixel = 0
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = name .. "Fill"
    sliderFill.Size = UDim2.new(defaultValue, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = name .. "Handle"
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new(defaultValue, -10, 0.5, -10)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    sliderHandle.BorderSizePixel = 0
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = sliderHandle
    
    sliderFill.Parent = sliderTrack
    sliderHandle.Parent = sliderTrack
    
    sliderLabel.Parent = sliderContainer
    sliderValue.Parent = sliderContainer
    sliderTrack.Parent = sliderContainer
    
    sliderContainer.Parent = parent
    
    return {
        container = sliderContainer,
        label = sliderLabel,
        value = sliderValue,
        track = sliderTrack,
        fill = sliderFill,
        handle = sliderHandle,
        current = defaultValue,
        min = minValue,
        max = maxValue,
        step = step
    }
end

-- Create sliders
local transparencySlider = createSlider(settingsSection, "Transparency", "Transparency", 0.5, 0.1, 0.9, 0.05)
local intensitySlider = createSlider(settingsSection, "Intensity", "Intensity", 0.8, 0.3, 1.0, 0.05)
local thicknessSlider = createSlider(settingsSection, "Thickness", "Outline Thickness", 2, 1, 5, 0.5)

-- UI State
local isHighlightEnabled = false
local selectedColor = colors[1][1]
local settings = {
    Transparency = 0.5,
    Intensity = 0.8,
    Thickness = 2
}

-- Update preview
local function updatePreview()
    previewHighlight.BackgroundColor3 = selectedColor
    previewHighlight.BackgroundTransparency = settings.Transparency
    
    -- Animate preview when enabled
    if isHighlightEnabled then
        local pulse = TweenService:Create(previewHighlight, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = settings.Transparency + 0.1
        })
        pulse:Play()
    else
        -- Stop all tweens
        local tweens = TweenService:GetRunningTweens(previewHighlight)
        for _, tween in ipairs(tweens) do
            tween:Cancel()
        end
    end
end

-- Update toggle switch
local function updateToggle()
    if isHighlightEnabled then
        TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(80, 255, 140),
            Position = UDim2.new(1, -36, 0.5, -18)
        }):Play()
        TweenService:Create(toggleBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(40, 100, 60)
        }):Play()
        toggleStatus.Text = "ON"
        toggleStatus.TextColor3 = Color3.fromRGB(80, 255, 140)
    else
        TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80),
            Position = UDim2.new(0, -2, 0.5, -18)
        }):Play()
        TweenService:Create(toggleBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        }):Play()
        toggleStatus.Text = "OFF"
        toggleStatus.TextColor3 = Color3.fromRGB(255, 120, 120)
    end
    updatePreview()
end

-- Toggle highlight system
toggleButton.MouseButton1Click:Connect(function()
    isHighlightEnabled = not isHighlightEnabled
    updateToggle()
    
    -- Send toggle to server
    ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
        Color = selectedColor,
        Transparency = settings.Transparency,
        Intensity = settings.Intensity,
        Thickness = settings.Thickness
    })
end)

-- Color selection
for button, data in pairs(colorButtons) do
    button.MouseButton1Click:Connect(function()
        selectedColor = data.color
        
        -- Update all selection rings
        for _, btnData in pairs(colorButtons) do
            btnData.ring.Visible = false
        end
        data.ring.Visible = true
        
        -- Update preview
        updatePreview()
        
        -- Update server if enabled
        if isHighlightEnabled then
            ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
                Color = selectedColor,
                Transparency = settings.Transparency,
                Intensity = settings.Intensity,
                Thickness = settings.Thickness
            })
        end
    end)
end

-- Slider functionality
local function setupSlider(sliderData)
    local isDragging = false
    
    local function updateSliderValue(xPosition)
        local absoluteX = sliderData.track.AbsolutePosition.X
        local absoluteWidth = sliderData.track.AbsoluteSize.X
        local percent = math.clamp((xPosition - absoluteX) / absoluteWidth, 0, 1)
        
        -- Apply step
        local value = sliderData.min + (percent * (sliderData.max - sliderData.min))
        value = math.floor(value / sliderData.step + 0.5) * sliderData.step
        
        sliderData.current = value
        sliderData.value.Text = string.format("%.2f", value)
        sliderData.fill.Size = UDim2.new(percent, 0, 1, 0)
        sliderData.handle.Position = UDim2.new(percent, -10, 0.5, -10)
        
        -- Update settings
        settings[sliderData.label.Text] = value
        
        -- Update preview
        updatePreview()
        
        -- Update server if enabled
        if isHighlightEnabled then
            ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
                Color = selectedColor,
                Transparency = settings.Transparency,
                Intensity = settings.Intensity,
                Thickness = settings.Thickness
            })
        end
    end
    
    sliderData.track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSliderValue(input.Position.X)
        end
    end)
    
    sliderData.track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    sliderData.handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    sliderData.handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSliderValue(input.Position.X)
        end
    end)
end

-- Setup all sliders
setupSlider(transparencySlider)
setupSlider(intensitySlider)
setupSlider(thicknessSlider)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    toggleUI()
end)

-- Toggle UI function
local function toggleUI()
    screenGui.Enabled = not screenGui.Enabled
    
    if screenGui.Enabled then
        -- Fade in blur
        TweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = 12
        }):Play()
        
        -- Scale in animation
        mainContainer.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 400, 0, 500)
        }):Play()
    else
        -- Fade out blur
        TweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = 0
        }):Play()
        
        -- Scale out animation
        TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
end

-- Keyboard shortcut (F3)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F3 then
        toggleUI()
    end
end)

-- Initialize
updateToggle()
updatePreview()

print("Highlight UI loaded! Press F3 to toggle.")
