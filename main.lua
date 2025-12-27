-- main.lua
-- Simple loader untuk semua fitur

print("=== Loading Fish It Hub ===")

-- Load Auto Fishing module
local AutoFishing = loadstring(game:HttpGet("https://raw.githubusercontent.com/DanzxxHosting/fishing-system-v2/refs/heads/main/Main/autofishing.lua"))()

-- Load UI
local UI = loadstring(game:HttpGet("https://github.com/DanzxxHosting/fishing-system-v2/blob/main/NeonUI.lua"))()

print("=== Fish It Hub Loaded Successfully ===")
print("Press F9 to toggle UI")
print("Use the Auto Fishing tab to control features")

-- Return modules
return {
    UI = UI,
    AutoFishing = AutoFishing
}