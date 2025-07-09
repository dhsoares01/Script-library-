local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Tema de cores revisado para um visual mais moderno e consistente
local theme = {
    Background = Color3.fromRGB(25, 25, 25),        -- Fundo principal da janela
    TabContainer = Color3.fromRGB(35, 35, 35),     -- Fundo do container de abas
    PageBackground = Color3.fromRGB(20, 20, 20),   -- Fundo das páginas de conteúdo (ScrollView)
    Accent = Color3.fromRGB(0, 150, 255),          -- Cor de destaque (azul vibrante)
    Text = Color3.fromRGB(240, 240, 240),          -- Cor principal do texto
    MutedText = Color3.fromRGB(180, 180, 180),     -- Texto secundário/indicadores
    Border = Color3.fromRGB(45, 45, 45),           -- Bordas sutis
    Hover = Color3.fromRGB(0, 170, 255),           -- Cor ao passar o mouse (um pouco mais claro que Accent)
    ToggleOff = Color3.fromRGB(50, 50, 50),        -- Cor do toggle desativado
    ToggleOn = Color3.fromRGB(0, 150, 255),        -- Cor do toggle ativado (Accent)
}

-- Constantes para facilitar ajustes
local CORNER_RADIUS = 8
local PADDING = 10
local TAB_WIDTH = 140
local HEADER_HEIGHT = 40
local CONTROL_HEIGHT = 36
local BUTTON_HEIGHT = 32

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 580, 0, 400) -- Tamanho inicial um pouco maior
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = false -- Draggable personalizado
    MainFrame.ClipsDescendants = true -- Garante que cantos arredondados sejam cortados corretamente
    MainFrame.Parent = ScreenGui

    -- Adiciona sombra sutil para profundidade
    local UIShadow = Instance.new("UIStroke", MainFrame)
    UIShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIShadow.Color = Color3.fromRGB(0,0,0) -- Cor da sombra
    UIShadow.Transparency = 0.6 -- Transparência da sombra
    UIShadow.Thickness = 2 -- Espessura da sombra

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, CORNER_RADIUS)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Border
    UIStroke.Thickness = 1

    -- Lógica de arrastar o MainFrame (melhorada para usar o Header)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    -- Frame superior para arrastar e título/botão
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = theme.TabContainer -- Cor de fundo para o cabeçalho
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.ClipsDescendants = true -- Importante para o canto superior arredondado

    -- UICorner apenas para os cantos superiores do HeaderFrame
    local HeaderCorner = Instance.new("UICorner", HeaderFrame)
    HeaderCorner.CornerRadius = UDim.new(0, CORNER_RADIUS)
    -- Remove UICorner do MainFrame se quiser apenas no Header (ajuste conforme preferência)

    HeaderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            startPos = MainFrame.Position
            input.Handled = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Título
    local Title = Instance.new("TextLabel", HeaderFrame)
    Title.Size = UDim2.new(1, -HEADER_HEIGHT - PADDING, 1, 0) -- Espaço para botão minimizar
    Title.Position = UDim2.new(0, PADDING, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão minimizar/maximizar
    local BtnMinimize = Instance.new("TextButton", HeaderFrame)
    BtnMinimize.Size = UDim2.new(0, HEADER_HEIGHT - PADDING * 2, 0, HEADER_HEIGHT - PADDING * 2)
    BtnMinimize.Position = UDim2.new(1, -HEADER_HEIGHT + PADDING, 0, PADDING)
    BtnMinimize.BackgroundColor3 = theme.ToggleOff
    BtnMinimize.Text = "—" -- Unicode para traço
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 22
    BtnMinimize.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2) -- Cantos ligeiramente menos arredondados

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Hover }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.ToggleOff }):Play()
    end)

    -- Contêiner de abas
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
    TabContainer.Size = UDim2.new(0, TAB_WIDTH, 1, -HEADER_HEIGHT)
    TabContainer.BackgroundColor3 = theme.TabContainer
    TabContainer.BorderSizePixel = 0

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, PADDING / 2) -- Espaçamento entre abas
    UIList.FillDirection = Enum.FillDirection.Vertical
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Adiciona padding ao TabContainer para as abas não colarem nas bordas
    local UIMargin = Instance.new("UIPadding", TabContainer)
    UIMargin.PaddingLeft = UDim.new(0, PADDING / 2)
    UIMargin.PaddingRight = UDim.new(0, PADDING / 2)
    UIMargin.PaddingTop = UDim.new(0, PADDING / 2)
    UIMargin.PaddingBottom = UDim.new(0, PADDING / 2)


    -- Contêiner de páginas
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, TAB_WIDTH, 0, HEADER_HEIGHT)
    PageContainer.Size = UDim2.new(1, -TAB_WIDTH, 1, -HEADER_HEIGHT)
    PageContainer.BackgroundColor3 = theme.PageBackground
    PageContainer.ClipsDescendants = true
    PageContainer.BorderSizePixel = 0

    local pages = {}
    local firstTabName = nil
    local currentVisiblePage = nil -- Mantém controle da página atualmente visível

    local minimized = false
    local originalSize = MainFrame.Size
    local originalPosition = MainFrame.Position

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            originalSize = MainFrame.Size -- Salva o tamanho atual antes de minimizar
            originalPosition = MainFrame.Position
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, TAB_WIDTH + PADDING * 2, 0, HEADER_HEIGHT),
                Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (originalSize.Y.Offset / 2) - (HEADER_HEIGHT / 2)) -- Centraliza verticalmente ao minimizar
            }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "☐" -- Ícone de maximizar
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = originalSize,
                Position = originalPosition
            }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "—" -- Ícone de minimizar
        end
    end)

    local function switchToPage(name)
        if currentVisiblePage then
            currentVisiblePage.Visible = false
        end
        local newPage = pages[name]
        if newPage then
            newPage.Visible = true
            currentVisiblePage = newPage
        end
    end

    local window = {}

    -- Redimensionar menu (borda direita-inferior)
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 15, 0, 15) -- Área de redimensionamento menor
        resizeFrame.Position = UDim2.new(1, -15, 1, -15)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10
        resizeFrame.Active = true
        resizeFrame.Name = "ResizeHandle"

        UserInputService.MouseIconEnabled = false -- Desabilita ícone de mouse nativo para usar cursor personalizado
        resizeFrame.MouseEnter:Connect(function()
            UserInputService.MouseIcon = "rbxassetid://628608466" -- Ícone de redimensionamento diagonal (ou similar)
        end)
        resizeFrame.MouseLeave:Connect(function()
            if not dragging then
                UserInputService.MouseIcon = "" -- Volta ao ícone padrão
            end
        end)

        local mouseDownResize = false
        local initialMousePos = Vector2.new()
        local initialFrameSize = UDim2.new()

        resizeFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDownResize = true
                initialMousePos = UserInputService:GetMouseLocation()
                initialFrameSize = MainFrame.Size
                input.Handled = true
                UserInputService.MouseIcon = "rbxassetid://628608466" -- Garante ícone de redimensionamento
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if mouseDownResize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = UserInputService:GetMouseLocation() - initialMousePos

                local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 400, 1000) -- Limites de redimensionamento
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 250, 700)

                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                -- Atualiza originalSize para manter o estado correto ao minimizar/maximizar
                originalSize = MainFrame.Size
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDownResize = false
                UserInputService.MouseIcon = "" -- Volta ao ícone padrão
            end
        end)
    end

    function window:CreateTab(tabName, icon)
        if firstTabName == nil then
            firstTabName = tabName
        end

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -PADDING, 0, CONTROL_HEIGHT) -- Ajusta tamanho do botão da aba
        Button.BackgroundColor3 = theme.TabContainer
        Button.TextColor3 = theme.MutedText
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 15
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.TextWrapped = true

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

        local currentStroke = Instance.new("UIStroke", Button)
        currentStroke.Color = theme.TabContainer
        currentStroke.Thickness = 1
        currentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, PADDING / 2, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 18
            iconLabel.TextColor3 = theme.Accent
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center

            Button.Text = "  " .. tabName -- Adiciona espaço para o ícone
            Button.TextXAlignment = Enum.TextXAlignment.Left -- Garante alinhamento à esquerda após o ícone
            Button.TextLabel.TextXAlignment = Enum.TextXAlignment.Left -- Força o alinhamento do texto interno
            Button.TextLabel.TextWrapped = true
            Button.TextLabel.Size = UDim2.new(1, -24 - PADDING, 1, 0) -- Ajusta tamanho do textlabel
            Button.TextLabel.Position = UDim2.new(0, 24 + PADDING / 2, 0, 0)

        else
            Button.Text = tabName
            local pad = Instance.new("UIPadding", Button)
            pad.PaddingLeft = UDim.new(0, PADDING)
        end

        local function updateTabVisual(isSelected)
            if isSelected then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Background, TextColor3 = theme.Text }):Play()
                TweenService:Create(currentStroke, TweenInfo.new(0.2), { Color = theme.Accent }):Play()
            else
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.TabContainer, TextColor3 = theme.MutedText }):Play()
                TweenService:Create(currentStroke, TweenInfo.new(0.2), { Color = theme.TabContainer }):Play()
            end
        end

        Button.MouseEnter:Connect(function()
            if currentVisiblePage ~= pages[tabName] then -- Apenas se não for a aba selecionada
                TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundColor3 = theme.Background }):Play()
                TweenService:Create(currentStroke, TweenInfo.new(0.15), { Color = theme.Border }):Play()
            end
        end)
        Button.MouseLeave:Connect(function()
            if currentVisiblePage ~= pages[tabName] then
                TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabContainer }):Play()
                TweenService:Create(currentStroke, TweenInfo.new(0.15), { Color = theme.TabContainer }):Play()
            end
        end)


        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 6 -- Scrollbar mais visível
        Page.ScrollBarImageColor3 = theme.Accent
        Page.BackgroundTransparency = 1 -- O PageContainer já tem a cor de fundo
        Page.BorderSizePixel = 0
        Page.ClipsDescendants = true -- Garante que o conteúdo não vaze

        -- Adiciona padding interno para os elementos da página
        local UIPagePadding = Instance.new("UIPadding", Page)
        UIPagePadding.PaddingLeft = UDim.new(0, PADDING)
        UIPagePadding.PaddingRight = UDim.new(0, PADDING)
        UIPagePadding.PaddingTop = UDim.new(0, PADDING)
        UIPagePadding.PaddingBottom = UDim.new(0, PADDING)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, PADDING)
        Layout.FillDirection = Enum.FillDirection.Vertical
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + PADDING * 2)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            for name, _ in pairs(pages) do
                updateTabVisual(name == tabName)
            end
            switchToPage(tabName)
        end)

        local tab = {}

        function tab:AddLabel(text, size, alignment)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, 0, 0, size or 24) -- Altura ajustável
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 16
            Label.TextXAlignment = alignment or Enum.TextXAlignment.Left
            Label.TextWrapped = true
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1, 1, 1) -- Branco puro para contraste no Accent
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 16
            Btn.AutoButtonColor = false

            local corner = Instance.new("UICorner", Btn)
            corner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Hover }):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
            end)

            Btn.MouseButton1Click:Connect(callback)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT)
            ToggleBtn.BackgroundColor3 = theme.ToggleOff
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16
            ToggleBtn.AutoButtonColor = false

            local corner = Instance.new("UICorner", ToggleBtn)
            corner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff }):Play()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { TextColor3 = state and Color3.new(1,1,1) or theme.Text }):Play()
            end
            updateToggleVisual()

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggleVisual()
                if callback then
                    callback(state)
                end
            end)

            ToggleBtn.MouseEnter:Connect(function()
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(60,60,60) }):Play()
                end
            end)
            ToggleBtn.MouseLeave:Connect(function()
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.1), { BackgroundColor3 = theme.ToggleOff }):Play()
                end
            end)

            return {
                Set = function(self, value)
                    state = value
                    updateToggleVisual()
                end,
                Get = function(self)
                    return state
                end,
                _instance = ToggleBtn
            }
        end

        function tab:AddDropdownButtonOnOff(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT)
            container.BackgroundColor3 = theme.ToggleOff
            container.BorderSizePixel = 0
            container.ClipsDescendants = true -- Para garantir que o UICorner funcione

            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.AutoButtonColor = false

            local dropdownFrame = Instance.new("Frame") -- Criado fora do container inicial
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0) -- Altura inicial 0, será ajustada
            dropdownFrame.BackgroundColor3 = theme.TabContainer
            dropdownFrame.Visible = false
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.BorderSizePixel = 0

            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, PADDING / 2)
            listLayout.FillDirection = Enum.FillDirection.Vertical
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false

                local btn = Instance.new("TextButton")
                btn.Name = name .. "Button"
                btn.Size = UDim2.new(1, -PADDING, 0, BUTTON_HEIGHT - 4) -- Menor que o controle para padding
                btn.BackgroundColor3 = theme.ToggleOff
                btn.TextColor3 = theme.MutedText
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.AutoButtonColor = false
                btn.Parent = dropdownFrame -- Parent para o dropdownFrame

                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2 - 2)

                local function updateBtnVisual()
                    btn.Text = "  " .. name .. ": " .. (states[name] and "ON" or "OFF") -- Adiciona espaço para alinhamento
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.ToggleOn or theme.ToggleOff }):Play()
                    TweenService:Create(btn, TweenInfo.new(0.15), { TextColor3 = states[name] and Color3.new(1,1,1) or theme.MutedText }):Play()
                end
                updateBtnVisual()
                itemButtons[name] = btn

                btn.MouseButton1Click:Connect(function()
                    states[name] = not states[name]
                    updateBtnVisual()
                    if callback then
                        callback(states)
                    end
                end)

                btn.MouseEnter:Connect(function()
                    if not states[name] then
                        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(60,60,60) }):Play()
                    end
                end)
                btn.MouseLeave:Connect(function()
                    if not states[name] then
                        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = theme.ToggleOff }):Play()
                    end
                end)
            end

            local expanded = false

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                header.Text = (expanded and "▾ " or "▸ ") .. title

                if expanded then
                    dropdownFrame.Parent = Page -- Move para a página para que o UIListLayout o gerencie
                    -- Ajusta a altura do dropdownFrame para caber todos os itens
                    local targetHeight = listLayout.AbsoluteContentSize.Y + PADDING
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, targetHeight)
                    }):Play()
                    dropdownFrame.Visible = true
                else
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                    -- Remove o dropdownFrame da hierarquia após a animação
                    task.delay(0.2, function()
                        if not expanded then
                            dropdownFrame.Parent = nil
                            dropdownFrame.Visible = false
                        end
                    end)
                end
            end)

            header.MouseEnter:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(60,60,60) }):Play()
            end)
            header.MouseLeave:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.1), { BackgroundColor3 = theme.ToggleOff }):Play()
            end)

            return {
                Set = function(_, item, value)
                    if states[item] ~= nil then
                        states[item] = value
                        if itemButtons[item] then
                            itemButtons[item].BackgroundColor3 = value and theme.ToggleOn or theme.ToggleOff
                            itemButtons[item].Text = "  " .. item .. ": " .. (value and "ON" or "OFF")
                            itemButtons[item].TextColor3 = value and Color3.new(1,1,1) or theme.MutedText
                        end
                        if callback then
                            callback(states)
                        end
                    end
                end,
                GetAll = function()
                    return states
                end,
                _container = container -- Retorna o container principal para fins de layout
            }
        end

        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT)
            container.BackgroundColor3 = theme.ToggleOff
            container.BorderSizePixel = 0
            container.ClipsDescendants = true

            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.AutoButtonColor = false

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "SelectDropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.BackgroundColor3 = theme.TabContainer
            dropdownFrame.Visible = false
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.BorderSizePixel = 0

            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, PADDING / 2)
            listLayout.FillDirection = Enum.FillDirection.Vertical
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local selectedItem = nil
            local expanded = false

            local function updateHeaderText()
                if selectedItem then
                    header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
                else
                    header.Text = (expanded and "▾ " or "▸ ") .. title
                end
            end

            for _, name in ipairs(items) do
                local btn = Instance.new("TextButton")
                btn.Name = name .. "OptionButton"
                btn.Size = UDim2.new(1, -PADDING, 0, BUTTON_HEIGHT - 4)
                btn.BackgroundColor3 = theme.ToggleOff
                btn.TextColor3 = theme.MutedText
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Text = "  " .. name
                btn.AutoButtonColor = false
                btn.Parent = dropdownFrame

                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, CORNER_RADIUS / 2 - 2)

                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                    task.delay(0.2, function()
                        if not expanded then
                            dropdownFrame.Parent = nil
                            dropdownFrame.Visible = false
                        end
                    end)
                end)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = theme.Hover }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = theme.ToggleOff }):Play()
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                updateHeaderText()

                if expanded then
                    dropdownFrame.Parent = Page
                    local targetHeight = listLayout.AbsoluteContentSize.Y + PADDING
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, targetHeight)
                    }):Play()
                    dropdownFrame.Visible = true
                else
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                    task.delay(0.2, function()
                        if not expanded then
                            dropdownFrame.Parent = nil
                            dropdownFrame.Visible = false
                        end
                    end)
                end
            end)

            header.MouseEnter:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(60,60,60) }):Play()
            end)
            header.MouseLeave:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.1), { BackgroundColor3 = theme.ToggleOff }):Play()
            end)

            return {
                Set = function(_, item)
                    if table.find(items, item) then
                        selectedItem = item
                        updateHeaderText()
                        if callback then
                            callback(selectedItem)
                        end
                    end
                end,
                Get = function()
                    return selectedItem
                end,
                _container = container
            }
        end

        function tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT + 8) -- Aumenta a altura para slider
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.BorderSizePixel = 0

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = theme.Text
            Label.Text = text .. ": " .. tostring(default)
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 8) -- Barra mais fina
            SliderBar.Position = UDim2.new(0, 0, 0, 24) -- Posição abaixo do label
            SliderBar.BackgroundColor3 = theme.ToggleOff
            SliderBar.BorderSizePixel = 0

            local SliderCorner = Instance.new("UICorner", SliderBar)
            SliderCorner.CornerRadius = UDim.new(0, 4)

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0

            local FillCorner = Instance.new("UICorner", SliderFill)
            FillCorner.CornerRadius = UDim.new(0, 4)

            local draggingSlider = false

            local function updateSliderValue(input)
                local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percent)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
                if callback then
                    callback(value)
                end
                return value
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSliderValue(input)
                    input.Handled = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Ajusta para que o slider continue funcionando mesmo se o mouse sair da barra, mas dentro da tela
                    updateSliderValue(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            return {
                Set = function(self, value)
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    if callback then
                        callback(value)
                    end
                end,
                Get = function(self)
                    local size = SliderFill.Size.X.Scale
                    return math.floor(min + (max - min) * size)
                end,
                _instance = SliderFrame
            }
        end

        return tab
    end

    -- Inicializa na primeira aba após a criação de todas
    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
            switchToPage(firstTabName)
            -- Assegura que o visual da primeira aba esteja correto
            local tabButton = TabContainer:FindFirstChildOfClass("TextButton", true) -- Encontra o primeiro botão de aba
            if tabButton then
                TweenService:Create(tabButton, TweenInfo.new(0.2), { BackgroundColor3 = theme.Background, TextColor3 = theme.Text }):Play()
                local stroke = tabButton:FindFirstChildOfClass("UIStroke")
                if stroke then
                     TweenService:Create(stroke, TweenInfo.new(0.2), { Color = theme.Accent }):Play()
                end
            end
        end
    end)()

    return window
end

return Library
