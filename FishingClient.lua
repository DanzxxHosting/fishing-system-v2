--// Fish It UI + Auto Fishing Test Feature
if game.CoreGui:FindFirstChild("FishItUI") then
	game.CoreGui.FishItUI:Destroy()
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 350)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Glow = Instance.new("UIStroke")
Glow.Thickness = 2
Glow.Color = Color3.fromRGB(255, 0, 60)
Glow.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "Fish It | Nexus Hub"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.fromRGB(255, 0, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

local menuItems = {"Main", "Spawn Boat", "Buy Rod", "Buy Weather", "Buy Bait", "Teleport", "Settings"}
local Buttons = {}

for i, text in ipairs(menuItems) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.Position = UDim2.new(0, 5, 0, (i * 40))
	btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	btn.Text = "  " .. text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = Sidebar

	local glow = Instance.new("UIStroke")
	glow.Color = Color3.fromRGB(255, 0, 60)
	glow.Thickness = 0
	glow.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(glow, TweenInfo.new(0.2), {Thickness = 2}):Play()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 0, 0)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(glow, TweenInfo.new(0.2), {Thickness = 0}):Play()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
	end)

	Buttons[text] = btn
end

local ContentFrame = Instance.new("Frame")
ContentFrame.Position = UDim2.new(0, 155, 0, 0)
ContentFrame.Size = UDim2.new(1, -155, 1, 0)
ContentFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 1, 0)
Label.Text = "Select a feature from the left menu."
Label.Font = Enum.Font.Gotham
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 18
Label.BackgroundTransparency = 1
Label.Parent = ContentFrame

-- 🐟 Fitur Auto Fishing
local autoFishingActive = false
local stopFishing = false

local function StartAutoFishing()
	if autoFishingActive then return end
	autoFishingActive = true
	stopFishing = false
	print("[Auto Fishing] Started... 🎣")

	while not stopFishing do
		print("[Auto Fishing] Casting line... 🎯")
		task.wait(3) -- Delay antar pancing (bisa diatur)
		print("[Auto Fishing] Fish caught! 🐠")
	end
	print("[Auto Fishing] Stopped.")
end

local function StopAutoFishing()
	stopFishing = true
	autoFishingActive = false
end

-- Tambahkan konten untuk menu Main
Buttons["Main"].MouseButton1Click:Connect(function()
	for _, c in ipairs(ContentFrame:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end

	local title = Instance.new("TextLabel")
	title.Text = "Main Panel"
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.fromRGB(255, 0, 60)
	title.TextSize = 22
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 10, 0, 10)
	title.Parent = ContentFrame

	local autoBtn = Instance.new("TextButton")
	autoBtn.Size = UDim2.new(0, 180, 0, 40)
	autoBtn.Position = UDim2.new(0, 20, 0, 70)
	autoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	autoBtn.Text = "▶️ Start Auto Fishing"
	autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoBtn.Font = Enum.Font.Gotham
	autoBtn.TextSize = 16
	autoBtn.Parent = ContentFrame

	autoBtn.MouseButton1Click:Connect(function()
		if autoFishingActive then
			StopAutoFishing()
			autoBtn.Text = "▶️ Start Auto Fishing"
			autoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		else
			StartAutoFishing()
			autoBtn.Text = "⏹ Stop Auto Fishing"
			autoBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 60)
		end
	end)
end)

-- Toggle buka/tutup UI (G)
local isOpen = true
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.G then
		isOpen = not isOpen
		local goal = {Size = isOpen and UDim2.new(0, 580, 0, 350) or UDim2.new(0, 0, 0, 0)}
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), goal):Play()
	end
end)
