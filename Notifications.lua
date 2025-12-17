-- Modern Notification System
-- notifications.lua - Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create notification system
local notificationScreen = Instance.new("ScreenGui")
notificationScreen.Name = "NotificationSystem"
notificationScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notificationScreen.ResetOnSpawn = false

-- Notification container
local notificationContainer = Instance.new("Frame")
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.new(0, 350, 1, -100)
notificationContainer.Position = UDim2.new(1, -370, 0, 50)
notificationContainer.AnchorPoint = Vector2.new(1, 0)
notificationContainer.BackgroundTransparency = 1

-- Active notifications
local activeNotifications = {}
local maxNotifications = 5

-- Notification types
local NotificationTypes = {
    Info = {
        Color = Color3.fromRGB(100, 200, 255),
        Icon = "rbxassetid://3926305904",
        IconRect = Vector2.new(124, 124)
    },
    Success = {
        Color = Color3.fromRGB(80, 255, 140),
        Icon = "rbxassetid://3926305904",
        IconRect = Vector2.new(924, 724)
    },
    Warning = {
        Color = Color3.fromRGB(255, 214, 0),
        Icon = "rbxassetid://3926305904",
        IconRect = Vector2.new(644, 204)
    },
    Error = {
        Color = Color3.fromRGB(255, 82, 82),
        Icon = "rbxassetid://3926305904",
        IconRect = Vector2.new(844, 444)
    },
    Highlight = {
        Color = Color3.fromRGB(255, 94, 247),
        Icon = "rbxassetid://3926305904",
        IconRect = Vector2.new(124, 204)
    }
}

-- Create notification function
local function createNotification(title, message, notificationType, duration)
    duration = duration or 5
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 80)
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = notificationType.Color
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = notification
    
    -- Accent bar
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, -16)
    accent.Position = UDim2.new(0, 8, 0, 8)
    accent.BackgroundColor3 = notificationType.Color
    accent.BorderSizePixel = 0
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accent
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 32, 0, 32)
    icon.Position = UDim2.new(0, 20, 0.5, -16)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = notificationType.Icon
    icon.ImageRectOffset = notificationType.IconRect
    icon.ImageRectSize = Vector2.new(36, 36)
    icon.ImageColor3 = notificationType.Color
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -70, 0, 25)
    titleLabel.Position = UDim2.new(0, 60, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -70, 0, 35)
    messageLabel.Position = UDim2.new(0, 60, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Close button
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -30, 0, 15)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = Color3.fromRGB(150, 150, 150)
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, -16, 0, 2)
    progressBar.Position = UDim2.new(0, 8, 1, -8)
    progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    progressBar.BorderSizePixel = 0
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBar
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = notificationType.Color
    progressFill.BorderSizePixel = 0
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(1, 0)
    progressFillCorner.Parent = progressFill
    
    -- Assemble notification
    progressFill.Parent = progressBar
    progressBar.Parent = notification
    closeButton.Parent = notification
    messageLabel.Parent = notification
    titleLabel.Parent = notification
    icon.Parent = notification
    accent.Parent = notification
    
    -- Add to container
    notification.Parent = notificationContainer
    
    -- Calculate position (stack from bottom)
    local position = #activeNotifications * 85
    notification.Position = UDim2.new(0, 0, 1, position + 85)
    
    -- Add to active notifications
    table.insert(activeNotifications, notification)
    
    -- Slide in animation
    local slideIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 1, position)
    })
    slideIn:Play()
    
    -- Progress bar animation
    local progressTween = TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, 0, 1, 0)
    })
    progressTween:Play()
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        removeNotification(notification)
    end)
    
    -- Auto-remove after duration
    local removeThread = coroutine.create(function()
        task.wait(duration)
        removeNotification(notification)
    end)
    coroutine.resume(removeThread)
    
    -- Update positions of other notifications
    updateNotificationPositions()
    
    return notification
end

-- Remove notification
local function removeNotification(notification)
    for i, notif in ipairs(activeNotifications) do
        if notif == notification then
            table.remove(activeNotifications, i)
            break
        end
    end
    
    -- Slide out animation
    local slideOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 1, notification.Position.Y.Offset + 100),
        BackgroundTransparency = 1
    })
    slideOut:Play()
    
    slideOut.Completed:Wait()
    if notification.Parent then
        notification:Destroy()
    end
    
    -- Update positions
    updateNotificationPositions()
end

-- Update notification positions
local function updateNotificationPositions()
    for i, notification in ipairs(activeNotifications) do
        local position = (i - 1) * 85
        TweenService:Create(notification, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 1, position)
        }):Play()
    end
end

-- Show notification function
local function showNotification(title, message, notificationType, duration)
    if #activeNotifications >= maxNotifications then
        removeNotification(activeNotifications[1])
    end
    
    local typeData = NotificationTypes[notificationType] or NotificationTypes.Info
    createNotification(title, message, typeData, duration)
end

-- Listen for highlight events
local highlightRemote = ReplicatedStorage:WaitForChild("HighlightToggle")

highlightRemote.OnClientEvent:Connect(function(action, data)
    if action == "Enabled" then
        showNotification("Highlights Enabled", data.Message, "Success", 3)
        
        -- Play sound
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://3570574874"
        sound.Volume = 0.5
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
        
    elseif action == "Disabled" then
        showNotification("Highlights Disabled", data.Message, "Info", 3)
        
        -- Play sound
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://3570574874"
        sound.Volume = 0.3
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end
end)

-- Test notifications (remove in production)
local function testNotifications()
    showNotification("Welcome!", "Press F3 to open Highlight Settings", "Info", 5)
    
    task.wait(2)
    showNotification("System Ready", "Highlight system initialized successfully", "Success", 4)
    
    task.wait(3)
    showNotification("Tip", "Adjust transparency for better visibility", "Highlight", 4)
end

-- Initialize
notificationContainer.Parent = notificationScreen
notificationScreen.Parent = playerGui

-- Start test notifications
task.wait(2)
testNotifications()

-- Export function
_G.ShowNotification = showNotification

print("Notification System loaded!")
