-- 📁 ReplicatedStorage/FishingRadar.lua
-- 📡 Fishing Radar System khusus Fish Atelier

local FishingRadar = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Variables
local player = Players.LocalPlayer
local radarEnabled = false
local radarActive = false
local radarConnection = nil
local radarRemote = nil
local radarVisual = nil

-- Configuration
local CONFIG = {
    UPDATE_INTERVAL = 5, -- seconds
    DETECTION_RANGE = 200, -- studs
    SHOW_VISUAL = true,
    HIGHLIGHT_FISH = true,
    AUTO_ENABLE = false,
    VISUAL_COLOR = Color3.fromRGB(0, 255, 255),
    PING_DURATION = 2
}

-- Radar data
local radarData = {
    lastUpdate = 0,
    fishLocations = {},
    hotspots = {},
    lastPingTime = 0
}

-- Statistics
local stats = {
    totalUpdates = 0,
    fishDetected = 0,
    hotspotsFound = 0,
    bestHotspot = nil,
    lastDetectionTime = 0
}

-- Fish detection settings
local FISH_DETECTION = {
    COMMON = {range = 50, color = Color3.fromRGB(150, 150, 150)},
    UNCOMMON = {range = 75, color = Color3.fromRGB(100, 200, 100)},
    RARE = {range = 100, color = Color3.fromRGB(100, 150, 255)},
    EPIC = {range = 150, color = Color3.fromRGB(180, 100, 255)},
    LEGENDARY = {range = 200, color = Color3.fromRGB(255, 200, 50)}
}

function FishingRadar.DetectRadarRemote()
    print("🔍 Detecting Fish Atelier radar remote...")
    
    local possiblePaths = {
        "Packages/_Index/sleitnick_net@0.2.0/net/RF/UpdateFishingRadar",
        "ReplicatedStorage/Remotes/Radar/UpdateRadar",
        "ReplicatedStorage/Events/RadarPing",
        "ReplicatedStorage/FishingSystem/Remotes/UseRadar",
        "ReplicatedStorage/Tools/Radar/Activate"
    }
    
    for _, path in ipairs(possiblePaths) do
        local remote = ReplicatedStorage:FindFirstChild(path, true)
        if remote then
            radarRemote = remote
            print("✅ Found radar remote:", path)
            return true
        end
    end
    
    -- Search for any radar-related remote
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("radar") or name:find("scan") or name:find("detect") then
                radarRemote = remote
                print("✅ Found potential radar remote:", remote:GetFullName())
                return true
            end
        end
    end
    
    print("❌ Radar remote not found")
    return false
end

function FishingRadar.UpdateRadar(enable)
    if not radarRemote then
        if not FishingRadar.DetectRadarRemote() then
            return false, "Radar remote not found"
        end
    end
    
    local args = {enable or false}
    
    print("📡 Updating fishing radar:", enable and "ENABLED" or "DISABLED")
    
    local success, result = pcall(function()
        if radarRemote:IsA("RemoteFunction") then
            return radarRemote:InvokeServer(unpack(args))
        else
            radarRemote:FireServer(unpack(args))
            return true
        end
    end)
    
    if success then
        radarActive = enable
        radarData.lastUpdate = tick()
        stats.totalUpdates = stats.totalUpdates + 1
        
        if enable then
            -- Create visual if enabled
            if CONFIG.SHOW_VISUAL then
                FishingRadar.CreateRadarVisual()
            end
            
            -- Start detection
            FishingRadar.StartFishDetection()
        else
            -- Remove visual
            FishingRadar.RemoveRadarVisual()
        end
        
        print("✅ Radar updated successfully")
        return true, "Radar " .. (enable and "enabled" or "disabled")
    else
        print("❌ Failed to update radar:", result)
        return false, result
    end
end

function FishingRadar.CreateRadarVisual()
    -- Remove existing visual
    FishingRadar.RemoveRadarVisual()
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Create radar sphere
    radarVisual = Instance.new("Part")
    radarVisual.Name = "FishingRadarVisual"
    radarVisual.Size = Vector3.new(CONFIG.DETECTION_RANGE * 2, 1, CONFIG.DETECTION_RANGE * 2)
    radarVisual.Position = rootPart.Position
    radarVisual.Anchored = true
    radarVisual.CanCollide = false
    radarVisual.Transparency = 0.7
    radarVisual.Color = CONFIG.VISUAL_COLOR
    radarVisual.Material = Enum.Material.Neon
    
    -- Create ring effect
    local ring = Instance.new("Part")
    ring.Name = "RadarRing"
    ring.Size = Vector3.new(5, 5, 5)
    ring.Shape = Enum.PartType.Ball
    ring.Position = rootPart.Position
    ring.Anchored = true
    ring.CanCollide = false
    ring.Transparency = 0.3
    ring.Color = CONFIG.VISUAL_COLOR
    ring.Material = Enum.Material.Neon
    ring.Parent = radarVisual
    
    -- Create UI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RadarInfo"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = radarVisual
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🎣 FISHING RADAR ACTIVE"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    radarVisual.Parent = Workspace
    
    -- Animate the ring
    spawn(function()
        while radarVisual and radarVisual.Parent do
            ring.Size = Vector3.new(5, 5, 5)
            for i = 1, CONFIG.DETECTION_RANGE / 5 do
                if not radarVisual then break end
                ring.Size = ring.Size + Vector3.new(10, 10, 10)
                ring.Transparency = ring.Transparency + 0.02
                task.wait(0.05)
            end
            ring.Size = Vector3.new(5, 5, 5)
            ring.Transparency = 0.3
            task.wait(1)
        end
    end)
end

function FishingRadar.RemoveRadarVisual()
    if radarVisual then
        radarVisual:Destroy()
        radarVisual = nil
    end
end

function FishingRadar.StartFishDetection()
    spawn(function()
        while radarActive do
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    FishingRadar.ScanForFish(rootPart.Position)
                end
            end
            task.wait(CONFIG.UPDATE_INTERVAL)
        end
    end)
end

function FishingRadar.ScanForFish(position)
    -- Clear previous data
    radarData.fishLocations = {}
    
    -- Scan for fish in workspace
    local fishCount = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local distance = (obj.Position - position).Magnitude
            
            if distance <= CONFIG.DETECTION_RANGE then
                -- Check if it's a fish (simple detection)
                if obj.Name:find("Fish") or obj.Name:find("fish") then
                    table.insert(radarData.fishLocations, {
                        position = obj.Position,
                        name = obj.Name,
                        distance = math.floor(distance),
                        rarity = FishingRadar.DetermineRarity(obj)
                    })
                    fishCount = fishCount + 1
                    
                    -- Highlight fish if enabled
                    if CONFIG.HIGHLIGHT_FISH then
                        FishingRadar.HighlightFish(obj)
                    end
                end
            end
        end
    end
    
    -- Update statistics
    if fishCount > 0 then
        stats.fishDetected = stats.fishDetected + fishCount
        stats.lastDetectionTime = tick()
        
        -- Find hotspots
        FishingRadar.DetectHotspots(position)
        
        print(string.format("🎯 Radar detected %d fish nearby", fishCount))
    end
    
    return fishCount
end

function FishingRadar.DetermineRarity(fishPart)
    -- Simple rarity determination based on color/name
    local name = fishPart.Name:lower()
    local color = fishPart.Color
    
    if name:find("gold") or name:find("dragon") then
        return "LEGENDARY"
    elseif name:find("shark") or name:find("marlin") then
        return "EPIC"
    elseif name:find("sturgeon") or name:find("snapper") then
        return "RARE"
    elseif name:find("salmon") or name:find("tuna") then
        return "UNCOMMON"
    else
        return "COMMON"
    end
end

function FishingRadar.HighlightFish(fishPart)
    -- Create highlight effect
    local highlight = Instance.new("Highlight")
    highlight.Name = "FishHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = fishPart
    
    -- Remove after duration
    task.wait(CONFIG.PING_DURATION)
    if highlight then
        highlight:Destroy()
    end
end

function FishingRadar.DetectHotspots(position)
    -- Group fish locations to find hotspots
    local groups = {}
    
    for _, fish in ipairs(radarData.fishLocations) do
        local added = false
        
        for _, group in ipairs(groups) do
            local distance = (fish.position - group.center).Magnitude
            if distance < 20 then -- Fish within 20 studs are in same hotspot
                table.insert(group.fish, fish)
                group.center = (group.center + fish.position) / 2
                group.count = group.count + 1
                added = true
                break
            end
        end
        
        if not added then
            table.insert(groups, {
                center = fish.position,
                fish = {fish},
                count = 1
            })
        end
    end
    
    -- Update hotspots
    radarData.hotspots = {}
    for _, group in ipairs(groups) do
        if group.count >= 3 then -- Minimum 3 fish for a hotspot
            table.insert(radarData.hotspots, {
                position = group.center,
                fishCount = group.count,
                distance = math.floor((group.center - position).Magnitude)
            })
        end
    end
    
    -- Update best hotspot
    if #radarData.hotspots > 0 then
        table.sort(radarData.hotspots, function(a, b)
            return a.fishCount > b.fishCount
        end)
        
        stats.bestHotspot = radarData.hotspots[1]
        stats.hotspotsFound = #radarData.hotspots
    end
end

function FishingRadar.StartAutoRadar()
    if radarEnabled then
        print("⚠️ Auto radar already running")
        return false
    end
    
    print("🚀 Starting auto fishing radar...")
    
    -- Detect remote
    if not radarRemote then
        FishingRadar.DetectRadarRemote()
    end
    
    radarEnabled = true
    
    -- Enable radar first time
    FishingRadar.UpdateRadar(true)
    
    -- Auto update loop
    radarConnection = RunService.Heartbeat:Connect(function()
        if not radarEnabled then return end
        
        local currentTime = tick()
        if currentTime - radarData.lastUpdate >= CONFIG.UPDATE_INTERVAL then
            FishingRadar.UpdateRadar(true)
        end
    end)
    
    print(string.format("✅ Auto radar started (interval: %ds)", CONFIG.UPDATE_INTERVAL))
    return true
end

function FishingRadar.StopAutoRadar()
    print("🛑 Stopping auto radar...")
    
    radarEnabled = false
    
    if radarConnection then
        radarConnection:Disconnect()
        radarConnection = nil
    end
    
    -- Disable radar
    FishingRadar.UpdateRadar(false)
    
    print("✅ Auto radar stopped")
end

function FishingRadar.ToggleRadar()
    if radarEnabled then
        FishingRadar.StopAutoRadar()
        return false
    else
        return FishingRadar.StartAutoRadar()
    end
end

function FishingRadar.GetRadarData()
    return {
        enabled = radarEnabled,
        active = radarActive,
        lastUpdate = radarData.lastUpdate,
        fishDetected = #radarData.fishLocations,
        hotspots = #radarData.hotspots,
        bestHotspot = stats.bestHotspot,
        nextUpdateIn = radarEnabled and 
            math.max(0, CONFIG.UPDATE_INTERVAL - (tick() - radarData.lastUpdate)) or 0
    }
end

function FishingRadar.GetNearbyFish()
    local character = player.Character
    if not character then return {} end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return {} end
    
    local nearbyFish = {}
    
    for _, fish in ipairs(radarData.fishLocations) do
        if (fish.position - rootPart.Position).Magnitude <= 50 then
            table.insert(nearbyFish, fish)
        end
    end
    
    table.sort(nearbyFish, function(a, b)
        return a.distance < b.distance
    end)
    
    return nearbyFish
end

function FishingRadar.GetHotspots()
    return radarData.hotspots
end

-- Auto initialize
spawn(function()
    task.wait(3)
    print("📡 Fish Atelier Fishing Radar System Initialized")
    FishingRadar.DetectRadarRemote()
    if CONFIG.AUTO_ENABLE then
        task.wait(5)
        FishingRadar.StartAutoRadar()
    end
end)

return FishingRadar