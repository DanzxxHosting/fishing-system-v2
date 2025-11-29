-- Complete Fishing Game for Roblox
-- Place this Script in ServerScriptService

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

-- Fishing Game Manager
local FishingGame = {}

-- Fish types with rarity and values
FishingGame.FISH_TYPES = {
    {Name = "Goldfish", Rarity = 1, Value = 10, Size = Vector3.new(1, 0.5, 0.5), Color = "Bright yellow"},
    {Name = "Bass", Rarity = 2, Value = 25, Size = Vector3.new(2, 0.8, 0.8), Color = "Dark green"},
    {Name = "Salmon", Rarity = 3, Value = 50, Size = Vector3.new(1.5, 0.6, 0.6), Color = "Bright orange"},
    {Name = "Tuna", Rarity = 4, Value = 100, Size = Vector3.new(2.5, 1, 1), Color = "Medium blue"},
    {Name = "Shark", Rarity = 5, Value = 200, Size = Vector3.new(4, 1.5, 1.5), Color = "Dark stone grey"},
    {Name = "Legendary Fish", Rarity = 10, Value = 1000, Size = Vector3.new(3, 1, 1), Color = "Bright violet"}
}

-- Player data storage
FishingGame.PlayerData = {}

-- Remote Events
FishingGame.Remotes = {
    AddFishToInventory = Instance.new("RemoteEvent"),
    GetPlayerInventory = Instance.new("RemoteEvent"),
    SellFish = Instance.new("RemoteEvent"),
    UpdateFishingRod = Instance.new("RemoteEvent")
}

-- Initialize the game
function FishingGame:Init()
    self:SetupRemotes()
    self:CreateFishingSpots()
    self:SetupPlayerHandlers()
    self:CreateWaterAreas()
    self:CreateFishingShop()
    
    print("Fishing Game Initialized!")
end

-- Setup Remote Events
function FishingGame:SetupRemotes()
    for name, remote in pairs(self.Remotes) do
        remote.Name = name
        remote.Parent = ReplicatedStorage
    end
    
    -- Handle remote events
    self.Remotes.AddFishToInventory.OnServerEvent:Connect(function(player, fishData)
        self:AddFishToInventory(player, fishData)
    end)
    
    self.Remotes.GetPlayerInventory.OnServerEvent:Connect(function(player)
        return self.PlayerData[player] and self.PlayerData[player].inventory or {}
    end)
    
    self.Remotes.SellFish.OnServerEvent:Connect(function(player, fishName, quantity)
        return self:SellFish(player, fishName, quantity or 1)
    end)
end

-- Create fishing spots around the map
function FishingGame:CreateFishingSpots()
    local spotPositions = {
        Vector3.new(50, 0, 50),
        Vector3.new(-50, 0, 50),
        Vector3.new(50, 0, -50),
        Vector3.new(-50, 0, -50),
        Vector3.new(0, 0, 75),
        Vector3.new(75, 0, 0),
        Vector3.new(-75, 0, 0)
    }
    
    for i, position in ipairs(spotPositions) do
        self:CreateFishingSpot(position, "FishingSpot" .. i)
    end
end

function FishingGame:CreateFishingSpot(position, name)
    local spot = Instance.new("Part")
    spot.Name = name
    spot.Size = Vector3.new(8, 1, 8)
    spot.Position = position
    spot.Anchored = true
    spot.CanCollide = false
    spot.Transparency = 1
    spot.Parent = Workspace
    
    -- Add particle effects
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(100, 150, 255))
    particleEmitter.Size = NumberSequence.new(0.3)
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 5
    particleEmitter.SpreadAngle = Vector2.new(45, 45)
    particleEmitter.Parent = spot
    
    -- Add glow
    local surfaceLight = Instance.new("SurfaceLight")
    surfaceLight.Brightness = 2
    surfaceLight.Color = Color3.fromRGB(100, 150, 255)
    surfaceLight.Range = 10
    surfaceLight.Parent = spot
    
    return spot
end

-- Create water areas for fishing
function FishingGame:CreateWaterAreas()
    local water = Instance.new("Part")
    water.Name = "Water"
    water.Size = Vector3.new(200, 5, 200)
    water.Position = Vector3.new(0, 0, 0)
    water.Anchored = true
    water.CanCollide = false
    water.Transparency = 0.7
    water.BrickColor = BrickColor.new("Bright blue")
    water.Material = Enum.Material.Water
    water.Parent = Workspace
end

-- Create fishing shop
function FishingGame:CreateFishingShop()
    local shop = Instance.new("Part")
    shop.Name = "FishingShop"
    shop.Size = Vector3.new(10, 10, 10)
    shop.Position = Vector3.new(0, 5, 100)
    shop.Anchored = true
    shop.BrickColor = BrickColor.new("Bright green")
    shop.Material = Enum.Material.WoodPlanks
    shop.Parent = Workspace
    
    -- Shop sign
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 8, 0)
    billboard.Parent = shop
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "FISH SHOP\nSell Your Fish Here!"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Fantasy
    label.Parent = billboard
end

-- Player management
function FishingGame:SetupPlayerHandlers()
    Players.PlayerAdded:Connect(function(player)
        self:InitializePlayer(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayerData(player)
    end)
    
    -- Initialize existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:InitializePlayer(player)
    end
end

function FishingGame:InitializePlayer(player)
    if not self.PlayerData[player] then
        self.PlayerData[player] = {
            inventory = {},
            money = 100, -- Starting money
            totalFishCaught = 0,
            fishingRodEquipped = false
        }
    end
    
    self:CreateFishingRod(player)
    self:UpdateLeaderstats(player)
    self:CreatePlayerGUI(player)
end

-- Fishing rod system
function FishingGame:CreateFishingRod(player)
    local tool = Instance.new("Tool")
    tool.Name = "FishingRod"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.Parent = player.Backpack
    
    -- Create handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 5, 1)
    handle.BrickColor = BrickColor.new("Brown")
    handle.Material = Enum.Material.Wood
    handle.Parent = tool
    
    -- Fishing line
    local fishingLine = Instance.new("Part")
    fishingLine.Name = "FishingLine"
    fishingLine.Size = Vector3.new(0.1, 0.1, 0.1)
    fishingLine.Transparency = 0.3
    fishingLine.BrickColor = BrickColor.new("White")
    fishingLine.CanCollide = false
    fishingLine.Anchored = true
    fishingLine.Parent = tool
    
    -- Bait
    local bait = Instance.new("Part")
    bait.Name = "Bait"
    bait.Size = Vector3.new(0.5, 0.5, 0.5)
    bait.Shape = Enum.PartType.Ball
    bait.BrickColor = BrickColor.new("Bright red")
    bait.CanCollide = false
    bait.Anchored = true
    bait.Parent = tool
    
    -- Tool script
    local toolScript = Instance.new("Script")
    toolScript.Parent = tool
    toolScript.Name = "FishingScript"
    
    -- Tool script code
    toolScript.Source = [[
        local tool = script.Parent
        local handle = tool:WaitForChild("Handle")
        local fishingLine = tool:WaitForChild("FishingLine")
        local bait = tool:WaitForChild("Bait")
        
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        
        local player = Players.LocalPlayer
        local character
        local humanoid
        
        local isFishing = false
        local isFishBiting = false
        local currentBiteTimeout
        
        -- Remote events
        local AddFishRemote = game:GetService("ReplicatedStorage"):WaitForChild("AddFishToInventory")
        
        -- Tool activation
        tool.Activated:Connect(function()
            if not character or not humanoid then return end
            
            if not isFishing then
                startFishing()
            elseif isFishBiting then
                reelFish()
            else
                stopFishing()
            end
        end)
        
        -- Character setup
        local function onCharacterAdded(newCharacter)
            character = newCharacter
            humanoid = character:WaitForChild("Humanoid")
        end
        
        if player.Character then
            onCharacterAdded(player.Character)
        end
        player.CharacterAdded:Connect(onCharacterAdded)
        
        -- Fishing functions
        function startFishing()
            if isFishing then return end
            
            -- Check if player is near water
            local rayOrigin = character.HumanoidRootPart.Position
            local rayDirection = (character.HumanoidRootPart.CFrame.LookVector * 20) + Vector3.new(0, -5, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if result and result.Instance:IsA("Part") and result.Instance.Name == "Water" then
                isFishing = true
                isFishBiting = false
                
                -- Cast fishing line
                castFishingLine(result.Position)
                
                -- Wait for fish bite (random time)
                local biteTime = math.random(2, 8)
                currentBiteTimeout = delay(biteTime, function()
                    if isFishing then
                        fishBite()
                    end
                end)
            else
                -- Not near water
                print("You need to be near water to fish!")
            end
        end
        
        function castFishingLine(waterPosition)
            -- Calculate fishing line length
            local lineLength = (character.HumanoidRootPart.Position - waterPosition).Magnitude
            
            -- Position fishing line between handle and bait
            fishingLine.Position = (character.HumanoidRootPart.Position + waterPosition) / 2
            fishingLine.CFrame = CFrame.lookAt(fishingLine.Position, waterPosition)
            fishingLine.Size = Vector3.new(0.05, 0.05, lineLength)
            fishingLine.Visible = true
            
            -- Position bait
            bait.Position = waterPosition
            bait.Visible = true
            
            -- Animate cast
            local castTween = TweenService:Create(
                bait,
                TweenInfo.new(0.3),
                {Position = waterPosition}
            )
            castTween:Play()
        end
        
        function fishBite()
            if not isFishing then return end
            
            isFishBiting = true
            
            -- Create splash effect
            createSplashEffect(bait.Position)
            
            -- Make bait bob up and down
            local startPos = bait.Position
            local bobConnection
            bobConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if not isFishing then
                    bobConnection:Disconnect()
                    return
                end
                local offset = math.sin(tick() * 8) * 0.3
                bait.Position = startPos + Vector3.new(0, offset, 0)
            end)
            
            -- Show notification
            print("🎣 Fish is biting! Click again to reel in!")
            
            -- Fish will escape after some time
            delay(3, function()
                if isFishBiting then
                    print("❌ Fish got away!")
                    stopFishing()
                end
            end)
        end
        
        function reelFish()
            if not isFishBiting then return end
            
            -- Calculate catch based on rarity
            local FISH_TYPES = {
                {Name = "Goldfish", Rarity = 1, Value = 10},
                {Name = "Bass", Rarity = 2, Value = 25},
                {Name = "Salmon", Rarity = 3, Value = 50},
                {Name = "Tuna", Rarity = 4, Value = 100},
                {Name = "Shark", Rarity = 5, Value = 200},
                {Name = "Legendary Fish", Rarity = 10, Value = 1000}
            }
            
            local totalRarity = 0
            for _, fish in pairs(FISH_TYPES) do
                totalRarity += fish.Rarity
            end
            
            local roll = math.random(1, totalRarity)
            local currentRarity = 0
            local caughtFish = nil
            
            for _, fish in pairs(FISH_TYPES) do
                currentRarity += fish.Rarity
                if roll <= currentRarity then
                    caughtFish = fish
                    break
                end
            end
            
            if caughtFish then
                catchFish(caughtFish)
            end
            
            stopFishing()
        end
        
        function catchFish(fishData)
            -- Create visual fish
            local fish = Instance.new("Part")
            fish.Name = "CaughtFish"
            fish.Size = Vector3.new(1, 0.5, 0.5)
            fish.Position = bait.Position
            fish.Anchored = true
            fish.CanCollide = false
            fish.BrickColor = BrickColor.new("Bright orange")
            fish.Material = Enum.Material.SmoothPlastic
            fish.Parent = workspace
            
            -- Animate fish to player
            local tween = TweenService:Create(
                fish,
                TweenInfo.new(1, Enum.EasingStyle.Back),
                {Position = character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)}
            )
            tween:Play()
            
            -- Show catch notification
            print("🎉 You caught a " .. fishData.Name .. "! Worth: $" .. fishData.Value)
            
            -- Add to inventory
            AddFishRemote:FireServer(fishData)
            
            -- Clean up
            game:GetService("Debris"):AddItem(fish, 2)
        end
        
        function stopFishing()
            isFishing = false
            isFishBiting = false
            fishingLine.Visible = false
            bait.Visible = false
            
            if currentBiteTimeout then
                currentBiteTimeout:disconnect()
                currentBiteTimeout = nil
            end
        end
        
        function createSplashEffect(position)
            local splash = Instance.new("Part")
            splash.Name = "Splash"
            splash.Size = Vector3.new(3, 0.2, 3)
            splash.Position = position + Vector3.new(0, 1, 0)
            splash.Anchored = true
            splash.CanCollide = false
            splash.BrickColor = BrickColor.new("Bright blue")
            splash.Transparency = 0.3
            splash.Material = Enum.Material.Water
            splash.Parent = workspace
            
            local tween = TweenService:Create(
                splash,
                TweenInfo.new(0.5),
                {Size = Vector3.new(5, 0.1, 5), Transparency = 1}
            )
            tween:Play()
            
            game:GetService("Debris"):AddItem(splash, 1)
        end
        
        -- Clean up when tool is unequipped
        tool.Unequipped:Connect(function()
            stopFishing()
        end)
    ]]
end

-- Inventory system
function FishingGame:AddFishToInventory(player, fishData)
    if not self.PlayerData[player] then
        self:InitializePlayer(player)
    end
    
    local playerData = self.PlayerData[player]
    
    if not playerData.inventory[fishData.Name] then
        playerData.inventory[fishData.Name] = {
            count = 0,
            data = fishData
        }
    end
    
    playerData.inventory[fishData.Name].count += 1
    playerData.totalFishCaught += 1
    
    self:UpdateLeaderstats(player)
    
    -- Notify player
    self:NotifyPlayer(player, "🎣 You caught a " .. fishData.Name .. "! ($" .. fishData.Value .. ")")
end

function FishingGame:SellFish(player, fishName, quantity)
    if not self.PlayerData[player] then return 0 end
    
    local playerData = self.PlayerData[player]
    local fishInfo = playerData.inventory[fishName]
    
    if fishInfo and fishInfo.count >= quantity then
        local totalValue = fishInfo.data.Value * quantity
        fishInfo.count -= quantity
        
        if fishInfo.count <= 0 then
            playerData.inventory[fishName] = nil
        end
        
        playerData.money += totalValue
        self:UpdateLeaderstats(player)
        
        self:NotifyPlayer(player, "💰 Sold " .. quantity .. " " .. fishName .. " for $" .. totalValue)
        
        return totalValue
    end
    
    return 0
end

-- Leaderstats
function FishingGame:UpdateLeaderstats(player)
    local playerData = self.PlayerData[player]
    if not playerData then return end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end
    
    -- Money
    local moneyValue = leaderstats:FindFirstChild("Money")
    if not moneyValue then
        moneyValue = Instance.new("IntValue")
        moneyValue.Name = "Money"
        moneyValue.Parent = leaderstats
    end
    moneyValue.Value = playerData.money
    
    -- Fish Caught
    local fishCaughtValue = leaderstats:FindFirstChild("FishCaught")
    if not fishCaughtValue then
        fishCaughtValue = Instance.new("IntValue")
        fishCaughtValue.Name = "FishCaught"
        fishCaughtValue.Parent = leaderstats
    end
    fishCaughtValue.Value = playerData.totalFishCaught
end

-- Player GUI
function FishingGame:CreatePlayerGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Fishing Shop GUI
    local shopGui = Instance.new("ScreenGui")
    shopGui.Name = "FishingShopGui"
    shopGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = shopGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    title.Text = "FISH SHOP"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.Fantasy
    title.Parent = mainFrame
    
    local fishList = Instance.new("ScrollingFrame")
    fishList.Size = UDim2.new(1, -20, 1, -120)
    fishList.Position = UDim2.new(0, 10, 0, 60)
    fishList.BackgroundTransparency = 1
    fishList.Parent = mainFrame
    
    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0, 150, 0, 40)
    sellButton.Position = UDim2.new(0.5, -75, 1, -50)
    sellButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    sellButton.Text = "SELL ALL FISH"
    sellButton.TextColor3 = Color3.new(1, 1, 1)
    sellButton.TextScaled = true
    sellButton.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(1, -110, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame
    
    -- Shop interaction
    local function toggleShop()
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            updateFishList()
        end
    end
    
    local function updateFishList()
        fishList:ClearAllChildren()
        
        local playerInventory = self.Remotes.GetPlayerInventory:InvokeServer(player)
        local yOffset = 0
        
        for fishName, fishInfo in pairs(playerInventory) do
            local fishFrame = Instance.new("Frame")
            fishFrame.Size = UDim2.new(1, 0, 0, 40)
            fishFrame.Position = UDim2.new(0, 0, 0, yOffset)
            fishFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            fishFrame.BorderSizePixel = 0
            
            local fishNameLabel = Instance.new("TextLabel")
            fishNameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            fishNameLabel.Position = UDim2.new(0, 5, 0, 0)
            fishNameLabel.BackgroundTransparency = 1
            fishNameLabel.Text = fishName
            fishNameLabel.TextColor3 = Color3.new(1, 1, 1)
            fishNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            fishNameLabel.Parent = fishFrame
            
            local fishCountLabel = Instance.new("TextLabel")
            fishCountLabel.Size = UDim2.new(0.2, 0, 1, 0)
            fishCountLabel.Position = UDim2.new(0.4, 0, 0, 0)
            fishCountLabel.BackgroundTransparency = 1
            fishCountLabel.Text = "x" .. fishInfo.count
            fishCountLabel.TextColor3 = Color3.new(1, 1, 1)
            fishCountLabel.Parent = fishFrame
            
            local fishValueLabel = Instance.new("TextLabel")
            fishValueLabel.Size = UDim2.new(0.3, 0, 1, 0)
            fishValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            fishValueLabel.BackgroundTransparency = 1
            fishValueLabel.Text = "$" .. fishInfo.data.Value
            fishValueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            fishValueLabel.Parent = fishFrame
            
            fishFrame.Parent = fishList
            yOffset += 45
        end
        
        fishList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    sellButton.MouseButton1Click:Connect(function()
        local totalEarned = 0
        local playerInventory = self.Remotes.GetPlayerInventory:InvokeServer(player)
        
        for fishName, fishInfo in pairs(playerInventory) do
            totalEarned += self.Remotes.SellFish:InvokeServer(player, fishName, fishInfo.count)
        end
        
        if totalEarned > 0 then
            self:NotifyPlayer(player, "💰 Sold all fish for $" .. totalEarned)
            updateFishList()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        toggleShop()
    end)
    
    -- Open shop when player touches shop
    workspace.FishingShop.Touched:Connect(function(part)
        if part:IsA("Part") and part.Parent == player.Character then
            toggleShop()
        end
    end)
end

-- Utility functions
function FishingGame:NotifyPlayer(player, message)
    -- You can implement a proper notification system here
    print("[" .. player.Name .. "] " .. message)
end

function FishingGame:SavePlayerData(player)
    -- Implement data saving using DataStoreService
    -- This is where you'd save player progress
end

-- Start the game
FishingGame:Init()

return FishingGame
