local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Para salvar/carregar configurações (Delta compatível)
local HttpService = game:GetService("HttpService") -- Usado para JSON encoding/decoding

-- Funções auxiliares para sistemas de arquivos (compatível com Delta e outros)
local function writeToFile(fileName, content)
    local success, err
    -- Tenta Roblox's DataStoreService (se disponível e para ambiente normal)
    local DS = game:GetService("DataStoreService"):GetDataStore("CustomMenuConfigs")
    if DS then
        success, err = pcall(function()
            DS:SetAsync(fileName, content)
        end)
        if success then print("Configuração salva via DataStore.") return true end
    end

    -- Fallback para Delta/Synapse (se `syn` for global)
    if typeof(syn) == "table" and syn.write_file then
        success, err = pcall(function()
            syn.write_file(fileName .. ".json", content)
        end)
        if success then print("Configuração salva via syn.write_file.") return true end
    end

    warn("Não foi possível salvar a configuração:", err)
    return false
end

local function readFromFile(fileName)
    local content = nil
    -- Tenta Roblox's DataStoreService
    local DS = game:GetService("DataStoreService"):GetDataStore("CustomMenuConfigs")
    if DS then
        local success, data = pcall(function()
            return DS:GetAsync(fileName)
        end)
        if success and data then
            print("Configuração carregada via DataStore.")
            return data
        end
    end

    -- Fallback para Delta/Synapse
    if typeof(syn) == "table" and syn.read_file then
        local success, data = pcall(function()
            return syn.read_file(fileName .. ".json")
        end)
        if success and data then
            print("Configuração carregada via syn.read_file.")
            return data
        end
    end

    warn("Não foi possível carregar a configuração.")
    return nil
end

-- 1. Refatoração do Tema: Mais opções e clareza
-- Definir o tema padrão
local theme = {
    Background = Color3.fromRGB(30, 30, 30),        -- Fundo principal da janela
    TabBackground = Color3.fromRGB(40, 40, 40),     -- Fundo das abas (barra lateral)
    Accent = Color3.fromRGB(0, 120, 255),           -- Cor de destaque para interações/seleções
    Text = Color3.fromRGB(255, 255, 255),           -- Cor do texto principal
    Stroke = Color3.fromRGB(60, 60, 60),            -- Cor da borda/traço
    ScrollViewBackground = Color3.fromRGB(20, 20, 20), -- Fundo da área de conteúdo (rolagem)
    ButtonBackground = Color3.fromRGB(50, 50, 50),  -- Cor de fundo padrão para botões
    Warning = Color3.fromRGB(255, 60, 60),          -- Para mensagens de erro/perigo (ex: botão de fechar)
    CornerRadius = UDim.new(0, 8),                  -- Raio de canto padrão para elementos maiores
    SmallCornerRadius = UDim.new(0, 6),             -- Raio de canto para elementos menores (botões)
    Padding = 8,                                    -- Preenchimento padrão para layouts
    TabButtonHeight = 34,                           -- Altura padrão para botões de aba
    ControlHeight = 32,                             -- Altura padrão para controles (botões, toggles)
    ControlPadding = 6,                             -- Espaçamento interno para controles
    Opacity = 1 -- Nova propriedade para opacidade
}

-- Armazena o tema atual em uso (pode ser modificado pelas configurações do usuário)
local currentTheme = table.clone(theme)

-- Configurações do usuário, que podem sobrescrever o tema padrão
local userSettings = {
    AccentColor = currentTheme.Accent,
    TextColor = currentTheme.Text,
    BackgroundColor = currentTheme.Background,
    MenuOpacity = currentTheme.Opacity
}

-- Funções auxiliares para criar elementos com estilos padronizados
local function createCorner(parent, radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = radius or currentTheme.CornerRadius
    UICorner.Parent = parent
    return UICorner
end

local function createPadding(parent, allPadding)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, allPadding)
    UIPadding.PaddingRight = UDim.new(0, allPadding)
    UIPadding.PaddingTop = UDim.new(0, allPadding)
    UIPadding.PaddingBottom = UDim.new(0, allPadding)
    UIPadding.Parent = parent
    return UIPadding
end

local function createTextLabel(parent, text, textSize, textColor, font, alignment)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize or 16
    label.TextColor3 = textColor or currentTheme.Text
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function createTextButton(parent, text, callback, bgColor, textColor, font, textSize)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
    button.BackgroundColor3 = bgColor or currentTheme.ButtonBackground
    button.Text = text
    button.TextColor3 = textColor or currentTheme.Text
    button.Font = font or Enum.Font.GothamMedium
    button.TextSize = textSize or 16
    button.AutoButtonColor = false
    button.Parent = parent

    createCorner(button, currentTheme.SmallCornerRadius)

    -- Efeitos de hover padrão
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Accent }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = bgColor or currentTheme.ButtonBackground }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

-- Novo: Função para aplicar o tema (cores e opacidade)
local function applyTheme()
    -- Aplica cores do userSettings
    currentTheme.Accent = userSettings.AccentColor
    currentTheme.Text = userSettings.TextColor
    currentTheme.Background = userSettings.BackgroundColor
    currentTheme.Opacity = userSettings.MenuOpacity

    -- Percorre todos os elementos da UI e aplica as novas cores/opacidade
    -- Isso é um exemplo simplificado. Para uma atualização completa, você precisaria
    -- redefinir as cores de cada elemento ou ter uma referência a eles.
    -- Para este exemplo, vou focar nos principais containers.
    if Library.MainFrame then
        TweenService:Create(Library.MainFrame, TweenInfo.new(0.2), { BackgroundColor3 = currentTheme.Background, BackgroundTransparency = 1 - currentTheme.Opacity }):Play()
        if Library.MainFrame.HeaderFrame then
             TweenService:Create(Library.MainFrame.HeaderFrame, TweenInfo.new(0.2), { BackgroundColor3 = currentTheme.TabBackground, BackgroundTransparency = 1 - currentTheme.Opacity }):Play()
        end
        if Library.MainFrame.TabContainer then
            TweenService:Create(Library.MainFrame.TabContainer, TweenInfo.new(0.2), { BackgroundColor3 = currentTheme.TabBackground, BackgroundTransparency = 1 - currentTheme.Opacity }):Play()
        end
        if Library.MainFrame.PageContainer then
             TweenService:Create(Library.MainFrame.PageContainer, TweenInfo.new(0.2), { BackgroundColor3 = currentTheme.ScrollViewBackground, BackgroundTransparency = 1 - currentTheme.Opacity }):Play()
        end
        if Library.MainFrame.UIStroke then
            TweenService:Create(Library.MainFrame.UIStroke, TweenInfo.new(0.2), { Color = currentTheme.Stroke, Transparency = 1 - currentTheme.Opacity }):Play()
        end

        -- Atualizar texto de todos os labels existentes
        for _, obj in pairs(Library.ScreenGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if obj.TextColor3 ~= currentTheme.Text then -- Evita spam de tween se já for a cor
                    TweenService:Create(obj, TweenInfo.new(0.1), { TextColor3 = currentTheme.Text }):Play()
                end
            end
            -- Para botões, ajustar cores de background se forem as cores padrão ou accent
            if obj:IsA("TextButton") then
                 if obj.BackgroundColor3 == theme.ButtonBackground then -- se for o padrão
                    TweenService:Create(obj, TweenInfo.new(0.1), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
                 elseif obj.BackgroundColor3 == theme.Accent then -- se for o accent
                    TweenService:Create(obj, TweenInfo.new(0.1), { BackgroundColor3 = currentTheme.Accent }):Play()
                 end
            end
        end
    end
end


function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    Library.ScreenGui = ScreenGui -- Armazena a referência para aplicar o tema

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = currentTheme.Background
    MainFrame.BackgroundTransparency = 1 - currentTheme.Opacity -- Aplicar opacidade
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true -- Essencial para arrastar
    MainFrame.Draggable = false -- Desativa o Draggable nativo do Roblox para implementar o personalizado
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Library.MainFrame = MainFrame -- Armazena a referência

    -- 2. Lógica de arrastar o MainFrame melhorada (movido para o cabeçalho)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    -- Frame para a barra superior (onde o título e botão de minimizar ficam)
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Name = "HeaderFrame"
    HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = currentTheme.TabBackground
    HeaderFrame.BackgroundTransparency = 1 - currentTheme.Opacity -- Aplicar opacidade
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Active = true -- Para arrastar pela barra superior
    Library.MainFrame.HeaderFrame = HeaderFrame -- Referência

    createCorner(HeaderFrame, currentTheme.CornerRadius) -- Aplicar canto ao header também (top-left, top-right)

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

    createCorner(MainFrame, currentTheme.CornerRadius)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Name = "UIStroke"
    UIStroke.Color = currentTheme.Stroke
    UIStroke.Thickness = 1
    UIStroke.Transparency = 1 - currentTheme.Opacity -- Aplicar opacidade
    Library.MainFrame.UIStroke = UIStroke -- Referência

    -- Título dentro do HeaderFrame
    local Title = createTextLabel(HeaderFrame, name or "Menu", 20, currentTheme.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    Title.Name = "TitleLabel"
    Title.Size = UDim2.new(1, -50, 1, 0) -- Menor para botão minimizar
    Title.Position = UDim2.new(0, currentTheme.Padding, 0, 0) -- Adiciona padding
    Title.TextYAlignment = Enum.TextYAlignment.Center

    -- Botão minimizar
    local BtnMinimize = createTextButton(HeaderFrame, "–", nil, currentTheme.TabBackground, currentTheme.Text, Enum.Font.GothamBold, 24)
    BtnMinimize.Name = "MinimizeButton"
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -currentTheme.Padding - 30, 0, (HeaderFrame.Size.Y.Offset - 30) / 2) -- Centraliza verticalmente
    createCorner(BtnMinimize, currentTheme.SmallCornerRadius) -- Usa small corner radius
    -- Ajustar hover do botão minimizar para ser mais discreto ou usar Warning color
    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Warning }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.TabBackground }):Play()
    end)

    -- Contêiner de abas e página
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Name = "TabContainer"
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40) -- Tab container agora começa abaixo do header
    TabContainer.BackgroundColor3 = currentTheme.TabBackground
    TabContainer.BackgroundTransparency = 1 - currentTheme.Opacity -- Aplicar opacidade
    TabContainer.ClipsDescendants = true -- Para que o canto arredondado funcione no fundo
    Library.MainFrame.TabContainer = TabContainer -- Referência

    local TabCorner = createCorner(TabContainer, currentTheme.CornerRadius) -- Arredondar canto inferior esquerdo
    -- UIListLayout para as abas
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Name = "TabListLayout"
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, currentTheme.Padding) -- Padding consistente
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    createPadding(TabContainer, currentTheme.Padding / 2) -- Adiciona padding interno ao TabContainer

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Name = "PageContainer"
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = currentTheme.ScrollViewBackground -- Fundo da área de conteúdo
    PageContainer.BackgroundTransparency = 1 - currentTheme.Opacity -- Aplicar opacidade
    PageContainer.ClipsDescendants = true
    Library.MainFrame.PageContainer = PageContainer -- Referência

    createCorner(PageContainer, currentTheme.CornerRadius) -- Arredondar canto inferior direito


    local pages = {}
    local firstTabName = nil
    local activeTabButton = nil -- Para controlar o estado visual da aba ativa

    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 40) }):Play() -- Aumentei um pouco a largura minimizada
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
        end
    end)

    local function switchToPage(name, button)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end

        if activeTabButton then
            TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
        end
        activeTabButton = button
        TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Accent }):Play()
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
        resizeFrame.Name = "ResizeHandle" -- Nome para facilitar a depuração

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

        local Button = createTextButton(TabContainer, "  " .. tabName, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
        Button.Size = UDim2.new(1, -currentTheme.Padding, 0, currentTheme.TabButtonHeight)
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Name = "TabButton_" .. tabName -- Adiciona nome para identificação

        if icon then
            local iconLabel = createTextLabel(Button, icon, 18, currentTheme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, currentTheme.ControlPadding, 0, 0) -- Ícone mais para a esquerda
            iconLabel.Name = "TabIcon_" .. tabName
        end

        -- Ajustar hover dos botões de aba para serem um pouco diferentes ou ter um indicador
        Button.MouseEnter:Connect(function()
            if Button ~= activeTabButton then -- Só faz hover se não for o botão ativo
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }):Play()
            end
        end)
        Button.MouseLeave:Connect(function()
            if Button ~= activeTabButton then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
            end
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name = "Page_" .. tabName -- Nome para identificação
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 6 -- Scrollbar um pouco mais espessa
        Page.BackgroundColor3 = currentTheme.ScrollViewBackground
        Page.BackgroundTransparency = 1 - currentTheme.Opacity -- Aplicar opacidade
        Page.BorderSizePixel = 0
        Page.Active = true -- Para permitir rolagem em si

        createCorner(Page, currentTheme.CornerRadius) -- Cantos arredondados

        local PageListLayout = Instance.new("UIListLayout", Page)
        PageListLayout.Name = "PageListLayout"
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Padding = UDim.new(0, currentTheme.Padding) -- Padding consistente
        PageListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- Centraliza os controles na página

        createPadding(Page, currentTheme.Padding) -- Padding interno para a página

        PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + currentTheme.Padding * 2) -- Adiciona padding no final
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = createTextLabel(Page, text, 16, currentTheme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 24) -- Ajusta tamanho
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, currentTheme.Accent, Color3.new(1,1,1), Enum.Font.GothamMedium, 16)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = createTextButton(Page, text, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            ToggleBtn.TextScaled = false -- Desativar TextScaled para controlar o tamanho do texto

            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
            end
            updateToggleVisual()

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggleVisual()
                if callback then
                    callback(state)
                end
            end)

            -- Ajustar hover do toggle
            ToggleBtn.MouseEnter:Connect(function()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and currentTheme.Accent or Color3.fromRGB(60,60,60) }):Play()
            end)
            ToggleBtn.MouseLeave:Connect(function()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
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
            container.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
            container.BackgroundColor3 = currentTheme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, currentTheme.SmallCornerRadius)

            local header = createTextButton(container, "▸ " .. title, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1 -- Não queremos hover color no header, o container muda

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * (currentTheme.ControlHeight + currentTheme.ControlPadding))
            dropdownFrame.BackgroundColor3 = currentTheme.TabBackground -- Fundo do dropdown
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, currentTheme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, currentTheme.ControlPadding)
            createPadding(dropdownFrame, currentTheme.ControlPadding / 2) -- Padding interno para os itens do dropdown

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false

                local btn = createTextButton(dropdownFrame, name .. ": OFF", nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left

                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
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

                 -- Ajustar hover para itens do dropdown
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and currentTheme.Accent or Color3.fromRGB(60,60,60) }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
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
                        if itemButtons[item] then
                            -- Atualiza visualmente o botão específico
                            itemButtons[item].BackgroundColor3 = value and currentTheme.Accent or currentTheme.ButtonBackground
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
            container.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
            container.BackgroundColor3 = currentTheme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, currentTheme.SmallCornerRadius)

            local header = createTextButton(container, "▸ " .. title, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * (currentTheme.ControlHeight + currentTheme.ControlPadding))
            dropdownFrame.BackgroundColor3 = currentTheme.TabBackground
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, currentTheme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, currentTheme.ControlPadding)
            createPadding(dropdownFrame, currentTheme.ControlPadding / 2)

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
                local btn = createTextButton(dropdownFrame, name, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left

                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                end)

                 -- Ajustar hover para itens do dropdown
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
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
            SliderFrame.Size = UDim2.new(1, 0, 0, 40)
            SliderFrame.BackgroundTransparency = 1

            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), 14, currentTheme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
            SliderBar.BackgroundColor3 = currentTheme.ButtonBackground
            SliderBar.BorderSizePixel = 0
            createCorner(SliderBar, currentTheme.SmallCornerRadius)

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = currentTheme.Accent
            SliderFill.BorderSizePixel = 0
            createCorner(SliderFill, currentTheme.SmallCornerRadius)

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

        function tab:AddColorPicker(text, defaultColor, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
            container.BackgroundColor3 = currentTheme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, currentTheme.SmallCornerRadius)

            local currentColor = defaultColor
            local colorPreview = Instance.new("Frame", container)
            colorPreview.Size = UDim2.new(0, 20, 0, 20)
            colorPreview.Position = UDim2.new(0, currentTheme.Padding, 0, (currentTheme.ControlHeight - 20) / 2)
            colorPreview.BackgroundColor3 = currentColor
            colorPreview.BorderSizePixel = 0
            createCorner(colorPreview, UDim.new(0, 4))

            local label = createTextLabel(container, text, 16, currentTheme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left)
            label.Size = UDim2.new(1, - (2 * currentTheme.Padding + 20), 1, 0)
            label.Position = UDim2.new(0, 2 * currentTheme.Padding + 20, 0, 0)

            container.MouseButton1Click:Connect(function()
                local colorSelected = UserInputService:WaitForColorPicker()
                if colorSelected then
                    currentColor = colorSelected
                    colorPreview.BackgroundColor3 = currentColor
                    if callback then
                        callback(currentColor)
                    end
                end
            end)

            return {
                Set = function(_, color)
                    currentColor = color
                    colorPreview.BackgroundColor3 = currentColor
                    if callback then
                        callback(currentColor)
                    end
                end,
                Get = function()
                    return currentColor
                end
            }
        end

        return tab

    end

    -- Inicializa na primeira aba se existir
    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
            -- Encontra o botão da primeira aba para ativá-lo visualmente
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and string.find(btn.Text, firstTabName) then
                    switchToPage(firstTabName, btn)
                    break
                end
            end
        end
    end)()

    -- **Nova Aba de Customização**
    local CustomizationTab = window:CreateTab("Settings", "⚙")

    CustomizationTab:AddLabel("Visual Settings")

    CustomizationTab:AddColorPicker("Accent Color", userSettings.AccentColor, function(color)
        userSettings.AccentColor = color
        applyTheme()
    end)

    CustomizationTab:AddColorPicker("Text Color", userSettings.TextColor, function(color)
        userSettings.TextColor = color
        applyTheme()
    end)

    CustomizationTab:AddColorPicker("Background Color", userSettings.BackgroundColor, function(color)
        userSettings.BackgroundColor = color
        applyTheme()
    end)

    CustomizationTab:AddSlider("Menu Opacity", 0.1, 1, userSettings.MenuOpacity, function(value)
        userSettings.MenuOpacity = value
        applyTheme()
    end)

    CustomizationTab:AddButton("Save Config", function()
        local configToSave = {
            AccentColor = {R = userSettings.AccentColor.R, G = userSettings.AccentColor.G, B = userSettings.AccentColor.B},
            TextColor = {R = userSettings.TextColor.R, G = userSettings.TextColor.G, B = userSettings.TextColor.B},
            BackgroundColor = {R = userSettings.BackgroundColor.R, G = userSettings.BackgroundColor.G, B = userSettings.BackgroundColor.B},
            MenuOpacity = userSettings.MenuOpacity
        }
        local jsonString = HttpService:JSONEncode(configToSave)
        local success = writeToFile("MenuCustomization", jsonString)
        if success then
            warn("Configurações salvas com sucesso!")
        else
            warn("Falha ao salvar configurações.")
        end
    end)

    CustomizationTab:AddButton("Load Config", function()
        local jsonString = readFromFile("MenuCustomization")
        if jsonString then
            local loadedConfig = HttpService:JSONDecode(jsonString)
            if loadedConfig then
                userSettings.AccentColor = Color3.fromRGB(loadedConfig.AccentColor.R * 255, loadedConfig.AccentColor.G * 255, loadedConfig.AccentColor.B * 255)
                userSettings.TextColor = Color3.fromRGB(loadedConfig.TextColor.R * 255, loadedConfig.TextColor.G * 255, loadedConfig.TextColor.B * 255)
                userSettings.BackgroundColor = Color3.fromRGB(loadedConfig.BackgroundColor.R * 255, loadedConfig.BackgroundColor.G * 255, loadedConfig.BackgroundColor.B * 255)
                userSettings.MenuOpacity = loadedConfig.MenuOpacity

                applyTheme()
                warn("Configurações carregadas com sucesso!")
            else
                warn("Erro ao decodificar configurações.")
            end
        else
            warn("Nenhuma configuração salva encontrada.")
        end
    end)

    -- Carregar configurações na inicialização (se existirem)
    local initialConfig = readFromFile("MenuCustomization")
    if initialConfig then
        local loadedConfig = HttpService:JSONDecode(initialConfig)
        if loadedConfig then
            userSettings.AccentColor = Color3.fromRGB(loadedConfig.AccentColor.R * 255, loadedConfig.AccentColor.G * 255, loadedConfig.AccentColor.B * 255)
            userSettings.TextColor = Color3.fromRGB(loadedConfig.TextColor.R * 255, loadedConfig.TextColor.G * 255, loadedConfig.TextColor.B * 255)
            userSettings.BackgroundColor = Color3.fromRGB(loadedConfig.BackgroundColor.R * 255, loadedConfig.BackgroundColor.G * 255, loadedConfig.BackgroundColor.B * 255)
            userSettings.MenuOpacity = loadedConfig.MenuOpacity
            applyTheme()
        end
    end

    return window
end

return Library

