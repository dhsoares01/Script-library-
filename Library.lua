local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- Adicionado para renderização

local theme = {
    Background = Color3.fromRGB(25, 25, 25), -- Fundo principal mais escuro
    Tab = Color3.fromRGB(35, 35, 35),       -- Fundo das abas
    Accent = Color3.fromRGB(0, 150, 255),    -- Azul vibrante para destaque
    AccentHover = Color3.fromRGB(0, 180, 255), -- Azul mais claro para hover
    Text = Color3.fromRGB(230, 230, 230),    -- Texto quase branco
    Stroke = Color3.fromRGB(50, 50, 50),     -- Borda sutil
    ScrollViewBackground = Color3.fromRGB(20, 20, 20), -- Fundo do scrollview
    -- Nova cor para elementos interativos em estado normal (não selecionado/hover)
    InteractiveNormal = Color3.fromRGB(45, 45, 45),
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = false -- Desabilitar draggable padrão para usar o customizado
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10) -- Cantos mais arredondados

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.5 -- Bordas mais suaves

    -- Suporte a arrastar com toque e mouse (customizado para o MainFrame)
    local dragging = false
    local dragStartOffset = Vector2.new()

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local success, minX = pcall(function() return MainFrame.AbsolutePosition.X end)
            if not success then return end -- Evita erros se AbsolutePosition ainda não estiver disponível

            -- Apenas arraste a partir da área do título ou superior
            if input.Position.Y - MainFrame.AbsolutePosition.Y <= 40 then -- Altura da barra de título
                dragging = true
                dragStartOffset = input.Position - MainFrame.AbsolutePosition
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MainFrame.Position = UDim2.new(0, input.Position.X - dragStartOffset.X, 0, input.Position.Y - dragStartOffset.Y)
        end
    end)

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -50, 0, 40) -- Espaço para botão minimizar e padding
    Title.Position = UDim2.new(0, 15, 0, 0) -- Padding esquerdo
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextWrapped = true -- Garante que o texto se ajuste se for muito longo

    -- Botão Minimizar/Maximizar
    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -40, 0, 8) -- Posicionado mais internamente
    BtnMinimize.BackgroundColor3 = theme.InteractiveNormal
    BtnMinimize.Text = "—" -- Traço de minimizar
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 20
    BtnMinimize.AutoButtonColor = false
    BtnMinimize.ZIndex = 2 -- Garante que esteja acima de outros elementos

    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(0, 6)

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.InteractiveNormal }):Play()
    end)

    -- Contêiner de abas
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 140, 1, -40) -- Largura ligeiramente maior
    TabContainer.BackgroundColor3 = theme.Tab
    TabContainer.BorderSizePixel = 0

    local TabContainerCorner = Instance.new("UICorner", TabContainer)
    TabContainerCorner.CornerRadius = UDim.new(0, 10) -- Consistente com o MainFrame
    TabContainerCorner.CornerRounding = Enum.RoundingScheme.CellOnly -- Aplica apenas aos cantos da célula

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8) -- Mais espaçamento entre as abas
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Contêiner da página
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 140, 0, 40)
    PageContainer.Size = UDim2.new(1, -140, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true
    PageContainer.BorderSizePixel = 0 -- Remove a borda

    local PageContainerCorner = Instance.new("UICorner", PageContainer)
    PageContainerCorner.CornerRadius = UDim.new(0, 10)
    PageContainerCorner.CornerRounding = Enum.RoundingScheme.CellOnly

    local pages = {}
    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 140, 0, 50) }):Play() -- Altura um pouco maior
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
            Title.Size = UDim2.new(1, -50, 0, 40)
            Title.Position = UDim2.new(0, 15, 0, 0)
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            -- Esperar o tween terminar para tornar visível
            RunService.Stepped:Wait() -- Pequeno atraso para o tween começar
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "—"
            Title.Size = UDim2.new(1, -50, 0, 40)
            Title.Position = UDim2.new(0, 15, 0, 0)
        end
    end)

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            if pgName == name then
                pg.Visible = true
                -- Animação de fade-in para a página
                pg.BackgroundTransparency = 1
                TweenService:Create(pg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
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

                local newWidth = math.clamp(MainFrame.AbsoluteSize.X + delta.X, 380, 900) -- Largura mínima ajustada
                local newHeight = math.clamp(MainFrame.AbsoluteSize.Y + delta.Y, 250, 600) -- Altura mínima ajustada

                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)      
                TabContainer.Size = UDim2.new(0, 140, 1, -40) -- Largura fixa da aba
                PageContainer.Size = UDim2.new(1, -140, 1, -40) -- Ajusta o tamanho da página

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
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -16, 0, 40) -- Botões de abas maiores
        Button.Position = UDim2.new(0, 8, 0, 0) -- Padding para os lados
        Button.BackgroundColor3 = theme.InteractiveNormal
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 18
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Parent = TabContainer

        local btnCorner = Instance.new("UICorner", Button)      
        btnCorner.CornerRadius = UDim.new(0, 8) -- Cantos mais arredondados para botões

        if icon then      
            local iconLabel = Instance.new("TextLabel", Button)      
            iconLabel.Text = icon      
            iconLabel.Size = UDim2.new(0, 28, 1, 0)      
            iconLabel.Position = UDim2.new(0, 8, 0, 0)      
            iconLabel.BackgroundTransparency = 1      
            iconLabel.Font = Enum.Font.GothamBold      
            iconLabel.TextSize = 20      
            iconLabel.TextColor3 = theme.Accent      
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center      
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center      

            Button.Text = "   " .. tabName      
        else      
            Button.Text = tabName      
        end      

        Button.MouseEnter:Connect(function()      
            TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundColor3 = theme.AccentHover }):Play()      
        end)      
        Button.MouseLeave:Connect(function()      
            TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundColor3 = theme.InteractiveNormal }):Play()      
        end)      

        local Page = Instance.new("ScrollingFrame")      
        Page.Visible = false      
        Page.Size = UDim2.new(1, -10, 1, -10) -- Reduzido para permitir padding dentro do PageContainer
        Page.Position = UDim2.new(0, 5, 0, 5) -- Adicionado padding
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)      
        Page.ScrollBarThickness = 6      
        Page.BackgroundColor3 = theme.ScrollViewBackground -- background mais escuro      
        Page.BorderSizePixel = 0      
        Page.BottomImage = "" -- Remover imagens padrão da scrollbar
        Page.TopImage = ""
        Page.MidImage = ""
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always -- Garante que a scrollbar apareça

        local pageCorner = Instance.new("UICorner", Page)      
        pageCorner.CornerRadius = UDim.new(0, 8)      
        pageCorner.Parent = Page -- Apenas um canto arredondado

        local Layout = Instance.new("UIListLayout", Page)      
        Layout.SortOrder = Enum.SortOrder.LayoutOrder      
        Layout.Padding = UDim.new(0, 10) -- Mais espaçamento vertical
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.VerticalAlignment = Enum.VerticalAlignment.Top

        -- Adiciona um UIPadding para espaçamento interno
        local UIPadding = Instance.new("UIPadding", Page)
        UIPadding.PaddingTop = UDim.new(0, 10)
        UIPadding.PaddingBottom = UDim.new(0, 10)
        UIPadding.PaddingLeft = UDim.new(0, 10)
        UIPadding.PaddingRight = UDim.new(0, 10)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()      
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20) -- Adicionado padding extra
        end)      

        Page.Parent = PageContainer -- Mover para cá para garantir que o PageContainer gerencie

        pages[tabName] = Page      

        Button.MouseButton1Click:Connect(function()      
            switchToPage(tabName)      
        end)      

        local tab = {}      

        function tab:AddLabel(text)      
            local Label = Instance.new("TextLabel", Page)      
            Label.Size = UDim2.new(1, -20, 0, 24) -- Largura com padding
            Label.BackgroundTransparency = 1      
            Label.Text = text      
            Label.TextColor3 = theme.Text      
            Label.Font = Enum.Font.Gotham      
            Label.TextSize = 16      
            Label.TextXAlignment = Enum.TextXAlignment.Left      
            Label.TextWrapped = true
            return Label
        end      

        function tab:AddButton(text, callback)      
            local Btn = Instance.new("TextButton", Page)      
            Btn.Size = UDim2.new(1, -20, 0, 36) -- Botões maiores
            Btn.BackgroundColor3 = theme.Accent      
            Btn.Text = text      
            Btn.TextColor3 = Color3.new(1,1,1)      
            Btn.Font = Enum.Font.GothamMedium      
            Btn.TextSize = 17      
            Btn.AutoButtonColor = false

            local corner = Instance.new("UICorner", Btn)      
            corner.CornerRadius = UDim.new(0, 8)      

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.AccentHover }):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
            end)

            Btn.MouseButton1Click:Connect(callback)      
            return Btn
        end      

        function tab:AddToggle(text, callback)      
            local ToggleBtn = Instance.new("TextButton", Page)      
            ToggleBtn.Size = UDim2.new(1, -20, 0, 36)      
            ToggleBtn.BackgroundColor3 = theme.InteractiveNormal      
            ToggleBtn.TextColor3 = theme.Text      
            ToggleBtn.Font = Enum.Font.GothamMedium      
            ToggleBtn.TextSize = 17      
            ToggleBtn.AutoButtonColor = false

            local corner = Instance.new("UICorner", ToggleBtn)      
            corner.CornerRadius = UDim.new(0, 8)      

            local state = false      
            local function update()      
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")      
                ToggleBtn.BackgroundColor3 = state and theme.Accent or theme.InteractiveNormal
            end      
            update()      

            ToggleBtn.MouseButton1Click:Connect(function()      
                state = not state      
                update()      
                if callback then      
                    callback(state)      
                end      
            end)      

            return {      
                Set = function(_, value)      
                    state = value      
                    update()      
                end,      
                Get = function()      
                    return state      
                end,      
            }      
        end      

        function tab:AddDropdownButtonOnOff(title, items, callback)  
            local container = Instance.new("Frame", Page)  
            container.Size = UDim2.new(1, -20, 0, 40) -- Altura maior para o header
            container.BackgroundColor3 = theme.InteractiveNormal  
            container.BorderSizePixel = 0  

            local corner = Instance.new("UICorner", container)  
            corner.CornerRadius = UDim.new(0, 8)  

            local header = Instance.new("TextButton", container)  
            header.Size = UDim2.new(1, 0, 1, 0)  
            header.BackgroundTransparency = 1  
            header.Text = "▸ " .. title  
            header.TextColor3 = theme.Text  
            header.TextSize = 17  
            header.Font = Enum.Font.GothamMedium  
            header.TextXAlignment = Enum.TextXAlignment.Left  
            header.AutoButtonColor = false

            -- Hover effect para o header
            header.MouseEnter:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.15), { TextColor3 = theme.Accent }):Play()
            end)
            header.MouseLeave:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.15), { TextColor3 = theme.Text }):Play()
            end)

            local dropdownFrame = Instance.new("Frame", Page)  
            dropdownFrame.Size = UDim2.new(1, -20, 0, #items * 36 + 8) -- Altura ajustada
            dropdownFrame.BackgroundColor3 = theme.Tab  
            dropdownFrame.Visible = false  
            dropdownFrame.ClipsDescendants = true -- Garante que os itens não escapem

            local dropCorner = Instance.new("UICorner", dropdownFrame)  
            dropCorner.CornerRadius = UDim.new(0, 8)  

            local listLayout = Instance.new("UIListLayout", dropdownFrame)  
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder  
            listLayout.Padding = UDim.new(0, 6)  
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local dropdownPadding = Instance.new("UIPadding", dropdownFrame)
            dropdownPadding.PaddingTop = UDim.new(0, 4)
            dropdownPadding.PaddingBottom = UDim.new(0, 4)

            local states = {}  

            for _, name in ipairs(items) do  
                states[name] = false  

                local btn = Instance.new("TextButton", dropdownFrame)  
                btn.Size = UDim2.new(1, -12, 0, 32) -- Tamanho do item do dropdown
                btn.Position = UDim2.new(0, 6, 0, 0) -- Padding interno
                btn.BackgroundColor3 = theme.Tab  
                btn.TextColor3 = theme.Text  
                btn.Font = Enum.Font.Gotham  
                btn.TextSize = 15  
                btn.TextXAlignment = Enum.TextXAlignment.Left  
                btn.AutoButtonColor = false

                local btnCorner = Instance.new("UICorner", btn)  
                btnCorner.CornerRadius = UDim.new(0, 6)  

                local function updateBtn()  
                    btn.Text = "  " .. name .. ": " .. (states[name] and "ON" or "OFF") -- Mais padding
                    btn.BackgroundColor3 = states[name] and theme.Accent or theme.Tab  
                end  
                updateBtn()  

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = states[name] and theme.AccentHover or Color3.fromRGB(55, 55, 55) }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = states[name] and theme.Accent or theme.Tab }):Play()
                end)

                btn.MouseButton1Click:Connect(function()  
                    states[name] = not states[name]  
                    updateBtn()  
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
            end)  

            return {  
                Set = function(_, item, value)  
                    if states[item] ~= nil then  
                        states[item] = value  
                        for _, child in pairs(dropdownFrame:GetChildren()) do  
                            if child:IsA("TextButton") and child.Text:find(item) then  
                                child.BackgroundColor3 = value and theme.Accent or theme.Tab  
                                child.Text = "  " .. item .. ": " .. (value and "ON" or "OFF")  
                            end  
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

        function tab:AddSlider(text, min, max, default, callback)      
            local SliderFrame = Instance.new("Frame", Page)      
            SliderFrame.Size = UDim2.new(1, -20, 0, 50) -- Altura maior para o slider
            SliderFrame.BackgroundTransparency = 1      

            local Label = Instance.new("TextLabel", SliderFrame)      
            Label.Size = UDim2.new(1, 0, 0, 18)      
            Label.Position = UDim2.new(0, 0, 0, 0)      
            Label.BackgroundTransparency = 1      
            Label.Font = Enum.Font.Gotham      
            Label.TextSize = 15      
            Label.TextColor3 = theme.Text      
            Label.Text = text .. ": " .. tostring(default)      
            Label.TextXAlignment = Enum.TextXAlignment.Left      

            local SliderBar = Instance.new("Frame", SliderFrame)      
            SliderBar.Size = UDim2.new(1, 0, 0, 14) -- Barra mais espessa
            SliderBar.Position = UDim2.new(0, 0, 0, 28)      
            SliderBar.BackgroundColor3 = theme.InteractiveNormal      
            SliderBar.BorderSizePixel = 0      

            local SliderCorner = Instance.new("UICorner", SliderBar)      
            SliderCorner.CornerRadius = UDim.new(0, 7)      

            local SliderFill = Instance.new("Frame", SliderBar)      
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)      
            SliderFill.BackgroundColor3 = theme.Accent      
            SliderFill.BorderSizePixel = 0      

            local FillCorner = Instance.new("UICorner", SliderFill)      
            FillCorner.CornerRadius = UDim.new(0, 7)      

            local dragging = false      

            local function updateValue(input)      
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
                    dragging = true      
                    updateValue(input)      
                end      
            end)      

            SliderBar.InputChanged:Connect(function(input)      
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then      
                    updateValue(input)      
                end      
            end)      

            UserInputService.InputEnded:Connect(function(input)      
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then      
                    dragging = false      
                end      
            end)      

            return {      
                Set = function(_, value)      
                    local percent = math.clamp((value - min) / (max - min), 0, 1)      
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)      
                    Label.Text = text .. ": " .. tostring(value)      
                    if callback then      
                        callback(value)      
                    end      
                end,      
                Get = function()      
                    local size = SliderFill.Size.X.Scale      
                    return math.floor(min + (max - min) * size)      
                end,      
            }      
        end      

        return tab

    end

    -- Inicializa na primeira aba se existir
    coroutine.wrap(function()
        -- Wait for the UI to be fully rendered before trying to switch
        RunService.Heartbeat:Wait()
        local firstTabName = nil
        for tabName, _ in pairs(pages) do
            firstTabName = tabName
            break
        end
        if firstTabName then
            switchToPage(firstTabName)
        end
    end)()

    return window

end

return Library
