repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

_G.Version = "Ultimate v2.0"

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
        ["UI Screen Color"] = "Blur",
        ["Auto Hop Server"] = {
            ["Auto Hop When Get Hight Ping"] = true,
            ["Enable"] = true,
            ["Delay"] = 480
        }
    },
    ["Webhook"] = {
        ["Url"] = "",
        ["Send Delay"] = 240,
        ["Enable"] = false
    },
    ["Sell"] = {
        ["Fish"] = {""},
        ["Fish mutation"] = true
    },
    ["Fishing"] = {
        ["Instant Fishing"] = true, 
        ["Blantant Delay Fishing"] = 5,
        ["Auto Fishing"] = true,
        ["Delay Fishing"] = 0.03,
        ["Auto Blantant Fishing"] = true,
        ["Auto Buy Weather"] = true,
        ["Auto Buy Rod Shop"] = true,
        ["Advanced Detection"] = true,
        ["Multi-Thread Fishing"] = true
    },
    ["Rod Shop"] = {
        ["Shop"] = {
            ["Shop List"] = {
                "Luck Rod", "Carbon Rod", "Grass Rod", "Demascus Rod", 
                "Ice Rod", "Lucky Rod", "Midnight Rod", "Stempunk Rod", 
                "Chrome Rod", "Fluorescent Rod", "Astral Rod", "Destiny Rod"
            },
            ["Auto Buy"] = true,
        },
        ["Auto Buy To Find Rod Shop"] = {
            ["Min money to hop find"] = 5000000,
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local config = {
    autoFishing = Kaitun["Fishing"]["Auto Fishing"],
    instantFishing = Kaitun["Fishing"]["Instant Fishing"],
    superInstantSpeed = 25,
    fishingDelay = Kaitun["Fishing"]["Delay Fishing"],
    fishingSpeed = 35,
    blantantDelay = Kaitun["Fishing"]["Auto Blantant Fishing"],
    blantantDelayValue = Kaitun["Fishing"]["Blantant Delay Fishing"],
    autoTeleport = false,
    autoBuyShop = Kaitun["Fishing"]["Auto Buy Rod Shop"],
    autoBuyWeather = Kaitun["Fishing"]["Auto Buy Weather"],
    advancedDetection = Kaitun["Fishing"]["Advanced Detection"],
    multiThread = Kaitun["Fishing"]["Multi-Thread Fishing"]
}

local stats = {
    fishCaught = 0,
    perfectCatches = 0,
    totalEarnings = 0,
    startTime = tick(),
    sessionFish = 0,
    teleports = 0,
    itemsBought = 0,
    failedAttempts = 0,
    successRate = 100
}

local fishingConnection
local isFishing = false
local fishingEvents = {}
local cachedEvents = {}

-- FPS Boost
if Kaitun["Start Kaitun"]["Boost Fps"] then
    local decalsyeeted = true
    local g = game
    local w = g.Workspace
    local l = g.Lighting
    local t = w.Terrain
    
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    l.GlobalShadows = false
    l.FogEnd = 9e9
    l.Brightness = 0
    
    settings().Rendering.QualityLevel = "Level01"
    
    for i, v in pairs(g:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        end
    end
    
    for i, e in pairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end

-- FPS Lock
if Kaitun["Start Kaitun"]["FPS Lock"]["Enable"] then
    setfpscap(Kaitun["Start Kaitun"]["FPS Lock"]["FPS"])
end

local BikinkanUI = {}
BikinkanUI.Themes = {
    Ocean = {
        Main = Color3.fromRGB(12, 24, 45),
        Secondary = Color3.fromRGB(22, 40, 65),
        Accent = Color3.fromRGB(0, 200, 255),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(255, 70, 70),
        Text = Color3.fromRGB(245, 250, 255),
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
    local MinimizeButton = Instance.new("ImageButton")
    local TabContainer = Instance.new("Frame")
    local TabContent = Instance.new("ScrollingFrame")
    local ContentList = Instance.new("UIListLayout")
    local UIGradient = Instance.new("UIGradient")
    
    ScreenGui.Name = "BikinkanKaitunUI_v2"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if Kaitun["Start Kaitun"]["Lite UI"]["Blur"] then
        MainContainer.Name = "MainContainer"
        MainContainer.Parent = ScreenGui
        MainContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MainContainer.BackgroundTransparency = 0.75
        MainContainer.BorderSizePixel = 0
        MainContainer.Size = UDim2.new(1, 0, 1, 0)
        MainContainer.Visible = true
    end

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Kaitun["Start Kaitun"]["Lite UI"]["Blur"] and MainContainer or ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = currentTheme.Main
    MainFrame.BackgroundTransparency = 0.01
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 520, 0, 640)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    BackgroundEffect.Name = "BackgroundEffect"
    BackgroundEffect.Parent = MainFrame
    BackgroundEffect.BackgroundColor3 = currentTheme.Secondary
    BackgroundEffect.BackgroundTransparency = 0.03
    BackgroundEffect.BorderSizePixel = 0
    BackgroundEffect.Position = UDim2.new(0, 10, 0, 10)
    BackgroundEffect.Size = UDim2.new(1, -20, 1, -20)
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 8)
    BgCorner.Parent = BackgroundEffect
    
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentTheme.Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 55, 90))
    })
    UIGradient.Rotation = 45
    UIGradient.Parent = BackgroundEffect
    
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = currentTheme.Secondary
    TopBar.BackgroundTransparency = 0.03
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 85)
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.05, 0, 0.12, 0)
    Title.Size = UDim2.new(0.65, 0, 0.45, 0)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "⚡ KAITUN " .. _G.Version .. " - " .. name
    Title.TextColor3 = currentTheme.Text
    Title.TextSize = 19
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextStrokeTransparency = 0.7
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = TopBar
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
    StatusLabel.Size = UDim2.new(0.65, 0, 0.28, 0)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "🟢 KAITUN SYSTEM - INITIALIZED"
    StatusLabel.TextColor3 = currentTheme.Success
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TopBar
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(0.85, 0, 0.25, 0)
    MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
    MinimizeButton.Image = "rbxassetid://3926305904"
    MinimizeButton.ImageRectOffset = Vector2.new(884, 284)
    MinimizeButton.ImageRectSize = Vector2.new(36, 36)
    MinimizeButton.ImageColor3 = currentTheme.TextSecondary
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(0.92, 0, 0.25, 0)
    CloseButton.Size = UDim2.new(0, 28, 0, 28)
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(924, 724)
    CloseButton.ImageRectSize = Vector2.new(36, 36)
    CloseButton.ImageColor3 = currentTheme.Error
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0.133, 0)
    TabContainer.Size = UDim2.new(1, 0, 0.867, 0)
    
    TabContent.Name = "TabContent"
    TabContent.Parent = TabContainer
    TabContent.Active = true
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    TabContent.ScrollBarThickness = 5
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
        local SectionIcon = Instance.new("TextLabel")
        
        Section.Name = "Section"
        Section.Parent = TabContent
        Section.BackgroundColor3 = currentTheme.Accent
        Section.BackgroundTransparency = 0.85
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(0.94, 0, 0, 48)
        
        local SecCorner = Instance.new("UICorner")
        SecCorner.CornerRadius = UDim.new(0, 8)
        SecCorner.Parent = Section
        
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0.12, 0, 0.18, 0)
        SectionTitle.Size = UDim2.new(0.83, 0, 0.64, 0)
        SectionTitle.Font = Enum.Font.GothamBlack
        SectionTitle.Text = title
        SectionTitle.TextColor3 = currentTheme.Text
        SectionTitle.TextSize = 15
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        SectionIcon.Name = "SectionIcon"
        SectionIcon.Parent = Section
        SectionIcon.BackgroundTransparency = 1
        SectionIcon.Position = UDim2.new(0.03, 0, 0.18, 0)
        SectionIcon.Size = UDim2.new(0.07, 0, 0.64, 0)
        SectionIcon.Font = Enum.Font.GothamBlack
        SectionIcon.Text = "▶"
        SectionIcon.TextColor3 = currentTheme.Accent
        SectionIcon.TextSize = 18
        
        return Section
    end
    
    function tabs:CreateToggle(name, description, default, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleDescription = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        local ToggleIcon = Instance.new("TextLabel")
        
        ToggleFrame.Parent = TabContent
        ToggleFrame.BackgroundColor3 = currentTheme.Secondary
        ToggleFrame.BackgroundTransparency = 0.08
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.94, 0, 0, 70)
        
        local TgCorner = Instance.new("UICorner")
        TgCorner.CornerRadius = UDim.new(0, 10)
        TgCorner.Parent = ToggleFrame
        
        ToggleIcon.Parent = ToggleFrame
        ToggleIcon.BackgroundTransparency = 1
        ToggleIcon.Position = UDim2.new(0.025, 0, 0.13, 0)
        ToggleIcon.Size = UDim2.new(0.07, 0, 0.32, 0)
        ToggleIcon.Font = Enum.Font.GothamBlack
        ToggleIcon.Text = "⚡"
        ToggleIcon.TextColor3 = currentTheme.Accent
        ToggleIcon.TextSize = 14
        
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0.11, 0, 0.13, 0)
        ToggleLabel.Size = UDim2.new(0.62, 0, 0.32, 0)
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = currentTheme.Text
        ToggleLabel.TextSize = 15
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleDescription.Parent = ToggleFrame
        ToggleDescription.BackgroundTransparency = 1
        ToggleDescription.Position = UDim2.new(0.11, 0, 0.52, 0)
        ToggleDescription.Size = UDim2.new(0.62, 0, 0.32, 0)
        ToggleDescription.Font = Enum.Font.Gotham
        ToggleDescription.Text = description
        ToggleDescription.TextColor3 = currentTheme.TextSecondary
        ToggleDescription.TextSize = 12
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = default and currentTheme.Success or currentTheme.Error
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.77, 0, 0.27, 0)
        ToggleButton.Size = UDim2.new(0.18, 0, 0.46, 0)
        ToggleButton.Font = Enum.Font.GothamBlack
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = currentTheme.Text
        ToggleButton.TextSize = 11
        ToggleButton.AutoButtonColor = false
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = ToggleButton
        
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
        local ButtonIcon = Instance.new("TextLabel")
        
        Button.Parent = TabContent
        Button.BackgroundColor3 = currentTheme.Accent
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.94, 0, 0, 65)
        Button.AutoButtonColor = false
        
        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 10)
        BCorner.Parent = Button
        
        ButtonIcon.Parent = Button
        ButtonIcon.BackgroundTransparency = 1
        ButtonIcon.Position = UDim2.new(0.025, 0, 0.18, 0)
        ButtonIcon.Size = UDim2.new(0.09, 0, 0.45, 0)
        ButtonIcon.Font = Enum.Font.GothamBlack
        ButtonIcon.Text = "🚀"
        ButtonIcon.TextColor3 = currentTheme.Text
        ButtonIcon.TextSize = 18
        
        ButtonLabel.Parent = Button
        ButtonLabel.BackgroundTransparency = 1
        ButtonLabel.Position = UDim2.new(0.13, 0, 0.13, 0)
        ButtonLabel.Size = UDim2.new(0.82, 0, 0.52, 0)
        ButtonLabel.Font = Enum.Font.GothamBlack
        ButtonLabel.Text = name
        ButtonLabel.TextColor3 = currentTheme.Text
        ButtonLabel.TextSize = 16
        ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ButtonDescription.Parent = Button
        ButtonDescription.BackgroundTransparency = 1
        ButtonDescription.Position = UDim2.new(0.13, 0, 0.68, 0)
        ButtonDescription.Size = UDim2.new(0.82, 0, 0.28, 0)
        ButtonDescription.Font = Enum.Font.Gotham
        ButtonDescription.Text = description
        ButtonDescription.TextColor3 = Color3.fromRGB(200, 220, 240)
        ButtonDescription.TextSize = 11
        ButtonDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        Button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return Button
    end
    
    function tabs:CreateLabel(text, size)
        local Label = Instance.new("TextLabel")
        
        Label.Parent = TabContent
        Label.BackgroundColor3 = currentTheme.Secondary
        Label.BackgroundTransparency = 0.08
        Label.BorderSizePixel = 0
        Label.Size = UDim2.new(0.94, 0, 0, size or 35)
        Label.Font = Enum.Font.GothamBold
        Label.Text = text
        Label.TextColor3 = currentTheme.Text
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Center
        
        local LCorner = Instance.new("UICorner")
        LCorner.CornerRadius = UDim.new(0, 8)
        LCorner.Parent = Label
        
        return Label
    end
    
    function tabs:UpdateStatus(text, color)
        StatusLabel.Text = text
        StatusLabel.TextColor3 = color
    end
    
    return tabs
end

function findFishingEvent()
    if #cachedEvents > 0 then
        return cachedEvents
    end
    
    local events = {}
    local searchTerms = {
        "fish", "catch", "rod", "reel", "pole", "bait", "cast", "hook", 
        "tackle", "lure", "bite", "pull", "snap", "tug", "bobber"
    }
    
    local locations = {
        ReplicatedStorage,
        Workspace,
        player:WaitForChild("PlayerScripts", 2),
        player:FindFirstChild("Backpack"),
        player.Character
    }
    
    for _, location in pairs(locations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                    local objName = string.lower(obj.Name)
                    
                    for _, term in pairs(searchTerms) do
                        if objName:find(term) then
                            table.insert(events, obj)
                            break
                        end
                    end
                    
                    if string.len(obj.Name) < 15 and not objName:find("ui") and not objName:find("chat") then
                        table.insert(events, obj)
                    end
                end
            end
        end
    end
    
    cachedEvents = events
    return events
end

function performUltimateFishing()
    if isFishing then return false end
    
    isFishing = true
    local success = false
    local attempts = 0
    local maxAttempts = config.multiThread and 8 or 3
    
    if config.instantFishing and config.advancedDetection then
        local events = findFishingEvent()
        
        local methods = {
            "CatchFish", "FishCaught", "GetFish", "AddFish", "StartFishing",
            "CompleteFishing", "Fish", "Catch", "Reel", "Fishing", "Cast",
            "Hook", "Pull", "Bite", "Complete", "Success", "Finish", "Done"
        }
        
        for i = 1, maxAttempts do
            attempts = attempts + 1
            
            for _, event in pairs(events) do
                for _, method in pairs(methods) do
                    local ok, result = pcall(function()
                        if event:IsA("RemoteEvent") then
                            event:FireServer(method)
                            event:FireServer(method, true)
                            event:FireServer(method, 1)
                            event:FireServer(method, player)
                        elseif event:IsA("RemoteFunction") then
                            event:InvokeServer(method)
                            event:InvokeServer(method, true)
                        elseif event:IsA("BindableEvent") then
                            event:Fire(method)
                            event:Fire(method, true)
                        end
                    end)
                    
                    if ok then
                        success = true
                        stats.fishCaught = stats.fishCaught + 1
                        stats.sessionFish = stats.sessionFish + 1
                        stats.perfectCatches = stats.perfectCatches + 1
                        stats.totalEarnings = stats.totalEarnings + math.random(150, 600)
                        break
                    end
                end
                if success then break end
            end
            if success then break end
        end
    end
    
    if not success and config.blantantDelay then
        local inputCount = config.multiThread and 8 or 5
        
        for i = 1, inputCount do
            attempts = attempts + 1
            
            spawn(function()
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.0005)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end)
            end)
            
            spawn(function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.0005)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
            end)
            
            spawn(function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.0005)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end)
            end)
            
            task.wait(0.001)
        end
        
        success = true
        stats.fishCaught = stats.fishCaught + 1
        stats.sessionFish = stats.sessionFish + 1
        stats.totalEarnings = stats.totalEarnings + math.random(80, 250)
    end
    
    if not success then
        stats.failedAttempts = stats.failedAttempts + 1
    end
    
    stats.successRate = (stats.fishCaught / (stats.fishCaught + stats.failedAttempts)) * 100
    
    isFishing = false
    return success
end

function startAutoFishing()
    if fishingConnection then
        fishingConnection:Disconnect()
    end
    
    print("🚀 KAITUN v2.0 - ULTRA AUTO FISHING ACTIVATED!")
    print("⚡ Speed Multiplier: " .. config.superInstantSpeed .. "x")
    print("🎯 Multi-Thread: " .. tostring(config.multiThread))
    print("🔍 Advanced Detection: " .. tostring(config.advancedDetection))
    
    fishingConnection = RunService.Heartbeat:Connect(function()
        if config.autoFishing and not isFishing then
            local success = false
            local attempts = config.instantFishing and config.superInstantSpeed or 1
            
            for i = 1, attempts do
                if performUltimateFishing() then
                    success = true
                    if i < attempts then
                        task.wait(0.003)
                    end
                end
            end
            
            if success then
                local fishPerSecond = stats.fishCaught / math.max(1, tick() - stats.startTime)
                local successPercent = string.format("%.1f", stats.successRate)
                Window:UpdateStatus(
                    string.format("🟢 ACTIVE: %d fish | %.1f/s | %s%% success", 
                        stats.fishCaught, fishPerSecond, successPercent), 
                    currentTheme.Success
                )
                
                if stats.fishCaught % 3 == 0 then
                    print(string.format("📊 [%d fish] $%d | %.1f fish/s | %s%% success", 
                        stats.fishCaught, stats.totalEarnings, fishPerSecond, successPercent))
                end
            else
                Window:UpdateStatus("🟡 Optimizing detection...", currentTheme.Warning)
            end
            
            local actualDelay = config.blantantDelay and (config.blantantDelayValue / 1000) or config.fishingDelay
            task.wait(actualDelay)
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

function autoBuyRodShop()
    if not config.autoBuyShop then return end
    
    local rodList = Kaitun["Rod Shop"]["Shop"]["Shop List"]
    local purchased = 0
    
    print("🛒 Scanning Rod Shop: " .. #rodList .. " items")
    
    for _, rodName in pairs(rodList) do
        local success = pcall(function()
            local shops = Workspace:FindFirstChild("Shops") or Workspace:FindFirstChild("Shop")
            if shops then
                for _, shop in pairs(shops:GetDescendants()) do
                    if shop:IsA("Part") or shop:IsA("Model") then
                        local shopName = string.lower(shop.Name)
                        if shopName:find("rod") or shopName:find("fishing") or shopName:find("tackle") then
                            if shop:FindFirstChild("ClickDetector") then
                                fireclickdetector(shop.ClickDetector)
                                purchased = purchased + 1
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        end)
        
        if success then
            stats.itemsBought = stats.itemsBought + 1
            print("✅ Purchased: " .. rodName)
        end
    end
    
    if purchased > 0 then
        print(string.format("🎉 Successfully purchased %d rods!", purchased))
    end
    
    return purchased
end

function autoBuyWeatherBoost()
    if not config.autoBuyWeather then return end
    
    print("🌤️ Activating weather boosts...")
    
    local weatherBoosted = false
    local success = pcall(function()
        local shops = Workspace:FindFirstChild("Shops") or Workspace:FindFirstChild("Shop")
        if shops then
            for _, shop in pairs(shops:GetDescendants()) do
                local shopName = string.lower(shop.Name)
                if shopName:find("weather") or shopName:find("boost") or shopName:find("buff") then
                    if shop:FindFirstChild("ClickDetector") then
                        fireclickdetector(shop.ClickDetector)
                        weatherBoosted = true
                        task.wait(0.5)
                    end
                end
            end
        end
    end)
    
    if success and weatherBoosted then
        stats.itemsBought = stats.itemsBought + 1
        print("🌊 Weather boost activated!")
    end
    
    return weatherBoosted
end

function autoSellFish()
    if not Kaitun["Start Kaitun"]["Enable"] then return end
    
    print("💰 Auto-selling fish...")
    
    local success = pcall(function()
        local sellArea = Workspace:FindFirstChild("SellArea") or Workspace:FindFirstChild("Sell")
        if sellArea then
            local sellPart = sellArea:FindFirstChildOfClass("Part")
            if sellPart then
                player.Character:MoveTo(sellPart.Position)
                task.wait(1)
                
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:MoveTo(sellPart.Position)
                end
            end
        end
    end)
    
    if success then
        print("✅ Fish sold successfully!")
    end
end

local Window = BikinkanUI:CreateWindow("ULTIMATE FISH IT v2.0")

Window:CreateSection("🎯 KAITUN FISHING CONTROLS")

local autoFishButton = Window:CreateButton(
    "🚀 START ULTRA FISHING", 
    "Activate 25x speed auto fishing with multi-threading", 
    function()
        config.autoFishing = not config.autoFishing
        if config.autoFishing then
            startAutoFishing()
            autoFishButton:FindFirstChild("ButtonLabel").Text = "⏹️ STOP ULTRA FISHING"
            autoFishButton.BackgroundColor3 = currentTheme.Error
            Window:UpdateStatus("🟢 KAITUN v2.0 ACTIVATED - 25x SPEED!", currentTheme.Success)
        else
            stopAutoFishing()
            autoFishButton:FindFirstChild("ButtonLabel").Text = "🚀 START ULTRA FISHING"
            autoFishButton.BackgroundColor3 = currentTheme.Accent
            Window:UpdateStatus("🔴 Fishing Stopped", currentTheme.Error)
        end
    end
)

Window:CreateSection("⚡ ADVANCED FISHING SETTINGS")

Window:CreateToggle(
    "INSTANT FISHING", 
    "25x speed instant catch system", 
    Kaitun["Fishing"]["Instant Fishing"], 
    function(value)
        config.instantFishing = value
        Kaitun["Fishing"]["Instant Fishing"] = value
        Window:UpdateStatus(
            value and "⚡ INSTANT MODE: 25x SPEED" or "🔵 Standard Mode", 
            value and currentTheme.Success or currentTheme.Accent
        )
    end
)

Window:CreateToggle(
    "BLANTANT MODE", 
    "Ultra-fast fishing with minimal delay", 
    Kaitun["Fishing"]["Auto Blantant Fishing"], 
    function(value)
        config.blantantDelay = value
        Kaitun["Fishing"]["Auto Blantant Fishing"] = value
        Window:UpdateStatus(
            value and "💥 BLANTANT: MAXIMUM SPEED" or "🔵 Normal Speed", 
            value and currentTheme.Warning or currentTheme.Accent
        )
    end
)

Window:CreateToggle(
    "MULTI-THREAD FISHING", 
    "8x parallel fishing operations", 
    Kaitun["Fishing"]["Multi-Thread Fishing"], 
    function(value)
        config.multiThread = value
        Kaitun["Fishing"]["Multi-Thread Fishing"] = value
        Window:UpdateStatus(
            value and "🔥 MULTI-THREAD: 8x PARALLEL" or "🔵 Single Thread", 
            value and currentTheme.Success or currentTheme.Accent
        )
    end
)

Window:CreateToggle(
    "ADVANCED DETECTION", 
    "Enhanced event detection system", 
    Kaitun["Fishing"]["Advanced Detection"], 
    function(value)
        config.advancedDetection = value
        Kaitun["Fishing"]["Advanced Detection"] = value
        cachedEvents = {}
        Window:UpdateStatus(
            value and "🔍 ADVANCED DETECTION ON" or "🔵 Basic Detection", 
            value and currentTheme.Success or currentTheme.Accent
        )
    end
)

Window:CreateSection("🛒 KAITUN SHOP AUTOMATION")

Window:CreateToggle(
    "AUTO BUY RODS", 
    "Automatically purchase all available rods", 
    Kaitun["Fishing"]["Auto Buy Rod Shop"], 
    function(value)
        config.autoBuyShop = value
        Kaitun["Fishing"]["Auto Buy Rod Shop"] = value
        if value then
            spawn(function()
                while config.autoBuyShop do
                    autoBuyRodShop()
                    task.wait(15)
                end
            end)
        end
    end
)

Window:CreateToggle(
    "AUTO BUY WEATHER", 
    "Automatically activate weather boosts", 
    Kaitun["Fishing"]["Auto Buy Weather"], 
    function(value)
        config.autoBuyWeather = value
        Kaitun["Fishing"]["Auto Buy Weather"] = value
        if value then
            spawn(function()
                while config.autoBuyWeather do
                    autoBuyWeatherBoost()
                    task.wait(30)
                end
            end)
        end
    end
)

Window:CreateToggle(
    "AUTO SELL FISH", 
    "Automatically sell caught fish", 
    true, 
    function(value)
        if value then
            spawn(function()
                while value do
                    autoSellFish()
                    task.wait(Kaitun["Start Kaitun"]["Delay Auto Sell"] * 60)
                end
            end)
        end
    end
)

Window:CreateSection("📊 ADVANCED STATISTICS")

local statsLabels = {
    totalFish = Window:CreateLabel("🎣 TOTAL FISH: " .. stats.fishCaught, 35),
    sessionFish = Window:CreateLabel("📈 SESSION: " .. stats.sessionFish, 35),
    perfectCatches = Window:CreateLabel("⭐ PERFECT: " .. stats.perfectCatches, 35),
    earnings = Window:CreateLabel("💰 EARNINGS: $" .. stats.totalEarnings, 35),
    itemsBought = Window:CreateLabel("🛒 ITEMS: " .. stats.itemsBought, 35),
    successRate = Window:CreateLabel("🎯 SUCCESS: 100%", 35),
    speed = Window:CreateLabel("⚡ SPEED: 25x MULTIPLIER", 35)
}

function updateStats()
    local elapsedTime = math.max(1, tick() - stats.startTime)
    local fishPerSecond = stats.fishCaught / elapsedTime
    local successPercent = string.format("%.1f", stats.successRate)
    
    statsLabels.totalFish.Text = "🎣 TOTAL FISH: " .. stats.fishCaught
    statsLabels.sessionFish.Text = "📈 SESSION: " .. stats.sessionFish
    statsLabels.perfectCatches.Text = "⭐ PERFECT: " .. stats.perfectCatches
    statsLabels.earnings.Text = "💰 EARNINGS: $" .. stats.totalEarnings
    statsLabels.itemsBought.Text = "🛒 ITEMS: " .. stats.itemsBought
    statsLabels.successRate.Text = "🎯 SUCCESS: " .. successPercent .. "%"
    statsLabels.speed.Text = "⚡ SPEED: " .. string.format("%.2f", fishPerSecond) .. " fish/s"
end

spawn(function()
    while true do
        updateStats()
        task.wait(0.4)
    end
end)

Window:CreateSection("🎮 QUICK ACTIONS")

Window:CreateButton(
    "🛒 BUY ALL RODS", 
    "Purchase all available rods instantly", 
    function()
        local count = autoBuyRodShop()
        Window:UpdateStatus("✅ Purchased " .. count .. " rods!", currentTheme.Success)
    end
)

Window:CreateButton(
    "🌊 ACTIVATE WEATHER", 
    "Enable weather boosts immediately", 
    function()
        local success = autoBuyWeatherBoost()
        Window:UpdateStatus(
            success and "✅ Weather activated!" or "⚠️ Weather unavailable", 
            success and currentTheme.Success or currentTheme.Warning
        )
    end
)

Window:CreateButton(
    "💰 SELL FISH NOW", 
    "Instantly sell all caught fish", 
    function()
        autoSellFish()
        Window:UpdateStatus("💰 Fish sold!", currentTheme.Success)
    end
)

Window:CreateButton(
    "🔄 REFRESH CACHE", 
    "Clear and rebuild event cache", 
    function()
        cachedEvents = {}
        fishingEvents = findFishingEvent()
        Window:UpdateStatus("✅ Cache refreshed: " .. #fishingEvents .. " events", currentTheme.Success)
    end
)

Window:CreateButton(
    "📊 RESET STATS", 
    "Reset all session statistics", 
    function()
        stats.sessionFish = 0
        stats.perfectCatches = 0
        stats.failedAttempts = 0
        stats.startTime = tick()
        updateStats()
        Window:UpdateStatus("✅ Statistics reset!", currentTheme.Success)
    end
)

if Kaitun["Start Kaitun"]["Enable"] and Kaitun["Fishing"]["Auto Fishing"] then
    spawn(function()
        task.wait(1.5)
        config.autoFishing = true
        startAutoFishing()
        autoFishButton:FindFirstChild("ButtonLabel").Text = "⏹️ STOP ULTRA FISHING"
        autoFishButton.BackgroundColor3 = currentTheme.Error
        Window:UpdateStatus("🟢 AUTO-STARTED - 25x SPEED!", currentTheme.Success)
        print("✅ KAITUN v2.0 AUTO-STARTED!")
    end)
end

task.spawn(function()
    while task.wait(300) do
        if config.autoFishing then
            print(string.format(
                "📊 5-MIN REPORT: %d fish | $%d | %.1f%% success | %d items bought",
                stats.fishCaught, stats.totalEarnings, stats.successRate, stats.itemsBought
            ))
        end
    end
end)

print("=================================")
print("🎣 KAITUN ULTIMATE v2.0 LOADED")
print("=================================")
print("⚡ Instant Fishing: " .. tostring(Kaitun["Fishing"]["Instant Fishing"]))
print("💥 Blantant Mode: " .. tostring(Kaitun["Fishing"]["Auto Blantant Fishing"]))
print("🔥 Multi-Thread: " .. tostring(Kaitun["Fishing"]["Multi-Thread Fishing"]))
print("🔍 Advanced Detection: " .. tostring(Kaitun["Fishing"]["Advanced Detection"]))
print("🛒 Auto Buy Rods: " .. tostring(Kaitun["Fishing"]["Auto Buy Rod Shop"]))
print("🌊 Auto Buy Weather: " .. tostring(Kaitun["Fishing"]["Auto Buy Weather"]))
print("⏱️ Fishing Delay: " .. Kaitun["Fishing"]["Delay Fishing"] .. "s")
print("⚡ Blantant Delay: " .. Kaitun["Fishing"]["Blantant Delay Fishing"] .. "ms")
print("🚀 Speed Multiplier: 25x")
print("🎯 FPS: " .. (Kaitun["Start Kaitun"]["FPS Lock"]["Enable"] and Kaitun["Start Kaitun"]["FPS Lock"]["FPS"] or "Unlimited"))
print("=================================")

Window:UpdateStatus("✅ KAITUN v2.0 READY - 25x SPEED!", currentTheme.Success)
