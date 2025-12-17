-- Place this LocalScript in StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.9
    highlight.Adornee = character
    highlight.Parent = character
    
    -- Make highlight pulse
    local pulseSpeed = 2
    local time = 0
    local connection = RunService.RenderStepped:Connect(function(delta)
        time = time + delta * pulseSpeed
        local transparency = 0.7 + 0.2 * math.sin(time)
        highlight.FillTransparency = transparency
    end)
    
    -- Clean up connection when highlight is removed
    highlight.AncestryChanged:Connect(function()
        if not highlight:IsDescendantOf(game) then
            connection:Disconnect()
        end
    end)
    
    return highlight
end

local function highlightOtherPlayers()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            if otherPlayer.Character then
                createHighlight(otherPlayer.Character)
            end
            otherPlayer.CharacterAdded:Connect(function(character)
                createHighlight(character)
            end)
        end
    end
end

-- Start highlighting
highlightOtherPlayers()

-- Handle new players joining
Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= player then
        newPlayer.CharacterAdded:Connect(function(character)
            createHighlight(character)
        end)
    end
end)
