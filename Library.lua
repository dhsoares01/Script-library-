local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Tab = Color3.fromRGB(45, 45, 48),
    TabHover = Color3.fromRGB(65, 65, 70),
    TabActive = Color3.fromRGB(0, 120, 255),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Stroke = Color3.fromRGB(60, 60, 60),
    ScrollViewBackground = Color3.fromRGB(18, 18, 18), -- fundo mais escuro para ScrollView
    Shadow = Color3.fromRGB(0, 0, 0),
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true

    -- Sombras sutis usando UIStroke com baixa transparência
    local UIStrokeMain = Instance.new("UIStroke", MainFrame)
    UIStrokeMain.Color = theme.Stroke
    UIStrokeMain.Transparency = 0.7
    UIStrokeMain.Thickness = 1

    local UICornerMain = Instance.new("UICorner", MainFrame)
    UICornerMain.CornerRadius = UDim.new(0, 10)

    -- Drag support (igual seu original)
    local dragging = false
    local dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    MainFrame.ClipsDescendants = true

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -40, 0, 40)
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
    BtnMinimize.Text = "–"
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 24
    BtnMinimize.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(0, 8)

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
    end)

    -- Contêiner de abas
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 150, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab
    TabContainer.ClipsDescendants = true

    local TabCorner = Instance.new("UICorner", TabContainer)
    TabCorner.CornerRadius = UDim.new(0, 10)

    -- Sombra interna para o container de abas (para efeito mais moderno)
    local TabShadow = Instance.new("Frame", TabContainer)
    TabShadow.Size = UDim2.new(1, 0, 1, 0)
    TabShadow.BackgroundColor3 = theme.Shadow
    TabShadow.BackgroundTransparency = 0.85
    TabShadow.BorderSizePixel = 0
    TabShadow.ZIndex = 0

    local TabShadowCorner = Instance.new("UICorner", TabShadow)
    TabShadowCorner.CornerRadius = UDim.new(0, 10)

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 10)

    -- Contêiner de páginas (ScrollView)
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 150, 0, 40)
    PageContainer.Size = UDim2.new(1, -150, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true

    local UIStrokePage = Instance.new("UIStroke", PageContainer)
    UIStrokePage.Color = theme.Stroke
    UIStrokePage.Transparency = 0.6
    UIStrokePage.Thickness = 1

    local pages = {}

    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 40) }):Play()
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
                pg.Visible = true
                pg.BackgroundTransparency = 1
                TweenService:Create(pg, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
            else
                pg.Visible = false
            end
        end
    end

    local window = {}

    -- Redimensionar menu (borda direita-inferior)
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
                TabContainer.Size = UDim2.new(0, 150, 1, -40)
                PageContainer.Size = UDim2.new(1, -150, 1, -40)

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
        Button.Size = UDim2.new(1, -20, 0, 38)
        Button.Position = UDim2.new(0, 10, 0, 0)
        Button.BackgroundColor3 = theme.Tab
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.ClipsDescendants = true

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 8)

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 8, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 18
            iconLabel.TextColor3 = theme.Accent
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center

            Button.Text = "  " .. tabName
        else
            Button.Text = tabName
        end

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 6
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        Page.ScrollBarImageColor3 = theme.Accent

        local pageCorner = Instance.new("UICorner", Page)
        pageCorner.CornerRadius = UDim.new(0, 10)

        -- Layout interno para os itens da página
        local layout = Instance.new("UIListLayout", Page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)

        -- Atualiza CanvasSize automaticamente com mudança no layout
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)

        -- Gerenciar toggle visual do botão da aba
        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)

            -- Atualiza as cores dos botões para mostrar qual está ativo
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn == Button then
                        TweenService:Create(btn, TweenInfo.new(0.25), { BackgroundColor3 = theme.TabActive, TextColor3 = Color3.new(1,1,1) }):Play()
                    else
                        TweenService:Create(btn, TweenInfo.new(0.25), { BackgroundColor3 = theme.Tab, TextColor3 = theme.Text }):Play()
                    end
                end
            end
        end)

        pages[tabName] = Page

        -- Se for a primeira aba criada, ativa automaticamente
        if next(pages) == Page then
            Button.BackgroundColor3 = theme.TabActive
            Button.TextColor3 = Color3.new(1,1,1)
            Page.Visible = true
        end

        -- Retorna o container da página para o usuário adicionar itens
        return Page
    end

    return window
end

return Library
