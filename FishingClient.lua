-- Bikinkan Premium UI Template
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Premium UI Library
local BikinkanUI = {}
BikinkanUI.Themes = {
    DeepOcean = {
        Main = Color3.fromRGB(15, 25, 45),
        Secondary = Color3.fromRGB(25, 40, 65),
        Accent = Color3.fromRGB(0, 200, 255),
        Success = Color3.fromRGB(0, 255, 170),
        Text = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(180, 200, 220),
        Border = Color3.fromRGB(40, 60, 90)
    },
    DarkPurple = {
        Main = Color3.fromRGB(30, 20, 45),
        Secondary = Color3.fromRGB(45, 30, 65),
        Accent = Color3.fromRGB(170, 0, 255),
        Success = Color3.fromRGB(0, 255, 170),
        Text = Color3.fromRGB(245, 240, 255),
        TextSecondary = Color3.fromRGB(200, 180, 220),
        Border = Color3.fromRGB(60, 40, 80)
    }
}

local currentTheme = BikinkanUI.Themes.DeepOcean

function BikinkanUI:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    local MainContainer = Instance.new("Frame")
    local MainFrame = Instance.new("Frame")
    local BackgroundEffect = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Subtitle = Instance.new("TextLabel")
    local CloseButton = Instance.new("ImageButton")
    local TabContainer = Instance.new("Frame")
    local TabContent = Instance.new("ScrollingFrame")
    local ContentList = Instance.new("UIListLayout")
    
    -- ScreenGui
    ScreenGui.Name = "BikinkanPremiumUI"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Container dengan glass effect
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = ScreenGui
    MainContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainContainer.BackgroundTransparency = 0.7
    MainContainer.BorderSizePixel = 0
    MainContainer.Size = UDim2.new(1, 0, 1, 0)
    MainContainer.Visible = true
    
    -- Main Frame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainContainer
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = currentTheme.Main
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 550)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Background Effect dengan gradient
    BackgroundEffect.Name = "BackgroundEffect"
    BackgroundEffect.Parent = MainFrame
    BackgroundEffect.BackgroundColor3 = currentTheme.Secondary
    BackgroundEffect.BackgroundTransparency = 0.1
    BackgroundEffect.BorderSizePixel = 0
    BackgroundEffect.Position = UDim2.new(0, 15, 0, 15)
    BackgroundEffect.Size = UDim2.new(1, -30, 1, -30)
    BackgroundEffect.ZIndex = -1
    
    -- Top Bar dengan elegant design
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = currentTheme.Secondary
    TopBar.BackgroundTransparency = 0.1
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 100)
    
    -- Title dengan elegant typography
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.08, 0, 0.2, 0)
    Title.Size = UDim2.new(0.7, 0, 0.3, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "✨ " .. name
    Title.TextColor3 = currentTheme.Text
    Title.TextSize = 24
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Subtitle
    Subtitle.Name = "Subtitle"
    Subtitle.Parent = TopBar
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.08, 0, 0.55, 0)
    Subtitle.Size = UDim2.new(0.7, 0, 0.25, 0)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Premium UI Template"
    Subtitle.TextColor3 = currentTheme.TextSecondary
    Subtitle.TextSize = 14
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button yang elegant
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(0.9, 0, 0.3, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(924, 724)
    CloseButton.ImageRectSize = Vector2.new(36, 36)
    CloseButton.ImageColor3 = currentTheme.TextSecondary
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.3), {
            ImageColor3 = Color3.fromRGB(255, 100, 100),
            Rotation = 90
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.3), {
            ImageColor3 = currentTheme.TextSecondary,
            Rotation = 0
        }):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Container
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = currentTheme.Main
    TabContainer.BackgroundTransparency = 0.05
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0.18, 0)
    TabContainer.Size = UDim2.new(1, 0, 0.82, 0)
    
    -- Tab Content Area
    TabContent.Name = "TabContent"
    TabContent.Parent = TabContainer
    TabContent.Active = true
    TabContent.BackgroundColor3 = currentTheme.Main
    TabContent.BackgroundTransparency = 0.05
    TabContent.BorderSizePixel = 0
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = currentTheme.Accent
    TabContent.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    
    ContentList.Parent = TabContent
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 20)
    
    local tabs = {}
    
    function tabs:CreateSection(title)
        local Section = Instance.new("Frame")
        local SectionTitle = Instance.new("TextLabel")
        local SectionDivider = Instance.new("Frame")
        
        Section.Name = "Section"
        Section.Parent = TabContent
        Section.BackgroundColor3 = currentTheme.Secondary
        Section.BackgroundTransparency = 0.1
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(0.9, 0, 0, 70)
        
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0.05, 0, 0.2, 0)
        SectionTitle.Size = UDim2.new(0.9, 0, 0.4, 0)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = "🎯 " .. title
        SectionTitle.TextColor3 = currentTheme.Text
        SectionTitle.TextSize = 18
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        SectionDivider.Name = "SectionDivider"
        SectionDivider.Parent = Section
        SectionDivider.BackgroundColor3 = currentTheme.Accent
        SectionDivider.BorderSizePixel = 0
        SectionDivider.Position = UDim2.new(0.05, 0, 0.8, 0)
        SectionDivider.Size = UDim2.new(0.9, 0, 0, 2)
        
        return Section
    end
    
    function tabs:CreateToggle(name, description, default, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleDescription = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        local ToggleIndicator = Instance.new("Frame")
        
        ToggleFrame.Parent = TabContent
        ToggleFrame.BackgroundColor3 = currentTheme.Secondary
        ToggleFrame.BackgroundTransparency = 0.1
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 85)
        
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
        ToggleLabel.Size = UDim2.new(0.7, 0, 0.3, 0)
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = currentTheme.Text
        ToggleLabel.TextSize = 16
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleDescription.Parent = ToggleFrame
        ToggleDescription.BackgroundTransparency = 1
        ToggleDescription.Position = UDim2.new(0.05, 0, 0.5, 0)
        ToggleDescription.Size = UDim2.new(0.7, 0, 0.3, 0)
        ToggleDescription.Font = Enum.Font.Gotham
        ToggleDescription.Text = description
        ToggleDescription.TextColor3 = currentTheme.TextSecondary
        ToggleDescription.TextSize = 12
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = default and currentTheme.Success or Color3.fromRGB(80, 80, 100)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.8, 0, 0.3, 0)
        ToggleButton.Size = UDim2.new(0.14, 0, 0.4, 0)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = currentTheme.Text
        ToggleButton.TextSize = 10
        ToggleButton.AutoButtonColor = false
        
        ToggleIndicator.Parent = ToggleButton
        ToggleIndicator.BackgroundColor3 = currentTheme.Text
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Position = UDim2.new(default and 0.55 or 0.05, 0, 0.15, 0)
        ToggleIndicator.Size = UDim2.new(0.4, 0, 0.7, 0)
        
        ToggleButton.MouseButton1Click:Connect(function()
            local newValue = not (ToggleIndicator.Position.X.Scale > 0.5)
            
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.3), {
                Position = UDim2.new(newValue and 0.55 or 0.05, 0, 0.15, 0)
            }):Play()
            
            TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
                BackgroundColor3 = newValue and currentTheme.Success or Color3.fromRGB(80, 80, 100)
            }):Play()
            
            if callback then
                callback(newValue)
            end
        end)
        
        return ToggleFrame
    end
    
    function tabs:CreateButton(name, description, callback)
        local Button = Instance.new("TextButton")
        local ButtonLabel = Instance.new("TextLabel")
        local ButtonDescription = Instance.new("TextLabel")
        local ButtonIcon = Instance.new("TextLabel")
        
        Button.Parent = TabContent
        Button.BackgroundColor3 = currentTheme.Accent
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 75)
        Button.AutoButtonColor = false
        
        ButtonIcon.Parent = Button
        ButtonIcon.BackgroundTransparency = 1
        ButtonIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
        ButtonIcon.Size = UDim2.new(0.1, 0, 0.6, 0)
        ButtonIcon.Font = Enum.Font.GothamBold
        ButtonIcon.Text = "⚡"
        ButtonIcon.TextColor3 = currentTheme.Text
        ButtonIcon.TextSize = 20
        
        ButtonLabel.Parent = Button
        ButtonLabel.BackgroundTransparency = 1
        ButtonLabel.Position = UDim2.new(0.2, 0, 0.15, 0)
        ButtonLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
        ButtonLabel.Font = Enum.Font.GothamBold
        ButtonLabel.Text = name
        ButtonLabel.TextColor3 = currentTheme.Text
        ButtonLabel.TextSize = 17
        ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ButtonDescription.Parent = Button
        ButtonDescription.BackgroundTransparency = 1
        ButtonDescription.Position = UDim2.new(0.2, 0, 0.55, 0)
        ButtonDescription.Size = UDim2.new(0.7, 0, 0.3, 0)
        ButtonDescription.Font = Enum.Font.Gotham
        ButtonDescription.Text = description
        ButtonDescription.TextColor3 = currentTheme.TextSecondary
        ButtonDescription.TextSize = 12
        ButtonDescription.TextXAlignment = Enum.TextXAlignment.Left
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.3), {
                BackgroundColor3 = currentTheme.Success,
                Size = UDim2.new(0.91, 0, 0, 77)
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.3), {
                BackgroundColor3 = currentTheme.Accent,
                Size = UDim2.new(0.9, 0, 0, 75)
            }):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            }):Play()
            wait(0.1)
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = currentTheme.Accent
            }):Play()
            
            if callback then
                callback()
            end
        end)
        
        return Button
    end
    
    function tabs:CreateSlider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        local SliderLabel = Instance.new("TextLabel")
        local SliderValue = Instance.new("TextLabel")
        local SliderBar = Instance.new("Frame")
        local SliderFill = Instance.new("Frame")
        local SliderButton = Instance.new("TextButton")
        
        SliderFrame.Parent = TabContent
        SliderFrame.BackgroundColor3 = currentTheme.Secondary
        SliderFrame.BackgroundTransparency = 0.1
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(0.9, 0, 0, 95)
        
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
        SliderLabel.Size = UDim2.new(0.6, 0, 0.25, 0)
        SliderLabel.Font = Enum.Font.GothamBold
        SliderLabel.Text = name
        SliderLabel.TextColor3 = currentTheme.Text
        SliderLabel.TextSize = 15
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderValue.Parent = SliderFrame
        SliderValue.BackgroundTransparency = 1
        SliderValue.Position = UDim2.new(0.7, 0, 0.1, 0)
        SliderValue.Size = UDim2.new(0.25, 0, 0.25, 0)
        SliderValue.Font = Enum.Font.GothamBold
        SliderValue.Text = tostring(default)
        SliderValue.TextColor3 = currentTheme.Accent
        SliderValue.TextSize = 15
        
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = currentTheme.Main
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(0.05, 0, 0.5, 0)
        SliderBar.Size = UDim2.new(0.9, 0, 0.2, 0)
        
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = currentTheme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        SliderButton.Parent = SliderBar
        SliderButton.BackgroundColor3 = currentTheme.Text
        SliderButton.BorderSizePixel = 0
        SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -4)
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Font = Enum.Font.Gotham
        SliderButton.Text = ""
        SliderButton.ZIndex = 2
        
        local dragging = false
        
        local function updateSlider(input)
            local pos = UDim2.new(
                math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1),
                0, 1, 0
            )
            SliderFill.Size = pos
            SliderButton.Position = UDim2.new(pos.X.Scale, -8, 0, -4)
            local value = math.floor(min + (pos.X.Scale * (max - min)))
            SliderValue.Text = tostring(value)
            if callback then
                callback(value)
            end
        end
        
        SliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        SliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        return SliderFrame
    end
    
    function tabs:CreateLabel(text, size)
        local Label = Instance.new("TextLabel")
        
        Label.Parent = TabContent
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.9, 0, 0, size or 35)
        Label.Font = Enum.Font.Gotham
        Label.Text = text
        Label.TextColor3 = currentTheme.Text
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        return Label
    end
    
    function tabs:CreateDivider()
        local Divider = Instance.new("Frame")
        
        Divider.Parent = TabContent
        Divider.BackgroundColor3 = currentTheme.Border
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(0.9, 0, 0, 2)
        
        return Divider
    end
    
    -- Entrance animation
    spawn(function()
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        BackgroundEffect.BackgroundTransparency = 1
        
        TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 450, 0, 550),
            BackgroundTransparency = 0.05
        }):Play()
        
        TweenService:Create(BackgroundEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    return tabs
end
