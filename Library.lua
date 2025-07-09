local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(36, 39, 44), -- Um pouco mais escuro e azulado
    Tab = Color3.fromRGB(44, 47, 53), -- Cor de abas, um pouco mais claro que o background
    Accent = Color3.fromRGB(56, 142, 255), -- Azul mais vibrante
    Text = Color3.fromRGB(220, 220, 220), -- Texto mais claro para contraste
    Stroke = Color3.fromRGB(50, 53, 58), -- Borda mais sutil
    ScrollViewBackground = Color3.fromRGB(30, 33, 38), -- Ainda mais escuro para o ScrollView
    Shadow = Color3.fromRGB(0, 0, 0), -- Cor para sombra
}

-- Função auxiliar para criar cantos arredondados
local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

-- Função auxiliar para criar sombra
local function createShadow(parent, offset, transparency, color, radius)
    local shadow = Instance.new("UIStroke")
    shadow.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    shadow.LineJoinMode = Enum.UIStrokeLineJoinMode.Round
    shadow.Color = color or theme.Shadow
    shadow.Transparency = transparency or 0.6
    shadow.Thickness = 5 -- Ajuste para espessura da sombra
    shadow.Parent = parent

    -- Para simular sombra, usando um UICorner no UIStroke (disponível em versões recentes)
    -- Ou uma abordagem mais robusta com múltiplas UIStrokes ou ImageLabel
    if radius then
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.CornerRadius = UDim.new(0, radius)
        shadowCorner.Parent = shadow
    end
    return shadow
end


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
    MainFrame.Draggable = false
    MainFrame.ClipsDescendants = false -- Permite que a sombra seja visível
    MainFrame.Parent = ScreenGui

    -- Sombra para o MainFrame (simulada com UIStroke com maior espessura e transparência)
    local frameStroke = Instance.new("UIStroke")
    frameStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    frameStroke.LineJoinMode = Enum.UIStrokeLineJoinMode.Round
    frameStroke.Color = theme.Shadow
    frameStroke.Transparency = 0.6 -- Mais transparente
    frameStroke.Thickness = 6 -- Mais espesso para simular sombra
    frameStroke.Parent = MainFrame
    createUICorner(frameStroke, 10) -- Cantos arredondados para a "sombra"

    createUICorner(MainFrame, 10) -- Cantos arredondados para o frame principal

    local UIStrokeBorder = Instance.new("UIStroke", MainFrame)
    UIStrokeBorder.Color = theme.Stroke
    UIStrokeBorder.Thickness = 1
    createUICorner(UIStrokeBorder, 10) -- Cantos arredondados para a borda interna

    -- Lógica de arrastar o MainFrame
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- Verifica se o clique foi na barra de título (ou parte superior do frame)
            if input.Position.Y - MainFrame.AbsolutePosition.Y <= 40 then -- Assumindo 40px de altura para a "barra de título"
                dragging = true
                dragStart = UserInputService:GetMouseLocation()
                startPos = MainFrame.Position
                input.Handled = true
            end
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

    -- Título e Botão Minimizar Container
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 45) -- Altura um pouco maior
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = theme.Background
    HeaderFrame.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", HeaderFrame)
    Title.Size = UDim2.new(1, -70, 1, 0) -- Espaço para o botão
    Title.Position = UDim2.new(0, 35, 0, 0) -- Mais padding à esquerda
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center

    -- Botão minimizar
    local BtnMinimize = Instance.new("TextButton", HeaderFrame)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -40, 0.5, 0)
    BtnMinimize.AnchorPoint = Vector2.new(1, 0.5)
    BtnMinimize.BackgroundColor3 = theme.Tab
    BtnMinimize.Text = "–"
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 24
    BtnMinimize.AutoButtonColor = false
    createUICorner(BtnMinimize, 6)

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
    end)

    -- Contêiner de abas e página
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 45) -- Ajusta para a nova altura do header
    TabContainer.Size = UDim2.new(0, 160, 1, -45) -- Largura da aba um pouco maior
    TabContainer.BackgroundColor3 = theme.Tab

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 160, 0, 45) -- Ajusta para a nova largura da aba e altura do header
    PageContainer.Size = UDim2.new(1, -160, 1, -45)
    PageContainer.BackgroundColor3 = theme.ScrollViewBackground -- Cor de fundo mais escura para o conteúdo
    PageContainer.ClipsDescendants = true

    createUICorner(TabContainer, 8) -- Cantos arredondados para o container de abas
    createUICorner(PageContainer, 8) -- Cantos arredondados para o container de páginas

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8) -- Mais padding entre as abas
    UIList.FillDirection = Enum.FillDirection.Vertical
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.VerticalAlignment = Enum.VerticalAlignment.Top

    local UIPaddingTabs = Instance.new("UIPadding", TabContainer)
    UIPaddingTabs.PaddingLeft = UDim.new(0, 10)
    UIPaddingTabs.PaddingRight = UDim.new(0, 10)
    UIPaddingTabs.PaddingTop = UDim.new(0, 8)
    UIPaddingTabs.PaddingBottom = UDim.new(0, 8)

    local pages = {}
    local firstTabName = nil
    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 160, 0, 45) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
            Title.TextXAlignment = Enum.TextXAlignment.Center -- Centraliza título quando minimizado
            Title.Size = UDim2.new(1, 0, 1, 0)
            Title.Position = UDim2.new(0, 0, 0, 0)
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 580, 0, 400) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Size = UDim2.new(1, -70, 1, 0)
            Title.Position = UDim2.new(0, 35, 0, 0)
        end
    end)

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            if pgName == name then
                pg.Visible = true
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
        resizeFrame.Name = "ResizeHandle"

        local mouseDown = false
        local initialMousePos = Vector2.new()
        local initialFrameSize = UDim2.new()

        resizeFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDown = true
                initialMousePos = UserInputService:GetMouseLocation()
                initialFrameSize = MainFrame.Size
                input.Handled = true
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if mouseDown and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = UserInputService:GetMouseLocation() - initialMousePos

                local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 350, 900)
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 600)

                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDown = false
            end
        end)
    end

    function window:CreateTab(tabName, icon)
        if firstTabName == nil then
            firstTabName = tabName
        end

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, 0, 0, 40) -- Altura um pouco maior
        Button.BackgroundTransparency = 1 -- Inicia transparente
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 17
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.TextYAlignment = Enum.TextYAlignment.Center

        createUICorner(Button, 6) -- Cantos arredondados

        local padding = Instance.new("UIPadding", Button)
        padding.PaddingLeft = UDim.new(0, 10) -- Padding para o texto

        local CurrentHighlight = Instance.new("Frame", Button)
        CurrentHighlight.Size = UDim2.new(0, 4, 1, 0)
        CurrentHighlight.Position = UDim2.new(0, 0, 0, 0)
        CurrentHighlight.BackgroundColor3 = theme.Accent
        CurrentHighlight.Visible = false -- Inicialmente invisível
        createUICorner(CurrentHighlight, 4)

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 10, 0, 0) -- Posição ajustada
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 20 -- Ícone um pouco maior
            iconLabel.TextColor3 = theme.Accent
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center

            Button.Text = "      " .. tabName -- Ajusta o espaçamento
        else
            Button.Text = tabName
        end

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Background }):Play()
        end)
        Button.MouseLeave:Connect(function()
            if Button.BackgroundColor3 ~= theme.Accent then -- Só muda se não for a aba ativa
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.new(0,0,0) }):Play() -- Volta para transparente
            end
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 6 -- Barra de rolagem um pouco mais grossa
        Page.ScrollBarImageColor3 = theme.Accent -- Cor da barra de rolagem
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0

        createUICorner(Page, 8) -- Cantos arredondados para o ScrollView

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10) -- Mais padding entre os elementos da página
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.FillDirection = Enum.FillDirection.Vertical

        local UIPaddingPage = Instance.new("UIPadding", Page)
        UIPaddingPage.PaddingLeft = UDim.new(0, 10)
        UIPaddingPage.PaddingRight = UDim.new(0, 10)
        UIPaddingPage.PaddingTop = UDim.new(0, 10)
        UIPaddingPage.PaddingBottom = UDim.new(0, 10)


        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20) -- Mais padding no final
        end)

        pages[tabName] = Page

        local function setActiveTab()
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn == Button then
                        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
                        btn.TextColor3 = Color3.new(1,1,1) -- Texto branco para aba ativa
                        if btn:FindFirstChild("CurrentHighlight") then
                            btn.CurrentHighlight.Visible = true
                        end
                    else
                        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.new(0,0,0) }):Play() -- Volta para transparente
                        btn.TextColor3 = theme.Text
                        if btn:FindFirstChild("CurrentHighlight") then
                            btn.CurrentHighlight.Visible = false
                        end
                    end
                end
            end
            switchToPage(tabName)
        end

        Button.MouseButton1Click:Connect(setActiveTab)

        local tab = {}

        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, 0, 0, 24) -- Largura total, ajustado
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextYAlignment = Enum.TextYAlignment.Center
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, 0, 0, 36) -- Altura um pouco maior
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 16

            createUICorner(Btn, 8)

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play() -- Efeito de hover
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
            end)

            Btn.MouseButton1Click:Connect(callback)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16

            createUICorner(ToggleBtn, 8)

            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.Tab }):Play()
            end
            updateToggleVisual()

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggleVisual()
                if callback then
                    callback(state)
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
            container.Size = UDim2.new(1, 0, 0, 36)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0
            container.ClipsDescendants = true -- Para garantir que os itens do dropdown fiquem dentro

            createUICorner(container, 8)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center

            local paddingHeader = Instance.new("UIPadding", header)
            paddingHeader.PaddingLeft = UDim.new(0, 10)

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0) -- Altura inicial 0
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false
            dropdownFrame.ClipsDescendants = true

            createUICorner(dropdownFrame, 8)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 2) -- Menos padding entre os itens do dropdown
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.FillDirection = Enum.FillDirection.Vertical

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false

                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -10, 0, 30) -- Itens um pouco menores
                btn.Position = UDim2.new(0, 5, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left

                createUICorner(btn, 6)

                local paddingBtn = Instance.new("UIPadding", btn)
                paddingBtn.PaddingLeft = UDim.new(0, 10)

                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.Tab }):Play()
                end
                updateBtnVisual()
                itemButtons[name] = btn

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = states[name] and theme.Accent or theme.Tab }):Play()
                end)

                btn.MouseButton1Click:Connect(function()
                    states[name] = not states[name]
                    updateBtnVisual()
                    if callback then
                        callback(states)
                    end
                end)
            end

            local expanded = false

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                header.Text = (expanded and "▾ " or "▸ ") .. title

                local targetHeight = expanded and (#items * 32 + 4) or 0 -- Altura total dos itens + padding
                TweenService:Create(dropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, targetHeight) }):Play()

                -- Ajustar CanvasSize da página para acomodar o dropdown
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
            end)

            return {
                Set = function(_, item, value)
                    if states[item] ~= nil then
                        states[item] = value
                        if itemButtons[item] then
                            itemButtons[item].BackgroundColor3 = value and theme.Accent or theme.Tab
                            itemButtons[item].Text = item .. ": " .. (value and "ON" or "OFF")
                        end
                        if callback then
                            callback(states)
                        end
                    end
                end,
                GetAll = function()
                    return states
                end
            }
        end

        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, 36)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0
            container.ClipsDescendants = true

            createUICorner(container, 8)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center

            local paddingHeader = Instance.new("UIPadding", header)
            paddingHeader.PaddingLeft = UDim.new(0, 10)

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0) -- Altura inicial 0
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false
            dropdownFrame.ClipsDescendants = true

            createUICorner(dropdownFrame, 8)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 2)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.FillDirection = Enum.FillDirection.Vertical

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
                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.Position = UDim2.new(0, 5, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Text = name

                createUICorner(btn, 6)

                local paddingBtn = Instance.new("UIPadding", btn)
                paddingBtn.PaddingLeft = UDim.new(0, 10)

                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()
                    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
                end)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = theme.Tab }):Play()
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                updateHeaderText()
                local targetHeight = expanded and (#items * 32 + 4) or 0
                TweenService:Create(dropdownFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, targetHeight) }):Play()
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
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
                end
            }
        end

        function tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 50) -- Altura um pouco maior para o slider
            SliderFrame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size = UDim2.new(1, 0, 0, 20) -- Ajuste de altura
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 16
            Label.TextColor3 = theme.Text
            Label.Text = text .. ": " .. tostring(default)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextYAlignment = Enum.TextYAlignment.Center

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 10) -- Barra mais fina
            SliderBar.Position = UDim2.new(0, 0, 0, 28) -- Posição ajustada
            SliderBar.BackgroundColor3 = theme.Tab
            SliderBar.BorderSizePixel = 0
            createUICorner(SliderBar, 5)

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0
            createUICorner(SliderFill, 5)

            local draggingSlider = false

            local function updateSliderValue(input)
                local mouseX = UserInputService:GetMouseLocation().X
                local relativeX = math.clamp(mouseX - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percent)

                -- Arredonda para 2 casas decimais para floats, mas mantém inteiro se for o caso
                if min % 1 == 0 and max % 1 == 0 and default % 1 == 0 then
                    value = math.floor(value)
                else
                    value = math.round((min + (max - min) * percent) * 100) / 100
                end


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

    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
            -- Encontra o botão da primeira aba e simula um clique para ativá-lo
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn.Text:match(firstTabName) then
                    btn.MouseButton1Click:Fire()
                    break
                end
            end
        end
    end)()

    return window
end

return Library

