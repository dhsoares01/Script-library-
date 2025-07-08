local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- SETTINGS
local theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Tab = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 500, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 20
    Title.Font = Enum.Font.SourceSansBold
    Title.TextColor3 = theme.Text

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 120, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 120, 0, 40)
    PageContainer.Size = UDim2.new(1, -120, 1, -40)
    PageContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    local corner = Instance.new("UICorner", PageContainer)
    corner.CornerRadius = UDim.new(0, 8)

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
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.BackgroundColor3 = theme.Background
        Button.Text = tabName
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.SourceSans
        Button.TextSize = 18

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundTransparency = 0
        Page.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

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
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 16
        end

        function tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 30)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 18
            Btn.MouseButton1Click:Connect(callback)
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -10, 0, 32)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16

            local corner = Instance.new("UICorner", ToggleBtn)
            corner.CornerRadius = UDim.new(0, 6)

            local state = false
            local function update()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                ToggleBtn.BackgroundColor3 = state and theme.Accent or theme.Tab
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
            frame.Size = UDim2.new(1, -10, 0, 40)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = theme.Text
            label.BackgroundTransparency = 1
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBar = Instance.new("Frame", frame)
            sliderBar.Size = UDim2.new(1, 0, 0, 10)
            sliderBar.Position = UDim2.new(0, 0, 0, 22)
            sliderBar.BackgroundColor3 = theme.Tab
            sliderBar.ClipsDescendants = true

            local sliderFill = Instance.new("Frame", sliderBar)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = theme.Accent
            sliderFill.BorderSizePixel = 0

            local mouseDown = false

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    mouseDown = true
                end
            end)

            sliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    mouseDown = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if (mouseDown and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) and input.Position then
                    local pos = input.Position.X - sliderBar.AbsolutePosition.X
                    local size = math.clamp(pos / sliderBar.AbsoluteSize.X, 0, 1)
                    sliderFill.Size = UDim2.new(size, 0, 1, 0)
                    local val = math.floor(min + size * (max - min))
                    label.Text = text .. ": " .. val
                    if callback then callback(val) end
                end
            end)

            if callback then
                callback(default)
            end
        end

        function tab:AddDropdown(text, options, callback)
            local button = Instance.new("TextButton", Page)
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Text = text .. ": " .. options[1]
            button.BackgroundColor3 = theme.Tab
            button.TextColor3 = theme.Text
            button.Font = Enum.Font.SourceSans
            button.TextSize = 16

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

    return window
end

return Library
