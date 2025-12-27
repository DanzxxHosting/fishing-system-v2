-- 📁 ReplicatedStorage/NotifySystem.lua
-- 🔔 Notification System khusus Fish Atelier

local NotifySystem = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local notificationQueue = {}
local isShowingNotification = false
local notificationContainer = nil

-- Configuration
local CONFIG = {
    MAX_NOTIFICATIONS = 5,
    DEFAULT_DURATION = 3,
    FADE_TIME = 0.3,
    SLIDE_DISTANCE = 100,
    ENABLE_SOUNDS = true,
    SOUND_VOLUME = 0.5
}

-- Notification types
local NOTIFICATION_TYPES = {
    SUCCESS = {
        Color = Color3.fromRGB(100, 255, 100),
        Icon = "✅",
        Sound = "rbxassetid://3578733456" -- Success sound
    },
    INFO = {
        Color = Color3.fromRGB(100, 150, 255),
        Icon = "ℹ️",
        Sound = "rbxassetid://3578733457" -- Info sound
    },
    WARNING = {
        Color = Color3.fromRGB(255, 200, 100),
        Icon = "⚠️",
        Sound = "rbxassetid://3578733458" -- Warning sound
    },
    ERROR = {
        Color = Color3.fromRGB(255, 100, 100),
        Icon = "❌",
        Sound = "rbxassetid://3578733459" -- Error sound
    },
    FISHING = {
        Color = Color3.fromRGB(0, 200, 255),
        Icon = "🎣",
        Sound = "rbxassetid://3578733460" -- Fishing sound
    },
    SELL = {
        Color = Color3.fromRGB(255, 150, 50),
        Icon = "💰",
        Sound = "rbxassetid://3578733461" -- Coin sound
    },
    DIVING = {
        Color = Color3.fromRGB(50, 150, 255),
        Icon = "🤿",
        Sound = "rbxassetid://3578733462" -- Bubble sound
    },
    RADAR = {
        Color = Color3.fromRGB(150, 50, 255),
        Icon = "📡",
        Sound = "rbxassetid://3578733463" -- Radar sound
    },
    TOTEM = {
        Color = Color3.fromRGB(255, 100, 150),
        Icon = "🗿",
        Sound = "rbxassetid://3578733464" -- Magic sound
    }
}

-- Statistics
local stats = {
    totalNotifications = 0,
    notificationsToday = 0,
    lastNotification = nil
}

function NotifySystem.Initialize()
    print("🔔 Initializing Fish Atelier Notification System...")
    
    -- Create notification container
    if playerGui:FindFirstChild("NotificationContainer") then
        playerGui.NotificationContainer:Destroy()
    end
    
    notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "NotificationContainer"
    notificationContainer.Size = UDim2.new(0, 350, 1, 0)
    notificationContainer.Position = UDim2.new(1, -360, 0, 20)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = playerGui
    
    -- Reset daily stats at midnight
    spawn(function()
        while true do
            local now = os.time()
            local tomorrow = os.time{
                year = os.date("%Y"),
                month = os.date("%m"),
                day = os.date("%d") + 1
            }
            local secondsUntilMidnight = tomorrow - now
            
            task.wait(secondsUntilMidnight)
            stats.notificationsToday = 0
            print("📅 Daily notifications reset")
        end
    end)
    
    print("✅ Notification System Ready")
end

function NotifySystem.Send(title, message, duration, notifType)
    -- Default values
    duration = duration or CONFIG.DEFAULT_DURATION
    notifType = notifType or "INFO"
    
    -- Get notification type config
    local typeConfig = NOTIFICATION_TYPES[notifType:upper()] or NOTIFICATION_TYPES.INFO
    
    -- Add to queue
    table.insert(notificationQueue, {
        title = title,
        message = message,
        duration = duration,
        type = typeConfig,
        timestamp = tick()
    })
    
    -- Update stats
    stats.totalNotifications = stats.totalNotifications + 1
    stats.notificationsToday = stats.notificationsToday + 1
    stats.lastNotification = title
    
    -- Process queue
    if not isShowingNotification then
        NotifySystem.ProcessQueue()
    end
    
    return #notificationQueue
end

function NotifySystem.ProcessQueue()
    if isShowingNotification or #notificationQueue == 0 then
        return
    end
    
    isShowingNotification = true
    
    while #notificationQueue > 0 do
        local notification = table.remove(notificationQueue, 1)
        NotifySystem.ShowNotification(notification)
        
        -- Wait for notification to complete plus a small gap
        task.wait(notification.duration + 0.5)
    end
    
    isShowingNotification = false
end

function NotifySystem.ShowNotification(notification)
    -- Create notification frame
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notification_" .. stats.totalNotifications
    notifFrame.Size = UDim2.new(0, 320, 0, 0)
    notifFrame.Position = UDim2.new(1, -340, 1, -20)
    notifFrame.AnchorPoint = Vector2.new(1, 1)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notifFrame.BackgroundTransparency = 0.1
    notifFrame.BorderSizePixel = 0
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = notificationContainer
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notifFrame
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = notification.type.Color
    stroke.Thickness = 2
    stroke.Parent = notifFrame
    
    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8992236561"
    glow.ImageColor3 = notification.type.Color
    glow.ImageTransparency = 0.8
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(256, 256, 256, 256)
    glow.Parent = notifFrame
    glow.ZIndex = -1
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = notification.type.Color
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Parent = notifFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    headerCorner.Parent = header
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 5)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 20
    icon.Text = notification.type.Icon
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 50, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Text = notification.title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Time label
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 60, 0, 15)
    timeLabel.Position = UDim2.new(1, -65, 0, 5)
    timeLabel.AnchorPoint = Vector2.new(1, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 10
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = header
    
    -- Message content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = notifFrame
    
    -- Message text
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.Text = notification.message
    messageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = content
    
    -- Calculate required height
    local textHeight = messageLabel.TextBounds.Y
    local contentHeight = math.min(textHeight + 10, 150)
    local totalHeight = 45 + contentHeight + 10
    
    -- Resize frames
    content.Size = UDim2.new(1, -20, 0, contentHeight)
    messageLabel.Size = UDim2.new(1, 0, 0, textHeight)
    notifFrame.Size = UDim2.new(0, 320, 0, totalHeight)
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = notification.type.Color
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notifFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 0, 0, 8)
    progressCorner.Parent = progressBar
    
    -- Play sound if enabled
    if CONFIG.ENABLE_SOUNDS and notification.type.Sound then
        local sound = Instance.new("Sound")
        sound.SoundId = notification.type.Sound
        sound.Volume = CONFIG.SOUND_VOLUME
        sound.Parent = notifFrame
        sound:Play()
        
        task.wait(sound.TimeLength)
        sound:Destroy()
    end
    
    -- Animation: Slide in
    notifFrame.Position = UDim2.new(1, 340, 1, -20)
    
    local slideIn = TweenService:Create(notifFrame,
        TweenInfo.new(CONFIG.FADE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -340, 1, -20)}
    )
    slideIn:Play()
    
    -- Progress animation
    local progressTween = TweenService:Create(progressBar,
        TweenInfo.new(notification.duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 3)}
    )
    progressTween:Play()
    
    -- Wait for duration
    task.wait(notification.duration)
    
    -- Animation: Slide out
    local slideOut = TweenService:Create(notifFrame,
        TweenInfo.new(CONFIG.FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 340, 1, -20)}
    )
    slideOut:Play()
    
    slideOut.Completed:Wait()
    notifFrame:Destroy()
end

function NotifySystem.QuickNotify(title, message, notifType)
    return NotifySystem.Send(title, message, 2, notifType)
end

function NotifySystem.ClearAll()
    for _, child in ipairs(notificationContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Notification") then
            child:Destroy()
        end
    end
    
    notificationQueue = {}
    print("🗑️ All notifications cleared")
end

function NotifySystem.GetStats()
    return {
        total = stats.totalNotifications,
        today = stats.notificationsToday,
        queue = #notificationQueue,
        last = stats.lastNotification
    }
end

-- Metatable untuk shortcut Notify(...)
setmetatable(NotifySystem, {
    __call = function(self, ...)
        return self.Send(...)
    end
})

-- Auto initialize
spawn(function()
    task.wait(2)
    NotifySystem.Initialize()
end)

return NotifySystem