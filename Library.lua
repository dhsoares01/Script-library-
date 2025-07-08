local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Tab = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(60, 60, 60)
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 8)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -40, 0, 40) -- espaço para botão minimizar
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão minimizar
    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -40, 0, 5)
    BtnMinimize.BackgroundColor3 = theme.Tab
    BtnMinimize.Text = "–" -- traço de minimizar
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 24
    BtnMinimize.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(0, 6)

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
    end)

    -- Contêiner de abas e página
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab

    local TabCorner = Instance.new("UICorner", TabContainer)
    TabCorner.CornerRadius = UDim.new(0, 6)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)

    local pages = {}

    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            -- anima esconder (encolher)
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 130, 0, 40) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(1, -40, 0, 40)
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(1, -40, 0, 40)
        end
    end)

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            if pgName == name then
                -- Fade in a página
                pg.Visible = true
                pg.BackgroundTransparency = 1
                TweenService:Create(pg, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
            else
                pg.Visible = false
            end
        end
    end

    local window = {}

    -- Função para permitir redimensionar o menu pela borda direita-inferior
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10
        resizeFrame.Active = true

        local mouseDown = false
        local lastPos = Vector2.new()

        resizeFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = true
                lastPos = UserInputService:GetMouseLocation()
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = UserInputService:GetMouseLocation() - lastPos
                lastPos = UserInputService:GetMouseLocation()

                local newWidth = math.clamp(MainFrame.AbsoluteSize.X + delta.X, 350, 900)
                local newHeight = math.clamp(MainFrame.AbsoluteSize.Y + delta.Y, 220, 600)

                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                -- Atualizar containers relativos ao tamanho
                TabContainer.Size = UDim2.new(0, 130, 1, -40)
                PageContainer.Size = UDim2.new(1, -130, 1, -40)

                -- Ajustar abas e páginas para o novo tamanho
                for _, pg in pairs(pages) do
                    pg.Size = UDim2.new(1, 0, 1, 0)
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = false
            end
        end)
    end

    function window:CreateTab(tabName, icon)
        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -10, 0, 34)
        Button.Position = UDim2.new(0, 5, 0, 0)
        Button.BackgroundColor3 = theme.Background
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 6)

        -- Adiciona ícone (emoji) à esquerda
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
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center

            Button.Text = "  " .. tabName -- espaço para o emoji
        else
            Button.Text = tabName
        end

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Background }):Play()
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0

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
            Btn.Size = UDim2.new(1, -10, 0, 32)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 16

            local corner = Instance.new("UICorner", Btn)
            corner.CornerRadius = UDim.new(0, 6)

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

            local UISizeConstraint = Instance.new("UISizeConstraint", sliderBar)
            UISizeConstraint.MaxSize = Vector2.new(350, 10)

            local mouseDown = false

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mouseDown = true
                    local pos = input.Position.X - sliderBar.AbsolutePosition.X
                    local size = math.clamp(pos / sliderBar.AbsoluteSize.X, 0, 1)
                    sliderFill.Size = UDim2.new(size, 0, 1, 0)
                    local val = math.floor(min + size * (max - min))
                    label.Text = text .. ": " .. val
                    if callback then callback(val) end
                end
            end)

            sliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mouseDown = false
                end
            end)

            sliderBar.InputChanged:Connect(function(input)
                if mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = input.Position.X - sliderBar.AbsolutePosition.X
                    local size = math.clamp(pos / sliderBar.AbsoluteSize.X, 0, 1)
                    sliderFill.Size = UDim2.new(size, 0, 1, 0)
                    local val = math.floor(min + size * (max - min))
                    label.Text = text .. ": " .. val
                    if callback then callback(val) end
                end
            end)

            -- Inicializa valor default no callback
            if callback then
                callback(default)
            end
        end

        function tab:AddDropdown(text, options, callback)
            local frame = Instance.new("Frame", Page)
            frame.Size = UDim2.new(1, -10, 0, 36)
            frame.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = text .. ": " .. options[1]
            label.Font = Enum.Font.Gotham
            label.TextColor3 = theme.Text
            label.BackgroundTransparency = 1
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left

            local index = 1
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    index = index + 1
                    if index > #options then index = 1 end
                    label.Text = text .. ": " .. options[index]
                    if callback then callback(options[index]) end
                end
            end)

            -- Também aceita clique no label
            label.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    index = index + 1
                    if index > #options then index = 1 end
                    label.Text = text .. ": " .. options[index]
                    if callback then callback(options[index]) end
                end
            end)
        end

        return tab
    end

    return window
end

return Library
