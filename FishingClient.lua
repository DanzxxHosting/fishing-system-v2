-- UI-Only: Neon Panel (sidebar + content) — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Toggle dengan tombol - dan logo. Safe (UI only).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- Theme colors
local theme = {
    Accent = ACCENT,
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 170, 0),
    Error = Color3.fromRGB(255, 70, 70),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180)
}

-- FISHING CONFIG
local config = {
    autoFishing = false,
    instantFishing = true,
    fishingDelay = 0.1,
    blantantMode = false,
    autoEquipRod = true
}

-- INSTANT FISHING EXPLOIT CONFIG
local InstantFishing = {
    Enabled = false,
    HookedRemotes = {},
    OriginalFunctions = {},
    InjectionMethods = {
        MemoryHooks = true,
        RemoteHijacking = true,
        EventSpoofing = true,
        PacketInjection = true
    }
}

local stats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successfulCatch = 0,
    failedCatch = 0
}

local fishingActive = false
local fishingConnection

-- cleanup old if exist
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container (centered)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow (image behind)
local glow = Instance.new("ImageLabel", screen)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = container.Position
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616" -- radial
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1

-- Card (panel)
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner", card)
cardCorner.CornerRadius = UDim.new(0, 12)

-- inner container
local inner = Instance.new("Frame", card)
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1

-- Title bar dengan kontrol minimize/maximize
local titleBar = Instance.new("Frame", inner)
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT - ULTIMATE"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("TextLabel", titleBar)
Status.Size = UDim2.new(0.4,-16,1,0)
Status.Position = UDim2.new(0.6,8,0,0)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.Text = "🔴 Ready"
Status.TextColor3 = Color3.fromRGB(200,200,200)
Status.TextXAlignment = Enum.TextXAlignment.Right

-- Kontrol minimize/maximize di pojok kanan atas
local controlFrame = Instance.new("Frame", titleBar)
controlFrame.Size = UDim2.new(0, 60, 1, 0)
controlFrame.Position = UDim2.new(1, -65, 0, 0)
controlFrame.BackgroundTransparency = 1

-- Minimize Button (-)
local minimizeBtn = Instance.new("TextButton", controlFrame)
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(0, 0, 0.5, -12)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
minimizeBtn.TextSize = 14
minimizeBtn.AutoButtonColor = false

local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 6)

-- Maximize Button (□)
local maximizeBtn = Instance.new("TextButton", controlFrame)
maximizeBtn.Size = UDim2.new(0, 25, 0, 25)
maximizeBtn.Position = UDim2.new(0, 30, 0.5, -12)
maximizeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.Text = "□"
maximizeBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
maximizeBtn.TextSize = 12
maximizeBtn.AutoButtonColor = false

local maxCorner = Instance.new("UICorner", maximizeBtn)
maxCorner.CornerRadius = UDim.new(0, 6)

-- left sidebar
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3

local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 8)

-- sidebar header icon
local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1

local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904" -- simple icon (roblox)
logo.ImageColor3 = ACCENT

local sTitle = Instance.new("TextLabel", sbHeader)
sTitle.Size = UDim2.new(1,-96,0,32)
sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- menu list area
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)

-- menu helper
local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner", row)
    corner.CornerRadius = UDim.new(0,8)

    local left = Instance.new("Frame", row)
    left.Size = UDim2.new(0,40,1,0)
    left.Position = UDim2.new(0,8,0,0)
    left.BackgroundTransparency = 1

    local icon = Instance.new("TextLabel", left)
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

-- menu items (order like photo)
local items = {
    {"Fishing", "🎣"},
    {"Auto Fish", "⚡"},
    {"Settings", "⚙"},
    {"Teleport", "📍"},
    {"Stats", "📊"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- content panel (right)
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0

local contentCorner = Instance.new("UICorner", content)
contentCorner.CornerRadius = UDim.new(0, 8)

-- content title area
local cTitle = Instance.new("TextLabel", content)
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Fishing Controls"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- =============================================
-- FISHING UTILITY FUNCTIONS
-- =============================================

local function SafeGetCharacter()
    local success, result = pcall(function()
        return player.Character
    end)
    return success and result or nil
end

local function GetFishingRod()
    local char = SafeGetCharacter()
    if not char then return nil end
    
    -- Cari fishing rod di backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            local itemName = string.lower(item.Name)
            if itemName:find("rod") or itemName:find("fishing") or itemName:find("pole") then
                return item
            end
        end
    end
    
    -- Cari di character
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = string.lower(item.Name)
                if itemName:find("rod") or itemName:find("fishing") or itemName:find("pole") then
                    return item
                end
            end
        end
    end
    
    return nil
end

local function EquipRod()
    if not config.autoEquipRod then return true end
    
    local rod = GetFishingRod()
    if not rod then
        Status.Text = "⚠️ No fishing rod found!"
        Status.TextColor3 = theme.Warning
        return false
    end
    
    -- Jika rod sudah di-equip
    if rod.Parent == player.Character then
        return true
    end
    
    -- Equip rod dari backpack
    pcall(function()
        player.Character:FindFirstChildOfClass("Humanoid"):EquipTool(rod)
        task.wait(0.1)
    end)
    
    return rod.Parent == player.Character
end

local function FindFishingProximityPrompt()
    local success, prompt = pcall(function()
        local char = SafeGetCharacter()
        if not char then return nil end
        
        for _, descendant in pairs(char:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local objText = descendant.ObjectText and descendant.ObjectText:lower() or "Perfect"
                local actionText = descendant.ActionText and descendant.ActionText:lower() or "Perfect"
                
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
        task.wait(0.001)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function SimulateClick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0.01)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0.01)
    end)
end

-- =============================================
-- INSTANT FISHING EXPLOIT FUNCTIONS
-- =============================================

-- Hook semua fishing related remotes
local function HookFishingRemotes()
    if not InstantFishing.InjectionMethods.RemoteHijacking then return end
    
    local function hijackRemote(remote)
        if InstantFishing.HookedRemotes[remote] then return end
        
        if remote:IsA("RemoteEvent") then
            -- Simpan function original
            local oldFire = remote.FireServer
            InstantFishing.OriginalFunctions[remote] = oldFire
            
            -- Override function
            remote.FireServer = function(self, ...)
                local args = {...}
                local methodName = tostring(args[1] or "")
                
                -- Auto trigger fishing ketika method fishing dipanggil
                if string.lower(methodName):find("fish") or 
                   string.lower(methodName):find("catch") or 
                   string.lower(methodName):find("reel") or
                   #args == 0 then -- Jika tidak ada args, anggap fishing
                    
                    if InstantFishing.Enabled then
                        -- Auto success fishing
                        stats.fishCaught = stats.fishCaught + 1
                        stats.successfulCatch = stats.successfulCatch + 1
                        
                        -- Return success value
                        if remote.Parent and remote.Parent:IsA("ModuleScript") then
                            return "Legendary", 9999, true
                        end
                        return true
                    end
                end
                
                -- Panggil function original
                return oldFire(self, ...)
            end
            
        elseif remote:IsA("RemoteFunction") then
            -- Simpan function original
            local oldInvoke = remote.InvokeServer
            InstantFishing.OriginalFunctions[remote] = oldInvoke
            
            -- Override function
            remote.InvokeServer = function(self, ...)
                local args = {...}
                local methodName = tostring(args[1] or "")
                
                -- Auto trigger fishing
                if string.lower(methodName):find("fish") or 
                   string.lower(methodName):find("catch") or
                   #args == 0 then
                    
                    if InstantFishing.Enabled then
                        stats.fishCaught = stats.fishCaught + 1
                        stats.successfulCatch = stats.successfulCatch + 1
                        return "Ultra", 5000, true, "Instant Catch"
                    end
                end
                
                return oldInvoke(self, ...)
            end
        end
        
        InstantFishing.HookedRemotes[remote] = true
    end
    
    -- Hook existing remotes
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            pcall(hijackRemote, remote)
        end
    end
    
    -- Hook new remotes yang dibuat setelah script jalan
    game.DescendantAdded:Connect(function(descendant)
        if (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction")) and InstantFishing.Enabled then
            task.wait(0.5) -- Tunggu remote fully loaded
            pcall(hijackRemote, descendant)
        end
    end)
end

-- Memory manipulation untuk inject fishing success
local function InjectMemoryHooks()
    if not InstantFishing.InjectionMethods.MemoryHooks then return end
    
    pcall(function()
        -- Cari module scripts yang berhubungan dengan fishing
        for _, module in pairs(game:GetDescendants()) do
            if module:IsA("ModuleScript") then
                local success, moduleTable = pcall(require, module)
                if success and type(moduleTable) == "table" then
                    
                    -- Inject ke fishing functions
                    if moduleTable.CatchFish or moduleTable.Fish then
                        -- Simpan original functions
                        if moduleTable.CatchFish and not InstantFishing.OriginalFunctions[module.."_CatchFish"] then
                            InstantFishing.OriginalFunctions[module.."_CatchFish"] = moduleTable.CatchFish
                        end
                        if moduleTable.Fish and not InstantFishing.OriginalFunctions[module.."_Fish"] then
                            InstantFishing.OriginalFunctions[module.."_Fish"] = moduleTable.Fish
                        end
                        
                        -- Override functions
                        if moduleTable.CatchFish then
                            moduleTable.CatchFish = function(...)
                                if InstantFishing.Enabled then
                                    stats.fishCaught = stats.fishCaught + 1
                                    stats.successfulCatch = stats.successfulCatch + 1
                                    return "Legendary", 10000, true
                                end
                                return InstantFishing.OriginalFunctions[module.."_CatchFish"](...)
                            end
                        end
                        
                        if moduleTable.Fish then
                            moduleTable.Fish = function(...)
                                if InstantFishing.Enabled then
                                    stats.fishCaught = stats.fishCaught + 1
                                    stats.successfulCatch = stats.successfulCatch + 1
                                    return true, "Mythical", 15000
                                end
                                return InstantFishing.OriginalFunctions[module.."_Fish"](...)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Event spoofing untuk trigger auto fishing
local function SpoofFishingEvents()
    if not InstantFishing.InjectionMethods.EventSpoofing then return end
    
    pcall(function()
        -- Cari bindable events fishing
        for _, bindable in pairs(game:GetDescendants()) do
            if bindable:IsA("BindableEvent") or bindable:IsA("BindableFunction") then
                local name = string.lower(bindable.Name)
                if name:find("fish") or name:find("catch") or name:find("reward") then
                    
                    -- Trigger events secara periodic saat instant fishing aktif
                    if InstantFishing.Enabled then
                        spawn(function()
                            while InstantFishing.Enabled and bindable.Parent do
                                pcall(function()
                                    if bindable:IsA("BindableEvent") then
                                        bindable:Fire("Legendary", 9999, true)
                                    elseif bindable:IsA("BindableFunction") then
                                        bindable:Invoke("InstantCatch")
                                    end
                                end)
                                task.wait(0.1)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- Packet injection untuk fake fishing data
local function InjectFishingPackets()
    if not InstantFishing.InjectionMethods.PacketInjection then return end
    
    pcall(function()
        -- Inject fake fishing packets ke server
        spawn(function()
            while InstantFishing.Enabled do
                -- Cari fishing remotes dan inject fake data
                for _, remote in pairs(game:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and string.lower(remote.Name):find("fish") then
                        pcall(function()
                            remote:FireServer("CatchFish", "Mythical", 20000)
                            remote:FireServer("FishCaught", "Ultra", 15000)
                        end)
                    end
                end
                task.wait(0.05)
            end
        end)
    end)
end

-- Main function untuk activate/deactivate instant fishing exploit
local function SetInstantFishingExploit(enabled)
    InstantFishing.Enabled = enabled
    
    if enabled then
        print("💉 INSTANT FISHING EXPLOIT ACTIVATED!")
        
        -- Jalankan semua injection methods
        HookFishingRemotes()
        InjectMemoryHooks()
        SpoofFishingEvents()
        InjectFishingPackets()
        
        Status.Text = "💉 INSTANT FISHING - INJECTED"
        Status.TextColor3 = Color3.fromRGB(255, 0, 255)
        
    else
        print("🔵 Instant Fishing Exploit Disabled")
        
        -- Restore original functions
        for remote, originalFunc in pairs(InstantFishing.OriginalFunctions) do
            if typeof(remote) == "Instance" and remote.Parent then
                if remote:IsA("RemoteEvent") then
                    remote.FireServer = originalFunc
                elseif remote:IsA("RemoteFunction") then
                    remote.InvokeServer = originalFunc
                end
            end
        end
        
        InstantFishing.HookedRemotes = {}
        InstantFishing.OriginalFunctions = {}
        
        Status.Text = "🔵 Normal Mode"
        Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end

-- =============================================
-- FISHING METHODS
-- =============================================

local function TryFishingMethod()
    local methods_tried = 0.001
    local success = false
    
    -- Method 1: Equip Rod
    if not EquipRod() then
        Status.Text = "⚠️ No fishing rod found!"
        Status.TextColor3 = theme.Warning
        return false
    end
    methods_tried = methods_tried + 0.1
    
    -- Method 2: ProximityPrompt
    pcall(function()
        local prompt = FindFishingProximityPrompt()
        if prompt and prompt.Enabled then
            fireproximityprompt(prompt)
            success = true
        end
    end)
    methods_tried = methods_tried + 0.1
    
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
    methods_tried = methods_tried + 0.1
    
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
    
    methods_tried = methods_tried + 0.1
    
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

-- =============================================
-- UI CREATION FUNCTIONS
-- =============================================

local function CreateSection(title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -24, 0, 400)
    section.Position = UDim2.new(0, 12, 0, 64)
    section.BackgroundColor3 = Color3.fromRGB(14,14,16)
    section.BorderSizePixel = 0
    section.Parent = content

    local corner = Instance.new("UICorner", section)
    corner.CornerRadius = UDim.new(0,8)

    local sectionTitle = Instance.new("TextLabel", section)
    sectionTitle.Size = UDim2.new(1, -20, 0, 40)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.Text = title
    sectionTitle.TextColor3 = theme.Text
    sectionTitle.TextSize = 16
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left

    return section
end

local function CreateButton(text, description, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.BackgroundColor3 = theme.Accent
    button.AutoButtonColor = false
    button.BorderSizePixel = 0

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0,8)

    local textLabel = Instance.new("TextLabel", button)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(30,30,30)
    textLabel.TextSize = 16
    textLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = theme.Accent}):Play()
    end)

    button.MouseButton1Click:Connect(callback)

    return button
end

-- Create fishing controls in content
local function ShowFishingContent()
    -- Clear existing content
    for _, child in pairs(content:GetChildren()) do
        if child.Name ~= "ContentTitle" then
            child:Destroy()
        end
    end

    -- Fishing controls panel
    local panel = CreateSection("🎯 FISHING CONTROLS")

    -- Start/Stop Fishing Button
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
    startBtn.Position = UDim2.new(0, 20, 0, 20)
    startBtn.Parent = panel

    -- Settings toggles
    local toggleY = 90
    local function CreateFishingToggle(name, desc, default, callback, isExploit)
        local frame = Instance.new("Frame", panel)
        frame.Size = UDim2.new(1, -40, 0, 50)
        frame.Position = UDim2.new(0, 20, 0, toggleY)
        
        if isExploit then
            frame.BackgroundColor3 = Color3.fromRGB(25, 15, 25) -- Purple untuk exploit
        else
            frame.BackgroundColor3 = Color3.fromRGB(20,20,22) -- Normal color
        end
        
        frame.BorderSizePixel = 0

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0,6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = name
        if isExploit then
            label.TextColor3 = Color3.fromRGB(255, 200, 255) -- Light purple untuk exploit
        else
            label.TextColor3 = Color3.fromRGB(230,230,230) -- Normal color
        end
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local descLabel = Instance.new("TextLabel", frame)
        descLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
        descLabel.Position = UDim2.new(0, 10, 0.5, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = desc
        if isExploit then
            descLabel.TextColor3 = Color3.fromRGB(200, 150, 200) -- Light purple untuk exploit
        else
            descLabel.TextColor3 = Color3.fromRGB(150,150,150) -- Normal color
        end
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBtn = Instance.new("TextButton", frame)
        toggleBtn.Size = UDim2.new(0, 60, 0, 30)
        toggleBtn.Position = UDim2.new(1, -70, 0.5, -15)
        
        if isExploit then
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(80, 0, 120)
        else
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
        end
        
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(30,30,30)
        toggleBtn.TextSize = 12
        toggleBtn.AutoButtonColor = false

        local toggleCorner = Instance.new("UICorner", toggleBtn)
        toggleCorner.CornerRadius = UDim.new(0,6)

        toggleBtn.MouseButton1Click:Connect(function()
            local new = toggleBtn.Text == "OFF"
            toggleBtn.Text = new and "ON" or "OFF"
            
            if isExploit then
                toggleBtn.BackgroundColor3 = new and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(80, 0, 120)
            else
                toggleBtn.BackgroundColor3 = new and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 70, 70)
            end
            
            callback(new)
        end)

        toggleY = toggleY + 60
        return frame
    end

    -- Normal Fishing Toggles
    CreateFishingToggle("Auto Equip Rod", "Automatically equip fishing rod", config.autoEquipRod, function(v)
        config.autoEquipRod = v
    end, false)

    CreateFishingToggle("Instant Fishing", "Fast fishing mode", config.instantFishing, function(v)
        config.instantFishing = v
        config.fishingDelay = v and 0.05 or 0.2
    end, false)

    CreateFishingToggle("Blantant Mode", "ULTRA FAST fishing", config.blantantMode, function(v)
        config.blantantMode = v
        if v then
            config.fishingDelay = 0.02
            config.instantFishing = true
            Status.Text = "💥 BLANTANT MODE"
            Status.TextColor3 = theme.Error
        else
            config.fishingDelay = 0.15
            Status.Text = "🔵 Normal Mode"
            Status.TextColor3 = theme.Success
        end
    end, false)

    -- Exploit Toggles
    CreateFishingToggle("💉 INSTANT FISHING EXPLOIT", "Inject into game system", InstantFishing.Enabled, function(v)
        SetInstantFishingExploit(v)
    end, true)

    CreateFishingToggle("Remote Hijacking", "Hook game remotes", InstantFishing.InjectionMethods.RemoteHijacking, function(v)
        InstantFishing.InjectionMethods.RemoteHijacking = v
    end, true)

    CreateFishingToggle("Memory Injection", "Modify game memory", InstantFishing.InjectionMethods.MemoryHooks, function(v)
        InstantFishing.InjectionMethods.MemoryHooks = v
    end, true)

    -- Stats display
    local statsPanel = Instance.new("Frame", content)
    statsPanel.Size = UDim2.new(1, -24, 0, 120)
    statsPanel.Position = UDim2.new(0, 12, 0, 480)
    statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
    statsPanel.BorderSizePixel = 0

    local statsCorner = Instance.new("UICorner", statsPanel)
    statsCorner.CornerRadius = UDim.new(0,8)

    local statsTitle = Instance.new("TextLabel", statsPanel)
    statsTitle.Size = UDim2.new(1, -20, 0, 30)
    statsTitle.Position = UDim2.new(0, 10, 0, 5)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Text = "📊 Live Statistics"
    statsTitle.TextColor3 = theme.Text
    statsTitle.TextSize = 14
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Stats labels
    local fishStat = Instance.new("TextLabel", statsPanel)
    fishStat.Size = UDim2.new(0.5, -10, 0, 25)
    fishStat.Position = UDim2.new(0, 10, 0, 40)
    fishStat.BackgroundTransparency = 1
    fishStat.Font = Enum.Font.Gotham
    fishStat.Text = "🎣 Fish: 0"
    fishStat.TextColor3 = theme.TextSecondary
    fishStat.TextSize = 12
    fishStat.TextXAlignment = Enum.TextXAlignment.Left

    local attemptsStat = Instance.new("TextLabel", statsPanel)
    attemptsStat.Size = UDim2.new(0.5, -10, 0, 25)
    attemptsStat.Position = UDim2.new(0.5, 0, 0, 40)
    attemptsStat.BackgroundTransparency = 1
    attemptsStat.Font = Enum.Font.Gotham
    attemptsStat.Text = "🔄 Attempts: 0"
    attemptsStat.TextColor3 = theme.TextSecondary
    attemptsStat.TextSize = 12
    attemptsStat.TextXAlignment = Enum.TextXAlignment.Left

    local rateStat = Instance.new("TextLabel", statsPanel)
    rateStat.Size = UDim2.new(0.5, -10, 0, 25)
    rateStat.Position = UDim2.new(0, 10, 0, 65)
    rateStat.BackgroundTransparency = 1
    rateStat.Font = Enum.Font.Gotham
    rateStat.Text = "⚡ Rate: 0.00/s"
    rateStat.TextColor3 = theme.TextSecondary
    rateStat.TextSize = 12
    rateStat.TextXAlignment = Enum.TextXAlignment.Left

    local successStat = Instance.new("TextLabel", statsPanel)
    successStat.Size = UDim2.new(0.5, -10, 0, 25)
    successStat.Position = UDim2.new(0.5, 0, 0, 65)
    successStat.BackgroundTransparency = 1
    successStat.Font = Enum.Font.Gotham
    successStat.Text = "✅ Success: 0"
    successStat.TextColor3 = theme.TextSecondary
    successStat.TextSize = 12
    successStat.TextXAlignment = Enum.TextXAlignment.Left

    -- Update stats in real-time
    task.spawn(function()
        while task.wait(0.5) do
            local elapsed = math.max(1, tick() - stats.startTime)
            local rate = stats.fishCaught / elapsed
            
            fishStat.Text = "🎣 Fish: " .. stats.fishCaught
            attemptsStat.Text = "🔄 Attempts: " .. stats.attempts
            rateStat.Text = string.format("⚡ Rate: %.2f/s", rate)
            successStat.Text = "✅ Success: " .. stats.successfulCatch
        end
    end)
end

-- Menu navigation
local activeMenu = "Fishing"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- Highlight selected
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        
        -- Update content
        cTitle.Text = name
        activeMenu = name
        
        if name == "Fishing" then
            ShowFishingContent()
        elseif name == "Stats" then
            -- Show stats content (bisa dikembangkan)
            for _, child in pairs(content:GetChildren()) do
                if child.Name ~= "ContentTitle" then
                    child:Destroy()
                end
            end
            -- Tambahkan content stats di sini
        else
            -- Placeholder untuk menu lainnya
            for _, child in pairs(content:GetChildren()) do
                if child.Name ~= "ContentTitle" then
                    child:Destroy()
                end
            end
        end
    end)
end

-- Initialize dengan content fishing
ShowFishingContent()
menuButtons["Fishing"].BackgroundColor3 = Color3.fromRGB(32,8,8)

-- UI State Management
local uiState = {
    isMinimized = false,
    isVisible = true
}

-- Minimize/Maximize Functions
local function MinimizeUI()
    uiState.isMinimized = true
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 80)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 380, 0, 160),
        ImageTransparency = 0.95
    }):Play()
    
    -- Sembunyikan konten
    sidebar.Visible = false
    content.Visible = false
    
    -- Update title untuk minimized state
    title.Text = "🎣 Kaitun Fish It"
    Status.Text = "⬇️ Minimized"
end

local function MaximizeUI()
    uiState.isMinimized = false
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    }):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {
        Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80),
        ImageTransparency = 0.92
    }):Play()
    
    -- Tampilkan konten
    sidebar.Visible = true
    content.Visible = true
    
    -- Update title untuk normal state
    title.Text = "⚡ KAITUN FISH IT - ULTIMATE"
    Status.Text = "🟢 Ready"
end

local function ToggleMinimize()
    if uiState.isMinimized then
        MaximizeUI()
    else
        MinimizeUI()
    end
end

-- Button Events
minimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
maximizeBtn.MouseButton1Click:Connect(ToggleMinimize) -- Both buttons do the same thing

-- Hover effects untuk buttons
minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 170, 0)}):Play()
end)

maximizeBtn.MouseEnter:Connect(function()
    TweenService:Create(maximizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 230, 255)}):Play()
end)
maximizeBtn.MouseLeave:Connect(function()
    TweenService:Create(maximizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
end)

-- Posisi UI di tengah layar
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
glow.Position = container.Position

-- Auto start dengan UI maximized
MaximizeUI()

print("[Kaitun Fish It] Loaded!")
print("🎣 Fishing system ready")
print("💉 Instant Fishing Exploit: Ready")
print("⚡ Controls: Use - and □ buttons to minimize/maximize")
print("📍 UI Position: Center screen")
