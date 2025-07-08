local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- SETTINGS
local theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Tab = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Scroll = Color3.fromRGB(15, 15, 15)
}

-- Create UI Base
function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 500, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Name = "MainWindow"
    MainFrame.BackgroundTransparency = 0
    MainFrame.ZIndex = 2
    MainFrame.AutomaticSize = Enum.AutomaticSize.None
    MainFrame.SizeConstraint = Enum.SizeConstraint.RelativeXY
    MainFrame.BorderMode = Enum.BorderMode.Outline
    MainFrame.BorderSizePixel = 0
    MainFrame:SetAttribute("Minimized", false)
    MainFrame.BackgroundTransparency = 0
    MainFrame:SetAttribute("OriginalSize", MainFrame.Size)

    local UICornerMain = Instance.new("UICorner", MainFrame)
    UICornerMain.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Minimize = Instance.new("TextButton", MainFrame)
    Minimize.Size = UDim2.new(0, 30, 0, 30)
    Minimize.Position = UDim2.new(1, -35, 0, 5)
    Minimize.BackgroundColor3 = theme.Tab
    Minimize.Text = "-"
    Minimize.TextColor3 = theme.Text
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 18
    Minimize.AutoButtonColor = true

    local UICornerMin = Instance.new("UICorner", Minimize)
    UICornerMin.CornerRadius = UDim.new(1, 0)

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 120, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 10)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 120, 0, 40)
    PageContainer.Size = UDim2.new(1, -120, 1, -40)
    PageContainer.BackgroundColor3 = theme.Scroll
    Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 10)

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)

    local pages = {}

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end
    end

    Minimize.MouseButton1Click:Connect(function()
        local minimized = MainFrame:GetAttribute("Minimized")
        MainFrame:SetAttribute("Minimized", not minimized)

        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = MainFrame:GetAttribute("OriginalSize")}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 500, 0, 40)}):Play()
        end
    end)

    local window = {}

    function window:CreateTab(tabName)
        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.BackgroundColor3 = theme.Background
        Button.Text = tabName
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = true
        Button.BorderSizePixel = 0
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.Position = UDim2.new(0, 5, 0, 5)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 5
        Page.ScrollBarImageColor3 = theme.Accent
        Page.BackgroundColor3 = theme.Scroll
        Page.BorderSizePixel = 0
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ClipsDescendants = true
        Instance.new("UICorner", Page).CornerRadius = UDim.new(0, 10)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 6)

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
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 16
            Btn.AutoButtonColor = true
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Btn.MouseButton1Click:Connect(callback)
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -10, 0, 30)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

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
            frame.Size = UDim2.new(1, -10, 0, 36)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 16)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = theme.Text
            label.BackgroundTransparency = 1
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBar = Instance.new("Frame", frame)
            sliderBar.Position = UDim2.new(0, 0, 0, 20)
            sliderBar.Size = UDim2.new(1, 0, 0, 6)
            sliderBar.BackgroundColor3 = theme.Tab
            sliderBar.BorderSizePixel = 0
            Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", sliderBar)
            fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
            fill.BackgroundColor3 = theme.Accent
            fill.BorderSizePixel = 0
            fill.Name = "Fill"
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateFill(input)
                local rel = input.Position.X - sliderBar.AbsolutePosition.X
                local pct = math.clamp(rel / sliderBar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                local val = math.floor(min + (max - min) * pct)
                label.Text = text .. ": " .. val
                callback(val)
            end

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFill(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFill(input)
                end
            end)

            callback(default)
        end

        return tab
    end

    return window
end

return Library
