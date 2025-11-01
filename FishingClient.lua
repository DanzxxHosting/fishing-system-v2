-- UI-Only: Neon Panel (sidebar + content) — paste ke StarterPlayer -> StarterPlayerScripts (LocalScript)
-- Tema: hitam matte + merah neon. Toggle dengan tombol G. Safe (UI only).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WIDTH = 920
local HEIGHT = 520
local SIDEBAR_W = 220
local ACCENT = Color3.fromRGB(255, 62, 62) -- neon merah
local BG = Color3.fromRGB(12,12,12) -- hitam matte
local SECOND = Color3.fromRGB(24,24,26)

-- cleanup old if exist
if playerGui:FindFirstChild("NeonDashboardUI") then
    playerGui.NeonDashboardUI:Destroy()
end

-- ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "NeonDashboardUI"
screen.ResetOnSpawn = false
screen.Parent = playerGui
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container (centered)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
container.BackgroundTransparency = 1
container.Parent = screen

-- Outer glow (image behind)
local glow = Instance.new("ImageLabel", screen)
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5,0.5)
glow.Size = UDim2.new(0, WIDTH+80, 0, HEIGHT+80)
glow.Position = container.Position
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5050741616" -- radial
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.92
glow.ZIndex = 1

-- Card (panel)
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
card.Position = UDim2.new(0,0,0,0)
card.BackgroundColor3 = BG
card.BorderSizePixel = 0
card.Parent = container
card.ZIndex = 2

local cardCorner = Instance.new("UICorner", card)
cardCorner.CornerRadius = UDim.new(0, 12)

-- inner container
local inner = Instance.new("Frame", card)
inner.Name = "Inner"
inner.Size = UDim2.new(1, -24, 1, -24)
inner.Position = UDim2.new(0, 12, 0, 12)
inner.BackgroundTransparency = 1

-- Title bar
local titleBar = Instance.new("Frame", inner)
titleBar.Size = UDim2.new(1,0,0,48)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.6,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ KAITUN FISH IT — UI Preview"
title.TextColor3 = Color3.fromRGB(255, 220, 220)
title.TextXAlignment = Enum.TextXAlignment.Left

local memLabel = Instance.new("TextLabel", titleBar)
memLabel.Size = UDim2.new(0.4,-16,1,0)
memLabel.Position = UDim2.new(0.6,8,0,0)
memLabel.BackgroundTransparency = 1
memLabel.Font = Enum.Font.Gotham
memLabel.TextSize = 13
memLabel.Text = "Client Memory Usage: 0 MB"
memLabel.TextColor3 = Color3.fromRGB(200,200,200)
memLabel.TextXAlignment = Enum.TextXAlignment.Right

-- left sidebar
local sidebar = Instance.new("Frame", inner)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -64)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = SECOND
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3

local sbCorner = Instance.new("UICorner", sidebar)
sbCorner.CornerRadius = UDim.new(0, 8)

-- sidebar header icon
local sbHeader = Instance.new("Frame", sidebar)
sbHeader.Size = UDim2.new(1,0,0,84)
sbHeader.BackgroundTransparency = 1

local logo = Instance.new("ImageLabel", sbHeader)
logo.Size = UDim2.new(0,64,0,64)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://3926305904" -- simple icon (roblox)
logo.ImageColor3 = ACCENT

local sTitle = Instance.new("TextLabel", sbHeader)
sTitle.Size = UDim2.new(1,-96,0,32)
sTitle.Position = UDim2.new(0, 88, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 14
sTitle.Text = "Kaitun"
sTitle.TextColor3 = Color3.fromRGB(240,240,240)
sTitle.TextXAlignment = Enum.TextXAlignment.Left

-- menu list area
local menuFrame = Instance.new("Frame", sidebar)
menuFrame.Size = UDim2.new(1,-12,1, -108)
menuFrame.Position = UDim2.new(0, 6, 0, 92)
menuFrame.BackgroundTransparency = 1

local menuLayout = Instance.new("UIListLayout", menuFrame)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding = UDim.new(0,8)

-- menu helper
local function makeMenuItem(name, iconText)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20,20,20)
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = menuFrame

    local corner = Instance.new("UICorner", row)
    corner.CornerRadius = UDim.new(0,8)

    local left = Instance.new("Frame", row)
    left.Size = UDim2.new(0,40,1,0)
    left.Position = UDim2.new(0,8,0,0)
    left.BackgroundTransparency = 1

    local icon = Instance.new("TextLabel", left)
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Text = iconText
    icon.TextColor3 = ACCENT
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Position = UDim2.new(0,56,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,10,10)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,20)}):Play()
    end)

    return row, label
end

-- menu items (order like photo)
local items = {
    {"Main", "★"},
    {"Spawn Boat", "⛵"},
    {"Buy Rod", "🪝"},
    {"Buy Weather", "☁"},
    {"Buy Bait", "🍤"},
    {"Teleport", "📍"},
    {"Settings", "⚙"},
}
local menuButtons = {}
for i, v in ipairs(items) do
    local btn, lbl = makeMenuItem(v[1], v[2])
    btn.LayoutOrder = i
    menuButtons[v[1]] = btn
end

-- content panel (right)
local content = Instance.new("Frame", inner)
content.Name = "Content"
content.Size = UDim2.new(1, -SIDEBAR_W - 36, 1, -64)
content.Position = UDim2.new(0, SIDEBAR_W + 24, 0, 56)
content.BackgroundColor3 = Color3.fromRGB(18,18,20)
content.BorderSizePixel = 0

local contentCorner = Instance.new("UICorner", content)
contentCorner.CornerRadius = UDim.new(0, 8)

-- content title area
local cTitle = Instance.new("TextLabel", content)
cTitle.Size = UDim2.new(1, -24, 0, 44)
cTitle.Position = UDim2.new(0,12,0,12)
cTitle.BackgroundTransparency = 1
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 16
cTitle.Text = "Teleport"
cTitle.TextColor3 = Color3.fromRGB(245,245,245)
cTitle.TextXAlignment = Enum.TextXAlignment.Left

-- inside content: example teleport UI (dropdown + buttons)
local panel = Instance.new("Frame", content)
panel.Size = UDim2.new(1, -24, 0, 220)
panel.Position = UDim2.new(0, 12, 0, 64)
panel.BackgroundColor3 = Color3.fromRGB(14,14,16)
panel.BorderSizePixel = 0

local pCorner = Instance.new("UICorner", panel)
pCorner.CornerRadius = UDim.new(0,8)

local pTitle = Instance.new("TextLabel", panel)
pTitle.Size = UDim2.new(1, -24, 0, 28)
pTitle.Position = UDim2.new(0,12,0,8)
pTitle.BackgroundTransparency = 1
pTitle.Font = Enum.Font.GothamBold
pTitle.TextSize = 14
pTitle.Text = "Teleport"
pTitle.TextColor3 = Color3.fromRGB(235,235,235)
pTitle.TextXAlignment = Enum.TextXAlignment.Left

-- dropdown label
local ddLabel = Instance.new("TextLabel", panel)
ddLabel.Size = UDim2.new(0.4,0,0,24)
ddLabel.Position = UDim2.new(0,12,0,44)
ddLabel.BackgroundTransparency = 1
ddLabel.Font = Enum.Font.Gotham
ddLabel.TextSize = 13
ddLabel.Text = "Island"
ddLabel.TextColor3 = Color3.fromRGB(200,200,200)
ddLabel.TextXAlignment = Enum.TextXAlignment.Left

-- dropdown button
local ddBtn = Instance.new("TextButton", panel)
ddBtn.Size = UDim2.new(0, 200, 0, 32)
ddBtn.Position = UDim2.new(0, 12, 0, 72)
ddBtn.BackgroundColor3 = Color3.fromRGB(20,20,22)
ddBtn.Font = Enum.Font.GothamBold
ddBtn.TextSize = 14
ddBtn.Text = "Select island"
ddBtn.TextColor3 = Color3.fromRGB(230,230,230)
ddBtn.AutoButtonColor = false
local ddCorner = Instance.new("UICorner", ddBtn); ddCorner.CornerRadius = UDim.new(0,6)

-- dropdown list (frame)
local ddList = Instance.new("Frame", panel)
ddList.Size = UDim2.new(0, 200, 0, 0)
ddList.Position = UDim2.new(0, 12, 0, 108)
ddList.BackgroundColor3 = Color3.fromRGB(18,18,20)
ddList.BorderSizePixel = 0
ddList.ClipsDescendants = true
local ddListCorner = Instance.new("UICorner", ddList); ddListCorner.CornerRadius = UDim.new(0,6)

local ddLayout = Instance.new("UIListLayout", ddList)
ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
ddLayout.Padding = UDim.new(0,4)

-- sample islands
local islandNames = {"None","Main Island","Tropical Island","Frozen Island","Volcano Island","Pirate Cove"}
for i, name in ipairs(islandNames) do
    local it = Instance.new("TextButton", ddList)
    it.Size = UDim2.new(1, -8, 0, 28)
    it.Position = UDim2.new(0,4,0, (i-1)*32)
    it.BackgroundColor3 = Color3.fromRGB(24,24,26)
    it.Text = "  "..name
    it.Font = Enum.Font.Gotham
    it.TextSize = 13
    it.TextColor3 = Color3.fromRGB(230,230,230)
    it.AutoButtonColor = false
    it.LayoutOrder = i

    local itCorner = Instance.new("UICorner", it); itCorner.CornerRadius = UDim.new(0,6)
    it.MouseEnter:Connect(function() TweenService:Create(it, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,8,8)}):Play() end)
    it.MouseLeave:Connect(function() TweenService:Create(it, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(24,24,26)}):Play() end)
    it.MouseButton1Click:Connect(function()
        ddBtn.Text = name
        -- close list
        TweenService:Create(ddList, TweenInfo.new(0.18), {Size = UDim2.new(0,200,0,0)}):Play()
        print("[UI] Selected island:", name)
    end)
end

-- action buttons
local action1 = Instance.new("TextButton", panel)
action1.Size = UDim2.new(0, 140, 0, 34)
action1.Position = UDim2.new(0, 12, 0, 150)
action1.BackgroundColor3 = ACCENT
action1.Font = Enum.Font.GothamBold
action1.TextSize = 14
action1.Text = "Teleport"
action1.TextColor3 = Color3.fromRGB(30,30,30)
local actionCorner = Instance.new("UICorner", action1); actionCorner.CornerRadius = UDim.new(0,6)

local action2 = Instance.new("TextButton", panel)
action2.Size = UDim2.new(0, 120, 0, 34)
action2.Position = UDim2.new(0, 164, 0, 150)
action2.BackgroundColor3 = Color3.fromRGB(40,40,40)
action2.Font = Enum.Font.GothamBold
action2.TextSize = 14
action2.Text = "Sell Fish"
action2.TextColor3 = Color3.fromRGB(230,230,230)
local action2Corner = Instance.new("UICorner", action2); action2Corner.CornerRadius = UDim.new(0,6)

-- interactions
local ddOpen = false
ddBtn.MouseButton1Click:Connect(function()
    ddOpen = not ddOpen
    if ddOpen then
        TweenService:Create(ddList, TweenInfo.new(0.18), {Size = UDim2.new(0,200,0, #islandNames*34)}):Play()
    else
        TweenService:Create(ddList, TweenInfo.new(0.14), {Size = UDim2.new(0,200,0,0)}):Play()
    end
end)

action1.MouseButton1Click:Connect(function()
    print("[UI] Teleport button pressed. Selected:", ddBtn.Text)
    -- placeholder: show feedback label
    local f = Instance.new("TextLabel", panel)
    f.Size = UDim2.new(0.5,0,0,28)
    f.Position = UDim2.new(0,12,0,190)
    f.BackgroundTransparency = 1
    f.Font = Enum.Font.GothamBold
    f.TextSize = 13
    f.Text = "Attempting teleport to: "..ddBtn.Text
    f.TextColor3 = Color3.fromRGB(200,255,200)
    delay(1.2, function() if f and f.Parent then f:Destroy() end end)
end)

action2.MouseButton1Click:Connect(function()
    print("[UI] Sell Fish clicked")
    local f = Instance.new("TextLabel", panel)
    f.Size = UDim2.new(0.5,0,0,28)
    f.Position = UDim2.new(0,12,0,190)
    f.BackgroundTransparency = 1
    f.Font = Enum.Font.GothamBold
    f.TextSize = 13
    f.Text = "Sell action (ui demo)"
    f.TextColor3 = Color3.fromRGB(255,220,120)
    delay(1.2, function() if f and f.Parent then f:Destroy() end end)
end)

-- menu navigation: highlight active and update content title (demo)
local activeMenu = "Teleport"
for name, btn in pairs(menuButtons) do
    btn.MouseButton1Click:Connect(function()
        -- highlight selected
        for n, b in pairs(menuButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20,20,20)
        end
        btn.BackgroundColor3 = Color3.fromRGB(32,8,8)
        -- set content title
        cTitle.Text = name
        print("[UI] Menu selected:", name)
        -- For demo: if selected not Teleport, show placeholder panel text
        if name ~= "Teleport" then
            pTitle.Text = name
            ddBtn.Text = "Select option"
        else
            pTitle.Text = "Teleport"
        end
    end)
end

-- close/open toggle with G (with pop animation)
local uiOpen = false
local function toggleUI(show)
    uiOpen = show
    if show then
        card.Visible = true
        glow.Visible = true
        container.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        container.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
        container.AnchorPoint = Vector2.new(0.5,0.5)
        container.ZIndex = 2
        card:TweenSize(UDim2.new(0, WIDTH,0,HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.28, true)
        TweenService:Create(glow, TweenInfo.new(0.28), {ImageTransparency = 0.8}):Play()
    else
        TweenService:Create(glow, TweenInfo.new(0.18), {ImageTransparency = 0.96}):Play()
        card:TweenSize(UDim2.new(0, WIDTH*0.9,0,HEIGHT*0.9), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.16, true)
        delay(0.16, function()
            card.Visible = true -- keep visible but scaled down (demo)
            glow.Visible = false
        end)
    end
end

-- initial hide
toggleUI(false)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        toggleUI(not uiOpen)
    end
end)

-- small update loop for mem label (demo)
spawn(function()
    while true do
        local mem = math.floor(collectgarbage("count"))
        memLabel.Text = "Client Memory Usage: "..mem.." KB"
        wait(1.2)
    end
end)

print("[NeonDashboardUI] Loaded (UI-only). Press G to toggle.")
