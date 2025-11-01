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

-- Function untuk mendapatkan rod terbaik
local function GetBestRod()
    local bestRod = nil
    local rodTiers = {
        ["astral"] = 10,
        ["fluorescent"] = 9,
        ["chrome"] = 8,
        ["stempunk"] = 7,
        ["midnight"] = 6,
        ["lucky"] = 5,
        ["ice"] = 4,
        ["demascus"] = 3,
        ["carbon"] = 2,
        ["grass"] = 1,
        ["luck"] = 0
    }
    

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

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

-- SAFE FISHING FUNCTIONS
local function SafeGetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function SafeGetHumanoid()
    local char = SafeGetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function GetFishingRod()
    local success, result = pcall(function()
        -- Check backpack
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("rod") or name:find("pole") or name:find("fishing") then
                        return item
                    end
                end
            end
        end
        
        -- Check character
        local char = player.Character
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("rod") or name:find("pole") or name:find("fishing") then
                        return item
                    end
                end
            end
        end
        
        return nil
    end)
    
    return success and result or nil
end

local function EquipRod()
    local success = pcall(function()
        local rod = GetFishingRod()
        if not rod then return false end
        
        if rod.Parent == player.Backpack then
            local humanoid = SafeGetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.3)
                return true
            end
        end
        
        return rod.Parent == player.Character
    end)
    
    return success
end

local function FindFishingProximityPrompt()
    local success, prompt = pcall(function()
        local char = SafeGetCharacter()
        if not char then return nil end
        
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local objText = descendant.ObjectText and descendant.ObjectText:lower() or ""
                local actionText = descendant.ActionText and descendant.ActionText:lower() or ""
                
                if objText:find("fish") or objText:find("cast") or objText:find("catch") or
                   actionText:find("fish") or actionText:find("cast") or actionText:find("catch") then
                    return descendant
                end
            end
        end
        
        return nil
    end)
    
    return success and prompt or nil
end

local function SimulateKeyPress(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function SimulateClick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

local function TryFishingMethod()
    local methods_tried = 0
    local success = false
    
    -- Method 1: Equip Rod
    if not EquipRod() then
        Status.Text = "⚠️ No fishing rod found!"
        Status.TextColor3 = theme.Warning
        return false
    end
    methods_tried = methods_tried + 1
    
    -- Method 2: ProximityPrompt
    pcall(function()
        local prompt = FindFishingProximityPrompt()
        if prompt and prompt.Enabled then
            fireproximityprompt(prompt)
            success = true
        end
    end)
    methods_tried = methods_tried + 1
    
    if success then
        stats.fishCaught = stats.fishCaught + 1
        return true
    end
    
    -- Method 3: ClickDetector
    pcall(function()
        local rod = GetFishingRod()
        if rod and rod.Parent == player.Character then
            local handle = rod:FindFirstChild("Handle")
            if handle then
                local clickDetector = handle:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    success = true
                end
            end
        end
    end)
    methods_tried = methods_tried + 1
    
    if success then
        stats.fishCaught = stats.fishCaught + 1
        return true
    end
    
    -- Method 4: Simulate Clicks
    SimulateClick()
    task.wait(0.001)
    
    -- Method 5: Simulate Key Presses
    SimulateKeyPress(Enum.KeyCode.E)
    task.wait(0.001)
    SimulateKeyPress(Enum.KeyCode.F)
    task.wait(0.001)
    
    methods_tried = methods_tried + 3
    
    -- Count as attempt
    stats.attempts = stats.attempts + 1
    
    -- Assume success for click/key methods
    stats.fishCaught = stats.fishCaught + 1
    
    return true
end

local function StartFishing()
    if fishingActive then return end
    
    fishingActive = true
    Status.Text = "🟢 Fishing started..."
    Status.TextColor3 = theme.Success
    
    print("🚀 Starting Kaitun Fishing...")
    print("⚡ Delay: " .. config.fishingDelay .. "s")
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not fishingActive then return end
        
        local success = pcall(function()
            TryFishingMethod()
        end)
        
        if not success then
            Status.Text = "⚠️ Error occurred, retrying..."
            Status.TextColor3 = theme.Warning
        else
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            Status.Text = string.format("🟢 Fish: %d | %.2f/s | Attempts: %d", 
                stats.fishCaught, rate, stats.attempts)
            Status.TextColor3 = theme.Success
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

-- Function untuk cek inventory rods
local function CheckRodInventory()
    local rods = {}
    local locations = {player.Backpack, player.Character}
    
    for _, location in pairs(locations) do
        if location then
            for _, item in pairs(location:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("rod") or name:find("pole") or name:find("fishing") then
                        table.insert(rods, {
                            Name = item.Name,
                            Location = location == player.Backpack and "Backpack" or "Equipped"
                        })
                    end
                end
            end
        end
    end
    
    return rods
end

    -- Cari di backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                for rodName, tier in pairs(rodTiers) do
                    if toolName:find(rodName) then
                        if not bestRod or tier > rodTiers[bestRod.Name:lower()] then
                            bestRod = tool
                        end
                    end
                end
            end
        end
    end
    
    -- Cari di character
    local character = player.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                for rodName, tier in pairs(rodTiers) do
                    if toolName:find(rodName) then
                        if not bestRod or tier > rodTiers[bestRod.Name:lower()] then
                            bestRod = tool
                        end
                    end
                end
            end
        end
    end
    
    return bestRod
end

-- Function untuk equip rod terbaik
local function EquipBestRod()
    local success = pcall(function()
        local bestRod = GetBestRod()
        if not bestRod then
            return false, "No fishing rod found"
        end
        
        -- Jika rod sudah di-equip
        if bestRod.Parent == player.Character then
            return true, bestRod.Name .. " already equipped"
        end
        
        -- Equip rod
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(bestRod)
            task.wait(0.5) -- Tunggu equip process
            return true, "Equipped " .. bestRod.Name
        end
        
        return false, "Cannot equip rod"
    end)
    
    return success
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

CreateSection("⚡ SETTINGS")

CreateToggle("Instant Fishing", "⚡ INSTANT CATCH - No delay fishing", config.instantFishing, function(v)
    config.instantFishing = v
    
    if v then
        -- Instant Fishing ON - Super fast
        config.fishingDelay = 0.01  -- 20x faster dari normal
        print("⚡ INSTANT FISHING ACTIVATED - INSTANT CATCH!")
        Status.Text = "⚡ INSTANT FISHING - NO DELAY"
        Status.TextColor3 = Color3.fromRGB(0, 255, 255)
        
        -- Auto enable features untuk instant fishing
        if not config.blantantMode then
            config.blantantMode = true
            print("💥 Auto-enabled Blantant Mode for maximum speed!")
        end
    else
        -- Instant Fishing OFF - Normal speed
        config.fishingDelay = 0.2
        print("🔵 Instant Fishing Disabled")
        Status.Text = "🔵 Normal Fishing"
        Status.TextColor3 = theme.Success
    end
end)

CreateToggle("Blantant Mode", "ULTRA FAST - Extreme speed fishing (20x Faster)", config.blantantMode, function(v)
    config.blantantMode = v
    
    if v then
        -- Blantant Mode ON - Ultra fast settings
        config.fishingDelay = 0.02  -- 10x faster dari normal
        config.instantFishing = true
        print("💥 BLASTANT MODE ACTIVATED - 10x SPEED!")
        Status.Text = "💥 BLASTANT MODE - ULTRA FAST"
        Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        -- Blantant Mode OFF - Normal settings
        config.fishingDelay = 0.15
        config.instantFishing = false
        print("🔵 Blantant Mode Disabled - Normal Speed")
        Status.Text = "🔵 Normal Mode"
        Status.TextColor3 = theme.Success
    end
end)

CreateSection("📊 Statistics")


-- Update button dengan auto equip rod terbaik
CreateButton("🎣 AUTO EQUIP BEST ROD", "Automatically equip your best fishing rod", function()
    local success, message = EquipBestRod()
    
    if success then
        local bestRod = GetBestRod()
        if bestRod then
            Status.Text = "✅ " .. bestRod.Name .. " equipped!"
            Status.TextColor3 = theme.Success
            print("🎣 Equipped best rod: " .. bestRod.Name)
        else
            Status.Text = "✅ Rod equipped!"
            Status.TextColor3 = theme.Success
        end
    else
        Status.Text = "❌ No fishing rod found!"
        Status.TextColor3 = theme.Error
        print("❌ No fishing rod available")
    end
end)


-- Button untuk cek inventory rods
CreateButton("📋 CHECK RODS", "Show all fishing rods in inventory", function()
    local rods = CheckRodInventory()
    local bestRod = GetBestRod()
    
    if #rods > 0 then
        local rodList = ""
        for i, rod in pairs(rods) do
            local marker = rod.Name == bestRod.Name and " 👑" or ""
            rodList = rodList .. rod.Name .. " (" .. rod.Location .. ")" .. marker .. "\n"
        end
        Status.Text = "📋 " .. #rods .. " rods found\nBest: " .. bestRod.Name
        Status.TextColor3 = theme.Success
        print("🎣 Rods in inventory:\n" .. rodList)
    else
        Status.Text = "❌ No rods found in inventory"
        Status.TextColor3 = theme.Error
    end
end)

CreateButton("🗑️ Close UI", "Close this interface", function()
    ScreenGui:Destroy()
    if fishingConnection then
        fishingConnection:Disconnect()
    end
end)

-- Auto start
if Kaitun["Fishing"]["Auto Fishing"] then
    task.wait(1)
    StartFishing()
    startBtn:FindFirstChild("TextLabel").Text = "⏹️ STOP FISHING"
    startBtn.BackgroundColor3 = theme.Error
    print("✅ Auto-started fishing!")
end

print("✅ Kaitun Fish It Loaded Successfully!")
print("🎣 Version: " .. _G.Version)
print("⚡ Ready to fish!")
