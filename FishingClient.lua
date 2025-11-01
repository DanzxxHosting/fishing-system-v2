repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

_G.Version = "Ultimate v2.0 Fixed"

getgenv().Kaitun = {
    ["Start Kaitun"] = {
        ["Enable"] = true,
        ["Boost Fps"] = true,
        ["Remove Notify"] = true,
        ["Delay Auto Sell"] = 1.5,
        ["FPS Lock"] = {
            ["Enable"] = true,
            ["FPS"] = 144
        },
        ["Lite UI"] = {
            ["Blur"] = true,
            ["White Screen"] = false
        },
        ["Auto Hop Server"] = {
            ["Auto Hop When Get Hight Ping"] = true,
            ["Enable"] = true,
            ["Delay"] = 480
        }
    },
    ["Fishing"] = {
        ["Instant Fishing"] = true, 
        ["Blantant Delay Fishing"] = 5,
        ["Auto Fishing"] = true,
        ["Delay Fishing"] = 0.05,
        ["Auto Blantant Fishing"] = true,
        ["Auto Buy Weather"] = true,
        ["Auto Buy Rod Shop"] = true,
    },
    ["Rod Shop"] = {
        ["Shop"] = {
            ["Shop List"] = {
                "Luck Rod", "Carbon Rod", "Grass Rod", "Damascus Rod", 
                "Ice Rod", "Lucky Rod", "Midnight Rod", "Steampunk Rod", 
                "Chrome Rod", "Fluorescent Rod", "Astral Rod"
            },
            ["Auto Buy"] = true,
        },
    },
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local config = {
    autoFishing = Kaitun["Fishing"]["Auto Fishing"],
    instantFishing = Kaitun["Fishing"]["Instant Fishing"],
    fishingDelay = Kaitun["Fishing"]["Delay Fishing"],
    blantantDelay = Kaitun["Fishing"]["Auto Blantant Fishing"],
    blantantDelayValue = Kaitun["Fishing"]["Blantant Delay Fishing"],
    autoBuyShop = Kaitun["Fishing"]["Auto Buy Rod Shop"],
    autoBuyWeather = Kaitun["Fishing"]["Auto Buy Weather"],
}

local stats = {
    fishCaught = 0,
    totalEarnings = 0,
    startTime = tick(),
    itemsBought = 0,
    failedAttempts = 0,
    successRate = 100
}

local fishingActive = false
local fishingConnection

-- FPS Boost
if Kaitun["Start Kaitun"]["Boost Fps"] then
    local lighting = game:GetService("Lighting")
    local terrain = workspace.Terrain
    
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 0
    
    settings().Rendering.QualityLevel = "Level01"
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        elseif obj:IsA("Explosion") then
            obj.BlastPressure = 1
            obj.BlastRadius = 1
        elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") then
            obj.Enabled = false
        end
    end
end

-- FPS Lock
if Kaitun["Start Kaitun"]["FPS Lock"]["Enable"] then
    setfpscap(Kaitun["Start Kaitun"]["FPS Lock"]["FPS"])
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

ScreenGui.Name = "KaitunUI"
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = theme.Main
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 550)
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
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 15, 0, 45)
Status.Size = UDim2.new(1, -30, 0, 25)
Status.Font = Enum.Font.Gotham
Status.Text = "🟢 Ready to start..."
Status.TextColor3 = theme.Success
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 80)
Container.Size = UDim2.new(1, -20, 1, -90)
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 4

UIList.Parent = Container
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local function CreateSection(text)
    local section = Instance.new("TextLabel")
    section.Name = "Section"
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

local function CreateButton(name, desc, callback)
    local button = Instance.new("TextButton")
    button.Parent = Container
    button.BackgroundColor3 = theme.Accent
    button.Size = UDim2.new(0.95, 0, 0, 50)
    button.Font = Enum.Font.GothamBold
    button.Text = ""
    button.TextColor3 = theme.Text
    
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

-- FISHING SYSTEM
local function GetRod()
    local backpack = player.Backpack
    local char = player.Character
    
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("pole")) then
            return item
        end
    end
    
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("pole")) then
                return item
            end
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == player.Backpack then
        humanoid:EquipTool(rod)
        wait(0.3)
        return true
    end
    return rod ~= nil
end

local function FindFishingPrompt()
    local char = player.Character
    if not char then return nil end
    
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and (
            obj.ObjectText:lower():find("fish") or 
            obj.ObjectText:lower():find("catch") or
            obj.ObjectText:lower():find("reel") or
            obj.ActionText:lower():find("fish") or
            obj.ActionText:lower():find("catch")
        ) then
            return obj
        end
    end
    
    return nil
end

local function SimulateKeyPress(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function SimulateClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local function TryFishing()
    -- Equip rod first
    if not EquipRod() then
        Status.Text = "⚠️ No fishing rod found!"
        Status.TextColor3 = theme.Warning
        return false
    end
    
    -- Try proximity prompt
    local prompt = FindFishingPrompt()
    if prompt and prompt.Enabled then
        fireproximityprompt(prompt)
        wait(0.2)
        stats.fishCaught = stats.fishCaught + 1
        return true
    end
    
    -- Try click detection
    local rod = GetRod()
    if rod and rod.Parent == player.Character then
        local handle = rod:FindFirstChild("Handle")
        if handle and handle:FindFirstChild("ClickDetector") then
            fireclickdetector(handle.ClickDetector)
            wait(0.2)
            stats.fishCaught = stats.fishCaught + 1
            return true
        end
    end
    
    -- Try key presses
    SimulateClick()
    wait(0.1)
    SimulateKeyPress(Enum.KeyCode.E)
    wait(0.1)
    
    -- Try mouse click on rod
    if rod and rod.Parent == player.Character then
        local mouse = player:GetMouse()
        mouse.Button1Down:Fire()
        wait(0.05)
        mouse.Button1Up:Fire()
    end
    
    stats.fishCaught = stats.fishCaught + 1
    return true
end

local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    Status.Text = "🟢 Fishing active..."
    Status.TextColor3 = theme.Success
    
    print("🚀 Starting Kaitun Fishing...")
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not config.autoFishing or not fishingActive then return end
        
        local success = pcall(function()
            TryFishing()
        end)
        
        if success then
            local elapsed = tick() - stats.startTime
            local rate = stats.fishCaught / math.max(1, elapsed)
            Status.Text = string.format("🟢 Fish: %d | %.1f/s", stats.fishCaught, rate)
            Status.TextColor3 = theme.Success
        else
            stats.failedAttempts = stats.failedAttempts + 1
        end
        
        wait(config.blantantDelay and (config.blantantDelayValue / 1000) or config.fishingDelay)
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

-- UI Elements
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

CreateSection("⚡ SETTINGS")

CreateToggle("Instant Fishing", "Fast fishing mode", config.instantFishing, function(v)
    config.instantFishing = v
end)

CreateToggle("Blantant Mode", "Ultra fast mode", config.blantantDelay, function(v)
    config.blantantDelay = v
end)

CreateSection("📊 STATISTICS")

local statLabels = {
    fish = CreateLabel("🎣 Fish: 0"),
    rate = CreateLabel("⚡ Rate: 0/s"),
    earnings = CreateLabel("💰 Earnings: $0"),
}

spawn(function()
    while wait(0.5) do
        local elapsed = tick() - stats.startTime
        local rate = stats.fishCaught / math.max(1, elapsed)
        
        statLabels.fish.Text = "🎣 Fish: " .. stats.fishCaught
        statLabels.rate.Text = string.format("⚡ Rate: %.2f/s", rate)
        statLabels.earnings.Text = "💰 Earnings: $" .. stats.totalEarnings
    end
end)

CreateSection("🎮 ACTIONS")

CreateButton("🔄 Equip Rod", "Equip fishing rod", function()
    if EquipRod() then
        Status.Text = "✅ Rod equipped!"
        Status.TextColor3 = theme.Success
    else
        Status.Text = "❌ No rod found!"
        Status.TextColor3 = theme.Error
    end
end)

CreateButton("📊 Reset Stats", "Reset statistics", function()
    stats.fishCaught = 0
    stats.totalEarnings = 0
    stats.startTime = tick()
    Status.Text = "✅ Stats reset!"
    Status.TextColor3 = theme.Success
end)

-- Auto start if enabled
if Kaitun["Start Kaitun"]["Enable"] and config.autoFishing then
    wait(2)
    StartFishing()
    startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
    startBtn.BackgroundColor3 = theme.Error
end

print("✅ Kaitun Fish It Loaded!")
print("🎣 Version: " .. _G.Version)
print("⚡ Ready to fish!")
