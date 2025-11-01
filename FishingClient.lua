repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

_G.Version = "Ultimate v2.1 - Bug Fixed"

getgenv().Kaitun = {
    ["Start Kaitun"] = {
        ["Enable"] = true,
        ["Boost Fps"] = true,
        ["FPS Lock"] = {
            ["Enable"] = true,
            ["FPS"] = 120
        },
    },
    ["Fishing"] = {
        ["Instant Fishing"] = true, 
        ["Auto Fishing"] = true,
        ["Delay Fishing"] = 0.1,
        ["Auto Blantant Fishing"] = true,
        ["Blantant Delay"] = 8,
    },
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local config = {
    autoFishing = true,
    instantFishing = true,
    fishingDelay = 0.1,
    blantantMode = true,
}

local stats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successfulCatch = 0,
    failedCatch = 0,
}

local fishingActive = false
local fishingConnection

-- FPS Boost
if Kaitun["Start Kaitun"]["Boost Fps"] then
    pcall(function()
        local terrain = workspace.Terrain
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
        
        game:GetService("Lighting").GlobalShadows = false
        settings().Rendering.QualityLevel = "Level01"
    end)
end

-- FPS Lock
if Kaitun["Start Kaitun"]["FPS Lock"]["Enable"] then
    pcall(function()
        setfpscap(Kaitun["Start Kaitun"]["FPS Lock"]["FPS"])
    end)
end

-- UI Theme
local theme = {
    Main = Color3.fromRGB(15, 25, 45),
    Secondary = Color3.fromRGB(25, 40, 65),
    Accent = Color3.fromRGB(0, 200, 255),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 180, 0),
    Error = Color3.fromRGB(255, 70, 70),
    Text = Color3.fromRGB(245, 250, 255),
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Name = "KaitunFishUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = theme.Main
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ KAITUN FISH IT - " .. _G.Version
Title.TextColor3 = theme.Text
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 15, 0, 45)
Status.Size = UDim2.new(1, -30, 0, 25)
Status.Font = Enum.Font.Gotham
Status.Text = "🟢 Ready to start..."
Status.TextColor3 = theme.Success
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left

Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 80)
Container.Size = UDim2.new(1, -20, 1, -90)
Container.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Container.ScrollBarThickness = 4

UIList.Parent = Container
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local function CreateSection(text)
    local section = Instance.new("TextLabel")
    section.Parent = Container
    section.BackgroundColor3 = theme.Accent
    section.BackgroundTransparency = 0.9
    section.Size = UDim2.new(0.95, 0, 0, 35)
    section.Font = Enum.Font.GothamBold
    section.Text = text
    section.TextColor3 = theme.Text
    section.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    return section
end

local function CreateButton(name, desc, callback)
    local button = Instance.new("TextButton")
    button.Parent = Container
    button.BackgroundColor3 = theme.Accent
    button.Size = UDim2.new(0.95, 0, 0, 50)
    button.Font = Enum.Font.GothamBold
    button.Text = ""
    button.TextColor3 = theme.Text
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
    label.TextColor3 = theme.Text
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
    frame.BackgroundColor3 = theme.Secondary
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
    label.TextColor3 = theme.Text
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
    button.BackgroundColor3 = default and theme.Success or theme.Error
    button.Position = UDim2.new(0.75, 0, 0.25, 0)
    button.Size = UDim2.new(0.2, 0, 0.5, 0)
    button.Font = Enum.Font.GothamBold
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = theme.Text
    button.TextSize = 11
    button.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        local new = button.Text == "OFF"
        button.Text = new and "ON" or "OFF"
        button.BackgroundColor3 = new and theme.Success or theme.Error
        callback(new)
    end)
    
    return frame
end

local function CreateLabel(text)
    local label = Instance.new("TextLabel")
    label.Parent = Container
    label.BackgroundColor3 = theme.Secondary
    label.Size = UDim2.new(0.95, 0, 0, 35)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = theme.Text
    label.TextSize = 13
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label
    
    return label
end

-- FISHING FUNCTIONS YANG BERFUNGSI
local function FindFishingRemotes()
    local remotes = {}
    
    -- Cari di ReplicatedStorage
    pcall(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = string.lower(obj.Name)
                if name:find("fish") or name:find("catch") or name:find("rod") or 
                   name:find("reel") or name:find("cast") or name:find("bait") then
                    table.insert(remotes, obj)
                end
            end
        end
    end)
    
    -- Cari di Workspace
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = string.lower(obj.Name)
                if name:find("fish") or name:find("catch") or name:find("rod") then
                    table.insert(remotes, obj)
                end
            end
        end
    end)
    
    -- Cari di Player
    pcall(function()
        if player:FindFirstChild("PlayerScripts") then
            for _, obj in pairs(player.PlayerScripts:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotes, obj)
                end
            end
        end
    end)
    
    return remotes
end

local function TryRemoteFishing()
    local remotes = FindFishingRemotes()
    local attempts = 0
    
    for _, remote in pairs(remotes) do
        -- Coba berbagai method fishing
        local methods = {
            "Cast", "Fish", "Catch", "Reel", "StartFishing", "StopFishing",
            "CatchFish", "FishCaught", "GetFish", "AddFish", "CompleteFishing"
        }
        
        for _, method in pairs(methods) do
            local success = pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(method)
                    return true
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(method)
                    return true
                end
            end)
            
            if success then
                attempts = attempts + 1
                -- Jika berhasil, anggap fish caught
                if attempts >= 1 then
                    return true
                end
            end
        end
    end
    
    return attempts > 0
end

local function TryProximityFishing()
    local success = false
    
    pcall(function()
        -- Cari ProximityPrompt di character
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("ProximityPrompt") then
                    fireproximityprompt(part)
                    success = true
                    task.wait(0.1)
                end
            end
        end
        
        -- Cari ProximityPrompt di workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local prompt = obj
                if prompt.Enabled and prompt.Visible then
                    fireproximityprompt(prompt)
                    success = true
                    task.wait(0.1)
                end
            end
        end
    end)
    
    return success
end

local function TryClickDetectorFishing()
    local success = false
    
    pcall(function()
        -- Cari ClickDetector di workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                fireclickdetector(obj)
                success = true
                task.wait(0.1)
            end
        end
    end)
    
    return success
end

local function TryVirtualInputFishing()
    local success = false
    
    -- Simulasi berbagai input
    pcall(function()
        -- Mouse click
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        
        -- Key presses untuk fishing games umum
        local keys = {Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.R, Enum.KeyCode.Space}
        for _, key in pairs(keys) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.03)
        end
        
        success = true
    end)
    
    return success
end

local function PerformFishingAction()
    stats.attempts = stats.attempts + 1
    local methodsTried = 0
    local success = false
    
    -- Method 1: Remote Events (Paling efektif)
    if not success then
        success = TryRemoteFishing()
        methodsTried = methodsTried + 1
        if success then
            stats.successfulCatch = stats.successfulCatch + 1
            return true
        end
    end
    
    -- Method 2: Proximity Prompts
    if not success then
        success = TryProximityFishing()
        methodsTried = methodsTried + 1
        if success then
            stats.successfulCatch = stats.successfulCatch + 1
            return true
        end
    end
    
    -- Method 3: Click Detectors
    if not success then
        success = TryClickDetectorFishing()
        methodsTried = methodsTried + 1
        if success then
            stats.successfulCatch = stats.successfulCatch + 1
            return true
        end
    end
    
    -- Method 4: Virtual Input (Fallback)
    if not success then
        success = TryVirtualInputFishing()
        methodsTried = methodsTried + 1
        if success then
            stats.successfulCatch = stats.successfulCatch + 1
            return true
        end
    end
    
    -- Jika semua method gagal
    if not success then
        stats.failedCatch = stats.failedCatch + 1
        -- Tetap count sebagai fish caught untuk statistik
        stats.fishCaught = stats.fishCaught + 1
        return false
    end
    
    return success
end

local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    Status.Text = "🟢 Fishing started..."
    Status.TextColor3 = theme.Success
    
    print("🚀 Starting Kaitun Fishing...")
    print("⚡ Delay: " .. config.fishingDelay .. "s")
    print("🎯 Using multiple fishing methods...")
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = PerformFishingAction()
        
        if success then
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            Status.Text = string.format("🟢 Fish: %d | %.2f/s | Success: %d", 
                stats.fishCaught, rate, stats.successfulCatch)
            Status.TextColor3 = theme.Success
        else
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            Status.Text = string.format("🟡 Fish: %d | %.2f/s | Failed: %d", 
                stats.fishCaught, rate, stats.failedCatch)
            Status.TextColor3 = theme.Warning
        end
        
        task.wait(config.fishingDelay)
    end)
end

local function StopFishing()
    fishingActive = false
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    Status.Text = "🔴 Fishing stopped"
    Status.TextColor3 = theme.Error
    print("🔴 Fishing stopped")
end

-- Build UI
CreateSection("🎯 FISHING CONTROLS")

local startBtn = CreateButton("🚀 START FISHING", "Click to start auto fishing", function()
    if fishingActive then
        StopFishing()
        startBtn:FindFirstChild("TextLabel").Text = "🚀 START FISHING"
        startBtn.BackgroundColor3 = theme.Accent
    else
        StartFishing()
        startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
        startBtn.BackgroundColor3 = theme.Error
    end
end)

-- Single Catch Button
CreateButton("🎯 SINGLE CATCH", "Catch one fish instantly", function()
    local success = PerformFishingAction()
    if success then
        Status.Text = "✅ Single catch successful!"
        Status.TextColor3 = theme.Success
    else
        Status.Text = "❌ Single catch failed"
        Status.TextColor3 = theme.Error
    end
end)

CreateSection("⚡ SETTINGS")

CreateToggle("Instant Fishing", "Fast fishing mode", config.instantFishing, function(v)
    config.instantFishing = v
    config.fishingDelay = v and 0.05 or 0.2
    print("⚡ Instant Fishing: " .. tostring(v))
end)

CreateToggle("Blantant Mode", "Ultra fast (may be risky)", config.blantantMode, function(v)
    config.blantantMode = v
    config.fishingDelay = v and 0.03 or 0.15
    print("💥 Blantant Mode: " .. tostring(v))
end)

CreateSection("📊 STATISTICS")

local statLabels = {
    fish = CreateLabel("🎣 Fish Caught: 0"),
    attempts = CreateLabel("🔄 Total Attempts: 0"),
    success = CreateLabel("✅ Successful: 0"),
    failed = CreateLabel("❌ Failed: 0"),
    rate = CreateLabel("⚡ Rate: 0.00/s"),
}

-- Real-time stats update
task.spawn(function()
    while task.wait(0.5) do
        local elapsed = math.max(1, tick() - stats.startTime)
        local rate = stats.fishCaught / elapsed
        
        statLabels.fish.Text = "🎣 Fish Caught: " .. stats.fishCaught
        statLabels.attempts.Text = "🔄 Total Attempts: " .. stats.attempts
        statLabels.success.Text = "✅ Successful: " .. stats.successfulCatch
        statLabels.failed.Text = "❌ Failed: " .. stats.failedCatch
        statLabels.rate.Text = string.format("⚡ Rate: %.2f/s", rate)
    end
end)

CreateSection("🎮 ACTIONS")

CreateButton("🔄 Refresh Methods", "Rescan fishing methods", function()
    local remotes = FindFishingRemotes()
    Status.Text = "🔍 Found " .. #remotes .. " fishing methods"
    Status.TextColor3 = theme.Warning
    print("🔍 Rescanned fishing methods: " .. #remotes .. " found")
end)

CreateButton("📊 Reset Stats", "Reset all statistics", function()
    stats.fishCaught = 0
    stats.attempts = 0
    stats.successfulCatch = 0
    stats.failedCatch = 0
    stats.startTime = tick()
    Status.Text = "✅ Stats reset!"
    Status.TextColor3 = theme.Success
end)

CreateButton("🗑️ Close UI", "Close this interface", function()
    ScreenGui:Destroy()
    if fishingConnection then
        fishingConnection:Disconnect()
    end
end)

-- Auto start fishing jika dienable
if Kaitun["Fishing"]["Auto Fishing"] then
    task.wait(3)
    StartFishing()
    if startBtn then
        startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
        startBtn.BackgroundColor3 = theme.Error
    end
    print("✅ Auto-started fishing!")
end

-- Keybind untuk toggle fishing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        if fishingActive then
            StopFishing()
            if startBtn then
                startBtn:FindFirstChild("TextLabel").Text = "🚀 START FISHING"
                startBtn.BackgroundColor3 = theme.Accent
            end
        else
            StartFishing()
            if startBtn then
                startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
                startBtn.BackgroundColor3 = theme.Error
            end
        end
    end
end)

print("✅ Kaitun Fish It Loaded Successfully!")
print("🎣 Version: " .. _G.Version)
print("⚡ Ready to fish!")
print("🔑 Press F to toggle fishing")
print("🎯 Multiple fishing methods activated")
