
-- LocalScript: HighlightToggleUI
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create RemoteEvent for communication
if not ReplicatedStorage:FindFirstChild("ToggleHighlight") then
    local remote = Instance.new("RemoteEvent")
    remote.Name = "ToggleHighlight"
    remote.Parent = ReplicatedStorage
end

-- Create the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 200)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Drop shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0.5, -190, 0.5, -110)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Parent = screenGui
shadow.ZIndex = -1

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PLAYER HIGHLIGHTS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.AnchorPoint = Vector2.new(0.5, 0.5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Main content
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1

-- Icon
local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 80, 0, 80)
icon.Position = UDim2.new(0, 20, 0, 20)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://3926307971" -- Eye icon
icon.ImageRectSize = Vector2.new(48, 48)
icon.ImageRectOffset = Vector2.new(124, 204)
icon.ImageColor3 = Color3.fromRGB(100, 150, 255)

-- Feature description
local description = Instance.new("TextLabel")
description.Name = "Description"
description.Size = UDim2.new(0.6, 0, 0, 60)
description.Position = UDim2.new(0, 120, 0, 30)
description.BackgroundTransparency = 1
description.Text = "Enable player highlights to see all players in the game with glowing outlines."
description.TextColor3 = Color3.fromRGB(200, 200, 200)
description.TextSize = 16
description.Font = Enum.Font.Gotham
description.TextWrapped = true
description.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0.5, -60, 1, -60)
toggleButton.AnchorPoint = Vector2.new(0.5, 1)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
toggleButton.Text = "ENABLE"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.GothamBold

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Status indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Name = "StatusIndicator"
statusIndicator.Size = UDim2.new(0, 12, 0, 12)
statusIndicator.Position = UDim2.new(1, -130, 0, 25)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = statusIndicator

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(0, 100, 0, 20)
statusText.Position = UDim2.new(1, -110, 0, 20)
statusText.BackgroundTransparency = 1
statusText.Text = "Disabled"
statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
statusText.TextSize = 14
statusText.Font = Enum.Font.Gotham
statusText.TextXAlignment = Enum.TextXAlignment.Left

-- Settings panel (collapsible)
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Size = UDim2.new(0, 120, 0, 30)
settingsButton.Position = UDim2.new(0.5, -60, 1, -100)
settingsButton.AnchorPoint = Vector2.new(0.5, 1)
settingsButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
settingsButton.Text = "⚙ Settings"
settingsButton.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsButton.TextSize = 14
settingsButton.Font = Enum.Font.Gotham

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsButton

-- Settings panel
local settingsPanel = Instance.new("Frame")
settingsPanel.Name = "SettingsPanel"
settingsPanel.Size = UDim2.new(1, -20, 0, 0)
settingsPanel.Position = UDim2.new(0, 10, 1, 10)
settingsPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
settingsPanel.BackgroundTransparency = 0.1
settingsPanel.BorderSizePixel = 0
settingsPanel.Visible = false
settingsPanel.ClipsDescendants = true

local settingsPanelCorner = Instance.new("UICorner")
settingsPanelCorner.CornerRadius = UDim.new(0, 8)
settingsPanelCorner.Parent = settingsPanel

-- Color picker
local colorLabel = Instance.new("TextLabel")
colorLabel.Name = "ColorLabel"
colorLabel.Size = UDim2.new(1, 0, 0, 25)
colorLabel.Position = UDim2.new(0, 10, 0, 10)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Highlight Color:"
colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
colorLabel.TextSize = 14
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextXAlignment = Enum.TextXAlignment.Left

local colorPicker = Instance.new("TextButton")
colorPicker.Name = "ColorPicker"
colorPicker.Size = UDim2.new(0, 80, 0, 30)
colorPicker.Position = UDim2.new(0, 10, 0, 40)
colorPicker.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
colorPicker.Text = "Green"
colorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
colorPicker.TextSize = 14

local colorPickerCorner = Instance.new("UICorner")
colorPickerCorner.CornerRadius = UDim.new(0, 6)
colorPickerCorner.Parent = colorPicker

-- Transparency slider
local transparencyLabel = Instance.new("TextLabel")
transparencyLabel.Name = "TransparencyLabel"
transparencyLabel.Size = UDim2.new(1, 0, 0, 25)
transparencyLabel.Position = UDim2.new(0, 10, 0, 80)
transparencyLabel.BackgroundTransparency = 1
transparencyLabel.Text = "Transparency: 0.8"
transparencyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
transparencyLabel.TextSize = 14
transparencyLabel.Font = Enum.Font.Gotham
transparencyLabel.TextXAlignment = Enum.TextXAlignment.Left

local transparencySlider = Instance.new("Frame")
transparencySlider.Name = "TransparencySlider"
transparencySlider.Size = UDim2.new(1, -20, 0, 20)
transparencySlider.Position = UDim2.new(0, 10, 0, 110)
transparencySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 10)
sliderCorner.Parent = transparencySlider

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0.8, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderFill.BorderSizePixel = 0

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 10)
sliderFillCorner.Parent = sliderFill

local sliderHandle = Instance.new("Frame")
sliderHandle.Name = "SliderHandle"
sliderHandle.Size = UDim2.new(0, 20, 0, 20)
sliderHandle.Position = UDim2.new(0.8, -10, 0, 0)
sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderHandle.BorderSizePixel = 0

local sliderHandleCorner = Instance.new("UICorner")
sliderHandleCorner.CornerRadius = UDim.new(1, 0)
sliderHandleCorner.Parent = sliderHandle

-- Assemble UI hierarchy
sliderFill.Parent = transparencySlider
sliderHandle.Parent = transparencySlider

colorLabel.Parent = settingsPanel
colorPicker.Parent = settingsPanel
transparencyLabel.Parent = settingsPanel
transparencySlider.Parent = settingsPanel

settingsPanel.Parent = mainFrame
settingsButton.Parent = mainFrame
statusIndicator.Parent = mainFrame
statusText.Parent = mainFrame
toggleButton.Parent = mainFrame
description.Parent = mainFrame
icon.Parent = mainFrame
contentFrame.Parent = mainFrame
closeButton.Parent = titleBar
titleBar.Parent = mainFrame
mainFrame.Parent = screenGui
screenGui.Parent = playerGui

-- UI State
local isHighlightEnabled = false
local isSettingsOpen = false
local currentColor = Color3.fromRGB(0, 255, 0)
local currentTransparency = 0.8

-- Animation functions
local function toggleSettings()
    isSettingsOpen = not isSettingsOpen
    settingsPanel.Visible = isSettingsOpen
    
    local targetSize = isSettingsOpen and 150 or 0
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local tween = TweenService:Create(settingsPanel, tweenInfo, {
        Size = UDim2.new(1, -20, 0, targetSize)
    })
    tween:Play()
    
    settingsButton.Text = isSettingsOpen and "▲ Hide Settings" or "⚙ Settings"
end

local function updateToggleButton()
    if isHighlightEnabled then
        toggleButton.Text = "DISABLE"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        statusText.Text = "Enabled"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        toggleButton.Text = "ENABLE"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        statusText.Text = "Disabled"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Button animations
local function animateButton(button)
    local originalSize = button.Size
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local shrink = TweenService:Create(button, tweenInfo, {
        Size = originalSize - UDim2.new(0, 5, 0, 5)
    })
    
    local grow = TweenService:Create(button, tweenInfo, {
        Size = originalSize
    })
    
    shrink:Play()
    shrink.Completed:Connect(function()
        grow:Play()
    end)
end

-- Toggle highlight feature
toggleButton.MouseButton1Click:Connect(function()
    animateButton(toggleButton)
    isHighlightEnabled = not isHighlightEnabled
    updateToggleButton()
    
    -- Send toggle event to server
    ReplicatedStorage.ToggleHighlight:FireServer(isHighlightEnabled, {
        Color = currentColor,
        Transparency = currentTransparency
    })
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    animateButton(closeButton)
    
    -- Animate close
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    
    tween:Play()
    tween.Completed:Wait()
    screenGui.Enabled = false
end)

-- Settings button
settingsButton.MouseButton1Click:Connect(function()
    animateButton(settingsButton)
    toggleSettings()
end)

-- Color picker
local colors = {
    {Color3.fromRGB(0, 255, 0), "Green"},
    {Color3.fromRGB(255, 0, 0), "Red"},
    {Color3.fromRGB(0, 0, 255), "Blue"},
    {Color3.fromRGB(255, 255, 0), "Yellow"},
    {Color3.fromRGB(255, 0, 255), "Magenta"},
    {Color3.fromRGB(0, 255, 255), "Cyan"},
    {Color3.fromRGB(255, 255, 255), "White"}
}

local currentColorIndex = 1

colorPicker.MouseButton1Click:Connect(function()
    animateButton(colorPicker)
    currentColorIndex = (currentColorIndex % #colors) + 1
    currentColor = colors[currentColorIndex][1]
    colorPicker.BackgroundColor3 = currentColor
    colorPicker.Text = colors[currentColorIndex][2]
    
    -- Update if highlights are active
    if isHighlightEnabled then
        ReplicatedStorage.ToggleHighlight:FireServer(isHighlightEnabled, {
            Color = currentColor,
            Transparency = currentTransparency
        })
    end
end)

-- Transparency slider
local isDragging = false

local function updateTransparency(value)
    currentTransparency = math.clamp(value, 0, 1)
    transparencyLabel.Text = string.format("Transparency: %.1f", currentTransparency)
    sliderFill.Size = UDim2.new(1 - currentTransparency, 0, 1, 0)
    sliderHandle.Position = UDim2.new(1 - currentTransparency, -10, 0, 0)
    
    -- Update if highlights are active
    if isHighlightEnabled then
        ReplicatedStorage.ToggleHighlight:FireServer(isHighlightEnabled, {
            Color = currentColor,
            Transparency = currentTransparency
        })
    end
end

transparencySlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
    end
end)

transparencySlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local xPos = input.Position.X - transparencySlider.AbsolutePosition.X
        local percent = math.clamp(xPos / transparencySlider.AbsoluteSize.X, 0, 1)
        updateTransparency(1 - percent)
    end
end)

-- Make UI draggable
local isDraggingUI = false
local dragStart, frameStart

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingUI = true
        dragStart = input.Position
        frameStart = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDraggingUI = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingUI and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
        shadow.Position = mainFrame.Position - UDim2.new(0, 15, 0, 10)
    end
end)

-- Keybind to open/close UI (F6 key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F6 then
        screenGui.Enabled = not screenGui.Enabled
        
        if screenGui.Enabled then
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            local tween = TweenService:Create(mainFrame, tweenInfo, {
                Size = UDim2.new(0, 350, 0, 200),
                Position = UDim2.new(0.5, -175, 0.5, -100)
            })
            tween:Play()
        end
    end
end)

-- Initialize UI
updateToggleButton()
updateTransparency(currentTransparency)

print("Highlight UI loaded! Press F6 to open.")
