-- Fitur/autofishing.lua
-- Auto Fishing Module untuk Fish It

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Module table
local AutoFishing = {}

-- Cache untuk remote function
local fishingRemote = nil

-- Fungsi untuk mendapatkan remote function
local function getFishingRemote()
    if fishingRemote then
        return fishingRemote
    end
    
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
            :WaitForChild("RF/UpdateAutoFishingState")
    end)
    
    if success and result then
        fishingRemote = result
        return fishingRemote
    else
        warn("[AutoFishing] Failed to find remote function")
        return nil
    end
end

-- Enable auto fishing
function AutoFishing.enable()
    local remote = getFishingRemote()
    if not remote then
        return false
    end
    
    local args = {true}
    local success, result = pcall(function()
        return remote:InvokeServer(unpack(args))
    end)
    
    if success then
        print("[AutoFishing] Auto fishing enabled successfully")
        return true
    else
        warn("[AutoFishing] Failed to enable:", result)
        return false
    end
end

-- Disable auto fishing
function AutoFishing.disable()
    local remote = getFishingRemote()
    if not remote then
        return false
    end
    
    local args = {false}
    local success, result = pcall(function()
        return remote:InvokeServer(unpack(args))
    end)
    
    if success then
        print("[AutoFishing] Auto fishing disabled successfully")
        return true
    else
        warn("[AutoFishing] Failed to disable:", result)
        return false
    end
end

-- Toggle auto fishing
function AutoFishing.toggle()
    -- Cek status saat ini (mungkin perlu implementasi berdasarkan feedback game)
    -- Untuk sekarang, kita asumsikan perlu di-disable dulu
    return AutoFishing.disable()
end

-- Cek status auto fishing
function AutoFishing.getStatus()
    -- Note: Game mungkin tidak memberikan status, implementasi ini tergantung game
    -- Ini adalah placeholder
    return "Status check not implemented"
end

-- Auto fishing dengan interval (jika diperlukan)
function AutoFishing.startAuto(interval)
    interval = interval or 5 -- default 5 detik
    
    local running = true
    
    spawn(function()
        while running do
            AutoFishing.enable()
            wait(interval)
            
            -- Tambahkan logika untuk cek jika perlu disable sementara
            -- tergantung mekanisme game
        end
    end)
    
    return {
        stop = function()
            running = false
            AutoFishing.disable()
        end
    }
end

-- Initialize module
function AutoFishing.init()
    print("[AutoFishing] Module initialized")
    getFishingRemote() -- Pre-cache remote
    return true
end

-- Auto-initialize
AutoFishing.init()

return AutoFishing