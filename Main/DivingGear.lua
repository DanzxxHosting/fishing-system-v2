-- 📁 ReplicatedStorage/DivingGear.lua
-- 🤿 Diving Gear System khusus Fish Atelier

local DivingGear = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Variables
local player = Players.LocalPlayer
local gearEquipped = false
local currentTank = nil
local oxygenLevel = 100
local oxygenDepletionRate = 0.1
local oxygenRefillRate = 0.5
local isUnderwater = false

-- Remotes
local equipRemote = nil
local unequipRemote = nil
local refillRemote = nil

-- Oxygen Tanks untuk Fish Atelier
local OXYGEN_TANKS = {
    {
        id = 100,
        name = "Basic Oxygen Tank",
        capacity = 60,
        refillCost = 100,
        rarity = "Common",
        model = "rbxassetid://1234567890"
    },
    {
        id = 101,
        name = "Standard Tank",
        capacity = 120,
        refillCost = 200,
        rarity = "Uncommon",
        model = "rbxassetid://1234567891"
    },
    {
        id = 102,
        name = "Advanced Tank",
        capacity = 300,
        refillCost = 500,
        rarity = "Rare",
        model = "rbxassetid://1234567892"
    },
    {
        id = 103,
        name = "Professional Tank",
        capacity = 600,
        refillCost = 1000,
        rarity = "Epic",
        model = "rbxassetid://1234567893"
    },
    {
        id = 104,
        name = "Master Diver Tank",
        capacity = 1200,
        refillCost = 2000,
        rarity = "Legendary",
        model = "rbxassetid://1234567894"
    },
    {
        id = 105,
        name = "Infinite Oxygen Tank",
        capacity = 999999,
        refillCost = 0,
        rarity = "Mythical",
        model = "rbxassetid://1234567895"
    }
}

-- Statistics
local stats = {
    TotalDiveTime = 0,
    DeepestDive = 0,
    TanksUsed = 0,
    RefillsUsed = 0,
    LastDiveDepth = 0
}

function DivingGear.DetectRemotes()
    print("🔍 Detecting Fish Atelier diving remotes...")
    
    local possiblePaths = {
        "Packages/_Index/sleitnick_net@0.2.0/net/RF/EquipOxygenTank",
        "Packages/_Index/sleitnick_net@0.2.0/net/RF/UnequipOxygenTank",
        "ReplicatedStorage/Remotes/Diving/EquipTank",
        "ReplicatedStorage/Events/DivingEquipment",
        "ReplicatedStorage/DivingSystem/Remotes/UseTank"
    }
    
    for _, path in ipairs(possiblePaths) do
        local remote = ReplicatedStorage:FindFirstChild(path, true)
        if remote then
            if path:find("Equip") then
                equipRemote = remote
                print("✅ Found equip remote:", path)
            elseif path:find("Unequip") then
                unequipRemote = remote
                print("✅ Found unequip remote:", path)
            end
        end
    end
    
    return equipRemote ~= nil
end

function DivingGear.GetTankInfo(tankId)
    for _, tank in ipairs(OXYGEN_TANKS) do
        if tank.id == tankId then
            return tank
        end
    end
    return nil
end

function DivingGear.EquipTank(tankId)
    if not equipRemote then
        if not DivingGear.DetectRemotes() then
            return false, "Diving remotes not found"
        end
    end
    
    if gearEquipped then
        return false, "Already have tank equipped"
    end
    
    local tankInfo = DivingGear.GetTankInfo(tankId)
    if not tankInfo then
        return false, "Invalid tank ID"
    end
    
    print("🤿 Equipping tank:", tankInfo.name)
    
    local args = {tankId}
    local success, result = pcall(function()
        if equipRemote:IsA("RemoteFunction") then
            return equipRemote:InvokeServer(unpack(args))
        else
            equipRemote:FireServer(unpack(args))
            return true
        end
    end)
    
    if success then
        gearEquipped = true
        currentTank = tankInfo
        oxygenLevel = tankInfo.capacity
        stats.TanksUsed = stats.TanksUsed + 1
        
        -- Start oxygen monitoring
        DivingGear.StartOxygenMonitor()
        
        print("✅ Tank equipped:", tankInfo.name)
        return true, tankInfo.name
    else
        print("❌ Failed to equip tank:", result)
        return false, result
    end
end

function DivingGear.UnequipTank()
    if not unequipRemote then
        return false, "Unequip remote not found"
    end
    
    if not gearEquipped then
        return false, "No tank equipped"
    end
    
    print("🤿 Unequipping tank...")
    
    local success, result = pcall(function()
        if unequipRemote:IsA("RemoteFunction") then
            return unequipRemote:InvokeServer()
        else
            unequipRemote:FireServer()
            return true
        end
    end)
    
    if success then
        gearEquipped = false
        currentTank = nil
        
        -- Stop oxygen monitoring
        DivingGear.StopOxygenMonitor()
        
        print("✅ Tank unequipped")
        return true, "Unequipped"
    else
        print("❌ Failed to unequip tank:", result)
        return false, result
    end
end

function DivingGear.StartOxygenMonitor()
    spawn(function()
        while gearEquipped do
            task.wait(1)
            
            -- Check if underwater
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head then
                    isUnderwater = head.Position.Y < 0 -- Simple check
                    
                    if isUnderwater then
                        -- Deplete oxygen
                        oxygenLevel = math.max(0, oxygenLevel - oxygenDepletionRate)
                        
                        -- Update deepest dive
                        local depth = math.abs(head.Position.Y)
                        stats.DeepestDive = math.max(stats.DeepestDive, depth)
                        stats.LastDiveDepth = depth
                        
                        -- Check for low oxygen
                        if oxygenLevel <= 10 then
                            warn("⚠️ LOW OXYGEN:", math.floor(oxygenLevel), "remaining")
                        end
                        
                        if oxygenLevel <= 0 then
                            print("🚨 OXYGEN DEPLETED! Returning to surface...")
                            DivingGear.EmergencySurface()
                        end
                    else
                        -- Refill oxygen when surfaced
                        if oxygenLevel < (currentTank and currentTank.capacity or 100) then
                            oxygenLevel = math.min(currentTank.capacity, oxygenLevel + oxygenRefillRate)
                        end
                    end
                    
                    stats.TotalDiveTime = stats.TotalDiveTime + 1
                end
            end
        end
    end)
end

function DivingGear.StopOxygenMonitor()
    -- Monitor akan berhenti sendiri ketika loop while gearEquipped false
end

function DivingGear.EmergencySurface()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Teleport to surface
        local surfacePosition = Vector3.new(
            character.PrimaryPart.Position.X,
            10,
            character.PrimaryPart.Position.Z
        )
        
        character:SetPrimaryPartCFrame(CFrame.new(surfacePosition))
        print("🆘 Emergency surface complete")
    end
end

function DivingGear.RefillOxygen()
    if not gearEquipped or not currentTank then
        return false, "No tank equipped"
    end
    
    oxygenLevel = currentTank.capacity
    stats.RefillsUsed = stats.RefillsUsed + 1
    
    print("🔋 Oxygen refilled:", currentTank.name)
    return true, oxygenLevel
end

function DivingGear.GetAvailableTanks()
    return OXYGEN_TANKS
end

function DivingGear.GetCurrentTank()
    return currentTank
end

function DivingGear.GetOxygenStatus()
    local percentage = 0
    if currentTank then
        percentage = (oxygenLevel / currentTank.capacity) * 100
    end
    
    return {
        equipped = gearEquipped,
        tank = currentTank,
        oxygen = oxygenLevel,
        percentage = math.floor(percentage),
        isUnderwater = isUnderwater,
        remainingTime = math.floor(oxygenLevel / oxygenDepletionRate)
    }
end

function DivingGear.AutoEquipBestTank()
    -- Equip the best available tank
    local bestTank = OXYGEN_TANKS[#OXYGEN_TANKS]
    return DivingGear.EquipTank(bestTank.id)
end

function DivingGear.ToggleGear()
    if gearEquipped then
        return DivingGear.UnequipTank()
    else
        return DivingGear.AutoEquipBestTank()
    end
end

function DivingGear.GetStats()
    return {
        totalDiveTime = math.floor(stats.TotalDiveTime / 60), -- minutes
        deepestDive = math.floor(stats.DeepestDive),
        tanksUsed = stats.TanksUsed,
        refillsUsed = stats.RefillsUsed,
        currentDepth = stats.LastDiveDepth
    }
end

-- Auto initialize
spawn(function()
    task.wait(3)
    print("🤿 Fish Atelier Diving Gear System Initialized")
    DivingGear.DetectRemotes()
end)

return DivingGear