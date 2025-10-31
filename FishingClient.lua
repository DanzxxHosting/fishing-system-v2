-- Bikinkan Ultra Modern UI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Ultra Modern UI Library
local BikinkanUI = {}
BikinkanUI.Themes = {
    CyberPunk = {
        Main = Color3.fromRGB(10, 15, 30),
        Secondary = Color3.fromRGB(20, 25, 45),
        Accent = Color3.fromRGB(0, 255, 255),
        Neon = Color3.fromRGB(255, 0, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        Glow = Color3.fromRGB(0, 150, 255)
    },
    Matrix = {
        Main = Color3.fromRGB(0, 20, 0),
        Secondary = Color3.fromRGB(0, 30, 0),
        Accent = Color3.fromRGB(0, 255, 0),
        Neon = Color3.fromRGB(0, 255, 100),
        Text = Color3.fromRGB(0, 255, 0),
        TextSecondary = Color3.fromRGB(0, 200, 0),
        Glow = Color3.fromRGB(0, 255, 50)
    }
}

local currentTheme = BikinkanUI.Themes.CyberPunk

function BikinkanUI:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    local MainContainer = Instance.new("Frame")
    local MainFrame = Instance.new("Frame")
    local GlowEffect = Instance.new("ImageLabel")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Subtitle = Instance.new("TextLabel")
    local CloseButton = Instance.new("ImageButton")
    local TabContent = Instance.new("ScrollingFrame")
    local ContentList = Instance.new("UIListLayout")
    
    -- ScreenGui
    ScreenGui.Name = "BikinkanUltraUI"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Container
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = ScreenGui
    MainContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainContainer.BackgroundTransparency = 0.8
    MainContainer.BorderSizePixel = 0
    MainContainer.Size = UDim2.new(1, 0, 1, 0)
    MainContainer.Visible = true
    
    -- Glow Effect
    GlowEffect.Name = "GlowEffect"
    GlowEffect.Parent = MainContainer
    GlowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
    GlowEffect.BackgroundTransparency = 1
    GlowEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
    GlowEffect.Size = UDim2.new(1, 100, 1, 100)
    GlowEffect.Image = "rbxassetid://8992230677"
    GlowEffect.ImageColor3 = currentTheme.Glow
    GlowEffect.ImageTransparency = 0.8
    GlowEffect.ScaleType = Enum.ScaleType.Slice
    GlowEffect.SliceCenter = Rect.new(100, 100, 100, 100)
    
    -- Main Frame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainContainer
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = currentTheme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Top Bar dengan gradient effect
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = currentTheme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 120)
    
    -- Title dengan neon effect
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.08, 0, 0.2, 0)
    Title.Size = UDim2.new(0.7, 0, 0.3, 0)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "⚡ " .. name
    Title.TextColor3 = currentTheme.Text
    Title.TextSize = 28
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextStrokeColor3 = currentTheme.Neon
    Title.TextStrokeTransparency = 0.7
    
    -- Subtitle
    Subtitle.Name = "Subtitle"
    Subtitle.Parent = TopBar
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.08, 0, 0.55, 0)
    Subtitle.Size = UDim2.new(0.7, 0, 0.25, 0)
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.Text = "ULTRA MODERN INTERFACE"
    Subtitle.TextColor3 = currentTheme.Accent
    Subtitle.TextSize = 14
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button futuristik
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundColor3 = currentTheme.Neon
    CloseButton.BackgroundTransparency = 0.8
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.9, 0, 0.3, 0)
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(924, 724)
    CloseButton.ImageRectSize = Vector2.new(36, 36)
    CloseButton.ImageColor3 = currentTheme.Text
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.3,
            Rotation = 180,
            Size = UDim2.new(0, 40, 0, 40)
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.8,
            Rotation = 0,
            Size = UDim2.new(0, 35, 0, 35)
        }):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(GlowEffect, TweenInfo.new(0.5), {
            ImageTransparency = 1
        }):Play()
        wait(0.5)
        ScreenGui:Destroy()
    end)
    
    -- Tab Content Area
    TabContent.Name = "TabContent"
    TabContent.Parent = MainFrame
    TabContent.Active = true
    TabContent.BackgroundColor3 = currentTheme.Main
    TabContent.BorderSizePixel = 0
    TabContent.Position = UDim2.new(0, 0, 0.2, 0)
    TabContent.Size = UDim2.new(1, 0, 0.8, 0)
    TabContent.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = currentTheme.Neon
    TabContent.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    
    ContentList.Parent = TabContent
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 25)
    
    local tabs = {}
    
    function tabs:CreateSection(title)
        local Section = Instance.new("Frame")
        local SectionTitle = Instance.new("TextLabel")
        local SectionGlow = Instance.new("Frame")
        
        Section.Name = "Section"
        Section.Parent = TabContent
        Section.BackgroundColor3 = currentTheme.Secondary
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(0.9, 0, 0, 80)
        
        SectionGlow.Name = "SectionGlow"
        SectionGlow.Parent = Section
        SectionGlow.BackgroundColor3 = currentTheme.Neon
        SectionGlow.BorderSizePixel = 0
        SectionGlow.Position = UDim2.new(0, 0, 0.9, 0)
        SectionGlow.Size = UDim2.new(1, 0, 0, 3)
        SectionGlow.BackgroundTransparency = 0.5
        
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0.05, 0, 0.2, 0)
        SectionTitle.Size = UDim2.new(0.9, 0, 0.6, 0)
        SectionTitle.Font = Enum.Font.GothamBlack
        SectionTitle.Text = "🔷 " .. title
        SectionTitle.TextColor3 = currentTheme.Text
        SectionTitle.TextSize = 20
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.TextStrokeColor3 = currentTheme.Accent
        SectionTitle.TextStrokeTransparency = 0.8
        
        return Section
    end
    
    function tabs:CreateButton(name, description, callback)
        local Button = Instance.new("TextButton")
        local ButtonLabel = Instance.new("TextLabel")
        local ButtonDescription = Instance.new("TextLabel")
        local ButtonGlow = Instance.new("Frame")
        local ButtonIcon = Instance.new("TextLabel")
        
        Button.Parent = TabContent
        Button.BackgroundColor3 = currentTheme.Secondary
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 90)
        Button.AutoButtonColor = false
        
        ButtonGlow.Name = "ButtonGlow"
        ButtonGlow.Parent = Button
        ButtonGlow.BackgroundColor3 = currentTheme.Neon
        ButtonGlow.BorderSizePixel = 0
        ButtonGlow.Position = UDim2.new(0, 0, 0, 0)
        ButtonGlow.Size = UDim2.new(1, 0, 0, 3)
        ButtonGlow.BackgroundTransparency = 0.7
        
        ButtonIcon.Parent = Button
        ButtonIcon.BackgroundTransparency = 1
        ButtonIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
        ButtonIcon.Size = UDim2.new(0.1, 0, 0.6, 0)
        ButtonIcon.Font = Enum.Font.GothamBlack
        ButtonIcon.Text = "⚡"
        ButtonIcon.TextColor3 = currentTheme.Accent
        ButtonIcon.TextSize = 24
        
        ButtonLabel.Parent = Button
        ButtonLabel.BackgroundTransparency = 1
        ButtonLabel.Position = UDim2.new(0.2, 0, 0.15, 0)
        ButtonLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
        ButtonLabel.Font = Enum.Font.GothamBlack
        ButtonLabel.Text = name
        ButtonLabel.TextColor3 = currentTheme.Text
        ButtonLabel.TextSize = 18
        ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ButtonDescription.Parent = Button
        ButtonDescription.BackgroundTransparency = 1
        ButtonDescription.Position = UDim2.new(0.2, 0, 0.55, 0)
        ButtonDescription.Size = UDim2.new(0.7, 0, 0.3, 0)
        ButtonDescription.Font = Enum.Font.GothamBold
        ButtonDescription.Text = description
        ButtonDescription.TextColor3 = currentTheme.TextSecondary
        ButtonDescription.TextSize = 12
        ButtonDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.3), {
                BackgroundColor3 = currentTheme.Accent,
                Size = UDim2.new(0.92, 0, 0, 95)
            }):Play()
            TweenService:Create(ButtonGlow, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, 0, 0, 5)
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.3), {
                BackgroundColor3 = currentTheme.Secondary,
                Size = UDim2.new(0.9, 0, 0, 90)
            }):Play()
            TweenService:Create(ButtonGlow, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.7,
                Size = UDim2.new(1, 0, 0, 3)
            }):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {
                BackgroundColor3 = currentTheme.Neon
            }):Play()
            TweenService:Create(ButtonGlow, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.1
            }):Play()
            
            wait(0.1)
            
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = currentTheme.Accent
            }):Play()
            TweenService:Create(ButtonGlow, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
            
            if callback then
                callback()
            end
        end)
        
        return Button
    end
    
    function tabs:CreateStatusCard(title, value, icon)
        local Card = Instance.new("Frame")
        local CardLabel = Instance.new("TextLabel")
        local CardValue = Instance.new("TextLabel")
        local CardIcon = Instance.new("TextLabel")
        local CardGlow = Instance.new("Frame")
        
        Card.Name = "StatusCard"
        Card.Parent = TabContent
        Card.BackgroundColor3 = currentTheme.Secondary
        Card.BorderSizePixel = 0
        Card.Size = UDim2.new(0.9, 0, 0, 70)
        
        CardGlow.Name = "CardGlow"
        CardGlow.Parent = Card
        CardGlow.BackgroundColor3 = currentTheme.Accent
        CardGlow.BorderSizePixel = 0
        CardGlow.Position = UDim2.new(0, 0, 0.9, 0)
        CardGlow.Size = UDim2.new(1, 0, 0, 2)
        CardGlow.BackgroundTransparency = 0.6
        
        CardIcon.Parent = Card
        CardIcon.BackgroundTransparency = 1
        CardIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
        CardIcon.Size = UDim2.new(0.1, 0, 0.6, 0)
        CardIcon.Font = Enum.Font.GothamBlack
        CardIcon.Text = icon or "📊"
        CardIcon.TextColor3 = currentTheme.Accent
        CardIcon.TextSize = 20
        
        CardLabel.Parent = Card
        CardLabel.BackgroundTransparency = 1
        CardLabel.Position = UDim2.new(0.2, 0, 0.2, 0)
        CardLabel.Size = UDim2.new(0.5, 0, 0.3, 0)
        CardLabel.Font = Enum.Font.GothamBold
        CardLabel.Text = title
        CardLabel.TextColor3 = currentTheme.TextSecondary
        CardLabel.TextSize = 12
        CardLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        CardValue.Parent = Card
        CardValue.BackgroundTransparency = 1
        CardValue.Position = UDim2.new(0.2, 0, 0.5, 0)
        CardValue.Size = UDim2.new(0.7, 0, 0.4, 0)
        CardValue.Font = Enum.Font.GothamBlack
        CardValue.Text = value
        CardValue.TextColor3 = currentTheme.Text
        CardValue.TextSize = 16
        CardValue.TextXAlignment = Enum.TextXAlignment.Left
        
        return CardValue
    end
    
    function tabs:CreateDivider()
        local Divider = Instance.new("Frame")
        local DividerGlow = Instance.new("Frame")
        
        Divider.Parent = TabContent
        Divider.BackgroundColor3 = currentTheme.Secondary
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(0.9, 0, 0, 5)
        
        DividerGlow.Name = "DividerGlow"
        DividerGlow.Parent = Divider
        DividerGlow.BackgroundColor3 = currentTheme.Neon
        DividerGlow.BorderSizePixel = 0
        DividerGlow.Size = UDim2.new(1, 0, 1, 0)
        DividerGlow.BackgroundTransparency = 0.5
        
        return Divider
    end
    
    -- Entrance animation
    spawn(function()
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        GlowEffect.ImageTransparency = 1
        
        TweenService:Create(MainFrame, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 600),
            BackgroundTransparency = 0
        }):Play()
        
        TweenService:Create(GlowEffect, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 0.8
        }):Play()
    end)
    
    return tabs
end

-- Initialize Ultra Modern UI
local Window = BikinkanUI:CreateWindow("CYBER CONTROL")

-- Demo Content (bisa dihapus atau diganti)
Window:CreateSection("SYSTEM STATUS")

local status1 = Window:CreateStatusCard("CPU USAGE", "24%", "💻")
local status2 = Window:CreateStatusCard("MEMORY", "1.2GB", "🧠")
local status3 = Window:CreateStatusCard("NETWORK", "45ms", "🌐")

Window:CreateDivider()

Window:CreateSection("QUICK ACTIONS")

Window:CreateButton("INITIALIZE SYSTEM", "Start all automated processes", function()
    print("🚀 System Initialized!")
end)

Window:CreateButton("SECURITY SCAN", "Run comprehensive security check", function()
    print("🛡️ Security Scan Started!")
end)

Window:CreateButton("DATA BACKUP", "Create system backup", function()
    print("💾 Backup Process Started!")
end)

Window:CreateDivider()

Window:CreateSection("PERFORMANCE")

Window:CreateButton("OPTIMIZE MEMORY", "Clear cache and optimize RAM", function()
    print("🧹 Memory Optimized!")
end)

Window:CreateButton("SPEED BOOST", "Increase system performance", function()
    print("⚡ Speed Boost Activated!")
end)

-- Animate status values
spawn(function()
    while true do
        status1.Text = math.random(20, 40) .. "%"
        status2.Text = math.random(1, 2) .. "." .. math.random(0, 9) .. "GB"
        status3.Text = math.random(30, 60) .. "ms"
        wait(3)
    end
end)

print("🎮 Ultra Modern UI Loaded!")
print("✨ Cyberpunk Design Activated")
print("🚀 Ready for Action")
