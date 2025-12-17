-- Clean Highlight UI LocalScript
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create RemoteEvent if it doesn't exist
if not ReplicatedStorage:FindFirstChild("HighlightToggle") then
    Instance.new("RemoteEvent", ReplicatedStorage).Name = "HighlightToggle"
end

-- Clean UI Design
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightPanel"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 300, 0, 380)
mainContainer.Position = UDim2.new(1, -320, 0.5, -190)
mainContainer.AnchorPoint = Vector2.new(0, 0.5)
mainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainContainer.BackgroundTransparency = 0.05
mainContainer.BorderSizePixel = 0

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = mainContainer

local containerShadow = Instance.new("ImageLabel")
containerShadow.Name = "Shadow"
containerShadow.Image = "rbxassetid://5554236805"
containerShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
containerShadow.ImageTransparency = 0.8
containerShadow.ScaleType = Enum.ScaleType.Slice
containerShadow.SliceCenter = Rect.new(23, 23, 277, 277)
containerShadow.Size = UDim2.new(1, 30, 1, 30)
containerShadow.Position = UDim2.new(0.5, -15, 0.5, -15)
containerShadow.AnchorPoint = Vector2.new(0.5, 0.5)
containerShadow.BackgroundTransparency = 1
containerShadow.Parent = mainContainer
containerShadow.ZIndex = -1

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PLAYER HIGHLIGHTS"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.TextSize = 18
title.Font = Enum.Font.GothamSemibold
title.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Button in Header
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 80, 0, 30)
toggleButton.Position = UDim2.new(1, -85, 0.5, -15)
toggleButton.AnchorPoint = Vector2.new(1, 0.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.AutoButtonColor = false

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- Close Button
local closeButton = Instance.new("ImageButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -30, 0, 13)
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageRectOffset = Vector2.new(284, 4)
closeButton.ImageRectSize = Vector2.new(24, 24)
closeButton.ImageColor3 = Color3.fromRGB(180, 180, 180)

-- Content Area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -50)
content.Position = UDim2.new(0, 0, 0, 50)
content.BackgroundTransparency = 1

-- Preview Section
local previewSection = Instance.new("Frame")
previewSection.Name = "PreviewSection"
previewSection.Size = UDim2.new(1, -20, 0, 80)
previewSection.Position = UDim2.new(0, 10, 0, 10)
previewSection.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
previewSection.BorderSizePixel = 0

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 6)
previewCorner.Parent = previewSection

local previewLabel = Instance.new("TextLabel")
previewLabel.Name = "PreviewLabel"
previewLabel.Size = UDim2.new(1, 0, 0, 25)
previewLabel.Position = UDim2.new(0, 10, 0, 5)
previewLabel.BackgroundTransparency = 1
previewLabel.Text = "PREVIEW"
previewLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
previewLabel.TextSize = 12
previewLabel.Font = Enum.Font.GothamSemibold
previewLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Preview Example
local previewExample = Instance.new("Frame")
previewExample.Name = "PreviewExample"
previewExample.Size = UDim2.new(0, 120, 0, 40)
previewExample.Position = UDim2.new(0.5, -60, 0.5, 0)
previewExample.AnchorPoint = Vector2.new(0.5, 0.5)
previewExample.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
previewExample.BorderSizePixel = 0

local exampleCorner = Instance.new("UICorner")
exampleCorner.CornerRadius = UDim.new(0, 4)
exampleCorner.Parent = previewExample

local previewHighlight = Instance.new("Frame")
previewHighlight.Name = "PreviewHighlight"
previewHighlight.Size = UDim2.new(1, 4, 1, 4)
previewHighlight.Position = UDim2.new(0, -2, 0, -2)
previewHighlight.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
previewHighlight.BackgroundTransparency = 0.3
previewHighlight.BorderSizePixel = 0
previewHighlight.ZIndex = -1

local highlightCorner = Instance.new("UICorner")
highlightCorner.CornerRadius = UDim.new(0, 6)
highlightCorner.Parent = previewHighlight

-- Color Selection
local colorSection = Instance.new("Frame")
colorSection.Name = "ColorSection"
colorSection.Size = UDim2.new(1, -20, 0, 100)
colorSection.Position = UDim2.new(0, 10, 0, 100)
colorSection.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
colorSection.BorderSizePixel = 0

local colorCorner = Instance.new("UICorner")
colorCorner.CornerRadius = UDim.new(0, 6)
colorCorner.Parent = colorSection

local colorLabel = Instance.new("TextLabel")
colorLabel.Name = "ColorLabel"
colorLabel.Size = UDim2.new(1, 0, 0, 25)
colorLabel.Position = UDim2.new(0, 10, 0, 5)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "HIGHLIGHT COLOR"
colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
colorLabel.TextSize = 12
colorLabel.Font = Enum.Font.GothamSemibold
colorLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Color Grid
local colorGrid = Instance.new("UIGridLayout")
colorGrid.Name = "ColorGrid"
colorGrid.CellSize = UDim2.new(0, 32, 0, 32)
colorGrid.CellPadding = UDim2.new(0, 6, 0, 6)
colorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
colorGrid.SortOrder = Enum.SortOrder.LayoutOrder
colorGrid.StartCorner = Enum.StartCorner.TopLeft

-- Color Options
local colors = {
    {Color3.fromRGB(60, 160, 255), "Blue"},
    {Color3.fromRGB(0, 230, 118), "Green"},
    {Color3.fromRGB(255, 82, 82), "Red"},
    {Color3.fromRGB(255, 214, 0), "Yellow"},
    {Color3.fromRGB(255, 94, 247), "Pink"},
    {Color3.fromRGB(0, 230, 230), "Cyan"},
    {Color3.fromRGB(255, 170, 0), "Orange"},
    {Color3.fromRGB(230, 230, 230), "White"}
}

local colorButtons = {}

-- Settings Section
local settingsSection = Instance.new("Frame")
settingsSection.Name = "SettingsSection"
settingsSection.Size = UDim2.new(1, -20, 0, 120)
settingsSection.Position = UDim2.new(0, 10, 0, 210)
settingsSection.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
settingsSection.BorderSizePixel = 0

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsSection

local settingsLabel = Instance.new("TextLabel")
settingsLabel.Name = "SettingsLabel"
settingsLabel.Size = UDim2.new(1, 0, 0, 25)
settingsLabel.Position = UDim2.new(0, 10, 0, 5)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Text = "SETTINGS"
settingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsLabel.TextSize = 12
settingsLabel.Font = Enum.Font.GothamSemibold
settingsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Transparency Setting
local transparencyFrame = Instance.new("Frame")
transparencyFrame.Name = "TransparencyFrame"
transparencyFrame.Size = UDim2.new(1, -20, 0, 50)
transparencyFrame.Position = UDim2.new(0, 10, 0, 30)
transparencyFrame.BackgroundTransparency = 1

local transparencyLabel = Instance.new("TextLabel")
transparencyLabel.Name = "TransparencyLabel"
transparencyLabel.Size = UDim2.new(0.4, 0, 1, 0)
transparencyLabel.BackgroundTransparency = 1
transparencyLabel.Text = "Transparency:"
transparencyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
transparencyLabel.TextSize = 14
transparencyLabel.Font = Enum.Font.Gotham
transparencyLabel.TextXAlignment = Enum.TextXAlignment.Left

local transparencyValue = Instance.new("TextLabel")
transparencyValue.Name = "TransparencyValue"
transparencyValue.Size = UDim2.new(0.2, 0, 1, 0)
transparencyValue.Position = UDim2.new(0.8, 0, 0, 0)
transparencyValue.BackgroundTransparency = 1
transparencyValue.Text = "0.7"
transparencyValue.TextColor3 = Color3.fromRGB(200, 200, 200)
transparencyValue.TextSize = 14
transparencyValue.Font = Enum.Font.GothamSemibold
transparencyValue.TextXAlignment = Enum.TextXAlignment.Right

local transparencySlider = Instance.new("Frame")
transparencySlider.Name = "TransparencySlider"
transparencySlider.Size = UDim2.new(0.4, 0, 0, 6)
transparencySlider.Position = UDim2.new(0.4, 0, 0.5, -3)
transparencySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
transparencySlider.BorderSizePixel = 0

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = transparencySlider

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0.7, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
sliderFill.BorderSizePixel = 0

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderHandle = Instance.new("Frame")
sliderHandle.Name = "SliderHandle"
sliderHandle.Size = UDim2.new(0, 16, 0, 16)
sliderHandle.Position = UDim2.new(0.7, -8, 0.5, -8)
sliderHandle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
sliderHandle.BorderSizePixel = 0

local handleCorner = Instance.new("UICorner")
handleCorner.CornerRadius = UDim.new(1, 0)
handleCorner.Parent = sliderHandle

-- Intensity Setting
local intensityFrame = Instance.new("Frame")
intensityFrame.Name = "IntensityFrame"
intensityFrame.Size = UDim2.new(1, -20, 0, 50)
intensityFrame.Position = UDim2.new(0, 10, 0, 80)
intensityFrame.BackgroundTransparency = 1

local intensityLabel = Instance.new("TextLabel")
intensityLabel.Name = "IntensityLabel"
intensityLabel.Size = UDim2.new(0.4, 0, 1, 0)
intensityLabel.BackgroundTransparency = 1
intensityLabel.Text = "Intensity:"
intensityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
intensityLabel.TextSize = 14
intensityLabel.Font = Enum.Font.Gotham
intensityLabel.TextXAlignment = Enum.TextXAlignment.Left

local intensityValue = Instance.new("TextLabel")
intensityValue.Name = "IntensityValue"
intensityValue.Size = UDim2.new(0.2, 0, 1, 0)
intensityValue.Position = UDim2.new(0.8, 0, 0, 0)
intensityValue.BackgroundTransparency = 1
intensityValue.Text = "0.8"
intensityValue.TextColor3 = Color3.fromRGB(200, 200, 200)
intensityValue.TextSize = 14
intensityValue.Font = Enum.Font.GothamSemibold
intensityValue.TextXAlignment = Enum.TextXAlignment.Right

local intensitySlider = Instance.new("Frame")
intensitySlider.Name = "IntensitySlider"
intensitySlider.Size = UDim2.new(0.4, 0, 0, 6)
intensitySlider.Position = UDim2.new(0.4, 0, 0.5, -3)
intensitySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
intensitySlider.BorderSizePixel = 0

local intensitySliderCorner = Instance.new("UICorner")
intensitySliderCorner.CornerRadius = UDim.new(1, 0)
intensitySliderCorner.Parent = intensitySlider

local intensityFill = Instance.new("Frame")
intensityFill.Name = "IntensityFill"
intensityFill.Size = UDim2.new(0.8, 0, 1, 0)
intensityFill.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
intensityFill.BorderSizePixel = 0

local intensityFillCorner = Instance.new("UICorner")
intensityFillCorner.CornerRadius = UDim.new(1, 0)
intensityFillCorner.Parent = intensityFill

local intensityHandle = Instance.new("Frame")
intensityHandle.Name = "IntensityHandle"
intensityHandle.Size = UDim2.new(0, 16, 0, 16)
intensityHandle.Position = UDim2.new(0.8, -8, 0.5, -8)
intensityHandle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
intensityHandle.BorderSizePixel = 0

local intensityHandleCorner = Instance.new("UICorner")
intensityHandleCorner.CornerRadius = UDim.new(1, 0)
intensityHandleCorner.Parent = intensityHandle

-- Assemble UI
transparencyLabel.Parent = transparencyFrame
transparencyValue.Parent = transparencyFrame
sliderFill.Parent = transparencySlider
sliderHandle.Parent = transparencySlider
transparencySlider.Parent = transparencyFrame

intensityLabel.Parent = intensityFrame
intensityValue.Parent = intensityFrame
intensityFill.Parent = intensitySlider
intensityHandle.Parent = intensitySlider
intensitySlider.Parent = intensityFrame

transparencyFrame.Parent = settingsSection
intensityFrame.Parent = settingsSection

previewLabel.Parent = previewSection
previewHighlight.Parent = previewExample
previewExample.Parent = previewSection

colorLabel.Parent = colorSection
colorGrid.Parent = colorSection

settingsLabel.Parent = settingsSection

previewSection.Parent = content
colorSection.Parent = content
settingsSection.Parent = content

title.Parent = header
toggleButton.Parent = header
closeButton.Parent = header
header.Parent = mainContainer
content.Parent = mainContainer
mainContainer.Parent = screenGui
screenGui.Parent = playerGui

-- Create color buttons
for i, colorData in ipairs(colors) do
    local colorButton = Instance.new("TextButton")
    colorButton.Name = "Color_" .. colorData[2]
    colorButton.Size = UDim2.new(0, 32, 0, 32)
    colorButton.BackgroundColor3 = colorData[1]
    colorButton.Text = ""
    colorButton.AutoButtonColor = false
    
    local colorButtonCorner = Instance.new("UICorner")
    colorButtonCorner.CornerRadius = UDim.new(1, 0)
    colorButtonCorner.Parent = colorButton
    
    -- Selection indicator
    local selectionRing = Instance.new("Frame")
    selectionRing.Name = "SelectionRing"
    selectionRing.Size = UDim2.new(1, 4, 1, 4)
    selectionRing.Position = UDim2.new(0, -2, 0, -2)
    selectionRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selectionRing.BackgroundTransparency = 0.8
    selectionRing.BorderSizePixel = 0
    selectionRing.Visible = (i == 1) -- First color selected by default
    
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(1, 0)
    selectionCorner.Parent = selectionRing
    
    selectionRing.Parent = colorButton
    colorButton.Parent = colorSection
    colorButtons[colorButton] = {color = colorData[1], name = colorData[2], ring = selectionRing}
end

-- UI State
local isHighlightEnabled = false
local selectedColor = colors[1][1]
local currentTransparency = 0.7
local currentIntensity = 0.8

-- Update preview
local function updatePreview()
    previewHighlight.BackgroundColor3 = selectedColor
    previewHighlight.BackgroundTransparency = currentTransparency
end

-- Update toggle button
local function updateToggleButton()
    if isHighlightEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 83)
        toggleButton.Text = "ON"
        
        -- Animate the preview when enabled
        local pulseTween = TweenService:Create(previewHighlight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = currentTransparency + 0.1
        })
        pulseTween:Play()
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
        toggleButton.Text = "OFF"
        
        -- Stop animations
        TweenService:GetRunningTweens(previewHighlight)
    end
    updatePreview()
end

-- Update sliders
local function updateSlider(slider, fill, handle, valueLabel, value, min, max)
    local percent = (value - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    handle.Position = UDim2.new(percent, -8, 0.5, -8)
    valueLabel.Text = string.format("%.1f", value)
end

-- Initialize sliders
updateSlider(transparencySlider, sliderFill, sliderHandle, transparencyValue, currentTransparency, 0, 1)
updateSlider(intensitySlider, intensityFill, intensityHandle, intensityValue, currentIntensity, 0.1, 1)

-- Toggle highlights
toggleButton.MouseButton1Click:Connect(function()
    isHighlightEnabled = not isHighlightEnabled
    updateToggleButton()
    
    -- Send to server
    ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
        Color = selectedColor,
        Transparency = currentTransparency,
        Intensity = currentIntensity
    })
    
    -- Button animation
    local originalSize = toggleButton.Size
    TweenService:Create(toggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize - UDim2.new(0, 5, 0, 5)
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(toggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    }):Play()
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
        
        -- Send update if highlights are enabled
        if isHighlightEnabled then
            ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
                Color = selectedColor,
                Transparency = currentTransparency,
                Intensity = currentIntensity
            })
        end
    end)
end

-- Slider functionality
local function setupSlider(sliderFrame, fill, handle, valueLabel, onValueChanged)
    local isDragging = false
    
    local function updateValue(xPosition)
        local absoluteX = sliderFrame.AbsolutePosition.X
        local absoluteWidth = sliderFrame.AbsoluteSize.X
        local percent = math.clamp((xPosition - absoluteX) / absoluteWidth, 0, 1)
        
        onValueChanged(percent)
        updateSlider(sliderFrame, fill, handle, valueLabel, percent, 0, 1)
    end
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateValue(input.Position.X)
        end
    end)
    
    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end

-- Setup sliders
setupSlider(transparencySlider, sliderFill, sliderHandle, transparencyValue, function(value)
    currentTransparency = value
    updatePreview()
    
    if isHighlightEnabled then
        ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
            Color = selectedColor,
            Transparency = currentTransparency,
            Intensity = currentIntensity
        })
    end
end)

setupSlider(intensitySlider, intensityFill, intensityHandle, intensityValue, function(value)
    currentIntensity = value
    
    if isHighlightEnabled then
        ReplicatedStorage.HighlightToggle:FireServer(isHighlightEnabled, {
            Color = selectedColor,
            Transparency = currentTransparency,
            Intensity = currentIntensity
        })
    end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    -- Slide out animation
    local tween = TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, 20, 0.5, -190)
    })
    tween:Play()
    
    tween.Completed:Wait()
    screenGui.Enabled = false
end)

-- Open/Close toggle with T key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        if not screenGui.Enabled then
            screenGui.Enabled = true
            -- Slide in from right
            mainContainer.Position = UDim2.new(1, 20, 0.5, -190)
            local tween = TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -320, 0.5, -190)
            })
            tween:Play()
        else
            -- Slide out
            local tween = TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 20, 0.5, -190)
            })
            tween:Play()
            tween.Completed:Wait()
            screenGui.Enabled = false
        end
    end
end)

-- Initialize
updateToggleButton()
updatePreview()

print("Clean Highlight UI loaded! Press T to toggle UI.")
