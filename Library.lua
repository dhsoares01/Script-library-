local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Tab = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(60, 60, 60),
    ScrollViewBackground = Color3.fromRGB(20, 20, 20), -- mais escuro para o background do ScrollView
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui -- Define o pai aqui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true -- Essencial para arrastar
    MainFrame.Draggable = false -- Desativa o Draggable nativo do Roblox para implementar o personalizado
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui -- Define o pai aqui

    -- Lógica de arrastar o MainFrame
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            startPos = MainFrame.Position
            -- Impede que outros elementos recebam o evento de input enquanto arrasta
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
    local firstTabName = nil -- Para controlar a primeira aba a ser exibida

    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
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
                pg.Visible = true
                -- Não precisa de tween para BackgroundTransparency se ele já está visível
                -- pg.BackgroundTransparency = 1
                -- TweenService:Create(pg, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
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
        resizeFrame.Active = true -- Essencial para detectar input

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
                -- Os tamanhos de TabContainer e PageContainer são relativos ao MainFrame,
                -- então eles se ajustarão automaticamente.
                -- Nao precisa atualizar o tamanho das paginas, elas ja sao 1,0,1,0
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
            firstTabName = tabName -- Define a primeira aba a ser criada
        end

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

            Button.Text = "  " .. tabName

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
        Page.Visible = false -- Inicia invisível
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundColor3 = theme.ScrollViewBackground -- background mais escuro
        Page.BorderSizePixel = 0

        -- Cantos arredondados para o ScrollView, inclusive canto inferior direito
        local pageCorner = Instance.new("UICorner", Page)
        pageCorner.CornerRadius = UDim.new(0, 8)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            -- Adiciona um pequeno padding ao final do scroll para melhor visualização
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
            Label.TextXAlignment = Enum.TextXAlignment.Left
            return Label
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
            return Btn
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
                _instance = ToggleBtn -- Retorna a instância para acesso direto, se necessário
            }
        end

        function tab:AddDropdownButtonOnOff(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -10, 0, 36)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0

            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, 6)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left

            local dropdownFrame = Instance.new("Frame", Page)
            -- Inicialmente invisível, e o tamanho será ajustado dinamicamente
            dropdownFrame.Size = UDim2.new(1, -10, 0, #items * 32 + 4)
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false

            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, 6)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 4)

            local states = {}
            local itemButtons = {} -- Para fácil acesso aos botões individuais

            for _, name in ipairs(items) do
                states[name] = false

                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -8, 0, 28)
                btn.Position = UDim2.new(0, 4, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left

                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, 6)

                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.Tab }):Play()
                end
                updateBtnVisual()
                itemButtons[name] = btn -- Armazena a referência do botão

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
                -- Ajusta a posição do dropdownframe para aparecer logo abaixo do header
                -- Isso pode ser um pouco complicado com UIListLayout,
                -- uma alternativa seria usar o ZIndex ou organizar os elementos em um layout diferente.
                -- Por simplicidade, vou apenas definir a visibilidade.
            end)

            return {
                Set = function(_, item, value)
                    if states[item] ~= nil then
                        states[item] = value
                        if itemButtons[item] then
                            -- Atualiza visualmente o botão específico
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
    container.Size = UDim2.new(1, -10, 0, 36)
    container.BackgroundColor3 = theme.Tab
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 6)

    local header = Instance.new("TextButton", container)
    header.Size = UDim2.new(1, 0, 1, 0)
    header.BackgroundTransparency = 1
    header.Text = "▸ " .. title  -- Texto inicial
    header.TextColor3 = theme.Text
    header.TextSize = 16
    header.Font = Enum.Font.Gotham
    header.TextXAlignment = Enum.TextXAlignment.Left

    local dropdownFrame = Instance.new("Frame", Page)
    dropdownFrame.Size = UDim2.new(1, -10, 0, #items * 32 + 4)
    dropdownFrame.BackgroundColor3 = theme.Tab
    dropdownFrame.Visible = false

    local dropCorner = Instance.new("UICorner", dropdownFrame)
    dropCorner.CornerRadius = UDim.new(0, 6)

    local listLayout = Instance.new("UIListLayout", dropdownFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)

    local selectedItem = nil
    local expanded = false

    -- Atualiza o texto do header com title: selectedItem
    local function updateHeaderText()
        if selectedItem then
            header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
        else
            header.Text = (expanded and "▾ " or "▸ ") .. title
        end
    end

    for _, name in ipairs(items) do
        local btn = Instance.new("TextButton", dropdownFrame)
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.Position = UDim2.new(0, 4, 0, 0)
        btn.BackgroundColor3 = theme.Tab
        btn.TextColor3 = theme.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = name

        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            selectedItem = name
            expanded = false
            dropdownFrame.Visible = false
            updateHeaderText()
            if callback then
                callback(selectedItem)
            end
        end)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
        end)
    end

    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        dropdownFrame.Visible = expanded
        updateHeaderText()
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
            SliderFrame.Size = UDim2.new(1, -10, 0, 40)
            SliderFrame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = theme.Text
            Label.Text = text .. ": " .. tostring(default)
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
            SliderBar.BackgroundColor3 = theme.Tab
            SliderBar.BorderSizePixel = 0

            local SliderCorner = Instance.new("UICorner", SliderBar)
            SliderCorner.CornerRadius = UDim.new(0, 6)

            local SliderFill = Instance.new("Frame", SliderBar)
            -- Calcula o tamanho inicial da barra de preenchimento
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0

            local FillCorner = Instance.new("UICorner", SliderFill)
            FillCorner.CornerRadius = UDim.new(0, 6)

            local draggingSlider = false -- Variável separada para evitar conflito com dragging do MainFrame

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
                    input.Handled = true -- Consome o input para o slider
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Certifica-se de que o input está sobre a janela do Roblox e não fora
                    if input.Position.X >= SliderBar.AbsolutePosition.X and
                       input.Position.X <= SliderBar.AbsolutePosition.X + SliderBar.AbsoluteSize.X and
                       input.Position.Y >= SliderBar.AbsolutePosition.Y and
                       input.Position.Y <= SliderBar.AbsolutePosition.Y + SliderBar.AbsoluteSize.Y then
                        updateSliderValue(input)
                    else
                        -- Se o mouse sair da barra enquanto arrasta, ainda atualiza
                        -- Mas podemos querer limitar isso ao bounds da tela ou do frame principal
                        updateSliderValue(input)
                    end
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
                _instance = SliderFrame -- Retorna a instância para acesso direto, se necessário
            }
        end

        return tab

    end

    -- Inicializa na primeira aba se existir
    -- Isso deve ser feito APÓS todas as abas terem sido criadas.
    -- Um pequeno delay garante que a GUI esteja renderizada.
    coroutine.wrap(function()
        task.wait(0.1) -- Pequeno delay para garantir que todos os elementos estejam prontos
        if firstTabName ~= nil then
            switchToPage(firstTabName)
        end
    end)()

    return window
end

return Library
