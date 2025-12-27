-- 📁 ReplicatedStorage/TotemSpawner.lua
-- 🗿 Totem Spawner System khusus Fish Atelier

local TotemSpawner = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Variables
local player = Players.LocalPlayer
local spawnRemote = nil
local lastSpawnTime = 0
local spawnCooldown = 30
local activeTotem = nil
local totemConnection = nil

-- Totem database untuk Fish Atelier
local TOTEM_DATA = {
    {
        id = "fc80da40-d5f5-4981-90ce-7a7685b43c92",
        name = "Basic Fishing Totem",
        description = "Increases common fish catch rate",
        duration = 300,
        rarity = "Common",
        buff = {common = 1.5, uncommon = 1.2},
        model = "rbxassetid://9876543210",
        cost = 1000
    },
    {
        id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        name = "Rare Fish Totem",
        description = "Greatly increases rare fish chances",
        duration = 600,
        rarity = "Rare",
        buff = {rare = 2.0, uncommon = 1.5, common = 1.3},
        model = "rbxassetid://9876543211",
        cost = 5000
    },
    {
        id = "d4e5f6a7-b8c9-0123-de45-67890abcdef1",
        name = "Epic Luck Totem",
        description = "Massively increases epic and legendary fish",
        duration = 1800,
        rarity = "Epic",
        buff = {epic = 3.0, legendary = 2.0, rare = 1.8},
        model = "rbxassetid://9876543212",
        cost = 15000
    },
    {
        id = "b3c4d5e6-f7a8-9012-bc34-567890abcdef",
        name = "Legendary Ocean Totem",
        description = "Summons the rarest fish in the ocean",
        duration = 3600,
        rarity = "Legendary",
        buff = {legendary = 5.0, epic = 3.0, rare = 2.0},
        model = "rbxassetid://9876543213",
        cost = 50000
    },
    {
        id = "c5d6e7f8-a9b0-1234-cd56-7890abcdef12",
        name = "Golden God Totem",
        description = "Divine blessing for maximum fishing",
        duration = 7200,
        rarity = "Mythical",
        buff = {all = 10.0},
        model = "rbxassetid://9876543214",
        cost = 100000
    }
}

-- Statistics
local stats = {
    totalSpawns = 0,
    activeDuration = 0,
    bestTotemUsed = nil,
    lastTotemEffect = nil,
    cooldownRemaining = 0
}

function TotemSpawner.DetectSpawnRemote()
    print("🔍 Detecting Fish Atelier totem remote...")
    
    local possiblePaths = {
        "Packages/_Index/sleitnick_net@0.2.0/net/RE/SpawnTotem",
        "ReplicatedStorage/Remotes/Totem/Spawn",
        "ReplicatedStorage/Events/UseTotem",
        "ReplicatedStorage/FishingSystem/Remotes/ActivateTotem",
        "ReplicatedStorage/Items/Totem/Use"
    }
    
    for _, path in ipairs(possiblePaths) do
        local remote = ReplicatedStorage:FindFirstChild(path, true)
        if remote then
            spawnRemote = remote
            print("✅ Found totem remote:", path)
            return true
        end
    end
    
    -- Search for totem-related remotes
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("totem") or name:find("buff") or name:find("boost") then
                spawnRemote = remote
                print("✅ Found potential totem remote:", remote:GetFullName())
                return true
            end
        end
    end
    
    print("❌ Totem spawn remote not found")
    return false
end

function TotemSpawner.GetTotemInfo(totemId)
    for _, totem in ipairs(TOTEM_DATA) do
        if totem.id == totemId then
            return totem
        end
    end
    return nil
end

function TotemSpawner.SpawnTotem(totemId)
    if not spawnRemote then
        if not TotemSpawner.DetectSpawnRemote() then
            return false, "Totem remote not found"
        end
    end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - lastSpawnTime < spawnCooldown then
        local remaining = spawnCooldown - (currentTime - lastSpawnTime)
        stats.cooldownRemaining = remaining
        return false, string.format("Cooldown: %.1fs remaining", remaining)
    end
    
    -- Validate totem
    local totemInfo = TotemSpawner.GetTotemInfo(totemId)
    if not totemInfo then
        return false, "Invalid totem ID"
    end
    
    print(string.format("🗿 Spawning %s totem...", totemInfo.rarity))
    
    local args = {totemId}
    local success, result = pcall(function()
        spawnRemote:FireServer(unpack(args))
        return true
    end)
    
    if success then
        -- Update stats
        lastSpawnTime = currentTime
        stats.totalSpawns = stats.totalSpawns + 1
        stats.bestTotemUsed = totemInfo.rarity
        stats.lastTotemEffect = totemInfo.buff
        activeTotem = totemInfo
        
        -- Start cooldown timer
        TotemSpawner.StartCooldownTimer()
        
        -- Create visual effect
        TotemSpawner.CreateTotemVisual(totemInfo)
        
        -- Start duration timer
        TotemSpawner.StartTotemDuration(totemInfo.duration)
        
        print(string.format("✅ %s totem activated for %d seconds", 
            totemInfo.name, totemInfo.duration))
        
        return true, totemInfo.name
    else
        print("❌ Failed to spawn totem:", result)
        return false, result
    end
end

function TotemSpawner.StartCooldownTimer()
    spawn(function()
        local startTime = tick()
        while tick() - startTime < spawnCooldown do
            stats.cooldownRemaining = spawnCooldown - (tick() - startTime)
            task.wait(0.1)
        end
        stats.cooldownRemaining = 0
    end)
end

function TotemSpawner.CreateTotemVisual(totemInfo)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Remove existing totem
    if totemConnection then
        totemConnection:Disconnect()
    end
    
    -- Create totem base
    local totemBase = Instance.new("Part")
    totemBase.Name = "ActiveTotem"
    totemBase.Size = Vector3.new(3, 6, 3)
    totemBase.Position = rootPart.Position + Vector3.new(0, 3, 0)
    totemBase.Anchored = true
    totemBase.CanCollide = false
    totemBase.Transparency = 0.3
    
    -- Set color based on rarity
    local rarityColors = {
        Common = Color3.fromRGB(150, 150, 150),
        Rare = Color3.fromRGB(100, 150, 255),
        Epic = Color3.fromRGB(180, 100, 255),
        Legendary = Color3.fromRGB(255, 200, 50),
        Mythical = Color3.fromRGB(255, 50, 50)
    }
    
    totemBase.Color = rarityColors[totemInfo.rarity] or Color3.fromRGB(255, 255, 255)
    totemBase.Material = Enum.Material.Neon
    
    -- Add glow
    local pointLight = Instance.new("PointLight")
    pointLight.Name = "TotemLight"
    pointLight.Brightness = 5
    pointLight.Range = 20
    pointLight.Color = totemBase.Color
    pointLight.Parent = totemBase
    
    -- Add particle effect
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "TotemParticles"
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Rate = 50
    particles.Speed = NumberRange.new(2, 5)
    particles.Lifetime = NumberRange.new(1, 3)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Color = ColorSequence.new(totemBase.Color)
    particles.Parent = totemBase
    
    -- Add billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TotemInfo"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.AlwaysOnTop = true
    billboard.Parent = totemBase
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🗿 " .. totemInfo.name
    title.TextColor3 = totemBase.Color
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = billboard
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 40)
    desc.Position = UDim2.new(0, 0, 0, 30)
    desc.BackgroundTransparency = 1
    desc.Text = totemInfo.description
    desc.TextColor3 = Color3.fromRGB(255, 255, 255)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 10
    desc.TextWrapped = true
    desc.Parent = billboard
    
    local timer = Instance.new("TextLabel")
    timer.Size = UDim2.new(1, 0, 0, 30)
    timer.Position = UDim2.new(0, 0, 0, 70)
    timer.BackgroundTransparency = 1
    timer.Text = "00:00"
    timer.TextColor3 = Color3.fromRGB(255, 255, 255)
    timer.Font = Enum.Font.GothamBold
    timer.TextSize = 12
    timer.Name = "Timer"
    timer.Parent = billboard
    
    totemBase.Parent = Workspace
    
    -- Follow player
    totemConnection = RunService.Heartbeat:Connect(function()
        if totemBase and character then
            local charPos = character.PrimaryPart.Position
            totemBase.Position = charPos + Vector3.new(0, 3, 0)
        end
    end)
    
    -- Store reference
    activeTotem = totemBase
end

function TotemSpawner.StartTotemDuration(duration)
    spawn(function()
        local startTime = tick()
        local endTime = startTime + duration
        
        while tick() < endTime and activeTotem do
            local remaining = endTime - tick()
            local minutes = math.floor(remaining / 60)
            local seconds = math.floor(remaining % 60)
            
            -- Update timer display
            if activeTotem then
                local timerLabel = activeTotem:FindFirstChild("TotemInfo")
                if timerLabel then
                    timerLabel = timerLabel:FindFirstChild("Timer")
                    if timerLabel then
                        timerLabel.Text = string.format("%02d:%02d", minutes, seconds)
                        
                        -- Flash when almost expired
                        if remaining < 10 then
                            timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                        end
                    end
                end
            end
            
            stats.activeDuration = remaining
            task.wait(1)
        end
        
        -- Remove totem
        TotemSpawner.RemoveTotemVisual()
        activeTotem = nil
        stats.activeDuration = 0
        
        print("🗿 Totem expired")
    end)
end

function TotemSpawner.RemoveTotemVisual()
    if activeTotem then
        activeTotem:Destroy()
        activeTotem = nil
    end
    
    if totemConnection then
        totemConnection:Disconnect()
        totemConnection = nil
    end
end

function TotemSpawner.GetAvailableTotems()
    return TOTEM_DATA
end

function TotemSpawner.SpawnBestTotem()
    -- Spawn the best available totem (last in array)
    local bestTotem = TOTEM_DATA[#TOTEM_DATA]
    return TotemSpawner.SpawnTotem(bestTotem.id)
end

function TotemSpawner.SetCooldown(seconds)
    if seconds < 5 then
        print("⚠️ Cooldown too short, minimum 5 seconds")
        return false
    end
    
    spawnCooldown = seconds
    print("⚙️ Totem cooldown set to", seconds, "seconds")
    return true
end

function TotemSpawner.GetStats()
    return {
        totalSpawns = stats.totalSpawns,
        bestTotemUsed = stats.bestTotemUsed,
        lastEffect = stats.lastTotemEffect,
        cooldownRemaining = math.floor(stats.cooldownRemaining),
        activeDuration = math.floor(stats.activeDuration),
        canSpawn = (tick() - lastSpawnTime) >= spawnCooldown,
        activeTotem = activeTotem ~= nil
    }
end

function TotemSpawner.AutoSpawnLoop(interval)
    interval = interval or 60
    
    spawn(function()
        while true do
            if (tick() - lastSpawnTime) >= spawnCooldown then
                TotemSpawner.SpawnBestTotem()
            end
            task.wait(interval)
        end
    end)
end

function TotemSpawner.CancelTotem()
    if activeTotem then
        TotemSpawner.RemoveTotemVisual()
        print("🗿 Active totem cancelled")
        return true
    end
    return false
end

-- Auto initialize
spawn(function()
    task.wait(3)
    print("🗿 Fish Atelier Totem Spawner System Initialized")
    TotemSpawner.DetectSpawnRemote()
end)

return TotemSpawner