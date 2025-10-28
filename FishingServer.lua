-- FishingServer.lua (Script) - put in ServerScriptService as 'FishingServer'
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Ensure RemoteEvents exist
local function getOrCreate(name, className)
    local obj = ReplicatedStorage:FindFirstChild(name)
    if not obj then
        obj = Instance.new(className or "RemoteEvent")
        obj.Name = name
        obj.Parent = ReplicatedStorage
    end
    return obj
end

local StartRemote = getOrCreate("FishingStart", "RemoteEvent") -- client -> server (start request)
local ReelRemote = getOrCreate("FishingReel", "RemoteEvent")   -- client -> server (reel attempt)
local NotifyRemote = getOrCreate("FishingNotify", "RemoteEvent") -- server -> client (bite/result)

local FishingModule = require(ReplicatedStorage:WaitForChild("FishingModule"))
local cfg = FishingModule.Config

-- per-player state
local playerState = {}

-- handle start: server schedules a bite after server-determined delay
StartRemote.OnServerEvent:Connect(function(player, clientStartTick, clientRequested)
    if not player or not player.Parent then return end
    local id = player.UserId
    playerState[id] = playerState[id] or {}
    local state = playerState[id]
    state.lastStart = state.lastStart or 0
    local now = tick()
    if now - state.lastStart < cfg.MinInterval then
        -- rate-limited; ignore
        return
    end
    state.lastStart = now

    -- Respect client's requested speed and delay multipliers but clamp them for safety
    local requestedSpeed = 1.0
    local delayMultiplier = 1.0
    if typeof(clientRequested) == "table" then
        requestedSpeed = tonumber(clientRequested.speed) or 1.0
        delayMultiplier = tonumber(clientRequested.delay) or 1.0
    end
    requestedSpeed = math.clamp(requestedSpeed, 0.1, cfg.MaxClientSpeed)
    delayMultiplier = math.clamp(delayMultiplier, 0.25, cfg.MaxDelayMultiplier)

    -- Determine bite time server-side (use BaseCatchTime, adjusted by client's speed and delay for testing)
    local base = cfg.BaseCatchTime
    local biteTime = (base / math.max(requestedSpeed, 0.01)) * delayMultiplier + (math.random() * 0.8 - 0.4)
    if biteTime < 0.1 then biteTime = 0.1 end

    state.waiting = true
    state.when = now + biteTime
    state.serverRequested = { speed = requestedSpeed, delay = delayMultiplier }

    NotifyRemote:FireClient(player, { event = "Started", when = state.when, serverNow = now, serverRequested = state.serverRequested })

    spawn(function()
        local finishAt = state.when
        while tick() < finishAt do
            if not player or not player.Parent then return end
            wait(0.05)
        end
        if state.waiting then
            state.biteTime = tick()
            NotifyRemote:FireClient(player, { event = "Bite", serverTime = state.biteTime })
        end
    end)
end)

-- handle reel attempt from client
ReelRemote.OnServerEvent:Connect(function(player, clientElapsed)
    if not player or not player.Parent then return end
    local id = player.UserId
    local state = playerState[id]
    if not state or not state.waiting or not state.biteTime then
        -- invalid reel (no bite pending)
        return
    end
    clientElapsed = tonumber(clientElapsed) or 0
    if clientElapsed < 0 or clientElapsed > 600 then return end

    -- compute serverElapsed and combine
    local serverElapsed = tick() - state.when
    local usedElapsed = (serverElapsed + clientElapsed) / 2
    local result = FishingModule.CalculateCatchOutcome(usedElapsed)

    -- Give reward (leaderstats Coins)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local money = leaderstats:FindFirstChild("Coins")
        if not money then
            money = Instance.new("IntValue")
            money.Name = "Coins"
            money.Value = 0
            money.Parent = leaderstats
        end
        money.Value = money.Value + result.reward
    end

    -- clear state and notify client
    state.waiting = false
    state.biteTime = nil
    state.when = nil
    state.serverRequested = nil

    NotifyRemote:FireClient(player, { event = "Result", result = result })
end)

print("FishingServer (v2) loaded.")
