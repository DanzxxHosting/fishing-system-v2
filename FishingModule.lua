-- FishingModule.lua (ModuleScript) - put in ReplicatedStorage as 'FishingModule'
local FishingModule = {}

-- Config
FishingModule.Config = {
    BaseCatchTime = 3.0,         -- seconds for a normal bite
    PerfectionWindow = 0.6,      -- seconds around center for "Perfect"
    RewardMin = 5,
    RewardMax = 20,
    MinInterval = 1.5,           -- minimum seconds between actions (server-side rate limit)
    MaxClientSpeed = 10.0,       -- server will clamp client-requested speed up to this (for testing)
    MaxDelayMultiplier = 4.0,    -- server will clamp delay multiplier
}

-- Calculate a catch outcome based on elapsed time since bite (server-side)
function FishingModule.CalculateCatchOutcome(elapsed, config)
    local cfg = config or FishingModule.Config
    elapsed = tonumber(elapsed) or 0
    local perfectCenter = cfg.BaseCatchTime
    local diff = math.abs(elapsed - perfectCenter)
    local isPerfect = diff <= cfg.PerfectionWindow
    local quality = isPerfect and "Perfect" or "Normal"
    local reward = math.floor(math.random(cfg.RewardMin, cfg.RewardMax) * (isPerfect and 1.8 or 1.0))
    return {
        isCatch = true,
        isPerfect = isPerfect,
        quality = quality,
        reward = reward,
    }
end

return FishingModule
