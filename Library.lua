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
local CONFIG_FILENAME = "custom_menu_config.json" -- Nome mais específico

-- Utilitários para leitura e escrita de arquivos
local function writeConfigFile(filename, content)
    local success, err = pcall(function()
        if typeof(writefile) == "function" then
            writefile(filename, content)
            return true
        elseif typeof(savefile) == "function" then -- Synapse X legacy
            savefile(filename, content)
            return true
        else
            error("Nenhuma função de escrita de arquivo (writefile/savefile) encontrada.")
        end
    end)
    if not success then
        warn("Erro ao escrever arquivo de configuração:", err)
    end
    return success
end

local function readConfigFile(filename)
    local content = nil
    local success, err = pcall(function()
        if typeof(readfile) == "function" then
            content = readfile(filename)
        elseif typeof(loadfile) == "function" then -- Fallback, though less ideal for pure config
            local res = loadfile(filename)
            if typeof(res) == "string" then content = res end
        else
            error("Nenhuma função de leitura de arquivo (readfile/loadfile) encontrada.")
        end
    end)
    if not success then
        warn("Erro ao ler arquivo de configuração:", err)
        return nil
    end
    return content
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
    Opacity = 0.95, -- Opacidade padrão ajustada
    Font = Enum.Font.Gotham,
    FontSize = 16,
    HeaderFontSize = 22,
}

local themeConfigKeys = {"Background", "TabBackground", "Accent", "Text", "Stroke", "ScrollViewBackground", "ButtonBackground", "Warning", "Opacity"}

-- Função para aplicar opacidade a todos os descendentes do frame principal
local function setMenuOpacity(mainFrame, opacityValue)
    -- Define a transparência de fundo diretamente usando a opacidade inversa
    -- Isso garante que a opacidade seja aplicada apenas a elementos que a suportam
    local function applyTransparency(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("ScrollingFrame") then
            -- Note: BackgroundTransparency é 1 para totalmente transparente, 0 para totalmente opaco
            obj.BackgroundTransparency = 1 - opacityValue
        end
        -- Para TextLabels, Color3.new(R,G,B, A) é o ideal, mas Roblox UI elements
        -- usam TextTransparency para texto e BackgroundTransparency para fundo.
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.TextTransparency = 1 - opacityValue
        end
        for _, child in ipairs(obj:GetChildren()) do
            applyTransparency(child)
        end
    end
    applyTransparency(mainFrame)
end

-- Funções utilitárias para criar elementos de UI
local function createCorner(parent, radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = radius or theme.CornerRadius
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
    label.TextSize = textSize or theme.FontSize
    label.TextColor3 = textColor or theme.Text
    label.Font = font or theme.Font
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function createTextButton(parent, text, callback, bgColor, textColor, font, textSize)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
    button.BackgroundColor3 = bgColor or theme.ButtonBackground
    button.Text = text
    button.TextColor3 = textColor or theme.Text
    button.Font = font or theme.Font
    button.TextSize = textSize or theme.FontSize
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
    local tab = windowInstance:CreateTab("Configurações", "⚙️") -- Nome da aba mais descritivo

    tab:AddLabel("Cor de Fundo do Menu")
    -- Adicionando mais opções de cores ou um ColorPicker mais avançado se possível
    local bgPicker = tab:AddSelectDropdown("Cor de Fundo", {"Padrão", "Vermelho", "Verde", "Azul", "Roxo", "Laranja"}, function(opt)
        local colors = {
            ["Padrão"] = Color3.fromRGB(30, 30, 30),
            ["Vermelho"] = Color3.fromRGB(120, 30, 30),
            ["Verde"] = Color3.fromRGB(30, 120, 30),
            ["Azul"] = Color3.fromRGB(30, 30, 120),
            ["Roxo"] = Color3.fromRGB(80, 30, 120),
            ["Laranja"] = Color3.fromRGB(120, 80, 30),
        }
        theme.Background = colors[opt] or theme.Background
        if applyThemeCallback then applyThemeCallback() end
    end)

    tab:AddLabel("Cor de Destaque (Accent)")
    local accentPicker = tab:AddSelectDropdown("Cor de Destaque", {"Padrão", "Cyan", "Magenta", "Amarelo"}, function(opt)
        local colors = {
            ["Padrão"] = Color3.fromRGB(0, 120, 255),
            ["Cyan"] = Color3.fromRGB(0, 200, 200),
            ["Magenta"] = Color3.fromRGB(200, 0, 200),
            ["Amarelo"] = Color3.fromRGB(200, 200, 0),
        }
        theme.Accent = colors[opt] or theme.Accent
        if applyThemeCallback then applyThemeCallback() end
    end)


    tab:AddLabel("Opacidade Global do Menu")
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
        local success = writeConfigFile(CONFIG_FILENAME, HttpService:JSONEncode(config))
        if success then
            print("Configuração salva com sucesso em:", CONFIG_FILENAME)
        else
            warn("Falha ao salvar configuração.")
        end
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
                print("Configuração carregada com sucesso.")
            else
                warn("Erro ao decodificar JSON da configuração ou formato inválido.")
            end
        else
            warn("Nenhuma configuração encontrada para carregar ou erro na leitura.")
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
    MainFrame.Draggable = false -- Custom drag implemented
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    createCorner(MainFrame, theme.CornerRadius)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1

    -- Título
    local Title = createTextLabel(MainFrame, name or "Menu", theme.HeaderFontSize, theme.Text, theme.Font, Enum.TextXAlignment.Left)
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.ZIndex = 2

    -- Botão minimizar
    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -40, 0, 5)
    BtnMinimize.BackgroundColor3 = theme.TabBackground
    BtnMinimize.Text = "–"
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
    createCorner(TabContainer, UDim.new(0, 6))

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
    local currentActiveTabButton = nil

    local minimized = false

    local dragConnections = {} -- Table to store drag connections

    local function connectDragEvents()
        dragConnections.InputBegan = MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.Position.Y <= (MainFrame.AbsolutePosition.Y + 40) then -- Only drag from title bar
                    local dragStart = UserInputService:GetMouseLocation()
                    local startPos = MainFrame.Position
                    local dragInputChangedConn
                    dragInputChangedConn = UserInputService.InputChanged:Connect(function(changedInput)
                        if (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                            local delta = UserInputService:GetMouseLocation() - dragStart
                            MainFrame.Position = UDim2.new(
                                startPos.X.Scale, startPos.X.Offset + delta.X,
                                startPos.Y.Scale, startPos.Y.Offset + delta.Y
                            )
                        end
                    end)
                    local dragInputEndedConn
                    dragInputEndedConn = UserInputService.InputEnded:Connect(function(endedInput)
                        if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                            dragInputChangedConn:Disconnect()
                            dragInputEndedConn:Disconnect()
                        end
                    end)
                    input.Handled = true
                end
            end
        end)
    end

    local function disconnectDragEvents()
        if dragConnections.InputBegan then
            dragConnections.InputBegan:Disconnect()
            dragConnections.InputBegan = nil
        end
    end

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 40) }):Play() -- Slightly wider for better look
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
            Title.TextXAlignment = Enum.TextXAlignment.Center -- Center title when minimized
            disconnectDragEvents()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
            Title.TextXAlignment = Enum.TextXAlignment.Left
            connectDragEvents()
            -- Ensure opacity is reapplied after maximize
            setMenuOpacity(MainFrame, theme.Opacity)
        end
    end)

    local function switchToPage(name, button)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
            if pgName == name then
                setMenuOpacity(pg, theme.Opacity) -- Ensure active page has correct opacity
            end
        end

        -- Update visual state of tab buttons
        if currentActiveTabButton then
            TweenService:Create(currentActiveTabButton, TweenInfo.new(0.2), { BackgroundColor3 = theme.TabBackground }):Play()
            createTextLabel(currentActiveTabButton, currentActiveTabButton.Text, nil, theme.Text):Destroy() -- Remove old text label
        end
        if button then
            TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
            currentActiveTabButton = button
            local icon, text = string.match(button.Text, "^(%S+)%s+(.*)$") -- Extract icon and text
            local newLabel = createTextLabel(button, text or "", theme.FontSize, theme.Text, theme.Font, Enum.TextXAlignment.Left)
            newLabel.Size = UDim2.new(1, -30, 1, 0) -- Adjust size for icon
            newLabel.Position = UDim2.new(0, 30, 0, 0)
            if icon then
                local iconLabel = createTextLabel(button, icon, 18, theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                iconLabel.Size = UDim2.new(0, 24, 1, 0)
                iconLabel.Position = UDim2.new(0, 6, 0, 0)
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
        resizeFrame.Draggable = false

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
        Button.Size = UDim2.new(1, -12, 0, theme.TabButtonHeight)
        Button.Position = UDim2.new(0, 6, 0, 0)
        Button.BackgroundColor3 = theme.TabBackground
        Button.TextColor3 = theme.Text
        Button.Font = theme.Font
        Button.TextSize = theme.FontSize
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
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent * 0.8 }):Play() -- Slightly darker accent for hover
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
        Page.ScrollBarThickness = 8 -- More visible
        Page.ScrollBarImageColor3 = theme.Accent
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0

        createCorner(Page, theme.CornerRadius)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, theme.Padding)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.FillDirection = Enum.FillDirection.Vertical

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + theme.Padding * 2)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text, horizontalAlignment)
            local Label = createTextLabel(Page, text, theme.FontSize, theme.Text, theme.Font, horizontalAlignment or Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, -theme.Padding * 2, 0, 24)
            Label.Position = UDim2.new(0, theme.Padding, 0, 0)
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, theme.ButtonBackground, theme.Text)
            Btn.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            Btn.Position = UDim2.new(0, theme.Padding, 0, 0)
            return Btn
        end

        function tab:AddToggle(text, initialValue, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            ToggleBtn.Position = UDim2.new(0, theme.Padding, 0, 0)
            ToggleBtn.BackgroundColor3 = theme.TabBackground
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = theme.Font
            ToggleBtn.TextSize = theme.FontSize
            ToggleBtn.AutoButtonColor = false

            createCorner(ToggleBtn, theme.SmallCornerRadius)

            local state = initialValue or false
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
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent * 0.8 }):Play()
                end
            end)
            ToggleBtn.MouseLeave:Connect(function()
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
                end
            end)

            return {
                Set = function(_, value)
                    state = value
                    updateToggleVisual()
                end,
                Get = function()
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
            container.ClipsDescendants = true

            createCorner(container, theme.SmallCornerRadius)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = theme.FontSize
            header.Font = theme.Font
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center
            header.AutoButtonColor = false

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 0)
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

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false

                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -theme.ControlPadding, 0, theme.ControlHeight)
                btn.Position = UDim2.new(0, theme.ControlPadding / 2, 0, 0)
                btn.BackgroundColor3 = theme.TabBackground
                btn.TextColor3 = theme.Text
                btn.Font = theme.Font
                btn.TextSize = theme.FontSize - 2
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
                    dropdownFrame.Parent = Page
                    dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, listLayout.AbsoluteContentSize.Y + theme.ControlPadding)
                else
                    dropdownFrame.Parent = nil
                end
                dropdownFrame.Visible = expanded
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
            header.TextSize = theme.FontSize
            header.Font = theme.Font
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center
            header.AutoButtonColor = false

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 0)
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
                btn.Font = theme.Font
                btn.TextSize = theme.FontSize - 2
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

            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), theme.FontSize - 2, theme.Text, theme.Font, Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)

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
            local currentValue = default

            local function updateSliderValue(inputPos)
                local relativeX = math.clamp(inputPos.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percent)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
                currentValue = value
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
                Set = function(_, value)
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    currentValue = value
                    if callback then
                        callback(value)
                    end
                end,
                Get = function()
                    return currentValue
                end,
                _instance = SliderFrame
            }
        end

        return tab

    end

    -- Aplica o tema ao iniciar
    local function applyTheme()
        MainFrame.BackgroundColor3 = theme.Background
        TabContainer.BackgroundColor3 = theme.TabBackground
        PageContainer.BackgroundColor3 = theme.Background
        Title.TextColor3 = theme.Text
        BtnMinimize.BackgroundColor3 = theme.TabBackground
        BtnMinimize.TextColor3 = theme.Text
        UIStroke.Color = theme.Stroke
        -- Re-aplicar opacidade a todos os elementos
        setMenuOpacity(MainFrame, theme.Opacity)

        -- Atualizar cores de elementos existentes (ex: botões de aba)
        for tabName, page in pairs(pages) do
            local tabButton = TabContainer:FindFirstChildOfClass("TextButton", function(btn) return btn.Text:find(tabName) end) -- Find tab button by name
            if tabButton then
                if tabButton == currentActiveTabButton then
                    tabButton.BackgroundColor3 = theme.Accent
                else
                    tabButton.BackgroundColor3 = theme.TabBackground
                end
                tabButton.TextColor3 = theme.Text
            end
            -- Para os controles dentro das páginas, seria necessário iterar ou ter referências diretas
            -- Para simplicidade aqui, vamos apenas garantir que a opacidade seja aplicada globalmente.
        end
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
        else
            warn("Erro ao carregar ou decodificar configuração inicial.")
        end
    end
    setMenuOpacity(MainFrame, theme.Opacity) -- Apply initial opacity to all elements

    -- Inicializa na primeira aba se existir
    task.wait(0.1) -- Small delay to ensure all elements are ready
    if firstTabName ~= nil then
        -- Find the button for the first tab and set it as active
        local firstTabButton = TabContainer:FindFirstChildOfClass("TextButton", function(btn)
            -- Check for exact text match or with icon prefix
            return btn.Text == firstTabName or btn.Text:find("  "..firstTabName, 1, true)
        end)
        switchToPage(firstTabName, firstTabButton)
    end

    -- Conecta os eventos de arrastar após a criação completa do menu
    connectDragEvents()

    -- Adiciona a customização ao criar a janela
    createCustomizationTab(window, MainFrame, applyTheme)

    return window
end

return Library
