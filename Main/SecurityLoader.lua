-- 📁 ReplicatedStorage/SecurityLoader.lua
-- 🔒 Security Loader v4.0 - Khusus Fish Atelier

local SecurityLoader = {}

local CONFIG = {
    VERSION = "4.0.0",
    ALLOWED_DOMAIN = "raw.githubusercontent.com",
    GAME_ID = "35102746",
    GAME_NAME = "Fish Atelier"
}

local SECRET_KEY = (function()
    local parts = {
        string.char(70, 105, 115, 104), -- Fish
        string.char(65, 116, 101, 108, 105, 101, 114), -- Atelier
        string.char(95, 83, 69, 67, 82, 69, 84), -- _SECRET
        tostring(CONFIG.GAME_ID),
        string.char(35, 36, 37, 94, 38)
    }
    return table.concat(parts)
end)()

local function decrypt(encrypted, key)
    if encrypted == "" then return "" end
    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    encrypted = encrypted:gsub('[^'..b64..'=]', '')
    
    local decoded = (encrypted:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b64:find(x)-1)
        for i=6,1,-1 do r = r .. (f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i=1,8 do c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
    
    local result = {}
    for i = 1, #decoded do
        local byte = string.byte(decoded, i)
        local keyByte = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    
    return table.concat(result)
end

-- ENCRYPTED MODULE URLS UNTUK FISH ATELIER
local encryptedURLs = {
    FishAtelierCore = "U2FsdGVkX19XyLk5PqGtM8rNpQw2LbRvHcXyZzAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzAaBbCcDdEe==",
    TeleportModule = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl90ZWxlcG9ydA==",
    AutoFishing = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl9maXNoaW5n",
    AutoSell = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl9zZWxs",
    DivingGear = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl9kaXZpbmc=",
    FishingRadar = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl9yYWRhcg==",
    TotemSpawner = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl90b3RlbQ==",
    NotifySystem = "U2FsdGVkX18kLmNoYW5nZWRfZm9yX0Zpc2hfQXRlbGllcl9ub3RpZnk="
}

function SecurityLoader.LoadModule(moduleName)
    local encrypted = encryptedURLs[moduleName]
    if not encrypted then
        warn("❌ Module not found in Fish Atelier:", moduleName)
        return nil
    end
    
    local url = decrypt(encrypted, SECRET_KEY)
    
    if url == "" then
        -- Fallback untuk testing
        warn("⚠️ Using fallback for:", moduleName)
        return SecurityLoader.GetFallbackModule(moduleName)
    end
    
    if not url:find(CONFIG.ALLOWED_DOMAIN, 1, true) then
        warn("🚫 Security: Invalid domain for", moduleName)
        return nil
    end
    
    local success, result = pcall(function()
        local moduleCode = game:HttpGet(url, true)
        local moduleFunc = loadstring(moduleCode)
        return moduleFunc()
    end)
    
    if not success then
        warn("❌ Failed to load", moduleName, ":", result)
        return SecurityLoader.GetFallbackModule(moduleName)
    end
    
    print("✅ Fish Atelier Module Loaded:", moduleName)
    return result
end

function SecurityLoader.GetFallbackModule(moduleName)
    local fallbacks = {
        TeleportModule = function()
            local module = {}
            module.Locations = {
                ["Spawn"] = Vector3.new(0, 5, 0),
                ["Market"] = Vector3.new(100, 5, 100),
                ["Fishing Spot 1"] = Vector3.new(50, 5, 50),
                ["Fishing Spot 2"] = Vector3.new(-50, 5, -50),
                ["Deep Sea"] = Vector3.new(0, 5, 200),
                ["Coral Reef"] = Vector3.new(150, 5, 150)
            }
            function module.TeleportTo(name)
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root and module.Locations[name] then
                        root.CFrame = CFrame.new(module.Locations[name])
                        return true
                    end
                end
                return false
            end
            return module
        end,
        
        AutoFishing = function()
            local module = {}
            function module.StartFishing()
                print("🎣 [Fish Atelier] Starting fishing...")
                return true
            end
            function module.StartAutoFishing()
                print("🚀 [Fish Atelier] Auto fishing started")
                return true
            end
            function module.StopAutoFishing()
                print("🛑 [Fish Atelier] Auto fishing stopped")
                return true
            end
            return module
        end,
        
        AutoSell = function()
            local module = {}
            function module.SellAll()
                print("💰 [Fish Atelier] Selling all items...")
                return true
            end
            function module.StartAutoSell(interval)
                print("⚡ [Fish Atelier] Auto sell started, interval:", interval or 60)
                return true
            end
            return module
        end,
        
        NotifySystem = function()
            local module = {}
            function module.Send(title, message, duration)
                print("[Fish Atelier]", title .. ":", message)
            end
            setmetatable(module, {__call = function(self, ...) self.Send(...) end})
            return module
        end
    }
    
    return fallbacks[moduleName] and fallbacks[moduleName]() or {}
end

function SecurityLoader.LoadFishAtelierSystem()
    print("🎮 Loading Fish Atelier Complete System...")
    
    local system = {}
    
    -- Load core module
    system.Core = SecurityLoader.LoadModule("FishAtelierCore") or {}
    
    -- Load all modules
    system.Modules = {
        Teleport = SecurityLoader.LoadModule("TeleportModule"),
        Fishing = SecurityLoader.LoadModule("AutoFishing"),
        Sell = SecurityLoader.LoadModule("AutoSell"),
        Diving = SecurityLoader.LoadModule("DivingGear"),
        Radar = SecurityLoader.LoadModule("FishingRadar"),
        Totem = SecurityLoader.LoadModule("TotemSpawner"),
        Notify = SecurityLoader.LoadModule("NotifySystem")
    }
    
    -- Verify all modules loaded
    local loadedCount = 0
    for name, module in pairs(system.Modules) do
        if module then loadedCount = loadedCount + 1 end
    end
    
    print(string.format("✅ Fish Atelier System Loaded: %d/%d modules", loadedCount, #system.Modules))
    
    return system
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎮 FISH ATELIER LOADER v" .. CONFIG.VERSION)
print("📁 Game ID: " .. CONFIG.GAME_ID)
print("📦 Total Modules: " .. #encryptedURLs)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

return SecurityLoader