 -- Advanced Highlight Features System
-- features.lua - Place in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create RemoteEvent if needed
if not ReplicatedStorage:FindFirstChild("HighlightToggle") then
    Instance.new("RemoteEvent", ReplicatedStorage).Name = "HighlightToggle"
end

-- Configuration
local Config = {
    MaxDistance = 1000, -- Maximum distance to show highlights
    UpdateRate = 1, -- How often to update (seconds)
    CleanupInterval = 30, -- Cleanup interval (seconds)
    TeamBased = false, -- Set to true for team-based highlighting
    IncludeSelf = false -- Set to true to highlight self
}

-- Data storage
local PlayerHighlights = {} -- [viewer] = {[target] = highlight}
local PlayerSettings = {} -- [player] = {color, transparency, intensity, thickness}

-- Create advanced highlight
local function createAdvancedHighlight(character, settings)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight_" .. os.time()
    
    -- Apply settings
    highlight.FillColor = settings.Color
    highlight.OutlineColor = settings.Color
    highlight.FillTransparency = settings.Transparency
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Intensity affects fill transparency
    highlight.FillTransparency = settings.Transparency + (1 - settings.Intensity) * 0.4
    
    -- Outline thickness (custom property)
    highlight:SetAttribute("OutlineThickness", settings.Thickness)
    
    -- Custom glow effect
    local glow = Instance.new("PointLight")
    glow.Name = "HighlightGlow"
    glow.Color = settings.Color
    glow.Range = 15
    glow.Brightness = 0.5 * settings.Intensity
    glow.Enabled = false -- Will be enabled based on distance
    glow.Parent = highlight
    
    -- Pulse effect
    local pulseEnabled = false
    if settings.Pulse then
        pulseEnabled = true
    end
    
    highlight.Adornee = character
    highlight.Parent = character
    
    return highlight, glow, pulseEnabled
end

-- Distance-based highlighting
local function isWithinDistance(viewerChar, targetChar)
    if not viewerChar or not targetChar then return false end
    
    local viewerPos = viewerChar:GetPivot().Position
    local targetPos = targetChar:GetPivot().Position
    
    return (viewerPos - targetPos).Magnitude <= Config.MaxDistance
end

-- Team check
local function shouldHighlight(viewer, target, settings)
    if viewer == target and not Config.IncludeSelf then
        return false
    end
    
    if Config.TeamBased then
        local viewerTeam = viewer.Team
        local targetTeam = target.Team
        
        if viewerTeam and targetTeam then
            if settings.TeamMode == "Allies" then
                return viewerTeam == targetTeam
            elseif settings.TeamMode == "Enemies" then
                return viewerTeam ~= targetTeam
            end
        end
    end
    
    return true
end

-- Update highlights for a viewer
local function updateHighlightsForViewer(viewer, settings)
    -- Clean up old highlights
    if PlayerHighlights[viewer] then
        for _, highlight in pairs(PlayerHighlights[viewer]) do
            if highlight then
                highlight:Destroy()
            end
        end
    end
    
    PlayerHighlights[viewer] = {}
    
    local viewerChar = viewer.Character
    if not viewerChar then return end
    
    -- Create highlights for valid targets
    for _, target in ipairs(Players:GetPlayers()) do
        if shouldHighlight(viewer, target, settings) and target.Character then
            if isWithinDistance(viewerChar, target.Character) then
                local highlight, glow, pulseEnabled = createAdvancedHighlight(target.Character, settings)
                PlayerHighlights[viewer][target] = highlight
                
                -- Setup glow based on distance
                local distance = (viewerChar:GetPivot().Position - target.Character:GetPivot().Position).Magnitude
                glow.Enabled = distance < 50
            end
        end
    end
end

-- Handle pulse effect
local function startPulseEffect(highlight, settings)
    coroutine.wrap(function()
        while highlight and highlight.Parent do
            local currentTransparency = highlight.FillTransparency
            local targetTransparency = settings.Transparency + 0.2
            
            -- Pulse up
            for i = 1, 10 do
                if not highlight or not highlight.Parent then break end
                highlight.FillTransparency = currentTransparency + (targetTransparency - currentTransparency) * (i / 10)
                task.wait(0.05)
            end
            
            -- Pulse down
            for i = 1, 10 do
                if not highlight or not highlight.Parent then break end
                highlight.FillTransparency = targetTransparency - (targetTransparency - currentTransparency) * (i / 10)
                task.wait(0.05)
            end
        end
    end)()
end

-- Main toggle handler
ReplicatedStorage.HighlightToggle.OnServerEvent:Connect(function(player, enabled, settingsData)
    if enabled then
        -- Store player settings
        PlayerSettings[player] = {
            Color = settingsData.Color or Color3.fromRGB(100, 200, 255),
            Transparency = settingsData.Transparency or 0.5,
            Intensity = settingsData.Intensity or 0.8,
            Thickness = settingsData.Thickness or 2,
            Pulse = settingsData.Pulse or false,
            TeamMode = settingsData.TeamMode or "All"
        }
        
        -- Enable highlights
        updateHighlightsForViewer(player, PlayerSettings[player])
        
        print(player.Name .. " enabled advanced highlights")
        
        -- Notify client
        ReplicatedStorage.HighlightToggle:FireClient(player, "Enabled", {
            Message = "Highlights enabled!",
            Color = PlayerSettings[player].Color
        })
    else
        -- Disable highlights
        if PlayerHighlights[player] then
            for _, highlight in pairs(PlayerHighlights[player]) do
                if highlight then
                    highlight:Destroy()
                end
            end
            PlayerHighlights[player] = nil
        end
        PlayerSettings[player] = nil
        
        print(player.Name .. " disabled highlights")
        
        -- Notify client
        ReplicatedStorage.HighlightToggle:FireClient(player, "Disabled", {
            Message = "Highlights disabled."
        })
    end
end)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1) -- Wait for character to load
        
        -- Update highlights for all viewers who have this player highlighted
        for viewer, highlights in pairs(PlayerHighlights) do
            if viewer ~= player and highlights[player] then
                if highlights[player] then
                    highlights[player].Adornee = character
                    highlights[player].Parent = character
                end
            end
        end
    end)
end)

-- Continuous update loop
coroutine.wrap(function()
    while true do
        task.wait(Config.UpdateRate)
        
        -- Update all active highlights
        for viewer, settings in pairs(PlayerSettings) do
            if PlayerHighlights[viewer] then
                local viewerChar = viewer.Character
                if not viewerChar then continue end
                
                for target, highlight in pairs(PlayerHighlights[viewer]) do
                    if target and target.Character and highlight then
                        -- Update based on distance
                        local distance = (viewerChar:GetPivot().Position - target.Character:GetPivot().Position).Magnitude
                        
                        if distance <= Config.MaxDistance then
                            -- Update glow
                            local glow = highlight:FindFirstChild("HighlightGlow")
                            if glow then
                                glow.Enabled = distance < 50
                                glow.Brightness = 0.5 * settings.Intensity * (1 - distance / 100)
                            end
                            
                            -- Update transparency based on distance
                            local distanceFactor = 1 - (distance / Config.MaxDistance)
                            highlight.FillTransparency = settings.Transparency + (1 - distanceFactor) * 0.3
                        else
                            -- Out of range, hide highlight
                            highlight.FillTransparency = 1
                            highlight.OutlineTransparency = 1
                            local glow = highlight:FindFirstChild("HighlightGlow")
                            if glow then
                                glow.Enabled = false
                            end
                        end
                    end
                end
            end
        end
    end
end)()

-- Cleanup loop
coroutine.wrap(function()
    while true do
        task.wait(Config.CleanupInterval)
        
        -- Remove invalid highlights
        for viewer, highlights in pairs(PlayerHighlights) do
            if not viewer or not viewer.Parent then
                for _, highlight in pairs(highlights) do
                    if highlight then
                        highlight:Destroy()
                    end
                end
                PlayerHighlights[viewer] = nil
                PlayerSettings[viewer] = nil
            else
                for target, highlight in pairs(highlights) do
                    if not target or not target.Parent or not target.Character or not highlight or not highlight.Parent then
                        if highlight then
                            highlight:Destroy()
                        end
                        highlights[target] = nil
                    end
                end
            end
        end
    end
end)()

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    if PlayerHighlights[player] then
        for _, highlight in pairs(PlayerHighlights[player]) do
            if highlight then
                highlight:Destroy()
            end
        end
        PlayerHighlights[player] = nil
    end
    PlayerSettings[player] = nil
    
    -- Remove from other players' highlights
    for viewer, highlights in pairs(PlayerHighlights) do
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end
end)

print("Advanced Highlight Features loaded!")
