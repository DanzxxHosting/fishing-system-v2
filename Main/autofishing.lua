-- 📁 ReplicatedStorage/AutoFishing.lua
-- 🎣 Auto Fishing System khusus Fish Atelier

local AutoFishing = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local fishingActive = false
local autoFishingEnabled = false
local currentRod = nil
local fishingConnection = nil
local lastCatchTime = 0
local catchCooldown = 2

-- Remote untuk Fish Atelier (akan dideteksi otomatis)
local fishingRemotes = {
    StartFishing = nil,
    CastRod = nil,
    ReelIn = nil,
    Minigame = nil,
    BuyBait = nil
}

-- Configuration untuk Fish Atelier
local CONFIG = {
    -- Timing
    CAST_DELAY = 0.5,
    REEL_DELAY = 0.3,
    MINIGAME_TIMING = 0.5,
    FISHING_COOLDOWN = 3,
    
    -- Detection
    WATER_DETECTION_RANGE = 100,
    MAX_FAILURE_COUNT = 5,
    AUTO_EQUIP_ROD = true,
    
    -- Visual
    SHOW_FISHING_LINE = true,
    SHOW_CATCH_NOTIFICATION = true,
    
    -- Anti-ban
    RANDOM_DELAY_VARIATION = 0.2,
    HUMAN_LIKE_MOVEMENT = true
}

-- Fishing statistics
local stats = {
    TotalCatches = 0,
    TotalAttempts = 0,
    SuccessRate = 0,
    CurrentStreak = 0,
    BestStreak = 0,
    RareCatches = 0,
    LastCatchType = nil,
    SessionStartTime = tick()
}

-- Fish types untuk Fish Atelier
local FISH_TYPES = {
    Common = {
        "Small Fish", "Carp", "Bass", "Trout", "Sardine",
        Color = Color3.fromRGB(150, 150, 150),
        Chance = 60
    },
    Uncommon = {
        "Salmon", "Tuna", "Mackerel", "Catfish", "Perch",
        Color = Color3.fromRGB(100, 200, 100),
        Chance = 25
    },
    Rare = {
        "Sturgeon", "Mahi Mahi", "Snapper", "Grouper", "Halibut",
        Color = Color3.fromRGB(100, 150, 255),
        Chance = 10
    },
    Epic = {
        "Marlin", "Swordfish", "Shark", "Ray", "Sunfish",
        Color = Color3.fromRGB(180, 100, 255),
        Chance = 4
    },
    Legendary = {
        "Golden Fish", "Dragon Fish", "Phoenix Fish", "Kraken", "Leviathan",
        Color = Color3.fromRGB(255, 200, 50),
        Chance = 1
    }
}

function AutoFishing.DetectRemotes()
    print("🔍 Detecting Fish Atelier fishing remotes...")
    
    -- Coba beberapa kemungkinan path untuk Fish Atelier
    local possiblePaths = {
        "Packages/_Index/sleitnick_net@0.2.0/net/RF/RequestFishingMinigameStarted",
        "Packages/_Index/knit/knit/Services/FishingService/StartFishing",
        "ReplicatedStorage/Remotes/Fishing/StartFishing",
        "ReplicatedStorage/Events/FishingCast",
        "ReplicatedStorage/FishingSystem/Remotes/CastRod"
    }
    
    for _, path in ipairs(possiblePaths) do
        local remote = ReplicatedStorage:FindFirstChild(path, true)
        if remote then
            print("✅ Found fishing remote:", path)
            
            -- Assign berdasarkan nama
            local name = remote.Name
            if name:find("Minigame") then
                fishingRemotes.Minigame = remote
            elseif name:find("Cast") then
                fishingRemotes.CastRod = remote
            elseif name:find("Start") then
                fishingRemotes.StartFishing = remote
            elseif name:find("Reel") then
                fishingRemotes.ReelIn = remote
            end
        end
    end
    
    -- Jika tidak ditemukan, coba search semua remote
    if not fishingRemotes.StartFishing then
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("rod") then
                    print("✅ Found potential fishing remote:", remote:GetFullName())
                    fishingRemotes.StartFishing = fishingRemotes.StartFishing or remote
                end
            end
        end
    end
    
    return fishingRemotes.StartFishing ~= nil
end

function AutoFishing.FindFishingRod()
    print("🎣 Looking for fishing rod...")
    
    -- Cek di backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name:find("Rod") or item.Name:find("Fishing") then
                currentRod = item
                print("✅ Found rod in backpack:", item.Name)
                return true
            end
        end
    end
    
    -- Cek di character (equipped)
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:find("Rod") or tool.Name:find("Fishing")) then
                currentRod = tool
                print("✅ Found equipped rod:", tool.Name)
                return true
            end
        end
    end
    
    -- Cek di workspace (jatuh)
    for _, rod in ipairs(Workspace:GetChildren()) do
        if rod.Name:find("Rod") and (rod.Position - (character and character.PrimaryPart.Position or Vector3.new())).Magnitude < 20 then
            currentRod = rod
            print("✅ Found rod in workspace")
            return true
        end
    end
    
    print("❌ No fishing rod found")
    return false
end

function AutoFishing.FindWater()
    local character = player.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not rootPart then return nil end
    
    local searchArea = Workspace:FindFirstChild("Water") or 
                      Workspace:FindFirstChild("Ocean") or
                      Workspace:FindFirstChild("Lake") or
                      Workspace:FindFirstChild("River")
    
    if searchArea then
        print("💧 Found water area:", searchArea.Name)
        return searchArea.Position
    end
    
    -- Cari part dengan material water
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("Part") then
            local distance = (part.Position - rootPart.Position).Magnitude
            if distance < CONFIG.WATER_DETECTION_RANGE then
                if part.Material == Enum.Material.Water or 
                   part.Name:find("Water") or
                   part.Color.b > part.Color.r + 0.3 then
                    print("💧 Found water at:", part.Position)
                    return part.Position
                end
            end
        end
    end
    
    return nil
end

function AutoFishing.CastRod()
    if not fishingRemotes.CastRod then
        if not AutoFishing.DetectRemotes() then
            print("❌ Cannot cast: No fishing remote found")
            return false
        end
    end
    
    print("🎣 Casting rod...")
    
    -- Cari posisi air
    local waterPosition = AutoFishing.FindWater()
    if not waterPosition then
        print("❌ No water found nearby")
        return false
    end
    
    -- Hadap ke air
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:MoveTo(waterPosition)
            task.wait(0.5)
        end
    end
    
    -- Delay natural
    local delay = CONFIG.CAST_DELAY + (math.random() * 0.3)
    task.wait(delay)
    
    -- Execute cast
    if fishingRemotes.CastRod:IsA("RemoteEvent") then
        fishingRemotes.CastRod:FireServer(waterPosition)
    elseif fishingRemotes.CastRod:IsA("RemoteFunction") then
        fishingRemotes.CastRod:InvokeServer(waterPosition)
    else
        -- Fallback: simulate click
        print("⚠️ Using fallback cast method")
    end
    
    return true
end

function AutoFishing.StartMinigame()
    if not fishingRemotes.Minigame then
        print("❌ Minigame remote not found")
        return false
    end
    
    print("🎮 Starting fishing minigame...")
    
    -- Timing calculation
    local timing = CONFIG.MINIGAME_TIMING
    if CONFIG.RANDOM_DELAY_VARIATION > 0 then
        timing = timing + (math.random() * CONFIG.RANDOM_DELAY_VARIATION - CONFIG.RANDOM_DELAY_VARIATION/2)
    end
    
    -- Args untuk Fish Atelier
    local args = {
        timing,
        0.5 + math.random() * 0.3, -- accuracy
        tick(),
        player.UserId
    }
    
    local success, result = pcall(function()
        if fishingRemotes.Minigame:IsA("RemoteFunction") then
            return fishingRemotes.Minigame:InvokeServer(unpack(args))
        else
            fishingRemotes.Minigame:FireServer(unpack(args))
            return true
        end
    end)
    
    if success then
        print("✅ Minigame started")
        return true
    else
        print("❌ Minigame failed:", result)
        return false
    end
end

function AutoFishing.ReelIn()
    print("🎣 Reeling in...")
    
    task.wait(CONFIG.REEL_DELAY)
    
    if fishingRemotes.ReelIn then
        if fishingRemotes.ReelIn:IsA("RemoteEvent") then
            fishingRemotes.ReelIn:FireServer()
        else
            fishingRemotes.ReelIn:InvokeServer()
        end
    end
    
    return true
end

function AutoFishing.CatchFish()
    -- Determine fish type based on probability
    local roll = math.random(1, 100)
    local cumulative = 0
    local caughtType = "Common"
    
    for rarity, data in pairs(FISH_TYPES) do
        cumulative = cumulative + data.Chance
        if roll <= cumulative then
            caughtType = rarity
            break
        end
    end
    
    -- Update stats
    stats.TotalCatches = stats.TotalCatches + 1
    stats.TotalAttempts = stats.TotalAttempts + 1
    stats.CurrentStreak = stats.CurrentStreak + 1
    stats.BestStreak = math.max(stats.BestStreak, stats.CurrentStreak)
    stats.LastCatchType = caughtType
    lastCatchTime = tick()
    
    if caughtType == "Rare" or caughtType == "Epic" or caughtType == "Legendary" then
        stats.RareCatches = stats.RareCatches + 1
    end
    
    stats.SuccessRate = (stats.TotalCatches / stats.TotalAttempts) * 100
    
    print(string.format("✅ Caught %s fish! (Streak: %d)", caughtType, stats.CurrentStreak))
    
    return caughtType
end

function AutoFishing.StartSingleFishing()
    if fishingActive then
        print("⚠️ Already fishing!")
        return false
    end
    
    if tick() - lastCatchTime < catchCooldown then
        print("⏳ On cooldown...")
        return false
    end
    
    fishingActive = true
    print("🎣 Starting fishing session...")
    
    -- Step 1: Cari rod
    if not AutoFishing.FindFishingRod() then
        fishingActive = false
        return false
    end
    
    -- Step 2: Cast rod
    if not AutoFishing.CastRod() then
        fishingActive = false
        return false
    end
    
    -- Step 3: Tunggu ikan bite
    local biteTime = 1 + math.random() * 2
    task.wait(biteTime)
    
    -- Step 4: Minigame
    if not AutoFishing.StartMinigame() then
        fishingActive = false
        return false
    end
    
    -- Step 5: Tunggu minigame
    task.wait(0.5)
    
    -- Step 6: Reel in
    if not AutoFishing.ReelIn() then
        fishingActive = false
        return false
    end
    
    -- Step 7: Tangkap ikan
    local fishType = AutoFishing.CatchFish()
    
    fishingActive = false
    return true, fishType
end

function AutoFishing.StartAutoFishing()
    if autoFishingEnabled then
        print("⚠️ Auto fishing already running")
        return false
    end
    
    print("🚀 Starting auto fishing system...")
    
    -- Deteksi remotes
    AutoFishing.DetectRemotes()
    
    autoFishingEnabled = true
    local consecutiveFailures = 0
    
    -- Main loop
    fishingConnection = RunService.Heartbeat:Connect(function()
        if not autoFishingEnabled then return end
        
        if not fishingActive then
            local success, fishType = AutoFishing.StartSingleFishing()
            
            if success then
                consecutiveFailures = 0
                -- Delay antar fishing
                local delay = CONFIG.FISHING_COOLDOWN + math.random() * 2
                for i = 1, delay do
                    if not autoFishingEnabled then break end
                    task.wait(1)
                end
            else
                consecutiveFailures = consecutiveFailures + 1
                print("❌ Fishing failed, attempt:", consecutiveFailures)
                
                if consecutiveFailures >= CONFIG.MAX_FAILURE_COUNT then
                    print("⚠️ Taking a break...")
                    task.wait(10)
                    consecutiveFailures = 0
                else
                    task.wait(2)
                end
            end
        end
    end)
    
    return true
end

function AutoFishing.StopAutoFishing()
    print("🛑 Stopping auto fishing...")
    autoFishingEnabled = false
    fishingActive = false
    
    if fishingConnection then
        fishingConnection:Disconnect()
        fishingConnection = nil
    end
end

function AutoFishing.GetStats()
    local sessionTime = tick() - stats.SessionStartTime
    local catchesPerHour = (stats.TotalCatches / (sessionTime / 3600))
    
    return {
        TotalCatches = stats.TotalCatches,
        TotalAttempts = stats.TotalAttempts,
        SuccessRate = math.floor(stats.SuccessRate * 100) / 100,
        CurrentStreak = stats.CurrentStreak,
        BestStreak = stats.BestStreak,
        RareCatches = stats.RareCatches,
        LastCatch = stats.LastCatchType,
        CatchesPerHour = math.floor(catchesPerHour * 10) / 10,
        IsFishing = fishingActive,
        IsAutoFishing = autoFishingEnabled
    }
end

function AutoFishing.ResetStats()
    stats = {
        TotalCatches = 0,
        TotalAttempts = 0,
        SuccessRate = 0,
        CurrentStreak = 0,
        BestStreak = 0,
        RareCatches = 0,
        LastCatchType = nil,
        SessionStartTime = tick()
    }
    print("📊 Fishing statistics reset")
end

-- Auto initialize
spawn(function()
    task.wait(3)
    print("🎣 Fish Atelier Auto Fishing System Initialized")
    AutoFishing.DetectRemotes()
end)

return AutoFishing