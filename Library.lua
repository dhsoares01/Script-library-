local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Tab = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Scroll = Color3.fromRGB(15, 15, 15),
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "CustomUILib"
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
    MainFrame.Name = "MainUI"
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.ZIndex = 2

    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = name or "Menu"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = theme.Text
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Minimize = Instance.new("TextButton", TitleBar)
    Minimize.Size = UDim2.new(0, 40, 1, 0)
    Minimize.Position = UDim2.new(1, -45, 0, 0)
    Minimize.BackgroundTransparency = 1
    Minimize.Text = "_"
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 22
    Minimize.TextColor3 = theme.Text
    Minimize.AutoButtonColor = false

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 120, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab
    TabContainer.BorderSizePixel = 0

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 120, 0, 40)
    PageContainer.Size = UDim2.new(1, -120, 1, -40)
    PageContainer.BackgroundColor3 = theme.Scroll
    PageContainer.BorderSizePixel = 0

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
        Button.TextSize = 16
        Button.AutoButtonColor = true

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = theme.Accent
        Page.BackgroundTransparency = 0
        Page.BackgroundColor3 = theme.Scroll
        Page.BorderSizePixel = 0

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
            Label.TextSize = 16
        end

        function tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 30)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 16
            Btn.AutoButtonColor = true
            Btn.MouseButton1Click:Connect(callback)
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -10, 0, 30)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16

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
            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(1, -10, 0, 36)
            Container.BackgroundTransparency = 1

            local Title = Instance.new("TextLabel", Container)
            Title.Size = UDim2.new(1, 0, 0.5, 0)
            Title.Text = text .. ": " .. tostring(default)
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.Gotham
            Title.TextSize = 14
            Title.BackgroundTransparency = 1

            local Slider = Instance.new("Frame", Container)
            Slider.Size = UDim2.new(1, 0, 0.5, 0)
            Slider.Position = UDim2.new(0, 0, 0.5, 0)
            Slider.BackgroundColor3 = theme.Tab
            Slider.BorderSizePixel = 0

            local Fill = Instance.new("Frame", Slider)
            Fill.BackgroundColor3 = theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

            local dragging = false

            local function set(val)
                val = math.clamp(val, min, max)
                local percent = (val - min) / (max - min)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                Title.Text = text .. ": " .. math.floor(val)
                if callback then callback(math.floor(val)) end
            end

            local function inputPos(x)
                local abs = Slider.AbsolutePosition.X
                local size = Slider.AbsoluteSize.X
                return ((x - abs) / size) * (max - min) + min
            end

            Slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    set(inputPos(input.Position.X))
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    set(inputPos(input.Position.X))
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            set(default)
        end

        return tab
    end

    -- Minimize behavior
    local minimized = false
    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = minimized and UDim2.new(0, 520, 0, 40) or UDim2.new(0, 520, 0, 340)
        }):Play()
    end)

    return window
end

return Library
