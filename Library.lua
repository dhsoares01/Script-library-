--[[
  Biblioteca de Menu Customizável com Suporte a Configurações:
  - Permite definir cor, opacidade, salvar/carregar configurações locais (LocalPlayer).
  - Compatível com uso via loadstring (ex: executores Delta, etc).
  - Inclui controles para cor e opacidade do menu.
  - Exemplo de uso para integração com botões de "Salvar" e "Carregar" configs.
--]]

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Nome do arquivo de configuração
local CONFIG_FILENAME = "menu_config.json"

-- Salvar arquivo (Delta, Synapse, etc) - auto detect
local function writeConfigFile(filename, content)
    if pcall(function() writefile(filename, content) end) then
        return true
    elseif (isfile and not isfile(filename)) or (readfile and not pcall(readfile, filename)) then
        -- Fallback for specific executors if writefile direct fails but others exist
        return pcall(function() writefile(filename, content) end)
    elseif savefile then -- Synapse X legacy
        return pcall(function() savefile(filename, content) end)
    end
    warn("Não foi possível encontrar uma função de escrita de arquivo (writefile/savefile).")
    return false
end

local function readConfigFile(filename)
    local content = nil
    if pcall(function() content = readfile(filename) end) then
        return content
    elseif isfile and isfile(filename) then
        return pcall(function() content = readfile(filename) end) and content
    elseif loadfile then -- Not ideal for configs, but kept for compatibility if it returns string
        local success, result = pcall(function() return loadfile(filename) end)
        if success and typeof(result) == "string" then return result end
    end
    warn("Não foi possível encontrar uma função de leitura de arquivo (readfile/loadfile).")
    return nil
end

-- 1. Refatoração do Tema: Mais opções e clareza
local theme = {
    Background = Color3.fromRGB(30, 30, 30),
    TabBackground = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(60, 60, 60),
    ScrollViewBackground = Color3.fromRGB(20, 20, 20),
    ButtonBackground = Color3.fromRGB(50, 50, 50),
    Warning = Color3.fromRGB(255, 60, 60),
    CornerRadius = UDim.new(0, 8),
    SmallCornerRadius = UDim.new(0, 6),
    Padding = 8,
    TabButtonHeight = 34,
    ControlHeight = 32,
    ControlPadding = 6,
    Opacity = 1, -- Novo: opacidade global do menu.
}

local themeConfigKeys = {"Background", "TabBackground", "Accent", "Text", "Stroke", "ScrollViewBackground", "ButtonBackground", "Warning", "Opacity"}

-- Função para aplicar opacidade a todos os descendentes do frame principal
local function setMenuOpacity(mainFrame, opacity)
    local function applyToDescendants(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("ScrollingFrame") then
            -- Ajusta a BackgroundTransparency. 1 - opacity porque 0 é opaco e 1 é transparente
            obj.BackgroundTransparency = 1 - opacity
        end
        for _, child in ipairs(obj:GetChildren()) do
            applyToDescendants(child)
        end
    end
    applyToDescendants(mainFrame)
end

-- Função para criar UICorner
local function createCorner(parent, radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = radius or theme.CornerRadius
    UICorner.Parent = parent
    return UICorner
end

-- Função para criar UIPadding
local function createPadding(parent, allPadding)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, allPadding)
    UIPadding.PaddingRight = UDim.new(0, allPadding)
    UIPadding.PaddingTop = UDim.new(0, allPadding)
    UIPadding.PaddingBottom = UDim.new(0, allPadding)
    UIPadding.Parent = parent
    return UIPadding
end

-- Função para criar TextLabel
local function createTextLabel(parent, text, textSize, textColor, font, alignment)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize or 16
    label.TextColor3 = textColor or theme.Text
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

-- Função para criar TextButton com efeitos de hover
local function createTextButton(parent, text, callback, bgColor, textColor, font, textSize)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
    button.BackgroundColor3 = bgColor or theme.ButtonBackground
    button.Text = text
    button.TextColor3 = textColor or theme.Text
    button.Font = font or Enum.Font.GothamMedium
    button.TextSize = textSize or 16
    button.AutoButtonColor = false
    button.Parent = parent

    createCorner(button, theme.SmallCornerRadius)

    -- Efeitos de hover
    local defaultBgColor = bgColor or theme.ButtonBackground
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = defaultBgColor }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

-- CUSTOMIZAÇÃO: Cria controles extras de customização no menu de opções/config
local function createCustomizationTab(windowInstance, mainFrame, applyThemeCallback)
    local tab = windowInstance:CreateTab("Config", "⚙️")

    tab:AddLabel("Cor de Fundo do Menu")
    local bgPicker = tab:AddSelectDropdown("Cor", {"Padrão", "Vermelho", "Verde", "Azul", "Rosa", "Amarelo"}, function(opt)
        local colors = {
            ["Padrão"] = Color3.fromRGB(30, 30, 30),
            ["Vermelho"] = Color3.fromRGB(120, 30, 30),
            ["Verde"] = Color3.fromRGB(30, 120, 30),
            ["Azul"] = Color3.fromRGB(30, 30, 120),
            ["Rosa"] = Color3.fromRGB(120, 30, 80),
            ["Amarelo"] = Color3.fromRGB(120, 120, 30),
        }
        theme.Background = colors[opt] or theme.Background
        if applyThemeCallback then applyThemeCallback() end
    end)

    tab:AddLabel("Opacidade do Menu")
    local sliderOpacity = tab:AddSlider("Opacidade", 30, 100, math.floor(theme.Opacity * 100), function(val)
        theme.Opacity = val / 100
        setMenuOpacity(mainFrame, theme.Opacity)
    end)

    tab:AddButton("Salvar Configuração", function()
        local config = {}
        for _, k in ipairs(themeConfigKeys) do
            local v = theme[k]
            if typeof(v) == "Color3" then
                config[k] = {v.R, v.G, v.B}
            else
                config[k] = v
            end
        end
        writeConfigFile(CONFIG_FILENAME, HttpService:JSONEncode(config))
        print("Configuração salva.")
    end)

    tab:AddButton("Carregar Configuração", function()
        local data = readConfigFile(CONFIG_FILENAME)
        if data then
            local ok, config = pcall(function() return HttpService:JSONDecode(data) end)
            if ok and typeof(config) == "table" then
                for _, k in ipairs(themeConfigKeys) do
                    if config[k] ~= nil then
                        if typeof(theme[k]) == "Color3" and typeof(config[k]) == "table" and #config[k] == 3 then
                            theme[k] = Color3.new(unpack(config[k]))
                        elseif k == "Opacity" then
                            theme[k] = tonumber(config[k]) or theme[k]
                        end
                    end
                end
                if applyThemeCallback then applyThemeCallback() end
                setMenuOpacity(mainFrame, theme.Opacity)
                print("Configuração carregada.")
            else
                warn("Erro ao decodificar JSON da configuração ou formato inválido.")
            end
        else
            warn("Nenhuma configuração encontrada para carregar.")
        end
    end)
end

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = false -- Desabilitado para implementar arrastar customizado
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Opacidade inicial
    setMenuOpacity(MainFrame, theme.Opacity)

    -- Atualizar temas dos frames após customização
    local function applyTheme()
        MainFrame.BackgroundColor3 = theme.Background
        -- Aplica o tema a elementos existentes que podem mudar de cor
        -- Isso pode ser expandido para todos os controles se necessário
        -- Para simplicidade, vamos re-aplicar a opacidade global
        setMenuOpacity(MainFrame, theme.Opacity)
    end

    -- Lógica de arrastar o MainFrame
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    local dragInputBeganConn
    dragInputBeganConn = MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            startPos = MainFrame.Position
            input.Handled = true
        end
    end)

    local dragInputChangedConn
    dragInputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local dragInputEndedConn
    dragInputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    createCorner(MainFrame, theme.CornerRadius)

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
    Title.ZIndex = 2 -- Garante que o título esteja acima de outros elementos se houver sobreposição

    -- Botão minimizar
    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -40, 0, 5)
    BtnMinimize.BackgroundColor3 = theme.TabBackground -- Usar TabBackground para consistência
    BtnMinimize.Text = "–" -- traço de minimizar
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 24
    BtnMinimize.AutoButtonColor = false
    BtnMinimize.ZIndex = 2

    createCorner(BtnMinimize, UDim.new(0, 6))

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
    end)

    -- Contêiner de abas e página
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.BackgroundColor3 = theme.TabBackground

    createCorner(TabContainer, UDim.new(0, 6)) -- Cantos arredondados para TabContainer

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)
    UIList.FillDirection = Enum.FillDirection.Vertical
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pages = {}
    local firstTabName = nil
    local currentActiveTabButton = nil -- Para gerenciar o estado visual do botão de aba

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
            -- Desconecta os eventos de arrastar e redimensionar quando minimizado
            dragInputBeganConn:Disconnect()
            dragInputChangedConn:Disconnect()
            dragInputEndedConn:Disconnect()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            -- Reconecta os eventos de arrastar e redimensionar
            dragInputBeganConn = MainFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = UserInputService:GetMouseLocation()
                    startPos = MainFrame.Position
                    input.Handled = true
                end
            end)
            dragInputChangedConn = UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = UserInputService:GetMouseLocation() - dragStart
                    MainFrame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)
            dragInputEndedConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(1, -40, 0, 40)
            -- Garante que a opacidade seja re-aplicada
            setMenuOpacity(MainFrame, theme.Opacity)
        end
    end)

    local function switchToPage(name, button)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
            if pgName == name then
                setMenuOpacity(pg, theme.Opacity) -- Garante que a página ativa tenha a opacidade correta
            end
        end

        -- Atualiza o estado visual dos botões de aba
        if currentActiveTabButton then
            TweenService:Create(currentActiveTabButton, TweenInfo.new(0.2), { BackgroundColor3 = theme.TabBackground }):Play()
        end
        if button then
            TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
            currentActiveTabButton = button
        end
    end

    local window = {}

    -- Redimensionar menu (borda direita-inferior)
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10 -- Garante que esteja acima de outros elementos
        resizeFrame.Active = true
        resizeFrame.Draggable = false -- Desabilitado para arrastar customizado

        local mouseDownResize = false
        local initialMousePos = Vector2.new()
        local initialFrameSize = UDim2.new()

        resizeFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDownResize = true
                initialMousePos = UserInputService:GetMouseLocation()
                initialFrameSize = MainFrame.Size
                input.Handled = true
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if mouseDownResize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = UserInputService:GetMouseLocation() - initialMousePos

                local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 350, 900)
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 600)

                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDownResize = false
            end
        end)
    end

    function window:CreateTab(tabName, icon)
        if firstTabName == nil then
            firstTabName = tabName
        end

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -12, 0, theme.TabButtonHeight) -- Ajuste de padding
        Button.Position = UDim2.new(0, 6, 0, 0) -- Ajuste de padding
        Button.BackgroundColor3 = theme.TabBackground
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        createCorner(Button, UDim.new(0, 6))

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
            if currentActiveTabButton ~= Button then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
            end
        end)
        Button.MouseLeave:Connect(function()
            if currentActiveTabButton ~= Button then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.TabBackground }):Play()
            end
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 6 -- Mais visível
        Page.ScrollBarImageColor3 = theme.Accent
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0

        createCorner(Page, theme.CornerRadius)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, theme.Padding) -- Usa o padding do tema
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.FillDirection = Enum.FillDirection.Vertical

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + theme.Padding * 2) -- Adiciona padding no final
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, -theme.Padding * 2, 0, 24) -- Ajusta tamanho com padding
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, theme.Padding, 0, 0) -- Adiciona padding lateral
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, theme.ButtonBackground, theme.Text)
            Btn.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            Btn.Position = UDim2.new(0, theme.Padding, 0, 0)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            ToggleBtn.Position = UDim2.new(0, theme.Padding, 0, 0)
            ToggleBtn.BackgroundColor3 = theme.TabBackground
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16
            ToggleBtn.AutoButtonColor = false

            createCorner(ToggleBtn, theme.SmallCornerRadius)

            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.TabBackground }):Play()
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
                if not state then -- Apenas se não estiver "ON"
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent * 0.8 }):Play() -- Um pouco mais escuro que Accent
                end
            end)
            ToggleBtn.MouseLeave:Connect(function()
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
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
            container.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            container.Position = UDim2.new(0, theme.Padding, 0, 0)
            container.BackgroundColor3 = theme.TabBackground
            container.BorderSizePixel = 0
            container.ClipsDescendants = true -- Para que o conteúdo do dropdown não vaze

            createCorner(container, theme.SmallCornerRadius)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center

            local dropdownFrame = Instance.new("Frame") -- Criado fora do container principal para controle de layout
            dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 0) -- Altura inicial 0
            dropdownFrame.BackgroundColor3 = theme.TabBackground
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 3 -- Garante que o dropdown apareça acima de outros elementos na página

            createCorner(dropdownFrame, theme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, theme.ControlPadding / 2)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.FillDirection = Enum.FillDirection.Vertical

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false

                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -theme.ControlPadding, 0, theme.ControlHeight)
                btn.Position = UDim2.new(0, theme.ControlPadding / 2, 0, 0)
                btn.BackgroundColor3 = theme.TabBackground
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.AutoButtonColor = false

                createCorner(btn, UDim.new(0, 4))

                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.TabBackground }):Play()
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
                        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent * 0.8 }):Play()
                    end
                end)
                btn.MouseLeave:Connect(function()
                    if not states[name] then
                        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
                    end
                end)
            end

            local expanded = false

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                header.Text = (expanded and "▾ " or "▸ ") .. title

                if expanded then
                    dropdownFrame.Parent = Page -- Move para a página para que UIListLayout a posicione
                    dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, listLayout.AbsoluteContentSize.Y + theme.ControlPadding)
                    -- Ajusta a posição Y do dropdownframe para aparecer logo abaixo do container pai no layout
                    -- O UIListLayout do Page já se encarregará disso se for um filho direto.
                    -- Se o container pai não for um Frame com ClipsDescendants, o dropdown pode ser flutuante.
                else
                    dropdownFrame.Parent = nil -- Remove temporariamente para não ocupar espaço
                    -- Ou você pode esconder: dropdownFrame.Visible = false
                end
                dropdownFrame.Visible = expanded
                -- Força uma atualização no CanvasSize do ScrollingFrame pai
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
            end)

            return {
                Set = function(_, item, value)
                    if states[item] ~= nil then
                        states[item] = value
                        if itemButtons[item] then
                            itemButtons[item].BackgroundColor3 = value and theme.Accent or theme.TabBackground
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
            container.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            container.Position = UDim2.new(0, theme.Padding, 0, 0)
            container.BackgroundColor3 = theme.TabBackground
            container.BorderSizePixel = 0
            container.ClipsDescendants = true

            createCorner(container, theme.SmallCornerRadius)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center
            header.AutoButtonColor = false

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 0) -- Altura inicial 0
            dropdownFrame.BackgroundColor3 = theme.TabBackground
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 3

            createCorner(dropdownFrame, theme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, theme.ControlPadding / 2)
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
                btn.Size = UDim2.new(1, -theme.ControlPadding, 0, theme.ControlHeight)
                btn.Position = UDim2.new(0, theme.ControlPadding / 2, 0, 0)
                btn.BackgroundColor3 = theme.TabBackground
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Text = name
                btn.AutoButtonColor = false

                createCorner(btn, UDim.new(0, 4))

                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    dropdownFrame.Parent = nil
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
                end)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                updateHeaderText()
                if expanded then
                    dropdownFrame.Parent = Page
                    dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, listLayout.AbsoluteContentSize.Y + theme.ControlPadding)
                else
                    dropdownFrame.Parent = nil
                end
                dropdownFrame.Visible = expanded
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
            SliderFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 40)
            SliderFrame.Position = UDim2.new(0, theme.Padding, 0, 0)
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
            SliderBar.BackgroundColor3 = theme.TabBackground
            SliderBar.BorderSizePixel = 0

            createCorner(SliderBar, UDim.new(0, 6))

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0

            createCorner(SliderFill, UDim.new(0, 6))

            local draggingSlider = false

            local function updateSliderValue(inputPos)
                local relativeX = math.clamp(inputPos.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
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
                    updateSliderValue(input.Position)
                    input.Handled = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSliderValue(input.Position)
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

    -- Carrega as configurações ao iniciar o menu
    local initialConfigData = readConfigFile(CONFIG_FILENAME)
    if initialConfigData then
        local ok, initialConfig = pcall(function() return HttpService:JSONDecode(initialConfigData) end)
        if ok and typeof(initialConfig) == "table" then
            for _, k in ipairs(themeConfigKeys) do
                if initialConfig[k] ~= nil then
                    if typeof(theme[k]) == "Color3" and typeof(initialConfig[k]) == "table" and #initialConfig[k] == 3 then
                        theme[k] = Color3.new(unpack(initialConfig[k]))
                    elseif k == "Opacity" then
                        theme[k] = tonumber(initialConfig[k]) or theme[k]
                    end
                end
            end
            applyTheme() -- Aplica o tema carregado
            setMenuOpacity(MainFrame, theme.Opacity)
        end
    end

    -- Inicializa na primeira aba se existir
    task.wait(0.1) -- Pequeno delay para garantir que todos os elementos estejam prontos
    if firstTabName ~= nil then
        switchToPage(firstTabName)
    end

    -- Adiciona a customização ao criar a janela
    createCustomizationTab(window, MainFrame, applyTheme)

    return window
end

return Library

