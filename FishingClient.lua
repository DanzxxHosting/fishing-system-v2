repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

_G.Version = "Ultimate v2.2 - Smooth & Silent"

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
        ["Delay Fishing"] = 0.05,
        ["Blantant Mode"] = true,
        ["Blantant Delay"] = 5,
    },
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local config = {
    autoFishing = true,
    instantFishing = true,
    blantantMode = true,
    fishingDelay = 0.05,
}

local stats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
}

local fishingActive = false
local fishingConnection
local lastCastTime = 0

-- FPS Optimization
if Kaitun["Start Kaitun"]["Boost Fps"] then
    pcall(function()
        local terrain = workspace.Terrain
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
        
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = "Level01"
    end)
end

if Kaitun["Start Kaitun"]["FPS Lock"]["Enable"] then
    pcall(function() setfpscap(120) end)
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

-- Create Lightweight UI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Name = "KaitunFishUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = theme.Main
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = true

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 12)
corner1.Parent = MainFrame

Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(1, -30, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ KAITUN FISH IT - " .. _G.Version
Title.TextColor3 = theme.Text
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 15, 0, 42)
Status.Size = UDim2.new(1, -30, 0, 22)
Status.Font = Enum.Font.Gotham
Status.Text = "🟢 Ready..."
Status.TextColor3 = theme.Success
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left

Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 75)
Container.Size = UDim2.new(1, -20, 1, -85)
Container.CanvasSize = UDim2.new(0, 0, 1.6, 0)
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
    section.Size = UDim2.new(0.96, 0, 0, 32)
    section.Font = Enum.Font.GothamBold
    section.Text = text
    section.TextColor3 = theme.Text
    section.TextSize = 13
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = section
    return section
end

local function CreateButton(name, desc, callback)
    local button = Instance.new("TextButton")
    button.Parent = Container
    button.BackgroundColor3 = theme.Accent
    button.Size = UDim2.new(0.96, 0, 0, 48)
    button.Text = ""
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Parent = button
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 6)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local desc_label = Instance.new("TextLabel")
    desc_label.Parent = button
    desc_label.BackgroundTransparency = 1
    desc_label.Position = UDim2.new(0, 10, 0, 26)
    desc_label.Size = UDim2.new(1, -20, 0, 16)
    desc_label.Font = Enum.Font.Gotham
    desc_label.Text = desc
    desc_label.TextColor3 = Color3.fromRGB(200, 210, 220)
    desc_label.TextSize = 10
    desc_label.TextXAlignment = Enum.TextXAlignment.Left
    
    button.MouseButton1Click:Connect(callback)
    return button
end

local function CreateToggle(name, desc, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = Container
    frame.BackgroundColor3 = theme.Secondary
    frame.Size = UDim2.new(0.96, 0, 0, 56)
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 6)
    label.Size = UDim2.new(0.58, 0, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = name
    label.TextColor3 = theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local desc_label = Instance.new("TextLabel")
    desc_label.Parent = frame
    desc_label.BackgroundTransparency = 1
    desc_label.Position = UDim2.new(0, 10, 0, 28)
    desc_label.Size = UDim2.new(0.58, 0, 0, 18)
    desc_label.Font = Enum.Font.Gotham
    desc_label.Text = desc
    desc_label.TextColor3 = Color3.fromRGB(180, 190, 200)
    desc_label.TextSize = 9
    desc_label.TextXAlignment = Enum.TextXAlignment.Left
    
    local button = Instance.new("TextButton")
    button.Parent = frame
    button.BackgroundColor3 = default and theme.Success or theme.Error
    button.Position = UDim2.new(0.72, 0, 0.23, 0)
    button.Size = UDim2.new(0.23, 0, 0.54, 0)
    button.Font = Enum.Font.GothamBold
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = theme.Text
    button.TextSize = 10
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = button
    
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
    label.Size = UDim2.new(0.96, 0, 0, 32)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = theme.Text
    label.TextSize = 12
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = label
    return label
end

-- CORE FISHING FUNCTIONS (NO JUMPING!)
local function SafeGetChar()
    return player.Character
end

local function GetRod()
    pcall(function()
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, tool in pairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    if n:find("rod") or n:find("pole") or n:find("fishing") then
                        return tool
                    end
                end
            end
        end
        
        local char = SafeGetChar()
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    if n:find("rod") or n:find("pole") or n:find("fishing") then
                        return tool
                    end
                end
            end
        end
    end)
    return nil
end

local function EquipRodSilent()
    local success = pcall(function()
        local rod = GetRod()
        if not rod then return false end
        
        if rod.Parent == player.Backpack then
            local char = SafeGetChar()
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum:EquipTool(rod)
                    task.wait(0.2)
                end
            end
        end
        return true
    end)
    return success
end

local function FindProximityPrompt()
    local success, result = pcall(function()
        local char = SafeGetChar()
        if not char then return nil end
        
        -- Search in character descendants
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                return obj
            end
        end
        
        -- Search in workspace near player
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local parent = obj.Parent
                    if parent and (parent.Position - hrp.Position).Magnitude < 20 then
                        return obj
                    end
                end
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

local function TryCastRod()
    -- Equip rod if not equipped
    EquipRodSilent()
    
    -- Try ProximityPrompt (BEST METHOD - NO JUMPING)
    local prompt = FindProximityPrompt()
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
        return true
    end
    
    -- Try ClickDetector on rod handle (SILENT METHOD)
    local rod = GetRod()
    if rod and rod.Parent == SafeGetChar() then
        pcall(function()
            local handle = rod:FindFirstChild("Handle")
            if handle then
                local cd = handle:FindFirstChild("ClickDetector")
                if cd then
                    fireclickdetector(cd)
                end
            end
        end)
        return true
    end
    
    -- Try Remote Events (SILENT METHOD)
    pcall(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("rod") then
                    obj:FireServer()
                    obj:FireServer("Cast")
                    obj:FireServer(true)
                end
            end
        end
    end)
    
    return true
end

local function AutoFishingLoop()
    while fishingActive do
        local currentTime = tick()
        
        -- Apply delay based on mode
        local delay = config.fishingDelay
        if config.blantantMode then
            delay = Kaitun["Fishing"]["Blantant Delay"] / 1000
        end
        
        -- Cast rod
        pcall(function()
            TryCastRod()
            stats.fishCaught = stats.fishCaught + 1
            stats.attempts = stats.attempts + 1
        end)
        
        lastCastTime = currentTime
        
        -- Update UI
        local elapsed = math.max(1, tick() - stats.startTime)
        local rate = stats.fishCaught / elapsed
        Status.Text = string.format("🟢 Fishing: %d fish | %.2f/s", stats.fishCaught, rate)
        
        task.wait(delay)
    end
end

local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    Status.Text = "🟢 Starting fishing..."
    Status.TextColor3 = theme.Success
    
    print("🚀 Kaitun Fishing Started")
    print("⚡ Mode: " .. (config.blantantMode and "BLANTANT" or "INSTANT"))
    print("⏱️ Delay: " .. (config.blantantMode and (Kaitun["Fishing"]["Blantant Delay"] .. "ms") or (config.fishingDelay .. "s")))
    
    task.spawn(AutoFishingLoop)
end

local function StopFishing()
    fishingActive = false
    Status.Text = "🔴 Fishing stopped"
    Status.TextColor3 = theme.Error
    print("🔴 Fishing stopped")
end

-- Build UI
CreateSection("🎯 FISHING CONTROLS")

local startBtn = CreateButton("🚀 START FISHING", "Start silent auto fishing", function()
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

CreateSection("⚡ FISHING MODES")

CreateToggle("Instant Fishing", "Ultra fast mode (0.05s delay)", config.instantFishing, function(v)
    config.instantFishing = v
    config.fishingDelay = v and 0.05 or 0.15
    if v then
        config.blantantMode = false
    end
end)

CreateToggle("Blantant Mode", "Extreme speed (5ms delay)", config.blantantMode, function(v)
    config.blantantMode = v
    if v then
        config.instantFishing = false
    end
end)

CreateSection("📊 STATISTICS")

local statLabels = {
    fish = CreateLabel("🎣 Fish: 0"),
    attempts = CreateLabel("🔄 Attempts: 0"),
    rate = CreateLabel("⚡ Rate: 0.00/s"),
}

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            
            statLabels.fish.Text = "🎣 Fish Caught: " .. stats.fishCaught
            statLabels.attempts.Text = "🔄 Attempts: " .. stats.attempts
            statLabels.rate.Text = string.format("⚡ Rate: %.2f/s", rate)
        end)
    end
end)

CreateSection("🎮 QUICK ACTIONS")

CreateButton("🎣 Equip Rod", "Manually equip fishing rod", function()
    if EquipRodSilent() then
        Status.Text = "✅ Rod equipped!"
        Status.TextColor3 = theme.Success
    else
        Status.Text = "❌ No rod found!"
        Status.TextColor3 = theme.Error
    end
end)

CreateButton("📊 Reset Stats", "Reset all statistics", function()
    stats.fishCaught = 0
    stats.attempts = 0
    stats.startTime = tick()
    Status.Text = "✅ Stats reset!"
    Status.TextColor3 = theme.Success
end)

CreateButton("🗑️ Close UI", "Destroy this interface", function()
    StopFishing()
    ScreenGui:Destroy()
end)

-- Auto-start if enabled
if Kaitun["Fishing"]["Auto Fishing"] then
    task.wait(2)
    StartFishing()
    startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
    startBtn.BackgroundColor3 = theme.Error
    print("✅ Auto-started fishing!")
end

print("✅ Kaitun Fish It Loaded!")
print("🎣 Version: " .. _G.Version)
print("🔇 Silent mode enabled - No jumping!")
print("⚡ Ready to fish!")
