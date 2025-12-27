-- loader.lua
-- Main loader untuk semua fitur

local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("Module loaded successfully")
        return result
    else
        warn("Failed to load module:", result)
        return nil
    end
end

-- Load semua module
print("=== Fish It Hub Loader ===")

-- Load UI
local UI = loadModule("https://github.com/DanzxxHosting/fishing-system-v2/blob/main/NeonUI.lua")

-- Atau untuk load local:
-- local UI = require(script.Parent.UI)

print("Loader finished!")