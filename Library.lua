local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
    Background = Color3.fromRGB(28, 28, 30),
    Tab = Color3.fromRGB(38, 38, 40),
    Accent = Color3.fromRGB(0, 132, 255),
    Text = Color3.fromRGB(235, 235, 245),
    Shadow = Color3.fromRGB(0, 0, 0)
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "UILibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0
    MainFrame.Name = "MainWindow"
    MainFrame.ZIndex = 10
    MainFrame.AutomaticSize = Enum.AutomaticSize.None
    MainFrame:SetAttribute("Minimized", false)
    MainFrame.UICorner = Instance.new("UICorner", MainFrame)
    MainFrame.UICorner.CornerRadius = UDim.new(0, 10)

    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = theme.Text

    local MinimizeBtn = Instance.new("TextButton", TitleBar)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -40, 0, 5)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextSize = 22
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextColor3 = theme.Text
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.AutoButtonColor = false

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 120, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab
    TabContainer.ZIndex = 2

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 120, 0, 40)
    PageContainer.Size = UDim2.new(1, -120, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ZIndex = 2

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)

    local pages = {}

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end
    end

    local window = {}

    function window:CreateTab(tabName)
        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.BackgroundColor3 = theme.Background
        Button.Text = tabName
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 15
        Button.BorderSizePixel = 0
        Button.AutoButtonColor = true
        Button.BackgroundTransparency = 0.2

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundTransparency = 1
        Page.ZIndex = 2

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 6)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, -10, 0, 24)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 30)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 16
            Btn.AutoButtonColor = true
            Btn.UICorner = Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(callback)
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -10, 0, 30)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16
            ToggleBtn.AutoButtonColor = true

            local state = false
            local function update()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
            end

            update()
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                update()
                if callback then callback(state) end
            end)
        end

        function tab:AddSlider(text, min, max, default, callback)
            local frame = Instance.new("Frame", Page)
            frame.Size = UDim2.new(1, -10, 0, 30)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = theme.Text
            label.BackgroundTransparency = 1
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local slider = Instance.new("TextButton", frame)
            slider.Size = UDim2.new(0.5, 0, 1, 0)
            slider.Position = UDim2.new(0.5, 0, 0, 0)
            slider.Text = "Set"
            slider.Font = Enum.Font.Gotham
            slider.TextColor3 = theme.Text
            slider.BackgroundColor3 = theme.Accent
            slider.TextSize = 14
            slider.UICorner = Instance.new("UICorner", slider)

            slider.MouseButton1Click:Connect(function()
                callback(default)
            end)

            callback(default)
        end

        function tab:AddDropdown(text, options, callback)
            local button = Instance.new("TextButton", Page)
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Text = text .. ": " .. options[1]
            button.BackgroundColor3 = theme.Tab
            button.TextColor3 = theme.Text
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            button.AutoButtonColor = true

            local index = 1
            button.MouseButton1Click:Connect(function()
                index = index + 1
                if index > #options then index = 1 end
                button.Text = text .. ": " .. options[index]
                if callback then callback(options[index]) end
            end)
        end

        return tab
    end

    -- Minimizar
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainFrame:SetAttribute("Minimized", minimized)

        TweenService:Create(MainFrame, TweenInfo.new(0.25), {
            Size = minimized and UDim2.new(0, 520, 0, 40) or UDim2.new(0, 520, 0, 340)
        }):Play()
    end)

    return window
end

return Library
