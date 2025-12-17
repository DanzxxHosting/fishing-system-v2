-- Working Highlight System
-- Place in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create RemoteEvent if needed
if not ReplicatedStorage:FindFirstChild("HighlightToggle") then
    Instance.new("RemoteEvent", ReplicatedStorage).Name = "HighlightToggle"
end

-- Store player highlights
local PlayerHighlights = {}

-- Clean up function
local function cleanupPlayerHighlights(player)
    if PlayerHighlights[player] then
        for _, highlight in pairs(PlayerHighlights[player]) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        PlayerHighlights[player] = nil
    end
end

-- Create highlight for a character
local function createHighlight(character, color, transparency, intensity)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = transparency
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Adjust intensity
    if intensity then
        highlight.FillTransparency = transparency + (1 - intensity) * 0.3
    end
    
    highlight.Adornee = character
    highlight.Parent = character
    
    return highlight
end

-- Highlight all players for a viewer
local function highlightAllPlayers(viewer, color, transparency, intensity)
    -- Clean up existing highlights
    cleanupPlayerHighlights(viewer)
    
    -- Create new highlights for all other players
    PlayerHighlights[viewer] = {}
    
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= viewer and target.Character then
            local highlight = createHighlight(target.Character, color, transparency, intensity)
            highlight.Name = viewer.Name .. "_View_" .. target.Name
            PlayerHighlights[viewer][target] = highlight
        end
    end
    
    -- Set up character added events for all players
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= viewer then
            target.CharacterAdded:Connect(function(character)
                task.wait(1) -- Wait for character to load
                
                if PlayerHighlights[viewer] and PlayerHighlights[viewer][target] then
                    -- Update existing highlight
                    PlayerHighlights[viewer][target].Adornee = character
                    PlayerHighlights[viewer][target].Parent = character
                elseif PlayerHighlights[viewer] then
                    -- Create new highlight
                    local highlight = createHighlight(character, color, transparency, intensity)
                    highlight.Name = viewer.Name .. "_View_" .. target.Name
                    PlayerHighlights[viewer][target] = highlight
                end
            end)
        end
    end
end

-- Handle toggle requests
ReplicatedStorage.HighlightToggle.OnServerEvent:Connect(function(player, enabled, settings)
    if enabled then
        -- Enable highlights
        local color = settings.Color or Color3.fromRGB(60, 160, 255)
        local transparency = settings.Transparency or 0.7
        local intensity = settings.Intensity or 0.8
        
        print(player.Name .. " enabled highlights with color: " .. tostring(color))
        
        highlightAllPlayers(player, color, transparency, intensity)
        
        -- Notify player
        task.spawn(function()
            local notification = Instance.new("Sound")
            notification.SoundId = "rbxassetid://3570574874" -- Click sound
            notification.Parent = player.Character or player:WaitForChild("Character")
            notification:Play()
            game:GetService("Debris"):AddItem(notification, 2)
        end)
    else
        -- Disable highlights
        cleanupPlayerHighlights(player)
        print(player.Name .. " disabled highlights")
        
        -- Notify player
        task.spawn(function()
            local notification = Instance.new("Sound")
            notification.SoundId = "rbxassetid://3570574874"
            notification.Parent = player.Character or player:WaitForChild("Character")
            notification:Play()
            game:GetService("Debris"):AddItem(notification, 2)
        end)
    end
end)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Check if any player is highlighting this new player
        for viewer, highlights in pairs(PlayerHighlights) do
            if viewer ~= player and highlights then
                task.wait(1)
                for target, highlight in pairs(highlights) do
                    if target == player and highlight then
                        highlight.Adornee = character
                        highlight.Parent = character
                    end
                end
            end
        end
    end)
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    cleanupPlayerHighlights(player)
    
    -- Remove highlights targeting this player
    for viewer, highlights in pairs(PlayerHighlights) do
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end
end)

-- Optional: Auto-cleanup every 30 seconds to prevent memory leaks
while true do
    task.wait(30)
    
    for viewer, highlights in pairs(PlayerHighlights) do
        if not viewer or not viewer.Parent then
            cleanupPlayerHighlights(viewer)
        else
            for target, highlight in pairs(highlights) do
                if not target or not target.Parent or not highlight or not highlight.Parent then
                    if highlight then
                        highlight:Destroy()
                    end
                    highlights[target] = nil
                end
            end
        end
    end
end
