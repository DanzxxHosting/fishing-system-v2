repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

_G.Version = "Ultimate v3.0 - Fixed"

-- Simple config
local config = {
    autoFishing = true,
    instantFishing = true,
    fishingDelay = 0.1,
    blantantMode = false
}

local stats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0
}

local fishingActive = false
local fishingConnection

-- Create basic UI
local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaitunFishUI"
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ KAITUN FISH IT - " .. _G.Version
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 15, 0, 45)
Status.Size = UDim2.new(1, -30, 0, 25)
Status.Font = Enum.Font.Gotham
Status.Text = "🟢 Ready to start..."
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 80)
Container.Size = UDim2.new(1, -20, 1, -90)
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout")
UIList.Parent = Container
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Simple fishing function
local function TryFishing()
    stats.attempts = stats.attempts + 1
    
    -- Coba berbagai remote event
    local remotes = {}
    
    -- Cari di ReplicatedStorage
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            if name:find("fish") or name:find("catch") or name:find("rod") then
                table.insert(remotes, obj)
            end
        end
    end
    
    -- Coba fire remote events
    for _, remote in pairs(remotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("CatchFish")
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer("CatchFish")
            end
        end)
    end
    
    -- Simulasi klik
    pcall(function()
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
    
    -- Simulasi tombol E
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    
    stats.fishCaught = stats.fishCaught + 1
    return true
end

-- Start fishing function
local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    Status.Text = "🟢 Fishing started..."
    Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    
    print("🚀 Starting Kaitun Fishing...")
    
    fishingConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = TryFishing()
        
        if success then
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            Status.Text = string.format("🟢 Fish: %d | %.2f/s", stats.fishCaught, rate)
        end
        
        task.wait(config.fishingDelay)
    end)
end

-- Stop fishing function
local function StopFishing()
    fishingActive = false
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    Status.Text = "🔴 Fishing stopped"
    Status.TextColor3 = Color3.fromRGB(255, 70, 70)
    print("🔴 Fishing stopped")
end

-- UI Creation functions
local function CreateSection(text)
    local section = Instance.new("TextLabel")
    section.Parent = Container
    section.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    section.BackgroundTransparency = 0.9
    section.Size = UDim2.new(0.95, 0, 0, 35)
    section.Font = Enum.Font.GothamBold
    section.Text = text
    section.TextColor3 = Color3.fromRGB(255, 255, 255)
    section.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    return section
end

local function CreateButton(name, desc, callback)
    local button = Instance.new("TextButton")
    button.Parent = Container
    button.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    button.Size = UDim2.new(0.95, 0, 0, 50)
    button.Font = Enum.Font.GothamBold
    button.Text = ""
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Parent = button
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 8)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local description = Instance.new("TextLabel")
    description.Parent = button
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 10, 0, 28)
    description.Size = UDim2.new(1, -20, 0, 18)
    description.Font = Enum.Font.Gotham
    description.Text = desc
    description.TextColor3 = Color3.fromRGB(200, 210, 220)
    description.TextSize = 10
    description.TextXAlignment = Enum.TextXAlignment.Left
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function CreateToggle(name, desc, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = Container
    frame.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
    frame.Size = UDim2.new(0.95, 0, 0, 60)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 8)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local description = Instance.new("TextLabel")
    description.Parent = frame
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 10, 0, 32)
    description.Size = UDim2.new(0.6, 0, 0, 20)
    description.Font = Enum.Font.Gotham
    description.Text = desc
    description.TextColor3 = Color3.fromRGB(180, 190, 200)
    description.TextSize = 10
    description.TextXAlignment = Enum.TextXAlignment.Left
    
    local button = Instance.new("TextButton")
    button.Parent = frame
    button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
    button.Position = UDim2.new(0.75, 0, 0.25, 0)
    button.Size = UDim2.new(0.2, 0, 0.5, 0)
    button.Font = Enum.Font.GothamBold
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    button.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        callback(new)
    end)
    
    return frame
end

-- Build UI
CreateSection("🎯 FISHING CONTROLS")

local startBtn = CreateButton("🚀 START FISHING", "Click to start auto fishing", function()
    if fishingActive then
        StopFishing()
        startBtn:FindFirstChild("TextLabel").Text = "🚀 START FISHING"
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    else
        StartFishing()
        startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
        startBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    end
end)

CreateSection("⚡ SETTINGS")

CreateToggle("Instant Fishing", "Fast fishing mode", config.instantFishing, function(v)
    config.instantFishing = v
    config.fishingDelay = v and 0.05 or 0.2
    print("⚡ Instant Fishing: " .. tostring(v))
end)

CreateToggle("Blantant Mode", "ULTRA FAST fishing", config.blantantMode, function(v)
    config.blantantMode = v
    if v then
        config.fishingDelay = 0.02
        config.instantFishing = true
        Status.Text = "💥 BLASTANT MODE - ULTRA FAST"
        Status.TextColor3 = Color3.fromRGB(255, 50, 50)
        print("💥 BLASTANT MODE ACTIVATED!")
    else
        config.fishingDelay = 0.15
        Status.Text = "🔵 Normal Mode"
        Status.TextColor3 = Color3.fromRGB(0, 255, 100)
        print("🔵 Normal Mode")
    end
end)

CreateSection("📊 STATISTICS")

local fishLabel = Instance.new("TextLabel")
fishLabel.Parent = Container
fishLabel.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
fishLabel.Size = UDim2.new(0.95, 0, 0, 35)
fishLabel.Font = Enum.Font.GothamBold
fishLabel.Text = "🎣 Fish Caught: 0"
fishLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fishLabel.TextSize = 13

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Parent = Container
attemptsLabel.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
attemptsLabel.Size = UDim2.new(0.95, 0, 0, 35)
attemptsLabel.Font = Enum.Font.GothamBold
attemptsLabel.Text = "🔄 Attempts: 0"
attemptsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
attemptsLabel.TextSize = 13

local rateLabel = Instance.new("TextLabel")
rateLabel.Parent = Container
rateLabel.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
rateLabel.Size = UDim2.new(0.95, 0, 0, 35)
rateLabel.Font = Enum.Font.GothamBold
rateLabel.Text = "⚡ Rate: 0.00/s"
rateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rateLabel.TextSize = 13

-- Update stats
task.spawn(function()
    while task.wait(0.5) do
        local elapsed = math.max(1, tick() - stats.startTime)
        local rate = stats.fishCaught / elapsed
        
        fishLabel.Text = "🎣 Fish Caught: " .. stats.fishCaught
        attemptsLabel.Text = "🔄 Attempts: " .. stats.attempts
        rateLabel.Text = string.format("⚡ Rate: %.2f/s", rate)
    end
end)

-- Auto start
task.wait(2)
if config.autoFishing then
    StartFishing()
    startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
    startBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
end

print("✅ Kaitun Fish It Loaded Successfully!")
print("🎣 Version: " .. _G.Version)
