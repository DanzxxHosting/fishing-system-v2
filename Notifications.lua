-- Simple Notification System
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create notification UI
local notificationScreen = Instance.new("ScreenGui")
notificationScreen.Name = "Notifications"
notificationScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notificationScreen.ResetOnSpawn = false

-- Notification template
local function createNotification(title, message, color)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.AnchorPoint = Vector2.new(1, 1)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local shadow = Instance.new("ImageLabel")
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, -10, 0.5, -10)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Parent = notification
    shadow.ZIndex = -1
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    
    accent.Parent = notification
    titleLabel.Parent = notification
    messageLabel.Parent = notification
    notification.Parent = notificationScreen
    
    -- Animate in
    notification.Position = UDim2.new(1, 20, 1, -100)
    
    local slideIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 1, -100)
    })
    
    slideIn:Play()
    
    -- Auto remove after 5 seconds
    task.wait(5)
    
    local slideOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, 20, 1, -100)
    })
    
    slideOut:Play()
    slideOut.Completed:Wait()
    notification:Destroy()
end

notificationScreen.Parent = playerGui

-- Function to show notifications
local function showNotification(title, message, color)
    color = color or Color3.fromRGB(60, 160, 255)
    createNotification(title, message, color)
end

-- Listen for highlight toggles
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local highlightRemote = ReplicatedStorage:WaitForChild("HighlightToggle")

-- Store last state to detect changes
local lastHighlightState = false

-- Check for changes periodically
while true do
    task.wait(0.5)
    
    -- This would be connected to actual highlight state
    -- For now, we'll just show a notification when T is pressed
end

-- Export function
_G.ShowNotification = showNotification
