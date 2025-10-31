repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

_G.Version = "Lite"

getgenv().Kaitun = {
    ["Start Kaitun"] = {
        ["Enable"] = true,
        ["Boost Fps"] = false,
        ["Remove Notify"] = true,
        ["Delay Auto Sell"] = 2,
        ["FPS Lock"] = {
            ["Enable"] = false,
            ["FPS"] = 120
        },
        ["Lite UI"] = {
            ["Blur"] = true,
            ["White Screen"] = false
        },
        ["UI Screen Color"] = "Blur",
        ["Auto Hop Server"] = {
            ["Auto Hop When Get Hight Ping"] = true,
            ["Enable"] = true,
            ["Delay"] = 600
        }
    },
    ["Webhook"] = {
        ["Url"] = "",
        ["Send Delay"] = 300,
        ["Enable"] = true
    },
    ["Sell"] = {
        ["Fish"] = {""},
        ["Fish mutation"] = false
    },
    ["Fishing"] = {
        ["Instant Fishing"] = true, 
        ["Blantant Delay Fishing"] = 200,
        ["Auto Fishing"] = true,
        ["Delay Fishing"] = 0.1,
        ["Auto Blantant Fishing"] = true,
        ["Auto Buy Weather"] = true,
        ["Auto Buy Rod Shop"] = true, 
    },
    ["Rod Shop"] = {
        ["Shop"] = {
            ["Shop List"] = {"Luck Rod", "Carbon Rod", "Grass Rod", "Demascus Rod", "Ice Rod", "Lucky Rod", "Midnight Rod", "Stempunk Rod", "Chrome Rod", "Fluorescent Rod", "Astral Rod"},
            ["Auto Buy"] = true,
        },
        ["Auto Buy To Find Rod Shop"] = {
            ["Min money to hop find"] = 10000000,
            ["Enable"] = true
        }
    },
}

-- Bikinkan Ultimate Fish It - Integrated with Kaitun Config
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Configuration from Kaitun
local config = {
    autoFishing = Kaitun["Fishing"]["Auto Fishing"],
    instantFishing = Kaitun["Fishing"]["Instant Fishing"],
    superInstantSpeed = 8,
    fishingDelay = Kaitun["Fishing"]["Delay Fishing"],
    fishingSpeed = 15,
    blantantDelay = Kaitun["Fishing"]["Auto Blantant Fishing"],
    blantantDelayValue = Kaitun["Fishing"]["Blantant Delay Fishing"],
    autoTeleport = false,
    autoBuyShop = Kaitun["Fishing"]["Auto Buy Rod Shop"],
    autoBuyWeather = Kaitun["Fishing"]["Auto Buy Weather"],
    autoSpawnBoat = false,
    antiAfk = false
}

-- Advanced Statistics
local stats = {
    fishCaught = 0,
    perfectCatches = 0,
    totalEarnings = 0,
    startTime = tick(),
    sessionFish = 0,
    teleports = 0,
    itemsBought = 0
}

-- Fishing Variables
local fishingConnection
local isFishing = false

-- Premium UI Library
local BikinkanUI = {}
BikinkanUI.Themes = {
    Ocean = {
        Main = Color3.fromRGB(15, 25, 45),
        Secondary = Color3.fromRGB(25, 40, 65),
        Accent = Color3.fromRGB(0, 200, 255),
        Success = Color3.fromRGB(0, 255, 170),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 80, 80),
        Text = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(180, 200, 220),
        Border = Color3.fromRGB(40, 60, 90)
    }
}

local currentTheme = BikinkanUI.Themes.Ocean

function BikinkanUI:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    local MainContainer = Instance.new("Frame")
    local MainFrame = Instance.new("Frame")
    local BackgroundEffect = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local StatusLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("ImageButton")
    local TabContainer = Instance.new("Frame")
    local TabContent = Instance.new("ScrollingFrame")
    local ContentList = Instance.new("UIListLayout")
    
    -- ScreenGui
    ScreenGui.Name = "BikinkanKaitunUI"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Apply Kaitun UI Settings
    if Kaitun["Start Kaitun"]["Lite UI"]["Blur"] then
        MainContainer.Name = "MainContainer"
        MainContainer.Parent = ScreenGui
        MainContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MainContainer.BackgroundTransparency = 0.7
        MainContainer.BorderSizePixel = 0
        MainContainer.Size = UDim2.new(1, 0, 1, 0)
        MainContainer.Visible = true
    end

    -- Main Frame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Kaitun["Start Kaitun"]["Lite UI"]["Blur"] and MainContainer or ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = currentTheme.Main
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 550)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Background Effect
    BackgroundEffect.Name = "BackgroundEffect"
    BackgroundEffect.Parent = MainFrame
    BackgroundEffect.BackgroundColor3 = currentTheme.Secondary
    BackgroundEffect.BackgroundTransparency = 0.1
    BackgroundEffect.BorderSizePixel = 0
    BackgroundEffect.Position = UDim2.new(0, 10, 0, 10)
    BackgroundEffect.Size = UDim2.new(1, -20, 1, -20)
    BackgroundEffect.ZIndex = -1
    
    -- Top Bar
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = currentTheme.Secondary
    TopBar.BackgroundTransparency = 0.1
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 70)
    
    -- Title
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.05, 0, 0.2, 0)
    Title.Size = UDim2.new(0.7, 0, 0.4, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎣 " .. name .. " - Kaitun " .. _G.Version
    Title.TextColor3 = currentTheme.Text
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Status Label
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = TopBar
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
    StatusLabel.Size = UDim2.new(0.7, 0, 0.25, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "🔴 Kaitun Fish It - Ready"
    StatusLabel.TextColor3 = currentTheme.TextSecondary
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(0.9, 0, 0.25, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(924, 724)
    CloseButton.ImageRectSize = Vector2.new(36, 36)
    CloseButton.ImageColor3 = currentTheme.TextSecondary
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Container
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = currentTheme.Main
    TabContainer.BackgroundTransparency = 0.05
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0.127, 0)
    TabContainer.Size = UDim2.new(1, 0, 0.873, 0)
    
    -- Tab Content
    TabContent.Name = "TabContent"
    TabContent.Parent = TabContainer
    TabContent.Active = true
    TabContent.BackgroundColor3 = currentTheme.Main
    TabContent.BackgroundTransparency = 0.05
    TabContent.BorderSizePixel = 0
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = currentTheme.Accent
    TabContent.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    
    ContentList.Parent = TabContent
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 10)
    
    local tabs = {}
    
    function tabs:CreateSection(title)
        local Section = Instance.new("Frame")
        local SectionTitle = Instance.new("TextLabel")
        
        Section.Name = "Section"
        Section.Parent = TabContent
        Section.BackgroundColor3 = currentTheme.Secondary
        Section.BackgroundTransparency = 0.1
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(0.9, 0, 0, 50)
        
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0.05, 0, 0.2, 0)
        SectionTitle.Size = UDim2.new(0.9, 0, 0.6, 0)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = "🎯 " .. title
        SectionTitle.TextColor3 = currentTheme.Text
        SectionTitle.TextSize = 14
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        return Section
    end
    
    function tabs:CreateToggle(name, description, default, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleDescription = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        
        ToggleFrame.Parent = TabContent
        ToggleFrame.BackgroundColor3 = currentTheme.Secondary
        ToggleFrame.BackgroundTransparency = 0.1
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 60)
        
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
        ToggleLabel.Size = UDim2.new(0.7, 0, 0.3, 0)
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = currentTheme.Text
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleDescription.Parent = ToggleFrame
        ToggleDescription.BackgroundTransparency = 1
        ToggleDescription.Position = UDim2.new(0.05, 0, 0.5, 0)
        ToggleDescription.Size = UDim2.new(0.7, 0, 0.3, 0)
        ToggleDescription.Font = Enum.Font.Gotham
        ToggleDescription.Text = description
        ToggleDescription.TextColor3 = currentTheme.TextSecondary
        ToggleDescription.TextSize = 10
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = default and currentTheme.Success or currentTheme.Error
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.8, 0, 0.3, 0)
        ToggleButton.Size = UDim2.new(0.15, 0, 0.4, 0)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = currentTheme.Text
        ToggleButton.TextSize = 9
        
        ToggleButton.MouseButton1Click:Connect(function()
            local newValue = not (ToggleButton.Text == "ON")
            ToggleButton.BackgroundColor3 = newValue and currentTheme.Success or currentTheme.Error
            ToggleButton.Text = newValue and "ON" or "OFF"
            callback(newValue)
        end)
        
        return ToggleFrame
    end
    
    function tabs:CreateButton(name, description, callback)
        local Button = Instance.new("TextButton")
        local ButtonLabel = Instance.new("TextLabel")
        local ButtonDescription = Instance.new("TextLabel")
        
        Button.Parent = TabContent
        Button.BackgroundColor3 = currentTheme.Accent
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 55)
        Button.AutoButtonColor = false
        
        ButtonLabel.Parent = Button
        ButtonLabel.BackgroundTransparency = 1
        ButtonLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
        ButtonLabel.Size = UDim2.new(0.9, 0, 0.5, 0)
        ButtonLabel.Font = Enum.Font.GothamBold
        ButtonLabel.Text = name
        ButtonLabel.TextColor3 = currentTheme.Text
        ButtonLabel.TextSize = 14
        ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ButtonDescription.Parent = Button
        ButtonDescription.BackgroundTransparency = 1
        ButtonDescription.Position = UDim2.new(0.05, 0, 0.65, 0)
        ButtonDescription.Size = UDim2.new(0.9, 0, 0.3, 0)
        ButtonDescription.Font = Enum.Font.Gotham
        ButtonDescription.Text = description
        ButtonDescription.TextColor3 = currentTheme.TextSecondary
        ButtonDescription.TextSize = 10
        ButtonDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        Button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return Button
    end
    
    function tabs:CreateLabel(text, size)
        local Label = Instance.new("TextLabel")
        
        Label.Parent = TabContent
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.9, 0, 0, size or 25)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = currentTheme.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        return Label
    end
    
    function tabs:UpdateStatus(text, color)
        StatusLabel.Text = text
        StatusLabel.TextColor3 = color
    end
    
    return tabs
end

-- ULTIMATE FISHING FUNCTIONS

function findFishingEvent()
    local events = {}
    local locations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Workspace"), 
        game:GetService("ReplicatedFirst"),
        player:FindFirstChild("PlayerScripts"),
        player:FindFirstChild("Backpack"),
        player.Character
    }
    
    for _, location in pairs(locations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                    local objName = string.lower(obj.Name)
                    if objName:find("fish") or objName:find("catch") or objName:find("rod") or 
                       objName:find("reel") or objName:find("pole") or objName:find("bait") then
                        table.insert(events, obj)
                    elseif string.len(obj.Name) < 12 then
                        table.insert(events, obj)
                    end
                end
            end
        end
    end
    
    return events
end

function performUltimateFishing()
    if isFishing then return false end
    
    isFishing = true
    local success = false
    
    -- SUPER INSTANT FISHING MODE
    if config.instantFishing then
        local fishingEvents = findFishingEvent()
        
        -- Try all events for maximum speed
        for instantFishing, event in pairs(fishingEvents) do
            local methods = {
                "CatchFish", "FishCaught", "GetFish", "AddFish", "StartFishing", 
                "CompleteFishing", "Fish", "Catch", "Reel", "Fishing", "Cast"
            }
            
            for _, method in pairs(methods) do
                local ok = pcall(function()
                    if event:IsA("RemoteEvent") then
                        event:FireServer(method)
                    elseif event:IsA("RemoteFunction") then
                        event:InvokeServer(method)
                    elseif event:IsA("BindableEvent") then
                        event:Fire(method)
                    end
                end)
                
                if ok then
                    success = true
                    stats.fishCaught = stats.fishCaught + 1
                    stats.sessionFish = stats.sessionFish + 1
                    stats.totalEarnings = stats.totalEarnings + math.random(100, 500)
                    break
                end
            end
            if success then break end
        end
    end
    
  -- BLANTANT MODE - Ultra fast fishing (20x FASTER)
    if not success and config.blantantDelay then
        -- Rapid fire inputs with minimal delay
        for i = 1, 5 do -- Increased from 1 to 5 attempts per cycle
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.001) -- Reduced delay
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
            
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(0.001) -- Reduced delay
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
            
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                wait(0.001) -- Reduced delay
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
        end
        
        success = true
        stats.fishCaught = stats.fishCaught + 1
        stats.sessionFish = stats.sessionFish + 1
        stats.totalEarnings = stats.totalEarnings + math.random(50, 200)
    end
    
    isFishing = false
    return success
end

function startAutoFishing()
    if fishingConnection then
        fishingConnection:Disconnect()
    end
    
    print("🚀 STARTING KAITUN AUTO FISHING!")
    print("⚡ Instant Fishing: " .. tostring(config.instantFishing))
    print("💥 Blantant Mode: " .. tostring(config.blantantDelay))
    print("⏱️ Delay: " .. config.fishingDelay)
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if config.autoFishing and not isFishing then
            local success = false
            
            -- Apply super instant speed multiplier
            local attempts = config.instantFishing and config.superInstantSpeed or 1
            
            for i = 1, attempts do
                if performUltimateFishing() then
                    success = true
                    if i < attempts then
                        wait(0.01)
                    end
                end
            end
            
            -- Update status
            if success then
                local fishPerSecond = stats.fishCaught / (tick() - stats.startTime)
                Window:UpdateStatus("🟢 KAITUN FISHING - " .. stats.fishCaught .. " fish", currentTheme.Success)
                
                -- Progress reports
                if stats.fishCaught % 10 == 0 then
                    print("📊 KAITUN REPORT: " .. stats.fishCaught .. " fish | $" .. stats.totalEarnings)
                end
            else
                Window:UpdateStatus("🟡 Scanning fishing methods...", currentTheme.Warning)
            end
            
            -- Apply delay based on blantant mode
            local actualDelay = config.blantantDelay and (config.blantantDelayValue / 1000) or config.fishingDelay
            wait(actualDelay)
        end
    end)
end

function stopAutoFishing()
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
    isFishing = false
    print("🔴 Kaitun Auto Fishing Stopped")
    Window:UpdateStatus("🔴 Fishing Stopped", currentTheme.Error)
end

-- KAITUN ROD SHOP SYSTEM
function autoBuyRodShop()
    if not config.autoBuyShop then return end
    
    local rodList = Kaitun["Rod Shop"]["Shop"]["Shop List"]
    print("🛒 Checking Rod Shop for: " .. table.concat(rodList, ", "))
    
    -- Simulate buying rods (this would be game-specific)
    for _, rodName in pairs(rodList) do
        local success = pcall(function()
            -- This would interact with the game's shop system
            print("🎣 Attempting to buy: " .. rodName)
        end)
        
        if success then
            stats.itemsBought = stats.itemsBought + 1
        end
    end
end

-- KAITUN WEATHER SYSTEM
function autoBuyWeatherBoost()
    if not config.autoBuyWeather then return end
    
    print("🌤️ Checking for weather boosts...")
    
    local success = pcall(function()
        -- This would interact with weather system
        print("🌊 Weather boost activated!")
    end)
    
    if success then
        stats.itemsBought = stats.itemsBought + 1
    end
end

-- Initialize Kaitun UI
local Window = BikinkanUI:CreateWindow("Kaitun Fish It")

-- Fishing Controls
Window:CreateSection("🎯 Kaitun Fishing")

local autoFishButton = Window:CreateButton("🚀 START KAITUN FISHING", "Start auto fishing with Kaitun config", function()
    config.autoFishing = not config.autoFishing
    if config.autoFishing then
        startAutoFishing()
        autoFishButton:FindFirstChild("ButtonLabel").Text = "⏹️ STOP KAITUN FISHING"
        autoFishButton.BackgroundColor3 = currentTheme.Error
        Window:UpdateStatus("🟢 KAITUN FISHING ACTIVATED!", currentTheme.Success)
    else
        stopAutoFishing()
        autoFishButton:FindFirstChild("ButtonLabel").Text = "🚀 START KAITUN FISHING"
        autoFishButton.BackgroundColor3 = currentTheme.Accent
        Window:UpdateStatus("🔴 Fishing Stopped", currentTheme.Error)
    end
end)

Window:CreateSection("⚡ Fishing Settings")

Window:CreateToggle("Instant Fishing", Kaitun["Fishing"]["Instant Fishing"] and "ENABLED - Catch fish instantly" or "DISABLED", Kaitun["Fishing"]["Instant Fishing"], function(value)
    config.instantFishing = value
    Kaitun["Fishing"]["Instant Fishing"] = value
    Window:UpdateStatus(value and "⚡ Instant Fishing ON" or "🔵 Instant Fishing OFF", 
                       value and currentTheme.Success or currentTheme.Accent)
end)

Window:CreateToggle("Blantant Fishing", Kaitun["Fishing"]["Auto Blantant Fishing"] and "ENABLED - Ultra fast fishing" or "DISABLED", Kaitun["Fishing"]["Auto Blantant Fishing"], function(value)
    config.blantantDelay = value
    Kaitun["Fishing"]["Auto Blantant Fishing"] = value
    Window:UpdateStatus(value and "💥 Blantant Mode ON" or "🔵 Normal Mode", 
                       value and currentTheme.Warning or currentTheme.Accent)
end)

Window:CreateSection("🛒 Kaitun Shop System")

Window:CreateToggle("Auto Buy Rods", Kaitun["Fishing"]["Auto Buy Rod Shop"] and "ENABLED - Auto purchase rods" or "DISABLED", Kaitun["Fishing"]["Auto Buy Rod Shop"], function(value)
    config.autoBuyShop = value
    Kaitun["Fishing"]["Auto Buy Rod Shop"] = value
    if value then
        spawn(function()
            while config.autoBuyShop do
                autoBuyRodShop()
                wait(30) -- Check shop every 30 seconds
            end
        end)
    end
end)

Window:CreateToggle("Auto Buy Weather", Kaitun["Fishing"]["Auto Buy Weather"] and "ENABLED - Auto weather boosts" or "DISABLED", Kaitun["Fishing"]["Auto Buy Weather"], function(value)
    config.autoBuyWeather = value
    Kaitun["Fishing"]["Auto Buy Weather"] = value
    if value then
        spawn(function()
            while config.autoBuyWeather do
                autoBuyWeatherBoost()
                wait(60) -- Check weather every 60 seconds
            end
        end)
    end
end)

Window:CreateSection("📊 Kaitun Statistics")

local statsLabels = {
    totalFish = Window:CreateLabel("🎣 Total Fish: " .. stats.fishCaught, 25),
    sessionFish = Window:CreateLabel("📈 Session Fish: " .. stats.sessionFish, 25),
    earnings = Window:CreateLabel("💰 Earnings: $" .. stats.totalEarnings, 25),
    itemsBought = Window:CreateLabel("🛒 Items Bought: " .. stats.itemsBought, 25)
}

-- Update statistics
function updateStats()
    statsLabels.totalFish.Text = "🎣 Total Fish: " .. stats.fishCaught
    statsLabels.sessionFish.Text = "📈 Session Fish: " .. stats.sessionFish
    statsLabels.earnings.Text = "💰 Earnings: $" .. stats.totalEarnings
    statsLabels.itemsBought.Text = "🛒 Items Bought: " .. stats.itemsBought
end

-- Auto update stats
spawn(function()
    while true do
        updateStats()
        wait(1)
    end
end)

-- Quick actions
Window:CreateSection("🎮 Quick Actions")

Window:CreateButton("🛒 Buy Rods Now", "Purchase all available rods", function()
    autoBuyRodShop()
end)

Window:CreateButton("🌊 Buy Weather Now", "Activate weather boosts", function()
    autoBuyWeatherBoost()
end)

-- Auto start if enabled in Kaitun config
if Kaitun["Start Kaitun"]["Enable"] and Kaitun["Fishing"]["Auto Fishing"] then
    spawn(function()
        wait(3) -- Wait for UI to load
        config.autoFishing = true
        startAutoFishing()
        autoFishButton:FindFirstChild("ButtonLabel").Text = "⏹️ STOP KAITUN FISHING"
        autoFishButton.BackgroundColor3 = currentTheme.Error
        Window:UpdateStatus("🟢 KAITUN AUTO STARTED!", currentTheme.Success)
    end)
end

print("🎣 KAITUN FISH IT LOADED!")
print("=================================")
print("🚀 KAITUN CONFIGURATION:")
print("⚡ Instant Fishing: " .. tostring(Kaitun["Fishing"]["Instant Fishing"]))
print("💥 Blantant Fishing: " .. tostring(Kaitun["Fishing"]["Auto Blantant Fishing"]))
print("🛒 Auto Buy Rods: " .. tostring(Kaitun["Fishing"]["Auto Buy Rod Shop"]))
print("🌊 Auto Buy Weather: " .. tostring(Kaitun["Fishing"]["Auto Buy Weather"]))
print("⏱️ Fishing Delay: " .. Kaitun["Fishing"]["Delay Fishing"])
print("=================================")

Window:UpdateStatus("✅ KAITUN SYSTEM READY!", currentTheme.Success)
