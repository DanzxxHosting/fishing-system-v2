-- Bikinkan Fish It Script - Like Video Version
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Configuration
local config = {
    Enabled = false,
    Speed = 20,
    AutoCast = true,
    AutoReel = true
}

-- Fishing Variables
local fishingConnection
local isFishing = false

-- Simple UI Library
local BikinkanUI = {}
BikinkanUI.Themes = {
    Dark = {
        Main = Color3.fromRGB(30, 30, 40),
        Secondary = Color3.fromRGB(40, 40, 50),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(180, 180, 180)
    }
}

local currentTheme = BikinkanUI.Themes.Dark

function BikinkanUI:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local Container = Instance.new("Frame")
    local Content = Instance.new("ScrollingFrame")
    local ContentList = Instance.new("UIListLayout")
    
    -- ScreenGui
    ScreenGui.Name = "FishItGUI"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = currentTheme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Top Bar
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = currentTheme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    
    -- Title
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎣 " .. name
    Title.TextColor3 = currentTheme.Text
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.9, 0, 0.2, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = currentTheme.Text
    CloseButton.TextSize = 12
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Container
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.BackgroundColor3 = currentTheme.Main
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 0, 0.114, 0)
    Container.Size = UDim2.new(1, 0, 0.886, 0)
    
    -- Content
    Content.Name = "Content"
    Content.Parent = Container
    Content.Active = true
    Content.BackgroundColor3 = currentTheme.Main
    Content.BorderSizePixel = 0
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.CanvasSize = UDim2.new(0, 0, 2, 0)
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = currentTheme.Accent
    
    ContentList.Parent = Content
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 10)
    
    local tabs = {}
    
    function tabs:CreateSection(title)
        local Section = Instance.new("Frame")
        local SectionTitle = Instance.new("TextLabel")
        
        Section.Name = "Section"
        Section.Parent = Content
        Section.BackgroundColor3 = currentTheme.Secondary
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(0.95, 0, 0, 40)
        
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0.05, 0, 0, 0)
        SectionTitle.Size = UDim2.new(0.9, 0, 1, 0)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = title
        SectionTitle.TextColor3 = currentTheme.Text
        SectionTitle.TextSize = 14
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        return Section
    end
    
    function tabs:CreateToggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        
        ToggleFrame.Parent = Content
        ToggleFrame.BackgroundColor3 = currentTheme.Secondary
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.95, 0, 0, 40)
        
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = currentTheme.Text
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.85, 0, 0.2, 0)
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = currentTheme.Text
        ToggleButton.TextSize = 10
        
        ToggleButton.MouseButton1Click:Connect(function()
            local newValue = not (ToggleButton.Text == "ON")
            ToggleButton.BackgroundColor3 = newValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            ToggleButton.Text = newValue and "ON" or "OFF"
            callback(newValue)
        end)
        
        return ToggleFrame
    end
    
    function tabs:CreateSlider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        local SliderLabel = Instance.new("TextLabel")
        local SliderValue = Instance.new("TextLabel")
        local SliderBar = Instance.new("Frame")
        local SliderFill = Instance.new("Frame")
        local SliderButton = Instance.new("TextButton")
        
        SliderFrame.Parent = Content
        SliderFrame.BackgroundColor3 = currentTheme.Secondary
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(0.95, 0, 0, 60)
        
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
        SliderLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = name
        SliderLabel.TextColor3 = currentTheme.Text
        SliderLabel.TextSize = 13
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderValue.Parent = SliderFrame
        SliderValue.BackgroundTransparency = 1
        SliderValue.Position = UDim2.new(0.7, 0, 0.1, 0)
        SliderValue.Size = UDim2.new(0.25, 0, 0.3, 0)
        SliderValue.Font = Enum.Font.GothamBold
        SliderValue.Text = tostring(default)
        SliderValue.TextColor3 = currentTheme.Accent
        SliderValue.TextSize = 13
        
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = currentTheme.Main
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
        SliderBar.Size = UDim2.new(0.9, 0, 0.2, 0)
        
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = currentTheme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        SliderButton.Parent = SliderBar
        SliderButton.BackgroundColor3 = currentTheme.Text
        SliderButton.BorderSizePixel = 0
        SliderButton.Position = UDim2.new((default - min) / (max - min), -6, 0, -3)
        SliderButton.Size = UDim2.new(0, 12, 0, 12)
        SliderButton.Font = Enum.Font.Gotham
        SliderButton.Text = ""
        SliderButton.ZIndex = 2
        
        local dragging = false
        
        local function updateSlider(input)
            local pos = UDim2.new(
                math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1),
                0, 1, 0
            )
            SliderFill.Size = pos
            SliderButton.Position = UDim2.new(pos.X.Scale, -6, 0, -3)
            local value = math.floor(min + (pos.X.Scale * (max - min)))
            SliderValue.Text = tostring(value)
            callback(value)
        end
        
        SliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        SliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        return SliderFrame
    end
    
    function tabs:CreateLabel(text)
        local Label = Instance.new("TextLabel")
        
        Label.Parent = Content
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.95, 0, 0, 30)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = currentTheme.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        return Label
    end
    
    return tabs
end

-- Fishing Functions
function findFishingEvent()
    -- Cari RemoteEvent fishing di berbagai lokasi
    local locations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Workspace"),
        player:FindFirstChild("PlayerScripts")
    }
    
    for _, location in pairs(locations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local name = string.lower(obj.Name)
                    if name:find("fish") or name:find("catch") or name:find("rod") then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

function performFishing()
    if isFishing then return false end
    
    isFishing = true
    local success = false
    
    -- Method 1: Coba fishing event
    local fishingEvent = findFishingEvent()
    if fishingEvent then
        local methods = {"CatchFish", "Fish", "StartFishing", "CompleteFishing"}
        for _, method in pairs(methods) do
            local ok = pcall(function()
                fishingEvent:FireServer(method)
            end)
            if ok then
                success = true
                break
            end
        end
    end
    
    -- Method 2: Mouse click fallback
    if not success then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            success = true
        end)
    end
    
    isFishing = false
    return success
end

function startAutoFishing()
    if fishingConnection then
        fishingConnection:Disconnect()
    end
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if config.Enabled and not isFishing then
            for i = 1, config.Speed do
                performFishing()
                if i < config.Speed then
                    wait(0.01)
                end
            end
            wait(0.1)
        end
    end)
end

function stopAutoFishing()
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    isFishing = false
end

-- Initialize UI
local Window = BikinkanUI:CreateWindow("Fish It")

-- Main Toggles
Window:CreateSection("Main Settings")

Window:CreateToggle("Enabled", config.Enabled, function(value)
    config.Enabled = value
    if value then
        startAutoFishing()
        print("✅ Auto Fishing Enabled")
    else
        stopAutoFishing()
        print("❌ Auto Fishing Disabled")
    end
end)

Window:CreateToggle("Auto Cast", config.AutoCast, function(value)
    config.AutoCast = value
    print("Auto Cast:", value)
end)

Window:CreateToggle("Auto Reel", config.AutoReel, function(value)
    config.AutoReel = value
    print("Auto Reel:", value)
end)

Window:CreateSection("Fishing Speed")

Window:CreateSlider("Speed", 1, 50, config.Speed, function(value)
    config.Speed = value
    print("Fishing Speed:", value)
end)

Window:CreateSection("Information")
Window:CreateLabel("Script by Bikinkan")
Window:CreateLabel("Like the video version")
Window:CreateLabel("Simple and Effective")

print("🎣 Fish It Script Loaded!")
print("✅ Like the video version")
print("🚀 Simple and effective auto fishing")
