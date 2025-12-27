-- 📁 ReplicatedStorage/AutoSell.lua
-- 💰 Auto Sell System khusus Fish Atelier

local AutoSell = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local autoSellEnabled = false
local sellConnection = nil
local lastSellTime = 0
local sellRemote = nil

-- Configuration
local CONFIG = {
    AUTO_SELL_INTERVAL = 60, -- detik
    MIN_VALUE_TO_SELL = 100,
    ENABLE_NOTIFICATIONS = true,
    SAFE_MODE = true,
    SELL_RARITY_FILTER = {"Common", "Uncommon"} -- Jual yang common saja
}

-- Statistics
local stats = {
    TotalSales = 0,
    TotalValue = 0,
    LastSaleAmount = 0,
    LastSaleTime = 0,
    SalesToday = 0,
    ItemsSoldToday = 0
}

-- Item database untuk Fish Atelier
local ITEM_VALUES = {
    -- Common fish
    ["Small Fish"] = 10,
    ["Carp"] = 15,
    ["Bass"] = 20,
    ["Trout"] = 25,
    ["Sardine"] = 8,
    
    -- Uncommon fish
    ["Salmon"] = 50,
    ["Tuna"] = 60,
    ["Mackerel"] = 45,
    ["Catfish"] = 40,
    
    -- Rare fish
    ["Sturgeon"] = 150,
    ["Mahi Mahi"] = 180,
    ["Snapper"] = 120,
    
    -- Epic fish
    ["Marlin"] = 500,
    ["Swordfish"] = 450,
    
    -- Legendary fish (sebaiknya tidak dijual auto)
    ["Golden Fish"] = 5000,
    ["Dragon Fish"] = 10000,
    
    -- Other items
    ["Old Boot"] = 1,
    ["Seaweed"] = 2,
    ["Pearl"] = 100,
    ["Gold Coin"] = 200
}

function AutoSell.DetectSellRemote()
    print("🔍 Detecting Fish Atelier sell remote...")
    
    -- Coba path yang mungkin
    local possiblePaths = {
        "Packages/_Index/sleitnick_net@0.2.0/net/RF/SellAllItems",
        "ReplicatedStorage/Remotes/Sell/SellAll",
        "ReplicatedStorage/Events/SellItems",
        "ReplicatedStorage/FishingSystem/Remotes/SellFish",
        "ReplicatedStorage/Trading/SellAll"
    }
    
    for _, path in ipairs(possiblePaths) do
        local remote = ReplicatedStorage:FindFirstChild(path, true)
        if remote then
            sellRemote = remote
            print("✅ Found sell remote:", path)
            return true
        end
    end
    
    -- Search manual
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("sell") or name:find("trade") or name:find("vendor") then
                sellRemote = remote
                print("✅ Found potential sell remote:", remote:GetFullName())
                return true
            end
        end
    end
    
    print("❌ Sell remote not found")
    return false
end

function AutoSell.EstimateInventoryValue()
    -- Estimate total value of sellable items
    local totalValue = 0
    local itemCount = 0
    
    -- Cek di backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            local itemName = item.Name
            local value = ITEM_VALUES[itemName]
            
            if value then
                -- Cek rarity filter
                local shouldSell = false
                for _, rarity in ipairs(CONFIG.SELL_RARITY_FILTER) do
                    for _, fishName in ipairs({
                        ["Common"] = {"Small Fish", "Carp", "Bass", "Trout", "Sardine", "Old Boot", "Seaweed"},
                        ["Uncommon"] = {"Salmon", "Tuna", "Mackerel", "Catfish"},
                        ["Rare"] = {"Sturgeon", "Mahi Mahi", "Snapper", "Pearl"},
                        ["Epic"] = {"Marlin", "Swordfish"},
                        ["Legendary"] = {"Golden Fish", "Dragon Fish", "Gold Coin"}
                    }[rarity] or {}) do
                        if itemName == fishName then
                            shouldSell = true
                            break
                        end
                    end
                    if shouldSell then break end
                end
                
                if shouldSell then
                    totalValue = totalValue + value
                    itemCount = itemCount + 1
                end
            end
        end
    end
    
    return totalValue, itemCount
end

function AutoSell.SellAllItems()
    if not sellRemote then
        if not AutoSell.DetectSellRemote() then
            return false, "Sell remote not found"
        end
    end
    
    -- Estimate value sebelum sell
    local estimatedValue, itemCount = AutoSell.EstimateInventoryValue()
    
    if CONFIG.SAFE_MODE and estimatedValue < CONFIG.MIN_VALUE_TO_SELL then
        return false, string.format("Value too low: %d < %d", estimatedValue, CONFIG.MIN_VALUE_TO_SELL)
    end
    
    print(string.format("💰 Selling %d items (est. value: %d)...", itemCount, estimatedValue))
    
    local success, result = pcall(function()
        if sellRemote:IsA("RemoteFunction") then
            return sellRemote:InvokeServer()
        elseif sellRemote:IsA("RemoteEvent") then
            sellRemote:FireServer()
            return true
        end
    end)
    
    if success then
        -- Update statistics
        stats.TotalSales = stats.TotalSales + 1
        stats.TotalValue = stats.TotalValue + estimatedValue
        stats.LastSaleAmount = estimatedValue
        stats.LastSaleTime = tick()
        stats.SalesToday = stats.SalesToday + 1
        stats.ItemsSoldToday = stats.ItemsSoldToday + itemCount
        
        -- Reset daily stats at midnight
        spawn(function()
            while true do
                local now = os.time()
                local tomorrow = os.time{
                    year = os.date("%Y"),
                    month = os.date("%m"),
                    day = os.date("%d") + 1
                }
                local secondsUntilMidnight = tomorrow - now
                
                task.wait(secondsUntilMidnight)
                stats.SalesToday = 0
                stats.ItemsSoldToday = 0
                print("📅 Daily sales reset")
            end
        end)
        
        print(string.format("✅ Sold %d items for ~%d coins", itemCount, estimatedValue))
        return true, estimatedValue
    else
        print("❌ Sell failed:", result)
        return false, result
    end
end

function AutoSell.StartAutoSell(interval)
    if autoSellEnabled then
        print("⚠️ Auto sell already running")
        return false
    end
    
    interval = interval or CONFIG.AUTO_SELL_INTERVAL
    
    if interval < 10 then
        print("⚠️ Interval too short, minimum 10 seconds")
        return false
    end
    
    CONFIG.AUTO_SELL_INTERVAL = interval
    
    print("🚀 Starting auto sell system...")
    print("⏰ Interval:", interval, "seconds")
    
    -- Deteksi remote
    if not sellRemote then
        AutoSell.DetectSellRemote()
    end
    
    autoSellEnabled = true
    
    -- Main loop
    sellConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not autoSellEnabled then return end
        
        local currentTime = tick()
        if currentTime - lastSellTime >= CONFIG.AUTO_SELL_INTERVAL then
            AutoSell.SellAllItems()
            lastSellTime = currentTime
        end
    end)
    
    return true
end

function AutoSell.StopAutoSell()
    print("🛑 Stopping auto sell...")
    
    autoSellEnabled = false
    
    if sellConnection then
        sellConnection:Disconnect()
        sellConnection = nil
    end
end

function AutoSell.SellNow()
    return AutoSell.SellAllItems()
end

function AutoSell.SetSellFilter(rarityList)
    CONFIG.SELL_RARITY_FILTER = rarityList or {"Common", "Uncommon"}
    print("⚙️ Sell filter updated:", table.concat(CONFIG.SELL_RARITY_FILTER, ", "))
    return true
end

function AutoSell.SetMinValue(minValue)
    CONFIG.MIN_VALUE_TO_SELL = minValue
    print("⚙️ Minimum sell value set to:", minValue)
    return true
end

function AutoSell.GetStats()
    local nextSaleIn = autoSellEnabled and 
        math.max(0, CONFIG.AUTO_SELL_INTERVAL - (tick() - lastSellTime)) or 0
    
    return {
        Enabled = autoSellEnabled,
        Interval = CONFIG.AUTO_SELL_INTERVAL,
        TotalSales = stats.TotalSales,
        TotalValue = stats.TotalValue,
        LastSaleAmount = stats.LastSaleAmount,
        SalesToday = stats.SalesToday,
        ItemsSoldToday = stats.ItemsSoldToday,
        NextSaleIn = math.floor(nextSaleIn),
        InventoryValue = AutoSell.EstimateInventoryValue()
    }
end

function AutoSell.AddItemValue(itemName, value)
    ITEM_VALUES[itemName] = value
    print("📝 Item value added:", itemName, "=", value)
    return true
end

-- Auto initialize
spawn(function()
    task.wait(5)
    print("💰 Fish Atelier Auto Sell System Initialized")
    AutoSell.DetectSellRemote()
end)

return AutoSell