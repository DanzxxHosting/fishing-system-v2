-- Fishing System - Single Script Version
-- Letakkan di ServerScriptService dengan nama "FishingSystem"

local FishingSystem = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Data Ikan
local FishData = {
    {
        Name = "Ikan Kecil",
        Rarity = "Common",
        MinWeight = 0.1,
        MaxWeight = 1.0,
        Probability = 0.6,
        Value = 10,
        Emoji = "🐟"
    },
    {
        Name = "Ikan Sedang",
        Rarity = "Uncommon", 
        MinWeight = 1.0,
        MaxWeight = 3.0,
        Probability = 0.3,
        Value = 25,
        Emoji = "🐠"
    },
    {
        Name = "Ikan Besar",
        Rarity = "Rare",
        MinWeight = 3.0,
        MaxWeight = 8.0,
        Probability = 0.08,
        Value = 50,
        Emoji = "🦈"
    },
    {
        Name = "Ikan Legendaris",
        Rarity = "Legendary",
        MinWeight = 8.0,
        MaxWeight = 15.0,
        Probability = 0.02,
        Value = 100,
        Emoji = "🐋"
    }
}

-- Player Data untuk menyimpan inventory
local PlayerData = {}

-- Remote Events
local StartFishingEvent = Instance.new("RemoteEvent")
StartFishingEvent.Name = "StartFishing"
StartFishingEvent.Parent = ReplicatedStorage

local UpdateUIEvent = Instance.new("RemoteEvent")
UpdateUIEvent.Name = "UpdateFishingUI"
UpdateUIEvent.Parent = ReplicatedStorage

-- Fungsi untuk mendapatkan ikan random
local function GetRandomFish()
    local randomValue = math.random()
    local cumulativeProbability = 0
    
    for _, fish in ipairs(FishData) do
        cumulativeProbability += fish.Probability
        if randomValue <= cumulativeProbability then
            local weight = math.random(fish.MinWeight * 100, fish.MaxWeight * 100) / 100
            return {
                Name = fish.Name,
                Rarity = fish.Rarity,
                Weight = weight,
                Value = fish.Value,
                Emoji = fish.Emoji
            }
        end
    end
    
    return GetRandomFish() -- Fallback
end

-- Fungsi untuk membuat UI di client
local function CreatePlayerUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Hapus UI lama jika ada
    local oldUI = playerGui:FindFirstChild("FishingGUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Buat UI baru
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishingGUI"
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 180)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.Text = "🎣 SISTEM MEMANCING"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Fishing Button
    local fishButton = Instance.new("TextButton")
    fishButton.Size = UDim2.new(0, 200, 0, 40)
    fishButton.Position = UDim2.new(0.5, -100, 0.3, 0)
    fishButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    fishButton.Text = "🎣 MULAI MEMANCING"
    fishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fishButton.TextSize = 14
    fishButton.Font = Enum.Font.GothamBold
    fishButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = fishButton
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
    statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Tekan F atau klik tombol untuk memancing"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    -- Result Label
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Size = UDim2.new(0.9, 0, 0, 40)
    resultLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    resultLabel.BackgroundTransparency = 1
    resultLabel.Text = ""
    resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    resultLabel.TextSize = 13
    resultLabel.Font = Enum.Font.GothamBold
    resultLabel.TextWrapped = true
    resultLabel.Parent = mainFrame
    
    -- Stats Label
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, 0, 0, 20)
    statsLabel.Position = UDim2.new(0, 0, 1, -20)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Total Ikan: 0 | Coins: 0"
    statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statsLabel.TextSize = 11
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.Parent = mainFrame
    
    -- Event handlers untuk UI
    fishButton.MouseButton1Click:Connect(function()
        StartFishingEvent:FireServer()
    end)
    
    -- Hotkey F
    local UserInputService = game:GetService("UserInputService")
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F then
            StartFishingEvent:FireServer()
        end
    end)
    
    -- Cleanup connection ketika player leaves
    player:GetPropertyChangedSignal("Parent"):Connect(function()
        if player.Parent == nil then
            connection:Disconnect()
        end
    end)
    
    return {
        FishButton = fishButton,
        StatusLabel = statusLabel,
        ResultLabel = resultLabel,
        StatsLabel = statsLabel
    }
end

-- Fungsi untuk update UI client
local function UpdatePlayerUI(player, status, result, fishData)
    local uiData = {
        Status = status,
        Result = result,
        FishData = fishData,
        PlayerData = PlayerData[player.UserId]
    }
    UpdateUIEvent:FireClient(player, uiData)
end

-- Main fishing function
StartFishingEvent.OnServerEvent:Connect(function(player)
    local userId = player.UserId
    
    -- Initialize player data jika belum ada
    if not PlayerData[userId] then
        PlayerData[userId] = {
            TotalFish = 0,
            TotalCoins = 0,
            Inventory = {},
            IsFishing = false
        }
    end
    
    local data = PlayerData[userId]
    
    -- Cek jika sedang memancing
    if data.IsFishing then
        UpdatePlayerUI(player, "error", "Sedang memancing, tunggu sebentar!")
        return
    end
    
    -- Set status memancing
    data.IsFishing = true
    UpdatePlayerUI(player, "fishing", "Sedang memancing...")
    
    -- Waktu memancing random (2-8 detik)
    local fishingTime = math.random(2, 8)
    
    -- Tunggu waktu memancing
    wait(fishingTime)
    
    -- Cek jika player masih ada
    if not player or not player.Parent then
        return
    end
    
    -- Dapatkan ikan random
    local caughtFish = GetRandomFish()
    
    -- Update player data
    data.TotalFish += 1
    data.TotalCoins += caughtFish.Value
    table.insert(data.Inventory, caughtFish)
    data.IsFishing = false
    
    -- Tentukan warna berdasarkan rarity
    local color = Color3.fromRGB(255, 255, 255) -- Default white
    if caughtFish.Rarity == "Uncommon" then
        color = Color3.fromRGB(0, 255, 0) -- Green
    elseif caughtFish.Rarity == "Rare" then
        color = Color3.fromRGB(0, 120, 255) -- Blue
    elseif caughtFish.Rarity == "Legendary" then
        color = Color3.fromRGB(255, 215, 0) -- Gold
    end
    
    -- Format result text
    local resultText = string.format("%s %s\n⚖️ %.2f kg | 💰 %d coins", 
        caughtFish.Emoji, caughtFish.Name, caughtFish.Weight, caughtFish.Value)
    
    -- Update UI
    UpdatePlayerUI(player, "success", resultText, {
        Fish = caughtFish,
        Color = color
    })
    
    -- Print ke console server
    print(string.format("[FISHING] %s menangkap: %s (%.2f kg) - %d coins", 
        player.Name, caughtFish.Name, caughtFish.Weight, caughtFish.Value))
end)

-- Handler untuk update UI di client
UpdateUIEvent.OnClientEvent:Connect(function(uiData)
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local fishingGUI = playerGui:FindFirstChild("FishingGUI")
    
    if not fishingGUI then return end
    
    local mainFrame = fishingGUI:FindFirstChild("Frame")
    if not mainFrame then return end
    
    local statusLabel = mainFrame:FindFirstChild("TextLabel")
    local resultLabel = mainFrame:FindFirstChild("TextLabel")
    local statsLabel = mainFrame:FindFirstChild("TextLabel")
    local fishButton = mainFrame:FindFirstChild("TextButton")
    
    -- Cari elements yang benar
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            if child.Position.Y.Scale == 0.6 then
                statusLabel = child
            elseif child.Position.Y.Scale == 0.75 then
                resultLabel = child
            elseif child.Position.Y.Scale > 0.9 then
                statsLabel = child
            end
        elseif child:IsA("TextButton") and child.Text:find("MEMANCING") then
            fishButton = child
        end
    end
    
    if uiData.Status == "fishing" then
        statusLabel.Text = uiData.Result
        fishButton.Text = "⏳ SEDANG MEMANCING..."
        fishButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        fishButton.Active = false
        resultLabel.Text = ""
        
    elseif uiData.Status == "success" then
        statusLabel.Text = "🎉 Berhasil menangkap ikan!"
        fishButton.Text = "🎣 MULAI MEMANCING"
        fishButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        fishButton.Active = true
        resultLabel.Text = uiData.Result
        resultLabel.TextColor3 = uiData.FishData.Color
        
        -- Update stats
        if uiData.PlayerData then
            statsLabel.Text = string.format("Total Ikan: %d | Coins: %d", 
                uiData.PlayerData.TotalFish, uiData.PlayerData.TotalCoins)
        end
        
    elseif uiData.Status == "error" then
        statusLabel.Text = uiData.Result
        resultLabel.Text = ""
        resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- Initialize system ketika game start
function FishingSystem.Init()
    print("[FISHING SYSTEM] Fishing system initialized!")
    
    -- Auto-create UI untuk players yang join
    Players.PlayerAdded:Connect(function(player)
        wait(2) -- Tunggu player loading
        CreatePlayerUI(player)
        
        -- Initialize player data
        PlayerData[player.UserId] = {
            TotalFish = 0,
            TotalCoins = 0,
            Inventory = {},
            IsFishing = false
        }
        
        print("[FISHING] Player " .. player.Name .. " joined fishing system")
    end)
    
    -- Cleanup ketika player leave
    Players.PlayerRemoving:Connect(function(player)
        PlayerData[player.UserId] = nil
    end)
    
    -- Create UI untuk players yang sudah ada
    for _, player in ipairs(Players:GetPlayers()) do
        CreatePlayerUI(player)
        PlayerData[player.UserId] = {
            TotalFish = 0,
            TotalCoins = 0,
            Inventory = {},
            IsFishing = false
        }
    end
end

-- Start the system
FishingSystem.Init()

return FishingSystem
