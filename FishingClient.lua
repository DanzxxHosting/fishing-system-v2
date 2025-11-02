--[[ 
Fishing System V1 - All In One
By ChatGPT
------------------------------------
✅ Letakkan script ini di:
   StarterPlayer > StarterPlayerScripts (LocalScript)
✅ Tidak perlu setup manual lagi, semuanya otomatis dibuat.
------------------------------------
Fitur:
 - Sistem memancing penuh (cast, bite, reel)
 - Auto buat RemoteEvent & Script server
 - UI sederhana di sudut kiri bawah
 - Reward uang otomatis ke leaderstats
------------------------------------
]]

--=== [ AUTO SETUP SERVER COMPONENTS ] ===--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- RemoteEvent setup
local remote = ReplicatedStorage:FindFirstChild("FishingEvent") or Instance.new("RemoteEvent")
remote.Name = "FishingEvent"
remote.Parent = ReplicatedStorage

-- ModuleScript
local module = ServerScriptService:FindFirstChild("FishingModule")
if not module then
	module = Instance.new("ModuleScript")
	module.Name = "FishingModule"
	module.Source = [[
local FishingModule = {}

FishingModule.FishList = {
    {Name = "Common Fish", Rarity = "Common", Weight = 70000, Value = 5},
    {Name = "Uncommon Fish", Rarity = "Uncommon", Weight = 20000, Value = 25},
    {Name = "Rare Fish", Rarity = "Rare", Weight = 8000, Value = 150},
    {Name = "Epic Fish", Rarity = "Epic", Weight = 800, Value = 1200},
    {Name = "Legendary Fish", Rarity = "Legendary", Weight = 200, Value = 8000},
    {Name = "Mythic Fish", Rarity = "Mythic", Weight = 50, Value = 50000},
}

local function weightedRandom(list)
    local total = 0
    for _,v in ipairs(list) do total = total + v.Weight end
    local pick = math.random() * total
    local acc = 0
    for _,v in ipairs(list) do
        acc = acc + v.Weight
        if pick <= acc then
            return v
        end
    end
    return list[#list]
end

function FishingModule.PickFish(luck)
    luck = math.clamp(luck or 0, 0, 1)
    local adjusted = {}
    for _,fish in ipairs(FishingModule.FishList) do
        local copy = {Name = fish.Name, Rarity = fish.Rarity, Value = fish.Value, Weight = fish.Weight}
        if fish.Rarity == "Rare" then copy.Weight = copy.Weight * (1 + 2*luck) end
        if fish.Rarity == "Epic" then copy.Weight = copy.Weight * (1 + 4*luck) end
        if fish.Rarity == "Legendary" then copy.Weight = copy.Weight * (1 + 10*luck) end
        if fish.Rarity == "Mythic" then copy.Weight = copy.Weight * (1 + 20*luck) end
        if fish.Rarity == "Common" then copy.Weight = math.max(10, copy.Weight * (1 - luck*0.6)) end
        table.insert(adjusted, copy)
    end
    return weightedRandom(adjusted)
end

function FishingModule.CheckReelSuccess(reelPower, requiredPower)
    reelPower = math.clamp(reelPower, 0, 1)
    requiredPower = math.clamp(requiredPower, 0, 1)
    if reelPower >= requiredPower then return true end
    local diff = requiredPower - reelPower
    local chance = math.clamp(1 - diff * 2.5, 0, 0.35)
    return math.random() < chance
end

return FishingModule
]]
	module.Parent = ServerScriptService
end

-- Server Script
if not ServerScriptService:FindFirstChild("FishingServer") then
	local server = Instance.new("Script")
	server.Name = "FishingServer"
	server.Source = [[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FishingModule = require(script.Parent:WaitForChild("FishingModule"))
local Remote = ReplicatedStorage:WaitForChild("FishingEvent")

Players.PlayerAdded:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end
    if not leaderstats:FindFirstChild("Money") then
        local money = Instance.new("IntValue")
        money.Name = "Money"
        money.Value = 0
        money.Parent = leaderstats
    end
end)

local cooldown = {}
local COOLDOWN_TIME = 1.2
local activeCasts = {}

local function startBiteSequence(player, castId, luck)
    local biteDelay = math.random(1000, 4000)/1000
    task.wait(biteDelay)
    if not activeCasts[player] or not activeCasts[player][castId] then return end
    local required = math.clamp(0.3 + math.random()*0.6, 0, 1)
    activeCasts[player][castId].requiredPower = required
    Remote:FireClient(player, "Bite", {castId = castId, requiredPower = required, biteDelay = biteDelay})
    task.spawn(function()
        task.wait(6)
        if activeCasts[player] and activeCasts[player][castId] then
            activeCasts[player][castId] = nil
            Remote:FireClient(player, "Miss", {castId = castId})
        end
    end)
end

Remote.OnServerEvent:Connect(function(player, action, data)
    if action == "Cast" then
        local now = tick()
        if cooldown[player] and now - cooldown[player] < COOLDOWN_TIME then return end
        cooldown[player] = now
        activeCasts[player] = activeCasts[player] or {}
        local castId = tostring(player.UserId).."-"..tostring(now)
        activeCasts[player][castId] = {start = now}
        startBiteSequence(player, castId, data and data.luck or 0)
        Remote:FireClient(player, "CastAccepted", {castId = castId})
    elseif action == "Reel" then
        local castId = data and data.castId
        local power = data and data.power or 0
        if not castId or not activeCasts[player] or not activeCasts[player][castId] then
            Remote:FireClient(player, "ReelResult", {success = false, reason = "No active cast"})
            return
        end
        local info = activeCasts[player][castId]
        local required = info.requiredPower or 0.5
        local success = FishingModule.CheckReelSuccess(power, required)
        activeCasts[player][castId] = nil
        if success then
            local fish = FishingModule.PickFish(data.luck or 0)
            local moneyVal = fish.Value or 1
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats and leaderstats:FindFirstChild("Money") then
                leaderstats.Money.Value += moneyVal
            end
            Remote:FireClient(player, "ReelResult", {success = true, fish = fish, money = moneyVal})
        else
            Remote:FireClient(player, "ReelResult", {success = false, reason = "Fish escaped"})
        end
    end
end)
]]
	server.Parent = ServerScriptService
end

--=== [ CLIENT (UI + Gameplay) ] ===--
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- UI Setup
local PlayerGui = player:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui")
screen.Name = "FishingUI"
screen.ResetOnSpawn = false
screen.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,120)
frame.Position = UDim2.new(0,20,1,-160)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.25
frame.Parent = screen

local castBtn = Instance.new("TextButton")
castBtn.Size = UDim2.new(0,220,0,50)
castBtn.Position = UDim2.new(0,20,0,20)
castBtn.Text = "Cast"
castBtn.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-40,0,40)
status.Position = UDim2.new(0,20,0,80)
status.Text = "Ready"
status.TextScaled = true
status.BackgroundTransparency = 1
status.Parent = frame

local currentCastId = nil
local awaitingBite = false

castBtn.MouseButton1Click:Connect(function()
	if awaitingBite then
		status.Text = "Already casting..."
		return
	end
	remote:FireServer("Cast", {luck = 0})
	status.Text = "Casting..."
end)

remote.OnClientEvent:Connect(function(action, data)
	if action == "CastAccepted" then
		currentCastId = data.castId
		awaitingBite = true
		status.Text = "Waiting for bite..."
	elseif action == "Bite" then
		if data.castId ~= currentCastId then return end
		status.Text = "BITE! Reel now!"
		local prompt = Instance.new("TextButton")
		prompt.Size = UDim2.new(0,200,0,60)
		prompt.Position = UDim2.new(0,30,0,-80)
		prompt.Text = "Hold to Reel"
		prompt.Parent = frame

		local startTime, held = 0, false
		local function finish()
			if held then
				held = false
				prompt:Destroy()
				local dt = math.clamp(tick() - startTime, 0, 2)
				local power = dt / 2
				remote:FireServer("Reel", {castId = currentCastId, power = power, luck = 0})
				status.Text = "Reeling..."
			end
		end

		prompt.MouseButton1Down:Connect(function()
			startTime = tick()
			held = true
		end)
		prompt.MouseButton1Up:Connect(finish)
		task.delay(6, function() if prompt.Parent then prompt:Destroy() end end)
	elseif action == "Miss" then
		awaitingBite, currentCastId = false, nil
		status.Text = "Missed the bite"
	elseif action == "ReelResult" then
		awaitingBite, currentCastId = false, nil
		if data.success then
			status.Text = "Caught: "..(data.fish.Name or "Fish").." (+$"..tostring(data.money)..")"
		else
			status.Text = "Failed: "..(data.reason or "escaped")
		end
	end
end)
