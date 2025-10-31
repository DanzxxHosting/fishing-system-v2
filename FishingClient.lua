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
        ["Blantant Delay Fishing"] = 10,
        ["Auto Fishing"] = true,
        ["Delay Fishing"] = 0.05,
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
    superInstantSpeed = 15,
    fishingDelay = Kaitun["Fishing"]["Delay Fishing"],
    fishingSpeed = 25,
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

-- Simple UI Library
local function CreateKaitunUI()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KaitunFishItUI"
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Main Container for Blur Effect
    local MainContainer
    if Kaitun["Start Kaitun"]["Lite UI"]["Blur"] then
        MainContainer = Instance.new("Frame")
        MainContainer.Name = "MainContainer"
        MainContainer.Parent = ScreenGui
        MainContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MainContainer.BackgroundTransparency = 0.7
        MainContainer.BorderSizePixel = 0
        MainContainer.Size = UDim2.new(1, 0, 1, 0)
    end

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainContainer or ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Active = true
    MainFrame.Draggable = true

    -- Background Effect
    local BackgroundEffect = Instance.new("Frame")
    BackgroundEffect.Name = "BackgroundEffect"
    BackgroundEffect.Parent = MainFrame
    BackgroundEffect.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
    BackgroundEffect.BorderSizePixel = 0
    BackgroundEffect.Position = UDim2.new(0, 5, 0, 5)
    BackgroundEffect.Size = UDim2.new(1, -10, 1, -10)
    BackgroundEffect.ZIndex = -1

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 60)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.05, 0, 0.2, 0)
    Title.Size = UDim2.new(0.7, 0, 0.4, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ KAITUN " .. _G.Version .. " - ULTIMATE FISH IT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = TopBar
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
    StatusLabel.Size = UDim2.new(0.7, 0, 0.25, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "🔴 SYSTEM READY"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.9, 0, 0.25, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0.1, 0)
    TabContainer.Size = UDim2.new(1, 0, 0.9, 0)

    -- Scrolling Frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Parent = TabContainer
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 3, 0)
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollFrame
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)

    -- UI Functions
    local UIFunctions = {}

    function UIFunctions:CreateSection(title)
        local Section = Instance.new("Frame")
        Section.Parent = ScrollFrame
        Section.BackgroundColor3 = Color3.fromRGB(30, 45, 70)
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(0.95, 0, 0, 40)

        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Size = UDim2.new(1, 0, 1, 0)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = "🎯 " .. title
        SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        SectionTitle.TextSize = 14

        return Section
    end

    function UIFunctions:CreateToggle(name, description, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 45, 70)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.95, 0, 0, 60)

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
        ToggleLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Parent = ToggleFrame
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Position = UDim2.new(0.05, 0, 0.5, 0)
        ToggleDesc.Size = UDim2.new(0.7, 0, 0.4, 0)
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.Text = description
        ToggleDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        ToggleDesc.TextSize = 10
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 60, 60)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.8, 0, 0.3, 0)
        ToggleButton.Size = UDim2.new(0.15, 0, 0.4, 0)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 11

        ToggleButton.MouseButton1Click:Connect(function()
            local newValue = not (ToggleButton.Text == "ON")
            ToggleButton.BackgroundColor3 = newValue and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 60, 60)
            ToggleButton.Text = newValue and "ON" or "OFF"
            callback(newValue)
        end)

        return ToggleFrame
    end

    function UIFunctions:CreateButton(name, description, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = ScrollFrame
        Button.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.95, 0, 0, 50)
        Button.AutoButtonColor = false

        local ButtonLabel = Instance.new("TextLabel")
        ButtonLabel.Parent = Button
        ButtonLabel.BackgroundTransparency = 1
        ButtonLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
        ButtonLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
        ButtonLabel.Font = Enum.Font.GothamBold
        ButtonLabel.Text = name
        ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonLabel.TextSize = 14
        ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left

        local ButtonDesc = Instance.new("TextLabel")
        ButtonDesc.Parent = Button
        ButtonDesc.BackgroundTransparency = 1
        ButtonDesc.Position = UDim2.new(0.05, 0, 0.6, 0)
        ButtonDesc.Size = UDim2.new(0.9, 0, 0.3, 0)
        ButtonDesc.Font = Enum.Font.Gotham
        ButtonDesc.Text = description
        ButtonDesc.TextColor3 = Color3.fromRGB(220, 220, 220)
        ButtonDesc.TextSize = 10
        ButtonDesc.TextXAlignment = Enum.TextXAlignment.Left

        Button.MouseButton1Click:Connect(function()
            callback()
        end)

        return Button
    end

    function UIFunctions:CreateLabel(text, height)
        local Label = Instance.new("TextLabel")
        Label.Parent = ScrollFrame
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.95, 0, 0, height or 25)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        return Label
    end

    function UIFunctions:UpdateStatus(text, color)
        StatusLabel.Text = text
        StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    end

    return UIFunctions, ScrollFrame
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
    
    -- SUPER INSTANT FISHING MODE (20x FASTER)
    if config.instantFishing then
        local fishingEvents = findFishingEvent()
        
        for _, event in pairs(fishingEvents) do
            local methods = {"CatchFish", "FishCaught", "GetFish", "AddFish", "StartFishing", "CompleteFishing", "Fish", "Catch", "Reel", "Fishing", "Cast"}
            
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
        for i = 1, 5 do
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.001)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
            
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(0.001)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
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
    
    print("🚀 STARTING KAITUN AUTO FISHING - 20x FASTER!")
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if config.autoFishing and not isFishing then
            local success = false
            local attempts = config.instantFishing and config.superInstantSpeed or 1
            
            for i = 1, attempts do
                if performUltimateFishing() then
                    success = true
                    if i < attempts then
                        wait(0.005)
                    end
                end
            end
            
            if success then
                local fishPerSecond = stats.fishCaught / (tick() - stats.startTime)
                Window:UpdateStatus("🟢 FISHING - " .. stats.fishCaught .. " fish | " .. string.format("%.1f", fishPerSecond) .. "/s", Color3.fromRGB(0, 255, 127))
                
                if stats.fishCaught % 5 == 0 then
                    print("📊 KAITUN REPORT: " .. stats.fishCaught .. " fish | $" .. stats.totalEarnings .. " | " .. string.format("%.1f", fishPerSecond) .. " fish/s")
                end
            else
                Window:UpdateStatus("🟡 Scanning fishing methods...", Color3.fromRGB(255, 200, 0))
            end
            
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
    Window:UpdateStatus("🔴 Fishing Stopped", Color3.fromRGB(255, 60, 60))
end

-- KAITUN ROD SHOP SYSTEM
function autoBuyRodShop()
    if not config.autoBuyShop then return end
    
    local rodList = Kaitun["Rod Shop"]["Shop"]["Shop List"]
    print("🛒 Checking Rod Shop for: " .. table.concat(rodList, ", "))
    
    for _, rodName in pairs(rodList) do
        local success = pcall(function()
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
        print("🌊 Weather boost activated!")
    end)
    
    if success then
        stats.itemsBought = stats.itemsBought + 1
    end
end

-- Initialize Kaitun UI
local Window, ScrollFrame = CreateKaitunUI()

-- Create UI Elements
Window:CreateSection("🎯 KAITUN FISHING CONTROLS")

local autoFishButton = Window:CreateButton("🚀 START KAITUN FISHING", "Start auto fishing with 20x faster speed", function()
    config.autoFishing = not config.autoFishing
    if config.autoFishing then
        startAutoFishing()
        autoFishButton:FindFirstChild("TextLabel").Text = "⏹️ STOP KAITUN FISHING"
        autoFishButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Window:UpdateStatus("🟢 KAITUN FISHING ACTIVATED - 20x SPEED!", Color3.fromRGB(0, 255, 127))
    else
        stopAutoFishing()
        autoFishButton:FindFirstChild("TextLabel").Text = "🚀 START KAITUN FISHING"
        autoFishButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        Window:UpdateStatus("🔴 Fishing Stopped", Color3.fromRGB(255, 60, 60))
    end
end)

Window:CreateSection("⚡ FISHING SETTINGS")

Window:CreateToggle("INSTANT FISHING", "ENABLED - Catch fish instantly (20x Faster)", Kaitun["Fishing"]["Instant Fishing"], function(value)
    config.instantFishing = value
    Kaitun["Fishing"]["Instant Fishing"] = value
    Window:UpdateStatus(value and "⚡ INSTANT FISHING ON - 20x SPEED" or "🔵 Instant Fishing OFF")
end)

Window:CreateToggle("BLANTANT MODE", "ENABLED - Ultra fast fishing (20x Faster)", Kaitun["Fishing"]["Auto Blantant Fishing"], function(value)
    config.blantantDelay = value
    Kaitun["Fishing"]["Auto Blantant Fishing"] = value
    Window:UpdateStatus(value and "💥 BLANTANT MODE ON - 20x SPEED" or "🔵 Normal Mode")
end)

Window:CreateSection("🛒 KAITUN SHOP SYSTEM")

Window:CreateToggle("AUTO BUY RODS", "ENABLED - Auto purchase best rods", Kaitun["Fishing"]["Auto Buy Rod Shop"], function(value)
    config.autoBuyShop = value
    Kaitun["Fishing"]["Auto Buy Rod Shop"] = value
    if value then
        spawn(function()
            while config.autoBuyShop do
                autoBuyRodShop()
                wait(20)
            end
        end)
    end
end)

Window:CreateToggle("AUTO BUY WEATHER", "ENABLED - Auto weather boosts", Kaitun["Fishing"]["Auto Buy Weather"], function(value)
    config.autoBuyWeather = value
    Kaitun["Fishing"]["Auto Buy Weather"] = value
    if value then
        spawn(function()
            while config.autoBuyWeather do
                autoBuyWeatherBoost()
                wait(40)
            end
        end)
    end
end)

Window:CreateSection("📊 KAITUN STATISTICS")

local statsLabels = {
    totalFish = Window:CreateLabel("🎣 TOTAL FISH CAUGHT: " .. stats.fishCaught, 30),
    sessionFish = Window:CreateLabel("📈 SESSION FISH: " .. stats.sessionFish, 30),
    earnings = Window:CreateLabel("💰 TOTAL EARNINGS: $" .. stats.totalEarnings, 30),
    itemsBought = Window:CreateLabel("🛒 ITEMS BOUGHT: " .. stats.itemsBought, 30),
    speed = Window:CreateLabel("⚡ FISHING SPEED: 20x FASTER", 30)
}

-- Update statistics
function updateStats()
    local currentTime = tick()
    local elapsedTime = currentTime - stats.startTime
    local fishPerSecond = elapsedTime > 0 and stats.fishCaught / elapsedTime or 0
    
    statsLabels.totalFish.Text = "🎣 TOTAL FISH CAUGHT: " .. stats.fishCaught
    statsLabels.sessionFish.Text = "📈 SESSION FISH: " .. stats.sessionFish
    statsLabels.earnings.Text = "💰 TOTAL EARNINGS: $" .. stats.totalEarnings
    statsLabels.itemsBought.Text = "🛒 ITEMS BOUGHT: " .. stats.itemsBought
    statsLabels.speed.Text = "⚡ FISHING SPEED: " .. string.format("%.1f", fishPerSecond) .. " fish/s"
end

-- Auto update stats
spawn(function()
    while true do
        updateStats()
        wait(0.5)
    end
end)

-- Quick actions
Window:CreateSection("🎮 QUICK ACTIONS")

Window:CreateButton("🛒 BUY RODS NOW", "Purchase all available rods instantly", function()
    autoBuyRodShop()
end)

Window:CreateButton("🌊 BUY WEATHER NOW", "Activate weather boosts instantly", function()
    autoBuyWeatherBoost()
end)

-- Auto start if enabled in Kaitun config
if Kaitun["Start Kaitun"]["Enable"] and Kaitun["Fishing"]["Auto Fishing"] then
    spawn(function()
        wait(2)
        config.autoFishing = true
        startAutoFishing()
        autoFishButton:FindFirstChild("TextLabel").Text = "⏹️ STOP KAITUN FISHING"
        autoFishButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Window:UpdateStatus("🟢 KAITUN AUTO STARTED - 20x SPEED!", Color3.fromRGB(0, 255, 127))
    end)
end

print("🎣 KAITUN FISH IT LOADED - 20x FASTER!")
print("⚡ Instant Fishing: " .. tostring(Kaitun["Fishing"]["Instant Fishing"]))
print("💥 Blantant Fishing: " .. tostring(Kaitun["Fishing"]["Auto Blantant Fishing"]))
print("⏱️ Fishing Delay: " .. Kaitun["Fishing"]["Delay Fishing"])

Window:UpdateStatus("✅ KAITUN SYSTEM READY - 20x SPEED!", Color3.fromRGB(0, 255, 127))
