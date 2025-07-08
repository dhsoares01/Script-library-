local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Tab = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(60, 60, 60),
    ScrollViewBackground = Color3.fromRGB(20, 20, 20),
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 8)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1

    -- (Todo o restante permanece igual até chegar no AddSlider)

    local window = {}

    function window:CreateTab(tabName, icon)
        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -10, 0, 34)
        Button.BackgroundColor3 = theme.Background
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 6)

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 6, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 18
            iconLabel.TextColor3 = theme.Accent
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        end

        Button.Text = icon and ("  " .. tabName) or tabName

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0

        local pageCorner = Instance.new("UICorner", Page)
        pageCorner.CornerRadius = UDim.new(0, 8)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)
        end)

        local tab = {}

        -- (Outras funções AddLabel, AddButton, AddToggle, AddDropdown, AddDropdownButtonOnOff já estão certas)

        function tab:AddSlider(text, min, max, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -10, 0, 36)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Size = UDim2.new(1, 0, 0, 16)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text .. ": " .. tostring(default)
            label.TextColor3 = theme.Text
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBg = Instance.new("Frame", container)
            sliderBg.Size = UDim2.new(1, 0, 0, 8)
            sliderBg.Position = UDim2.new(0, 0, 0, 20)
            sliderBg.BackgroundColor3 = theme.Tab
            sliderBg.BorderSizePixel = 0

            local corner = Instance.new("UICorner", sliderBg)
            corner.CornerRadius = UDim.new(0, 4)

            local sliderFill = Instance.new("Frame", sliderBg)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = theme.Accent
            sliderFill.BorderSizePixel = 0

            local fillCorner = Instance.new("UICorner", sliderFill)
            fillCorner.CornerRadius = UDim.new(0, 4)

            local dragging = false
            local value = default

            local function update(val)
                value = math.clamp(val, min, max)
                local percent = (value - min) / (max - min)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = text .. ": " .. math.floor(value)
                if callback then callback(value) end
            end

            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(min + (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X * (max - min))
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(min + (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X * (max - min))
                end
            end)

            return {
                Set = function(_, val)
                    update(val)
                end,
                Get = function()
                    return value
                end
            }
        end

        return tab
    end

    return window
end

return Library
