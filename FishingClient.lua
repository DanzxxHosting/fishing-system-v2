-- FishingClient.lua (LocalScript) - put in StarterPlayerScripts
-- Adds UI toggles: SuperFast (8x/10x), Delay Mode (2x), Auto-Equip FishingRadar, Animation On/Off.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterPack = game:GetService("StarterPack")
local player = Players.LocalPlayer

local StartRemote = ReplicatedStorage:WaitForChild("FishingStart")
local ReelRemote = ReplicatedStorage:WaitForChild("FishingReel")
local NotifyRemote = ReplicatedStorage:WaitForChild("FishingNotify")

-- DEV settings exposed by UI
local DEV = {
    autoFish = false,
    autoPerfection = false,
    speedMultiplier = 1.0,
    instantCatch = false,
    superFast = 0, -- 0=off, 8 or 10 when on
    delayMode = 1.0, -- 1.0 normal, 2.0 for 2x delay
    autoEquipRadar = false,
    animationEnabled = true,
}

-- Build UI (similar to v1, with new buttons)
local screen = Instance.new("ScreenGui")
screen.Name = "FishingUI_v2"
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 360, 0, 200)
main.Position = UDim2.new(0, 10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BorderSizePixel = 0
main.Parent = screen

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.Position = UDim2.new(0,6,0,6)
title.BackgroundTransparency = 1
title.Text = "Fishing System v2 (Debug)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Parent = main

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -12, 0, 22)
status.Position = UDim2.new(0,6,0,36)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.TextScaled = false
status.Parent = main

local progressHolder = Instance.new("Frame")
progressHolder.Size = UDim2.new(1, -12, 0, 16)
progressHolder.Position = UDim2.new(0,6,0,62)
progressHolder.BackgroundColor3 = Color3.fromRGB(50,50,50)
progressHolder.Parent = main

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.Position = UDim2.new(0,0,0,0)
progressBar.BackgroundColor3 = Color3.fromRGB(200,60,60)
progressBar.Parent = progressHolder

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0, 130, 0, 36)
startBtn.Position = UDim2.new(0,6,0,88)
startBtn.Text = "Start Fishing"
startBtn.Parent = main

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 80, 0, 28)
autoBtn.Position = UDim2.new(0,146,0,88)
autoBtn.Text = "Auto: Off"
autoBtn.Parent = main

local perfBtn = Instance.new("TextButton")
perfBtn.Size = UDim2.new(0, 80, 0, 28)
perfBtn.Position = UDim2.new(0,146,0,118)
perfBtn.Text = "Perfect: Off"
perfBtn.Parent = main

local superBtn = Instance.new("TextButton")
superBtn.Size = UDim2.new(0, 80, 0, 28)
superBtn.Position = UDim2.new(0,236,0,88)
superBtn.Text = "Super: Off"
superBtn.Parent = main

local delayBtn = Instance.new("TextButton")
delayBtn.Size = UDim2.new(0, 80, 0, 28)
delayBtn.Position = UDim2.new(0,236,0,118)
delayBtn.Text = "Delay: Off"
delayBtn.Parent = main

local equipBtn = Instance.new("TextButton")
equipBtn.Size = UDim2.new(0, 110, 0, 28)
equipBtn.Position = UDim2.new(0,6,0,132)
equipBtn.Text = "Auto-Equip Radar: Off"
equipBtn.Parent = main

local animBtn = Instance.new("TextButton")
animBtn.Size = UDim2.new(0, 110, 0, 28)
animBtn.Position = UDim2.new(0,126,0,132)
animBtn.Text = "Animation: On"
animBtn.Parent = main

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 60, 0, 20)
speedLabel.Position = UDim2.new(0,246,0,132)
speedLabel.Text = "Speed: 1.0x"
speedLabel.TextScaled = true
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = main

local speedInc = Instance.new("TextButton")
speedInc.Size = UDim2.new(0, 40, 0, 20)
speedInc.Position = UDim2.new(0,306,0,132)
speedInc.Text = "+0.5"
speedInc.Parent = main

local speedDec = Instance.new("TextButton")
speedDec.Size = UDim2.new(0, 40, 0, 20)
speedDec.Position = UDim2.new(0,306,0,156)
speedDec.Text = "-0.5"
speedDec.Parent = main

-- Internal state
local isFishing = false
local startTick = 0
local biteTick = nil

local function setStatus(text)
    status.Text = text or ""
end

local function setProgress(p)
    p = math.clamp(p, 0, 1)
    progressBar.Size = UDim2.new(p, 0, 1, 0)
end

-- Auto-equip helper: looks for Tool named "FishingRadar" in Backpack or StarterPack
local function tryAutoEquipRadar()
    if not DEV.autoEquipRadar then return end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("FishingRadar")
        if tool and tool:IsA("Tool") then
            player.CharacterAdded:Wait() -- ensure character loaded
            -- equip
            local character = player.Character
            if character and character.Parent then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:EquipTool(tool)
                    setStatus("Radar auto-equipped.")
                end
            end
            return
        end
    end
    -- also check StarterPack (for play-test)
    local sp = StarterPack:FindFirstChild("FishingRadar")
    if sp and sp:IsA("Tool") then
        -- cloning into Backpack so it can be equipped
        local clone = sp:Clone()
        clone.Parent = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
        setStatus("Radar added to Backpack and equipped.")
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(clone)
        end
    end
end

-- UI callbacks
startBtn.MouseButton1Click:Connect(function()
    if isFishing then
        setStatus("Already fishing...")
        return
    end
    isFishing = true
    startTick = tick()
    setStatus("Casting...")
    setProgress(0)
    local req = { speed = DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1), delay = DEV.delayMode }
    StartRemote:FireServer(startTick, req)
    -- try auto-equip if enabled
    tryAutoEquipRadar()
end)

autoBtn.MouseButton1Click:Connect(function()
    DEV.autoFish = not DEV.autoFish
    autoBtn.Text = "Auto: " .. (DEV.autoFish and "On" or "Off")
end)

perfBtn.MouseButton1Click:Connect(function()
    DEV.autoPerfection = not DEV.autoPerfection
    perfBtn.Text = "Perfect: " .. (DEV.autoPerfection and "On" or "Off")
end)

superBtn.MouseButton1Click:Connect(function()
    if DEV.superFast == 0 then
        DEV.superFast = 8
        superBtn.Text = "Super: 8x"
    elseif DEV.superFast == 8 then
        DEV.superFast = 10
        superBtn.Text = "Super: 10x"
    else
        DEV.superFast = 0
        superBtn.Text = "Super: Off"
    end
    speedLabel.Text = "Speed: " .. tostring(DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1)) .. "x"
end)

delayBtn.MouseButton1Click:Connect(function()
    if DEV.delayMode == 1.0 then
        DEV.delayMode = 2.0
        delayBtn.Text = "Delay: 2x"
    else
        DEV.delayMode = 1.0
        delayBtn.Text = "Delay: Off"
    end
end)

equipBtn.MouseButton1Click:Connect(function()
    DEV.autoEquipRadar = not DEV.autoEquipRadar
    equipBtn.Text = "Auto-Equip Radar: " .. (DEV.autoEquipRadar and "On" or "Off")
    if DEV.autoEquipRadar then
        tryAutoEquipRadar()
    end
end)

animBtn.MouseButton1Click:Connect(function()
    DEV.animationEnabled = not DEV.animationEnabled
    animBtn.Text = "Animation: " .. (DEV.animationEnabled and "On" or "Off")
end)

speedInc.MouseButton1Click:Connect(function()
    DEV.speedMultiplier = math.floor((DEV.speedMultiplier + 0.5) * 10) / 10
    speedLabel.Text = "Speed: " .. tostring(DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1)) .. "x"
end)
speedDec.MouseButton1Click:Connect(function()
    DEV.speedMultiplier = math.max(0.1, math.floor((DEV.speedMultiplier - 0.5) * 10) / 10)
    speedLabel.Text = "Speed: " .. tostring(DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1)) .. "x"
end)

-- Remote notifications (server -> client)
NotifyRemote.OnClientEvent:Connect(function(payload)
    if not payload or not payload.event then return end
    if payload.event == "Started" then
        setStatus("Waiting for bite...")
        local target = (payload.when or tick())
        spawn(function()
            while isFishing and tick() < target do
                local total = math.max(0.01, (target - startTick))
                local elapsed = tick() - startTick
                setProgress(elapsed / total)
                wait(0.03)
            end
        end)
    elseif payload.event == "Bite" then
        biteTick = payload.serverTime or tick()
        if DEV.animationEnabled then
            setStatus("Fish is biting! Reel now (E) or press Reel button.")
        else
            setStatus("Fish is biting! (animation off)")
        end
        setProgress(1)
        if DEV.instantCatch then
            ReelRemote:FireServer(0)
        elseif DEV.autoPerfection then
            local perfect = 3.0 / math.max(DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1), 0.01)
            delay(perfect, function()
                if isFishing then
                    local elapsed = tick() - startTick
                    ReelRemote:FireServer(elapsed)
                end
            end)
        elseif DEV.autoFish then
            local elapsed = 3.0 / math.max(DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1), 0.01)
            ReelRemote:FireServer(elapsed)
        end
    elseif payload.event == "Result" then
        local res = payload.result or {}
        setStatus("Result: " .. (res.quality or "Unknown") .. " +" .. tostring(res.reward or 0))
        isFishing = false
        biteTick = nil
        wait(2)
        setStatus("Ready")
        setProgress(0)
    end
end)

-- Keyboard input for reel
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E and isFishing then
        local elapsed = tick() - startTick
        ReelRemote:FireServer(elapsed)
    end
end)

-- Auto loop if autoFish toggled
spawn(function()
    while true do
        if DEV.autoFish and not isFishing then
            startBtn:Activate()
        end
        wait(0.5)
    end
end)

print("FishingClient v2 loaded (UI created).")
