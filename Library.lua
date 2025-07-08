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

-- Create UI Base
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
    PageContainer.BackgroundColor3 = theme.Background

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
        Page.BackgroundTransparency = 1

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
            ToggleBtn.Size = UDim2.new(1, -10, 0, 30)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.SourceSans
            ToggleBtn.TextSize = 18

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
            label.Font = Enum.Font.SourceSans
            label.TextColor3 = theme.Text
            label.BackgroundTransparency = 1
            label.TextSize = 16

            local slider = Instance.new("TextButton", frame)
            slider.Size = UDim2.new(0.5, 0, 1, 0)
            slider.Position = UDim2.new(0.5, 0, 0, 0)
            slider.Text = "Set"
            slider.Font = Enum.Font.SourceSans
            slider.TextColor3 = theme.Text
            slider.BackgroundColor3 = theme.Accent
            slider.TextSize = 16

            slider.MouseButton1Click:Connect(function()
                local val = tonumber(string.match(slider.Text, "%d+"))
                if val then
                    callback(val)
                end
            end)

            local current = default or min
            callback(current)
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
