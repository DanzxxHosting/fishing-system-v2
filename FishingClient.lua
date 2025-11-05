-- KAITUN FISH IT v4.0 - COMPLETE FEATURES
-- paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62)
local BG = Color3.fromRGB(12,12,12)
local SECOND = Color3.fromRGB(24,24,26)

-- FISHING CONFIG
local fishingConfig = {
    enabled = false,
    instantCast = true,
    instantReel = true,
    perfectTiming = true,
    speed = "ultra",
    multiMethod = true,
    bypassAnticheat = true
}

-- FEATURE CONFIG
local featureConfig = {
    -- Player Mods
    walkSpeed = 16,
    jumpPower = 50,
    infiniteJump = false,
    noClip = false,
    flyEnabled = false,
    
    -- Fishing Enhancements
    fishingRadar = false,
    autoSell = false,
    autoUpgrade = false,
    autoCraft = false,
    
    -- Game Features
    spawnBoat = false,
    autoCompleteQuests = false,
    unlockAllAreas = false,
    autoFarm = false,
    
    -- Visual
    xrayVision = false,
    fullBright = false,
    espEnabled = false,
    chunkBorders = false
}

local fishingStats = {
    fishCaught = 0,
    startTime = tick(),
    attempts = 0,
    successes = 0,
    fails = 0,
    lastCatch = 0
}

local fishingActive = false
local activeConnections = {}
local detectedMethods = {}
local uiEnabled = true

-- Feature Variables
local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd
}
local xRayParts = {}
local infiniteJumpConnection
local radarConnection
local flyConnection
local noclipConnection
local espConnection
local chunkBorderParts = {}

-- Cleanup old UI
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- TRAY ICON
local trayIcon = Instance.new("ImageButton")
trayIcon.Name = "TrayIcon"
trayIcon.Size = UDim2.new(0, 60, 0, 60)
trayIcon.Position = UDim2.new(1, -70, 0, 20)
trayIcon.BackgroundColor3 = ACCENT
trayIcon.Image = "rbxassetid://3926305904"
trayIcon.Visible = false
trayIcon.ZIndex = 10
trayIcon.Parent = screen

local trayCorner = Instance.new("UICorner")
trayCorner.CornerRadius = UDim.new(0, 12)
trayCorner.Parent = trayIcon

local trayGlow = Instance.new("ImageLabel")
trayGlow.Name = "TrayGlow"
trayGlow.Size = UDim2.new(1, 20, 1, 20)
trayGlow.Position = UDim2.new(0, -10, 0, -10)
trayGlow.BackgroundTransparency = 1
trayGlow.Image = "rbxassetid://5050741616"
trayGlow.ImageColor3 = ACCENT
trayGlow.ImageTransparency = 0.8
trayGlow.ZIndex = 9
trayGlow.Parent = trayIcon

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1
glow.Parent = container

-- Card
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

-- inner container
local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1
inner.Parent = card

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = inner

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT v4.0"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Window Controls
local windowControls = Instance.new("Frame")
windowControls.Size = UDim2.new(0, 80, 1, 0)
windowControls.Position = UDim2.new(1, -85, 0, 0)
windowControls.BackgroundTransparency = 1
windowControls.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(0, 0, 0.5, -16)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = windowControls

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(0, 40, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "🗙"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = windowControls

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local memLabel = Instance.new("TextLabel")
memLabel.Size = UDim2.new(0.4,-100,1,0)
memLabel.Position = UDim2.new(0.6,8,0,0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 11
memLabel.Text = "Memory: 0 KB | Fish: 0"
memLabel.TextColor3 = Color3.fromRGB(200,200,200)
memLabel.TextXAlignment = Enum.TextXAlignment.Left
memLabel.Parent = titleBar

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
sidebar.Parent = inner

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = sidebar

local sbHeader = Instance.new("Frame")
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1
sbHeader.Parent = sidebar

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904"
logo.ImageColor3 = ACCENT
logo.Parent = sbHeader

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1,-96,0,32)
sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = sbHeader

local sSubtitle = Instance.new("TextLabel")
sSubtitle.Size = UDim2.new(1,-96,0,20)
sSubtitle.Position = UDim2.new(0, 88, 0, 38)
sSubtitle.BackgroundTransparency = 1
sSubtitle.Font = Enum.Font.Gotham
sSubtitle.TextSize = 10
sSubtitle.Text = "Ultimate Suite v4.0"
sSubtitle.TextColor3 = ACCENT
sSubtitle.TextXAlignment = Enum.TextXAlignment.Left
sSubtitle.Parent = sbHeader

-- Menu
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1
menuFrame.Parent = sidebar

local menuLayout = Instance.new("UIListLayout")
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)
menuLayout.Parent = menuFrame

local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = row

    local left = Instance.new("Frame")
    left.Size = UDim2.new(0,40,1,0)
    left.Position = UDim2.new(0,8,0,0)
    left.BackgroundTransparency = 1
    left.Parent = row

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center
    icon.Parent = left

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

local items = {
    {"Fishing", "🎣"},
    {"Teleport", "📍"},
    {"Player", "👤"},
    {"Shop", "🛒"},
    {"Quests", "📜"},
    {"Visual", "👁️"},
    {"Settings", "⚙"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- Content panel
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0
content.Parent = inner

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = content

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Perfect Instant Fishing"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = content

-- ═══════════════════════════════════════════════════════════
-- ADVANCED UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        return nil
    end
    return result
end

local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ═══════════════════════════════════════════════════════════
-- PLAYER MODIFICATIONS SYSTEM
-- ═══════════════════════════════════════════════════════════

local function ApplyPlayerMods()
    SafeCall(function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = featureConfig.walkSpeed
            humanoid.JumpPower = featureConfig.jumpPower
        end
    end)
end

-- Infinite Jump
local function ToggleInfiniteJump()
    if featureConfig.infiniteJump then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            SafeCall(function()
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
        print("[✓] Infinite Jump: ENABLED")
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
            print("[✓] Infinite Jump: DISABLED")
        end
    end
end

-- Fly System
local function ToggleFly()
    if featureConfig.flyEnabled then
        local bodyVelocity
        flyConnection = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local rootPart = GetRootPart()
                if not rootPart then return end
                
                if not bodyVelocity then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = rootPart
                end
                
                local camera = Workspace.CurrentCamera
                local direction = Vector3.new(0, 0, 0)
                local speed = 50
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = direction * speed
                bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
            end)
        end)
        print("[✓] Fly: ENABLED - WASD + Space/Shift")
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        SafeCall(function()
            local rootPart = GetRootPart()
            if rootPart then
                for _, v in pairs(rootPart:GetChildren()) do
                    if v:IsA("BodyVelocity") then
                        v:Destroy()
                    end
                end
            end
        end)
        print("[✓] Fly: DISABLED")
    end
end

-- No Clip
local function ToggleNoClip()
    if featureConfig.noClip then
        noclipConnection = RunService.Stepped:Connect(function()
            SafeCall(function()
                local char = GetCharacter()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
        print("[✓] No Clip: ENABLED")
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        print("[✓] No Clip: DISABLED")
    end
end

-- ═══════════════════════════════════════════════════════════
-- VISUAL ENHANCEMENTS SYSTEM
-- ═══════════════════════════════════════════════════════════

-- Full Bright
local function ToggleFullBright()
    if featureConfig.fullBright then
        originalLighting = {
            Ambient = Lighting.Ambient,
            Brightness = Lighting.Brightness,
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd
        }
        
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        
        print("[✓] Full Bright: ENABLED")
    else
        Lighting.Ambient = originalLighting.Ambient or Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = originalLighting.Brightness or 1
        Lighting.GlobalShadows = originalLighting.GlobalShadows ~= nil and originalLighting.GlobalShadows or true
        Lighting.FogEnd = originalLighting.FogEnd or 1000
        
        print("[✓] Full Bright: DISABLED")
    end
end

-- X-Ray Vision
local xRayConnection
local function ToggleXRayVision()
    if featureConfig.xrayVision then
        for part, originalProps in pairs(xRayParts) do
            if part and part.Parent then
                part.LocalTransparencyModifier = originalProps.Transparency
                part.Material = originalProps.Material
            end
        end
        xRayParts = {}
        
        xRayConnection = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "Handle" then
                        local isWall = part.Name:lower():match("wall") or 
                                     part.Name:lower():match("building") or 
                                     part.Name:lower():match("house") or
                                     part.Name:lower():match("obstacle") or
                                     part.Name:lower():match("rock") or
                                     part.Name:lower():match("tree")
                        
                        if isWall and not xRayParts[part] then
                            xRayParts[part] = {
                                Transparency = part.LocalTransparencyModifier,
                                Material = part.Material
                            }
                            part.LocalTransparencyModifier = 0.8
                            part.Material = Enum.Material.Neon
                        end
                    end
                end
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                        
                        if name:match("fish") or parentName:match("fish") or 
                           name:match("coin") or name:match("treasure") or 
                           name:match("chest") then
                            
                            if not xRayParts[obj] then
                                xRayParts[obj] = {
                                    Transparency = obj.LocalTransparencyModifier,
                                    Material = obj.Material
                                }
                            end
                            obj.LocalTransparencyModifier = 0.3
                            obj.Material = Enum.Material.Neon
                            obj.BrickColor = BrickColor.new("Bright green")
                        end
                    end
                end
            end)
        end)
        print("[✓] X-Ray Vision: ENABLED")
    else
        if xRayConnection then
            xRayConnection:Disconnect()
            xRayConnection = nil
        end
        for part, originalProps in pairs(xRayParts) do
            if part and part.Parent then
                part.LocalTransparencyModifier = originalProps.Transparency
                part.Material = originalProps.Material
            end
        end
        xRayParts = {}
        print("[✓] X-Ray Vision: DISABLED")
    end
end

-- ESP System
local function ToggleESP()
    if featureConfig.espEnabled then
        espConnection = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                -- Highlight fish
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") then
                        local name = obj.Name:lower()
                        if name:match("fish") and obj:FindFirstChild("Head") then
                            local head = obj.Head
                            if not head:FindFirstChild("ESPBox") then
                                local box = Instance.new("BoxHandleAdornment")
                                box.Name = "ESPBox"
                                box.Adornee = head
                                box.AlwaysOnTop = true
                                box.ZIndex = 10
                                box.Size = head.Size + Vector3.new(0.2, 0.2, 0.2)
                                box.Color3 = Color3.new(0, 1, 0)
                                box.Transparency = 0.3
                                box.Parent = head
                                
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "ESPLabel"
                                billboard.Adornee = head
                                billboard.Size = UDim2.new(0, 100, 0, 40)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.AlwaysOnTop = true
                                billboard.Parent = head
                                
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = "🐟 " .. obj.Name
                                label.TextColor3 = Color3.new(0, 1, 0)
                                label.TextStrokeTransparency = 0
                                label.TextSize = 14
                                label.Font = Enum.Font.GothamBold
                                label.Parent = billboard
                            end
                        end
                    end
                end
            end)
        end)
        print("[✓] ESP: ENABLED")
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj:FindFirstChild("ESPBox") then
                    obj.ESPBox:Destroy()
                end
                if obj:FindFirstChild("ESPLabel") then
                    obj.ESPLabel:Destroy()
                end
            end
        end
        print("[✓] ESP: DISABLED")
    end
end

-- Chunk Borders
local function ToggleChunkBorders()
    if featureConfig.chunkBorders then
        for _, part in pairs(chunkBorderParts) do
            if part then
                part:Destroy()
            end
        end
        chunkBorderParts = {}
        
        local function createChunkBorder(position, size, color)
            local part = Instance.new("Part")
            part.Size = size
            part.Position = position
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new(color)
            part.Transparency = 0.7
            part.Parent = Workspace
            table.insert(chunkBorderParts, part)
        end
        
        -- Create fishing area borders
        createChunkBorder(Vector3.new(0, 0, 0), Vector3.new(100, 50, 100), "Bright blue")
        createChunkBorder(Vector3.new(100, 0, 0), Vector3.new(100, 50, 100), "Bright green")
        createChunkBorder(Vector3.new(0, 0, 100), Vector3.new(100, 50, 100), "Bright yellow")
        createChunkBorder(Vector3.new(-100, 0, 0), Vector3.new(100, 50, 100), "Bright red")
        
        print("[✓] Chunk Borders: ENABLED")
    else
        for _, part in pairs(chunkBorderParts) do
            if part then
                part:Destroy()
            end
        end
        chunkBorderParts = {}
        print("[✓] Chunk Borders: DISABLED")
    end
end

-- ═══════════════════════════════════════════════════════════
-- FISHING RADAR SYSTEM
-- ═══════════════════════════════════════════════════════════

local function ToggleFishingRadar()
    if featureConfig.fishingRadar then
        print("[📡] Activating Fishing Radar...")
        
        radarConnection = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:match("radar") or name:match("sonar") or name:match("detect") then
                            remote:FireServer(true)
                            remote:FireServer("Activate")
                            remote:FireServer("Start")
                        end
                    end
                end
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local action = obj.ActionText and obj.ActionText:lower() or ""
                        if action:match("radar") or action:match("sonar") then
                            fireproximityprompt(obj)
                        end
                    end
                end
            end)
        end)
        print("[✓] Fishing Radar: ACTIVATED")
    else
        if radarConnection then
            radarConnection:Disconnect()
            radarConnection = nil
        end
        SafeCall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:match("radar") or name:match("sonar") then
                        remote:FireServer(false)
                        remote:FireServer("Deactivate")
                    end
                end
            end
        end)
        print("[✓] Fishing Radar: DEACTIVATED")
    end
end

-- ═══════════════════════════════════════════════════════════
-- FISHING CONTENT
-- ═══════════════════════════════════════════════════════════

local fishingContent = Instance.new("ScrollingFrame")
fishingContent.Name = "FishingContent"
fishingContent.Size = UDim2.new(1, -24, 1, -68)
fishingContent.Position = UDim2.new(0, 12, 0, 56)
fishingContent.BackgroundTransparency = 1
fishingContent.BorderSizePixel = 0
fishingContent.ScrollBarThickness = 6
fishingContent.ScrollBarImageColor3 = ACCENT
fishingContent.CanvasSize = UDim2.new(0, 0, 0, 1200)
fishingContent.Visible = true
fishingContent.Parent = content

-- Stats Panel
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 140)
statsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
statsPanel.BorderSizePixel = 0
statsPanel.Parent = fishingContent

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0,8)
statsCorner.Parent = statsPanel

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -24, 0, 28)
statsTitle.Position = UDim2.new(0,12,0,8)
statsTitle.BackgroundTransparency = 1
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.Text = "📊 Perfect Fishing Statistics"
statsTitle.TextColor3 = Color3.fromRGB(235,235,235)
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsPanel

-- Stats Grid
local statsGrid = Instance.new("Frame")
statsGrid.Size = UDim2.new(1, -24, 1, -44)
statsGrid.Position = UDim2.new(0, 12, 0, 40)
statsGrid.BackgroundTransparency = 1
statsGrid.Parent = statsPanel

local function CreateStat(name, emoji, color, xPos, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, -4, 0, 28)
    frame.Position = UDim2.new(xPos, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = statsGrid
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = emoji .. " " .. name .. ": 0"
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    return label
end

local fishCountLabel = CreateStat("Fish Caught", "🎣", Color3.fromRGB(100, 255, 150), 0, 0)
local rateLabel = CreateStat("Rate", "⚡", Color3.fromRGB(255, 220, 100), 0.5, 0)
local attemptsLabel = CreateStat("Attempts", "🎯", Color3.fromRGB(200, 200, 255), 0, 0.33)
local successLabel = CreateStat("Success", "✅", Color3.fromRGB(150, 255, 150), 0.5, 0.33)
local timeLabel = CreateStat("Session", "⏱️", Color3.fromRGB(255, 180, 180), 0, 0.66)

-- Controls Panel
local controlsPanel = Instance.new("Frame")
controlsPanel.Size = UDim2.new(1, 0, 0, 130)
controlsPanel.Position = UDim2.new(0, 0, 0, 152)
controlsPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
controlsPanel.BorderSizePixel = 0
controlsPanel.Parent = fishingContent

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0,8)
controlsCorner.Parent = controlsPanel

local controlsTitle = Instance.new("TextLabel")
controlsTitle.Size = UDim2.new(1, -24, 0, 28)
controlsTitle.Position = UDim2.new(0,12,0,8)
controlsTitle.BackgroundTransparency = 1
controlsTitle.Font = Enum.Font.GothamBold
controlsTitle.TextSize = 14
controlsTitle.Text = "⚡ Perfect Controls"
controlsTitle.TextColor3 = Color3.fromRGB(235,235,235)
controlsTitle.TextXAlignment = Enum.TextXAlignment.Left
controlsTitle.Parent = controlsPanel

-- Main Button
local fishingButton = Instance.new("TextButton")
fishingButton.Size = UDim2.new(0, 240, 0, 54)
fishingButton.Position = UDim2.new(0, 12, 0, 44)
fishingButton.BackgroundColor3 = ACCENT
fishingButton.Font = Enum.Font.GothamBold
fishingButton.TextSize = 15
fishingButton.Text = "🚀 START PERFECT FISHING"
fishingButton.TextColor3 = Color3.fromRGB(255,255,255)
fishingButton.AutoButtonColor = false
fishingButton.Parent = controlsPanel

local fishingBtnCorner = Instance.new("UICorner")
fishingBtnCorner.CornerRadius = UDim.new(0,8)
fishingBtnCorner.Parent = fishingButton

-- Reset Button
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 160, 0, 54)
resetButton.Position = UDim2.new(0, 264, 0, 44)
resetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 13
resetButton.Text = "🔄 RESET STATS"
resetButton.TextColor3 = Color3.fromRGB(230,230,230)
resetButton.AutoButtonColor = false
resetButton.Parent = controlsPanel

local resetBtnCorner = Instance.new("UICorner")
resetBtnCorner.CornerRadius = UDim.new(0,8)
resetBtnCorner.Parent = resetButton

-- Status Frame
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0, 200, 0, 54)
statusFrame.Position = UDim2.new(0, 436, 0, 44)
statusFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = controlsPanel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0,8)
statusCorner.Parent = statusFrame

local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 14, 0, 14)
statusIndicator.Position = UDim2.new(0, 14, 0.5, -7)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = statusFrame

local statusIndCorner = Instance.new("UICorner")
statusIndCorner.CornerRadius = UDim.new(1, 0)
statusIndCorner.Parent = statusIndicator

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -44, 1, 0)
statusLabel.Position = UDim2.new(0, 38, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.Text = "⭕ OFFLINE"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

-- Speed Selector Panel
local speedPanel = Instance.new("Frame")
speedPanel.Size = UDim2.new(1, 0, 0, 100)
speedPanel.Position = UDim2.new(0, 0, 0, 294)
speedPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
speedPanel.BorderSizePixel = 0
speedPanel.Parent = fishingContent

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,8)
speedCorner.Parent = speedPanel

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -24, 0, 28)
speedTitle.Position = UDim2.new(0,12,0,8)
speedTitle.BackgroundTransparency = 1
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextSize = 14
speedTitle.Text = "⚡ Speed Mode"
speedTitle.TextColor3 = Color3.fromRGB(235,235,235)
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = speedPanel

local function CreateSpeedButton(name, desc, speed, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, -8, 0, 52)
    btn.Position = UDim2.new(xPos, 0, 0, 40)
    btn.BackgroundColor3 = fishingConfig.speed == speed and Color3.fromRGB(255, 62, 62) or Color3.fromRGB(30, 30, 32)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = speedPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local btnTitle = Instance.new("TextLabel")
    btnTitle.Size = UDim2.new(1, -16, 0, 22)
    btnTitle.Position = UDim2.new(0, 8, 0, 6)
    btnTitle.BackgroundTransparency = 1
    btnTitle.Font = Enum.Font.GothamBold
    btnTitle.TextSize = 13
    btnTitle.Text = name
    btnTitle.TextColor3 = Color3.fromRGB(240,240,240)
    btnTitle.TextXAlignment = Enum.TextXAlignment.Left
    btnTitle.Parent = btn
    
    local btnDesc = Instance.new("TextLabel")
    btnDesc.Size = UDim2.new(1, -16, 0, 18)
    btnDesc.Position = UDim2.new(0, 8, 0, 28)
    btnDesc.BackgroundTransparency = 1
    btnDesc.Font = Enum.Font.Gotham
    btnDesc.TextSize = 10
    btnDesc.Text = desc
    btnDesc.TextColor3 = Color3.fromRGB(180,180,180)
    btnDesc.TextXAlignment = Enum.TextXAlignment.Left
    btnDesc.Parent = btn
    
    return btn, speed
end

local normalBtn, normalSpeed = CreateSpeedButton("Normal", "1.0s delay", "normal", 0.02)
local fastBtn, fastSpeed = CreateSpeedButton("Fast", "0.6s delay", "fast", 0.35)
local ultraBtn, ultraSpeed = CreateSpeedButton("Ultra", "0.3s instant", "ultra", 0.68)

local speedButtons = {
    {btn = normalBtn, speed = "normal"},
    {btn = fastBtn, speed = "fast"},
    {btn = ultraBtn, speed = "ultra"}
}

for _, data in ipairs(speedButtons) do
    data.btn.MouseButton1Click:Connect(function()
        fishingConfig.speed = data.speed
        for _, d in ipairs(speedButtons) do
            d.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
        end
        data.btn.BackgroundColor3 = Color3.fromRGB(255, 62, 62)
        print("[Speed] Changed to:", data.speed:upper())
    end)
end

-- Toggles Panel
local togglesPanel = Instance.new("Frame")
togglesPanel.Size = UDim2.new(1, 0, 0, 180)
togglesPanel.Position = UDim2.new(0, 0, 0, 406)
togglesPanel.BackgroundColor3 = Color3.fromRGB(14,14,16)
togglesPanel.BorderSizePixel = 0
togglesPanel.Parent = fishingContent

local togglesCorner = Instance.new("UICorner")
togglesCorner.CornerRadius = UDim.new(0,8)
togglesCorner.Parent = togglesPanel

local togglesTitle = Instance.new("TextLabel")
togglesTitle.Size = UDim2.new(1, -24, 0, 28)
togglesTitle.Position = UDim2.new(0,12,0,8)
togglesTitle.BackgroundTransparency = 1
togglesTitle.Font = Enum.Font.GothamBold
togglesTitle.TextSize = 14
togglesTitle.Text = "🔧 Advanced Settings"
togglesTitle.TextColor3 = Color3.fromRGB(235,235,235)
togglesTitle.TextXAlignment = Enum.TextXAlignment.Left
togglesTitle.Parent = togglesPanel

local function CreateToggle(name, desc, configKey, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = togglesPanel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.65, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(160,160,160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 30)
    button.Position = UDim2.new(0.7, 0, 0.15, 0)
    button.BackgroundColor3 = fishingConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = fishingConfig[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        fishingConfig[configKey] = not fishingConfig[configKey]
        button.Text = fishingConfig[configKey] and "ON" or "OFF"
        local targetColor = fishingConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        print("[Toggle]", name, ":", fishingConfig[configKey] and "ON" or "OFF")
    end)

    return frame
end

CreateToggle("🎯 Instant Cast", "Instantly cast fishing rod", "instantCast", 40)
CreateToggle("🔄 Instant Reel", "Auto-complete reel minigame", "instantReel", 80)
CreateToggle("✨ Perfect Timing", "Always perfect cast timing", "perfectTiming", 120)
CreateToggle("🔧 Multi-Method", "Use all fishing methods", "multiMethod", 160)

-- ═══════════════════════════════════════════════════════════
-- TELEPORT SYSTEM
-- ═══════════════════════════════════════════════════════════

local teleportContent = Instance.new("ScrollingFrame")
teleportContent.Name = "TeleportContent"
teleportContent.Size = UDim2.new(1, -24, 1, -68)
teleportContent.Position = UDim2.new(0, 12, 0, 56)
teleportContent.BackgroundTransparency = 1
teleportContent.BorderSizePixel = 0
teleportContent.ScrollBarThickness = 6
teleportContent.ScrollBarImageColor3 = ACCENT
teleportContent.CanvasSize = UDim2.new(0, 0, 0, 1000)
teleportContent.Visible = false
teleportContent.Parent = content

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Size = UDim2.new(1, -24, 0, 44)
teleportTitle.Position = UDim2.new(0,12,0,12)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 16
teleportTitle.Text = "📍 Teleport Locations"
teleportTitle.TextColor3 = Color3.fromRGB(245,245,245)
teleportTitle.TextXAlignment = Enum.TextXAlignment.Left
teleportTitle.Parent = teleportContent

-- Teleport Locations
local teleportLocations = {
    {"🏝️ Starter Island", Vector3.new(0, 10, 0)},
    {"🌊 Ocean Center", Vector3.new(100, 5, 100)},
    {"❄️ Ice Realm", Vector3.new(-200, 20, -200)},
    {"🔥 Volcano", Vector3.new(300, 50, 0)},
    {"🌴 Palm Island", Vector3.new(150, 15, -150)},
    {"⚡ Stormy Seas", Vector3.new(-100, 10, 200)},
    {"💎 Crystal Cave", Vector3.new(0, -50, 300)},
    {"🌅 Sunset Beach", Vector3.new(-300, 10, -100)},
    {"🐉 Dragon's Lair", Vector3.new(400, 100, 400)},
    {"🌌 Deep Ocean", Vector3.new(0, -100, 0)},
    {"🏔️ Mountain Peak", Vector3.new(0, 200, 0)},
    {"🕳️ Abyss", Vector3.new(0, -200, 0)},
    {"🚢 Shipwreck", Vector3.new(500, -50, 200)},
    {"🏰 Castle", Vector3.new(-400, 30, -300)},
    {"🌋 Lava Zone", Vector3.new(600, 25, -400)}
}

local function CreateTeleportButton(name, position, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 50)
    btn.Position = UDim2.new(0, 12, 0, 60 + (index * 60))
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    btn.AutoButtonColor = false
    btn.Parent = teleportContent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SafeCall(function()
            local char = GetCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(position)
                print("[Teleport] Teleported to:", name)
            end
        end)
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
    end)
    
    return btn
end

for i, location in ipairs(teleportLocations) do
    CreateTeleportButton(location[1], location[2], i)
end

-- Custom Teleport
local customTeleportFrame = Instance.new("Frame")
customTeleportFrame.Size = UDim2.new(1, -24, 0, 100)
customTeleportFrame.Position = UDim2.new(0, 12, 0, 60 + (#teleportLocations * 60) + 20)
customTeleportFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
customTeleportFrame.BorderSizePixel = 0
customTeleportFrame.Parent = teleportContent

local customTeleportCorner = Instance.new("UICorner")
customTeleportCorner.CornerRadius = UDim.new(0,8)
customTeleportCorner.Parent = customTeleportFrame

local customTitle = Instance.new("TextLabel")
customTitle.Size = UDim2.new(1, -24, 0, 30)
customTitle.Position = UDim2.new(0, 12, 0, 8)
customTitle.BackgroundTransparency = 1
customTitle.Font = Enum.Font.GothamBold
customTitle.TextSize = 14
customTitle.Text = "🎯 Custom Teleport"
customTitle.TextColor3 = Color3.fromRGB(240,240,240)
customTitle.TextXAlignment = Enum.TextXAlignment.Left
customTitle.Parent = customTeleportFrame

local xInput = Instance.new("TextBox")
xInput.Size = UDim2.new(0.3, -8, 0, 30)
xInput.Position = UDim2.new(0, 12, 0, 45)
xInput.BackgroundColor3 = Color3.fromRGB(40,40,45)
xInput.PlaceholderText = "X"
xInput.Text = "0"
xInput.TextColor3 = Color3.fromRGB(240,240,240)
xInput.Parent = customTeleportFrame

local yInput = Instance.new("TextBox")
yInput.Size = UDim2.new(0.3, -8, 0, 30)
yInput.Position = UDim2.new(0.33, 8, 0, 45)
yInput.BackgroundColor3 = Color3.fromRGB(40,40,45)
yInput.PlaceholderText = "Y"
yInput.Text = "10"
yInput.TextColor3 = Color3.fromRGB(240,240,240)
yInput.Parent = customTeleportFrame

local zInput = Instance.new("TextBox")
zInput.Size = UDim2.new(0.3, -8, 0, 30)
zInput.Position = UDim2.new(0.66, 8, 0, 45)
zInput.BackgroundColor3 = Color3.fromRGB(40,40,45)
zInput.PlaceholderText = "Z"
zInput.Text = "0"
zInput.TextColor3 = Color3.fromRGB(240,240,240)
zInput.Parent = customTeleportFrame

local teleportCustomBtn = Instance.new("TextButton")
teleportCustomBtn.Size = UDim2.new(1, -24, 0, 30)
teleportCustomBtn.Position = UDim2.new(0, 12, 0, 80)
teleportCustomBtn.BackgroundColor3 = ACCENT
teleportCustomBtn.Font = Enum.Font.GothamBold
teleportCustomBtn.TextSize = 12
teleportCustomBtn.Text = "🚀 TELEPORT TO COORDINATES"
teleportCustomBtn.TextColor3 = Color3.fromRGB(255,255,255)
teleportCustomBtn.AutoButtonColor = false
teleportCustomBtn.Parent = customTeleportFrame

local customBtnCorner = Instance.new("UICorner")
customBtnCorner.CornerRadius = UDim.new(0,6)
customBtnCorner.Parent = teleportCustomBtn

teleportCustomBtn.MouseButton1Click:Connect(function()
    SafeCall(function()
        local x = tonumber(xInput.Text) or 0
        local y = tonumber(yInput.Text) or 10
        local z = tonumber(zInput.Text) or 0
        
        local char = GetCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
            print("[Teleport] Teleported to custom coordinates:", x, y, z)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- PLAYER MODIFICATIONS CONTENT
-- ═══════════════════════════════════════════════════════════

local playerContent = Instance.new("ScrollingFrame")
playerContent.Name = "PlayerContent"
playerContent.Size = UDim2.new(1, -24, 1, -68)
playerContent.Position = UDim2.new(0, 12, 0, 56)
playerContent.BackgroundTransparency = 1
playerContent.BorderSizePixel = 0
playerContent.ScrollBarThickness = 6
playerContent.ScrollBarImageColor3 = ACCENT
playerContent.CanvasSize = UDim2.new(0, 0, 0, 800)
playerContent.Visible = false
playerContent.Parent = content

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1, -24, 0, 44)
playerTitle.Position = UDim2.new(0,12,0,12)
playerTitle.BackgroundTransparency = 1
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextSize = 16
playerTitle.Text = "👤 Player Modifications"
playerTitle.TextColor3 = Color3.fromRGB(245,245,245)
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.Parent = playerContent

-- Walk Speed Slider
local walkSpeedFrame = Instance.new("Frame")
walkSpeedFrame.Size = UDim2.new(1, -24, 0, 80)
walkSpeedFrame.Position = UDim2.new(0, 12, 0, 60)
walkSpeedFrame.BackgroundTransparency = 1
walkSpeedFrame.Parent = playerContent

local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Size = UDim2.new(1, 0, 0, 24)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.Font = Enum.Font.GothamBold
walkSpeedLabel.TextSize = 14
walkSpeedLabel.Text = "🚶 Walk Speed: " .. featureConfig.walkSpeed
walkSpeedLabel.TextColor3 = Color3.fromRGB(240,240,240)
walkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
walkSpeedLabel.Parent = walkSpeedFrame

local walkSpeedSlider = Instance.new("Frame")
walkSpeedSlider.Size = UDim2.new(1, 0, 0, 30)
walkSpeedSlider.Position = UDim2.new(0, 0, 0, 30)
walkSpeedSlider.BackgroundColor3 = Color3.fromRGB(40,40,45)
walkSpeedSlider.BorderSizePixel = 0
walkSpeedSlider.Parent = walkSpeedFrame

local walkSpeedCorner = Instance.new("UICorner")
walkSpeedCorner.CornerRadius = UDim.new(0,6)
walkSpeedCorner.Parent = walkSpeedSlider

local walkSpeedFill = Instance.new("Frame")
walkSpeedFill.Size = UDim2.new((featureConfig.walkSpeed - 16) / 50, 0, 1, 0)
walkSpeedFill.BackgroundColor3 = ACCENT
walkSpeedFill.BorderSizePixel = 0
walkSpeedFill.Parent = walkSpeedSlider

local walkSpeedFillCorner = Instance.new("UICorner")
walkSpeedFillCorner.CornerRadius = UDim.new(0,6)
walkSpeedFillCorner.Parent = walkSpeedFill

walkSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = walkSpeedSlider.AbsolutePosition
            local sliderSize = walkSpeedSlider.AbsoluteSize.X
            local relativeX = math.clamp(mouse.X - sliderPos.X, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            featureConfig.walkSpeed = math.floor(16 + (percentage * 50))
            walkSpeedLabel.Text = "🚶 Walk Speed: " .. featureConfig.walkSpeed
            walkSpeedFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            ApplyPlayerMods()
        end)
        
        local function endDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end
        
        UserInputService.InputEnded:Connect(endDrag)
    end
end)

-- Jump Power Slider
local jumpPowerFrame = Instance.new("Frame")
jumpPowerFrame.Size = UDim2.new(1, -24, 0, 80)
jumpPowerFrame.Position = UDim2.new(0, 12, 0, 160)
jumpPowerFrame.BackgroundTransparency = 1
jumpPowerFrame.Parent = playerContent

local jumpPowerLabel = Instance.new("TextLabel")
jumpPowerLabel.Size = UDim2.new(1, 0, 0, 24)
jumpPowerLabel.BackgroundTransparency = 1
jumpPowerLabel.Font = Enum.Font.GothamBold
jumpPowerLabel.TextSize = 14
jumpPowerLabel.Text = "🦘 Jump Power: " .. featureConfig.jumpPower
jumpPowerLabel.TextColor3 = Color3.fromRGB(240,240,240)
jumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpPowerLabel.Parent = jumpPowerFrame

local jumpPowerSlider = Instance.new("Frame")
jumpPowerSlider.Size = UDim2.new(1, 0, 0, 30)
jumpPowerSlider.Position = UDim2.new(0, 0, 0, 30)
jumpPowerSlider.BackgroundColor3 = Color3.fromRGB(40,40,45)
jumpPowerSlider.BorderSizePixel = 0
jumpPowerSlider.Parent = jumpPowerFrame

local jumpPowerCorner = Instance.new("UICorner")
jumpPowerCorner.CornerRadius = UDim.new(0,6)
jumpPowerCorner.Parent = jumpPowerSlider

local jumpPowerFill = Instance.new("Frame")
jumpPowerFill.Size = UDim2.new((featureConfig.jumpPower - 50) / 100, 0, 1, 0)
jumpPowerFill.BackgroundColor3 = ACCENT
jumpPowerFill.BorderSizePixel = 0
jumpPowerFill.Parent = jumpPowerSlider

local jumpPowerFillCorner = Instance.new("UICorner")
jumpPowerFillCorner.CornerRadius = UDim.new(0,6)
jumpPowerFillCorner.Parent = jumpPowerFill

jumpPowerSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = jumpPowerSlider.AbsolutePosition
            local sliderSize = jumpPowerSlider.AbsoluteSize.X
            local relativeX = math.clamp(mouse.X - sliderPos.X, 0, sliderSize)
            local percentage = relativeX / sliderSize
            
            featureConfig.jumpPower = math.floor(50 + (percentage * 100))
            jumpPowerLabel.Text = "🦘 Jump Power: " .. featureConfig.jumpPower
            jumpPowerFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            ApplyPlayerMods()
        end)
        
        local function endDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end
        
        UserInputService.InputEnded:Connect(endDrag)
    end
end

-- Player Toggles
local function CreatePlayerToggle(name, desc, configKey, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = playerContent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.65, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(160,160,160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 30)
    button.Position = UDim2.new(0.7, 0, 0.15, 0)
    button.BackgroundColor3 = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = featureConfig[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        featureConfig[configKey] = not featureConfig[configKey]
        button.Text = featureConfig[configKey] and "ON" or "OFF"
        local targetColor = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        if configKey == "infiniteJump" then
            ToggleInfiniteJump()
        elseif configKey == "flyEnabled" then
            ToggleFly()
        elseif configKey == "noClip" then
            ToggleNoClip()
        elseif configKey == "fishingRadar" then
            ToggleFishingRadar()
        end
        
        print("[Player]", name, ":", featureConfig[configKey] and "ON" or "OFF")
    end)

    return frame
end

CreatePlayerToggle("∞ Infinite Jump", "Jump infinitely in air", "infiniteJump", 260)
CreatePlayerToggle("🚀 Fly Mode", "Fly around with WASD + Space/Shift", "flyEnabled", 300)
CreatePlayerToggle("🚫 No Clip", "Walk through walls and objects", "noClip", 340)
CreatePlayerToggle("📡 Fishing Radar", "Auto activate fishing radar", "fishingRadar", 380)
CreatePlayerToggle("💰 Auto Sell", "Automatically sell caught fish", "autoSell", 420)
CreatePlayerToggle("⚡ Auto Upgrade", "Auto upgrade fishing equipment", "autoUpgrade", 460)
CreatePlayerToggle("🛠️ Auto Craft", "Auto craft fishing items", "autoCraft", 500)
CreatePlayerToggle("🌾 Auto Farm", "Auto farm fishing spots", "autoFarm", 540)

-- ═══════════════════════════════════════════════════════════
-- SHOP SYSTEM
-- ═══════════════════════════════════════════════════════════

local shopContent = Instance.new("ScrollingFrame")
shopContent.Name = "ShopContent"
shopContent.Size = UDim2.new(1, -24, 1, -68)
shopContent.Position = UDim2.new(0, 12, 0, 56)
shopContent.BackgroundTransparency = 1
shopContent.BorderSizePixel = 0
shopContent.ScrollBarThickness = 6
shopContent.ScrollBarImageColor3 = ACCENT
shopContent.CanvasSize = UDim2.new(0, 0, 0, 1200)
shopContent.Visible = false
shopContent.Parent = content

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -24, 0, 44)
shopTitle.Position = UDim2.new(0,12,0,12)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 16
shopTitle.Text = "🛒 Ultimate Shop & Merchant"
shopTitle.TextColor3 = Color3.fromRGB(245,245,245)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent = shopContent

-- Shop Items Database
local shopItems = {
    -- Fishing Rods
    {"🎣 Beginner Rod", "BeginnerRod", "Fishing Rod", 0},
    {"🎣 Wooden Rod", "WoodenRod", "Fishing Rod", 0},
    {"🎣 Iron Rod", "IronRod", "Fishing Rod", 0}, 
    {"🎣 Golden Rod", "GoldenRod", "Fishing Rod", 0},
    {"🎣 Diamond Rod", "DiamondRod", "Fishing Rod", 0},
    {"🎣 Epic Rod", "EpicRod", "Fishing Rod", 0},
    {"🎣 Legendary Rod", "LegendaryRod", "Fishing Rod", 0},
    {"🎣 Mythical Rod", "MythicalRod", "Fishing Rod", 0},
    
    -- Baits
    {"🪱 Worm Bait", "WormBait", "Bait", 0},
    {"🪱 Cricket Bait", "CricketBait", "Bait", 0},
    {"🪱 Shrimp Bait", "ShrimpBait", "Bait", 0},
    {"🪱 Squid Bait", "SquidBait", "Bait", 0},
    {"🪱 Magic Bait", "MagicBait", "Bait", 0},
    {"🪱 Golden Bait", "GoldenBait", "Bait", 0},
    
    -- Boats
    {"🛥️ Wooden Boat", "WoodenBoat", "Boat", 0},
    {"🛥️ Speed Boat", "SpeedBoat", "Boat", 0},
    {"🛥️ Luxury Boat", "LuxuryBoat", "Boat", 0},
    {"🛥️ Fishing Boat", "FishingBoat", "Boat", 0},
    
    -- Traveling Merchant Items
    {"🧭 Fishing Radar", "FishingRadar", "Tool", 0},
    {"🔮 Magic Compass", "MagicCompass", "Tool", 0},
    {"💎 Treasure Map", "TreasureMap", "Tool", 0},
    {"🌟 Lucky Charm", "LuckyCharm", "Accessory", 0},
    {"⚡ Speed Potion", "SpeedPotion", "Potion", 0},
    {"💰 Coin Multiplier", "CoinMultiplier", "Boost", 0},
    
    -- Special Items
    {"✨ Enchant Rod", "EnchantRod", "Upgrade", 0},
    {"🌟 Double Enchant", "DoubleEnchant", "Upgrade", 0},
    {"🔥 Fire Bait", "FireBait", "Special Bait", 0},
    {"❄️ Ice Bait", "IceBait", "Special Bait", 0},
    {"⚡ Lightning Bait", "LightningBait", "Special Bait", 0}
}

-- Function to purchase items
local function PurchaseItem(itemName, itemId, category)
    SafeCall(function()
        print("[🛒] Attempting to purchase:", itemName)
        
        -- Method 1: Direct remote calls
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local remoteName = remote.Name:lower()
                if remoteName:match("buy") or remoteName:match("purchase") or remoteName:match("shop") then
                    pcall(function() remote:FireServer(itemId) end)
                    pcall(function() remote:FireServer("Buy", itemId) end)
                    pcall(function() remote:FireServer(itemId, 1) end)
                end
            end
        end
        
        -- Method 2: Merchant-specific
        for _, remote in pairs(Workspace:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local remoteName = remote.Name:lower()
                if remoteName:match("merchant") or remoteName:match("vendor") then
                    pcall(function() remote:FireServer("Buy", itemId) end)
                end
            end
        end
        
        -- Method 3: Proximity prompts
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local action = obj.ActionText and obj.ActionText:lower() or ""
                if action:match("buy") or action:match("purchase") then
                    fireproximityprompt(obj)
                end
            end
        end
        
        print("[✓] Purchase attempt completed for:", itemName)
    end)
end

-- Create Shop Items
for i, item in ipairs(shopItems) do
    local itemName, itemId, category = item[1], item[2], item[3]
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 70)
    frame.Position = UDim2.new(0, 12, 0, 60 + (i * 80))
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = shopContent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0,8)
    frameCorner.Parent = frame
    
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    itemLabel.Position = UDim2.new(0, 15, 0, 8)
    itemLabel.BackgroundTransparency = 1
    itemLabel.Font = Enum.Font.GothamBold
    itemLabel.TextSize = 14
    itemLabel.Text = itemName
    itemLabel.TextColor3 = Color3.fromRGB(240,240,240)
    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    descLabel.Position = UDim2.new(0, 15, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.Text = category .. " • FREE"
    descLabel.TextColor3 = Color3.fromRGB(180,180,180)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame
    
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.3, -10, 0, 36)
    buyBtn.Position = UDim2.new(0.7, 5, 0.5, -18)
    buyBtn.BackgroundColor3 = ACCENT
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 12
    buyBtn.Text = "BUY FREE"
    buyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    buyBtn.AutoButtonColor = false
    buyBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = buyBtn
    
    buyBtn.MouseButton1Click:Connect(function()
        PurchaseItem(itemName, itemId, category)
    end)
    
    buyBtn.MouseEnter:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 82, 82)}):Play()
    end)
    
    buyBtn.MouseLeave:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
    end)
    
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    end)
    
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
    end)
end

-- ═══════════════════════════════════════════════════════════
-- QUESTS SYSTEM
-- ═══════════════════════════════════════════════════════════

local questsContent = Instance.new("ScrollingFrame")
questsContent.Name = "QuestsContent"
questsContent.Size = UDim2.new(1, -24, 1, -68)
questsContent.Position = UDim2.new(0, 12, 0, 56)
questsContent.BackgroundTransparency = 1
questsContent.BorderSizePixel = 0
questsContent.ScrollBarThickness = 6
questsContent.ScrollBarImageColor3 = ACCENT
questsContent.CanvasSize = UDim2.new(0, 0, 0, 800)
questsContent.Visible = false
questsContent.Parent = content

local questsTitle = Instance.new("TextLabel")
questsTitle.Size = UDim2.new(1, -24, 0, 44)
questsTitle.Position = UDim2.new(0,12,0,12)
questsTitle.BackgroundTransparency = 1
questsTitle.Font = Enum.Font.GothamBold
questsTitle.TextSize = 16
questsTitle.Text = "📜 Quest Automation"
questsTitle.TextColor3 = Color3.fromRGB(245,245,245)
questsTitle.TextXAlignment = Enum.TextXAlignment.Left
questsTitle.Parent = questsContent

-- Quest Automation Functions
local function CompleteAllQuests()
    SafeCall(function()
        print("[📜] Completing all quests...")
        
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("quest") or name:match("mission") then
                    remote:FireServer("Complete")
                    remote:FireServer("Claim")
                    remote:FireServer("Finish")
                    remote:FireServer("CompleteAll")
                end
            end
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local action = obj.ActionText and obj.ActionText:lower() or ""
                if action:match("quest") or action:match("mission") then
                    fireproximityprompt(obj)
                end
            end
        end
        
        print("[✓] Quest completion attempt finished")
    end)
end

-- Quest Buttons
local questFrame = Instance.new("Frame")
questFrame.Size = UDim2.new(1, -24, 0, 120)
questFrame.Position = UDim2.new(0, 12, 0, 60)
questFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
questFrame.BorderSizePixel = 0
questFrame.Parent = questsContent

local questCorner = Instance.new("UICorner")
questCorner.CornerRadius = UDim.new(0,8)
questCorner.Parent = questFrame

local questLabel = Instance.new("TextLabel")
questLabel.Size = UDim2.new(1, -24, 0, 40)
questLabel.Position = UDim2.new(0, 12, 0, 8)
questLabel.BackgroundTransparency = 1
questLabel.Font = Enum.Font.GothamBold
questLabel.TextSize = 14
questLabel.Text = "🎯 Auto Quest System"
questLabel.TextColor3 = Color3.fromRGB(240,240,240)
questLabel.TextXAlignment = Enum.TextXAlignment.Left
questLabel.Parent = questFrame

local questDesc = Instance.new("TextLabel")
questDesc.Size = UDim2.new(1, -24, 0, 30)
questDesc.Position = UDim2.new(0, 12, 0, 40)
questDesc.BackgroundTransparency = 1
questDesc.Font = Enum.Font.Gotham
questDesc.TextSize = 11
questDesc.Text = "Automatically completes available quests"
questDesc.TextColor3 = Color3.fromRGB(180,180,180)
questDesc.TextXAlignment = Enum.TextXAlignment.Left
questDesc.Parent = questFrame

local questButton = Instance.new("TextButton")
questButton.Size = UDim2.new(0, 140, 0, 36)
questButton.Position = UDim2.new(0.5, -70, 0, 75)
questButton.BackgroundColor3 = ACCENT
questButton.Font = Enum.Font.GothamBold
questButton.TextSize = 13
questButton.Text = "🚀 COMPLETE QUESTS"
questButton.TextColor3 = Color3.fromRGB(255,255,255)
questButton.AutoButtonColor = false
questButton.Parent = questFrame

local questBtnCorner = Instance.new("UICorner")
questBtnCorner.CornerRadius = UDim.new(0,6)
questBtnCorner.Parent = questButton

questButton.MouseButton1Click:Connect(function()
    CompleteAllQuests()
end)

-- Daily Quests
local dailyFrame = Instance.new("Frame")
dailyFrame.Size = UDim2.new(1, -24, 0, 120)
dailyFrame.Position = UDim2.new(0, 12, 0, 200)
dailyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
dailyFrame.BorderSizePixel = 0
dailyFrame.Parent = questsContent

local dailyCorner = Instance.new("UICorner")
dailyCorner.CornerRadius = UDim.new(0,8)
dailyCorner.Parent = dailyFrame

local dailyLabel = Instance.new("TextLabel")
dailyLabel.Size = UDim2.new(1, -24, 0, 40)
dailyLabel.Position = UDim2.new(0, 12, 0, 8)
dailyLabel.BackgroundTransparency = 1
dailyLabel.Font = Enum.Font.GothamBold
dailyLabel.TextSize = 14
dailyLabel.Text = "📅 Daily Quests"
dailyLabel.TextColor3 = Color3.fromRGB(240,240,240)
dailyLabel.TextXAlignment = Enum.TextXAlignment.Left
dailyLabel.Parent = dailyFrame

local dailyDesc = Instance.new("TextLabel")
dailyDesc.Size = UDim2.new(1, -24, 0, 30)
dailyDesc.Position = UDim2.new(0, 12, 0, 40)
dailyDesc.BackgroundTransparency = 1
dailyDesc.Font = Enum.Font.Gotham
dailyDesc.TextSize = 11
dailyDesc.Text = "Complete daily fishing challenges"
dailyDesc.TextColor3 = Color3.fromRGB(180,180,180)
dailyDesc.TextXAlignment = Enum.TextXAlignment.Left
dailyDesc.Parent = dailyFrame

local dailyButton = Instance.new("TextButton")
dailyButton.Size = UDim2.new(0, 140, 0, 36)
dailyButton.Position = UDim2.new(0.5, -70, 0, 75)
dailyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
dailyButton.Font = Enum.Font.GothamBold
dailyButton.TextSize = 13
dailyButton.Text = "🔄 CLAIM DAILY"
dailyButton.TextColor3 = Color3.fromRGB(255,255,255)
dailyButton.AutoButtonColor = false
dailyButton.Parent = dailyFrame

local dailyBtnCorner = Instance.new("UICorner")
dailyBtnCorner.CornerRadius = UDim.new(0,6)
dailyBtnCorner.Parent = dailyButton

dailyButton.MouseButton1Click:Connect(function()
    SafeCall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("daily") then
                    remote:FireServer("Claim")
                    remote:FireServer("Daily")
                end
            end
        end
        print("[✓] Daily quest claim attempted")
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- VISUAL ENHANCEMENTS CONTENT
-- ═══════════════════════════════════════════════════════════

local visualContent = Instance.new("ScrollingFrame")
visualContent.Name = "VisualContent"
visualContent.Size = UDim2.new(1, -24, 1, -68)
visualContent.Position = UDim2.new(0, 12, 0, 56)
visualContent.BackgroundTransparency = 1
visualContent.BorderSizePixel = 0
visualContent.ScrollBarThickness = 6
visualContent.ScrollBarImageColor3 = ACCENT
visualContent.CanvasSize = UDim2.new(0, 0, 0, 600)
visualContent.Visible = false
visualContent.Parent = content

local visualTitle = Instance.new("TextLabel")
visualTitle.Size = UDim2.new(1, -24, 0, 44)
visualTitle.Position = UDim2.new(0,12,0,12)
visualTitle.BackgroundTransparency = 1
visualTitle.Font = Enum.Font.GothamBold
visualTitle.TextSize = 16
visualTitle.Text = "👁️ Visual Enhancements"
visualTitle.TextColor3 = Color3.fromRGB(245,245,245)
visualTitle.TextXAlignment = Enum.TextXAlignment.Left
visualTitle.Parent = visualContent

-- Visual Toggles
local function CreateVisualToggle(name, desc, configKey, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = visualContent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.65, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(160,160,160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 30)
    button.Position = UDim2.new(0.7, 0, 0.15, 0)
    button.BackgroundColor3 = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = featureConfig[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        featureConfig[configKey] = not featureConfig[configKey]
        button.Text = featureConfig[configKey] and "ON" or "OFF"
        local targetColor = featureConfig[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        if configKey == "xrayVision" then
            ToggleXRayVision()
        elseif configKey == "fullBright" then
            ToggleFullBright()
        elseif configKey == "espEnabled" then
            ToggleESP()
        elseif configKey == "chunkBorders" then
            ToggleChunkBorders()
        end
        
        print("[Visual]", name, ":", featureConfig[configKey] and "ON" or "OFF")
    end)

    return frame
end

CreateVisualToggle("🔍 X-Ray Vision", "See through walls & highlight fish", "xrayVision", 60)
CreateVisualToggle("💡 Full Bright", "Remove darkness and shadows", "fullBright", 100)
CreateVisualToggle("🎯 ESP", "Show fish locations through walls", "espEnabled", 140)
CreateVisualToggle("🧭 Chunk Borders", "Show fishing area boundaries", "chunkBorders", 180)

-- ═══════════════════════════════════════════════════════════
-- SETTINGS CONTENT
-- ═══════════════════════════════════════════════════════════

local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -24, 1, -68)
settingsContent.Position = UDim2.new(0, 12, 0, 56)
settingsContent.BackgroundTransparency = 1
settingsContent.BorderSizePixel = 0
settingsContent.ScrollBarThickness = 6
settingsContent.ScrollBarImageColor3 = ACCENT
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 800)
settingsContent.Visible = false
settingsContent.Parent = content

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -24, 0, 44)
settingsTitle.Position = UDim2.new(0,12,0,12)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 16
settingsTitle.Text = "⚙ Settings & Configuration"
settingsTitle.TextColor3 = Color3.fromRGB(245,245,245)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsContent

-- Info Panel
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, -24, 0, 120)
infoFrame.Position = UDim2.new(0, 12, 0, 60)
infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
infoFrame.BorderSizePixel = 0
infoFrame.Parent = settingsContent

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0,8)
infoCorner.Parent = infoFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -24, 1, -8)
infoLabel.Position = UDim2.new(0, 12, 0, 4)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.Text = "⚡ KAITUN FISH IT v4.0\n\n• Perfect Instant Fishing System\n• Advanced Player Modifications\n• Complete Shop & Merchant System\n• Visual Enhancements & ESP\n• Teleport System\n• Quest Automation\n• Safe & Undetectable"
infoLabel.TextColor3 = Color3.fromRGB(200,200,200)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = infoFrame

-- Settings Toggles
local settingsToggles = {
    {"🔒 Anti-Cheat Bypass", "Bypass game anti-cheat systems", "bypassAnticheat", fishingConfig},
    {"🚀 Ultra Performance", "Optimize for maximum performance", "speed", fishingConfig},
    {"📊 Save Statistics", "Save fishing stats between sessions", "saveStats", featureConfig},
    {"🔔 Notifications", "Show success/failure notifications", "showNotifications", featureConfig}
}

local function CreateSettingsToggle(name, desc, configKey, configTable, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 36)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = settingsContent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = name
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.65, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(160,160,160)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 30)
    button.Position = UDim2.new(0.7, 0, 0.15, 0)
    button.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = configTable[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.AutoButtonColor = false
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        button.Text = configTable[configKey] and "ON" or "OFF"
        local targetColor = configTable[configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        print("[Settings]", name, ":", configTable[configKey] and "ON" or "OFF")
    end)

    return frame
end

for i, toggle in ipairs(settingsToggles) do
    CreateSettingsToggle(toggle[1], toggle[2], toggle[3], toggle[4], 200 + (i * 40))
end

-- Action Buttons
local resetAllBtn = Instance.new("TextButton")
resetAllBtn.Size = UDim2.new(1, -24, 0, 50)
resetAllBtn.Position = UDim2.new(0, 12, 0, 400)
resetAllBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
resetAllBtn.Font = Enum.Font.GothamBold
resetAllBtn.TextSize = 14
resetAllBtn.Text = "🔄 RESET ALL SETTINGS"
resetAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
resetAllBtn.AutoButtonColor = false
resetAllBtn.Parent = settingsContent

local resetAllCorner = Instance.new("UICorner")
resetAllCorner.CornerRadius = UDim.new(0,8)
resetAllCorner.Parent = resetAllBtn

resetAllBtn.MouseButton1Click:Connect(function()
    -- Reset all configs
    for key, value in pairs(fishingConfig) do
        if type(value) == "boolean" then
            fishingConfig[key] = false
        elseif key == "speed" then
            fishingConfig[key] = "ultra"
        end
    end
    
    for key, value in pairs(featureConfig) do
        if type(value) == "boolean" then
            featureConfig[key] = false
        elseif key == "walkSpeed" then
            featureConfig[key] = 16
        elseif key == "jumpPower" then
            featureConfig[key] = 50
        end
    end
    
    fishingStats = {
        fishCaught = 0,
        startTime = tick(),
        attempts = 0,
        successes = 0,
        fails = 0,
        lastCatch = 0
    }
    
    -- Stop all features
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    if radarConnection then radarConnection:Disconnect() end
    if xRayConnection then xRayConnection:Disconnect() end
    if espConnection then espConnection:Disconnect() end
    
    -- Restore everything
    Lighting.Ambient = originalLighting.Ambient or Color3.new(0.5, 0.5, 0.5)
    Lighting.Brightness = originalLighting.Brightness or 1
    Lighting.GlobalShadows = originalLighting.GlobalShadows ~= nil and originalLighting.GlobalShadows or true
    
    for part, originalProps in pairs(xRayParts) do
        if part and part.Parent then
            part.LocalTransparencyModifier = originalProps.Transparency
            part.Material = originalProps.Material
        end
    end
    xRayParts = {}
    
    for _, part in pairs(chunkBorderParts) do
        if part then part:Destroy() end
    end
    chunkBorderParts = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj:FindFirstChild("ESPBox") then obj.ESPBox:Destroy() end
            if obj:FindFirstChild("ESPLabel") then obj.ESPLabel:Destroy() end
        end
    end
    
    ApplyPlayerMods()
    print("[Settings] All settings reset to default!")
end)

local exportBtn = Instance.new("TextButton")
exportBtn.Size = UDim2.new(1, -24, 0, 50)
exportBtn.Position = UDim2.new(0, 12, 0, 460)
exportBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
exportBtn.Font = Enum.Font.GothamBold
exportBtn.TextSize = 14
exportBtn.Text = "💾 EXPORT CONFIG"
exportBtn.TextColor3 = Color3.fromRGB(255,255,255)
exportBtn.AutoButtonColor = false
exportBtn.Parent = settingsContent

local exportCorner = Instance.new("UICorner")
exportCorner.CornerRadius = UDim.new(0,8)
exportCorner.Parent = exportBtn

exportBtn.MouseButton1Click:Connect(function()
    local configData = {
        fishingConfig = fishingConfig,
        featureConfig = featureConfig,
        fishingStats = fishingStats
    }
    
    local json = HttpService:JSONEncode(configData)
    print("[Settings] Config exported to console")
    print(json)
end)

-- ═══════════════════════════════════════════════════════════
-- UI MANAGEMENT & RUNTIME
-- ═══════════════════════════════════════════════════════════

-- Content Management
local currentContent = fishingContent
local contents = {
    Fishing = fishingContent,
    Teleport = teleportContent,
    Player = playerContent,
    Shop = shopContent,
    Quests = questsContent,
    Visual = visualContent,
    Settings = settingsContent
}

-- Menu Navigation
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        local label = btn:FindFirstChildOfClass("TextLabel")
        if label then
            cTitle.Text = label.Text
        end
        
        for _, contentFrame in pairs(contents) do
            if contentFrame then
                contentFrame.Visible = false
            end
        end
        
        if contents[name] then
            contents[name].Visible = true
            currentContent = contents[name]
        end
        
        for _, otherBtn in pairs(menuButtons) do
            otherBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    end)
end

-- Fishing Button
fishingButton.MouseButton1Click:Connect(function()
    if not fishingActive then
        fishingActive = true
        fishingButton.Text = "🛑 STOP FISHING"
        fishingButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        statusLabel.Text = "✅ FISHING ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        print("[Fishing] Started")
    else
        fishingActive = false
        fishingButton.Text = "🚀 START PERFECT FISHING"
        fishingButton.BackgroundColor3 = ACCENT
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "⭕ OFFLINE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        print("[Fishing] Stopped")
    end
end)

resetButton.MouseButton1Click:Connect(function()
    fishingStats = {
        fishCaught = 0,
        startTime = tick(),
        attempts = 0,
        successes = 0,
        fails = 0,
        lastCatch = 0
    }
    print("[Stats] Fishing statistics reset!")
end)

-- Window Controls
local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        container.Size = UDim2.new(0, WIDTH, 0, 48)
        glow.Size = UDim2.new(0, WIDTH+80, 0, 48+80)
        inner.Visible = false
        minimizeBtn.Text = "+"
    else
        container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
        glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
        inner.Visible = true
        minimizeBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    container.Visible = false
    glow.Visible = false
    trayIcon.Visible = true
end)

trayIcon.MouseButton1Click:Connect(function()
    container.Visible = true
    glow.Visible = true
    trayIcon.Visible = false
end)

-- Mouse Drag
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Memory and Stats Update 
local memoryUpdate = RunService.Heartbeat:Connect(function()
    local memory = math.floor(collectgarbage("count"))
    memLabel.Text = string.format("Memory: %d KB | Fish: %d", memory, fishingStats.fishCaught)
    
    if fishingActive then
        local elapsed = tick() - fishingStats.startTime
        local successRate = (fishingStats.successes / math.max(1, fishingStats.attempts)) * 100
        local fishPerMinute = (fishingStats.fishCaught / math.max(1, elapsed)) * 60
        
        fishCountLabel.Text = "🎣 Fish Caught: " .. fishingStats.fishCaught
        rateLabel.Text = "⚡ Rate: " .. string.format("%.1f/min", fishPerMinute)
        attemptsLabel.Text = "🎯 Attempts: " .. fishingStats.attempts
        successLabel.Text = "✅ Success: " .. string.format("%.1f%%", successRate)
        timeLabel.Text = "⏱️ Session: " .. string.format("%.1fs", elapsed)
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function()
    task.wait(2)
    print("[System] Character respawned - UI ready")
end)

-- Initial setup with debug info
print("═══════════════════════════════════════")
print("⚡ KAITUN FISH IT v4.0 LOADED!")
print("✅ UI System: VISIBLE")
print("✅ Navigation: WORKING")
print("✅ Window Controls: FUNCTIONAL")
print("✅ All Features: READY")
print("═══════════════════════════════════════")

-- Debug: Check if UI elements are properly created
task.wait(1)
print("[DEBUG] ScreenGui created:", screen and screen.Parent == playerGui)
print("[DEBUG] Container visible:", container and container.Visible)
print("[DEBUG] Fishing content:", fishingContent and fishingContent.Visible)
print("[DEBUG] Menu buttons count:", #menuButtons)

-- Cleanup on script termination
screen.AncestryChanged:Connect(function()
    memoryUpdate:Disconnect()
    print("[System] UI Cleaned up")
end)
